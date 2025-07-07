create table EmployeeSalesPerformance (

	EmployeeRank int ,
	EmployeeID int,
	FullName varchar (20),
	TotalOrders int,
	TotalRevenue float,
	LastOrderDate date,
	foreign key (EmployeeID)  references Employees(EmployeeID),
);



INSERT INTO EmployeeSalesPerformance(EmployeeRank, EmployeeID, FullName, TotalOrders, TotalRevenue, LastOrderDate)
SELECT TOP 30
    RANK() OVER (ORDER BY SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) DESC) AS EmployeeRank,
    e.EmployeeID,
    e.FirstName + ' ' + e.LastName AS FullName,
    COUNT(DISTINCT o.OrderID) AS TotalOrders,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalRevenue,
    MAX(o.OrderDate) AS LastOrderDate
FROM Employees e
JOIN Orders o ON o.EmployeeID = e.EmployeeID
JOIN [Order Details] od ON od.OrderID = o.OrderID
GROUP BY e.EmployeeID, e.FirstName, e.LastName
ORDER BY TotalRevenue DESC;


select * from EmployeeSalesPerformance