-- Query: Top Employee per City and Their Best Customer
-- Finds the highest-selling employee in each city (by quantity)
-- and returns their top customer based on sales volume.
-- Uses CTEs with ROW_NUMBER for ranking employees and customers.
use NORTHWND;


WITH TotalQuantityWorkersInCity AS (
    SELECT 
        e.EmployeeID,
        e.City, 
        e.FirstName + ' ' + e.LastName AS eName,
        SUM(od.Quantity) AS TotalQuantity,
        ROW_NUMBER() OVER (PARTITION BY e.City ORDER BY SUM(od.Quantity) DESC) AS rn
    FROM Employees AS e
    JOIN Orders AS o ON o.EmployeeID = e.EmployeeID
    JOIN [Order Details] AS od ON o.OrderID = od.OrderID
    WHERE o.OrderDate >= DATEADD(DAY, -10000, GETDATE())
    GROUP BY e.EmployeeID, e.City, e.FirstName, e.LastName
),

BestCustomerPerTopEmployee AS (
    SELECT 
        tq.City,
        tq.eName,
        tq.TotalQuantity,
        c.ContactName AS BestCustomer,
        c.CompanyName,
        ROW_NUMBER() OVER (PARTITION BY tq.EmployeeID ORDER BY SUM(od.Quantity) DESC) AS custRank
    FROM TotalQuantityWorkersInCity as tq
    JOIN Orders o ON o.EmployeeID = tq.EmployeeID
    JOIN [Order Details] od ON od.OrderID = o.OrderID
    JOIN Customers c ON o.CustomerID = c.CustomerID
    WHERE tq.rn = 1 
    GROUP BY tq.City, tq.eName, tq.TotalQuantity, tq.EmployeeID, c.ContactName, c.CompanyName
)

SELECT 
    City,
    eName,
    TotalQuantity,
    BestCustomer,
    CompanyName
FROM BestCustomerPerTopEmployee
WHERE custRank = 1
ORDER BY TotalQuantity DESC;


----------------------------------------------------------------------------------------------------------------
-- Query: Year-over-Year Sales and Revenue Trend Analysis by Employee
-- This query compares sales quantity and revenue for each employee between 1997 and 1998.
-- It returns whether sales and revenue increased, decreased, or stayed the same.

SELECT
    e.EmployeeID,
    e.FirstName,
    
    SUM(CASE WHEN YEAR(o.OrderDate) = 1997 THEN od.Quantity ELSE 0 END) AS Sales_1997,
    SUM(CASE WHEN YEAR(o.OrderDate) = 1997 THEN od.Quantity * od.UnitPrice ELSE 0 END) AS Revenue_1997,

    SUM(CASE WHEN YEAR(o.OrderDate) = 1998 THEN od.Quantity ELSE 0 END) AS Sales_1998,
    SUM(CASE WHEN YEAR(o.OrderDate) = 1998 THEN od.Quantity * od.UnitPrice ELSE 0 END) AS Revenue_1998,

    CASE 
        WHEN SUM(CASE WHEN YEAR(o.OrderDate) = 1998 THEN od.Quantity ELSE 0 END) >
             SUM(CASE WHEN YEAR(o.OrderDate) = 1997 THEN od.Quantity ELSE 0 END)
        THEN 'Satýþ Arttý'
        WHEN SUM(CASE WHEN YEAR(o.OrderDate) = 1998 THEN od.Quantity ELSE 0 END) <
             SUM(CASE WHEN YEAR(o.OrderDate) = 1997 THEN od.Quantity ELSE 0 END)
        THEN 'Satýþ Azaldý'
        ELSE 'Ayný'
    END AS SalesTrend,

    CASE 
        WHEN SUM(CASE WHEN YEAR(o.OrderDate) = 1998 THEN od.Quantity * od.UnitPrice ELSE 0 END) >
             SUM(CASE WHEN YEAR(o.OrderDate) = 1997 THEN od.Quantity * od.UnitPrice ELSE 0 END)
        THEN 'Ciro Arttý'
        WHEN SUM(CASE WHEN YEAR(o.OrderDate) = 1998 THEN od.Quantity * od.UnitPrice ELSE 0 END) <
             SUM(CASE WHEN YEAR(o.OrderDate) = 1997 THEN od.Quantity * od.UnitPrice ELSE 0 END)
        THEN 'Ciro Azaldý'
        ELSE 'Ayný'
    END AS RevenueTrend

FROM Employees AS e
JOIN Orders AS o ON o.EmployeeID = e.EmployeeID
JOIN [Order Details] AS od ON od.OrderID = o.OrderID
WHERE YEAR(o.OrderDate) IN (1997, 1998)
GROUP BY e.EmployeeID, e.FirstName
ORDER BY e.FirstName;

----------------------------------------------------------------------------------------------------------------
-- Query: Top Selling Product and Its Best City & Seller
-- Finds the highest-selling product overall,
-- then identifies the city with the most sales of that product,
-- and lists the top-selling employees in that city for that product.
-- Uses multiple CTEs to structure the logic step by step.

WITH ProductSales AS (
    SELECT 
        od.ProductID,
        p.ProductName,
        SUM(od.Quantity) AS TotalQuantity
    FROM [Order Details] AS od
    JOIN Products AS p ON p.ProductID = od.ProductID
    GROUP BY od.ProductID, p.ProductName
),
TopProduct AS (
    SELECT TOP 1 *
    FROM ProductSales
    ORDER BY TotalQuantity DESC
),

CitySales AS (
    SELECT 
        c.City,
        e.FirstName,
        od.ProductID,
        SUM(od.Quantity) AS TotalSold
    FROM Orders AS o
    JOIN Customers AS c ON c.CustomerID = o.CustomerID
    JOIN [Order Details] AS od ON od.OrderID = o.OrderID
    JOIN Employees AS e ON e.EmployeeID = o.EmployeeID
    WHERE od.ProductID = (SELECT ProductID FROM TopProduct)
    GROUP BY c.City, e.FirstName, od.ProductID
),

TopCity AS (
    SELECT TOP 1 
        City,
        SUM(TotalSold) AS CityTotal
    FROM CitySales
    GROUP BY City
    ORDER BY CityTotal DESC
)

SELECT TOP 4
    cs.City,    
    tp.ProductName,
    cs.FirstName AS TopSeller,
    cs.TotalSold
FROM CitySales AS cs
JOIN TopCity AS tc ON cs.City = tc.City
JOIN TopProduct AS tp ON cs.ProductID = tp.ProductID
ORDER BY cs.TotalSold DESC




--------------------------------------------------------------------------------------------------
-- Query: Total quantity sold per employee, product, and customer city
-- Shows which employee sold how much of each product, grouped by customer city
-- Useful to identify which employee is strong in which region/product combo

select e.FirstName , p.ProductName , od.Quantity, c.City
from  Customers as c
join Orders as o on o.CustomerID = c.CustomerID
join [Order Details] as od on od.OrderID = o.OrderID
join Employees as e on e.EmployeeID = o.EmployeeID
join Products as p on p.ProductID = od.ProductID
group by e.FirstName ,od.Quantity, p.ProductName , c.City
order by od.Quantity desc