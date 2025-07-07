# Northwind Data Warehouse Project

A SQL-based mini data warehouse built on Microsoft’s Northwind database.  
This project uses a star schema structure, analytical summary tables, and advanced SQL queries for business reporting.

---

## Features

### 1. Star Schema Design
- Central fact table: **FactSales**
- Dimension tables:
  - `Customers`, `Products`, `Employees`, `Categories`, `Suppliers`, `Shippers`, `Territories`, `Region`
- Analysis tables with rankings:
  - `CustomerOrderHistory`, `ProductAnalysis`, `EmployeeSalesPerformance`, `CategorySalesSummary`

### 2. Analytical Tables
- **CustomerOrderHistory** – Top customers by spending  
- **ProductAnalysis** – Top-selling products by revenue  
- **EmployeeSalesPerformance** – Best performing employees  
- **CategorySalesSummary** – Revenue and sales count by category  

### 3. Advanced Queries
- Trend analysis (YoY comparisons)
- Top employee per city and their best customer
- Top-selling product by city and seller  
_Browse `sql/queries/advancedQueries.sql` for details_

---

##  Setup Instructions

1. **Download Northwind database**  
   Use the official Microsoft backup from:  
   https://northwinddatabase.codeplex.com/

2. **Restore database**  
   ```powershell
   sqlcmd -S localhost -d master -i Northwind.sql
