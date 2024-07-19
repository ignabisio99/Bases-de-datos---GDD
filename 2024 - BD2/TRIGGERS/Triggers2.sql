----- PRACTICA TRIGGERS 2

-- EJ 1
DROP TABLE items_error
CREATE TABLE items_error(
	order_num SMALLINT PRIMARY KEY,
	item_num SMALLINT,
	manu_code CHAR(3),
	quantity SMALLINT,
	stock_num SMALLINT,
	unite_price DECIMAL,
	fecha DATETIME
	)

CREATE TRIGGER TRIGGER2
ON items
INSTEAD OF INSERT
AS
BEGIN

	DECLARE @ORDER_NUM SMALLINT, @ITEM_NUM SMALLINT, @MANU_CODE CHAR(3), @QUANTITY SMALLINT, @STOCK_NUM SMALLINT, 
		@UNITE_PRICE DECIMAL
	 
	 DECLARE C_ITEMS CURSOR FOR
	 SELECT i.order_num, i.item_num, i.manu_code, i.quantity, i.stock_num, i.unit_price FROM inserted i

	 OPEN C_ITEMS
	 FETCH NEXT FROM C_ITEMS INTO @ORDER_NUM, @ITEM_NUM, @MANU_CODE, @QUANTITY, @STOCK_NUM, @UNITE_PRICE
	 WHILE(@@FETCH_STATUS = 0)
	 BEGIN

		IF((SELECT c.state FROM orders o
			JOIN customer c ON c.customer_num = o.customer_num
			WHERE order_num = @ORDER_NUM) = 'CA') 
			BEGIN
				IF((SELECT COUNT(i.order_num) FROM items i WHERE i.order_num = @ORDER_NUM) <= 5)
				BEGIN
					INSERT INTO items(order_num, item_num, manu_code, quantity, stock_num, unit_price)
					VALUES(@ORDER_NUM, @ITEM_NUM, @MANU_CODE, @QUANTITY, @STOCK_NUM, @UNITE_PRICE)
				END
				ELSE
				BEGIN
					INSERT INTO items_error(order_num, item_num, manu_code, quantity, stock_num, unite_price)
					VALUES(@ORDER_NUM, @ITEM_NUM, @MANU_CODE, @QUANTITY, @STOCK_NUM, @UNITE_PRICE, GETDATE())
				END
			END
	 END
END

-- EJ 2

CREATE VIEW ProdPorFabricante AS
SELECT m.manu_code, m.manu_name, COUNT(*) as cantProd
FROM manufact m 
INNER JOIN products p ON (m.manu_code = p.manu_code)
GROUP BY m.manu_code, m.manu_name;

CREATE TRIGGER insertProdFab
ON ProdPorFabricante
INSTEAD OF INSERT
AS
BEGIN
	
	DECLARE @MANU_CODE CHAR(3), @MANU_NAME VARCHAR(15)

	DECLARE C_INSERT CURSOR FOR
	SELECT i.manu_code, i.manu_name FROM inserted i

	OPEN C_INSERT
	FETCH NEXT FROM C_INSERT INTO @MANU_CODE, @MANU_NAME
	WHILE(@@FETCH_STATUS = 0)
	BEGIN

		INSERT INTO manufact(manu_code, manu_name, lead_time) 
		VALUES (@MANU_CODE, @MANU_NAME, 10)

		FETCH NEXT FROM C_INSERT INTO @MANU_CODE, @MANU_NAME

	END

	CLOSE C_INSERT
	DEALLOCATE C_INSERT	
	
END

-- EJ 3 Muy largo

CREATE TABLE customer_pend (
	[fecha_hora] [datetime] NOT NULL,
	[customer_num] [smallint] NOT NULL,
	[fname] [varchar](15) NULL,
	[lname] [varchar](15) NULL,
	[company] [varchar](20) NULL,
	[address1] [varchar](20) NULL,
	[address2] [varchar](20) NULL,
	[city] [varchar](15) NULL,
	[state] [char](2) NULL,
	[zipcode] [char](5) NULL,
	[phone] [varchar](18) NULL,
	[customer_num_referedBy] [smallint] NULL,
	[status] [char](1) NULL
)

CREATE TRIGGER TRIGGER3
ON customer
INSTEAD OF INSERT, UPDATE
AS
BEGIN

	DECLARE C_CUSTOMER CURSOR FOR
	SELECT i.customer_num FROM inserted i

END

-- EJ 4

CREATE VIEW ProdPorFabricanteDet 
AS
SELECT m.manu_code, m.manu_name, pt.stock_num, pt.description
FROM manufact m LEFT OUTER JOIN products p ON m.manu_code = p.manu_code
LEFT OUTER JOIN product_types pt ON p.stock_num = pt.stock_num;

CREATE TRIGGER eliminacionProdFab
ON ProdPorFabricanteDet
INSTEAD OF DELETE
AS
BEGIN
	
	DELETE FROM manufact WHERE manu_code IN (SELECT manu_code FROM deleted where description IS NULL)
END

-- EJ 5

CREATE VIEW ordenesPendientes AS
SELECT c.customer_num, c.fname, c.lname, c.company, o.order_num, o.order_date FROM customer c
JOIN orders o ON o.customer_num = c.customer_num WHERE o.paid_date IS NULL


CREATE TRIGGER EJE55 
ON ordenesPendientes
INSTEAD OF DELETE
AS
BEGIN

	DECLARE @CANT_DELET INTEGER, @CANT_ITEMS INTEGER

	SELECT @CANT_ITEMS = COUNT(i.item_num) FROM items i JOIN deleted d ON d.order_num = i.order_num
	SELECT @CANT_DELET = COUNT(d.order_num) FROM deleted d

	IF(@CANT_ITEMS > 1)
	BEGIN
		RAISERROR('No se puede eliminar orden con mas de 1 item', 16, 1)
	END

	IF(@CANT_DELET = 1)
	BEGIN
		RAISERROR('El cliente tiene solo 1 orden pendiente', 16, 1)
	END

	DELETE FROM items WHERE order_num = (SELECT order_num FROM deleted)
	DELETE FROM orders WHERE order_num = (SELECT order_num FROM deleted)

END