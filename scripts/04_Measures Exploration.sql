 -- 1. Find the Total Sales

SELECT TOP 5
*
FROM gold.fact_sales;

SELECT
SUM(sales_amount) AS Total_sales
FROM gold.fact_sales;

 -- 2. Find how many items are sold

SELECT
SUM(quantity) AS Total_quantity
FROM gold.fact_sales;

 -- 3. Find the average selling price

SELECT
AVG(price) AS avg_price
FROM gold.fact_sales;

 -- 4. Find the total number of Orders

SELECT
COUNT(order_number) AS false_total_orders 
FROM gold.fact_sales; 

/* This query returns repeated orders as well because one customer
ordered three different product in same order. So we have to find the 
distinct orders*/

SELECT
COUNT(DISTINCT order_number) AS true_total_orders 
FROM gold.fact_sales;

 -- 5. Find the total number of products

SELECT 
COUNT(product_key) AS total_products
FROM gold.dim_products;

-- Check

SELECT
COUNT(DISTINCT product_key) AS total_products
FROM gold.dim_products;

-- Or can check using product name as they are unique

SELECT
COUNT(product_name) AS total_products
FROM gold.dim_products;

SELECT
COUNT(DISTINCT product_name) AS total_products
FROM gold.dim_products;

 -- 6. Find the total number of customers

SELECT
COUNT(customer_key) AS total_customers
FROM gold.dim_customers;

 -- 7. Find the total number of customers that has placed an order

SELECT
COUNT(DISTINCT customer_key) AS total_customers_ordered
FROM gold.fact_sales;

 -- 8. Generate a report that shows all key metrics of the business

SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity) FROM gold.fact_sales
UNION ALL
SELECT 'Average Price', AVG(price) FROM gold.fact_sales
UNION ALL
SELECT 'Total Nr. Orders', COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION ALL
SELECT 'Total Nr. Products', COUNT(product_name) FROM gold.dim_products
UNION ALL
SELECT 'Total Nr. Customers', COUNT(customer_key) FROM gold.dim_customers;

