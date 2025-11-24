#Sales Data Analysis SQL Project 1

## Project Overview

**Project Title**: Sales Data Analysis 
**Platform Used**: pgadmin 4
**SQL Query Language**: postgresql
**Database**: sql_project_2

This SQL project focuses on cleaning, exploring, and analyzing a retail sales dataset. The workflow simulates a real-world analytics task: preparing raw data, performing exploratory analysis, answering business questions, and generating insights that can guide strategic decision-making.

## Skill Demonstrated

1. Data Cleaning & Transformation.
2. Exploratory Queries.
3. Advanced Analytical SQL Functions.
4. Critical Thinking.
5. Problem Solving.
6. Data cleaning & transformation.

## Objectives

1. **Set up a database**: Create and populate a retail sales database with the provided sales data.
2. **Data Cleaning**: Identify and remove any records with missing or null values.
3. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.
4. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `sql_project_2`.
- **Table Creation**: A table named `sales_data` is created to store the sales data. The table structure includes columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount.

```sql
CREATE DATABASE sql_project_p2;

CREATE TABLE sales_data
(
    transactions_id	INT PRIMARY KEY,
    sale_date DATE,
    sale_time TIME,
    customer_id	INT,
    gender	VARCHAR(15),
    age	INT,
    category VARCHAR(25),
    quantity INT,
    price_per_unit FLOAT,	
    cogs FLOAT,
    total_sale FLOAT
);
```

### 2. Data Cleaning & Transformation

- **Null Value Check**: Check for any null values in the dataset and delete records with missing data.
- **Delete Invalid Data**: Delete rows missing essential data for analysis.
- **Replace NULL Age Value**: Replace NULL ages with the average customer age.

```sql
SELECT COUNT(*) FROM sales_data;
SELECT COUNT(DISTINCT customer_id) FROM sales_data;
SELECT COUNT(DISTINCT category) FROM sales_data;

SELECT * FROM sales_data
WHERE 
	transactions_id IS NULL
	OR
	sale_date IS NULL
	OR
	sale_time IS NULL
	OR
    customer_id IS NULL
	OR
	gender IS NULL
	OR
	age IS NULL
	OR 
	category IS NULL
	OR
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR 
	cogs IS NULL
	OR
	total_sale IS NULL;

DELETE FROM sales_data
WHERE 
	category IS NULL
	OR
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR 
	cogs IS NULL
	OR
	total_sale IS NULL;

UPDATE sales_data
SET age = sub.avg_age
FROM (SELECT AVG(age) AS avg_age FROM sales_data WHERE age IS NOT NULL) sub
WHERE age IS NULL;
```

### 3. Data Exploration
- **Record Count**: Determine the total number of records in the dataset.
- **Customer Count**: Find out how many unique customers are in the dataset.
- **Category Count**: Identify all unique product categories in the dataset.

```sql
SELECT COUNT(*) FROM sales_data;
SELECT COUNT(DISTINCT customer_id) FROM sales_data;
SELECT COUNT(DISTINCT category) FROM sales_data;
```

### 4. Data Analysis (Business Questions)

The following SQL queries were developed to answer specific business questions:

1. **Retrieve all sales made on 2022-11-05**:
```sql
SELECT * FROM sales_data
WHERE sale_date = '2022-11-05';
```

2. **Retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 3 in the month of Nov-2022.**:
```sql
SELECT * FROM sales_data
WHERE category = 'Clothing'
	  AND
	  quantity > 3
	  AND	  
	  TO_CHAR(sale_date, 'YYYY-MM') = '2022-11';
```

3. **Calculate the total sales (total_sale) for each category, total orders and grand total.**:
```sql
SELECT 
	 COALESCE(category, 'Grand Total') AS category,
	 SUM (total_sale) AS net_sale,
	 COUNT (*) AS total_orders
FROM sales_data
GROUP BY ROLLUP (category)
ORDER BY net_sale ASC;
```

4. **Find the average age of customers who purchased items from the 'Beauty' category.**:
```sql
SELECT
	 ROUND(AVG(age), 2) AS avg_age
FROM sales_data
WHERE category = 'Beauty';
```

