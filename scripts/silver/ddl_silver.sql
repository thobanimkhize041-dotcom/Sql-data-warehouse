/*
=================================================================================
DDL script: Createsilver tables
=================================================================================
Script purpose:
The purpose of the script is create silver tables and to drop any if existing
=================================================================================
Run this script to redefine the ddl sructure of bronze tables
*/

IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
  DROP TABLE silver.crm_cust_info;
GO
CREATE TABLE silver.crm_cust_info(
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname VARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_marital_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO
IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
  DROP TABLE silver.crm_prd_info;
GO
CREATE TABLE silver.crm_prd_info(
	prd_id INT,
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(50),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATETIME,
	prd_end_dt DATETIME,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO
IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
  DROP TABLE silver.crm_sales_details;

GO
CREATE TABLE silver.crm_sales_details(
	sls_ord_num NVARCHAR(50),
	sls_prd_key NVARCHAR(50),
	sls_cust_id INT,
	sls_order_dt INT,
	sls_ship_dt INT,
	sls_due_dt INT,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO
IF OBJECT_ID('silver.erp_CUST_AZ12', 'U') IS NOT NULL
  DROP TABLE silver.erp_CUST_AZ12;

GO

CREATE TABLE silver.erp_CUST_AZ12(
	CID NVARCHAR(50),
	BDATE DATE,
	GEN  VARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO
IF OBJECT_ID('silver.erp_LOC_A101', 'U') IS NOT NULL
  DROP TABLE silver.erp_LOC_A101;

GO
CREATE TABLE silver.erp_LOC_A101(
	CID NVARCHAR(50),
	CNTRY NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO
IF OBJECT_ID('silver.erp_PX_CAT_G1V2', 'U') IS NOT NULL
  DROP TABLE silver.erp_PX_CAT_G1V2;

GO

CREATE TABLE silver.erp_PX_CAT_G1V2(
	ID NVARCHAR(50),
	CAT NVARCHAR(50),
	SUBCAT NVARCHAR(50),
	MAINTENANCE NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
