-- EJ 1

SELECT m.manu_code, m.manu_name, m.lead_time, SUM(i.quantity * i.unit_price) AS MontoTotal
FROM manufact m
LEFT JOIN items i ON i.manu_code = m.manu_code
GROUP BY m.manu_code, m.manu_name, m.lead_time
ORDER BY m.manu_code

-- EJ 2

SELECT p1.stock_num, t.description, p1.manu_code, p2.manu_code FROM products p1
LEFT JOIN products p2 ON (p1.stock_num = p2.stock_num  AND p1.manu_code != p2.manu_code)
JOIN product_types t ON t.stock_num = p1.stock_num
WHERE p1.manu_code < p2.manu_code OR p2.manu_code IS NULL

-- EJ 3
-- a

SELECT c.customer_num, c.fname, c.lname FROM customer c
WHERE 1 < (SELECT COUNT(o.customer_num) FROM orders o
			WHERE o.customer_num = c.customer_num)

-- b

SELECT o.customer_num, c.fname, c.lname FROM orders o
JOIN customer c ON c.customer_num = o.customer_num
GROUP BY o.customer_num, c.fname, c.lname
HAVING COUNT(o.customer_num) > 1

-- EJ 4

SELECT i.order_num, SUM(i.quantity * i.unit_price) FROM items i
GROUP BY i.order_num
HAVING SUM(i.quantity * i.unit_price) < (SELECT AVG(i2.quantity * i2.unit_price) 
										FROM items i2)

-- EJ 5

SELECT m.manu_code, m.manu_name, p.stock_num, u.unit_descr, p.unit_price FROM manufact m
JOIN products p ON p.manu_code = m.manu_code
JOIN units u ON u.unit_code = p.unit_code
WHERE p.unit_price > (SELECT AVG(i2.unit_price) FROM items i2
						WHERE i2.manu_code = m.manu_code)

-- EJ 6 

SELECT o.customer_num, c.company, o.order_num, o.order_date FROM orders o
JOIN customer c ON c.customer_num = o.customer_num
JOIN items i ON i.order_num = o.order_num
WHERE NOT EXISTS (SELECT p.stock_num FROM product_types p 
					WHERE p.stock_num = i.stock_num AND p.description = 'baseball gloves')
ORDER BY c.company ASC, o.order_num DESC

-- EJ 7 ESTA MAL

SELECT c.customer_num, c.fname, c.lname FROM customer c
WHERE NOT EXISTS (SELECT o.customer_num FROM orders o
					JOIN items i on i.order_num = o.order_num
					WHERE o.customer_num = c.customer_num AND i.manu_code = 'HSK') 

-- EJ 8


-- EJ 9

SELECT * FROM products
WHERE manu_code = 'HRO' OR stock_num = 1

SELECT * FROM products p 
WHERE p.manu_code = 'HRO' 
UNION
SELECT * FROM products p
WHERE p.stock_num = 1

-- EJ 10


-- EJ 11 MAL

SELECT TOP 2 i1.stock_num ,SUM(i1.quantity) AS Cantidad FROM items i1
WHERE EXISTS (SELECT TOP 2 i11.stock_num ,SUM(i11.quantity) AS Cantidad FROM items i11
						GROUP BY i11.stock_num
						ORDER BY SUM(i11.quantity) DESC)
GROUP BY i1.stock_num
UNION 
SELECT TOP 2 i2.stock_num ,SUM(i2.quantity) AS Cantidad FROM items i2
WHERE EXISTS (SELECT TOP 2 i22.stock_num ,SUM(i22.quantity) AS Cantidad FROM items i22
						GROUP BY i22.stock_num
						ORDER BY SUM(i22.quantity) ASC)
GROUP BY i2.stock_num

-- EJ 12

