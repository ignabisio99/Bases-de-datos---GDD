-- Ejercicio 1

SELECT clie_codigo, clie_razon_social FROM Cliente
WHERE clie_limite_credito >= 1000
ORDER BY clie_codigo

-- Ejercicio 2

SELECT prod_codigo, prod_detalle FROM Producto
JOIN Item_Factura on item_producto = prod_codigo
JOIN Factura on fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
WHERE year(fact_fecha) = 2012
GROUP BY prod_codigo, prod_detalle
ORDER BY sum(item_cantidad)

-- Ejercicio 3


SELECT prod_codigo, prod_detalle, SUM(stoc_cantidad) FROM Producto
JOIN STOCK on stoc_producto = prod_codigo
GROUP BY prod_codigo, prod_detalle
ORDER BY prod_detalle


-- Ejercicio 4

SELECT prod_codigo, prod_detalle, COUNT(comp_componente) FROM Producto
LEFT JOIN Composicion ON prod_codigo = comp_producto 
WHERE prod_codigo IN (SELECT stoc_producto FROM STOCK
						GROUP BY stoc_producto
						HAVING AVG(stoc_cantidad) > 100)
GROUP BY prod_codigo,prod_detalle


-- Ejercicio 5

SELECT prod_codigo, prod_detalle, SUM(item_cantidad) FROM Producto
JOIN Item_Factura on prod_codigo = item_producto 
JOIN Factura on fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
WHERE YEAR(fact_fecha) = 2012
GROUP BY prod_codigo, prod_detalle
HAVING SUM(item_cantidad) > (SELECT SUM(item_cantidad) FROM Item_Factura
							JOIN Factura on fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
							WHERE YEAR(fact_fecha) = 2011 and item_producto = prod_codigo)


-- Ejercicio 6

SELECT rubr_id, rubr_detalle, COUNT (prod_rubro) FROM Rubro
JOIN Producto ON prod_rubro = rubr_id
WHERE prod_codigo in (SELECT stoc_producto FROM STOCK GROUP BY stoc_producto HAVING
					SUM(stoc_cantidad) > (SELECT stoc_cantidad FROM STOCK
					WHERE stoc_producto = '00000000' AND stoc_deposito = '00'))
GROUP BY rubr_id, rubr_detalle


-- Ejercicio 7

SELECT p.prod_codigo, p.prod_detalle, MAX (i.item_precio) as Mayor, MIN(i.item_precio) AS Menor,
CAST(((MAX(i.item_precio)-MIN(i.item_precio)) *100 / MIN(i.item_precio) ) AS DECIMAL(10,2)) AS DifPrecios
FROM Producto p
JOIN Item_Factura i on i.item_producto = p.prod_codigo
WHERE p.prod_codigo IN (SELECT stoc_producto FROM STOCK
						GROUP BY stoc_producto
						HAVING SUM(stoc_cantidad) > 0)
GROUP BY p.prod_codigo, p.prod_detalle

-- EJERCICIO 8

SELECT p.prod_detalle, MAX(stoc_cantidad)
FROM Producto p
JOIN STOCK S on s.stoc_producto = p.prod_codigo
GROUP BY P.prod_detalle
HAVING COUNT(DISTINCT s.stoc_deposito) = (SELECT COUNT (depo_codigo)FROM DEPOSITO)

-- Ejercicio 9

SELECT e.empl_jefe, e.empl_codigo, e.empl_nombre,
(SELECT COUNT (depo_codigo) FROM DEPOSITO
WHERE depo_encargado = e.empl_codigo) AS CantEmpl,
(SELECT COUNT (depo_codigo) FROM DEPOSITO
WHERE depo_encargado = e.empl_jefe) AS CantJefe
FROM Empleado e
GROUP BY e.empl_codigo, e.empl_jefe, e.empl_nombre


-- Ejercico 10

SELECT p.prod_detalle,(SELECT TOP 1 fact_cliente FROM Factura
						JOIN Item_Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
						WHERE item_producto = p.prod_codigo
						GROUP BY fact_cliente
						ORDER BY SUM(item_cantidad) DESC)
FROM Producto p
WHERE p.prod_codigo IN (SELECT TOP 10 item_producto FROM Item_Factura
						GROUP BY item_producto
						ORDER BY SUM(item_cantidad) DESC)
OR
p.prod_codigo IN (SELECT TOP 10 item_producto FROM Item_Factura
						GROUP BY item_producto
						ORDER BY SUM(item_cantidad) ASC)

-- Ejercicio 11