5. **Find all transactions where the total_sale is greater than 1000.**:
```sql
SELECT * FROM sales_data
WHERE total_sale > 1000
ORDER BY total_sale DESC;
```

6. **Find the total number of transactions (transaction_id) made by each gender in each category.**:
```sql
SELECT 
    gender,
    category,
    COUNT(*) AS total_transactions
FROM sales_data
GROUP BY gender, category
ORDER BY gender, category;
```

7. **Calculate the average sale for each month. Find out best selling month in each year.**:
```sql
SELECT
	 year,
	 month,
	 avg_sale
FROM (
    SELECT
        EXTRACT(YEAR FROM sale_date) AS year,
        EXTRACT(MONTH FROM sale_date) AS month,
        AVG(total_sale) AS avg_sale,
        RANK() OVER (
            PARTITION BY EXTRACT(YEAR FROM sale_date)
            ORDER BY AVG(total_sale) DESC
        ) AS rank
    FROM sales_data
    GROUP BY EXTRACT(YEAR FROM sale_date), EXTRACT(MONTH FROM sale_date)
) AS sub
WHERE rank = 1;
```

8. **Find the top 5 customers based on the highest total sales.**:
```sql
SELECT 
	 customer_id,
	 SUM(total_sale) as total_sales
FROM sales_data
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;
```

9. **Find the number of unique customers who purchased items from each category.**:
```sql
SELECT
	 COUNT(DISTINCT customer_id) AS no_of_unique_customers,
	 category
FROM sales_data
GROUP BY category
ORDER BY no_of_unique_customers DESC;
```

10. **Create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17).**:
```sql
WITH shift_table
AS
(SELECT *,
	CASE
		WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END AS employee_shift
FROM sales_data
)
SELECT 
	 employee_shift,
	 COUNT (*) AS total_no_of_orders
FROM shift_table
GROUP BY employee_shift;
```

11. **What is the average quantity bought per customer by gender?**:
```sql
SELECT 
	 gender,
	 ROUND(AVG(quantity), 2) AS avg_quantity
FROM sales_data
GROUP BY gender
ORDER BY avg_quantity DESC;
```

12. **Which product category generates the highest profit margin?**:
```sql
SELECT
	 category,
	 ROUND(AVG((total_sale - cogs) / total_sale * 100)::numeric, 2) AS avg_profit_margin
FROM sales_data
GROUP BY category
ORDER BY avg_profit_margin DESC;
```

## Findings

- **Customer Demographics**: The dataset contains 2,000 records representing customers across various age groups. Sales are distributed among three main product categories: Electronics, Clothing, and Beauty.
- **High-Value Transactions**: Several transactions exceeded a total sale amount of 1,000, indicating premium purchases, with the highest sale recorded at 2,000.
- **Sales Trends**: Monthly sales analysis revealed fluctuations throughout the year. July 2022 was the peak month for sales in 2022, while February 2023 recorded the highest sales for that year.
- **Customer Insights**:
 1. The top 5 spending customers were: Customer ID 3 – 38,440 total purchases, Customer ID 1 – 30,750 total purchases, Customer ID 5 – 30,405 total purchases, Customer ID 2 – 25,295 total purchases, Customer ID 4 – 23,580 total purchases.

2. Female customers accounted for the highest average purchases, with an average of 2.54 purchases per customer.

3. The most profitable and best-selling product category is Clothing, with 149 unique sales and an average profit margin of 73.19%.

## Recommendations

- **Target High-Value Customers**: Develop loyalty programs or personalized promotions for top-spending customers to increase retention and repeat purchases.
- **Seasonal Marketing Campaigns**: Focus marketing efforts on peak months (July 2022, February 2023) to maximize sales during high-demand periods.
- **Product Focus**: Prioritize inventory and marketing for high-margin categories like Clothing, while exploring strategies to boost sales in Electronics and Beauty.
- **Gender-Based Insights**: Tailor campaigns to female customers, who show higher purchase frequency, potentially using personalized offers or recommendations.
- **Upselling & Cross-Selling**: Use high-value transaction patterns to identify opportunities for upselling and cross-selling complementary products.
  


