-- 1erParcial práctico 2021-07-14

-- QUERY

SELECT r.fname NombreReferido, r.lname ApellidoReferido, SUM(i2.quantity * i2.unit_price)/ COUNT(DISTINCT o2.order_num) PromReferido,
c.fname NombreReferente, c.lname NombreReferente, SUM(i1.quantity * i1.unit_price)/ COUNT(DISTINCT o1.order_num) PromReferente
FROM customer c
JOIN customer r ON r.customer_num = c.customer_num_referedBy
JOIN orders o1 ON o1.customer_num = c.customer_num
JOIN items i1 ON i1.order_num = o1.order_num
JOIN orders o2 ON o2.customer_num = r.customer_num
JOIN items i2 ON i2.order_num = o2.order_num
GROUP BY r.fname, r.lname, c.fname, c.lname
HAVING SUM(i2.quantity * i2.unit_price)/ COUNT(DISTINCT o2.order_num) > SUM(i1.quantity * i1.unit_price)/ COUNT(DISTINCT o1.order_num)
ORDER BY r.fname, r.lname

-- STORED PROCEDURE
DROP TABLE audit_fabricante

CREATE TABLE audit_fabricante(
	nro_audit BIGINT IDENTITY PRIMARY KEY,
	fecha DATETIME DEFAULT getDate(),
	accion CHAR(1) CHECK (accion IN ('I','O','N','D')),
	manu_code char(3),
	manu_name varchar(30),
	lead_time smallint,
	state char(2),
	usuario VARCHAR(30) DEFAULT USER,
);CREATE PROCEDURE inversasAuditoria(@FECHAMAX DATETIME)ASBEGIN	BEGIN TRANSACTION		DECLARE @NROAUDIT BIGINT, @FECHA DATETIME, @ACCION CHAR(1), @MANUCODE CHAR(3), @MANUNAME VARCHAR(30),	@LEADTIME SMALLINT, @STATE CHAR(2), @USUARIO VARCHAR(30)	DECLARE C_AUDITORIA CURSOR FOR	SELECT nro_audit, fecha, accion, manu_code, manu_name, lead_time, state, usuario FROM audit_fabricante	WHERE @FECHAMAX >= fecha	OPEN C_AUDITORIA	FETCH NEXT FROM C_AUDITORIA INTO @NROAUDIT, @FECHA, @ACCION, @MANUCODE, @MANUNAME,	@LEADTIME, @STATE, @USUARIO	WHILE(@@FETCH_STATUS = 0)	BEGIN		BEGIN TRY			IF(@ACCION = 'I')			BEGIN				DELETE FROM manufact WHERE manu_code = @MANUCODE			END			IF(@ACCION = 'O')			BEGIN				UPDATE manufact SET manu_name = @MANUNAME, lead_time = @LEADTIME, state = @STATE, f_alta_audit = @FECHA,				d_usualta_audit = @FECHA 				WHERE manu_code = @MANUCODE			END			IF(@ACCION = 'D')			BEGIN				INSERT INTO manufact (manu_code, manu_name, lead_time, state, f_alta_audit, d_usualta_audit)				VALUES(@MANUCODE, @MANUNAME, @LEADTIME, @STATE, @FECHA, @FECHA)			END		END TRY		BEGIN CATCH			PRINT 'Ha ocurrido el siguiente error: ' + ERROR_MESSAGE();
			PRINT 'No se ha realizado ninguna operación.'
			ROLLBACK TRANSACTION		END CATCH		FETCH NEXT FROM C_AUDITORIA INTO @NROAUDIT, @FECHA, @ACCION, @MANUCODE, @MANUNAME,		@LEADTIME, @STATE, @USUARIO			END	COMMIT TRANSACTION	CLOSE C_AUDITORIA	DEALLOCATE C_AUDITORIAEND-- TRIGGERCREATE TRIGGER bajaLogicaON ordersINSTEAD OF DELETEASBEGIN	BEGIN TRANSACTION		DECLARE @ORDERNUM SMALLINT, @CUSTOMERNUM SMALLINT	DECLARE C_ORDERS CURSOR FOR	SELECT order_num, customer_num FROM deleted	OPEN C_ORDERS	FETCH NEXT FROM C_ORDERS INTO @ORDERNUM, @CUSTOMERNUM	WHILE(@@FETCH_STATUS = 0)	BEGIN		BEGIN TRY		IF((SELECT COUNT(*) FROM orders			WHERE customer_num = @CUSTOMERNUM) < 5)		BEGIN			UPDATE orders SET flag_baja = 1, fecha_baja = GETDATE(), user_baja = USER_NAME()		END		ELSE		BEGIN			INSERT INTO borradosFallidos(customer_num, order_num, fecha_baja, user_baja)			VALUES(@CUSTOMERNUM, @ORDERNUM, GETDATE(), USER_NAME())		END		END TRY				BEGIN CATCH			PRINT 'Ha ocurrido el siguiente error: ' + ERROR_MESSAGE();
			PRINT 'No se ha realizado ninguna operación.'			ROLLBACK TRANSACTION		END CATCH		FETCH NEXT FROM C_ORDERS INTO @ORDERNUM, @CUSTOMERNUM	END	COMMIT TRANSACTION	CLOSE C_ORDERS	DEALLOCATE C_ORDERSEND