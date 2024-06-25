-- PARCIAL 2018-06-27

-- QUERY 

SELECT c.fname + ', ' + c.lname AS Cliente, COALESCE(SUM(i.quantity * i.unit_price),0) AS TotalCompra,
cr.fname + ', ' + cr.lname AS ClienteReferido, SUM(i2.quantity * i2.unit_price) * 0.05 AS TotalComision
FROM customer c
LEFT JOIN customer cr ON cr.customer_num = c.customer_num_referedBy
LEFT JOIN orders o ON o.customer_num = c.customer_num
LEFT JOIN items i ON i.order_num = o.order_num
LEFT JOIN orders o2 ON o2.customer_num = cr.customer_num
LEFT JOIN items i2 ON i2.order_num = o2.order_num
WHERE i2.stock_num IN (1,4,5,6,9)
GROUP BY c.fname, c.lname, cr.fname, cr.lname
ORDER BY 1

-- STORED PROCEDURES

CREATE PROCEDURE operacionProducto(@STOCK_NUM SMALLINT, @MANU_CODE CHAR(3),
@UNITE_PRICE DECIMAL(6,2), @UNITE_CODE SMALLINT, @DESCRIPCION VARCHAR(15))
AS
BEGIN
	
	IF EXISTS (SELECT 1 FROM products WHERE stock_num = @STOCK_NUM AND manu_code = @MANU_CODE)
	BEGIN
		UPDATE products set unit_price = @UNITE_PRICE, unit_code = @UNITE_CODE
		WHERE stock_num = @STOCK_NUM AND manu_code = @MANU_CODE
	END
	ELSE
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM manufact WHERE manu_code = @MANU_CODE)
		BEGIN
			RAISERROR('NO EXISTE EL FABRICANTE', 16, 1)
		END

		IF NOT EXISTS(SELECT 1 FROM product_types WHERE stock_num = @STOCK_NUM)
		BEGIN
			INSERT INTO product_types(stock_num, description)
			VALUES(@STOCK_NUM, @DESCRIPCION)
		END
		ELSE
		BEGIN
			UPDATE product_types set description = @DESCRIPCION WHERE stock_num = @STOCK_NUM
		END

		IF EXISTS(SELECT 1 FROM units WHERE unit_code = @UNITE_CODE)
		BEGIN
			RAISERROR('EXISTE EL UNITE_CODE', 16, 1)
			 
		END

		INSERT INTO products(stock_num, manu_code, unit_price, unit_code)
		VALUES(@STOCK_NUM, @MANU_CODE, @UNITE_PRICE, @UNITE_CODE)
	END

END

-- TRIGGER 

CREATE VIEW v_Productos (codCliente, nombre, apellido, codProvincia, fechaLlamado, usuarioId, 
codTipoLlamada, descrLlamada, descrTipoLlamada)
AS
SELECT c.customer_num, fname, lname, state, call_dtime, user_id, cc.call_code, call_descr, code_descr
FROM customer c 
JOIN cust_calls cc ON (c.customer_num=cc.customer_num)
JOIN call_type ct ON (cc.call_code=ct.call_code)
WHERE ct.call_code IN ('B','D','I','L','O') AND state IN (SELECT s.state FROM state s)
WITH CHECK OPTIONCREATE TRIGGER vistaProductoON v_ProductosINSTEAD OF INSERTASBEGIN	DECLARE @codCliente smallint
	declare @nombre varchar(15)
	declare @apellido varchar(15)
	declare @codProvincia char(2)
	declare @fechaLlamado datetime
	declare @usuarioId char(32)
	declare @codTipoLlamada char(1)
	declare @descrLlamada varchar(40)
	declare @descrTipoLlamada varchar(30)		DECLARE C_VISTA CURSOR FOR	SELECT * FROM inserted	BEGIN TRY		OPEN C_VISTA		FETCH NEXT FROM C_VISTA INTO @codCliente, @nombre, @apellido, @codProvincia, @fechaLlamado,
										@usuarioId, @codTipoLlamada, @descrLlamada, @descrTipoLlamada		WHILE(@@FETCH_STATUS = 0)		BEGIN			if not exists (select 1 from dbo.customer c where c.customer_num = @codCliente)
			 insert into customer (customer_num, fname, lname,state)
			 values (@codCliente, @nombre, @apellido, @codProvincia)

			 if not exists (select 1 from call_type ct where ct.call_code = @codTipoLlamada)
			 insert into call_type (call_code,code_descr)
			 values (@codTipoLlamada, @descrTipoLlamada)

			 insert into cust_calls (customer_num, call_dtime, user_id, call_code, call_descr)
			 values (@codCliente, @fechaLlamado, @usuarioId, @codTipoLlamada, @descrLlamada)

			 FETCH NEXT FROM contactos_cur
			 INTO @codCliente, @nombre, @apellido, @codProvincia, @fechaLlamado,
			 @usuarioId, @codTipoLlamada, @descrLlamada, @descrTipoLlamada;		END	END TRY	begin catch
	 rollback;
	 print 'Nro. Error:' + cast(ERROR_NUMBER() as varchar);
	 print 'mensaje:' + ERROR_MESSAGE();
	end catch
CLOSE contactos_cur
DEALLOCATE contactos_curEND