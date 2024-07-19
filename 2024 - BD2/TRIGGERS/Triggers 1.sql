-- Ejercicio 1

DROP TABLE products_historia_precios

CREATE TABLE Products_Historia_Precios(
	stock_historia_id INTEGER IDENTITY(1,1) PRIMARY KEY,
	stock_num SMALLINT,
	manu_code CHAR(3),
	fechaHora DATETIME,
	usuario NVARCHAR(255),
	unite_price_old DECIMAL(6,2),
	unite_price_new DECIMAL(6,2),
	state CHAR(1) DEFAULT 'A' CHECK(state IN ('A','I'))
)

CREATE TRIGGER verificarEstado
ON products
AFTER UPDATE
AS
BEGIN
	INSERT INTO Products_Historia_Precios
	SELECT d.stock_num, d.manu_code, GETDATE(),SUSER_NAME(), d.unit_price, i.unit_price, 'I' FROM deleted d
	JOIN inserted i ON i.manu_code = d.manu_code AND i.stock_num = d.stock_num
	WHERE i.unit_price != d.unit_price
END

-- EJ 2

CREATE TRIGGER borradosProductos
ON Products_Historia_Precios
INSTEAD OF DELETE
AS
BEGIN
	UPDATE Products_Historia_Precios SET state = 'I' WHERE stock_historia_id IN (SELECT d.stock_historia_id FROM deleted d)
END

-- EJ 3

CREATE TRIGGER validarInsertado
ON products
INSTEAD OF INSERT
AS
BEGIN
	DECLARE @HORAACTUAL TIME = CONVERT(TIME, GETDATE());

	IF (@HORAACTUAL BETWEEN '08:00:00' AND '20:00:00')
	BEGIN
		INSERT INTO products(stock_num, manu_code, unit_price, unit_code, status)
		SELECT i.stock_num, i.manu_code, i.unit_code, i.unit_price, i.status FROM inserted i
	END
	ELSE
	BEGIN
		RAISERROR('No es un horario apto para hacer inserts',16,1)
	END
END

-- EJ 4

CREATE TRIGGER borradoEnOrders
ON orders
INSTEAD OF DELETE
AS
BEGIN

	DECLARE @ORDER_NUM SMALLINT

	IF((SELECT COUNT(*) FROM deleted) > 1)
	BEGIN
		RAISERROR('No se puede eliminar mas de 1 orden a la vez',16,1)
	END
	ELSE
	BEGIN
		SELECT @ORDER_NUM = order_num FROM deleted

		DELETE FROM items WHERE order_num = @ORDER_NUM
		DELETE FROM orders WHERE order_num = @ORDER_NUM
	END
END


-- EJ 5

CREATE TRIGGER codigoEnItems
ON items
INSTEAD OF INSERT
AS
BEGIN
	
	DECLARE @ORDER_NUM SMALLINT, @MANU_CODE CHAR(3)

	DECLARE C_ITEMS CURSOR FOR
	SELECT i.order_num, i.manu_code FROM inserted i

	OPEN C_ITEMS
	FETCH NEXT FROM C_ITEMS INTO @ORDER_NUM, @MANU_CODE
	WHILE(@@FETCH_STATUS = 0)
	BEGIN
		IF(@MANU_CODE NOT IN (SELECT manu_code FROM manufact))
		BEGIN
			INSERT INTO manufact(manu_code, manu_name, lead_time)
			VALUES(@MANU_CODE,'Manu Orden ' + @ORDER_NUM,1)
		END
		FETCH NEXT FROM C_ITEMS INTO @ORDER_NUM, @MANU_CODE
	END
	
	CLOSE C_ITEMS
	DEALLOCATE C_ITEMS

	INSERT INTO items(item_num, order_num, manu_code, stock_num, quantity, unit_price)
		SELECT i.item_num, i.order_num, i.manu_code, i.stock_num, i.quantity, i.unit_price FROM inserted i
END


-- EJ 6

DROP TABLE Products_replica

CREATE TABLE Products_replica(
	stock_num SMALLINT REFERENCES product_types,
	manu_code CHAR(3) REFERENCES manufact,
	unite_price DECIMAL(6,2),
	unite_code SMALLINT REFERENCES units,
	status CHAR(1),
	PRIMARY KEY (stock_num,manu_code)
	)

CREATE TRIGGER insertProducto
ON products
AFTER INSERT	
AS
BEGIN
	
	INSERT INTO Products_replica(stock_num,manu_code,unite_price, unite_code)
	SELECT i.stock_num, i.manu_code, i.unit_price, i.unit_code, i.status FROM inserted i

END

CREATE TRIGGER updateProducto
ON products
AFTER UPDATE	
AS
BEGIN
	
	DECLARE @MANU_CODE CHAR(3), @STOCK_NUM SMALLINT, @UNITE_CODE SMALLINT, @UNITE_PRICE DECIMAL

	DECLARE C_INSERT CURSOR FOR
	SELECT i.manu_code, i.stock_num, i.unit_code, i.unit_price FROM inserted i

	OPEN C_INSERT
	FETCH NEXT FROM C_INSERT INTO @MANU_CODE, @STOCK_NUM, @UNITE_CODE, @UNITE_PRICE
	WHILE(@@FETCH_STATUS = 0)
	BEGIN
		UPDATE Products_replica SET unite_code = @UNITE_CODE, unite_price = @UNITE_PRICE 
			WHERE manu_code = @MANU_CODE AND stock_num = @STOCK_NUM
	END

	CLOSE C_INSERT
	DEALLOCATE C_INSERT					

END

CREATE TRIGGER deleteProducto
ON products
AFTER DELETE	
AS
BEGIN
	
	DELETE d FROM Products_replica d
	JOIN deleted de ON (d.stock_num = de.stock_num AND d.manu_code = de.manu_code)

END

-- EJ 7

CREATE VIEW Productos_x_fabricante(
	stock_num, description, manu_code, manu_name, unite_price)
AS
SELECT pt.stock_num, pt.description, m.manu_code, m.manu_name, p.unit_price FROM product_types pt
JOIN products p ON p.stock_num = pt.stock_num
JOIN manufact m ON m.manu_code = p.manu_code

CREATE TRIGGER insertsDeProducts
ON Productos_x_fabricante
INSTEAD OF INSERT
AS
BEGIN

	INSERT INTO products
	SELECT i.stock_num, i.manu_code, i.unite_price FROM inserted i

	IF ((SELECT i.manu_code FROM inserted i) NOT IN (SELECT manu_code FROM manufact))
	BEGIN
		INSERT INTO manufact
		SELECT i.manu_code, i.manu_name, 1 FROM inserted i
		WHERE i.manu_code NOT IN (SELECT manu_code FROM manufact)
	END

END
