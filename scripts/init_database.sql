/*
===============================================================================
Create Database and Schemas
===============================================================================
Description:
    This script creates the 'DataWarehouse' database and initializes the 
    Medallion Architecture layers (Bronze, Silver, Gold).
    WARNING: This script will drop the existing 'DataWarehouse' database.
===============================================================================
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

-- Create Databases 'DataWarehouse'
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


