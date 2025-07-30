-- Let's all we have in the table 
select * from `supermarket_sales new`;

-- creating a duplicate of the original table
create table supermarket_sales_reviewed
 as select * from `supermarket_sales new`
;

-- Lets confirm whats in the new table created
select * from supermarket_sales_reviewed;

-- Seeing through the specifics in each column
select distinct(`customer type`) from supermarket_sales_reviewed;
select distinct(`Product line`) from supermarket_sales_reviewed;
select distinct(`city`) from supermarket_sales_reviewed;
select distinct(`branch`) from supermarket_sales_reviewed;

-- Doing little cleaning by rounding the tax to two decimal places
update supermarket_sales_reviewed
set `tax 5%` = round(`tax 5%`,2);

-- inserting a column for the total price paid by each customer
alter table supermarket_sales_reviewed
add Total_Price int;

update supermarket_sales_reviewed
set Total_Price = round((`unit price` * quantity),2);
-- Let's now see our table
select * from supermarket_sales_reviewed;
-- What is the total amount made at the supermarket?
select sum(total_price) from supermarket_sales_reviewed;
-- What's the average amount made?
select avg(total_price) from supermarket_sales_reviewed;
-- How many people visited?
select count(gender) from supermarket_sales_reviewed;
-- How many are the people by gender?
select count(gender) from supermarket_sales_reviewed where gender = 'male';
select count(gender) from supermarket_sales_reviewed where gender = 'female'; 
-- What is the highest amount made?
-- Who spent that amount? Where was it spent and which product line? 
select * from supermarket_sales_reviewed order by total_price desc limit 1;

-- What is the amount made per each product line?
-- Which product line sold most and least?
-- How many people patronised each product line?
-- Which product line has the highest and least patronage ?
with PL_distinct as(
select `Product line`, total_price, count(`Product line`) over (partition by `Product line`) as Total_Patrons_Per_Product_Line, 
sum(Total_price) over (partition by `Product line`) as Total_Made_Per_Product_Line

from supermarket_sales_reviewed )
select distinct(`Product line`) as Product_Line,Total_Patrons_Per_Product_Line,Total_Made_Per_Product_Line 
from PL_distinct order by Total_Made_Per_Product_Line desc;

-- Lets see what is happening at the branches
select * from supermarket_sales_reviewed
where Branch = 'A'
;
select * from supermarket_sales_reviewed
where Branch = 'B'
;
select * from supermarket_sales_reviewed
where Branch = 'C'
; 
-- Which branch made the most sales?
select Branch, sum(Total_Price) as  Total_Sales_By_Branch from supermarket_sales_reviewed group by Branch order by  Total_Sales_By_Branch desc; 
-- Which branch made the highest singular sale?
select Branch, max(Total_Price) as Highest_Sale from supermarket_sales_reviewed group by Branch order by Highest_Sale desc;
-- What is the average sale per branch?
select Branch, avg(Total_Price) from supermarket_sales_reviewed group by Branch order by Branch;
-- How many people came to each branch?
select Branch, count(Gender) as Total_patrons from supermarket_sales_reviewed
group by branch order by branch;


-- Summary Insights
-- 1. More females patronage were recorded although the difference is little(3 precisely)
-- 2. Food and beverages has the highest number of sales (money wise)
-- 3. Most people patronised fashion accessories 
-- 4. The highest singular amount was made at branch C through a sale at fashion acessories product line
-- 5. Branch C also has the highest number of sales (money wise)
-- 6. Although branch A has the highest number of patrons