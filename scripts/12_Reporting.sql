/* 
===============================================================================
CUSTOMER REPORT
===============================================================================
Purpose:
	- This report consolidates key customer metrics and behaviors

Highlights:

	1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
	3. Aggregates customer-level metrics:
		- total orders
		- total sales
		- total quantity purchased
		- total products
		- lifespan (in months)
	4. Calculates valuable KPIs:
		- recency (months since last order)
		- average order value
		- average monthly spend

Steps:
	1. Create base
	2. Transform
	3. Aggregations
	4. Final results
	5. Final transform
	6. Create views
================================================================================
*/

-- 1. Base Query: Retrieves core columns from tables

CREATE VIEW gold.report_customers AS

WITH base_query AS (
SELECT
	s.order_number,
	s.product_key,
	s.order_date,
	s.sales_amount,
	s.quantity,
	c.customer_key,
	c.customer_number,
	CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
	DATEDIFF(year, c.birthdate, GETDATE()) age
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON c.customer_key = s.customer_key
WHERE order_date IS NOT NULL
)

-- 2. Customer Aggregations: Summarizes key metrics at the customer level

, customer_aggregation AS (

SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT product_key) AS total_products,
	MAX(order_date) AS last_order_date,
	DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query
GROUP BY 
	customer_key,
	customer_number,
	customer_name,
	age 
)

-- 3.
SELECT
customer_key,
customer_number,
customer_name,
age,
CASE 
	WHEN age < 20 THEN 'Under 20'
	WHEN age BETWEEN 20 AND 29 THEN '20-29'
	WHEN age BETWEEN 30 AND 39 THEN '30-39'
	WHEN age BETWEEN 40 AND 49 THEN '40-49'
	ELSE '50 and above'
END AS age_group,
CASE
	WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
	WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
	ELSE 'New'
END AS customer_segment,
total_orders,
last_order_date,

-- Compute recency
DATEDIFF(month, last_order_date, GETDATE()) AS recency,

total_sales,
total_quantity,
total_products,
lifespan,

-- Compute average order value (AOV)
CASE WHEN total_sales = 0 THEN 0
	 ELSE total_sales / total_orders
END AS avg_order_value,

-- Compute average montly spend
CASE WHEN lifespan = 0 THEN total_sales	
	 ELSE total_sales / lifespan
END AS avg_monthly_spend
FROM customer_aggregation 



-- Checking our view
-- SELECT * FROM gold.report_customers



/* 
===============================================================================
PRODUCT REPORT
===============================================================================
Purpose:
	- This report consolidates key product metrics and behaviors

Highlights:

	1. Gathers essential fields such as product name, category, subcategory, and cost.
	2. Segments products by revenue to identify High-Performers, Mid-range, or Low-performers.
	3. Aggregates product-level metrics:
		- total orders
		- total sales
		- total quantity sold
		- total customers (unique)
		- lifespan (in months)
	4. Calculates valuable KPIs:
		- recency (months since last sale)
		- average order value (AOR)
		- average monthly revenue

Steps:
	1. Create base
	2. Transform
	3. Aggregations
	4. Final results
	5. Final transform
	6. Create views
================================================================================
*/

-- 1. Base Query: Retrieves core columns from tables

CREATE VIEW gold.report_products AS

WITH base_query AS (
SELECT
	s.order_number,
	s.order_date,
	s.customer_key,
	s.sales_amount,
	s.quantity,
	p.product_key,
	p.product_name,
	p.category,
	p.subcategory,
	p.cost
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
	ON s.product_key = p.product_key
WHERE order_date IS NOT NULL 
)

-- 2. Product Aggregations: Summarizes key metrics at the product level

, product_aggregations AS (
SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan,
	MAX(order_date) AS last_sale_date,
	COUNT(DISTINCT order_number) AS total_orders,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)),1) AS avg_selling_price
FROM base_query
GROUP BY
	product_key,
	product_name,
	category,
	subcategory,
	cost
)

-- 3. Final Query: Combines all product results into one output

SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_sale_date,
	DATEDIFF(month, last_sale_date, GETDATE()) AS recency_in_months,
	CASE
		WHEN total_sales > 50000 THEN 'High-Performer'
		WHEN total_sales >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS product_segment,
	lifespan,
	total_orders,
	total_sales,
	total_quantity,
	total_customers,
	avg_selling_price,

	-- Average Order Revenue (AOR)
	CASE
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders
	END AS avg_order_revenue,

	-- Average Montly Revenue
	CASE 
		WHEN lifespan = 0 THEN total_sales
		ELSE total_sales / lifespan
	END AS avg_montly_revenue

FROM product_aggregations


-- Checking our view
-- SELECT * FROM gold.report_products