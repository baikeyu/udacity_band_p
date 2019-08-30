-- Customers
-- Page 1: Customers from which countries
SELECT Country, COUNT(*) AS Amount
  FROM Customers
  GROUP BY 1
  ORDER BY 2 DESC;

-- Page 2: product categories procurement from top 10 customers
WITH TopCustomers AS (
SELECT CustomerID
FROM (SELECT c.CustomerID, SUM(d.UnitPrice * d.Quantity * (1 - d.Discount)) AS TOTAL_COST
		FROM Customers c
		JOIN Orders o
		ON c.CustomerID = o.CustomerID
		JOIN OrderDetails d
		ON o.OrderId = d.OrderID
		GROUP BY c.CustomerID
		ORDER BY TOTAL_COST
		DESC
		LIMIT 10) sub)

SELECT CompanyName, CategoryName, SUM(d.UnitPrice * d.Quantity * (1 - d.Discount)) AS TotalCost
FROM Customers c
JOIN Orders o
ON c.CustomerID = o.CustomerID
JOIN OrderDetails d
ON o.OrderId = d.OrderID
JOIN Products p
ON d.ProductID = p.ProductID
JOIN Categories cs
ON p.CategoryID = cs.CategoryID
JOIN TopCustomers t1
ON c.CustomerID = t1.CustomerID
GROUP BY CompanyName, CategoryName
ORDER BY CompanyName, TotalCost
DESC;

-- Page 3: top 10 suppliers and total order amount
SELECT s.CompanyName, SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalCost
FROM Suppliers s
JOIN Products p
ON s.SupplierID = p.SupplierID
JOIN OrderDetails od
ON od.ProductID = p.ProductID
GROUP BY s.CompanyName
ORDER BY TotalCost
DESC
LIMIT 10;

-- Page 4: top 10 suppliers product categories and order amount
WITH TopSuppliers AS (SELECT SupplierID FROM (SELECT s.SupplierID, SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalCost
FROM Suppliers s
JOIN Products p
ON s.SupplierID = p.SupplierID
JOIN OrderDetails od
ON od.ProductID = p.ProductID
GROUP BY s.CompanyName
ORDER BY TotalCost
DESC
LIMIT 10) sub)

SELECT s.CompanyName, ct.CategoryName, SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalCost
FROM Suppliers s
JOIN Products p
ON s.SupplierID = p.SupplierID
JOIN OrderDetails od
ON od.ProductID = p.ProductID
JOIN Orders o
ON o.OrderId = od.OrderID
JOIN Categories ct
ON ct.CategoryID = p.CategoryID
JOIN TopSuppliers ts
ON ts.SupplierID = s.SupplierID
GROUP BY CompanyName, CategoryName
ORDER BY CompanyName, TotalCost
DESC;

-- Page 5: products sales trend
SELECT ca.CategoryName, STRFTIME('%m/%Y', o.OrderDate) AS OrderMonth, SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSales
  FROM Categories ca
  JOIN Products p
  ON ca.CategoryID = p.CategoryID
  JOIN OrderDetails od
  ON p.ProductID = od.ProductID
  JOIN Orders o
  ON od.OrderID = o.OrderId
  GROUP BY 1, 2
  ORDER BY 1, 2

-- Page 6: best sales employee
SELECT e.EmployeeID, PRINTF('%s %s', FirstName, LastName) AS Name, Country, t1.TotalSales
FROM Employees e
JOIN
(SELECT EmployeeID, TotalSales FROM (SELECT e.EmployeeID, SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSales
FROM Employees e
JOIN Orders o
ON o.EmployeeID = e.EmployeeID
JOIN OrderDetails od
ON od.OrderID = o.OrderId
GROUP BY 1
ORDER BY 2
DESC
LIMIT 1)) AS t1
ON
e.EmployeeID = t1.EmployeeID

-- Page 7: product categories from best sales employee
SELECT c.CategoryName, COUNT(*) AS ProductNum
FROM Categories c
JOIN Products p
ON c.CategoryID = p.CategoryID
JOIN OrderDetails od
ON od.ProductID = p.ProductID
JOIN Orders o
ON o.OrderId = od.OrderID
WHERE o.EmployeeID = (SELECT EmployeeID FROM (SELECT e.EmployeeID, SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSales
FROM Employees e
JOIN Orders o
ON o.EmployeeID = e.EmployeeID
JOIN OrderDetails od
ON od.OrderID = o.OrderId
GROUP BY 1
ORDER BY 2
DESC
LIMIT 1) t1)
GROUP BY 1
ORDER BY 2
DESC