SELECT f.fami_detalle, COUNT(DISTINCT i.item_producto) AS DifProductos,
SUM(fa.fact_total) - SUM(fa.fact_total_impuestos) AS TotalSinImpuestos
FROM Familia f
JOIN Producto p on p.prod_familia = f.fami_id
JOIN Item_Factura i on i.item_producto = p.prod_codigo
JOIN Factura fa on fa.fact_tipo+fa.fact_sucursal+fa.fact_numero = i.item_tipo+i.item_sucursal+i.item_numero
GROUP BY f.fami_detalle,f.fami_id
HAVING (SELECT SUM(item_cantidad * item_precio)
		FROM Producto
		JOIN Item_Factura ON prod_codigo = item_producto
		JOIN Factura ON item_numero + item_tipo + item_sucursal =
		fact_numero + fact_tipo + fact_sucursal
		WHERE YEAR(fact_fecha) = 2012 
		AND prod_familia = f.fami_id) > 20000
ORDER BY COUNT(DISTINCT i.item_producto) DESC

-- Ejercicio 12 

SELECT p.prod_detalle, COUNT(DISTINCT f.fact_cliente) as CantClientesDist, AVG(i.item_precio*i.item_cantidad) as ImporteProm,
(SELECT COUNT(stoc_cantidad) FROM STOCK WHERE stoc_producto = p.prod_codigo AND stoc_cantidad > 0) AS CantDepoConStock,
(SELECT SUM(stoc_cantidad) FROM STOCK WHERE stoc_producto = p.prod_codigo) AS CantStockActual
FROM Producto p
JOIN Item_Factura i on i.item_producto = p.prod_codigo
JOIN Factura f on f.fact_tipo+f.fact_sucursal+f.fact_numero = i.item_tipo+i.item_sucursal+i.item_numero
WHERE p.prod_codigo in (SELECT i.item_producto FROM Item_Factura
						JOIN Factura on fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
						 WHERE YEAR(fact_fecha) = 2012)
GROUP BY p.prod_detalle, p.prod_codigo
ORDER BY AVG(i.item_precio*i.item_cantidad) DESC

-- Ejercicio 13

SELECT p.prod_detalle, p.prod_precio, SUM(c.comp_cantidad * p2.prod_precio) AS PrecioSumatoria
FROM Producto p
JOIN Composicion c on c.comp_producto = p.prod_codigo
JOIN Producto p2 on p2.prod_codigo = c.comp_componente
GROUP BY p.prod_detalle, p.prod_precio
HAVING COUNT(DISTINCT c.comp_componente) > 2
ORDER BY COUNT(DISTINCT c.comp_componente) DESC

-- Ejercicio 14

SELECT c.clie_codigo, COUNT(f.fact_cliente) AS CantCompras, AVG(f.fact_total) AS PromedioPorCompra,
COUNT(DISTINCT i.item_producto) AS CantProdDif, MAX(f.fact_total) AS MayorMonto
FROM Cliente c
JOIN Factura f on f.fact_cliente = c.clie_codigo
JOIN Item_Factura i on i.item_tipo+i.item_sucursal+i.item_numero = f.fact_tipo+f.fact_sucursal+f.fact_numero
WHERE YEAR(f.fact_fecha) = YEAR(GETDATE()) - 1
GROUP BY c.clie_codigo
ORDER BY COUNT(f.fact_cliente)

-- Ejercicio 15

SELECT i.item_producto as cod1,
 p.prod_detalle as detalle1,
 i2.item_producto as cod2,
 p2.prod_detalle as detalle2,
 count(1) as veces
 FROM Item_Factura i 
  join Factura f on i.item_numero = f.fact_numero and i.item_tipo = f.fact_tipo  
   and f.fact_sucursal  = i.item_sucursal
  join Item_Factura i2 on i.item_tipo = i2.item_tipo  
   and i.item_sucursal = i2.item_sucursal and i.item_numero = i2.item_numero 
   and i.item_producto > i2.item_producto 
  join Producto p on i.item_producto  = p.prod_codigo 
  join Producto p2 on i2.item_producto = p2.prod_codigo 
 group by i.item_producto, i2.item_producto, p.prod_detalle, p2.prod_detalle 
 having  count (1) > 500

-- Ejercicio 16 Revisar Promedio

SELECT c.clie_razon_social,
	  SUM(item_cantidad) AS CantProductos,
	  (SELECT TOP 1 item_producto FROM Factura
	  JOIN Item_Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
	  WHERE fact_cliente = c.clie_codigo AND YEAR(fact_fecha) = 2012
	  GROUP BY item_producto
	  ORDER BY SUM(item_cantidad) DESC, item_producto ASC) AS CodProdMasVend
