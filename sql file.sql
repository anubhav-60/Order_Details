ALTER TABLE od.order_detail
DROP COLUMN MyUnknownColumn
-- Find top 10 highest revenue generating products
select Product_id, round(sum(Quantity*Sale_price),2) as Revenue
from od.order_detail
group by Product_id
order by sum(Quantity*Sale_price) desc
limit 10

-- Top 5 highest selling products in each region
with cte1 as 
(select Region, Product_id, sum(Quantity) as Sales
from od.order_detail
group by Region, Product_id
order by Region, Sales desc
),
cte2 as (
select *, dense_rank() over (partition by Region order by Sales desc) as rnk
from cte1
)
select * from cte2
where rnk<=5

-- Find month over month growth comparison for year 2022 and 2023 
with cte2022 as (
select monthname(Order_date) as month_name, round(sum(Quantity*Sale_price),2) as Revenue
from order_detail
where year(Order_date)=2022
group by month_name
),
cte2023 as (
select monthname(Order_date) as month_name, round(sum(Quantity*Sale_price),2) as Revenue
from order_detail
where year(Order_date)=2023
group by month_name
)
select c1.month_name, c1.Revenue, c2.Revenue, round(abs(c1.Revenue-c2.Revenue)*100/c1.Revenue,2) as Growth_per
from cte2022 c1
join cte2023 as c2 on c1.month_name=c2.month_name
order by month_name

-- For each category which month had highest sales
with cte1 as (
select Category, Date_format(Order_date, "%Y-%m") as month_name, round(sum(Quantity*Sale_price),2) as Sales
from order_detail
group by Category, month_name
),
cte2 as (
select *, row_number() over (partition by Category order by Sales desc) as rnk
from cte1
)
select Category,  month_name, Sales from cte2 where rnk=1

-- Which sub_category had highest growth by profit in 2023 compare to 2022
with cte2022 as (
select Sub_category, round(sum(Profit),2) as profit_22
from order_detail
where year(Order_date)=2022
group by Sub_category
),
cte2023 as (
select Sub_category, round(sum(profit),2) as profit_23
from order_detail
where year(Order_date)=2023
group by Sub_category
),
tte3 as 
(select c1.Sub_Category, c1.profit_22, c2.profit_23, ((c2.profit_23-c1.profit_22)/c1.profit_22)*100 as Growth
from cte2022 c1
join cte2023 c2 on c1.Sub_category=c2.Sub_category
)
select * from tte3
order by Growth desc
limit 1