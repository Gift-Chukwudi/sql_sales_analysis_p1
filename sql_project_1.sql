-- Drops existing table
DROP TABLE IF EXISTS a;sales_dat
-- Creates the table
CREATE TABLE sales_data(
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
			  
-- Confirms the table exists
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_name LIKE '%sales_data%';
-- Select all data from the table with a limit
SELECT * FROM sales_data
LIMIT 10;
-- Confirm the total rows of data
SELECT
	  COUNT (*)
FROM sales_data;

-- Data Cleaning
-- Check for NULL values
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
-- Delete NULL rows without relevant values for the analysis.
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
-- Verify delete
SELECT * FROM sales_data
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
-- Since NULL values in age, have corresponding values for analysis, replace NULL with average/median.
UPDATE sales_data
SET age = sub.avg_age
FROM (SELECT AVG(age) AS avg_age FROM sales_data WHERE age IS NOT NULL) sub
-- subquery that calculates the average age of all rows where age is not NULL
WHERE age IS NULL;
-- Confirm number of rows
SELECT COUNT (*) FROM sales_data;
-- Confirm that all NULL Values have been resolved.
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

-- Data Exploration
-- Total number of transactions/sales
SELECT COUNT (*) AS total_sale
FROM sales_data;
-- Total number of unique customers
SELECT COUNT (DISTINCT customer_id) AS total_customers
FROM sales_data;
-- Total number of categories
SELECT COUNT (DISTINCT category) AS total_category
FROM sales_data;

-- Data Analysis (Business Questions)
-- Q1. Retrieve all columns for sales made on '2022-11-05'.
SELECT * FROM sales_data
WHERE sale_date = '2022-11-05';

-- Q2. Retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 3 in the month of Nov-2022.
SELECT * FROM sales_data
WHERE category = 'Clothing'
	  AND
	  quantity > 3
	  AND	  
	  TO_CHAR(sale_date, 'YYYY-MM') = '2022-11';
-- Converts sale_date column to the required format.

-- Q3. Calculate the total sales (total_sale) for each category, total orders and grand total.
SELECT 
	 COALESCE(category, 'Grand Total') AS category,
	 SUM (total_sale) AS net_sale,
	 COUNT (*) AS total_orders
FROM sales_data
GROUP BY ROLLUP (category)
ORDER BY net_sale ASC;
	 
-- Q4. Find the average age of customers who purchased items from the 'Beauty' category.
SELECT
	 ROUND(AVG(age), 2) AS avg_age
FROM sales_data
WHERE category = 'Beauty';

-- Q5. Find all transactions where the total_sale is greater than 1000.
SELECT * FROM sales_data
WHERE total_sale > 1000;

-- Q6. Find the total number of transactions (transaction_id) made by each gender in each category.
SELECT 
    gender,
    category,
    COUNT(*) AS total_transactions
FROM sales_data
GROUP BY gender, category
ORDER BY gender, category;
	 
-- Q7. Calculate the average sale for each month. Find out best selling month in each year.
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

-- Q8. Find the top 5 customers based on the highest total sales.
SELECT 
	 customer_id,
	 SUM(total_sale) as total_sales
FROM sales_data
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;
	 
-- Q9. Find the number of unique customers who purchased items from each category.
SELECT
	 COUNT(DISTINCT customer_id) AS no_of_unique_customers,
	 category
FROM sales_data
GROUP BY category
ORDER BY no_of_unique_customers DESC;

-- Q10. Create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)
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

-- Q11. What is the average quantity per customer by gender?
SELECT 
	 gender,
	 ROUND(AVG(quantity), 2) AS avg_quantity
FROM sales_data
GROUP BY gender
ORDER BY avg_quantity DESC;

--Q12. Which product category generates the highest profit margin?
SELECT
	 category,
	 ROUND(AVG((total_sale - cogs) / total_sale * 100)::numeric, 2) AS avg_profit_margin
FROM sales_data
GROUP BY category
ORDER BY avg_profit_margin DESC;

-- End of project