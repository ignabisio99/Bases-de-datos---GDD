-- parcial_2k20-zaffaroni_2c

-- QUERY 

SELECT c.state, c.customer_num, c.fname, c.lname, 
SUM(i.quantity * i.unit_price) / COUNT(DISTINCT o.order_num) PromedioXOrden,
SUM(i.quantity * i.unit_price) MontoXCliente,
(SELECT SUM(i2.quantity * i2.unit_price) FROM customer c2
	JOIN orders o2 ON o2.customer_num = c2.customer_num
	JOIN items i2 ON i2.order_num = o2.order_num
	WHERE c2.state = c.state) MontoXEstado
FROM customer c
JOIN orders o ON o.customer_num = c.customer_num
JOIN items i ON i.order_num = o.order_num
WHERE c.state IN (SELECT TOP 3 c5.state FROM customer c5
				JOIN orders o5 ON o5.customer_num = c5.customer_num
				JOIN items i5 ON i5.order_num = o5.order_num
				GROUP BY c5.state
				ORDER BY SUM(i5.quantity * i5.unit_price) DESC)
GROUP BY c.state, c.customer_num, c.fname, c.lname
HAVING SUM(i.quantity * i.unit_price) > 85 
ORDER BY 7 DESC, 6 DESC

-- STORED PROCEDURE

CREATE TABLE cuentaCorriente(
	id BIGINT IDENTITY(1,1) PRIMARY KEY,
	fechaMovimiento DATETIME,
	customer_num SMALLINT REFERENCES customer,
	order_num SMALLINT REFERENCES orders,
	importe DECIMAL(12,2)
);

CREATE PROCEDURE cargarTabla
AS
BEGIN
	
	INSERT INTO cuentaCorriente(fechaMovimiento, customer_num, order_num, importe)
	SELECT o.order_date ,o.customer_num, o.order_num, SUM(i.quantity * i.unit_price) FROM orders o
	JOIN items i ON i.order_num = o.order_num
	GROUP BY o.order_date, o.customer_num, o.order_num
	UNION
	SELECT o.paid_date, o.customer_num, o.order_num, SUM(i.quantity * i.unit_price - 1) FROM orders o
	JOIN items i ON i.order_num = o.order_num
	WHERE o.paid_date IS NOT NULL
	GROUP BY o.paid_date, o.customer_num, o.order_num

END

-- TRIGGER

CREATE TABLE CUSTOMER_AUDIT(
	 customer_num smallint,
	 update_date datetime,
	 ApeyNom_NEW varchar(40),
	 State_NEW char(2),
	 customer_num_referedBy_NEW smallint,
	 ApeyNom_OLD varchar(40),
	 State_OLD char(2),
	 customer_num_referedBy_OLD smallint,
	 update_user varchar(30) not null
	 PRIMARY KEY(customer_num, update_date)
);

CREATE TRIGGER modificacionesCustomer
ON customer
AFTER DELETE, UPDATE
AS
BEGIN
	
	DECLARE @NOMBRE_APELLIDO_O VARCHAR(40), @NOMBRE_APELLIDO_N VARCHAR(40), @STATE_O CHAR(2), @STATE_N CHAR(2),
			@REF_O SMALLINT, @REF_N SMALLINT, @CUSTOMER_NUM SMALLINT
	
	DECLARE C_CUSTOMER CURSOR FOR
	SELECT d.lname + ', ' + d.fname, d.state, d.customer_num_referedBy, 
	i.lname + ', ' + i.fname, i.state, i.customer_num_referedBy 
	FROM deleted d
	LEFT JOIN inserted i ON i.customer_num = d.customer_num

	OPEN C_CUSTOMER
	FETCH NEXT FROM C_CUSTOMER INTO @NOMBRE_APELLIDO_O, @STATE_O, @REF_O, @NOMBRE_APELLIDO_N, @STATE_N, @REF_N
	WHILE(@@FETCH_STATUS = 1)
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION 

			IF NOT EXISTS(SELECT 1 FROM inserted)
			BEGIN
				INSERT INTO CUSTOMER_AUDITt(customer_num, update_Date, apeynom_OLD,
										state_Old, customer_num_referedby_OLD, update_user)
				VALUES(@CUSTOMER_NUM, GETDATE(), @NOMBRE_APELLIDO_O, @STATE_O, @REF_O, SYSTEM_USER)
			END
			ELSE
			BEGIN
				if not exists(select 1 from customer
				where customer_num = @REF_N)
				THROW 50001, 'Referente inexistente', 1;

				if not exists (select 1 from state where state = @STATE_N)
				THROW 50002, 'Estado inexistente', 1;

				INSERT INTO customer_audit(customer_num, update_Date,apeynom_NEW,
							state_NEW,customer_num_referedby_NEW, apeynom_OLD,
							state_Old, customer_num_referedby_OLD,
							update_user)
							 values (@CUSTOMER_NUM, getDate(),
							 @NOMBRE_APELLIDO_N, @STATE_N, @REF_N, @NOMBRE_APELLIDO_O, @STATE_O, @REF_O, SYSTEM_USER)
			END

			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
		END CATCH 
		FETCH NEXT FROM C_CUSTOMER INTO @NOMBRE_APELLIDO_O, @STATE_O, @REF_O, @NOMBRE_APELLIDO_N, @STATE_N, @REF_N
	END

	CLOSE C_CUSTOMER
	DEALLOCATE C_CUSTOMER
END