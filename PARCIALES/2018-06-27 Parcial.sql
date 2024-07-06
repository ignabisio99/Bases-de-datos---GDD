-- 2018-06-27 Parcial

-- QUERY

SELECT c.lname, c.fname, COALESCE(SUM(i1.quantity * i1.unit_price),0) TotalCompra,
ref.lname, ref.fname, TotalCompraRef * 0.05 AS TotalComision
FROM customer c
LEFT JOIN orders o1 ON o1.customer_num = c.customer_num
LEFT JOIN items i1 ON i1.order_num = o1.order_num
LEFT JOIN (SELECT r.customer_num, r.lname, r.fname, SUM(i2.quantity * i2.unit_price) TotalCompraRef, r.customer_num_referedBy
			FROM customer r 
			JOIN orders o2 ON o2.customer_num = r.customer_num
			JOIN items i2 ON i2.order_num = o2.order_num
			WHERE r.customer_num IS NOT NULL AND i2.item_num IN (1,4,5,6,9)
			GROUP BY r.customer_num, r.lname, r.fname, r.customer_num_referedBy) ref ON ref.customer_num_referedBy = c.customer_num
GROUP BY c.customer_num, c.lname, c.fname, ref.lname, ref.fname, ref.customer_num, ref.TotalCompraRef
ORDER BY c.lname, c.fname


-- STORED PROCEDURE

CREATE PROCEDURE operacionProducto(@STOCKNUM SMALLINT, @MANUCODE CHAR(3), @UNITPRICE DECIMAL(6,2), @UNITECODE SMALLINT,
									@DESCRIPTION VARCHAR(15))
AS
BEGIN
	
	IF(EXISTS (SELECT * FROM products WHERE stock_num = @STOCKNUM AND manu_code = @MANUCODE))
	BEGIN
		UPDATE products SET unit_price = @UNITPRICE, unit_code = @UNITECODE WHERE stock_num = @STOCKNUM AND manu_code = @MANUCODE
		UPDATE product_types SET description = @DESCRIPTION WHERE stock_num = @STOCKNUM
	END
	ELSE
	BEGIN
		IF(NOT EXISTS (SELECT * FROM manufact WHERE manu_code = @MANUCODE))
		BEGIN
			throw 50000, 'Fabricante INEXISTENTE', 1
		END

		IF(NOT EXISTS (SELECT * FROM units WHERE unit_code = @UNITECODE))
		BEGIN
			throw 50000, 'Unicidad INEXISTENTE', 1
		END


		IF(NOT EXISTS (SELECT * FROM product_types WHERE stock_num = @STOCKNUM))
		BEGIN
			INSERT INTO product_types (stock_num, description)
			VALUES(@STOCKNUM, @DESCRIPTION)
		END
		ELSE
		BEGIN
			UPDATE product_types SET description = @DESCRIPTION WHERE stock_num = @STOCKNUM
		END

		INSERT INTO products(stock_num, manu_code, unit_price, unit_code)
		VALUES(@STOCKNUM, @MANUCODE, @UNITPRICE, @UNITECODE)

	END
END

-- TRIGGER


CREATE VIEW v_Productos (codCliente, nombre, apellido, codProvincia, fechaLlamado, usuarioId,
codTipoLlamada, descrLlamada, descrTipoLlamada)
AS
SELECT c.customer_num, fname, lname, state, call_dtime,user_id, cc.call_code, call_descr, code_descr
FROM customer c 
JOIN cust_calls cc ON (c.customer_num=cc.customer_num)
JOIN call_type ct ON (cc.call_code=ct.call_code)
WHERE ct.call_code IN ('B','D','I','L','O')
AND state IN (SELECT state FROM state)
WITH CHECK OPTIONCREATE TRIGGER insertarVistaON v_ProductosINSTEAD OF INSERTASBEGIN	declare @codCliente smallint
	declare @nombre varchar(15)
	declare @apellido varchar(15)
	declare @codProvincia char(2)
	declare @fechaLlamado datetime
	declare @usuarioId char(32)
	declare @codTipoLlamada char(1)
	declare @descrLlamada varchar(40)
	declare @descrTipoLlamada varchar(30)		DECLARE C_PRODUCTOS CURSOR FOR	SELECT i.apellido, i.codCliente, i.codProvincia, i.codTipoLlamada, i.descrLlamada, i.descrTipoLlamada, i.fechaLlamado,	i.nombre, i.usuarioId FROM inserted i	BEGIN TRY	OPEN C_PRODUCTOS	FETCH NEXT FROM C_PRODUCTOS INTO  @codCliente, @nombre, @apellido, @codProvincia, @fechaLlamado,
									@usuarioId, @codTipoLlamada, @descrLlamada, @descrTipoLlamada	WHILE(@@FETCH_STATUS = 0)	BEGIN				IF(NOT EXISTS(SELECT * FROM state WHERE state = @codCliente))		BEGIN			INSERT INTO state(state)			VALUES(@codProvincia)		END				IF(NOT EXISTS (SELECT * FROM customer WHERE customer_num = @codCliente))		BEGIN			INSERT INTO customer(customer_num, lname, fname, state)			VALUES(@codCliente, @nombre, @apellido, @codProvincia)		END		IF(NOT EXISTS(SELECT * FROM call_type WHERE call_code = @codTipoLlamada))		BEGIN			INSERT INTO call_type(call_code, code_descr)			VALUES(@codTipoLlamada, @descrTipoLlamada)		END		INSERT INTO cust_calls(customer_num, call_dtime, user_id, call_code, call_descr)		VALUES(@codCliente, @fechaLlamado, @usuarioId, @codTipoLlamada, @descrLlamada)		FETCH NEXT FROM C_PRODUCTOS INTO  @codCliente, @nombre, @apellido, @codProvincia, @fechaLlamado,
									@usuarioId, @codTipoLlamada, @descrLlamada, @descrTipoLlamada	END	END TRY		BEGIN CATCH		ROLLBACK		PRINT 'NUMERO DE ERROR: ' + ERROR_NUMBER()		PRINT 'MENSAJE:' + ERROR_MESSAGE()	END CATCH	CLOSE C_PRODUCTOS	DEALLOCATE C_PRODUCTOSEND