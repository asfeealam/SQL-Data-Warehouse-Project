-- Explore all objects in the database
SELECT * FROM INFORMATION_SCHEMA.TABLES;

-- Explore all columns in the database
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';


-- ======================================
SELECT
*
FROM gold.dim_customers;

SELECT
*
FROM gold.dim_products;

SELECT
*
FROM gold.fact_sales;