FROM Cliente c
JOIN Factura ON fact_cliente = c.clie_codigo
JOIN Item_Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
WHERE YEAR(fact_fecha) = 2012
GROUP BY c.clie_razon_social, c.clie_codigo
HAVING SUM(item_cantidad) < (SELECT TOP 1 SUM(item_cantidad) FROM Factura
							JOIN Item_Factura ON item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
							WHERE YEAR(fact_fecha) = 2012
							GROUP BY item_producto
							ORDER BY SUM(item_cantidad) DESC) * 1/3

-- Ejercicio 17

SELECT 
		FORMAT(f.fact_fecha,'yyyy/MM') AS Periodo,
		p.prod_codigo, 
		p.prod_detalle,
		SUM(ISNULL(i.item_cantidad,0)) AS CantVendida,
		(SELECT ISNULL(SUM(ISNULL(item_cantidad,0)),0) FROM Item_Factura
		JOIN Factura ON fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
		WHERE item_producto = p.prod_codigo AND 
		YEAR(fact_fecha) = YEAR(f.fact_fecha) -1 AND MONTH(fact_fecha) = MONTH(f.fact_fecha) - 1) AS VentaAñoAnt,
		COUNT(*) AS	CantFacturas 
FROM Producto p
JOIN Item_Factura i ON i.item_producto = p.prod_codigo
JOIN Factura f ON f.fact_tipo+f.fact_sucursal+f.fact_numero = i.item_tipo+i.item_sucursal+i.item_numero
GROUP BY f.fact_fecha,p.prod_codigo, p.prod_detalle
ORDER BY f.fact_fecha, p.prod_codigo


-- Ejercicio 18 (Revisar el segundo mejor)

SELECT r.rubr_detalle,
	   ISNULL(SUM(i.item_cantidad * i.item_precio),0) AS Ventas,
	   ISNULL((SELECT TOP 1 item_producto FROM Item_Factura
	   JOIN Producto on prod_codigo = item_producto
	   WHERE prod_rubro = r.rubr_id
	   GROUP BY item_producto
	   ORDER BY SUM(item_cantidad) DESC),0) AS Prod1,
	   ISNULL((SELECT TOP 1 item_producto FROM Item_Factura
	   JOIN Producto on prod_codigo = item_producto
	   WHERE prod_rubro = r.rubr_id AND 
	   prod_codigo != ((SELECT TOP 1 item_producto FROM Item_Factura
	   JOIN Producto on prod_codigo = item_producto
	   WHERE prod_rubro = r.rubr_id
	   GROUP BY item_producto
	   ORDER BY SUM(item_cantidad) DESC))
	   GROUP BY item_producto
	   ORDER BY SUM(item_cantidad) DESC),0) AS Prod2,
	   ISNULL((SELECT TOP 1 fact_cliente FROM Factura
				JOIN Item_Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
				JOIN Producto on prod_codigo = item_producto
				WHERE prod_rubro = r.rubr_id AND (MONTH(GETDATE()) - MONTH(fact_fecha) = 1) 
				GROUP BY fact_cliente
				ORDER BY SUM(item_cantidad) DESC),0) AS Cliente
FROM Rubro r
JOIN Producto p ON p.prod_rubro = r.rubr_id
JOIN Item_Factura i ON i.item_producto = p.prod_codigo
GROUP BY r.rubr_detalle, r.rubr_id
ORDER BY COUNT(DISTINCT i.item_producto) DESC


-- Ejercicio 19 INCOMPLETO (revisar cant caracteres)

SELECT p.prod_codigo,
	   p.prod_detalle,
	   p.prod_familia,
	   f.fami_detalle,
	   (SELECT TOP 1 prod_familia FROM Producto) AS FamSug
FROM Producto p
JOIN Familia f ON f.fami_id = p.prod_familia
GROUP BY p.prod_codigo,p.prod_detalle, p.prod_familia,f.fami_detalle
ORDER BY prod_detalle

-- Ejercicio 20

SELECT TOP 3 e.empl_codigo,
		e.empl_nombre,
		e.empl_apellido,
		YEAR(e.empl_ingreso),
		CASE 
			WHEN (SELECT COUNT(*) FROM Factura WHERE fact_vendedor = e.empl_codigo AND
					YEAR(fact_fecha) = 2011) >= 50
				THEN(SELECT COUNT(*) FROM Factura
				WHERE fact_vendedor = e.empl_codigo AND
				YEAR(fact_fecha)  = 2011 AND fact_total > 100)
			ELSE(SELECT COUNT(*) FROM Factura WHERE
					fact_vendedor IN (SELECT empl_codigo FROM Empleado WHERE empl_jefe = e.empl_codigo) AND YEAR(fact_fecha)  = 2011)
			END 'Puntaje 2011',
		CASE 
			WHEN (SELECT COUNT(*) FROM Factura WHERE fact_vendedor = e.empl_codigo AND
					YEAR(fact_fecha) = 2012) >= 50
				THEN(SELECT COUNT(*) FROM Factura
				WHERE fact_vendedor = e.empl_codigo AND
				YEAR(fact_fecha)  = 2012 AND fact_total > 100)
			ELSE(SELECT COUNT(*) FROM Factura WHERE
					fact_vendedor IN (SELECT empl_codigo FROM Empleado WHERE empl_jefe = e.empl_codigo) AND YEAR(fact_fecha)  = 2012)
			END 'Puntaje 2012'
