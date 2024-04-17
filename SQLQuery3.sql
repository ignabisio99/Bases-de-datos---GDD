-- Ej 1

SELECT * INTO #clientes
FROM customer

SELECT * FROM #clientes

-- Ej 2

INSERT INTO #clientes (customer_num,fname,lname,company,state,city)
VALUES (144,'Agustin','Creevy','Jaguares SA','CA','Los Angeles')

-- Ej 3

SELECT * INTO #clientesCalifornia
FROM customer
WHERE state = 'CA'

SELECT * FROM #clientesCalifornia

-- Ej 4

INSERT INTO #clientes (customer_num,fname,lname,company,address1,address2,city,state,zipcode,phone,customer_num_referedBy,status)
SELECT 155, fname,lname,company,address1,address2,city,state,zipcode,phone,customer_num_referedBy,status FROM #clientes
WHERE customer_num = 103

SELECT * FROM #clientes

-- Ej 5

DELETE FROM #clientes
WHERE zipcode BETWEEN 94000 AND 94050 AND city LIKE 'M%'

SELECT * FROM #clientes

-- Ej 6

UPDATE #clientes
SET state = 'AK', address2 = 'Barrio Las Heras'
WHERE state = 'CO'


-- Ej 7

SELECT * FROM #clientes

UPDATE #clientes
SET phone ='1' + phone