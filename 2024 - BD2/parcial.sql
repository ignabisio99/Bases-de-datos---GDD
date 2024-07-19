-- QUERY 

SELECT m.manu_code, m.manu_name, c.lname, c.fname,
SUM(i.quantity * i.unit_price) MontoTotalVendido,
(SELECT COUNT(DISTINCT o3.order_num) 
		FROM orders o3
		JOIN items i3 ON i3.order_num = o3.order_num
		WHERE i3.manu_code = m.manu_code AND o3.customer_num = c.customer_num) CantOrdenesConProductosDelFab
FROM orders o
JOIN items i ON i.order_num = o.order_num
JOIN customer c ON c.customer_num = o.customer_num
JOIN manufact m ON m.manu_code = i.manu_code
WHERE m.lead_time < 20 
GROUP BY m.manu_code, m.manu_name, c.lname, c.fname, c.customer_num
HAVING SUM(i.quantity * i.unit_price) > 1000
ORDER BY m.manu_code ASC, MontoTotalVendido DESC

-- TRIGGER

CREATE TRIGGER borradoEnCustomer
ON customer
INSTEAD OF DELETE
AS
BEGIN

	DECLARE @CUSTOMERNUM SMALLINT
	
	DECLARE C_CUSTOMER CURSOR FOR
	SELECT d.customer_num FROM deleted d

	OPEN C_CUSTOMER
	FETCH NEXT FROM C_CUSTOMER INTO @CUSTOMERNUM
	WHILE(@@FETCH_STATUS = 0)
	BEGIN
		IF((SELECT COUNT(DISTINCT o.order_num) FROM orders o WHERE o.customer_num = @CUSTOMERNUM) = 0)
		BEGIN
			DELETE customer WHERE customer_num = @CUSTOMERNUM
		END

		IF((SELECT TOP 1 CAST(o.order_date AS DATE) FROM orders o
			ORDER BY o.order_date DESC) < 2015-07-01)
		BEGIN
			UPDATE customer SET status = 'I' WHERE customer_num = @CUSTOMERNUM
		END
		ELSE
		BEGIN
			UPDATE customer SET status = 'P' WHERE customer_num = @CUSTOMERNUM
		END

		FETCH NEXT FROM C_CUSTOMER INTO @CUSTOMERNUM
	END
	
	CLOSE C_CUSTOMER
	DEALLOCATE C_CUSTOMER
END

-- STORED PROCEDURE

CREATE PROCEDURE borrarOrdenPr(@nroOrden int)
AS
BEGIN
	
	DECLARE @NRO_ORDEN SMALLINT

	BEGIN TRY

		DECLARE C_ITEMS CURSOR FOR
		SELECT order_num FROM items

		OPEN C_ITEMS
		FETCH NEXT FROM C_ITEMS INTO @NRO_ORDEN
		WHILE(@@FETCH_STATUS = 0)

		BEGIN TRANSACTION

		BEGIN
			IF(@NRO_ODEN = @nroOrden)
			DELETE items WHERE order_num = @nroOrden
			FETCH NEXT FROM C_ITEMS INTO @NRO_ORDEN
		END
		
		DELETE orders WHERE order_num = @nroOrden
		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		
		PRINT cast(ERROR_NUMBER() AS VARCHAR(10))
		PRINT ERROR_MESSAGE();
		THROW 50001, 'ERROR AL BORRAR ORDEN', 1
		
		ROLLBACK TRANSACTION
	END CATCH
END

B) La logica de negocio que falla es que solo se esta borrando el primer item que encuentra con ese order_num, por lo que si tenemos una
orden de compra con varios items distintos, van a quedar almacenados teniendo una FK a una orden que ya no existe. Se deberia eliminar
todos los items utilizando un cursor.
