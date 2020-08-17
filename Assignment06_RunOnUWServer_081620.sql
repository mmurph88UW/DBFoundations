--*************************************************************************--
-- Title: Assignment06
-- Author: Michele Murphy
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2020-08-16, Michele Murphy, Created File
--**************************************************************************--

BEGIN TRY
	USE MASTER;
	IF EXISTS(SELECT NAME FROM SysDatabases WHERE NAME = 'Assignment06DB_MicheleMurphy')
	 BEGIN 
	  ALTER DATABASE Assignment06DB_MicheleMurphy SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	  DROP DATABASE Assignment06DB_MicheleMurphy;
	 END
	CREATE DATABASE Assignment06DB_MicheleMurphy;
END TRY
BEGIN CATCH
	PRINT Error_Number();
END CATCH
GO
USE Assignment06DB_MicheleMurphy;

-------------
-- Create Tables (Module 01)-- 
CREATE TABLE Categories
(CategoryID int IDENTITY(1,1) NOT NULL 
,CategoryName nvarchar(100) NOT NULL
);
GO

CREATE TABLE Products
(ProductID int IDENTITY(1,1) NOT NULL 
,ProductName nvarchar(100) NOT NULL 
,CategoryID int NULL  
,UnitPrice money NOT NULL
);
GO

CREATE TABLE Employees -- New Table
(EmployeeID int IDENTITY(1,1) NOT NULL 
,EmployeeFirstName nvarchar(100) NOT NULL
,EmployeeLastName nvarchar(100) NOT NULL 
,ManagerID int NULL  
);
GO

CREATE TABLE Inventories
(InventoryID int IDENTITY(1,1) NOT NULL
,InventoryDate Date NOT NULL
,EmployeeID int NOT NULL -- New Column
,ProductID int NOT NULL
,Count int NOT NULL
);
GO
--------------------------------------------
-- Add Constraints (Module 02) -- 
BEGIN  -- Categories
	ALTER TABLE Categories 
	 ADD CONSTRAINT pkCategories 
	  PRIMARY KEY (CategoryId);

	ALTER TABLE Categories 
	 ADD CONSTRAINT ukCategories 
	  UNIQUE (CategoryName);
END
GO 

BEGIN -- Products
	ALTER TABLE Products 
	 ADD CONSTRAINT pkProducts 
	  PRIMARY KEY (ProductId);

	ALTER TABLE Products 
	 ADD CONSTRAINT ukProducts 
	  UNIQUE (ProductName);

	ALTER TABLE Products 
	 ADD CONSTRAINT fkProductsToCategories 
	  FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId);

	ALTER TABLE Products 
	 ADD CONSTRAINT ckProductUnitPriceZeroOrHigher 
	  CHECK (UnitPrice >= 0);
END
GO

BEGIN -- Employees
	ALTER TABLE Employees
	 ADD CONSTRAINT pkEmployees 
	  PRIMARY KEY (EmployeeId);

	ALTER TABLE Employees 
	 ADD CONSTRAINT fkEmployeesToEmployeesManager 
	  FOREIGN KEY (ManagerId) REFERENCES Employees(EmployeeId);
END
GO

BEGIN -- Inventories
	ALTER TABLE Inventories 
	 ADD CONSTRAINT pkInventories 
	  PRIMARY KEY (InventoryId);

	ALTER TABLE Inventories
	 ADD CONSTRAINT dfInventoryDate
	  DEFAULT GETDATE() FOR InventoryDate;

	ALTER TABLE Inventories
	 ADD CONSTRAINT fkInventoriesToProducts
	  FOREIGN KEY (ProductId) REFERENCES Products(ProductId);

	ALTER TABLE Inventories 
	 ADD CONSTRAINT ckInventoryCountZeroOrHigher 
	  CHECK (Count >= 0);

	ALTER TABLE Inventories
	 ADD CONSTRAINT fkInventoriesToEmployees
	  FOREIGN KEY (EmployeeId) REFERENCES Employees(EmployeeId);
END 
GO

-- Adding Data (Module 04) -- 
INSERT INTO Categories 
(CategoryName)
SELECT CategoryName 
 FROM Northwind.dbo.Categories
 ORDER BY CategoryID;
GO

INSERT INTO Products
(ProductName, CategoryID, UnitPrice)
SELECT ProductName,CategoryID, UnitPrice 
 FROM Northwind.dbo.Products
  ORDER BY ProductID;
GO