FROM Empleado e
GROUP BY e.empl_codigo, e.empl_nombre, e.empl_apellido, YEAR(e.empl_ingreso)



-- Ejercicio 21

SELECT YEAR(f.fact_fecha),
		(SELECT COUNT(DISTINCT fact_cliente) FROM Factura
		WHERE fact_tipo+fact_sucursal+fact_numero IN 
			(SELECT item_tipo+item_sucursal+item_numero FROM Item_Factura
			GROUP BY item_tipo+item_sucursal+item_numero
			HAVING SUM(item_cantidad * item_precio) <> 
					(SELECT (f2.fact_total - f2.fact_total_impuestos) FROM Factura f2
					WHERE f2.fact_tipo+f2.fact_sucursal+f2.fact_numero = item_tipo+item_sucursal+item_numero ) )  ) AS CantClientes,
		((SELECT COUNT(fact_fecha) FROM Factura
		WHERE fact_tipo+fact_sucursal+fact_numero IN 
			(SELECT item_tipo+item_sucursal+item_numero FROM Item_Factura
			GROUP BY item_tipo+item_sucursal+item_numero
			HAVING SUM(item_cantidad * item_precio) <> 
					(SELECT (f2.fact_total - f2.fact_total_impuestos) FROM Factura f2
					WHERE f2.fact_tipo+f2.fact_sucursal+f2.fact_numero = item_tipo+item_sucursal+item_numero ) )  )) AS CantFact
FROM Factura f
JOIN Cliente c ON c.clie_codigo = f.fact_cliente
GROUP BY YEAR(f.fact_fecha)

-- Ejercicio 22

SELECT r.rubr_detalle,
       DATEPART(QUARTER,f.fact_fecha) AS NumeroTrimestre,
	   COUNT(DISTINCT f.fact_tipo+f.fact_sucursal+f.fact_numero) AS CantFacturas,
	   COUNT(DISTINCT i.item_producto) AS CantProductos
FROM Rubro r
JOIN Producto p ON p.prod_rubro = r.rubr_id
JOIN Item_Factura i on i.item_producto = p.prod_codigo
JOIN Factura f on f.fact_tipo+f.fact_sucursal+f.fact_numero = i.item_tipo+i.item_sucursal+i.item_numero
GROUP BY r.rubr_detalle, DATEPART(QUARTER,f.fact_fecha)
HAVING COUNT(DISTINCT f.fact_tipo+f.fact_sucursal+f.fact_numero) > 100
ORDER BY 1,3

-- Ejercicio 23

SELECT YEAR(f.fact_fecha),
		i.item_producto,
		(SELECT COUNT(comp_componente) FROM Composicion
		WHERE comp_producto = i.item_producto) AS CantComp,
		COUNT(DISTINCT f.fact_tipo+fact_sucursal+fact_numero) AS CantFacturas,
		(SELECT TOP 1 fact_cliente FROM Factura
		JOIN Item_Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
		WHERE item_producto = i.item_producto AND YEAR(fact_fecha) = YEAR(f.fact_fecha)
		GROUP BY fact_cliente
		ORDER BY SUM(i.item_cantidad) DESC
		) AS ClienteMasCompro
FROM Factura f
JOIN Item_Factura i ON i.item_tipo+i.item_sucursal+i.item_numero = f.fact_tipo+f.fact_sucursal+f.fact_numero
WHERE i.item_producto IN (SELECT TOP 1 prod_codigo FROM Producto
		JOIN Item_Factura on item_producto = prod_codigo
		JOIN Factura on fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
		WHERE prod_codigo IN (SELECT comp_producto FROM Composicion) AND YEAR(fact_fecha) = YEAR(f.fact_fecha)
		GROUP BY prod_codigo
		ORDER BY SUM(item_cantidad) DESC)
GROUP BY YEAR(f.fact_fecha),i.item_producto

-- Ejercicio 24

SELECT p.prod_codigo,
		p.prod_detalle,
		(SUM(i.item_cantidad)) AS unidadesFacturadas
