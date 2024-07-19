-- EJ 1

SELECT o.customer_num, c.company, o.order_num FROM orders o
JOIN customer c ON c.customer_num = o.customer_num
ORDER BY o.customer_num

-- EJ 2

SELECT i.order_num, i.item_num, t.description, i.manu_code, i.quantity, (i.quantity * i.unit_price) as PrecioTotal
FROM items i
JOIN product_types t ON t.stock_num = i.stock_num
WHERE i.order_num = 1004

-- EJ 3

SELECT i.order_num, i.item_num, t.description, i.manu_code, i.quantity, (i.quantity * i.unit_price) as PrecioTotal, m.manu_name
FROM items i
JOIN product_types t ON t.stock_num = i.stock_num
JOIN manufact m ON m.manu_code =i.manu_code
WHERE i.order_num = 1004

-- EJ 4

SELECT o.order_num, o.customer_num, c.fname, c.lname, c.company FROM orders o
JOIN customer c ON c.customer_num = o.customer_num

-- EJ 5

SELECT DISTINCT (o.customer_num), c.fname, c.lname, c.company FROM orders o
JOIN customer c ON c.customer_num = o.customer_num

-- EJ 6

SELECT m.manu_name, p.stock_num, t.description, u.unit, p.unit_price, (p.unit_price *1.2) as PrecioJunio 
FROM manufact m
JOIN products p ON p.manu_code = m.manu_code
JOIN product_types t ON t.stock_num = p.stock_num
JOIN units u ON u.unit_code = p.unit_code

-- EJ 7

SELECT i.item_num, pt.description, i.quantity, i.quantity * i.unit_price AS PrecioTotal
FROM items i
JOIN product_types pt ON i.stock_num = pt.stock_num
WHERE i.order_num = 1004;

-- EJ 8

SELECT m.manu_name, m.lead_time FROM orders o
JOIN items i on i.order_num = o.order_num
JOIN manufact m on m.manu_code = i.manu_code
WHERE i.order_num = 104

-- EJ 9

SELECT o.order_num, o.order_date, i.item_num, t.description, i.quantity, i.quantity * i.unit_price AS PrecioTotal 
FROM orders o
JOIN items i on i.order_num = o.order_num
JOIN product_types t on t.stock_num = i.stock_num

-- EJ 10

SELECT lname + ', ' + fname, '(' + SUBSTRING(phone,1,3) + ') ' + SUBSTRING(phone,5,12) FROM customer
ORDER BY 1

-- EJ 11

SELECT o.ship_date, c.lname + ', ' + c.fname, COUNT(o.order_num) FROM orders o
JOIN customer c ON o.customer_num = c.customer_num
JOIN state s ON s.state = c.state
WHERE s.sname = 'California' AND c.zipcode BETWEEN 94000 AND 94100
GROUP BY o.ship_date, c.lname + ', ' + c.fname
ORDER BY 1,2

-- EJ 12

SELECT m.manu_name, t.description, sum(i.quantity), sum(i.unit_price * i.quantity) AS MontoTotal FROM items i
JOIN manufact m ON m.manu_code = i.manu_code
JOIN product_types t ON t.stock_num = i.stock_num
JOIN orders o ON o.order_num = i.order_num
WHERE MONTH(o.order_date) BETWEEN 5 AND 6 AND m.manu_code IN ('ANZ', 'HRO', 'HSK', 'SMT')
GROUP BY m.manu_name, t.description
ORDER BY sum(i.unit_price * i.quantity) DESC

-- EJ 13

SELECT CAST(YEAR(order_date) AS VARCHAR)+'/'+CAST(MONTH(order_date) AS VARCHAR) AnioMes,
SUM(quantity) AS Cantidad, SUM(unit_price*quantity) AS Total
FROM orders O 
JOIN items i ON (o.order_num=i.order_num)
GROUP BY CAST(YEAR(order_date) AS VARCHAR)+'/'+CAST(MONTH(order_date) AS VARCHAR)
ORDER BY 3 DESC
