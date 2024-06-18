-- EJ 1

SELECT c.customer_num, c.fname, c.lname, SUM(i.quantity * i.unit_price) AS TotalDelCliente,
COUNT(DISTINCT o.order_num) AS OrdenesDelCliente, (SELECT COUNT(DISTINCT order_num) FROM orders) AS OrdenesTotales
FROM customer c
JOIN orders o ON o.customer_num = c.customer_num
JOIN items i ON i.order_num = o.order_num
WHERE c.zipcode LIKE '94%'
GROUP BY c.customer_num, c.fname, c.lname
HAVING COUNT(DISTINCT o.order_num) >= 2 AND  
(SELECT SUM(i3.quantity * i3.unit_price) / COUNT(DISTINCT i3.order_num) FROM items i3
JOIN orders o3 ON o3.order_num = i3.order_num WHERE o3.customer_num = c.customer_num) -- Promedio de compra del cliente
> (SELECT SUM(i2.quantity * i2.unit_price) / COUNT(DISTINCT i2.order_num) FROM items i2) -- Prodmedio de compra general

-- EJ 2

SELECT i.stock_num, i.manu_code, pt.description, m.manu_name,  
SUM(i.unit_price * i.quantity) as total_producto, SUM(i.quantity) as Unidades
INTO #ABC_Productos
FROM items i
JOIN product_types pt ON i.stock_num = pt.stock_num
JOIN manufact m on i.manu_code = m.manu_code
WHERE m.manu_code IN (SELECT manu_code FROM products 
					  GROUP BY manu_code 
					  HAVING COUNT(stock_num) >=10)
GROUP BY i.stock_num, i.manu_code, pt.description, m.manu_name
ORDER BY SUM(i.unit_price * i.quantity)

-- EJ 3

SELECT tp.stock_num, tp.description, MONTH(o.order_date) as Mes, c.lname + ', ' + c.fname,
	COUNT(DISTINCT o.order_num) as Ordenes_por_mes,
	SUM(i.quantity) as unid_producto,
	SUM(i.quantity * i.unit_price) as total
FROM #ABC_Productos tp
JOIN items i ON i.stock_num = tp.stock_num AND i.manu_code = tp.manu_code
JOIN orders o ON i.order_num = o.order_num
JOIN customer c ON o.customer_num = c.customer_num
WHERE c.state = (SELECT top 1 state FROM customer 
				GROUP BY state 
				ORDER BY COUNT(customer_num) DESC)
GROUP BY tp.stock_num, tp.description,  MONTH(o.order_date), c.lname + ', ' + c.fname
ORDER BY Mes, tp.description, unid_producto DESC

-- EJ 4

SELECT DISTINCT i1.stock_num, i1.manu_code, c1.customer_num, c1.lname, c2.customer_num, c2.lname FROM orders o1
JOIN items i1 ON i1.order_num = o1.order_num
JOIN customer c1 ON c1.customer_num = o1.customer_num
JOIN items i2 ON i2.stock_num = i1.stock_num AND i2.manu_code = i1.manu_code
JOIN orders o2 ON o2.order_num = i1.order_num
JOIN customer c2 ON c2.customer_num = o2.customer_num
WHERE i1.stock_num IN (5,6,9) AND i1.manu_code = 'ANZ'
AND (SELECT SUM(i11.quantity) FROM items i11
	JOIN orders o11 ON o11.order_num = i11.order_num
	WHERE i11.stock_num = i1.stock_num AND i11.manu_code = i1.manu_code 
	AND o11.customer_num = c1.customer_num) > (SELECT SUM(i22.quantity) FROM items i22
												JOIN orders o22 ON o22.order_num = i22.order_num
												WHERE i22.stock_num = i2.stock_num AND i22.manu_code = i2.manu_code AND
												o22.customer_num = c2.customer_num)
ORDER BY 1,2

-- EJ 5

