DROP TABLE IF EXISTS FactSales;

CREATE TABLE FactSales (
    SaleID INT IDENTITY(1,1) PRIMARY KEY,

    OrderID INT,
    OrderDate DATE,

    CustomerID NCHAR(5),
    ProductID INT,
    CategoryID INT,
    SupplierID INT,
    EmployeeID INT,
    ShipperID INT,
    TerritoryID NVARCHAR(20),
    RegionID INT,

    CustomerRank INT,
    ProductRank INT,
    EmployeeRank INT,
    CategoryRank INT,

    UnitPrice MONEY,
    Quantity INT,
    Discount FLOAT,
    TotalRevenue AS (UnitPrice * Quantity * (1 - Discount)) PERSISTED,

    -- Foreign keys to dimension tables
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
    FOREIGN KEY (ShipperID) REFERENCES Shippers(ShipperID),
    FOREIGN KEY (TerritoryID) REFERENCES Territories(TerritoryID),
    FOREIGN KEY (RegionID) REFERENCES Region(RegionID),

    -- Foreign keys to static rank tables (safe only because static!)
    FOREIGN KEY (CustomerRank) REFERENCES CustomerOrderHistory(CustomerRank),
    FOREIGN KEY (ProductRank) REFERENCES ProductAnalysis(ProductRank),
    FOREIGN KEY (EmployeeRank) REFERENCES EmployeeSalesPerformance(EmployeeRank),
    FOREIGN KEY (CategoryRank) REFERENCES CategorySalesSummary(CategoryRank)
);
