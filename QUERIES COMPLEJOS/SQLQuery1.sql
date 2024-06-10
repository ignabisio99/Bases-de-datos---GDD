-- EJ 1a

 ALTER VIEW productos_vista(manu_code, manu_name, cant_producto, ult_fecha_orden)
 AS
 SELECT m.manu_code, m.manu_name, COUNT(p.stock_num), MAX(o.order_date) FROM manufact m
 LEFT JOIN products p ON p.manu_code = m.manu_code
 LEFT JOIN items i ON i.manu_code = m.manu_code AND i.stock_num = p.stock_num
 LEFT JOIN orders o ON o.order_num = i.order_num
 GROUP BY m.manu_code, m.manu_name
 HAVING COUNT(DISTINCT p.stock_num) = 0 OR COUNT(DISTINCT p.stock_num) > 2

 -- 1b

 SELECT manu_code, manu_name, cant_producto, 
 CASE 
	WHEN ult_fecha_orden IS NULL THEN 'No posee productos'
	WHEN ult_fecha_orden IS NOT NULL THEN CAST(ult_fecha_orden AS CHAR)
 END
 FROM productos_vista

 -- EJ 2

 SELECT m.manu_code, m.manu_name, COUNT(DISTINCT i.order_num), SUM(i.quantity * i.unit_price) 
 FROM manufact m
 JOIN items i ON i.manu_code = m.manu_code
 JOIN product_types p ON p.stock_num = i.stock_num
 WHERE m.manu_code LIKE '[AN]__' AND (p.description LIKE '%tennis%' OR p.description LIKE '%ball%')
 GROUP BY m.manu_code, m.manu_name
 HAVING  SUM(i.quantity * i.unit_price) > (SELECT SUM(quantity * unit_price)/COUNT(DISTINCT manu_code) FROM items)
 ORDER BY SUM(i.quantity * i.unit_price) DESC

 -- EJ 3

 CREATE VIEW ejercicio33 AS
 SELECT c.customer_num, c.lname, c.company, COUNT(DISTINCT o.order_num) AS CantOrders, MAX(o.order_date) AS FechaMasReciente,
 SUM(i.quantity * i.unit_price) AS Total, (SELECT SUM(quantity * unit_price) FROM items) AS TotalGeneral
 FROM customer c
 LEFT JOIN orders o ON o.customer_num = c.customer_num
 LEFT JOIN items i on i.order_num = o.order_num
 GROUP BY c.customer_num, c.lname, c.company
 HAVING COUNT(DISTINCT o.order_num) = 0 OR (COUNT(DISTINCT o.order_num) >= 3 AND 
 c.customer_num IN (SELECT DISTINCT o2.customer_num FROM orders o2
					JOIN items i2 on i2.order_num = o2.order_num
					GROUP BY o2.customer_num
					HAVING COUNT(DISTINCT i2.manu_code) > 2))
 ORDER BY COUNT(DISTINCT o.order_num) DESC, c.customer_num

 -- EJ 4

 SELECT TOP 5 c.state, p.description FROM customer c
 JOIN orders o ON o.customer_num = c.customer_num
 JOIN items i ON i.order_num = o.order_num
 JOIN product_types p ON p.stock_num = i.stock_num
 GROUP BY c.state, p.description, i.stock_num
 HAVING i.stock_num = (SELECT TOP 1 i1.stock_num FROM product_types t1
						JOIN items i1 ON i1.stock_num = t1.stock_num
						JOIN orders o1 ON o1.order_num = i1.order_num
						JOIN customer c1 ON c1.customer_num = o1.order_num
						WHERE c.state = c1.state
						GROUP BY i1.stock_num, c1.state
						ORDER BY SUM(i1.quantity) DESC)
 ORDER BY SUM(i.quantity) DESC
 
 -- EJ 5

 SELECT c.customer_num, c.fname, c.lname, o.paid_date
 FROM customer c
 LEFT JOIN orders o ON o.customer_num = c.customer_num
 LEFT JOIN items i ON i.order_num = o.order_num
 GROUP BY c.customer_num, c.fname, c.lname, o.paid_date
 ORDER BY SUM(i.quantity * i.unit_price) DESC

 -- EJ 6