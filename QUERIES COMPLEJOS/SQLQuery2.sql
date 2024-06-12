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

-- EJ 6

SELECT c.customer_num, o.order_num FROM customer c
JOIN orders o ON o.customer_num = c.customer_num
WHERE c.state = 'CA'
GROUP BY c.customer_num, o.order_num
HAVING (SELECT COUNT(DISTINCT o1.customer_num) FROM orders o1
		WHERE o1.customer_num = c.customer_num AND YEAR(o1.order_date) = 2015) >= 4

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
