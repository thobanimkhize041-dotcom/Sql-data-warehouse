/*
SCRIPT PURPOSE:
This scipt creates a dataBASE named 'datawarehouse' after checking if it exists. If it exists, it is dropped and recreated. Three schemas are also created within the database.
WARNING:
Running the cript will cause the database to be deleted if it already exists. This will lead to permanent deletion of data in the database.

*/
USE master;
GO

IF EXISTS ( SELECT 1 FROM sys.databases WHERE name = 'Datawarehouse')
BEGIN 
ALTER DATABASE Datawarehouse SET SINGLE_USER with ROLLBACK IMMEDIATE;
DROP DATABASE Datawarehouse;
END;
GO

CREATE DATABASE Datawarehouse;
GO

CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
