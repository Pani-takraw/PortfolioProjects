-- To use schema
Use gdb023;

-- To Get the current date
Select CURDATE();
-- To get the current date along with time
Select NOW();

-- To change date to a specific format
Select date_format(NOW(), '%D %M %Y') ;

-- To get name of day of date
Select dayname(Now());

-- To get Month, Year, Day of date
Select month(Now());
Select year(Now());
Select day(Now());
Select weekday(Date('2023/01/12'));
Select week(Now(),1);
Select quarter(Date('2023/04/12'));

-- Time Series Analysis
-- Simple Trend
-- Total revenue by each day 
Select sales_month, sales 
from us_retail
Where kind_of_business = 'Retail and food services sales, total';

-- Sales by year 
Select year(sales_month) as sales_year
, sum(sales) 
from us_retail
Where kind_of_business = 'Retail and food services sales, total'
Group by 1;

-- Sales by monthname
Select monthname(sales_month) as sales_month
, sum(sales) 
from us_retail
Where kind_of_business = 'Retail and food services sales, total'
Group by 1;

-- Sales by weeks
Select week(sales_month) as sales_month
, sum(sales) 
from us_retail
Where kind_of_business = 'Retail and food services sales, total'
Group by 1
order by 1 asc;

-- Sales comparisons across different business with aggregation
Select Year(sales_month) as sales_year,
kind_of_business
, sum(sales) 
from us_retail
Where kind_of_business in('Book Stores', 'Sporting goods stores',
'Hobby, toy, and game stores')
Group by 1,2;

-- Comparison without aggregation
Select sales_month, kind_of_business
, sales 
from us_retail
Where kind_of_business in (
'Men''s clothing stores', 'Women''s clothing stores');

-- Comparison with aggregation
Select Year(sales_month) as sales_year, kind_of_business
, SUM(sales) 
from us_retail
Where kind_of_business in (
'Men''s clothing stores', 'Women''s clothing stores')
Group by 1,2;

-- Difference calculation between two business
Select sales_year,
women_sales - men_sales as women_minus_men,
men_sales - women_sales as men_minus_women 
From(
Select Year(sales_month) as sales_year, 
Sum(Case When kind_of_business = 'Women''s clothing stores' Then sales End) as Women_sales,
Sum(Case When kind_of_business = 'Men''s clothing stores' Then sales End) as men_sales
from us_retail
Where kind_of_business in (
'Men''s clothing stores', 'Women''s clothing stores')
Group by 1) a;

-- Percentage calculation between two business
Select sales_year,
(women_sales/ men_sales - 1) * 100  as women_pct_men
From(
Select Year(sales_month) as sales_year, 
Sum(Case When kind_of_business = 'Women''s clothing stores' Then sales End) as Women_sales,
Sum(Case When kind_of_business = 'Men''s clothing stores' Then sales End) as men_sales
from us_retail
Where kind_of_business in (
'Men''s clothing stores', 'Women''s clothing stores')
Group by 1) a;

-- Percentage of total calculations
Select sales_month, kind_of_business, sales
, sum(sales) over (partition by sales_month) as total_sales
, sales * 100 / sum(sales) over(partition by sales_month) as pct_sales
From us_retail
Where  kind_of_business in (
'Men''s clothing stores', 'Women''s clothing stores');

-- Percentage over time 
Select sales_month, kind_of_business, sales,
Sum(sales) over (partition by year(sales_month), kind_of_business) as yearly_sales,
sales * 100 / Sum(sales) over (partition by year(sales_month), kind_of_business) as pct_yearly
From us_retail
Where  kind_of_business in (
'Men''s clothing stores', 'Women''s clothing stores');

-- Indexing
Select sales_year, sales,
	first_value(sales) over (order by sales_year) as index_sales 
From(
Select Year(sales_month) as sales_year, 
	sum(sales) as sales
    From us_retail
Where kind_of_business = 'Women''s clothing stores'
Group by 1 
 ) a ;   

-- Percentage increase/decrease with index value
Select sales_year, kind_of_business, sales,
	(sales / first_value(sales) over (partition by kind_of_business order by sales_year) - 1) * 100 as pct_from_index 
From(
Select Year(sales_month) as sales_year, 
	kind_of_business,
    sum(sales) as sales
    From us_retail
Where kind_of_business in (
'Men''s clothing stores', 'Women''s clothing stores')
Group by 1, 2
 ) a ;

-- Rolling Time Windows
Select sales_month, sales,
	avg(sales) over (order by sales_month
						rows between 11 preceding and current row
                        ) as moving_avg,
	count(sales) over (order by sales_month
						rows between 11 preceding and current row
                        ) as records_count
From us_retail
Where kind_of_business = 'Women''s clothing stores' 
group by 1,2;


-- Cumulative totals
Select sales_month, sales,
	sum(sales) over (partition by year(sales_month) order by sales_month) as sales_ytd
From us_retail
Where kind_of_business = 'Women''s clothing stores'; 


-- Period over period comparison
Select kind_of_business, sales_month, sales,
lag(sales_month) Over (partition by kind_of_business order by sales_month) as prev_month,
lag(sales) Over (partition by kind_of_business order by sales_month) as prev_month_sales
From us_retail
Where kind_of_business = 'Book stores';

-- Yearly level
Select sales_year, yearly_sales,
lag(yearly_sales) over (order by sales_year) as prev_year_sales,
(yearly_sales / lag(yearly_sales) over (order by sales_year) - 1 ) *100 as pct_growth
From
(
Select year(sales_month) as sales_year, sum(sales) as yearly_sales
From us_retail
Where kind_of_business = 'Book stores'
Group by 1) a;

-- Previous Year Month comparison
Select sales_month, sales,
sales - lag(sales) over (partition by Month(sales_month) order by sales_month) as absolute_diff,
(sales / lag(sales) over (partition by Month(sales_month) order by sales_month) -1 ) *100 as pct_diff
 From us_retail
 Where kind_of_business = 'Book stores';
 
-- Pivoting
Select Month(sales_month) as Month_num,
monthname(sales_month) as Month_name,
Max(Case When Year(sales_month) = 1992 Then sales end) as sales_1992, 
Max(Case When Year(sales_month) = 1993 Then sales end) as sales_1993,
Max(Case When Year(sales_month) = 1994 Then sales end) as sales_1994
From us_retail
Where kind_of_business = 'Book stores'
	and sales_month between '1992-01-01' and '1994-12-01'
group by 1,2;


-- Multiple period comparisons
select sales_month, sales,
(sales / avg(sales) over(partition by month(sales_month) order by sales_month
								rows between 3 preceding and 1 preceding)) * 100 as pct_of_prev3
From us_retail
Where kind_of_business = 'Book stores';