FROM Producto p
JOIN Item_Factura i ON i.item_producto = p.prod_codigo
JOIN Factura f ON f.fact_tipo+f.fact_sucursal+f.fact_numero = i.item_tipo+i.item_sucursal+i.item_numero
WHERE p.prod_codigo IN (SELECT comp_producto FROM Composicion) 
AND f.fact_vendedor IN (SELECT TOP 2 empl_codigo FROM Empleado
						ORDER BY empl_comision DESC)
GROUP BY p.prod_codigo,p.prod_detalle
HAVING COUNT(i.item_producto) > 5
ORDER BY SUM(i.item_cantidad) DESC

-- Ejercicio 25

SELECT YEAR(f.fact_fecha),
		p.prod_familia,
		(COUNT (DISTINCT p.prod_rubro)) AS CantRubros,
		(SELECT COUNT(comp_componente) FROM Composicion
		WHERE comp_producto = (SELECT TOP 1 prod_codigo FROM Producto
								JOIN Item_Factura on item_producto = prod_codigo
								JOIN Factura on fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
								WHERE YEAR(fact_fecha) = YEAR(f.fact_fecha) AND prod_familia = p.prod_familia
								GROUP BY prod_codigo
								ORDER BY (SUM(item_cantidad)) DESC)) AS CantProductosDelMasVendido,
		(COUNT (DISTINCT f.fact_tipo+f.fact_sucursal+f.fact_numero)) AS CantFacturas,
		(SELECT TOP 1 fact_cliente FROM Factura
		JOIN Item_Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
		JOIN Producto p on p.prod_codigo = item_producto
		WHERE YEAR(fact_fecha) = YEAR(f.fact_fecha) AND prod_familia = p.prod_familia
		GROUP BY fact_cliente
		ORDER BY SUM(item_cantidad) DESC) AS ClienteQueMasCompro,
		(SUM(item_cantidad*item_precio) * 100 / (SELECT SUM(item_cantidad*item_precio) FROM Item_Factura
												JOIN Factura on fact_tipo+fact_sucursal+fact_numero =
												item_tipo+item_sucursal+item_numero
												WHERE YEAR(fact_fecha) = YEAR(f.fact_fecha))) AS Porcentaje
FROM Producto p
JOIN Item_Factura i ON  i.item_producto = p.prod_codigo
JOIN Factura f ON f.fact_tipo+f.fact_sucursal+f.fact_numero = i.item_tipo+i.item_sucursal+i.item_numero 
WHERE p.prod_familia = (SELECT TOP 1 prod_familia FROM Producto
		JOIN Item_Factura on item_producto = prod_codigo
	    JOIN Factura on fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
		WHERE YEAR(fact_fecha) = YEAR(f.fact_fecha)
		GROUP BY prod_familia
		ORDER BY (SUM(item_cantidad)) DESC)
GROUP BY YEAR(f.fact_fecha), p.prod_familia


-- Ejercicio 26

SELECT e.empl_codigo,
		COUNT(d.depo_encargado) AS CantDepo,
		SUM(ISNULL(fact_total,0)) AS TotalFacturadoEnAñoCorriente,
		(SELECT TOP 1 fact_cliente FROM Factura
		WHERE YEAR(fact_fecha) = 2012 AND fact_vendedor = e.empl_codigo
		GROUP BY fact_cliente
		ORDER BY COUNT (fact_cliente) DESC) AS MejorCliente,
		(SELECT TOP 1 item_producto FROM Item_Factura
		JOIN Factura f2 on f2.fact_tipo+f2.fact_sucursal+f2.fact_numero = item_tipo+item_sucursal+item_numero
		WHERE YEAR(f2.fact_fecha) = 2012 AND f2.fact_vendedor = e.empl_codigo
		GROUP BY item_producto
		ORDER BY SUM(item_cantidad)) AS MejorProducto,
		(SUM(ISNULL(fact_total,0)) * 100 / (SELECT SUM(f3.fact_total) FROM Factura f3
											WHERE YEAR(f3.fact_fecha) = 2012)) AS PorcentajeEmpleado
FROM Empleado e
LEFT JOIN DEPOSITO d on d.depo_encargado = e.empl_codigo
LEFT JOIN Factura f on f.fact_vendedor = e.empl_codigo AND YEAR(f.fact_fecha) = 2012
GROUP BY e.empl_codigo,d.depo_encargado
ORDER BY SUM(f.fact_total) DESC 

-- Ejercicio 27


