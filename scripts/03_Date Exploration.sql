-- Find the date of the first and last order
-- How many years of sales are available

/*SELECT 
order_number
WHERE order_date = MAX(order_date);*/


SELECT 
MIN(order_date) AS first_order_date, 
MAX(order_date) AS last_order_date,
DATEDIFF(year, MIN(order_date), MAX(order_date)) AS order_range_years,
DATEDIFF(month, MIN(order_date), MAX(order_date)) AS order_range_months
FROM gold.fact_sales;		

-- Find the youngest and oldest customer

SELECT
MAX(birthdate) AS youngest_customer,
DATEDIFF(year, MAX(birthdate), GETDATE()) AS youngest_age,
MIN(birthdate) AS oldest_customer,
DATEDIFF(year, MIN(birthdate), GETDATE()) AS oldest_age
FROM gold.dim_customers;