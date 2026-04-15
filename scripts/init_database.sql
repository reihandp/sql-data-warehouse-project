/*
========================================================
Create Database and Schemas
========================================================

Script Purpose:
This script creates a new database named 'DataWarehouse'.
If the database already exists, it will be dropped and recreated.

Additionally, the script creates three schemas:
- bronze
- silver
- gold

WARNING:
Running this script will permanently delete the existing 'DataWarehouse' database.
All data will be lost. Make sure you have proper backups before executing.
========================================================
*/

USE master;
GO

-- Drop and recreate the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse 
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

    DROP DATABASE DataWarehouse;
END;
GO

-- Create Databases 'DawaWarehouse'
CREATE DATABASE DataWarehouse;

-- Use the new database
USE DataWarehouse;
GO

-- Create schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO


