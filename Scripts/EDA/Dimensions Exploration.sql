-- Explore all countries our customers come from.
SELECT DISTINCT
	country
FROM gold.dim_customers;

-- Explore all product categories " the major divisions".
SELECT DISTINCT
	category,
	subcategory,
	product_name
FROM gold.dim_products
ORDER BY 1,2,3;

-- =========================================================

-- Find the date of first and last order.
-- How many years of sales are available?
SELECT
	MIN(order_date) AS first_order_date,
	MAX(order_date) AS last_order_date,
	DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) AS order_range_years
FROM gold.fact_sales;

-- Find the youngest and oldest customer.
SELECT
	MIN(birthdate) AS youngest_birthdate,
	MAX(birthdate) AS oldest_birthdate,
	DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS youngest_customer_age,
	DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS oldest_customer_age
FROM gold.dim_customers;