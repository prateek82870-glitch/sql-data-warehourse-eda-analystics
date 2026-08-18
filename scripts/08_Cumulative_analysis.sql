-- Calculate the total sales per month using window functions
-- and the runnning total of sales over time

SELECT
order_date,
total_sales,
SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales
FROM
	(
	SELECT
	DATETRUNC(month,order_date) AS order_date,
	SUM(sales_amount) AS total_sales
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(month, order_date)
	) t

 -- Partition it by year

SELECT
order_date,
total_sales,
SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales
FROM
	(
	SELECT
	DATETRUNC(month,order_date) AS order_date,
	SUM(sales_amount) AS total_sales
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(month, order_date)
	) t

-- Year wise

SELECT
order_date,
total_sales,
SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales
FROM
	(
	SELECT
	DATETRUNC(year,order_date) AS order_date,
	SUM(sales_amount) AS total_sales
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(year, order_date)
	) t


 -- Moving average

 SELECT
 order_date,
 total_sales,
 SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
 AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
 FROM
	(
	SELECT
	DATETRUNC(year, order_date) AS order_date,
	SUM(sales_amount) AS total_sales,
	AVG(price) AS avg_price
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(year, order_date)
	)t