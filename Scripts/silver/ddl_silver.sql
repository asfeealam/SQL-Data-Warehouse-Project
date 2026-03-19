/*
====================================================================
DDL Script: Create Silver Tables
====================================================================

Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables
    if they already exist.
    Run this script to re-define the DDL structure of 'silver' tables
====================================================================
*/

IF OBJECT_ID ('silver.crm_customer_info', 'U') IS NOT NULL
	DROP TABLE silver.crm_customer_info;

CREATE TABLE silver.crm_customer_info (
	customer_id INT,
	customer_key NVARCHAR(50),
	customer_firstname NVARCHAR(50),
	customer_lastname NVARCHAR(50),
	customer_marital_status NVARCHAR(50),
	customer_gender NVARCHAR(50),
	customer_create_date DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID ('silver.crm_product_info', 'U') IS NOT NULL
	DROP TABLE silver.crm_product_info;

CREATE TABLE silver.crm_product_info (
	product_id INT,
	category_id NVARCHAR(50),
	product_key NVARCHAR(50),
	product_nm NVARCHAR(50),
	product_cost INT,
	product_line NVARCHAR(50),
	product_start_date DATE,
	product_end_date DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID ('silver.crm_sales_details', 'U') IS NOT NULL
	DROP TABLE silver.crm_sales_details;

CREATE TABLE silver.crm_sales_details (
	sales_order_no NVARCHAR(50),
	sales_product_key NVARCHAR(50),
	sales_customer_id INT,
	sales_order_date DATE,
	sales_ship_date DATE,
	sales_due_date DATE,
	sales_sales INT,
	sales_quantity INT,
	sales_price INT,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID ('silver.erp_loc_a101', 'U') IS NOT NULL
	DROP TABLE silver.erp_loc_a101;

CREATE TABLE silver.erp_loc_a101 (
	cid NVARCHAR(50),
	cntry NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID ('silver.erp_cust_az12', 'U') IS NOT NULL
	DROP TABLE silver.erp_cust_az12;

CREATE TABLE silver.erp_cust_az12 (
	cid NVARCHAR(50),
	bdate DATE,
	gen NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID ('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
	DROP TABLE silver.erp_px_cat_g1v2;

CREATE TABLE silver.erp_px_cat_g1v2 (
	id NVARCHAR(50),
	cat NVARCHAR(50),
	subcat NVARCHAR(50),
	maintenance NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
