/*
====================================================================
DDL Script: Create Bronze Tables
====================================================================

Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables
    if they already exist.
    Run this script to re-define the DDL structure of 'bronze' Tables
====================================================================
*/

IF OBJECT_ID ('bronze.crm_customer_info', 'U') IS NOT NULL
	DROP TABLE bronze.crm_customer_info;

CREATE TABLE bronze.crm_customer_info (
	customer_id INT,
	customer_key NVARCHAR(50),
	customer_firstname NVARCHAR(50),
	customer_lastname NVARCHAR(50),
	customer_marital_status NVARCHAR(50),
	customer_gender NVARCHAR(50),
	customer_create_date DATE
);

IF OBJECT_ID ('bronze.crm_product_info', 'U') IS NOT NULL
	DROP TABLE bronze.crm_product_info;

CREATE TABLE bronze.crm_product_info (
	product_id INT,
	product_key NVARCHAR(50),
	product_nm NVARCHAR(50),
	product_cost INT,
	product_line NVARCHAR(50),
	product_start_date DATETIME,
	product_end_date DATETIME
);

IF OBJECT_ID ('bronze.crm_sales_details', 'U') IS NOT NULL
	DROP TABLE bronze.crm_sales_details;

CREATE TABLE bronze.crm_sales_details (
	sales_order_no NVARCHAR(50),
	sales_product_key NVARCHAR(50),
	sales_customer_id INT,
	sales_order_date INT,
	sales_ship_date INT,
	sales_due_date INT,
	sales_sales INT,
	sales_quantity INT,
	sales_price INT
);

IF OBJECT_ID ('bronze.erp_loc_a101', 'U') IS NOT NULL
	DROP TABLE bronze.erp_loc_a101;

CREATE TABLE bronze.erp_loc_a101 (
	cid NVARCHAR(50),
	cntry NVARCHAR(50)
);

IF OBJECT_ID ('bronze.erp_cust_az12', 'U') IS NOT NULL
	DROP TABLE bronze.erp_cust_az12;

CREATE TABLE bronze.erp_cust_az12 (
	cid NVARCHAR(50),
	bdate DATE,
	gen NVARCHAR(50)
);

IF OBJECT_ID ('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
	DROP TABLE bronze.erp_px_cat_g1v2;

CREATE TABLE bronze.erp_px_cat_g1v2 (
	id NVARCHAR(50),
	cat NVARCHAR(50),
	subcat NVARCHAR(50),
	maintenance NVARCHAR(50)
);
