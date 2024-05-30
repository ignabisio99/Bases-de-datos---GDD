-- EJ 1

DROP TABLE CustomerStatistics

CREATE TABLE CustomerStatistics(
		customer_num INTEGER PRIMARY KEY,
		ordersqty INTEGER,
		maxdate DATE,
		uniqueProducts INTEGER
		)

ALTER PROCEDURE actualizarEstadisticas(@customer_numDES INTEGER, @customer_numHAS INTEGER)
AS
BEGIN
	
	DECLARE @CUSTOMER_NUM INTEGER
	DECLARE @ORDERSQTY INTEGER
	DECLARE @MAXDATE DATE
	DECLARE @UNIQUEPRODUCTS INTEGER

	DECLARE C_CUSTOMER CURSOR FOR
	SELECT c.customer_num FROM Customer c
	WHERE c.customer_num BETWEEN @customer_numDES AND @customer_numHAS

	OPEN C_CUSTOMER
	FETCH NEXT FROM C_CUSTOMER INTO @CUSTOMER_NUM
	WHILE(@@FETCH_STATUS = 0)
	BEGIN
		SET @ORDERSQTY = (SELECT COUNT(DISTINCT o.order_num) FROM orders o
								WHERE o.customer_num = @CUSTOMER_NUM)
		SET @MAXDATE = (SELECT TOP 1 o.order_date FROM orders o
							WHERE o.customer_num = @CUSTOMER_NUM
							ORDER BY o.order_date DESC)
		SET @UNIQUEPRODUCTS = (SELECT COUNT(DISTINCT i.stock_num) FROM items i
									JOIN orders o ON o.order_num = i.order_num
									WHERE o.customer_num = @CUSTOMER_NUM)

		IF (@CUSTOMER_NUM NOT IN (SELECT customer_num FROM CustomerStatistics))
		BEGIN
			INSERT INTO CustomerStatistics(customer_num, ordersqty, maxdate, uniqueProducts)
			VALUES(@CUSTOMER_NUM, @ORDERSQTY, @MAXDATE, @UNIQUEPRODUCTS)
		END
		ELSE
		BEGIN
			UPDATE CustomerStatistics
			SET ordersqty = @ORDERSQTY,
				maxdate = @MAXDATE,
				uniqueProducts = @UNIQUEPRODUCTS
		END
		FETCH NEXT FROM C_CUSTOMER INTO @CUSTOMER_NUM
	END
	CLOSE C_CUSTOMER
	DEALLOCATE C_CUSTOMER
END

SELECT * FROM CustomerStatistics

execute actualizarEstadisticas 101,110

-- EJ 2

DROP TABLE clientesCalifornia
DROP TABLE clientesNoCaBaja
DROP TABLE clientesNoCAAlta

CREATE TABLE clientesCalifornia(
		customer_num smallint NOT NULL,
		fname varchar(15),
		lname varchar(15),
		company varchar(20),
		address1 varchar(20),
		address2 varchar(20),
		city varchar(15) ,
		state char(2) ,
		zipcode char(5),
		phone varchar(18)
		)

CREATE TABLE clientesNoCaBaja(
		customer_num smallint NOT NULL,
		fname varchar(15),
		lname varchar(15),
		company varchar(20),
		address1 varchar(20),
		address2 varchar(20),
		city varchar(15) ,
		state char(2) ,
		zipcode char(5),
		phone varchar(18)
		)

CREATE TABLE clientesNoCAAlta(
		customer_num smallint NOT NULL,
		fname varchar(15),
		lname varchar(15),
		company varchar(20),
		address1 varchar(20),
		address2 varchar(20),
		city varchar(15) ,
		state char(2) ,
		zipcode char(5),
		phone varchar(18)
		)

