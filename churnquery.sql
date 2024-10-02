create database db_churn
use db_churn;
-- let's do first analayze the data set 
SHOW TABLES;
SELECT * FROM stg_churn LIMIT 10;
SELECT * FROM stg_churn WHERE Customer_status = "Churned";
/* 
Question 1:
How would you calculate the percentage distribution of customers by gender from the stg_churn table? 
 */
select * from stg_churn;
select Gender, Count(Gender) as TotalCount,
Count(Gender) * 100.0  / (select Count(*) from stg_churn) as percentage
from stg_churn
group by Gender
/* 
Question 2:
How many total revenue occurred according to states in ascending order? 
 */
-- SOLUTION: 
-- How many total revenue occurred according to states in ascending order? 
SELECT 
    State,
    SUM(Total_Revenue) AS Total_Revenue
FROM 
    stg_Churn
GROUP BY 
    State
ORDER BY 
   Total_Revenue ASC;
/* 
Question 3:
 Return the top 5 customers with the highest total charges generated in this dataset. Include the customer's ID,
 state, total charges, total refunds,payment method?
 */
 SELECT 
    Customer_ID, 
    State, 
    SUM(Total_Charges) AS Total_Charges,
    SUM(Total_Refunds) AS Total_Refunds,
    Payment_Method
FROM 
    stg_Churn
GROUP BY 
    Customer_ID, 
    State, 
    Payment_Method
ORDER BY 
    Total_Charges DESC
LIMIT 5;
/* 
Question 4:
 Return a table with a row for each customer, including an event column that specifies the churn status,
 a total charges column, and a moving average of total charges that averages the last 50 transactions?
 */
 SELECT 
    Customer_ID,
    State,
    Total_Charges,
    Customer_Status AS Event,  -- Assuming Customer_Status indicates churn status
    AVG(Total_Charges) OVER (ORDER BY Customer_ID ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) AS Moving_Average_Charges
FROM 
    stg_Churn;
/* 
Question 5:
 Return each state and the number of customers who have churned from that state, along with the average total charges
 of those customers. Order the results by the count of churned customers in ascending order?
 */
SELECT 
    State,
    COUNT(Customer_ID) AS Churned_Customer_Count,
    AVG(Total_Charges) AS Average_Total_Charges
FROM 
    stg_Churn
WHERE 
    Customer_Status = 'Churned'  -- Assuming 'Churned' indicates customers who have churned
GROUP BY 
    State
ORDER BY 
    Churned_Customer_Count ASC;
/* 
Question 6:
 Construct a column that summarizes each customer's transaction details.
 The summary should include the customer's ID, gender, age, marital status, state, total charges, 
 total extra data charges, and total long-distance charges. Format the summary as follows: "Customer 
 ID [Customer_ID] (Gender: [Gender], Age: [Age], Married: [Married]) from [State] incurred total charges 
 of $[Total_Charges], with total extra data charges of $[Total_Extra_Data_Charges] and total long-distance
 charges of $[Total_Long_Distance_Charges]." Round the total charges, total extra data charges, and total 
 long-distance charges to the nearest hundredth?
 */
 SELECT  
    CONCAT('Customer ID ', Customer_ID, 
           ' (Gender: ', Gender, 
           ', Age: ', Age, 
           ', Married: ', Married, 
           ') from ', State, 
           ' incurred total charges of $', ROUND(Total_Charges, 2), 
           ', with total extra data charges of $', ROUND(Total_Extra_Data_Charges, 2), 
           ' and total long-distance charges of $', ROUND(Total_Long_Distance_Charges, 2), '.') AS Transaction_Summary
FROM 
    stg_Churn
ORDER BY 
    Total_Charges DESC;
/*
Question 7: Create a histogram of the ranges of Total Charges incurred by customers. 
Round the Total Charges to the nearest hundred value.
*/
SELECT 
    ROUND(Total_Charges, -2) AS bucket, -- Round Total Charges to the nearest hundred
    COUNT(*) AS count, -- Count the number of customers in each bucket
    RPAD(' ', COUNT(*), '*') AS bar -- Create a bar representation with asterisks
FROM 
    stg_Churn
GROUP BY 
    bucket -- Group by the rounded Total Charges
ORDER BY 
    count DESC; -- Order by the bucket in descending order
/* 
Question 8:Return a unioned query that contains the maximum total charges incurred by each customer and a new column 
called status saying “highest,” alongside a query that has the minimum total charges incurred by each customer
with the status column saying “lowest.” The table should have a Customer_ID column, a Total_Charges column called 
price, and a status column. Order the result set by the Customer_ID and the status in ascending order.
 */
SELECT 
    Customer_ID, 
    Customer_Status, 
    Churn_Category, 
    Churn_Reason, 
    MAX(Total_Charges) AS price, 
    'highest' AS status 