SELECT YEAR(f.fact_fecha),
	   e.enva_codigo,
	   e.enva_detalle,
	   COUNT (DISTINCT p.prod_codigo) AS CantProductos,
	   SUM(item_cantidad) AS CantFact,
	   (SELECT TOP 1 prod_detalle FROM Producto
	   JOIN Item_Factura ON item_producto = prod_codigo
	   JOIN Factura ON fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
	   WHERE YEAR(fact_fecha) = YEAR(f.fact_fecha) AND prod_envase = e.enva_codigo
	   GROUP BY prod_detalle
	   ORDER BY SUM(item_cantidad)) AS ProdMasVendido,
	   (SUM(item_cantidad*item_precio)) AS MontoTotal,
	   ( (SUM(item_cantidad*item_precio)) * 100 / (SELECT SUM(item_cantidad*item_precio) FROM Item_Factura
													JOIN Factura ON fact_tipo+fact_sucursal+fact_numero = 
													item_tipo+item_sucursal+item_numero
													WHERE YEAR(fact_fecha) = YEAR(f.fact_fecha)) ) AS PorcentajeTotal
FROM Factura f
JOIN Item_Factura i ON i.item_tipo+i.item_sucursal+i.item_numero = f.fact_tipo+f.fact_sucursal+f.fact_numero
JOIN Producto p ON p.prod_codigo = i.item_producto
JOIN Envases e ON e.enva_codigo = p.prod_envase
GROUP BY YEAR(f.fact_fecha), e.enva_codigo,e.enva_detalle
ORDER BY 1, (SUM(item_cantidad*item_precio)) DESC


-- Ejercicio 28

SELECT YEAR(f.fact_fecha), 
		e.empl_codigo, 
		e.empl_apellido,
		COUNT(DISTINCT f.fact_tipo+f.fact_sucursal+f.fact_numero) AS CantFacturas,
		COUNT(DISTINCT f.fact_cliente) AS CantClientes,
		( SELECT COUNT(DISTINCT item_producto) FROM Item_Factura
		JOIN Factura on fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
		WHERE YEAR(fact_fecha)  = YEAR(f.fact_fecha) AND fact_vendedor = e.empl_codigo AND item_producto IN 
		(SELECT comp_producto FROM Composicion) ) AS CantProdConComp,
		(SELECT COUNT(DISTINCT item_producto) FROM Item_Factura
		JOIN Factura on fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
		WHERE YEAR(fact_fecha)  = YEAR(f.fact_fecha) AND fact_vendedor = e.empl_codigo AND item_producto NOT IN 
		(SELECT comp_producto FROM Composicion)) AS CantProdSinComp,
		SUM(f.fact_total) as TotalVendido
FROM Empleado e
JOIN Factura f on f.fact_vendedor = e.empl_codigo
GROUP BY YEAR(f.fact_fecha),e.empl_codigo,e.empl_apellido
ORDER BY 1, (SELECT COUNT(DISTINCT item_producto) FROM Item_Factura
			JOIN Factura on fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero
			WHERE YEAR(fact_fecha) = YEAR(f.fact_fecha) AND fact_vendedor = e.empl_codigo)

-- Ejercicio 29

SELECT p.prod_codigo, 
	   p.prod_detalle,
	   SUM(i.item_cantidad) AS CantVendida,
	   COUNT(f.fact_tipo+f.fact_sucursal+f.fact_numero) AS CantFacturas,
	   SUM(i.item_cantidad * i.item_precio) AS TotalFact
FROM Producto p
JOIN Item_Factura i on i.item_producto = p.prod_codigo
JOIN Factura f on f.fact_tipo+f.fact_sucursal+f.fact_numero = i.item_tipo+i.item_sucursal+i.item_numero
WHERE YEAR(f.fact_fecha) = 2011 AND p.prod_familia in (SELECT fami_id FROM Familia
														JOIN Producto ON prod_familia = fami_id
														GROUP BY fami_id
														HAVING COUNT(DISTINCT prod_codigo) > 20)
GROUP BY p.prod_codigo, p.prod_detalle
ORDER BY 3 DESC

-- Ejercicio 30

SELECT j.empl_nombre,
		COUNT(DISTINCT e.empl_codigo) AS CanEmpl,
		SUM(f.fact_total) AS MontoTotalEmpleados,
		COUNT(DISTINCT f.fact_tipo+f.fact_sucursal+f.fact_numero) AS CantFacturas,
		(SELECT TOP 1 e1.empl_nombre FROM Empleado e1
		JOIN Factura on fact_vendedor = e1.empl_codigo
		WHERE e1.empl_jefe = j.empl_codigo AND YEAR(fact_fecha) = 2012
		GROUP BY e1.empl_codigo, e1.empl_nombre
		ORDER BY SUM(fact_total) DESC) AS MejorEmpleado
FROM Empleado j
JOIN Empleado e on e.empl_jefe = j.empl_codigo
JOIN Factura f on f.fact_vendedor = e.empl_codigo
WHERE YEAR(f.fact_fecha) = 2012
GROUP BY j.empl_codigo,j.empl_nombre
HAVING COUNT(DISTINCT f.fact_tipo+f.fact_sucursal+f.fact_numero) > 10
ORDER BY 3 DESC

