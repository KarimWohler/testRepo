-- https://docs.yugabyte.com/latest/sample-data/northwind/

USE Northwind;

SELECT * FROM Suppliers;
SELECT * FROM Employees;
SELECT * FROM Categories;
SELECT * FROM Products;
SELECT * FROM Orders;
SELECT * FROM [Order Details];

-- Exercise 1

-- Exercise 1.1
SELECT c.CustomerID, c.CompanyName, c.Address, c.City, c.Region, c.PostalCode, c.Country 
FROM Customers c
WHERE c.City = 'London' OR c.City = 'Paris';

-- Exercise 1.2
SELECT * 
FROM Products p
WHERE p.QuantityPerUnit LIKE '%bottle%';

-- Exercise 1.3
SELECT p.* , s.CompanyName, s.Country 
FROM Products p INNER JOIN Suppliers s On p.SupplierID = s.SupplierID
WHERE p.QuantityPerUnit LIKE '%bottle%'


-- Exercise 1.4
SELECT c.CategoryName AS "Category Name",
    COUNT(p.ProductName) AS "Number of Products"
FROM Products p INNER JOIN Categories c 
ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryName
ORDER BY "Number of Products" DESC


-- Exercise 1.5
SELECT CONCAT(e.TitleOfCourtesy, ' ', e.FirstName, ' ', e.LastName, ', ', e.City) AS "Employees"
FROM Employees e
WHERE e.Country = 'UK'


-- Exercise 1.6
-- Each ORDER ID has an EMPLOYEEID which has a TERRITORY ID which has a REGION ID
-- Orders -> Employees -> EmployeeTerritories -> Territories
SELECT t.RegionID, 
    Round(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) AS "Sales Total",
    r.RegionDescription
FROM [Order Details] od INNER JOIN Orders o 
ON od.OrderID = o.OrderID
INNER JOIN Employees e 
ON o.EmployeeID = e.EmployeeID
INNER JOIN EmployeeTerritories et 
ON et.EmployeeID = e.EmployeeID
INNER JOIN Territories t 
ON t.TerritoryID = et.TerritoryID
INNER JOIN Region r
ON r.RegionID = t.RegionID
GROUP BY t.RegionID, r.RegionDescription
HAVING Round(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) > 1000000
ORDER BY t.RegionID


-- Exercise 1.7 
SELECT COUNT(*) AS "Number of Orders that have a Freight amount greater than 100.00 and either USA or UK as Ship Country." 
FROM Orders
WHERE Freight > 100 AND
    (ShipCountry = 'UK' OR 
        ShipCountry = 'USA')


-- Exercise 1.8 
SELECT TOP 1 od.OrderID, 
    ROUND(SUM(od.Discount * od.UnitPrice *od.Quantity), 2) AS "Discount Amount"
FROM [Order Details] od
GROUP BY od.OrderID 
Order BY "Discount Amount" DESC


-- Exercise 2 (given example)
CREATE TABLE films_table
(
    film_name VARCHAR(30),
    film_type VARCHAR(30),
    date_of_release DATE,
    director_name VARCHAR(30),
    writer_name VARCHAR(30),
    star_name VARCHAR(30),
    film_language VARCHAR(15),
    official_website VARCHAR(30),
    plotSummary VARCHAR(MAX),
);

SELECT * FROM films_table;


-- Exercise 2 (Mini Project)

-- Exercise 2.1
CREATE TABLE Spartan_Table
(  
    Title VARCHAR(6),
    First_Name VARCHAR(10),
    Last_Name VARCHAR(10),
    University VARCHAR(30),
    Course_Taken VARCHAR(30),
    Marks_Achieved INT,
)

-- Exercise 2.2
INSERT INTO Spartan_Table
VALUES ('Mr', 'Thomas', 'Canfield', 'University of This Place', 'Sorcery', 1),
('Mr', 'Alex', 'Chang', 'University of Some Place', 'Animal Linguistics', 2),
('Mr', 'Alexander', 'Legon', 'University of Um', 'Acrobatic Sitting', 2),
('Mr', 'Adrian', 'Wong', 'The University', 'Whistling', 1),
('Mr', 'Alex', 'Lynch', 'University of Somewhere', 'Furniture Tester', 1)

SELECT * FROM Spartan_Table


DROP TABLE Spartan_Table


-- Exercise 3

-- Exercise 3.1 
SELECT CONCAT(e.FirstName, ' ', e.LastName) AS "Employee Name", 
        CONCAT(e2.FirstName, ' ', e2.LastName) AS "Reports To"
FROM Employees e LEFT OUTER JOIN Employees e2
ON e.ReportsTo = e2.EmployeeID


-- Exercise 3.2
-- Order Details (Order ID)(Product ID) -> Products (Product ID) (Supplier ID) -> Suppliers (Supplier ID)
SELECT s.CompanyName, 
        ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)),2) AS "Total Sales"
FROM [Order Details] od INNER JOIN Products p
ON p.ProductID = od.ProductID
INNER JOIN Suppliers s
ON S.SupplierID = p.SupplierID
GROUP BY s.CompanyName
HAVING SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) > 10000
ORDER BY "Total Sales" 


-- Exercise 3.3 - Cutomers Year to Date depending on the 'total value' of orders shipped
-- ytd - year to date 
-- Order Details - (Order ID) (Unit Price) (Quantity) (Discount)
-- Orders - (Order Date) (Customer ID) (Order ID)
-- Customers - (Customer ID) (Company Name)
SELECT TOP 10 c.CompanyName, 
    ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) AS "Total Sales (YTD)"
FROM [Order Details] od INNER JOIN Orders o 
ON o.OrderID = od.OrderID
INNER JOIN Customers c 
ON c.CustomerID = o.CustomerID
WHERE YEAR(o.ShippedDate) = (SELECT YEAR(MAX(o.ShippedDate)) FROM Orders o)
GROUP BY c.CompanyName
ORDER BY "Total Sales (YTD)" DESC



-- Exercise 3.4
-- Difference between Order date, and Shipped Date
--  -- Considering Order Date to encompass the entirety of the Shipping Time
-- Cast Average to FLOAT
SELECT CONCAT(MONTH(o.OrderDate), '-', YEAR(o.OrderDate)) AS "Date ",
    ROUND(AVG(CAST(DATEDIFF(dd, o.OrderDate, o.ShippedDate) AS FLOAT)), 2)  AS "Ship Time"
FROM Orders o
GROUP BY Year(o.OrderDate), MONTH(o.OrderDate)
ORDER BY Year(o.OrderDate), MONTH(o.OrderDate)