FROM 
    stg_Churn 
GROUP BY 
    Customer_ID, 
    Customer_Status, 
    Churn_Category, 
    Churn_Reason

UNION ALL 

SELECT 
    Customer_ID, 
    Customer_Status, 
    Churn_Category, 
    Churn_Reason, 
    MIN(Total_Charges) AS price, 
    'lowest' AS status 
FROM 
    stg_Churn 
GROUP BY 
    Customer_ID, 
    Customer_Status, 
    Churn_Category, 
    Churn_Reason 

ORDER BY 
     price ASC;
/* 
QUESTION 9: Which customer incurred the highest total charges each month based on their tenure, and what were their details? 
Include the customer's ID, state, total charges, and tenure in months. Order the results chronologically by total charges.
 */
SELECT *
FROM (
    SELECT 
        Tenure_in_Months,
        Customer_ID,
        State,
        ROUND(Total_Charges, 2) AS Total_Charges,
        DENSE_RANK() OVER(PARTITION BY Tenure_in_Months ORDER BY Total_Charges DESC) AS Rank_Per_Tenure
    FROM 
        stg_Churn
) AS RankedData
WHERE Rank_Per_Tenure = 1
ORDER BY Total_Charges ASC;
/*
Question 10: Create an “estimated average value calculator” that provides a representative price of customer charges every month
 based on the following criteria:
Exclude all monthly outlier charges where the total charge amount is below 10% of the monthly average charge.
Calculate the average of the remaining transactions.
a) First, create a query that will be used as a subquery. Select the month, total charges, and the average total 
charges for each month using a window function. Save it as a temporary table.
b) Use the table you created in Part A to filter out rows where the total charges are below 10% of the monthly
 average and return a new estimated value, which is just the monthly average of the filtered data.
/*
-- Create a temporary table for monthly averages
CREATE TEMPORARY TABLE Monthly_Averages AS
SELECT 
    Tenure_in_Months AS month,
    ROUND(AVG(Total_Charges), 2) AS Avg_Total_Charges,
    ROUND(SUM(Total_Charges), 2) AS Total_Charges
FROM 
    stg_Churn
GROUP BY 
    Tenure_in_Months;

-- Calculate estimated average value excluding outliers
SELECT 
    month,
    ROUND(AVG(Total_Charges), 2) AS Estimated_Avg_Value
FROM 
    Monthly_Averages
WHERE 
    Total_Charges >= 0.1 * Avg_Total_Charges
GROUP BY 
    month
ORDER BY 
    month ASC;

/* 
Question 11:
How can you determine the percentage distribution of customers by contract type in the stg_churn table?
 */
select contract, count(contract) as Totalcount,
count(contract) * 1.0 / (select count(*) from stg_churn) as percentage
from stg_churn
group by contract
/* 
Question 12:
How can you rank the states by the percentage of customers in the stg_churn table?
 */
select state, count(state) as TotalCount,
count(state)  / (select count(*) from stg_churn) as percentage
from stg_churn
group by state
order by percentage desc
/* 
Question 13:
How would you retrieve the distinct types of internet services available in the stg_churn table?
 */
select distinct Internet_Type
from stg_churn

 /* 
Question 14:
How can you identify and count the number of missing (null) values for each column in the stg_churn table?
 */

