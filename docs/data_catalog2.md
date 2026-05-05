# Data Catalog – SQL Data Warehouse Project

> **Project:** SQL Data Warehouse with Medallion Architecture  
> **Platform:** SQL Server  
> **Author:** reihandp  
> **Last Updated:** 2025  

---

## 📌 Overview

This data catalog documents all tables and views across the three layers of the data warehouse: **Bronze**, **Silver**, and **Gold**. It is intended to help business stakeholders, analysts, and developers understand the structure, purpose, and lineage of every dataset in this project.

---

## 🗂️ Architecture Summary

| Layer  | Schema   | Type              | Purpose                                              |
|--------|----------|-------------------|------------------------------------------------------|
| Bronze | `bronze` | Raw Tables        | Stores raw data as-is from source CSV files          |
| Silver | `silver` | Cleaned Tables    | Cleansed, standardized, and normalized data          |
| Gold   | `gold`   | Analytical Views  | Business-ready star schema for reporting & analytics |

---

### 🥉 Bronze Layer

> The Bronze layer ingests raw data directly from ERP and CRM source systems (CSV files) with no transformation. It serves as the raw data landing zone.

#### `bronze.crm_cust_info`
**Source:** CRM System – Customer Information  
**Description:** Contains raw customer master data from the CRM system, including personal details and account status.

| Column Name      | Data Type    | Description                                      |
|------------------|--------------|--------------------------------------------------|
| `cst_id`         | INT          | Unique customer identifier from CRM              |
| `cst_key`        | NVARCHAR(50) | Business key used to identify customer           |
| `cst_firstname`  | NVARCHAR(50) | Customer's first name                            |
| `cst_lastname`   | NVARCHAR(50) | Customer's last name                             |
| `cst_marital_status` | NVARCHAR(10) | Marital status (e.g., Single, Married)       |
| `cst_gndr`       | NVARCHAR(10) | Gender as recorded in CRM                        |
| `cst_create_date`| DATE         | Date when the customer record was created        |


#### `bronze.crm_prd_info`
**Source:** CRM System – Product Information  
**Description:** Contains raw product master data from the CRM system.

| Column Name      | Data Type    | Description                                      |
|------------------|--------------|--------------------------------------------------|
| `prd_id`         | INT          | Unique product identifier                        |
| `prd_key`        | NVARCHAR(50) | Business key for product (includes category code)|
| `prd_nm`         | NVARCHAR(100)| Product name                                     |
| `prd_cost`       | INT          | Cost of the product                              |
| `prd_line`       | NVARCHAR(10) | Product line classification                      |
| `prd_start_dt`   | DATE         | Product availability start date                  |
| `prd_end_dt`     | DATE         | Product availability end date (NULL = current)   |


#### `bronze.crm_sales_details`
**Source:** CRM System – Sales Transactions  
**Description:** Raw sales order detail records from the CRM system.

| Column Name      | Data Type    | Description                                      |
|------------------|--------------|--------------------------------------------------|
| `sls_ord_num`    | NVARCHAR(50) | Sales order number                               |
| `sls_prd_key`    | NVARCHAR(50) | Product key reference                            |
| `sls_cust_id`    | INT          | Customer ID reference                            |
| `sls_order_dt`   | INT          | Order date (stored as integer, e.g. 20110101)    |
| `sls_ship_dt`    | INT          | Shipping date (stored as integer)                |
| `sls_due_dt`     | INT          | Due date (stored as integer)                     |
| `sls_sales`      | INT          | Total sales amount                               |
| `sls_quantity`   | INT          | Quantity of items sold                           |
| `sls_price`      | INT          | Price per unit                                   |



#### `bronze.erp_cust_az12`
**Source:** ERP System – Customer Demographics  
**Description:** Customer demographic data from the ERP system, used for enrichment.

| Column Name  | Data Type    | Description                                          |
|--------------|--------------|------------------------------------------------------|
| `cid`        | NVARCHAR(50) | Customer ID (may include prefix, e.g. "NAS-12345")   |
| `bdate`      | DATE         | Customer birth date                                  |
| `gen`        | NVARCHAR(10) | Gender as recorded in ERP                            |



