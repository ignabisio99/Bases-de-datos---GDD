-- EJ 1

SELECT c.customer_num, c.fname, c.lname, c.state, COUNT(DISTINCT o.order_num) CantOrdenes,
SUM(i.quantity * i.unit_price) MontoTotal
FROM customer c
JOIN orders o ON o.customer_num = c.customer_num
JOIN items i ON i.order_num = o.order_num
WHERE c.state != 'FL' AND YEAR(o.order_date) = 2015
GROUP BY c.customer_num, c.fname, c.lname, c.state
HAVING SUM(i.quantity * i.unit_price) > (SELECT SUM(i.quantity * i.unit_price) / COUNT(DISTINCT o2.customer_num) FROM customer c2
										JOIN orders o2 ON o2.customer_num = c2.customer_num
										JOIN items i2 ON i2.order_num = o2.order_num
										WHERE c2.state != 'FL')
ORDER BY 6 DESC

-- EJ 2

SELECT c.customer_num, c.fname, c.lname, SUM(i.quantity * i.unit_price) MontoTotal,
c2.customer_num, c2.fname, c2.lname, c2.MontoReferido
FROM customer c
JOIN orders o ON o.customer_num = c.customer_num
JOIN items i ON i.order_num = o.order_num
LEFT JOIN (SELECT c2.customer_num, c2.fname, c2.lname, SUM(i2.quantity * i2.unit_price) MontoReferido FROM customer c2
			JOIN orders o2 ON o2.customer_num = c2.customer_num
			JOIN items i2 ON i2.order_num = o2.order_num
			WHERE YEAR(o2.order_date) = 2015
			GROUP BY c2.customer_num, c2.fname, c2.lname) c2 ON c2.customer_num = c.customer_num_referedBy
WHERE YEAR(o.order_date) = 2015
GROUP BY c.customer_num, c.fname, c.lname,c2.customer_num, c2.fname, c2.lname, c2.MontoReferido
HAVING SUM(i.quantity * i.unit_price) > COALESCE(c2.MontoReferido, 0)