SELECT TOP 1 (SELECT TOP 1 COUNT(DISTINCT o.order_num) FROM orders o
		GROUP BY o.customer_num
		ORDER BY 1 DESC) MayorCantOrdenes,
		(SELECT TOP 1 SUM(i.quantity * i.unit_price) FROM orders o
		JOIN items i ON i.order_num = o.order_num
		GROUP BY o.customer_num
		ORDER BY 1 DESC) MayorMontoSolicitado,
		(SELECT TOP 1 SUM(i.quantity) FROM orders o 
		JOIN items i ON i.order_num = o.order_num
		GROUP BY o.customer_num
		ORDER BY 1 DESC) MayorCantItemsSolicitado,
		(SELECT TOP 1 COUNT(DISTINCT o.order_num) FROM orders o
		GROUP BY o.customer_num
		ORDER BY 1) MenorCantOrdenes,
		(SELECT TOP 1 SUM(i.quantity * i.unit_price) FROM orders o
		JOIN items i ON i.order_num = o.order_num
		GROUP BY o.customer_num
		ORDER BY 1) MenorMontoSolicitado,
		(SELECT TOP 1 SUM(i.quantity) FROM orders o 
		JOIN items i ON i.order_num = o.order_num
		GROUP BY o.customer_num
		ORDER BY 1) MenorCantItemsSolicitado
FROM orders

-- EJ 6

SELECT o.customer_num, o.order_num, SUM(i.quantity * i.unit_price) MontoOrdenTotal 
FROM orders o
JOIN customer c ON c.customer_num = o.customer_num
JOIN items i ON i.order_num = o.order_num
WHERE c.state = 'CA'
GROUP BY o.customer_num, o.order_num
HAVING o.customer_num IN (SELECT o1.customer_num FROM orders o1
						  WHERE YEAR(o1.order_date) = 2015
						  GROUP BY o1.customer_num
						  HAVING COUNT(DISTINCT o1.order_num) >= 4)
AND o.order_num IN (SELECT o2.order_num FROM orders o2
					JOIN items i2 ON i2.order_num = o2.order_num
					GROUP BY o2.order_num
					HAVING COUNT(i2.item_num) > (SELECT TOP 1 COUNT(i3.item_num) FROM orders o3
												JOIN items i3 ON i3.order_num = o3.order_num
												JOIN customer c3 ON c3.customer_num = o3.customer_num
												WHERE c3.state = 'AZ' AND YEAR(o3.order_date) = 2015
												GROUP BY o3.order_num
												ORDER BY 1 DESC)) 

-- EJ 7

SELECT TOP 1 s.state, s.sname, c.lname + ', ' + c.fname Cliente1, c1.lname + ', ' + c1.fname Cliente2, 
SUM(i1.quantity * i1.unit_price) + SUM(i2.quantity * i2.unit_price) TotalSolicitado
FROM state s
JOIN customer c ON c.state = s.state
JOIN customer c1 ON c1.state = s.state AND c1.customer_num != c.customer_num
JOIN orders o1 ON o1.customer_num = c.customer_num
JOIN orders o2 ON o2.customer_num = c1.customer_num
JOIN items i1 ON i1.order_num = o1.order_num
JOIN items i2 ON i2.order_num = o2.order_num
WHERE c.state = 'CA'
GROUP BY s.state, s.sname, c.lname, c.fname, c1.lname, c1.fname
ORDER BY SUM(i1.quantity * i1.unit_price) + SUM(i2.quantity * i2.unit_price) DESC

-- EJ 8

SELECT o.order_num, o.customer_num, o.order_date, 
CASE
	WHEN c.status = 'P' THEN NULL
	ELSE o.order_date + 1 + m.lead_time
END AS FechaModificada
FROM orders o
JOIN items i ON i.order_num = o.order_num
JOIN manufact m ON i.manu_code = m.manu_code
JOIN customer c ON c.customer_num = o.customer_num
ORDER BY 4

-- EJ 9

SELECT c.customer_num, c.fname, c.lname, c.state, COUNT(DISTINCT o.order_num) Cant_Ordenes,
SUM(i.quantity * i.unit_price) Monto_Total
FROM customer c
JOIN orders o ON o.customer_num = c.customer_num
JOIN items i ON i.order_num = o.order_num
WHERE c.state != 'WI'
GROUP BY c.customer_num, c.fname, c.lname, c.state
HAVING SUM(i.quantity * i.unit_price) > 
(SELECT SUM(i2.quantity * i2.unit_price) / COUNT(DISTINCT i2.order_num) FROM items i2) -- Monto Total Promedio