#### `bronze.erp_loc_a101`
**Source:** ERP System – Customer Location  
**Description:** Customer location/country data from the ERP system.

| Column Name  | Data Type    | Description                             |
|--------------|--------------|-----------------------------------------|
| `cid`        | NVARCHAR(50) | Customer ID reference                   |
| `cntry`      | NVARCHAR(50) | Country name (raw, may be inconsistent) |


#### `bronze.erp_px_cat_g1v2`
**Source:** ERP System – Product Categories  
**Description:** Product category and subcategory hierarchy from the ERP system.

| Column Name    | Data Type    | Description                           |
|----------------|--------------|---------------------------------------|
| `id`           | NVARCHAR(50) | Category identifier                   |
| `cat`          | NVARCHAR(50) | Product category name                 |
| `subcat`       | NVARCHAR(50) | Product subcategory name              |
| `maintenance`  | NVARCHAR(50) | Maintenance classification            |

---

### 🥈 Silver Layer

> The Silver layer contains cleansed, standardized, and normalized data. Data quality issues from the Bronze layer (nulls, duplicates, inconsistent formats, invalid values) are resolved here.



#### `silver.crm_cust_info`
**Source:** `bronze.crm_cust_info`  
**Description:** Deduplicated and standardized customer information. Only the most recent record per customer is retained.

| Column Name          | Data Type    | Transformation Applied                              |
|----------------------|--------------|-----------------------------------------------------|
| `cst_id`             | INT          | No change                                           |
| `cst_key`            | NVARCHAR(50) | Whitespace trimmed                                  |
| `cst_firstname`      | NVARCHAR(50) | Whitespace trimmed                                  |
| `cst_lastname`       | NVARCHAR(50) | Whitespace trimmed                                  |
| `cst_marital_status` | NVARCHAR(10) | Standardized: `'M'` → `'Married'`, `'S'` → `'Single'`, others → `'n/a'` |
| `cst_gndr`           | NVARCHAR(10) | Standardized: `'M'` → `'Male'`, `'F'` → `'Female'`, others → `'n/a'`   |
| `cst_create_date`    | DATE         | No change                                           |



#### `silver.crm_prd_info`
**Source:** `bronze.crm_prd_info`  
**Description:** Cleaned product data with derived category key and calculated end dates.

| Column Name      | Data Type    | Transformation Applied                                |
|------------------|--------------|-------------------------------------------------------|
| `prd_id`         | INT          | No change                                             |
| `cat_id`         | NVARCHAR(50) | Extracted from `prd_key` (characters before `-`)      |
| `prd_key`        | NVARCHAR(50) | Cleaned: dashes replaced with underscores             |
| `prd_nm`         | NVARCHAR(100)| Whitespace trimmed                                    |
| `prd_cost`       | INT          | Nulls replaced with 0                                 |
| `prd_line`       | NVARCHAR(10) | Standardized: `'M'` → `'Mountain'`, `'R'` → `'Road'`, `'S'` → `'Other Sales'`, `'T'` → `'Touring'` |
| `prd_start_dt`   | DATE         | No change                                             |
| `prd_end_dt`     | DATE         | Derived using `LEAD()` window function (start of next record - 1 day) |


#### `silver.crm_sales_details`
**Source:** `bronze.crm_sales_details`  
**Description:** Cleaned sales transactions with properly formatted dates and validated financial figures.

| Column Name      | Data Type    | Transformation Applied                                     |
|------------------|--------------|-------------------------------------------------------------|
| `sls_ord_num`    | NVARCHAR(50) | No change                                                   |
| `sls_prd_key`    | NVARCHAR(50) | No change                                                   |
| `sls_cust_id`    | INT          | No change                                                   |
| `sls_order_dt`   | DATE         | Converted from INT (YYYYMMDD) to DATE; invalid values set to NULL |
| `sls_ship_dt`    | DATE         | Converted from INT to DATE; invalid values set to NULL      |
| `sls_due_dt`     | DATE         | Converted from INT to DATE; invalid values set to NULL      |
| `sls_sales`      | INT          | Recalculated as `sls_quantity * ABS(sls_price)` when null or invalid |
| `sls_quantity`   | INT          | No change                                                   |
| `sls_price`      | INT          | Absolute value applied; null replaced with derived value    |