CREATE PROCEDURE migraClientes (@customer_numDES INTEGER, @customer_numHAS INTEGER)
AS
BEGIN
    DECLARE @CUSTOMER_NUM smallint, @FNAME VARCHAR(15), @LNAME VARCHAR(15), @COMPANY VARCHAR(20), @ADD1 VARCHAR(20),
            @ADD2 VARCHAR(20), @CITY VARCHAR(15), @STATE CHAR(2), @ZIP CHAR(5), @PHONE VARCHAR(18);

    DECLARE @errorDescripcion VARCHAR(100);

    BEGIN TRY
        DECLARE C_CLIENTES CURSOR FOR
        SELECT customer_num, fname, lname, company, address1, address2, city, state, zipcode, phone 
        FROM customer
        WHERE customer_num BETWEEN @customer_numDES AND @customer_numHAS;

        OPEN C_CLIENTES;

        FETCH NEXT FROM C_CLIENTES INTO @CUSTOMER_NUM, @FNAME, @LNAME, @COMPANY, @ADD1, @ADD2, @CITY, @STATE, @ZIP, @PHONE;
        WHILE (@@FETCH_STATUS = 0)
        BEGIN
            IF (SELECT c.state FROM customer c WHERE c.customer_num = @CUSTOMER_NUM) = 'CA'
            BEGIN
                INSERT INTO clientesCalifornia(customer_num, fname, lname, company, address1, address2, city, state, zipcode, phone)
                VALUES (@CUSTOMER_NUM, @FNAME, @LNAME, @COMPANY, @ADD1, @ADD2, @CITY, @STATE, @ZIP, @PHONE);
            END
            ELSE
            BEGIN
                IF (SELECT SUM(i.quantity * i.unit_price) 
                    FROM items i
                    JOIN orders o ON o.order_num = i.order_num
                    WHERE o.customer_num = @CUSTOMER_NUM) > 999
                BEGIN
                    INSERT INTO clientesNoCAAlta(customer_num, fname, lname, company, address1, address2, city, state, zipcode, phone)
                    VALUES (@CUSTOMER_NUM, @FNAME, @LNAME, @COMPANY, @ADD1, @ADD2, @CITY, @STATE, @ZIP, @PHONE);
                END
                ELSE
                BEGIN
                    INSERT INTO clientesNoCaBaja(customer_num, fname, lname, company, address1, address2, city, state, zipcode, phone)
                    VALUES (@CUSTOMER_NUM, @FNAME, @LNAME, @COMPANY, @ADD1, @ADD2, @CITY, @STATE, @ZIP, @PHONE);
                END
            END

            UPDATE customer SET status = 'P' WHERE customer_num = @CUSTOMER_NUM;

            FETCH NEXT FROM C_CLIENTES INTO @CUSTOMER_NUM, @FNAME, @LNAME, @COMPANY, @ADD1, @ADD2, @CITY, @STATE, @ZIP, @PHONE;
        END

        CLOSE C_CLIENTES;
        DEALLOCATE C_CLIENTES;
    END TRY
    BEGIN CATCH
        IF CURSOR_STATUS('global', 'C_CLIENTES') >= -1
        BEGIN
            CLOSE C_CLIENTES;
            DEALLOCATE C_CLIENTES;
        END

        ROLLBACK TRANSACTION;

        SET @errorDescripcion = 'Error en Cliente ' + CAST(@CUSTOMER_NUM AS CHAR(5));
        THROW 50000, @errorDescripcion, 1;
    END CATCH
END;

SELECT * FROM clientesCalifornia 
select * from customer

exec migraClientes 100,126

-- EJ 3

CREATE TABLE listaPreciosMayor(
	stock_num SMALLINT NOT NULL,
	manu_code CHAR(3) NOT NULL,
	unite_price DECIMAL(6,2),
	unite_code SMALLINT,
	status CHAR(1)
	)
CREATE TABLE listaPreciosMenor(
	stock_num SMALLINT NOT NULL,
	manu_code CHAR(3) NOT NULL,
	unite_price DECIMAL(6,2),
	unite_code SMALLINT,
	status CHAR(1)
	)


CREATE PROCEDURE actualizarPrecios (@manu_codeDES CHAR(3), @manu_codeHAS CHAR(3), @porcActualizacion DECIMAL(5,3))
AS
BEGIN

	DECLARE @MANU_CODE CHAR(3), @STOCK_NUM SMALLINT, @UNITE_PRICE DECIMAL(6,2), @UNITE_CODE SMALLINT, @STATUS CHAR(1)
	DECLARE @errorDescripcion VARCHAR(100)
	
	DECLARE C_PRODUCTOS CURSOR FOR
	SELECT manu_code, stock_num, unit_price, unit_code, status FROM products 
	WHERE manu_code BETWEEN @manu_codeDES AND @manu_codeHAS

	BEGIN TRY
	OPEN C_PRODUCTOS
	FETCH NEXT FROM C_PRODUCTOS INTO @MANU_CODE, @STOCK_NUM, @UNITE_PRICE, @UNITE_CODE, @STATUS
	WHILE(@@FETCH_STATUS = 0)
	BEGIN
		IF (SELECT SUM(i.quantity) FROM items i
		WHERE i.manu_code = @MANU_CODE and i.stock_num = @STOCK_NUM) >= 500
		BEGIN
			INSERT INTO listaPreciosMayor 
			VALUES (@STOCK_NUM, @MANU_CODE, @UNITE_PRICE * @porcActualizacion * 0.80, @UNITE_CODE, @STATUS)
		END
		ELSE
		BEGIN
			INSERT INTO listaPreciosMenor 
			VALUES (@STOCK_NUM, @MANU_CODE, @UNITE_PRICE * @porcActualizacion, @UNITE_CODE, @STATUS)
		END

		UPDATE products SET status = 'A' WHERE manu_code = @MANU_CODE AND stock_num = @STOCK_NUM

		FETCH NEXT FROM C_PRODUCTOS INTO @MANU_CODE, @STOCK_NUM, @UNITE_PRICE, @UNITE_CODE, @STATUS
	END

	CLOSE C_PRODUCTOS
	DEALLOCATE C_PRODUCTOS

	END TRY
    BEGIN CATCH
        IF CURSOR_STATUS('global', 'C_PRODUCTOS') >= -1
        BEGIN
            CLOSE C_PRODUCTOS;
            DEALLOCATE C_PRODUCTOS;
        END

        ROLLBACK TRANSACTION;

        SET @errorDescripcion = 'Error en producto ' + CAST(@MANU_CODE AS CHAR(3));
        THROW 50000, @errorDescripcion, 1;
    END CATCH
END

exec actualizarPrecios 'HRO','HRO',0.10
select * from listaPreciosMenor