SELECT 

    SUM(CASE WHEN Customer_ID IS NULL THEN 1 ELSE 0 END) AS Customer_ID_Null_Count,

    SUM(CASE WHEN Gender IS NULL THEN 1 ELSE 0 END) AS Gender_Null_Count,

    SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS Age_Null_Count,

    SUM(CASE WHEN Married IS NULL THEN 1 ELSE 0 END) AS Married_Null_Count,

    SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS State_Null_Count,

    SUM(CASE WHEN Number_of_Referrals IS NULL THEN 1 ELSE 0 END) AS Number_of_Referrals_Null_Count,

    SUM(CASE WHEN Tenure_in_Months IS NULL THEN 1 ELSE 0 END) AS Tenure_in_Months_Null_Count,

    SUM(CASE WHEN Value_Deal IS NULL THEN 1 ELSE 0 END) AS Value_Deal_Null_Count,

    SUM(CASE WHEN Phone_Service IS NULL THEN 1 ELSE 0 END) AS Phone_Service_Null_Count,

    SUM(CASE WHEN Multiple_Lines IS NULL THEN 1 ELSE 0 END) AS Multiple_Lines_Null_Count,

    SUM(CASE WHEN Internet_Service IS NULL THEN 1 ELSE 0 END) AS Internet_Service_Null_Count,

    SUM(CASE WHEN Internet_Type IS NULL THEN 1 ELSE 0 END) AS Internet_Type_Null_Count,

    SUM(CASE WHEN Online_Security IS NULL THEN 1 ELSE 0 END) AS Online_Security_Null_Count,

    SUM(CASE WHEN Online_Backup IS NULL THEN 1 ELSE 0 END) AS Online_Backup_Null_Count,

    SUM(CASE WHEN Device_Protection_Plan IS NULL THEN 1 ELSE 0 END) AS Device_Protection_Plan_Null_Count,

    SUM(CASE WHEN Premium_Support IS NULL THEN 1 ELSE 0 END) AS Premium_Support_Null_Count,

    SUM(CASE WHEN Streaming_TV IS NULL THEN 1 ELSE 0 END) AS Streaming_TV_Null_Count,

    SUM(CASE WHEN Streaming_Movies IS NULL THEN 1 ELSE 0 END) AS Streaming_Movies_Null_Count,

    SUM(CASE WHEN Streaming_Music IS NULL THEN 1 ELSE 0 END) AS Streaming_Music_Null_Count,

    SUM(CASE WHEN Unlimited_Data IS NULL THEN 1 ELSE 0 END) AS Unlimited_Data_Null_Count,

    SUM(CASE WHEN Contract IS NULL THEN 1 ELSE 0 END) AS Contract_Null_Count,

    SUM(CASE WHEN Paperless_Billing IS NULL THEN 1 ELSE 0 END) AS Paperless_Billing_Null_Count,

    SUM(CASE WHEN Payment_Method IS NULL THEN 1 ELSE 0 END) AS Payment_Method_Null_Count,

    SUM(CASE WHEN Monthly_Charge IS NULL THEN 1 ELSE 0 END) AS Monthly_Charge_Null_Count,

    SUM(CASE WHEN Total_Charges IS NULL THEN 1 ELSE 0 END) AS Total_Charges_Null_Count,

    SUM(CASE WHEN Total_Refunds IS NULL THEN 1 ELSE 0 END) AS Total_Refunds_Null_Count,

    SUM(CASE WHEN Total_Extra_Data_Charges IS NULL THEN 1 ELSE 0 END) AS Total_Extra_Data_Charges_Null_Count,

    SUM(CASE WHEN Total_Long_Distance_Charges IS NULL THEN 1 ELSE 0 END) AS Total_Long_Distance_Charges_Null_Count,

    SUM(CASE WHEN Total_Revenue IS NULL THEN 1 ELSE 0 END) AS Total_Revenue_Null_Count,

    SUM(CASE WHEN Customer_Status IS NULL THEN 1 ELSE 0 END) AS Customer_Status_Null_Count,

    SUM(CASE WHEN Churn_Category IS NULL THEN 1 ELSE 0 END) AS Churn_Category_Null_Count,

    SUM(CASE WHEN Churn_Reason IS NULL THEN 1 ELSE 0 END) AS Churn_Reason_Null_Count

FROM stg_Churn;
 /* 
Question 15:
How would you create a new table prod_Churn by copying the structure and data from an existing table?
 */
---- Remove null and insert the new data into Prod table
CREATE TABLE prod_Churn AS
SELECT 

    Customer_ID,

    Gender,

    Age,

    Married,

    State,

    Number_of_Referrals,

    Tenure_in_Months,

    IFNULL(Value_Deal, 'None') AS Value_Deal,

    Phone_Service,

    IFNULL(Multiple_Lines, 'No') AS Multiple_Lines,

    Internet_Service,

    IFNULL(Internet_Type, 'None') AS Internet_Type,

    IFNULL(Online_Security, 'No') AS Online_Security,

    IFNULL(Online_Backup, 'No') AS Online_Backup,

    IFNULL(Device_Protection_Plan, 'No') AS Device_Protection_Plan,

    IFNULL(Premium_Support, 'No') AS Premium_Support,

    IFNULL(Streaming_TV, 'No') AS Streaming_TV,

    IFNULL(Streaming_Movies, 'No') AS Streaming_Movies,

    IFNULL(Streaming_Music, 'No') AS Streaming_Music,

    IFNULL(Unlimited_Data, 'No') AS Unlimited_Data,

    Contract,

    Paperless_Billing,

    Payment_Method,

    Monthly_Charge,

    Total_Charges,

    Total_Refunds,

    Total_Extra_Data_Charges,

    Total_Long_Distance_Charges,

    Total_Revenue,

    Customer_Status,

    IFNULL(Churn_Category, 'Others') AS Churn_Category,

    IFNULL(Churn_Reason , 'Others') AS Churn_Reason

INTO prod_Churn  -- No database and schema prefix, just the table name in MySQL

FROM stg_Churn;  -- No database and schema prefix, just the table name in MySQL
USE db_Churn;
select * from prod_churn;
 /* 
Question 16:
Create View for Power BI
 */
create view vw_churndata as 
    select * from prod_churn where customer_status in ('churned', 'stayed')
    
create view vw_JoinData as
    select * from prod_churn where customer_status = 'Joined'

