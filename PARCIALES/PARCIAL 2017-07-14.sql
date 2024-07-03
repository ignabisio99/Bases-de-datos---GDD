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
);
			PRINT 'No se ha realizado ninguna operaci�n.'
			ROLLBACK TRANSACTION
			END CATCH
			FETCH NEXT FROM cursor_audit into @fecha, @accion, @manu_code,
			@manu_name, @lead_time, @state, @usuario
			END
			COMMIT TRANSACTION
			CLOSE cursor_audit
			DEALLOCATE cursor_audit
			END