-- Ejercicio 31

SELECT YEAR(f.fact_fecha), e.empl_codigo, e.empl_apellido,
		(SELECT COUNT(fact_vendedor) FROM Factura
		WHERE fact_vendedor = e.empl_codigo AND YEAR(fact_fecha) = YEAR(f.fact_fecha)) AS CantFacturas,
		
		(SELECT COUNT(DISTINCT fact_cliente) FROM Factura
		WHERE fact_vendedor = e.empl_codigo AND YEAR(fact_fecha) = YEAR(f.fact_fecha)) AS CantClientes,

		(SELECT COUNT(DISTINCT item_producto) FROM Factura
		JOIN Item_Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
		 WHERE fact_vendedor = e.empl_codigo AND YEAR(fact_fecha) = YEAR(f.fact_fecha) AND
		 item_producto IN (SELECT comp_producto FROM Composicion)) AS CantProdConComp,

		 (SELECT COUNT(DISTINCT item_producto) FROM Factura
		JOIN Item_Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
		 WHERE fact_vendedor = e.empl_codigo AND YEAR(fact_fecha) = YEAR(f.fact_fecha) AND
		 item_producto NOT IN (SELECT comp_producto FROM Composicion)) AS CantProdSinComp,

		(SELECT SUM(fact_total) FROM Factura
		WHERE fact_vendedor = e.empl_codigo and YEAR(fact_fecha) = YEAR(f.fact_fecha)) AS MontoTotal
FROM Factura f
LEFT JOIN Empleado e on e.empl_codigo = f.fact_vendedor
GROUP BY YEAR(f.fact_fecha), e.empl_codigo, e.empl_apellido
ORDER BY YEAR(f.fact_fecha), (SELECT COUNT (DISTINCT item_producto) FROM Factura
								JOIN Item_Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
								WHERE fact_vendedor = e.empl_codigo AND YEAR(fact_fecha) = YEAR(f.fact_fecha)
								)

-- Ejercicio 32

SELECT f1.fami_id,
	   f1.fami_detalle,
	   f2.fami_id,
	   f2.fami_detalle,
	   COUNT(DISTINCT f.fact_tipo+f.fact_sucursal+f.fact_numero) AS CantFacturas,
	   SUM(i.item_cantidad*i.item_precio) + SUM(i2.item_cantidad*i2.item_precio) AS TotalVendido
FROM Familia f1
JOIN Producto p ON p.prod_familia = f1.fami_id
JOIN Item_Factura i ON i.item_producto = p.prod_codigo
JOIN Factura f ON f.fact_tipo+f.fact_sucursal+f.fact_numero = i.item_tipo+i.item_sucursal+i.item_numero
JOIN Item_Factura i2 ON i2.item_tipo+i2.item_sucursal+i2.item_numero = f.fact_tipo+f.fact_sucursal+f.fact_numero
JOIN Producto p2 ON p2.prod_codigo = i2.item_producto
JOIN Familia f2 ON f2.fami_id = p2.prod_familia
WHERE f2.fami_id <> f1.fami_id AND i.item_tipo+i.item_sucursal+i.item_numero = i2.item_tipo+i2.item_sucursal+i2.item_numero
GROUP BY f1.fami_id,f1.fami_detalle, f2.fami_id,f2.fami_detalle
HAVING (COUNT(DISTINCT f.fact_tipo+f.fact_sucursal+f.fact_numero)) > 10
ORDER BY 3



-- Ejercicio 33

SELECT p.prod_codigo, 
	   p.prod_detalle,
	   SUM(i.item_cantidad) AS CantVendida,
	   COUNT(DISTINCT f.fact_numero) AS CantFacturas,
	   AVG(item_precio) AS PrecioPromedio,
	   SUM(i.item_cantidad*i.item_precio) AS TotalFacturado
FROM Producto p
JOIN Composicion c on p.prod_codigo = c.comp_componente
JOIN Item_Factura i on i.item_producto = p.prod_codigo
JOIN Factura f on f.fact_tipo+f.fact_sucursal+f.fact_numero = i.item_tipo+i.item_sucursal+i.item_numero
WHERE YEAR(f.fact_fecha) = 2012 AND c.comp_producto = 
	(select top 1 item_producto from Item_Factura 
	join factura on fact_numero+fact_tipo+fact_sucursal = item_numero+item_tipo+item_sucursal
	where year(fact_fecha) = 2012 and item_producto in (select comp_producto from Composicion)
	group by item_producto
	order by sum(item_precio*item_cantidad) desc)
