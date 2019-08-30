-- Products
-- Page 1: Sales overview of all product categories

SELECT ca.CategoryName,
       COUNT(*) AS OrderCount
FROM Orders o
JOIN OrderDetails od ON o.OrderId = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
JOIN Categories ca ON p.CategoryID = ca.CategoryID
GROUP BY ca.CategoryID
ORDER BY OrderCount DESC LIMIT 10;

-- Page 2: Product categories stock levels

SELECT CategoryName,
       CategoryID,
       SUM(UnitsInStock) AS Stock
FROM
  (SELECT *
   FROM Categories c
   JOIN Products p ON c.CategoryID = p.CategoryID)substr
GROUP BY CategoryID
ORDER BY Stock; 

-- Page 3: Top 10 best sell products


SELECT ProductID,
       ProductName,
       SUM(Quantity) AS OrderAmount
FROM
  (SELECT *
   FROM OrderDetails d
   JOIN Products P ON d.ProductID = p.ProductID) Q
JOIN Orders o ON Q.OrderID =O.OrderId
GROUP BY ProductName
ORDER BY OrderAmount DESC LIMIT 10;

 -- Page 4: Product category quaterly sales trend

SELECT ca.CategoryName AS Name,
       STRFTIME('%Y-%m', o.OrderDate) AS OrderMonth,
       SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSales
FROM Categories ca
JOIN Products p ON ca.CategoryID = p.CategoryID
JOIN OrderDetails od ON p.ProductID = od.ProductID
JOIN Orders o ON od.OrderID = o.OrderId
GROUP BY Name,
         OrderMonth
ORDER BY Name,
         OrderMonth;