INSERT INTO Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
SELECT E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 FROM Northwind.dbo.Employees AS E
  ORDER BY E.EmployeeID;
GO

INSERT INTO Inventories
(InventoryDate, EmployeeID, ProductID, Count)
SELECT '20170101' AS InventoryDate, 5 AS EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 AS RandomValue
FROM Northwind.dbo.Products
UNION
SELECT '20170201' AS InventoryDate, 7 AS EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 AS RandomValue
FROM Northwind.dbo.Products
UNION
SELECT '20170301' AS InventoryDate, 9 AS EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 AS RandomValue
FROM Northwind.dbo.Products
ORDER BY 1, 2
GO

-- Show the Current data in the Categories, Products, and Inventories Tables
SELECT * FROM Categories;
GO
SELECT * FROM Products;
GO
SELECT * FROM Employees;
GO
SELECT * FROM Inventories;
GO

----------------------
---------------------

/********************************* Questions and Answers *********************************/
/*'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'*/

-- Question 1 (5 pts): How can you create BASIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

/*
USE Assignment06DB_MicheleMurphy;
GO

SELECT * FROM Categories;
GO
SELECT * FROM Products;
GO
SELECT * FROM Employees;
GO
SELECT * FROM Inventories;
GO
*/

-- 1. Create vCategories
CREATE -- DROP
VIEW vCategories
WITH SCHEMABINDING -- Add SCHEMABINDING to stop view dependent table changes
AS 
	SELECT 
		CategoryID
		,CategoryName
	FROM dbo.Categories; -- use 2 part name
GO
-- Review vCategories
SELECT 
	CategoryID
	,CategoryName
	FROM dbo.vCategories;
GO

-- 2. Create vProducts
CREATE 
VIEW vProducts
WITH SCHEMABINDING
AS
	SELECT
		ProductID
		,ProductName
		,CategoryID
		,UnitPrice
	FROM dbo.Products;
GO

-- Review vProducts
SELECT
	ProductID
	,ProductName
	,CategoryID
	,UnitPrice
FROM dbo.vProducts;
GO

-- 3. Create vEmployees
CREATE
VIEW vEmployees
WITH SCHEMABINDING
AS
	SELECT 
		EmployeeID
		,EmployeeFirstName
		,EmployeeLastName
		,ManagerID
	FROM dbo.Employees;
GO

-- Review vEmployees
SELECT 
	EmployeeID
	,EmployeeFirstName
	,EmployeeLastName
	,ManagerID
FROM dbo.vEmployees;
GO

-- 4. Create vInventories
CREATE -- DROP
VIEW vInventories
WITH SCHEMABINDING
AS
	SELECT
		InventoryID
		,InventoryDate
		,EmployeeID
		,ProductID
		,[Count]
	FROM dbo.Inventories;
GO

-- Review vInventories
SELECT
	InventoryID
	,InventoryDate
	,EmployeeID
	,ProductID
	,[Count]
FROM dbo.vInventories;
GO

