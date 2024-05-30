-- Ej 1

SELECT customer_num, address1 FROM customer

-- Ej 2

SELECT customer_num, address1 FROM customer
WHERE state = 'CA'

-- Ej 3

SELECT DISTINCT city FROM customer
WHERE state = 'CA'

-- Ej 4

SELECT DISTINCT city FROM customer
WHERE state = 'CA'
ORDER BY city

-- EJ 5

SELECT address1 FROM customer
WHERE customer_num = 103

-- Ej 6

SELECT * FROM products
WHERE manu_code = 'ANZ'
ORDER BY unit_code

-- Ej 7

SELECT DISTINCT manu_code FROM items
ORDER BY manu_code

-- Ej 8

SELECT order_num, order_date, customer_num, ship_date FROM orders
WHERE paid_date IS NULL AND ship_date >= '2015-01-01' AND ship_date < '2015-07-01'

-- Ej 9

SELECT customer_num,company FROM customer
WHERE company LIKE '%town%'

-- Ej 10

SELECT MAX(ship_charge), MIN(ship_charge), AVG(ship_charge) FROM orders

-- Ej 11

SELECT order_num, order_date, ship_date FROM orders
WHERE MONTH(order_date) = MONTH(ship_date) AND YEAR(order_date) = YEAR(ship_date)

-- Ej 12

SELECT customer_num, ship_date, COUNT(ship_date),SUM(ship_charge) FROM orders
GROUP BY customer_num,ship_date
ORDER BY SUM(ship_charge) DESC


-- Ej 13

SELECT ship_date, SUM(ship_weight) FROM orders
GROUP BY ship_date
HAVING SUM(ship_weight) > 30
ORDER BY SUM(ship_weight) DESC

-- Ej 14

SELECT * FROM customer
WHERE state = 'CA'
ORDER BY company 

-- Ej 15

SELECT manu_code, COUNT(DISTINCT item_num) FROM items
GROUP BY manu_code
HAVING SUM(unit_price*quantity) > 1500
ORDER BY COUNT(DISTINCT item_num) DESC

-- Ej 16

SELECT manu_code, stock_num, SUM(quantity), SUM(quantity * unit_price) FROM items
WHERE manu_code LIKE '_R%'
GROUP BY manu_code, stock_num
ORDER BY manu_code, stock_num

-- Ej 17

SELECT customer_num, count(order_num) AS cantCompras, MIN(order_date) AS primeraCompra, 
MAX(order_date) AS ultimaCompra INTO #ordenesTemp
FROM orders
GROUP BY customer_num

SELECT * FROM #ordenesTemp
WHERE primeraCompra < '2015-05-23 00:00:00.000'
ORDER BY ultimaCompra DESC

-- Ej 18

SELECT cantCompras, COUNT(DISTINCT customer_num) AS cantClientes FROM #ordenesTemp
GROUP BY cantCompras
ORDER BY 2 DESC

-- Ej 19

SELECT * from #ordenesTemp
-- SE borra la tabla porque es solo temporal

-- Ej 20

SELECT state, city, COUNT(customer_num) FROM customer
WHERE company LIKE '%ts%' AND zipcode BETWEEN 93000 AND 94100 AND city != 'Mountain View'
GROUP BY state,city
ORDER BY city

-- Ej 21

SELECT state, COUNT(customer_num) FROM customer
WHERE company LIKE '[A-L]%' AND customer_num_referedBy IS NOT NULL
GROUP BY state

-- Ej 22

SELECT state, AVG(lead_time)
FROM manufact
WHERE manu_name LIKE '%e%' AND lead_time BETWEEN 5 AND 20
GROUP BY state

-- Ej 23

SELECT unit, COUNT(unit_descr)+1 FROM units
WHERE unit_descr IS NOT NULL 
GROUP BY unit
HAVING COUNT(unit_descr) > 5
