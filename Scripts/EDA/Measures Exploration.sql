-- Find the total sales
SELECT
	SUM(sales_amount) AS total_sales
FROM gold.fact_sales;

-- Find how many items are sold
SELECT
	SUM(quantity) AS sold_items
FROM gold.fact_sales;

-- Find the average selling price
SELECT
	AVG(price) AS avg_price
FROM gold.fact_sales;

-- Find the total number of orders
SELECT
	COUNT(order_number) AS total_orders
FROM gold.fact_sales;
-- --------------------
SELECT
	COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales;

-- Find the total number of products
SELECT
	COUNT(product_key) AS total_products
FROM gold.dim_products;

-- Find the total number of customers
SELECT
	COUNT(customer_key) AS total_customers
FROM gold.dim_customers;

-- Find the total number of customers that has placed an order
SELECT
	COUNT(DISTINCT customer_key) AS total_customers_order
FROM gold.fact_sales;

-- Generate a report that shows all key metrics of the business.
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity' AS measure_name, SUM(quantity) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Average Price' AS measure_name, AVG(price) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders' AS measure_name, COUNT(DISTINCT order_number) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Products' AS measure_name, COUNT(product_key) AS measure_value FROM gold.dim_products
UNION ALL
SELECT 'Total Customers' AS measure_name, COUNT(customer_key) AS measure_value FROM gold.dim_customers
UNION ALL
SELECT 'Total Customers with Orders' AS measure_name, COUNT(DISTINCT customer_key) AS measure_value FROM gold.fact_sales;
