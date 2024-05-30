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
WHERE MONTH(order_date) = MONTH(ship_date)

-- Ej 12 DUDOSO

SELECT COUNT(ship_date),SUM(ship_charge) FROM orders
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

SELECT COUNT(DISTINCT item_num) FROM items
GROUP BY manu_code
HAVING SUM(unit_price) > 1500
ORDER BY COUNT(DISTINCT item_num) DESC

-- Ej 16

SELECT manu_code, item_num, quantity, quantity * unit_price FROM items
WHERE manu_code LIKE '_R%'
ORDER BY manu_code, item_num

-- Ej 20

SELECT COUNT(customer_num) FROM customer
WHERE company LIKE '%ts%' AND zipcode BETWEEN 93000 AND 94100 AND city != 'Mountain View'
GROUP BY state,city
ORDER BY city

-- Ej 21

SELECT COUNT(customer_num) FROM customer
WHERE company LIKE '[A-L]%'
GROUP BY state

-- Ej 22

SELECT AVG(lead_time) FROM manufact
WHERE manu_name LIKE '%e%'
GROUP BY state
HAVING AVG(lead_time) BETWEEN 5 AND 20

-- Ej 23

SELECT COUNT(unit_descr)+1 FROM units
WHERE unit_descr IS NOT NULL 
GROUP BY unit
HAVING COUNT(unit_descr) > 5
