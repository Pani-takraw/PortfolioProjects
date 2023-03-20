-- To use schema
Use pizza_sales;

-- To get all columns from fact table
Select * From fact;

-- To calculate total revenue/sales per order
SELECT *, quantity*price as sales FROM pizza_sales.fact;

-- Total revenue
Select ROUND(SUM(quantity*price),2) as sales From fact;

-- Total Quantity ordered
Select SUM(quantity) From fact;

-- Total revenue by pizza size
Select size,  ROUND(SUM(quantity*price),2) as sales From fact
group by size
order by sales desc;

-- Total revenue by day
Select monthname(date),  ROUND(SUM(quantity*price),2) as sales From fact
group by 1
order by sales;
	
-- Total revenue by size
Select size,  ROUND(SUM(quantity*price),2) as sales From fact
group by size
order by sales;

-- Total revenue by category
Select pt.category, ROUND(SUM(quantity*price),2) as sales From fact f
join pizza_types pt
on pt.pizza_type_id = f.pizza_type_id
Group by pt.category;


-----------------------------------------------------------------------------------------------

-- Orders sheet

-- Total quantity by size
Select size, Sum(quantity) as quan from fact
group by size
order by quan desc;

-- Total order % by category
with cte1 as (
Select COUNT(order_id)as total from fact),
cte2 as (
Select category, Count(order_id) as orders from fact f
	Join pizza_types pt
		On f.pizza_type_id = pt.pizza_type_id
Group by 1)
Select category, (orders/total)*100 as pct from cte1, cte2;


-- Pizzas with most orders
Select pizza_id, COUNT(order_id) as orders from fact
group by 1
order by orders desc
Limit 5;

-- Pizzas with least orders
Select pizza_id, COUNT(order_id) as orders from fact
group by 1
order by orders 
Limit 5;


-----------------------------------------------------------------------------------------------


-- Times Series
-- Orders by month
Select monthname(date), count(order_id) from fact
Group by 1;


Select dayname(date), ROUND(SUM(quantity * price),3) as revenue from fact
group by 1
order by revenue desc;

-- Total orders by hour
Select Hour(time), count(order_id) as orders from fact
Group by 1
Order by orders desc;


















