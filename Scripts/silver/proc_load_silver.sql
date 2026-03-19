/*
---------------------------------------------------------------
Stored Procedure: Load Silver Layer (Bronze -> Silver)
---------------------------------------------------------------

Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to
    populate the 'silver' schema tables from the 'bronze' schema.

Actions Performed:
    - Truncates Silver tables.
    - Inserts transformed and cleansed data from Bronze into Silver tables.

Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC silver.load_silver;
---------------------------------------------------------------
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '======================================================';
		PRINT 'Loading Silver Layer';
		PRINT '======================================================';

		-- Inserting data into Silver Product info table
		SET @start_time = GETDATE();
		PRINT '>> Truncating table: silver.crm_product_info'
		TRUNCATE TABLE silver.crm_product_info;
		PRINT '>> Inserting data into: silver.crm_product_info'
		INSERT INTO silver.crm_product_info (
			product_id,
			category_id,
			product_key,
			product_nm,
			product_cost,
			product_line,
			product_start_date,
			product_end_date
		)

		SELECT
			product_id,
			REPLACE(SUBSTRING(product_key, 1, 5), '-', '_') AS category_id,   -- Extract Category ID
			SUBSTRING(product_key, 7, LEN(product_key)) AS product_key,		  -- Extract Product Key
			product_nm,
			ISNULL(product_cost, 0) AS product_cost,
			CASE UPPER(TRIM(product_line))
				WHEN 'M' THEN 'Mountain'
				WHEN 'R' THEN 'Road'
				WHEN 'S' THEN 'Other Sales'
				WHEN 'T' THEN 'Tour'
				ELSE 'n/a'
			END AS product_line,		-- Map product line codes to descriptive values
			CAST(product_start_date AS DATE) AS product_start_date,
			-- Calculate end date as one day before the next start date
			CAST(LEAD(product_start_date) OVER (PARTITION BY product_key ORDER BY product_start_date) - 1 AS DATE) AS product_end_date
		FROM bronze.crm_product_info;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '>> -----------------'

		-- =========================================================================

		-- Inserting data into Silver ERP location table
		SET @start_time = GETDATE();
		PRINT '>> Truncating table: silver.erp_loc_a101'
		TRUNCATE TABLE silver.erp_loc_a101;
		PRINT '>> Inserting data into: silver.erp_loc_a101'
		INSERT INTO silver.erp_loc_a101(
			cid,
			cntry
		)

		SELECT
			REPLACE(cid, '-', '') AS cid,
			CASE 
				WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
				WHEN UPPER(TRIM(cntry)) IN ('US', 'USA', 'UNITED STATES') THEN 'United States'
				WHEN cntry = '' OR cntry IS NULL THEN 'n/a'
				ELSE TRIM(cntry)
			END AS country				-- Normalize and handle missing or blank country codes
		FROM bronze.erp_loc_a101;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '>> -----------------'

		-- =========================================================================

		-- Inserting data into Silver ERP cust table
		SET @start_time = GETDATE();
		PRINT '>> Truncating table: silver.erp_cust_az12'
		TRUNCATE TABLE silver.erp_cust_az12;
		PRINT '>> Inserting data into: silver.erp_cust_az12'
		INSERT INTO silver.erp_cust_az12(
			cid,
			bdate,
			gen
		)

		SELECT
			CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
				 ELSE cid
			END AS cid,				-- Remove 'NAS' prefix if present
			CASE WHEN bdate > GETDATE() THEN NULL
				 ELSE bdate
			END AS bdate,			-- Set future birth dates to null
			CASE WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
				 WHEN UPPER(TRIM(gen)) IN ('M', 'FEMALE') THEN 'Female'
				 ELSE 'n/a'
			END as gender			-- Normalize gender values and handle unknown cases
		FROM bronze.erp_cust_az12;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '>> -----------------'

		-- =========================================================================

		-- Inserting data into Silver ERP cat table
		SET @start_time = GETDATE();
		PRINT '>> Truncating table: silver.erp_px_cat_g1v2'
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		PRINT '>> Inserting data into: silver.erp_px_cat_g1v2'
		INSERT INTO silver.erp_px_cat_g1v2(
			id,
			cat,
			subcat,
			maintenance
		)

		SELECT
			id,
			cat,
			subcat,
			maintenance
		FROM bronze.erp_px_cat_g1v2;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '>> -----------------'

		-- =========================================================================

		-- Inserting data into Silver Customer info table
		SET @start_time = GETDATE();
		PRINT '>> Truncating table: silver.crm_customer_info'
		TRUNCATE TABLE silver.crm_customer_info;
		PRINT '>> Inserting data into: silver.crm_customer_info'
		INSERT INTO silver.crm_customer_info(
			customer_id,
			customer_key,
			customer_firstname,
			customer_lastname,
			customer_marital_status,
			customer_gender,
			customer_create_date
		)

		SELECT
			customer_id,
			customer_key,
			TRIM(customer_firstname) AS customer_firstname,
			TRIM(customer_lastname) AS customer_lastname,
			CASE WHEN UPPER(TRIM(customer_marital_status)) = 'M' THEN 'Married'
				 WHEN UPPER(TRIM(customer_marital_status)) = 'S' THEN 'Single'
				 ELSE 'n/a'
			END customer_marital_status,      -- Normalise marital status values to readable format
			CASE WHEN UPPER(TRIM(customer_gender)) = 'M' THEN 'Male'
				 WHEN UPPER(TRIM(customer_gender)) = 'F' THEN 'Female'
				 ELSE 'n/a'
			END customer_gender,              -- Normalise gender values to readable format
			customer_create_date
		FROM(
			-- Removing duplicate records
			SELECT
				*,
				ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY customer_create_date DESC) as flag_last
			FROM bronze.crm_customer_info
			WHERE customer_id IS NOT NULL
		)t WHERE flag_last = 1;               -- Select the most recent record per customer
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '>> -----------------'

		-- =========================================================================

		-- Inserting data into Silver Sales details table
		SET @start_time = GETDATE();
		PRINT '>> Truncating table: silver.crm_sales_details'
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT '>> Inserting data into: silver.crm_sales_details'
		INSERT INTO silver.crm_sales_details (
			sales_order_no,
			sales_product_key,
			sales_customer_id,
			sales_order_date,
			sales_ship_date,
			sales_due_date,
			sales_sales,
			sales_quantity,
			sales_price
		)

		SELECT
			sales_order_no,
			sales_product_key,
			sales_customer_id,
			CASE 
				WHEN sales_order_date <= 0 OR LEN(sales_order_date) != 8 THEN NULL
				ELSE CAST(CAST(sales_order_date AS VARCHAR) AS DATE)
			END AS sales_order_date,
			CASE 
				WHEN sales_ship_date <= 0 OR LEN(sales_ship_date) != 8 THEN NULL
				ELSE CAST(CAST(sales_ship_date AS VARCHAR) AS DATE)
			END AS sales_ship_date,
			CASE 
				WHEN sales_due_date <= 0 OR LEN(sales_due_date) != 8 THEN NULL
				ELSE CAST(CAST(sales_due_date AS VARCHAR) AS DATE)
			END AS sales_due_date,
			CASE 
				WHEN sales_sales <= 0 OR sales_sales IS NULL OR sales_sales != sales_price * sales_quantity THEN ABS(sales_price) * sales_quantity
				ELSE sales_sales
			END AS sales_sales,					-- Recalculate sales if original value is missing or incorrect
			sales_quantity,
			CASE 
				WHEN sales_price <= 0 OR sales_price IS NULL THEN sales_sales / NULLIF(sales_quantity, 0)
				ELSE sales_price				-- Recalculate price if original value is missing or incorrect
			END AS sales_price
		FROM bronze.crm_sales_details;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '>> -----------------'

		SET @batch_end_time = GETDATE();
		PRINT '================================================'
		PRINT 'Silver Layer load is completed.'
		PRINT 'Total Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + 'seconds';
		PRINT '================================================'
	END TRY

	BEGIN CATCH
		PRINT '================================================='
		PRINT 'Error occured during loading Silver Layer.'
		PRINT 'Error Message: ' + ERROR_MESSAGE();
		PRINT 'Error Message: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message: ' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '================================================='
	END CATCH
END

-- =========================================================================
