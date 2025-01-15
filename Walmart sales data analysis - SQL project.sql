create database walmart;
use walmart;
create table if not exists sales(
invoice_id varchar(30) not null primary key,
branch varchar(5) not null,
city varchar(30) not null,
customer_type varchar(30) not null,
gender varchar(10) not null,
product_line varchar(100) not null,
unit_price decimal(10,2) not null,
quantity INT(20) not null,
vat FLOAT(6,4) not null,
total decimal(12,4) not null,
date DATETIME not null,
time TIME not null,
payment varchar(15) not null,
cogs decimal(10,2) not null,
gross_margin_pct float(11,9),
gross_income DECIMAL(12,4),
rating float(2,1)
);
show GLOBAL variables LIKE 'local_infile';
SET GLOBAL local_infile = 1;

load data local infile 
"C:\Users\DELL\Downloads\Walmart Sales Data.csv.csv"
INTO TABLE sales
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 1. Time_of_day
select time, 
(case
		WHEN 'time' BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN 'time' BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
END) AS time_of_day
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);
SET SQL_SAFE_UPDATES=0;	
UPDATE sales
SET time_of_day = (
        CASE
                 WHEN 'time' BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
                 WHEN 'time' BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
                 ELSE "Evening"
		END
);

-- 2. Day_name
select date, 
DAYNAME(date) AS day_name
from sales;

ALTER TABLE sales add column day_name varchar(10);
update sales 
SET day_name = DAYNAME(date);

-- 3. month_name
select date,
MONTHNAME(date) AS month_name
from sales;

alter table sales add column month_name varchar(10);
update sales 
SET month_name = MONTHNAME(date);

-- 1. How many distinct cities are present in the dataset?
SELECT DISTINCT city FROM sales;

-- 2. in which city is each branch situated?
select distinct branch, city from sales;


-- Product analysis
-- 1. how many distinct product lines are there in the dataset?
select count(distinct product_line) from sales;

-- 2. what is the most common payment method ?
select payment, count(payment) as common_payment_method
from sales group by payment order by common_payment_method desc limit 1;

-- 3. what is the most selling product line?
select product_line, count(product_line) as most_selling_product
from sales group by product_line order by most_selling_product desc limit 1;

-- 4 . what is the total revenue by month?
select month_name, sum(total) as total_revenue
from sales group by month_name order by total_revenue desc;

-- 5. which month recorded the highest cost of goods sold (cogs)?
select month_name, sum(cogs) as total_cogs
from sales group by month_name order by total_cogs desc;

-- 6. which product line generated the highest revenue?
select product_line, sum(total) as total_revenue
from sales group by product_line  order by total_revenue desc limit 1;

-- 7. which city has the highest revenue?
select city, sum(total) as total_revenue 
from sales group by city order by total_revenue desc limit 1;

-- 8. which product line incurred the highest VAT?
select product_line, sum(vat) as vat
from sales group by product_line order by VAT desc limit 1;

-- 9. Retrieve each product line and add a column product_category, indicating 'Good', or 'bad'  based in whether its sales.
alter table sales add column product_category varchar(20);
update sales 
SET product_category = 
(CASE
		WHEN total >= (select avg(total) from sales) then "Good"
	ELSE "Bad"
end)from sales;

-- 10. which branch sold more products than average product sold?
select branch, sum(quantity) as quantity
from sales group by branch having sum(quantity) > avg(quantity) order by quantity desc limit 1;

-- 11. what is the most common product line by gender?
select gender, product_line, count(gender) total_count 
from sales group by gender, product_line order by total_count desc;

-- 12. what is the average rating of each product line?
select product_line, round(avg(rating),2) average_rating
from sales group by product_line order by average_rating desc;

-- Sales Analysis
-- 1. number of sales made in each time of the day per weekday.
select day_name, time_of_day, count(invoice_id) as total_sales
from sales group by day_name, time_of_day having day_name not in ('sunday', 'saturday');
select day_name, time_of_day, count(*) as total_sales
from sales where day_name not in ('saturday', 'sunday') group by day_name, time_of_day;

-- 2. Identify the customer type that generates the highest revenue.
select customer_type, sum(total) as total_sales
from sales group by customer_type order by total_sales desc limit 1;

-- 3. which city has the largest tax percent / Vat(value added tax)?
select city, sum(vat) as total_vat
from sales group by city order by total_vat desc limit 1;

-- 4. which customer type pays the most in vat?
select customer_type,  sum(vat) as total_vat
from sales group by customer_type order by total_vat desc limit 1;

-- Customer Analysis
-- 1. how many unique customer types does the data have?
select count(distinct customer_type ) from sales;
-- 2. how many unique payment methods does the data have?
select count(distinct payment) from sales;
-- 3. which is the most common customer type?
select customer_type, count(customer_type) as common_customer
from sales group by customer_type order by common_customer desc limit 1;
-- 4. which customer type buys the most?
select customer_type, count(*) as most_buyer
from sales group by customer_type order by most_buyer desc limit 1;
-- 5. what is the gender of most of the customers?
select gender, count(*) as all_genders
from sales group by gender order by all_genders desc limit 1;
-- 6. what is the gender distribution per branch?
select branch,gender, count(gender)as gender_distribution
from sales group by branch,gender order by branch;
-- 7. which time of the day do customers give most ratings?
select time_of_day,avg(rating)as most_rating
from sales group by time_of_day order by most_rating desc limit 1;
-- 8. which day of the week has the best average ratings per branch?
select branch,day_name, avg(rating) as average_rating
from sales group by day_name,branch order by average_rating desc;


	 																																																										



