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

SELECT m.manu_code, m.manu_name, p.stock_num, pt.description, p.unit_price FROM manufact m
JOIN products p ON p.manu_code = m.manu_code
JOIN product_types pt ON pt.stock_num = p.stock_num
WHERE p.unit_price > (SELECT AVG(p2.unit_price) FROM products p2
						WHERE p2.manu_code = m.manu_code)

-- EJ 6 

SELECT o.customer_num, c.company, o.order_num, o.order_date FROM orders o
JOIN customer c ON c.customer_num = o.customer_num
JOIN items i ON i.order_num = o.order_num
WHERE NOT EXISTS (SELECT p.stock_num FROM product_types p 
					WHERE p.stock_num = i.stock_num AND p.description = '%baseball gloves%')
ORDER BY c.company ASC, o.order_num DESC

-- EJ 7

SELECT c.customer_num, c.fname, c.lname FROM customer c
WHERE c.customer_num NOT IN (SELECT o.customer_num FROM orders o
					JOIN items i on i.order_num = o.order_num
					WHERE i.manu_code = 'HSK') 

-- EJ 8

SELECT c.customer_num, c.fname, c.lname FROM customer c
WHERE c.customer_num IN (SELECT o.customer_num FROM orders o
					JOIN items i on i.order_num = o.order_num
					WHERE i.manu_code = 'HSK'
					GROUP BY o.customer_num
					HAVING COUNT(DISTINCT i.stock_num) = (SELECT COUNT(DISTINCT stock_num)
															FROM items
															WHERE manu_code = 'HSK')) 

-- EJ 9

SELECT * FROM products
WHERE manu_code = 'HRO' OR stock_num = 1

SELECT * FROM products p 
WHERE p.manu_code = 'HRO' 
UNION
SELECT * FROM products p
WHERE p.stock_num = 1

-- EJ 10

SELECT 1 AS ClaveOrd, c.city, c.company FROM customer c
WHERE c.city = 'Redwood City'
UNION 
SELECT 2 AS ClaveOrd, c2.city, c2.company FROM customer c2
WHERE c2.city != 'Redwood City'
ORDER BY 1, 2

-- EJ 11

SELECT i1.stock_num, SUM(i1.quantity) AS Cantidad FROM items i1
GROUP BY i1.stock_num
HAVING i1.stock_num IN (SELECT TOP 2 i11.stock_num FROM items i11
						GROUP BY i11.stock_num
						ORDER BY SUM(i11.quantity) DESC)
UNION
SELECT i1.stock_num, SUM(i1.quantity) AS Cantidad FROM items i1
GROUP BY i1.stock_num
HAVING i1.stock_num IN (SELECT TOP 2 i11.stock_num FROM items i11
						GROUP BY i11.stock_num
						ORDER BY SUM(i11.quantity) ASC)
ORDER BY 2 DESC
-- EJ 12

CREATE VIEW ClientesConMultiplesOrdenes 
(numero_de_cliente, nombre, apellido)
AS
SELECT c.customer_num, c.fname, c.lname FROM customer c
WHERE 1 < (SELECT COUNT(o.customer_num) FROM orders o
			WHERE o.customer_num = c.customer_num)

SELECT * FROM ClientesConMultiplesOrdenes

-- EJ 13

CREATE VIEW Productos_HRO
(stock_num, manu_code, unit_price, unit_code, status)
AS
SELECT * FROM products
WHERE manu_code = 'HRO'
WITH CHECK OPTION

INSERT INTO Productos_HRO(stock_num, manu_code, unit_price, unit_code,status)
VALUES (303,'ANZ',1,1,NULL)

INSERT INTO Productos_HRO(stock_num, manu_code, unit_price, unit_code,status)
VALUES (303,'HRO',1,1,NULL)

SELECT * FROM Productos_HRO

-- EJ 14

BEGIN TRANSACTION 

	INSERT INTO customer(customer_num,fname, lname) VALUES (24912,'Fred', 'Filstone')

	SELECT * FROM customer c
	WHERE c.fname = 'Fred'

ROLLBACK TRANSACTION

-- EJ 15

BEGIN TRANSACTION

	INSERT INTO manufact(manu_code,manu_name,lead_time) VALUES ('AZZ','AZZIO SA',5)

	INSERT INTO products(stock_num, manu_code, unit_price, unit_code)
	SELECT p.stock_num, 'AZZ', p.unit_price, p.unit_code FROM products p
	JOIN product_types t ON t.stock_num = p.stock_num
	WHERE p.manu_code = 'ANZ' AND t.description LIKE '%tennis%'

COMMIT
