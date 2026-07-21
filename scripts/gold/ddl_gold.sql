/*
===============================================================================
DDL Script: Create Gold Views
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/
-- Create Dimension: gold.dim_customers
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO
CREATE VIEW gold.dim_customers AS
SELECT 
ROW_NUMBER() OVER(ORDER BY ci.cst_id) Customer_key,--Surrogate key
ci.cst_id AS customer_id,
ci.cst_key AS customer_number,
ci.cst_firstname AS first_name,
ci.cst_lastname AS last_name,
la.CNTRY AS country,
CASE 
	WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
	ELSE COALESCE(ca.GEN,'n/a')
END gender,
ci.cst_marital_status AS marital_status,
ca.BDATE AS birthdate,
ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_CUST_AZ12 ca 
ON ci.cst_key = ca.CID
LEFT JOIN silver.erp_LOC_A101 la
ON la.CID = ci.cst_key;
GO

--Create Dimesion : gold.dim_products
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO
CREATE VIEW gold.dim_products AS
SELECT
ROW_NUMBER() OVER(ORDER BY pr.prd_start_dt,pr.prd_key ) AS product_key, --Surrogate key
pr.prd_id AS product_id,
pr.prd_key AS product_number,
pr.prd_nm AS product_name,
pr.cat_id AS category_id,
px.CAT AS category,
px.SUBCAT AS subcatergory,
px.MAINTENANCE AS maintenance,
pr.prd_cost AS cost,
pr.prd_line AS product_line,
pr.prd_start_dt AS start_date
FROM silver.crm_prd_info pr
LEFT JOIN silver.erp_PX_CAT_G1V2 px
ON pr.cat_id = px.ID
WHERE prd_end_dt IS NULL --Filtering out historical and keeping current
GO

--Create Dimension : gold.fact_sales
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.fact_sales AS
SELECT
cr.sls_ord_num AS order_number,
gp.product_key,
gc.Customer_key,
cr.sls_order_dt AS order_date,
cr.sls_ship_dt AS shipping_date,
cr.sls_due_dt AS due_date,
cr.sls_sales AS sales_amount,
cr.sls_quantity AS quantity,
cr.sls_price AS price
FROM silver.crm_sales_details cr
LEFT JOIN gold.dim_products gp
ON cr.sls_prd_key = gp.product_number
LEFT JOIN gold.dim_customers gc
ON cr.sls_cust_id = gc.customer_id;
GO




