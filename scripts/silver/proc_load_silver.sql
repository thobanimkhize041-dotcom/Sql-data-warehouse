/*
===============================================================================================================
Stored procedure: Load silver layer( Bronze -> Silver)
===============================================================================================================
Script purpose:
This stored procedure performs the ETL to populate the 'silver' schema tables from the 'bronze' schema tables
Actions performed:
  -Truncate the silver tables
  - Insert the transformed and cleaned data from bronze into the silver tables
Parameters:
No parameters
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN

	PRINT '>>>>>Truncate table silver.crm_cust_info AND Inserting into table silver.crm_cust_info'
	TRUNCATE TABLE silver.crm_cust_info;
	INSERT INTO silver.crm_cust_info(
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date
	)
	SELECT
	cst_id,
	cst_key,
	TRIM(cst_firstname) cst_firstname,
	TRIM(cst_lastname) cst_lastname ,
	CASE WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
		 WHEN UPPER(TRIM(cst_marital_status))= 'S' THEN 'Single'
		 ELSE 'n/a'
	END cst_marital_status,
	CASE WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
		 WHEN UPPER(TRIM(cst_gndr))= 'F' THEN 'Female'
		 ELSE 'n/a'
	END cst_gndr,
	cst_create_date
	FROM (
	SELECT 
	*,
	ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) flag_last
	FROM bronze.crm_cust_info
	WHERE cst_id IS NOT NULL
	)t
	WHERE flag_last = 1;

	PRINT '>>>>>Truncate table silver.crm_prd_info AND Inserting into table silver.crm_prd_info'
	TRUNCATE TABLE silver.crm_prd_info;
	INSERT INTO silver.crm_prd_info(
	prd_id,
	cat_id,
	prd_key,
	prd_nm,
	prd_cost,
	prd_line,
	prd_start_dt,
	prd_end_dt
	)
	SELECT 
	prd_id,
	REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
	SUBSTRING(prd_key,7,LEN(prd_key))  prd_key,
	prd_nm,
	ISNULL(prd_cost,0) prd_cost,
	CASE 
		WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
		WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
		WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
		WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
		ELSE 'n/a'
	END prd_line,
	CAST(CAST(prd_start_dt AS VARCHAR) AS DATE) prd_start_dt,
	CAST(CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS VARCHAR) AS DATE) prd_end_dt
	FROM bronze.crm_prd_info;


	PRINT '>>>>>Truncate table silver.crm_sales_details AND Inserting into table silver.crm_sales_details'
	TRUNCATE TABLE silver.crm_sales_details;
	INSERT INTO silver.crm_sales_details(
		sls_ord_num,
		sls_prd_key ,
		sls_cust_id ,
		sls_order_dt ,
		sls_ship_dt ,
		sls_due_dt ,
		sls_sales,
		sls_quantity ,
		sls_price 
	)
	SELECT 
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE 
		WHEN sls_order_dt < 0 THEN NULL
		WHEN LEN(sls_order_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
	END sls_order_dt, 
	CASE 
		WHEN sls_ship_dt < 0 THEN NULL
		WHEN LEN(sls_ship_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
	END sls_ship_dt, 
	CASE 
		WHEN sls_due_dt < 0 THEN NULL
		WHEN LEN(sls_due_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
	END sls_due_dt,
	CASE 
		WHEN sls_sales IS NULL OR sls_sales != ABS(sls_price) * sls_quantity OR sls_sales < 0 THEN sls_quantity * ABS(sls_price) 
		ELSE sls_sales
	END sls_sales,
	sls_quantity,
	CASE 
		WHEN sls_price IS NULL OR sls_price < 0 THEN  sls_sales / NULLIF(sls_quantity,0)
		ELSE sls_price
	END sls_price
	FROM bronze.crm_sales_details;

	PRINT '>>>>>Truncate table silver.erp_CUST_AZ12 AND Inserting into table silver.erp_CUST_AZ12'
	TRUNCATE TABLE silver.erp_CUST_AZ12;
	INSERT INTO silver.erp_CUST_AZ12(
	CID,
	BDATE,
	GEN
	)
	SELECT
	CASE 
		WHEN CID  LIKE ('NAS%') THEN SUBSTRING(CID, 4, LEN(CID))
		ELSE CID
	END CID,
	CASE 
		WHEN BDATE > GETDATE() THEN NULL
		ELSE BDATE
	END BDATE,
	CASE 
		WHEN UPPER(TRIM(GEN)) IN ('M','MALE') THEN 'Male'
		WHEN UPPER(TRIM(GEN)) IN ('F','FEMALE') THEN 'Female'
		ELSE 'n/a'
	END GEN
	FROM bronze.erp_CUST_AZ12;

	PRINT '>>>>>Truncate table silver.erp_LOC_A101 AND Inserting into table silver.erp_LOC_A101'
	TRUNCATE TABLE silver.erp_LOC_A101;
	INSERT INTO silver.erp_LOC_A101(
	CID,
	CNTRY
	)

	SELECT 
	REPLACE(CID, '-','') CID,
	CASE 
		WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
		WHEN TRIM(CNTRY) IN ('US','USA') THEN 'United States'
		WHEN TRIM(CNTRY) = '' OR TRIM(CNTRY) IS NULL THEN 'n/a'
		ELSE TRIM(CNTRY)
	END	CNTRY
	FROM bronze.erp_LOC_A101;

	PRINT '>>>>>Truncate table silver.erp_PX_CAT_G1V2 AND Inserting into table silver.erp_PX_CAT_G1V2'
	TRUNCATE TABLE silver.erp_PX_CAT_G1V2;
	INSERT INTO silver.erp_PX_CAT_G1V2(
	ID,
	CAT,
	SUBCAT,
	MAINTENANCE
	)

	SELECT
	ID,
	CAT,
	SUBCAT,
	MAINTENANCE
	FROM bronze.erp_PX_CAT_G1V2;

END
