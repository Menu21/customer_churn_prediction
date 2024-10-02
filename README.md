# customer_churn_prediction

### Introduction to Churn Analysis

In today's competitive business environment, retaining customers is crucial for long-term success. Churn analysis is a key technique used to understand and reduce this customer attrition. It involves examining customer data to identify patterns and reasons behind customer departures. By using advanced data analytics and machine learning, businesses can predict which customers are at risk of leaving and understand the factors driving their decisions. This knowledge allows companies to take proactive steps to improve customer satisfaction and loyalty.

### Who is the Target Audience

Although this project focuses on churn analysis for a telecom firm, the techniques and insights are applicable across various industries. From retail and finance to healthcare and beyond, any business that values customer retention can benefit from churn analysis. We will explore the methods, tools, and best practices for reducing churn and improving customer loyalty, transforming data into actionable insights for sustained success.

![e3da6a_d4188d916c7449bcb29e973c8654d50e~mv2](https://github.com/user-attachments/assets/88660485-ec5a-49f5-b9c1-b6c5cfa58ee1)

## Project Target

Create an entire ETL process in a database & a Power BI dashboard to utilize the Customer Data and achieve below goals:

- Visualize & Analyse Customer Data at below levels

- Demographic

- Geographic

- Payment & Account Info

- Services

- Study Churner Profile & Identify Areas for Implementing Marketing Campaigns

- Identify a Method to Predict Future Churners

 

## Metrics Required

- Total Customers

- Total Churn & Churn Rate

- New Joiners

### STEP 1 - ETL Process in  MY SQL 
So the first step in churn analysis is to load the data from our source file. For this purpose we will be using My sql because it is a widely used solution across the industry and also because a full-fledged Database System is better at handling recurring data loads and maintaining data integrity compared to an excel file.

### Creating Database
Once connected, click on NEW QUERY button at the top ribbon and then write below query. This will create a new Database named db_Churn

	- CREATE DATABASE db_Churn
 
 Remember to add customerId as primary key and allow nulls for all remaining columns. This is done to avoid any errors while data load. Also make sure to change the datatype where it say Bit to Varchar(50). We are doing this because while using import wizard I faced issues with the BIT data type, however Varchar(50) works fine.
 ### STEP 2 - Power BI Transform
 ### STEP 3 - Power BI Measure
 ### STEP 4 - Power BI Visualization

### STEP 5 – Predict Customer Churn

- For predicting customer churn, we will be using a widely used Machine Learning algorithm called RANDOM FOREST.

What is Random Forest?A random forest is a machine learning algorithm that consists of multiple decision trees. Each decision tree is trained on a random subset of the data and features. The final prediction is made by averaging the predictions (in regression tasks) or taking the majority vote (in classification tasks) from all the trees in the forest. This ensemble approach improves the accuracy and robustness of the model by reducing the risk of overfitting compared to using a single decision tree.

#### Create Churn Prediction Model – Random Forest

Now we will work with an application called Jupyter Notebook and we will coding our ML model in Python. That’s it, now you have a comprehensive Power BI dashboard with and Executive Summary to analyze historical data and also a Churn Prediction page to predict future churners.




