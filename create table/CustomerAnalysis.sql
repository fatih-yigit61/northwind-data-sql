use NORTHWND;
drop table CustomerOrderHistory

CREATE TABLE CustomerOrderHistory (
    CustomerRank INT PRIMARY KEY,
    CustomerID NCHAR(5) NOT NULL,
    CompanyName NVARCHAR(40),
    TotalOrders INT,
    TotalSpent MONEY,
    StartDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);


INSERT INTO CustomerOrderHistory (CustomerRank, CustomerID, CompanyName, TotalOrders, TotalSpent, StartDate)
SELECT TOP 30
    RANK() OVER (ORDER BY SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) DESC) AS CustomerRank,
    c.CustomerID,
    c.CompanyName,
    COUNT(DISTINCT o.OrderID) AS TotalOrders,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSpent,
    CAST(DATEADD(DAY, -10000, GETDATE()) AS DATE) AS StartDate
FROM Products p
JOIN [Order Details] od ON p.ProductID = od.ProductID
JOIN Orders o ON o.OrderID = od.OrderID
JOIN Customers c ON c.CustomerID = o.CustomerID
WHERE o.OrderDate >= DATEADD(DAY, -10000, GETDATE())
GROUP BY c.CustomerID, c.CompanyName
ORDER BY TotalSpent DESC;

SELECT * FROM CustomerOrderHistory