GROUP BY p.prod_codigo,p.prod_detalle
ORDER BY SUM(i.item_cantidad) DESC

-- Ejercicio 34 Esta mal

SELECT r.rubr_id, MONTH(f.fact_fecha) AS MES,
	(SELECT ISNULL(COUNT(fact_tipo+fact_sucursal+fact_numero),0) FROM Factura
		JOIN Item_Factura on item_tipo+item_sucursal+item_numero = fact_tipo+fact_sucursal+fact_numero
		JOIN Producto on prod_codigo = item_producto
		WHERE YEAR(fact_fecha) = 2011 AND MONTH(fact_fecha) = MONTH(f.fact_fecha) AND 
		prod_rubro <> rubr_id AND fact_tipo+fact_sucursal+fact_numero = f.fact_tipo+f.fact_sucursal+f.fact_numero
		GROUP BY MONTH(fact_fecha),fact_tipo+fact_sucursal+fact_numero) AS CantFactMal
FROM Rubro r
LEFT JOIN Producto p on p.prod_rubro = r.rubr_id
LEFT JOIN Item_Factura i on i.item_producto = p.prod_codigo
LEFT JOIN Factura f on f.fact_tipo+f.fact_sucursal+f.fact_numero = i.item_tipo+i.item_sucursal+i.item_numero
WHERE YEAR(f.fact_fecha) = 2011
GROUP BY r.rubr_id, MONTH(f.fact_fecha),f.fact_tipo+f.fact_sucursal+f.fact_numero
ORDER BY MONTH(f.fact_fecha), r.rubr_id


-- Ejercicio 35

SELECT YEAR(f.fact_fecha),
		p.prod_codigo,
		p.prod_detalle,
		COUNT(DISTINCT F.fact_tipo+F.fact_sucursal+F.fact_numero) AS CantFacturas,
		COUNT(DISTINCT f.fact_vendedor) AS CantDifVend,
		(SELECT ISNULL(COUNT(comp_componente),0) FROM Composicion
		WHERE comp_producto = p.prod_codigo) AS CantComp,
		(SUM(i.item_cantidad * item_producto) * 100 / (SELECT SUM(fact_total) FROM Factura
														WHERE YEAR(fact_fecha) = YEAR(f.fact_fecha))) AS PorcetajeDelTotal
FROM Factura f
JOIN Item_Factura i ON i.item_tipo+i.item_sucursal+i.item_numero = f.fact_tipo+f.fact_sucursal+f.fact_numero
JOIN Producto p on p.prod_codigo = i.item_producto
GROUP BY YEAR(f.fact_fecha),p.prod_codigo,p.prod_detalle
ORDER BY YEAR(f.fact_fecha),COUNT(DISTINCT F.fact_tipo+F.fact_sucursal+F.fact_numero) DESC


--- PARCIAL PASADO

SELECT
	COUNT(DISTINCT c.clie_codigo)
FROM Factura f
JOIN Cliente c ON c.clie_codigo = f.fact_cliente
JOIN Item_Factura i ON i.item_tipo+i.item_sucursal+i.item_numero = f.fact_tipo+f.fact_sucursal+f.fact_numero
WHERE (YEAR(fact_fecha) % 2 = 0) AND 
		(SELECT SUM(item_cantidad) FROM Item_Factura
		JOIN Factura on fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero AND fact_cliente = c.clie_codigo 
		WHERE YEAR(fact_fecha) = (SELECT TOP 1 YEAR(fact_fecha) FROM Factura
									WHERE fact_cliente = c.clie_codigo	
									ORDER BY YEAR(fact_fecha) DESC)
		GROUP BY fact_cliente) > 
								(SELECT SUM(item_cantidad) FROM Item_Factura
		JOIN Factura on fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero AND fact_cliente = c.clie_codigo 
		WHERE YEAR(fact_fecha) != (SELECT TOP 1 YEAR(fact_fecha) FROM Factura
									WHERE fact_cliente = c.clie_codigo	
									ORDER BY YEAR(fact_fecha) DESC)
		GROUP BY fact_cliente) * 0.10
	AND
	(SELECT COUNT(DISTINCT item_producto) FROM Item_Factura
		JOIN Factura on fact_tipo+fact_sucursal+fact_numero = item_tipo+item_sucursal+item_numero AND fact_cliente = c.clie_codigo 
		WHERE YEAR(fact_fecha) = (SELECT TOP 1 YEAR(fact_fecha) FROM Factura
									WHERE fact_cliente = c.clie_codigo	
									ORDER BY YEAR(fact_fecha) DESC)
		GROUP BY fact_cliente) > 10
HAVING COUNT(DISTINCT c.clie_codigo) > 10
	     
