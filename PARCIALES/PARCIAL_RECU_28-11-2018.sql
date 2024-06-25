-- PARCIAL 1 RECU 28/11/2018

-- 1C SQL

SELECT m.manu_code, m.manu_name, COUNT(DISTINCT i.order_num) CantOrdenes,
SUM(i.quantity) CantVendida, 
(SELECT SUM(ii.quantity * ii.unit_price)/COUNT(DISTINCT ii.manu_code) FROM items ii) AS PromedioCantidadVentas
FROM manufact m
JOIN items i ON i.manu_code = m.manu_code
GROUP BY m.manu_code, m.manu_name
HAVING SUM(i.quantity * i.unit_price) > (SELECT SUM(i2.quantity * i2.unit_price)/ COUNT(DISTINCT i2.manu_code) FROM items i2) -- PROMEDIO VENTAS
ORDER BY 4 DESC

-- 2A STORED PROCEDURE

CREATE TABLE auditOC(
	ordern_num SMALLINT PRIMARY KEY,
	order_date DATETIME,
	customer_num SMALLINT,
	cant_items DECIMAL(12,0),
	total_orden DECIMAL(12,2),
	cant_productos_comprados DECIMAL(12,0)
);

CREATE TABLE erroresOC(
	orden_num SMALLINT PRIMARY KEY,
	order_date DATETIME,
	customer_num SMALLINT,
	error_ocurrido VARCHAR(50)
);

CREATE PROCEDURE procBorraOC(@NUMERO_ORDEN SMALLINT)
AS
BEGIN
	
	DECLARE @ORDEN_NUM SMALLINT, @ordern_num SMALLINT, @order_date DATETIME, @customer_num SMALLINT, @cant_items DECIMAL(12,0),
	@total_orden DECIMAL(12,2), @cant_productos_comprados DECIMAL(12,0), @error_mensaje NVARCHAR(255)

	DECLARE C_ORDEN CURSOR FOR
	SELECT o.order_num, o.order_date, o.customer_num, COUNT(DISTINCT i.item_num), SUM(i.quantity * i.unit_price),
	COUNT(DISTINCT i.item_num)
	FROM orders o
	JOIN items i ON i.order_num = o.order_num
	GROUP BY o.order_num, o.order_date, o.customer_num

	BEGIN TRY
	OPEN C_ORDEN
	FETCH NEXT FROM C_ORDEN INTO @ORDEN_NUM, @ordern_num, @order_date, @customer_num, @cant_items,
	@total_orden, @cant_productos_comprados
	WHILE(@@FETCH_STATUS = 0)
	BEGIN
		IF(@ORDEN_NUM = @NUMERO_ORDEN)
		BEGIN
			INSERT INTO auditOC(ordern_num, order_date, customer_num, cant_items, total_orden, cant_productos_comprados)
			VALUES(@ORDEN_NUM, @order_date, @customer_num, @cant_items,
					@total_orden, @cant_productos_comprados)
		END

			FETCH NEXT FROM C_ORDEN INTO @ORDEN_NUM
	END
	
	CLOSE C_ORDEN
	DEALLOCATE C_ORDEN

	END TRY

	BEGIN CATCH
	
	IF(CURSOR_STATUS('global','C_ORDEN')) >= -1
		BEGIN
			CLOSE C_ORDEN
			DEALLOCATE C_ORDEN
		END
			
		SET @error_mensaje = 'Error en Orden' + CAST(@NUMERO_ORDEN AS char(10));
		THROW 50000, @error_mensaje, 1;
		INSERT INTO erroresOC(orden_num, order_date, customer_num, error_ocurrido)
		SELECT o.order_num, o.order_date, o.customer_num, @error_mensaje FROM orders o WHERE o.order_num = @NUMERO_ORDEN
	END CATCH

END

-- 2E TRIGGER
