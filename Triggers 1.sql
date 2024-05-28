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
END

-- EJ 2

CREATE TRIGGER borradosProductos
ON Products_Historia_Precios
AFTER DELETE
AS
BEGIN
	UPDATE Products_Historia_Precios SET state = 'I' WHERE stock_historia_id = (SELECT d.stock_historia_id FROM deleted d)
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
		ROLLBACK TRANSACTION
		RETURN
	END
END

-- EJ 4

CREATE TRIGGER borradoORders
ON orders
AFTER DELETE
AS
BEGIN
	
	

END

-- EJ 5

CREATE TRIGGER detectorManuCode
ON items
AFTER INSERT
AS
BEGIN

	IF ( (SELECT i.manu_code FROM inserted i) NOT IN (SELECT manu_code FROM manufact))
	BEGIN
		INSERT INTO manufact
		SELECT i.manu_code, 'Manu Orden ' + i.order_num, 1 FROM inserted i
		WHERE i.manu_code NOT IN (SELECT manu_code FROM manufact)
	END
	
	
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
	
	INSERT INTO Products_replica
	SELECT i.stock_num, i.manu_code, i.unit_price, i.unit_code, i.status FROM inserted i
	WHERE i.stock_num + i.manu_code NOT IN (SELECT stock_num+manu_code FROM Products_replica)

END

CREATE TRIGGER updateProducto
ON products
AFTER UPDATE	
AS
BEGIN
	
	UPDATE Products_replica
	SELECT i.stock_num, i.manu_code, i.unit_price, i.unit_code, i.status FROM inserted i
	WHERE i.stock_num + i.manu_code NOT IN (SELECT stock_num+manu_code FROM Products_replica)

END

CREATE TRIGGER updateProducto
ON products
AFTER DELETE	
AS
BEGIN
	
	INSERT INTO Products_replica
	SELECT i.stock_num, i.manu_code, i.unit_price, i.unit_code, i.status FROM deleted i
	WHERE i.stock_num + i.manu_code NOT IN (SELECT stock_num+manu_code FROM Products_replica)

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

----- PRACTICA TRIGGERS 2

-- EJ 2

CREATE VIEW ProdPorFabricante AS
SELECT m.manu_code, m.manu_name, COUNT(*) as cantProd
FROM manufact m 
INNER JOIN products p ON (m.manu_code = p.manu_code)
GROUP BY m.manu_code, m.manu_name;

CREATE TRIGGER insertProdFab
ON ProdPorFabricante
AFTER INSERT
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

-- EJ 4

CREATE VIEW ProdPorFabricanteDet 
AS
SELECT m.manu_code, m.manu_name, pt.stock_num, pt.description
FROM manufact m LEFT OUTER JOIN products p ON m.manu_code = p.manu_code
LEFT OUTER JOIN product_types pt ON p.stock_num = pt.stock_num;

CREATE TRIGGER eliminacionProdFab
ON ProdPorFabricanteDet
AFTER DELETE
AS
BEGIN
	
	DELETE FROM manufact WHERE manu_code IN (SELECT m.manu_code FROM product_types pt
											JOIN products p ON p.stock_num = pt.stock_num
											JOIN manufact m ON m.manu_code = p.manu_code
											WHERE pt.description = NULL) AND manu_code = (SELECT d.manu_code FROM deleted d)

END
