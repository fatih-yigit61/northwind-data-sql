drop table  CategorySalesSummary;
CREATE TABLE CategorySalesSummary (
    CategoryRank INT PRIMARY KEY,
    CategoryID INT,
    CategoryName NVARCHAR(50),
    TotalSalesCount INT,
    TotalRevenue FLOAT,
    ProductCount INT,
    TopProduct NVARCHAR(50),
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

INSERT INTO CategorySalesSummary (CategoryRank, CategoryID, CategoryName, TotalSalesCount, TotalRevenue, ProductCount, TopProduct)
SELECT TOP 30
    RANK() OVER (ORDER BY SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) DESC) AS CategoryRank,
    c.CategoryID,
    c.CategoryName,
    SUM(od.Quantity) AS TotalSalesCount,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalRevenue,
    COUNT(DISTINCT p.ProductID) AS ProductCount,
    MAX(p.ProductName) AS TopProduct
FROM Categories c
JOIN Products p ON p.CategoryID = c.CategoryID
JOIN [Order Details] od ON od.ProductID = p.ProductID
JOIN Orders o ON o.OrderID = od.OrderID
WHERE o.OrderDate >= DATEADD(DAY, -10000, GETDATE())
GROUP BY c.CategoryID, c.CategoryName
ORDER BY TotalRevenue DESC;

select * from CategorySalesSummary