-- Question 2 (5 pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

/*
SELECT * FROM vCategories;
SELECT * FROM vProducts;
SELECT * FROM vEmployees;
SELECT * FROM vInventories;
GO
*/

-- Remove permissions from table - Grant permission to the new Basic Views
DENY SELECT ON dbo.Categories TO PUBLIC;
GRANT SELECT ON dbo.vCategories TO PUBLIC;

DENY SELECT ON dbo.Products TO PUBLIC;
GRANT SELECT ON dbo.vProducts TO PUBLIC;

DENY SELECT ON dbo.Employees TO PUBLIC;
GRANT SELECT ON dbo.vEmployees TO PUBLIC;

DENY SELECT ON dbo.Inventories TO PUBLIC;
GRANT SELECT ON dbo.vInventories TO PUBLIC;

-- Question 3 (10 pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

/*
SELECT * FROM dbo.vCategories;
SELECT * FROM dbo.vProducts;
GO
*/

-- CREATE View
GO
CREATE
VIEW vCategoryProducts -- DROP VIEW vCategoryProducts
AS
	SELECT TOP 100 PERCENT
	c.CategoryName
	,p.ProductName
	,p.UnitPrice
	FROM dbo.vCategories AS c
	JOIN dbo.vProducts AS p ON c.CategoryID = p.CategoryID
	ORDER BY c.CategoryName
	,p.ProductName;
GO

-- Display Data
SELECT 
	CategoryName
	,ProductName
	,UnitPrice
FROM dbo.vCategoryProducts;
GO

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00


-- Question 4 (10 pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- CREATE View
CREATE
VIEW vProductsInventoryDate -- DROP VIEW vProductsInventoryDate
AS 
	SELECT TOP 100 PERCENT
		p.ProductName
		,i.InventoryDate
		,SUM(i.[Count]) AS [Count]
	FROM dbo.vProducts AS p
	JOIN dbo.vInventories AS i ON p.ProductID = i.ProductID
	GROUP BY p.ProductName
		,i.InventoryDate
	ORDER BY p.ProductName
		,i.InventoryDate
		,SUM(i.[Count]);
GO

-- Display data
-- Wrapping Select in View statement sort order no longer works
SELECT
	ProductName
	,InventoryDate
	,[Count]
FROM dbo.vProductsInventoryDate
ORDER BY ProductName
		,InventoryDate
		,[Count];
GO

-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83


-- Question 5 (10 pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth


-- CREATE View
CREATE
VIEW vInventoryDatesByEmployee -- DROP VIEW vInventoryDatesByEmployee
AS
	SELECT DISTINCT TOP 100 PERCENT i.InventoryDate
	,e.EmployeeFirstName + ' ' + e.EmployeeLastName As EmployeeName
	FROM dbo.vInventories AS i
	JOIN dbo.vEmployees AS e ON i.EmployeeID = e.EmployeeID
	ORDER BY i.InventoryDate;
GO

-- Display Data
SELECT 
	InventoryDate
	,EmployeeName
FROM dbo.vInventoryDatesByEmployee;
GO

-- Question 6 (10 pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- CREATE View
CREATE -- DROP
VIEW vCatProdByInventoryDates
AS
	SELECT TOP 100 PERCENT 
		c.CategoryName
		,p.ProductName
		,i.InventoryDate
		,SUM(i.[Count]) AS [Count]
	FROM dbo.vCategories AS c
	JOIN dbo.vProducts AS p ON c.CategoryID = p.CategoryID
	JOIN dbo.vInventories AS i ON p.ProductID = i.ProductID
	GROUP BY 
		c.CategoryName
		,p.ProductName
		,i.InventoryDate
	ORDER BY 
		c.CategoryName
		,p.ProductName
		,i.InventoryDate
		,SUM(i.[Count]);
GO

-- Display Data
SELECT 
	CategoryName
	,ProductName
	,InventoryDate
	,[Count]
FROM dbo.vCatProdByInventoryDates;
GO

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54


-- Question 7 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- CREATE View
CREATE -- DROP
VIEW vCatProdByInventoryDatesByEmp
AS
	SELECT TOP 100 PERCENT
		c.CategoryName
		,p.ProductName
		,i.InventoryDate
		,SUM(i.[Count]) AS [Count]
		,(e.EmployeeFirstName + ' ' + e.EmployeeLastName) AS EmployeeName
	FROM dbo.vCategories AS c
	JOIN dbo.vProducts AS p ON c.CategoryID = p.CategoryID
	JOIN dbo.vInventories AS i ON p.ProductID = i.ProductID
	JOIN dbo.vEmployees AS e ON i.EmployeeID = e.EmployeeID
	GROUP BY 
		c.CategoryName
		,p.ProductName
		,i.InventoryDate
		,(e.EmployeeFirstName + ' ' + e.EmployeeLastName)
	ORDER BY 
		i.InventoryDate
		,c.CategoryName
		,p.ProductName
		,(e.EmployeeFirstName + ' ' + e.EmployeeLastName);
GO

-- DISPLAY Data
SELECT 
	CategoryName
	,ProductName
	,InventoryDate
	,[Count]
	,EmployeeName
FROM dbo.vCatProdByInventoryDatesByEmp
ORDER BY InventoryDate
	,CategoryName
	,ProductName
	,EmployeeName;
GO

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan


-- Question 8 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- CREATE View
CREATE -- DROP
VIEW vCatProdByInventoryDatesByEmpChaiChang
AS
	SELECT TOP 100 PERCENT
		c.CategoryName
		,p.ProductName
		,i.InventoryDate
		,SUM(i.[Count]) AS [Count]
		,(e.EmployeeFirstName + ' ' + e.EmployeeLastName) AS EmployeeName
	FROM dbo.vCategories AS c
	JOIN (SELECT p2.ProductID
				,p2.ProductName
				,p2.CategoryID
				FROM dbo.vProducts AS p2 
				WHERE p2.ProductName IN ('Chai','Chang')) AS p ON c.CategoryID = p.CategoryID
	JOIN dbo.vInventories AS i ON p.ProductID = i.ProductID
	JOIN dbo.vEmployees AS e ON i.EmployeeID = e.EmployeeID
	GROUP BY 
		c.CategoryName
		,p.ProductName
		,i.InventoryDate
		,(e.EmployeeFirstName + ' ' + e.EmployeeLastName)
	ORDER BY 
		i.InventoryDate
		,c.CategoryName
		,p.ProductName
		,(e.EmployeeFirstName + ' ' + e.EmployeeLastName);
GO

-- DISPLAY Data
SELECT
	CategoryName
	,ProductName
	,InventoryDate
	,[Count]
	,EmployeeName
FROM dbo.vCatProdByInventoryDatesByEmpChaiChang
ORDER BY 
	InventoryDate
	,CategoryName
	,ProductName
	,EmployeeName
GO

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King


-- Question 9 (10 pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- CREATE View
CREATE -- DROP
VIEW vEmployeesByManager
AS
	SELECT TOP 100 PERCENT
		m.EmployeeFirstName + ' ' + m.EmployeeLastName AS Manager
		,e.EmployeeFirstName + ' ' + e.EmployeeLastName AS Employee
	FROM dbo.vEmployees AS e
	JOIN dbo.vEmployees AS m ON e.ManagerID = m.EmployeeID
	ORDER BY 
		(m.EmployeeFirstName + ' ' + m.EmployeeLastName)
		,(e.EmployeeFirstName + ' ' + e.EmployeeLastName);
GO

-- DISPLAY Data
SELECT
	Manager
	,Employee
FROM dbo.vEmployeesByManager
ORDER BY 	
	Manager
	,Employee;
GO

-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan


-- Question 10 (10 pts): How can you create one view to show all the data from all four 
-- BASIC Views?

--CREATE View
CREATE -- DROP
VIEW vInventoriesByProductsByCategoriesByEmployees
WITH SCHEMABINDING
AS
	SELECT
		c.CategoryID
		,c.CategoryName
		,p.ProductID
		,p.ProductName
		,p.UnitPrice
		,i.InventoryID
		,i.InventoryDate
		,i.[Count]
		,e.EmployeeID
		,e.EmployeeFirstName + ' ' + e.EmployeeLastName AS Employee
		,m.EmployeeFirstName + ' ' + m.EmployeeLastName AS Manager
	FROM dbo.vCategories AS c
	JOIN dbo.vProducts AS p ON c.CategoryID = p.CategoryID
	JOIN dbo.vInventories AS i ON p.ProductID = i.ProductID
	JOIN dbo.vEmployees AS e ON i.EmployeeID = e.EmployeeID
	JOIN dbo.vEmployees AS m ON e.ManagerID = m.EmployeeID;
GO

-- DISPLAY Data
SELECT 
	CategoryID
	,CategoryName
	,ProductID
	,ProductName
	,UnitPrice
	,InventoryID
	,InventoryDate
	,[Count]
	,EmployeeID
	,Employee
	,Manager 
FROM dbo.vInventoriesByProductsByCategoriesByEmployees
ORDER BY 
	CategoryName
	,ProductName
	,UnitPrice
	,InventoryDate
	,[Count]
	,Employee
	,Manager 
GO

-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan

-- Test your Views (NOTE: You must change the names to match yours as needed!)
/*
Select * From dbo.vCategories
Select * From dbo.vProducts
Select * From dbo.vInventories
Select * From dbo.vEmployees

Select * From dbo.vCategoryProducts -- dbo.vProductsByCategories -- Q3
Select * From dbo.vProductsInventoryDate -- dbo.vInventoriesByProductsByDates Q4
Select * From dbo.vInventoryDatesByEmployee -- dbo.vInventoriesByEmployeesByDates Q5
Select * From dbo.vCatProdByInventoryDates -- dbo.vInventoriesByProductsByCategories Q6
Select * From dbo.vCatProdByInventoryDatesByEmp -- dbo.vInventoriesByProductsByEmployees Q7
Select * From dbo.vCatProdByInventoryDatesByEmpChaiChang -- dbo.vInventoriesForChaiAndChangByEmployees Q8
Select * From dbo.vEmployeesByManager -- Q9
Select * From dbo.vInventoriesByProductsByCategoriesByEmployees -- Q10
*/
/***************************************************************************************/