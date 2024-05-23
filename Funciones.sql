-- Ej 1

CREATE FUNCTION nombreDelDia (@FECHA DATETIME, @IDIOMA VARCHAR(20))
RETURNS VARCHAR(20)
AS
BEGIN
	DECLARE @DIA INTEGER
	DECLARE @NOMBREDIA VARCHAR(20)

	SET @DIA = datepart(weekday,@FECHA)

	IF @IDIOMA = 'ingles'
	BEGIN
		SET @NOMBREDIA = CASE
							WHEN @DIA = 1 THEN 'Sunday'
							WHEN @DIA = 2 THEN 'Monday'
							WHEN @DIA = 3 THEN 'Tuesday'
							WHEN @DIA = 4 THEN 'Wednesday'
							WHEN @DIA = 5 THEN 'Thursday'
							WHEN @DIA = 6 THEN 'Friday'
							WHEN @DIA = 7 THEN 'Saturday'
						  END
	END
	ELSE
	BEGIN
		SET @NOMBREDIA = CASE
							WHEN @DIA = 1 THEN 'Domingo'
							WHEN @DIA = 2 THEN 'Lunes'
							WHEN @DIA = 3 THEN 'Martes'
							WHEN @DIA = 4 THEN 'Miercoles'
							WHEN @DIA = 5 THEN 'Jueves'
							WHEN @DIA = 6 THEN 'Viernes'
							WHEN @DIA = 7 THEN 'Sabado'
						  END
	END

RETURN @NOMBREDIA
END


SELECT o.order_num, o.order_date,
	CASE
		WHEN c.state = 'CA' THEN dbo.nombreDelDia(DAY(o.order_date), 'ingles')
		WHEN c.state != 'CA' THEN dbo.nombreDelDia(DAY(o.order_date), 'español')
	END
FROM orders o
JOIN customer c ON c.customer_num = o.customer_num
WHERE o.paid_date IS NULL


-- EJ 2

CREATE FUNCTION mayorShipCharge(@ORDEN SMALLINT, @NUMEROCLIE SMALLINT)
RETURNS VARCHAR(100)
AS
BEGIN
	
	DECLARE @FECHAYMONTO VARCHAR(100)
	DECLARE @MES VARCHAR(4)
	DECLARE @MONTO VARCHAR(50)

	IF @ORDEN = 1
	BEGIN
		SELECT TOP 1 @MES = MONTH(o.order_date), @MONTO = o.ship_charge FROM orders o
		WHERE o.customer_num = @NUMEROCLIE
		ORDER BY o.ship_charge DESC
	END
	ELSE
	BEGIN
		SELECT TOP 1 @MES = MONTH(o.order_date), @MONTO = o.ship_charge FROM orders o
		WHERE o.customer_num = @NUMEROCLIE AND o.ship_charge != 
					(SELECT TOP 1 o1.ship_charge FROM orders o1
					WHERE o1.customer_num = @NUMEROCLIE
					ORDER BY o1.ship_charge)
		ORDER BY o.ship_charge DESC
	END

	SET @FECHAYMONTO = @MES + ' Total: ' + @MONTO

RETURN @FECHAYMONTO
END

SELECT o.customer_num, dbo.mayorShipCharge(1,o.customer_num) AS MayorCargo, dbo.mayorShipCharge(2,o.customer_num) AS SegundoMayorCargo
FROM orders o
JOIN orders o2 ON o2.customer_num = o.customer_num
WHERE o.order_num != o2.order_num AND MONTH(o.order_date) != MONTH(o2.order_date)


-- EJ 3

CREATE FUNCTION dbo.nombresFabricantes(@NRO_PRODUCTO smallint)
RETURNS VARCHAR(100)
AS
BEGIN

	DECLARE @NOMBRES_FAB VARCHAR(100)
	DECLARE @FAB VARCHAR(3)
	DECLARE C_FAB CURSOR FOR
			SELECT manu_code FROM catalog
			WHERE @NRO_PRODUCTO = stock_num;

	SET @NOMBRES_FAB = ''
	OPEN C_FAB
	FETCH NEXT FROM C_FAB INTO @FAB
	WHILE(@@FETCH_STATUS =0)
	BEGIN
		 IF(@NOMBRES_FAB = '')
			BEGIN
				SET @NOMBRES_FAB = @FAB
			END
		 ELSE
			BEGIN
				SET @NOMBRES_FAB = @NOMBRES_FAB + ' | ' + @FAB
			END
		
		FETCH NEXT FROM C_FAB INTO @FAB
	END

	CLOSE C_FAB
	DEALLOCATE C_FAB

RETURN @NOMBRES_FAB
END


SELECT DISTINCT p.stock_num, dbo.nombresFabricantes(p.stock_num) AS Fabricantes
FROM products p
WHERE p.stock_num IN (SELECT c.stock_num FROM catalog c)