#### `silver.erp_cust_az12`
**Source:** `bronze.erp_cust_az12`  
**Description:** Cleaned ERP customer demographics with validated birth dates and standardized gender.

| Column Name  | Data Type    | Transformation Applied                                     |
|--------------|--------------|------------------------------------------------------------|
| `cid`        | NVARCHAR(50) | Prefix `'NAS'` removed for join compatibility              |
| `bdate`      | DATE         | Future dates set to NULL; dates before 1924 set to NULL    |
| `gen`        | NVARCHAR(10) | Standardized: `'F'`/`'Female'` → `'Female'`, `'M'`/`'Male'` → `'Male'`, others → `'n/a'` |



#### `silver.erp_loc_a101`
**Source:** `bronze.erp_loc_a101`  
**Description:** Cleaned customer location data with standardized country names.

| Column Name  | Data Type    | Transformation Applied                                  |
|--------------|--------------|---------------------------------------------------------|
| `cid`        | NVARCHAR(50) | Dashes removed for join compatibility                   |
| `cntry`      | NVARCHAR(50) | Standardized: e.g. `'DE'` → `'Germany'`, `'US'`/`'USA'` → `'United States'`, empty → `'n/a'` |



#### `silver.erp_px_cat_g1v2`
**Source:** `bronze.erp_px_cat_g1v2`  
**Description:** No significant transformation; serves as a clean lookup table for product categories.

| Column Name    | Data Type    | Transformation Applied |
|----------------|--------------|------------------------|
| `id`           | NVARCHAR(50) | No change              |
| `cat`          | NVARCHAR(50) | Whitespace trimmed     |
| `subcat`       | NVARCHAR(50) | Whitespace trimmed     |
| `maintenance`  | NVARCHAR(50) | Whitespace trimmed     |

---

### 🥇 Gold Layer

> The Gold layer contains business-ready views modeled as a **Star Schema**. These views are the primary consumption layer for BI tools, ad-hoc analysis, and reporting.

**Star Schema Overview:**
```
         dim_customers
               |
fact_sales ────┤
               |
         dim_products
```

---

#### `gold.dim_customers`
**Type:** Dimension View  
**Source:** `silver.crm_cust_info` + `silver.erp_cust_az12` + `silver.erp_loc_a101`  
**Description:** Unified customer dimension integrating data from CRM and ERP systems. CRM is the master source; ERP data is used to enrich missing attributes. Each row represents one unique customer.

| Column Name       | Data Type    | Description                                            | Example            |
|-------------------|--------------|--------------------------------------------------------|--------------------|
| `customer_key`    | INT          | Surrogate primary key (generated via `ROW_NUMBER()`)   | 1, 2, 3            |
| `customer_id`     | INT          | Original customer ID from CRM                          | 10001              |
| `customer_number` | NVARCHAR(50) | Business key for the customer                          | `'CUST-10001'`     |
| `first_name`      | NVARCHAR(50) | Customer's first name                                  | `'John'`           |
| `last_name`       | NVARCHAR(50) | Customer's last name                                   | `'Smith'`          |
| `country`         | NVARCHAR(50) | Customer's country of residence                        | `'United States'`  |
| `marital_status`  | NVARCHAR(10) | Marital status                                         | `'Married'`        |
| `gender`          | NVARCHAR(10) | Gender (CRM preferred; ERP used as fallback)           | `'Male'`           |
| `birthdate`       | DATE         | Customer's date of birth                               | `1980-05-15`       |
| `create_date`     | DATE         | Date the customer record was first created             | `2011-03-01`       |



#### `gold.dim_products`
**Type:** Dimension View  
**Source:** `silver.crm_prd_info` + `silver.erp_px_cat_g1v2`  
**Description:** Unified product dimension combining product master data and category hierarchy. Only currently active products are included (where `prd_end_dt IS NULL`).

