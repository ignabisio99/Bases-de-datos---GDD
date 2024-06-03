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
