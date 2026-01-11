-- Created database

create database pizza_sales;

-- Changed incorrect data types

 alter table orders
 modify column `date` date,
 modify column `time` time;
                                      
-- What is the Total Revenue?

select format(sum(price*quantity),2) as Total_revenue
from order_details as o
 join pizzas as p
  on o.pizza_id = p.pizza_id;
  
-- What is the Average Order Value?

select concat('$',format(sum(price*quantity)/count(distinct order_id),2)) as Average_order_value
from order_details as o
 join pizzas as p
  on o.pizza_id = p.pizza_id;

-- How many Pizza's were sold?

 select format(sum(quantity),0) as Total_quanity
 from order_details;
 
-- How many orders were placed?

select format(count(distinct order_id),0) as Total_orders
from order_details;	

-- What is the Average Pizza's Per Order?

select round(sum(quantity)/count(distinct order_id)) as Average_per_order
from order_details;

-- Which day of the week we got most orders throughout the year?

select dayname(`date`) as Week_day,format(count(distinct order_id),0) as Total_orders
from orders
group by Week_day 
order by Total_orders desc;

-- Which month we got most orders?

select monthname(`date`) as Month_name,format(count(distinct order_id),0) as Total_orders
from orders
group by Month_name
order by Total_orders desc;

-- What percentage of sales contributed by each Pizza Category?

with Overall_sales as
(select format(sum(price*quantity),2) as Total_sales 
 from order_details as o
  join pizzas as p
   on o.pizza_id = p.pizza_id),
   
sales_by_category as 
(select t.category,
   format(sum(price*quantity),2) as category_sales
from order_details as o
 join pizzas as p
 on o.pizza_id = p.pizza_id
 join pizza_types as t
  on p.pizza_type_id = t.pizza_type_id
group by t.category)

select Category,
 concat('$',category_sales) as Total_sales,
 concat(round(100*(category_sales/Total_sales),2),'%') as Percentage_contribution
from Overall_sales,sales_by_category
order by percentage_contribution desc;

-- How many Pizza's were sold by each Category?

select Category,format(sum(quantity),0) as Total_quantity
from order_details as o
 join pizzas as p
  on o.pizza_id = p.pizza_id
 join pizza_types as t
  on p.pizza_type_id = t.pizza_type_id
group by category
order by Total_quantity desc;

-- What are the Top 5 Pizza's by revenue?

select `name` as Name_of_Pizza,concat('$',format(sum(price*quantity),0)) as Total_revenue
from order_details as o
 join pizzas as p
  on o.pizza_id = p.pizza_id
 join pizza_types as t
  on p.pizza_type_id = t.pizza_type_id
group by Name_of_Pizza
order by Total_revenue desc
limit 5;

-- What are the Bottom 5 Pizza's by revenue?

select `name` as Name_of_Pizza,concat('$',format(sum(price*quantity),0)) as Total_revenue
from order_details as o
 join pizzas as p
  on o.pizza_id = p.pizza_id
 join pizza_types as t
  on p.pizza_type_id = t.pizza_type_id
group by Name_of_Pizza
order by Total_revenue asc
limit 5;

-- What are the Top 5 Pizza's by quantity?

select `name`as Name_of_Pizza,sum(quantity) as Total_quantity
from order_details as o
 join pizzas as p
  on o.pizza_id = p.pizza_id
 join pizza_types as t
  on p.pizza_type_id = t.pizza_type_id
group by Name_of_Pizza
order by Total_quantity desc
limit 5;

-- What are the Bottom 5 Pizza's by quantity?

select `name` as Name_of_Pizza,sum(quantity) as Total_quantity
from order_details as o
 join pizzas as p
  on o.pizza_id = p.pizza_id
 join pizza_types as t
  on p.pizza_type_id = t.pizza_type_id
group by Name_of_Pizza
order by Total_quantity asc
limit 5;

-- What are the Top 5 Pizza's by Orders?

select `name` as Name_of_Pizza,count(distinct order_id) as Total_orders
from order_details as o
 join pizzas as p
  on o.pizza_id = p.pizza_id
 join pizza_types as t
  on p.pizza_type_id = t.pizza_type_id
group by Name_of_Pizza
order by Total_orders desc
limit 5;

-- What are the Bottom 5 Pizza's by Orders?

with cte as 
(select `name` as Name_of_Pizza,count(distinct order_id) as Total_orders,
dense_rank() over(order by count(distinct order_id) asc) as Ranks
from order_details as o
 join pizzas as p
  on o.pizza_id = p.pizza_id
 join pizza_types as t
  on p.pizza_type_id = t.pizza_type_id
group by `name`)

select *
from cte 
where Ranks <= 5;

-- Which Time most Pizza's were sold?

select 
case when time_format(`time`,'%H') between 09 and 11 then 'Morning'
	 when time_format(`time`,'%H') between 12 and 17 then 'Afternoon'
     when time_format(`time`,'%H') between 18 and 23 then 'Evening'
     else 'Night' end as Time_of_day,
     format(sum(quantity),0) as Total_pizzas
from order_details as d
 join orders as o
  on o.order_id = d.order_id
group by Time_of_day
order by Time_of_day;
