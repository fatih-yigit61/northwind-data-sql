
-- Top 10 suppliers with the highest total of UnitsInStock + UnitsOnOrder per product

select top 10 s.SupplierID, s.CompanyName,p.ProductName,(p.QuantityPerUnit),p.UnitPrice,s.City,sum(p.UnitsInStock + p.UnitsOnOrder) as SuppliedProduct
from Suppliers s 
left join Products p on p.SupplierID = s.SupplierID
group by s.SupplierID, s.CompanyName,p.ProductName,p.UnitPrice,s.City,p.QuantityPerUnit
order by SuppliedProduct desc

-- Returns the most expensive product (by UnitPrice) for each order

------------------------------------------------------------------------------
------------------------------------------------------------------------------
WITH RankedProducts AS (
    SELECT
        od.OrderID,
        p.ProductName,
        od.UnitPrice,
        ROW_NUMBER() OVER (
            PARTITION BY od.OrderID
            ORDER BY od.UnitPrice DESC
        ) AS r
    FROM [Order Details] od
    JOIN Products p ON od.ProductID = p.ProductID
)

SELECT
    OrderID,
    ProductName,
    UnitPrice
FROM RankedProducts
WHERE r = 1;

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Customers who ordered the same product more than once,
-- showing first and last order dates for that product.

SELECT 
    c.CustomerID,
    c.CompanyName,
    p.ProductName,
    MIN(o.OrderDate) AS FirstOrderDate,
    MAX(o.OrderDate) AS LastOrderDate,
    COUNT(DISTINCT o.OrderID) AS OrderCount
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN [Order Details] od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
GROUP BY c.CustomerID, c.CompanyName, p.ProductName
HAVING COUNT(DISTINCT o.OrderID) > 1  -- Only those who ordered the same product more than once
ORDER BY c.CustomerID, OrderCount DESC;


-----------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Product pairs that were ordered together in the same order
-- Sorted by how frequently they were paired.

SELECT 
    p1.ProductName AS ProductA,
    p2.ProductName AS ProductB,
    COUNT(*) AS PairCount
FROM [Order Details] od1
JOIN [Order Details] od2 
    ON od1.OrderID = od2.OrderID AND od1.ProductID < od2.ProductID  -- avoid self-join & duplicate pairs
JOIN Products p1 ON od1.ProductID = p1.ProductID
JOIN Products p2 ON od2.ProductID = p2.ProductID
GROUP BY p1.ProductName, p2.ProductName
ORDER BY PairCount DESC;


-----------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Top 3 products by revenue per category
WITH ProductRevenue AS (
    SELECT 
        p.ProductID,
        p.ProductName,
        c.CategoryName,
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalRevenue
    FROM [Order Details] od
    JOIN Products p ON od.ProductID = p.ProductID
    JOIN Categories c ON p.CategoryID = c.CategoryID
    GROUP BY p.ProductID, p.ProductName, c.CategoryName
),
RankedProducts AS (
    SELECT *,
        DENSE_RANK() OVER (
            PARTITION BY CategoryName
            ORDER BY TotalRevenue DESC
        ) AS rank
    FROM ProductRevenue
)
SELECT 
    CategoryName,
    ProductName,
    TotalRevenue
FROM RankedProducts
WHERE rank <= 3
ORDER BY CategoryName, TotalRevenue DESC;
