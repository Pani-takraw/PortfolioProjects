Use gdb023;

-- Provide the list of markets in which customer "Atliq Exclusive" operates its business in the APAC region
Select DISTINCT(market) from dim_customer
Where customer = 'Atliq Exclusive' and region = "APAC";

-- What is the percentage of unique product increase in 2021 vs. 2020?
With cte1 as (
Select fiscal_year, COUNT(distinct(product_code)) as unique_products_2021 
from fact_sales_monthly
Where  fiscal_year = 2021),
cte2 as (
Select fiscal_year, COUNT(distinct(product_code)) as unique_products_2020 
from fact_sales_monthly
Where  fiscal_year = 2020)
Select unique_products_2020, unique_products_2021,
	((unique_products_2021-unique_products_2020)/unique_products_2020)*100 as pct_increase from cte1, cte2;

-- Provide a report with all the unique product counts for each segment
Select segment, COUNT(DISTINCT product_code) as product_count 
From dim_product
	Group by segment
	order by product_count desc;

-- Which segment had the most increase in unique products in 2021 vs 2020?
Select gp.fiscal_year,pr.segment, COUNT(distinct(gp.product_code)) as product_count 
from dim_product pr
Join fact_gross_price gp
	on pr.product_code = gp.product_code
Where gp.fiscal_year IN (2021,2020)
	Group by gp.fiscal_year, pr.segment
	Order by product_count desc ;

-- Get the products that have the highest and lowest manufacturing costs
Select m.product_code, p.product, m.manufacturing_cost
From fact_manufacturing_cost m
Join dim_product p 
	on m.product_code = p.product_code
Where manufacturing_cost = (Select max(manufacturing_cost) from fact_manufacturing_cost)
			or manufacturing_cost = (Select min(manufacturing_cost) from fact_manufacturing_cost);
    
-- Generate a report which contains the top 5 customers who received an average high pre_invoice_discount_pct 
-- for the fiscal year 2021 and in the Indian market.
Select pr.customer_code,c.customer, 
	ROUND(Avg(pre_invoice_discount_pct),3) as average_discount_pct  
From fact_pre_invoice_deductions pr
Join dim_customer c
    On pr.customer_code = c.customer_code
Where pr.fiscal_year = 2021 and c.market = 'India'
    Group by pr.customer_code
    Order by average_discount_pct desc
    Limit 5;

-- Get the complete report of the Gross sales amount for the customer “Atliq Exclusive” for each month
Select *  
from fact_gross_price gp
Join fact_sales_monthly sm
	on gp.product_code = sm.product_code
AND gp.fiscal_year = sm.fiscal_year
Join dim_customer c
	on c.customer_code = sm.customer_code
where customer  = 'Atliq Exclusive'
	limit 10000000;

-- In which quarter of 2020, got the maximum total_sold_quantity
Select date, 
	CASE 	 when Month(date) IN (9,10,11) then "Q1"
		 When  Month(date) IN (12,1,2) then "Q2"
        	 When Month(date) IN (3,4,5) then "Q3"
		 Else "Q4" 
    	End  as Quarter,
Sum(sold_quantity)/1000000 as total_sold_quantity
From fact_sales_monthly
WHERE fiscal_year = 2020
	group by Quarter
	order by  total_sold_quantity desc;

-- Which channel helped to bring more gross sales in the fiscal year 2021 and the percentage of contribution
Select c.channel, gp.gross_price, sm.sold_quantity,SUM(gross_price * sold_quantity)/10000000 as gross_sales_mln 
from fact_gross_price gp
Join fact_sales_monthly sm
	on gp.product_code = sm.product_code
	AND gp.fiscal_year = sm.fiscal_year
Join dim_customer c
	on c.customer_code = sm.customer_code
Group by channel;

-- Get the Top 3 products in each division that have a high total_sold_quantity in the fiscal_year 2021
with cte as (
Select p.division, p.product_code, p.product, fm.sold_quantity,SUM(sold_quantity) as total_sold_quantity
From dim_product p
Join fact_sales_monthly fm
	on p.product_code = fm.product_code
where fm.fiscal_year = 2021
	Group by p.division, p.product_code, p.product),
cte2 as(
Select *,
	Rank() Over(partition by division order by total_sold_quantity desc)  as Top_3
from cte)
Select * from cte2
Where Top_3 IN (1,2,3)