| Column Name        | Data Type    | Description                                          | Example              |
|--------------------|--------------|------------------------------------------------------|----------------------|
| `product_key`      | INT          | Surrogate primary key (generated via `ROW_NUMBER()`) | 1, 2, 3              |
| `product_id`       | INT          | Original product ID from CRM                         | 210                  |
| `product_number`   | NVARCHAR(50) | Business key for the product                         | `'BK-M68B-38'`       |
| `product_name`     | NVARCHAR(100)| Full product name                                    | `'Mountain-200 Black'`|
| `category_id`      | NVARCHAR(50) | Category identifier (used for joining)               | `'CAT-01'`           |
| `category`         | NVARCHAR(50) | Product category                                     | `'Bikes'`            |
| `subcategory`      | NVARCHAR(50) | Product subcategory                                  | `'Mountain Bikes'`   |
| `maintenance`      | NVARCHAR(50) | Maintenance classification                           | `'Yes'`              |
| `cost`             | INT          | Unit cost of the product                             | 1912                 |
| `product_line`     | NVARCHAR(50) | Product line (e.g. Mountain, Road, Touring)          | `'Mountain'`         |
| `start_date`       | DATE         | Date product became available                        | `2010-12-01`         |


#### `gold.fact_sales`
**Type:** Fact View  
**Source:** `silver.crm_sales_details` + `gold.dim_customers` + `gold.dim_products`  
**Description:** Central fact table containing all sales transactions. Each row represents one line item of a sales order. Foreign keys reference the dimension views using surrogate keys.

| Column Name      | Data Type    | Description                                            | Example         |
|------------------|--------------|--------------------------------------------------------|-----------------|
| `order_number`   | NVARCHAR(50) | Sales order number (business key)                      | `'SO-12345'`    |
| `product_key`    | INT          | Foreign key → `gold.dim_products.product_key`          | 47              |
| `customer_key`   | INT          | Foreign key → `gold.dim_customers.customer_key`        | 123             |
| `order_date`     | DATE         | Date when the order was placed                         | `2013-06-15`    |
| `shipping_date`  | DATE         | Date when the order was shipped                        | `2013-06-22`    |
| `due_date`       | DATE         | Date when the order is due                             | `2013-07-02`    |
| `sales_amount`   | INT          | Total sales value for the line item                    | 3578            |
| `quantity`       | INT          | Number of units sold                                   | 2               |
| `price`          | INT          | Unit selling price                                     | 1789            |


---
### 📐 Data Lineage Summary

```
Source CSVs (ERP & CRM)
        │
        ▼
  [Bronze Layer]          ← Raw ingestion, no transformation
  bronze.crm_cust_info
  bronze.crm_prd_info
  bronze.crm_sales_details
  bronze.erp_cust_az12
  bronze.erp_loc_a101
  bronze.erp_px_cat_g1v2
        │
        ▼
  [Silver Layer]          ← Cleansed, standardized, deduplicated
  silver.crm_cust_info
  silver.crm_prd_info
  silver.crm_sales_details
  silver.erp_cust_az12
  silver.erp_loc_a101
  silver.erp_px_cat_g1v2
        │
        ▼
  [Gold Layer]            ← Star schema, business-ready
  gold.dim_customers
  gold.dim_products
  gold.fact_sales
        │
        ▼
  BI Tools / Analytics / Reporting
```

---

### 📝 Notes

- All Gold layer objects are **views**, not physical tables, to ensure data is always up to date.
- Surrogate keys in the Gold layer are generated using `ROW_NUMBER()` and are not persisted — they are computed at query time.
- Gender conflicts between CRM and ERP are resolved by **prioritizing CRM** as the master source.
- Sales amount validation rule: `sales_amount = quantity × price`. Records where this does not hold are corrected during Silver transformation.
- Date fields in the Bronze sales table are stored as integers (YYYYMMDD format) and converted to proper `DATE` types in Silver.
