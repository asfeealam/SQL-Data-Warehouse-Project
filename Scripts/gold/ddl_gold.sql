/*
====================================================================
DDL Script: Create Gold Views
====================================================================

Script Purpose:
    This script creates views for the Gold layer in the data warehouse.
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
====================================================================
*/

-- ====================================================================
-- Create Dimension: gold.dim_customers
-- ====================================================================

-- Creating Dimension Customers
CREATE OR ALTER VIEW gold.dim_customers AS
SELECT
	ROW_NUMBER() OVER(ORDER BY ci.customer_id) AS customer_key,
	ci.customer_id,
	ci.customer_key AS customer_number,
	ci.customer_firstname AS first_name,
	ci.customer_lastname AS last_name,
	ci.customer_marital_status AS marital_status,
	CASE
		WHEN ci.customer_gender != ca.gen THEN ci.customer_gender  -- CRM is the master for gender info
		ELSE COALESCE(ca.gen, 'n/a')
	END AS gender,
	la.cntry AS country,
	ca.bdate AS birthdate,
	ci.customer_create_date AS create_date
FROM silver.crm_customer_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.customer_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS la
ON ci.customer_key = la.cid;

-- =================================================================
SELECT * FROM gold.dim_customers;

-- =================================================================

-- Handling gender info
SELECT DISTINCT
	ci.customer_gender,
	ca.gen,
	CASE
		WHEN ci.customer_gender != ca.gen THEN ci.customer_gender  -- CRM is the master for gender info
		ELSE COALESCE(ca.gen, 'n/a')
	END AS new_gender
FROM silver.crm_customer_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON ci.customer_key = ca.cid
LEFT JOIN silver.erp_loc_a101 AS la
ON ci.customer_key = la.cid
ORDER BY 1,2;

-- =================================================================

SELECT DISTINCT gender FROM gold.dim_customers;

-- =================================================================

-- ====================================================================
-- Create Dimension: gold.dim_products
-- ====================================================================

-- Creating Products Dimensions
CREATE OR ALTER VIEW gold.dim_products AS
SELECT
	ROW_NUMBER() OVER(ORDER BY pn.product_start_date, pn.product_key) AS product_key,
	pn.product_id,
	pn.product_key AS product_number,
	pn.product_nm AS product_name,
	pn.category_id,
	pc.cat AS category,
	pc.subcat AS subcategory,
	pc.maintenance,
	pn.product_cost,
	pn.product_line,
	pn.product_start_date AS start_date
FROM silver.crm_product_info AS pn
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
ON pn.category_id = pc.id
WHERE pn.product_end_date IS NULL;			-- Filter out all historical data

-- =================================================================

SELECT * FROM gold.dim_products;

-- =================================================================

-- ====================================================================
-- Create Dimension: gold.fact_sales
-- ====================================================================
-- Creating sales fact table
CREATE OR ALTER view gold.fact_sales AS
SELECT
	sd.sales_order_no AS order_number,
	pr.product_key,
	cs.customer_key,
	sd.sales_order_date AS order_date,
	sd.sales_ship_date AS ship_date,
	sd.sales_due_date AS due_date,
	sd.sales_sales AS sales_amount,
	sd.sales_quantity AS quantity,
	sd.sales_price AS price
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_products AS pr
ON sd.sales_product_key = pr.product_number
LEFT JOIN gold.dim_customers AS cs
ON sd.sales_customer_id = cs.customer_id;

SELECT * FROM gold.fact_sales;


-- Foreign key integrity (Dimensions)
SELECT
*
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
ON f.customer_key = c.customer_key
LEFT JOIN gold.dim_products AS p
ON f.product_key = p.product_key
WHERE c.customer_key IS NULL OR p .product_key IS NULL;

-- ====================================================================
