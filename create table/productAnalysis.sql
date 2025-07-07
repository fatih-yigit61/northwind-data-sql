
use NORTHWND
drop table ProductAnalysis

create table ProductAnalysis(
        ProductRank INT PRIMARY KEY,
        ProductID NVARCHAR(40),
        ProductName  NVARCHAR(40),
        NofSales int,
        TotalRevenue  float,
        LastOrderedDate date,
);

insert into ProductAnalysis (ProductRank,ProductID,ProductName ,NofSales,TotalRevenue,LastOrderedDate )
select top 30 
 RANK() OVER (ORDER BY SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) DESC) AS ProductRank,
        p.ProductID,
        p.ProductName,
        sum(od.Quantity) as NofSales, 
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalRevenue,
        CAST(MAX(o.OrderDate) AS DATE) AS LastOrderedDate
from Products p 
join [Order Details] od on od.ProductID = p.ProductID
JOIN Orders o ON o.OrderID = od.OrderID
WHERE o.OrderDate >= DATEADD(DAY, -10000, GETDATE())
group by p.ProductID, p.ProductName
order by TotalRevenue desc


select * from ProductAnalysis




