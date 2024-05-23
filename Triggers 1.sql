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