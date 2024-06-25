-- PARCIAL 2017-07-14


-- 1 QUERY

SELECT c.fname, c.lname, SUM(i1.quantity * i1.unit_price) / (SELECT COUNT(DISTINCT o3.order_num) FROM orders o3 
										 WHERE o3.customer_num = c.customer_num) PromedioOrdenReferente,
cr.fname, cr.lname, SUM(i2.quantity * i2.unit_price) / (SELECT COUNT(DISTINCT o3.order_num) FROM orders o3 
										 WHERE o3.customer_num = cr.customer_num) PromedioOrdenReferido
FROM customer c
JOIN customer cr ON cr.customer_num = c.customer_num_referedBy
JOIN orders o1 ON o1.customer_num = c.customer_num
JOIN items i1 ON i1.order_num = o1.order_num
JOIN orders o2 ON o2.customer_num = cr.customer_num
JOIN items i2 ON i2.order_num = o2.order_num
GROUP BY c.fname, c.lname, cr.fname, cr.lname, c.customer_num, cr.customer_num
HAVING SUM(i1.quantity * i1.unit_price) / (SELECT COUNT(DISTINCT o3.order_num) FROM orders o3 
										 WHERE o3.customer_num = c.customer_num)
		< SUM(i2.quantity * i2.unit_price) / (SELECT COUNT(DISTINCT o3.order_num) FROM orders o3 
										 WHERE o3.customer_num = cr.customer_num)
ORDER BY cr.fname, cr.lname


-- STORED PROCEDURE

CREATE TABLE audit_fabricante(
	nro_audit BIGINT IDENTITY PRIMARY KEY,
	fecha DATETIME DEFAULT getDate(),
	accion CHAR(1) CHECK (accion IN ('I','O','N','D')),
	manu_code char(3),
	manu_name varchar(30),
	lead_time smallint,
	state char(2),
	usuario VARCHAR(30) DEFAULT USER,
);CREATE PROCEDURE rollback_procedure(@FECHA_HASTA DATETIME)ASBEGIN	DECLARE @NRO_AUDIT BIGINT, @ACCION CHAR(1), @MANU_CODE CHAR(3), @MANU_NAME VARCHAR(30), @LEAD_TIME SMALLINT,	@STATE CHAR(2), @USUARIO VARCHAR(30)		DECLARE C_AUDIT CURSOR FOR	SELECT nro_audit, accion, manu_code, manu_name, lead_time, state, usuario FROM audit_fabricante	WHERE fecha > @FECHA_HASTA AND fecha < GETDATE()	BEGIN TRY	OPEN C_AUDIT	FETCH NEXT FROM C_AUDIT INTO @NRO_AUDIT, @ACCION, @MANU_CODE, @MANU_NAME, @LEAD_TIME, @STATE, @USUARIO	WHILE(@@FETCH_STATUS = 0)	BEGIN						IF(@ACCION = 'I')			BEGIN				DELETE FROM manufact WHERE manu_code = @MANU_CODE			END			IF(@ACCION = 'O')			BEGIN				UPDATE manufact SET manu_name = @MANU_NAME, lead_time = @LEAD_TIME, state = @STATE, f_alta_audit = GETDATE(),				d_usualta_audit = @USUARIO				WHERE manu_code = @MANU_CODE			END			IF(@ACCION = 'D')			BEGIN				INSERT INTO manufact(manu_code, manu_name, lead_time, state, f_alta_audit, d_usualta_audit)				VALUES(@MANU_CODE, @MANU_NAME, @LEAD_TIME, @STATE, GETDATE(), @USUARIO)			END		END	CLOSE C_AUDIT	DEALLOCATE C_AUDIT	END TRY	BEGIN CATCH		PRINT 'Ha ocurrido el siguiente error: ' + ERROR_MESSAGE();
			PRINT 'No se ha realizado ninguna operación.'
			ROLLBACK TRANSACTION
			END CATCH
			FETCH NEXT FROM cursor_audit into @fecha, @accion, @manu_code,
			@manu_name, @lead_time, @state, @usuario
			END
			COMMIT TRANSACTION
			CLOSE cursor_audit
			DEALLOCATE cursor_audit
			END	END CATCHEND