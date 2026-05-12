# 🌟 Data Catalog: Gold Layer Documentation

## 📖 Overview
The **Gold Layer** represents the final stage of the Medallion Architecture. It contains business-level data structured for high-performance analytical reporting and BI tools. This layer follows a **Star Schema** design, consisting of dimension and fact tables to support key business metrics.

---

## 🏗️ Data Dictionary

### 1. 👤 Dimension: Customers (`gold.dim_customers`)
**Business Value:** Enables customer segmentation and demographic analysis (e.g., sales performance by country or gender).

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| **customer_key** | INT | Surrogate key uniquely identifying each customer record. |
| **customer_id** | INT | Unique numerical identifier assigned to each customer. |
| **customer_number** | NVARCHAR(50) | Alphanumeric identifier used for tracking and referencing. |
| **first_name** | NVARCHAR(50) | The customer's first name. |
| **last_name** | NVARCHAR(50) | The customer's last name or family name. |
| **country** | NVARCHAR(50) | Country of residence (e.g., 'Australia'). |
| **marital_status** | NVARCHAR(50) | Marital status (e.g., 'Married', 'Single'). |
| **gender** | NVARCHAR(50) | Gender of the customer (e.g., 'Male', 'Female'). |
| **birthdate** | DATE | Date of birth (YYYY-MM-DD). |
| **create_date** | DATE | Date and time when the record was created. |

---

### 2. 📦 Dimension: Products (`gold.dim_products`)
**Business Value:** Allows for product performance tracking, inventory categorization, and pricing strategy analysis.

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| **product_key** | INT | Surrogate key uniquely identifying each product record. |
| **product_id** | INT | Unique identifier for internal tracking and referencing. |
| **product_number** | NVARCHAR(50) | Alphanumeric code representing the product. |
| **product_name** | NVARCHAR(50) | Descriptive name (includes type, color, and size). |
| **category_id** | NVARCHAR(50) | Unique identifier for the product's category. |
| **category** | NVARCHAR(50) | Broad classification (e.g., Bikes, Components). |
| **subcategory** | NVARCHAR(50) | Detailed classification (e.g., Mountain Bikes). |
| **maintenance_required**| NVARCHAR(50) | Indicates if the product requires maintenance ('Yes'/'No'). |
| **cost** | INT | The cost or base price of the product. |
| **product_line** | NVARCHAR(50) | Specific series (e.g., Road, Mountain). |
| **start_date** | DATE | The date when the product became available. |

---

### 3. 💰 Fact: Sales (`gold.fact_sales`)
**Business Value:** The core transactional table used to calculate Revenue, Quantity Sold, and Order Fullfilment metrics.

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| **order_number** | NVARCHAR(50) | Unique alphanumeric identifier for each sales order. |
| **product_key** | INT | Foreign key linking to `gold.dim_products`. |
| **customer_key** | INT | Foreign key linking to `gold.dim_customers`. |
| **order_date** | DATE | The date when the order was placed. |
| **shipping_date** | DATE | The date when the order was shipped. |
| **due_date** | DATE | The date when the payment was due. |
| **sales_amount** | INT | Total monetary value of the sale item. |
| **quantity** | INT | Number of units ordered. |
| **price** | INT | Price per unit for the line item. |

---

## 🚀 Key Features
* **Star Schema Optimized:** Designed for efficient joins between facts and dimensions.
* **Business Ready:** Data is cleaned, transformed, and ready for Power BI/Tableau.
* **Historical Tracking:** Includes surrogate keys and dates for accurate reporting.
