select * from mtn_customer_churn;
-- how many unique customers do we have
select count(distinct(Customer_ID)) from mtn_customer_churn;
-- what is the age of the oldest customer?
select max(Age) from mtn_customer_churn;
-- what is the age of the youngest customer?
select min(Age) from mtn_customer_churn;
-- Which states are captured in this data
select distinct(state) from mtn_customer_churn;
-- how many are the states?
select count(distinct(state)) from mtn_customer_churn;
-- How many MTN Device do we have and the population by usage
with device as(
select Customer_ID,`MTN Device`,
count(Customer_ID) over (partition by `MTN Device` ) as Unique_Device
from mtn_customer_churn)
select distinct(`MTN Device`), Unique_Device from device 
;
-- What is the spread of each device per state?
with device_per_state as(
select Customer_ID,`MTN Device`, State,
count(Customer_ID) over (partition by `State` ) as Total_device_per_state
from mtn_customer_churn)
select distinct(`State`),`MTN Device`, Total_device_per_state from device_per_state
;
-- How were the reviews
with device_reviews as(
select `MTN Device`,`Customer Review`, 
count(`Customer Review`) over (partition by `Customer Review` ) as Total_device_reviews
from mtn_customer_churn)
select distinct(`Customer Review`), Total_device_reviews from device_reviews
order by Total_device_reviews desc;

-- The reviews as they relate to devices
select  `MTN Device`,count(`MTN Device`) as Total_Excellent_Reviews from mtn_customer_churn where 
`Customer Review` = 'Excellent' group by `MTN Device` order by Total_Excellent_Reviews desc ;

select  `MTN Device`,count(`MTN Device`) as Total_Very_Good_Reviews from mtn_customer_churn where 
`Customer Review` = 'Very Good' group by `MTN Device` order by Total_Very_Good_Reviews desc ;

select  `MTN Device`,count(`MTN Device`) as Total_Poor_Reviews from mtn_customer_churn where 
`Customer Review` = 'Poor' group by `MTN Device` order by Total_Poor_Reviews desc ;

-- What's the relationship between location and reviews
select  `State`,count(`Customer Review`) as Total_Excellent_Per_state from mtn_customer_churn where 
`Customer Review` = 'Excellent' group by `State` order by Total_Excellent_Per_state desc ;

select  `State`,count(`Customer Review`) as Total_Very_Good_Per_state from mtn_customer_churn where 
`Customer Review` = 'Very Good' group by `State` order by Total_Very_Good_Per_state desc ;

select  `State`,count(`Customer Review`) as Total_Poor_Per_state from mtn_customer_churn where 
`Customer Review` = 'Poor' group by `State` order by Total_Poor_Per_state desc ;

-- What is the gender distribution like
select count(Gender), gender from mtn_customer_churn group by Gender;

-- What are the five highest months used by a customer and what do they say 
select * from mtn_customer_churn order by `Customer Tenure in months` desc limit 5;

-- How many subscription plans do we have?
select distinct(`Subscription Plan`) from mtn_customer_churn;

-- How is each plan being used
select count(Customer_ID) as Total_User_Per_Plan, (`Subscription Plan`) 
from mtn_customer_churn group by `Subscription Plan` order by Total_User_Per_Plan desc;

-- What is the total revenue made
select sum(`Total Revenue`) as Total_Revenue_Per_Plan
from mtn_customer_churn;

-- Which of the data plan generated the highest revenue
select sum(`Total Revenue`) as Total_Revenue_Per_Plan, (`Subscription Plan`) 
from mtn_customer_churn group by `Subscription Plan` order by Total_Revenue_Per_Plan desc;

-- How many customers churn
select count(`Customer Churn Status`) as Number_of_Churn_Customers, `Customer Churn Status` 
from mtn_customer_churn group by `Customer Churn Status` ;
-- What is the percentage like?
-- select (count(`Customer Churn Status`)/count(`Customer Churn Status`))* 100 as Number_of_Churn_Customers, `Customer Churn Status` 
-- from mtn_customer_churn group by `Customer Churn Status` ;
-- How much are we loosing from tose that churned
select sum(`Total Revenue`) as Total_Revenue_Per_Plan
from mtn_customer_churn where `Customer Churn Status` = 'Yes';
-- Why are people churning
select distinct(`Reasons for Churn`) from mtn_customer_churn;

-- What is the rate of churning per each reason
select count(Customer_ID) as Number_of_Churn_Customers, `Reasons for Churn` from mtn_customer_churn
group by `Reasons for Churn` order by Number_of_Churn_Customers desc limit 10 offset 1;

