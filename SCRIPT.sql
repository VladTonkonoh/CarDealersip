USE TermPaper

-- 1.Запит для перегляду наявних автомобілей
SELECT m.Name as Name, Body, Color, Kilometrage, Cost, Guarantee, Additional, en.Name AS Engine, en.FuelType AS FuelType, en.Power AS Power, FuelConsumption FROM Cars as c
INNER JOIN Equipments as e ON e.EquipmentId = c.EquipmentId
JOIN Models as m ON m.ModelId = e.ModelId
JOIN Engines as en ON en.EngineId = e.EngineId
WHERE c.State = 'Наявний';

-- 2.Запит для підрахунку суми отриманих бонусів Консультантом

SELECT Sum(Value) AS Amount, e.Name FROM EmployeeCompensations AS ec
INNER JOIN Employees AS e ON e.EmployeeId = ec.EmployeeId
GROUP BY ec.EmployeeId, e.Name;

-- 3.Запит для перегляду всіх можливих автомобілів для замовлення

SELECT p.Name AS ProdName, m.Name AS ModelName, Additional, en.Name AS Engine, en.FuelType AS FuelType, en.Power AS Power, FuelConsumption FROM Producers AS p
INNER JOIN Models AS m ON m.ProducerId = p.ProducerId
INNER JOIN Equipments AS eq ON eq.ModelId = m.ModelId
INNER JOIN Engines AS en ON en.EngineId = eq.EngineId

SELECT * FROM EmployeeCompensations

-- 4.Запит для перегляду всіх авто які були отримані від клієнтів

GO
CREATE OR ALTER FUNCTION GetCarInfo(@carId INT)
RETURNS TABLE 
RETURN 
	SELECT m.Name AS ModelName, Additional, en.Name AS Engine, en.FuelType AS FuelType, en.Power AS Power, FuelConsumption, c.Color, c.Cost, c.Kilometrage, c.State FROM  Models AS m
	INNER JOIN Equipments AS eq ON eq.ModelId = m.ModelId
	INNER JOIN Engines AS en ON en.EngineId = eq.EngineId
	INNER JOIN Cars AS c ON c.EquipmentId = eq.EquipmentId
	WHERE c.CarId = @carId
GO

DECLARE CarFromClientCursor CURSOR FOR
SELECT DISTINCT(cc.CarId) FROM Cars
INNER JOIN CarFromTheClient AS cc ON Cars.CarId = cc.CarId

DECLARE @carId INT
OPEN CarFromClientCursor

FETCH NEXT FROM CarFromClientCursor INTO @carId
WHILE @@FETCH_STATUS = 0
BEGIN 
	SELECT * FROM GetCarInfo(@carId)
	FETCH NEXT FROM CarFromClientCursor INTO @carId
END

CLOSE CarFromClientCursor

-- 5.Всі Операції зараєстрованих в системі клієнтів

SELECT cl.ClientId, cl.Name, COUNT(DISTINCT(cc.ClientId)) AS TradeIns, COUNT(DISTINCT(co.ClientId)) AS Orders, COUNT(DISTINCT(gc.ClientId)) AS GuaranteeCases, COUNT(DISTINCT(s.ClientId)) AS Boughts FROM Clients AS cl
LEFT JOIN CarFromTheClient AS cc ON cl.ClientId = cc.ClientId
LEFT JOIN CustomerOrders AS co ON cl.ClientId = co.ClientId
LEFT JOIN GuaranteeCases AS gc ON cl.ClientId = gc.ClientId
LEFT JOIN Sales AS s ON cl.ClientId = s.ClientId
GROUP BY cl.ClientId, cl.Name;

-- 6.Запит для перегляду всіх авто які мали гарантійні випадки

SELECT Cars.CarId FROM Cars 
INNER JOIN GuaranteeCases AS gc ON Cars.CarId = gc.CarId
Group BY Cars.CarId

-- 7.Запит для перегляду всіх Замовлених авто

DECLARE OrderedCarsCursor CURSOR FOR
SELECT DISTINCT(co.CarId) FROM Cars
INNER JOIN CustomerOrders AS co ON Cars.CarId = co.CarId


DECLARE @carId1 INT
OPEN OrderedCarsCursor

FETCH NEXT FROM OrderedCarsCursor INTO @carId1
WHILE @@FETCH_STATUS = 0
BEGIN 
	SELECT * FROM GetCarInfo(@carId1)
	FETCH NEXT FROM OrderedCarsCursor INTO @carId1
END

CLOSE OrderedCarsCursor;

-- 8.Запит для підрахунку здійснених продаж Консультантом

SELECT e.Name, COUNT(ec.EmployeeId) AS SalesNumber FROM EmployeeCompensations AS ec
RIGHT JOIN Employees AS e ON ec.EmployeeId = e.EmployeeId 
WHERE e.Position = 'Консультант'
GROUP BY ec.EmployeeId, e.Name

-- 9.Запит для перегляду всіх проданих авто

SELECT c.CarId, c.Cost FROM Sales AS s
INNER JOIN Cars AS c ON s.CarId = c.CarId 

-- 10.Запит Для перегляду загальної суми проданих авто

SELECT Sum(c.Cost) AS TotalCost FROM Sales AS s
INNER JOIN Cars AS c ON s.CarId = c.CarId 


-- 11.Запит для перегляду націнки на авто від клієнта

SELECT Clients.Name AS ClientName, c.Cost - cc.PurchasePrice AS PriceDifference,  c.CarId FROM CarFromTheClient AS cc
INNER JOIN Cars AS c ON cc.CarId = c.CarId
INNER JOIN Clients ON cc.ClientId = Clients.ClientId

-- 12.Запит для перегляду заробітку автосалону від трейд-іну

SELECT SUM(c.Cost - cc.PurchasePrice) AS Earning FROM CarFromTheClient AS cc
INNER JOIN Cars AS c ON cc.CarId = c.CarId
INNER JOIN Clients ON cc.ClientId = Clients.ClientId
WHERE c.State = 'Продано';

-- 13.Запит для виведення авто проданих за місяць до поточної дати

SELECT * FROM Sales 
INNER JOIN Cars ON Sales.CarId = Cars.CarId
WHERE DATEDIFF(MONTH, Sales.SalesDate, CURRENT_TIMESTAMP) < 2

-- 14.Запит для списку отриманих від клієнта коштів

SELECT c.Name, SUM(Cars.Cost)AS Sum FROM Sales AS s
INNER JOIN Clients AS c ON s.ClientId = c.ClientId
INNER JOIN Cars ON Cars.CarId = s.CarId
GROUP BY  c.Name, c.ClientId
UNION
SELECT c.Name, 0 FROM Clients AS c
WHERE c.ClientId NOT IN (SELECT ClientId FROM Sales)
ORDER BY Sum DESC

-- 15.Запит для перегляду всіх гарантійних випадків

SELECT c.Name, gc.Status, gc.Description FROM GuaranteeCases AS gc
LEFT JOIN Clients AS c ON c.ClientId = gc.ClientId;

-- 16.Запит для переглядуВсіх моделей авто які пропонує постачальник

SELECT p.Name, m.Name FROM Models AS m
JOIN Producers AS p ON m.ProducerId = p.ProducerId
ORDER BY p.Name

-- 17.Запит для визначення кількості гарантійних випадків у моделі і порівняння їх з кількістю продажів

SELECT m.Name, m.ModelId, COUNT(gc.GuaranteeCaseId) AS GuaranteeCases, COUNT(s.SaleId) AS SalesCount, CAST(CAST(COUNT(gc.GuaranteeCaseId) AS float) / COUNT(s.SaleId) * 100 AS nvarchar)  + '%' AS Percents FROM Cars AS c
RIGHT JOIN Sales AS s ON s.CarId = c.CarId
LEFT JOIN GuaranteeCases AS gc ON gc.CarId = c.CarId
INNER JOIN Equipments AS e ON e.EquipmentId = c.EquipmentId
INNER JOIN Models AS m ON m.ModelId = e.ModelId
GROUP BY m.ModelId, m.Name

-- 18.Запит для виявлення найпопулярнішого двигуна

SELECT eq.EngineId, en.Name, COUNT(c.CarId) AS Count FROM Cars AS c
JOIN Equipments AS eq ON eq.EquipmentId = c.EquipmentId
JOIN Engines AS en ON en.EngineId = eq.EngineId
GROUP BY eq.EngineId, en.Name
ORDER BY COUNT(c.CarId) DESC

-- 19.Запит для виявлення найпопулярнішої комплектації

SELECT c.EquipmentId, eq.Additional, COUNT(c.CarId) AS Count FROM Cars AS c
JOIN Equipments AS eq ON eq.EquipmentId = c.EquipmentId
GROUP BY c.EquipmentId, eq.Additional
ORDER BY COUNT(c.CarId) DESC

-- 20.Запит для виявлення найпопулярнішої моделі

SELECT eq.ModelId, m.Name, COUNT(c.CarId) AS Count FROM Cars AS c
JOIN Equipments AS eq ON eq.EquipmentId = c.EquipmentId
JOIN Models AS m ON m.ModelId = eq.ModelId
GROUP BY eq.ModelId, m.Name
ORDER BY COUNT(c.CarId) DESC
-- 21.Запит для виявлення найпопулярнішого пстачальника

SELECT m.ProducerId, p.Name, COUNT(c.CarId) AS Count FROM Cars AS c
JOIN Equipments AS eq ON eq.EquipmentId = c.EquipmentId
JOIN Models AS m ON m.ModelId = eq.ModelId
JOIN Producers AS p ON p.ProducerId = m.ProducerId
GROUP BY m.ProducerId, p.Name
ORDER BY COUNT(c.CarId) DESC

--Функція для Відображення наявних автомобілів, певної комплектації
GO
CREATE FUNCTION GetAvailableCars(@EquipmentId INT)
RETURNS TABLE
RETURN 
	SELECT m.Name, Cost, Color, Guarantee, Kilometrage  FROM Cars AS c
	INNER JOIN Equipments AS e ON c.EquipmentId = e.EquipmentId
	INNER JOIN Models AS m ON m.ModelId = e.ModelId
	WHERE @EquipmentId = c.EquipmentId AND c.State = 'Наявний';
GO

SELECT * FROM GetAvailableCars(2)

-- Функція для виведення списку клієнтів котрі здійснили покупки бульше ніж...
GO
CREATE FUNCTION ClientsSalesMoreThan(@Count INT)
RETURNS TABLE
RETURN
	SELECT cl.ClientId, cl.Name, COUNT(DISTINCT(s.SaleId)) AS CountSales FROM Clients AS cl
	INNER JOIN Sales AS s ON cl.ClientId = s.ClientId
	GROUP BY cl.ClientId, cl.Name
	HAVING COUNT(DISTINCT(s.SaleId)) > @Count
GO
SELECT * FROM ClientsSalesMoreThan(1)

--Функція котра повертає розмір бонусів за продаж клієнту

GO
CREATE FUNCTION GetCompensationValue(@SaleId INT, @Course INT)
RETURNS INT
BEGIN
	DECLARE @CarCost INT;
	SELECT @CarCost = Cars.Cost FROM Sales INNER JOIN Cars ON Cars.CarId = Sales.CarId WHERE SaleId = @SaleId
	DECLARE @CompValue INT
	IF @CarCost * @Course * 0.05 > 7500
		SET @CompValue = 7500
	ELSE 
		SET @CompValue = @CarCost * @Course * 0.05
	RETURN @CompValue
END
GO

PRINT Term.dbo.GetCompensationValue(7, 37)

-- Процедура для виведення авто дешевше/потужніше ніж
GO
CREATE PROCEDURE GetFilteredCarsByPrice @Price INT, @More bit AS
	IF @More = 1
		SELECT * FROM Cars WHERE cars.Cost >= @Price AND Cars.State = 'Наявний'
	ELSE 
		SELECT * FROM Cars WHERE cars.Cost <= @Price AND Cars.State = 'Наявний'
GO
EXEC GetFilteredCarsByPrice 25000, 0;

GO

CREATE PROCEDURE GetFilteredCarsByPower @Power INT, @More bit AS
	IF @More = 1
		SELECT CarId, Color, Kilometrage, Price, Power FROM Cars 
		INNER JOIN Equipments ON Equipments.EquipmentId = Cars.EquipmentId
		INNER JOIN Engines ON Engines.EngineID = Equipments.EngineId
		WHERE Engines.Power >= @Power AND Cars.State = 'Наявний'
	ELSE 
		SELECT CarId, Color, Kilometrage, Price, Power FROM Cars 
		INNER JOIN Equipments ON Equipments.EquipmentId = Cars.EquipmentId
		INNER JOIN Engines ON Engines.EngineID = Equipments.EngineId
		WHERE Engines.Power <= @Power AND Cars.State = 'Наявний'
GO

EXEC GetFilteredCarsByPower 400, 0;

-- Процедура для створення нового замовлення
GO
CREATE PROCEDURE OrederCar(@EquipmentId INT, @Color NVARCHAR(255), @Amount INT, @ClientId INT) AS
BEGIN
	DECLARE @EquipmentCost INT;
	SELECT @EquipmentCost = Equipments.Price FROM Equipments WHERE EquipmentId = @EquipmentID;
	INSERT INTO Cars(EquipmentId,State,Color, Cost, Guarantee)
	VALUES
	(@EquipmentID,'Замовлено', @Color, CONVERT(INT, @EquipmentCost*1.05), 5);
	DECLARE @CarId INT;
	SELECT @CarId = CarId FROM Cars ORDER BY CarId DESC Offset 0 ROWS FETCH NEXT 1 ROWS ONLY ;
	INSERT INTO CustomerOrders(ClientId, CarId, Amount, State, OrderDate)
	VALUES
	(@ClientId, @CarId, @Amount,'Оброблюється', CURRENT_TIMESTAMP);
END
GO
SELECT * FROM CustomerOrders
SELECT * FROM Cars
EXEC OrederCar 2,'Blue', 1, 3

--Процедура для здійснення продажі 
GO
ALTER PROCEDURE MakeSale(@Employee INT, @CarId INT, @ClientId INT) AS
BEGIN
	IF @CarId NOT IN (SELECT CarId FROM Sales UNION SELECT CarId FROM Cars WHERE State = 'Замовлено' OR State = 'Продано')
	BEGIN
		INSERT INTO Sales(CarId, ClientId)
		VALUES
		(@CarId, @ClientId)

		DECLARE @Counter INT
		SELECT @Counter = SaleId FROM Sales ORDER BY Sales.SaleId DESC Offset 0 ROWS FETCH NEXT 1 ROWS ONLY 

		DECLARE @CompValue INT
		SELECT @CompValue = TermPaper.dbo.GetCompensationValue(SaleId,37) FROM Sales ORDER BY Sales.SaleId DESC Offset 0 ROWS FETCH NEXT 1 ROWS ONLY 

		INSERT INTO EmployeeCompensations(EmployeeId, SaleId, Value)
		VALUES
		(@Employee, @Counter, @CompValue)
	END
	ELSE
		PRINT 'This Car is already saled!'
END
GO


EXEC MakeSale 9,7,3

SELECT * FROM EmployeeCompensations
SELECT * FROM Cars
SELECT * FROM Sales
DELETE Sales WHERE SaleId = 12
UPDATE Cars SET State = 'Наявний' WHERE CarId = 3 
DECLARE @Cuorce INT
SET @Cuorce = 37
DECLARE @Co INT
		SET @Co = (SELECT Term.dbo.GetCompensationValue(SaleId,@Cuorce) FROM Sales ORDER BY Sales.SaleId DESC Offset 0 ROWS FETCH NEXT 1 ROWS ONLY )
PRINT Term.dbo.GetCompensationValue(7,1) -- @Co

DECLARE @Cuorce1 INT
SET @Cuorce1 = 37
SELECT TermPaper.dbo.GetCompensationValue(SaleId,1) AS CompVal FROM Sales ORDER BY Sales.SaleId DESC Offset 0 ROWS FETCH NEXT 1 ROWS ONLY

--Тригер при додаванні нової продажі
GO
CREATE TRIGGER Made_Sale
ON Sales
AFTER INSERT, UPDATE
AS
DECLARE @Count INT
SELECT @Count = COUNT(*) FROM inserted
DECLARE @Id INT 
DECLARE @CarID INT
DECLARE @Date DATETIME2
WHILE @Count > 0
BEGIN
	SELECT @Id = SaleId FROM inserted ORDER BY inserted.SaleId Offset @Count-1 ROWS FETCH NEXT 1 ROWS ONLY 
	SELECT @CarID = CarId FROM Sales WHERE SaleId = @Id
	SELECT @Date = SalesDate FROM Sales WHERE SaleId = @Id
	IF @Date > CURRENT_TIMESTAMP 
		BEGIN	
			PRINT 'Date has to be in the future!'
			DELETE Sales WHERE SaleId = @Id
			BREAK
		END
	IF @CarID IN (SELECT CarId FROM Sales WHERE SaleId <> @Id)
		BEGIN
		PRINT 'This car has already been saled'
		DELETE Sales WHERE SaleId = @Id
		END
	ELSE 
		BEGIN
		IF @Date IS NULL
			UPDATE Sales SET SalesDate = CURRENT_TIMESTAMP WHERE SaleId = (SELECT SaleId FROM inserted)
		UPDATE Cars SET State = 'Продано' WHERE CarId IN (SELECT CarId FROM inserted)
		END
	SET @Count = @Count - 1
END
GO

SELECT * FROM Sales

INSERT INTO Sales (CarId, ClientId, SalesDate) 
VALUES 
(3,4, DATEADD(HH,1,CURRENT_TIMESTAMP))

DELETE FROM Sales WHERE SaleId = 22

--Тригер при видаленні продажі
GO
ALTER TRIGGER Delete_Sale
ON Sales
INSTEAD OF DELETE
AS
BEGIN
	DECLARE @Count INT
	DECLARE @Id INT
	SELECT @Count = COUNT(*) FROM deleted
	DECLARE @CarId INT
	WHILE @Count > 0
	BEGIN
		SELECT @Id = SaleId FROM deleted ORDER BY deleted.SaleId Offset @Count-1 ROWS FETCH NEXT 1 ROWS ONLY 
		SELECT @CarId = CarId FROM Sales WHERE SaleId = @Id
		DELETE EmployeeCompensations WHERE SaleId = @Id
		DELETE Sales WHERE SaleId = @Id
		UPDATE Cars SET State = 'Наявний' WHERE CarId = @CarId
		SET @Count = @Count - 1
	END
END
GO
DELETE Sales WHERE SaleId = 15
SELECT * FROM EmployeeCompensations
SELECT * FROM Sales
SELECT * FROM Cars

--Тригер для зміни ціни автомобіля, коли комплектація подорожчала
GO
CREATE TRIGGER ChangeEquipmentPrice
ON Equipments
AFTER UPDATE AS
BEGIN
	IF(UPDATE(Price))
	BEGIN
		DECLARE @Count INT
		SELECT @Count = COUNT(*) FROM inserted
		DECLARE @NewPrice INT
		DECLARE @EquipmentId INT
		WHILE @Count > 0
			BEGIN
				SELECT @NewPrice = Price FROM inserted ORDER BY inserted.EquipmentId Offset @Count-1 ROWS FETCH NEXT 1 ROWS ONLY 
				SELECT @EquipmentId = EquipmentId FROM inserted ORDER BY inserted.EquipmentId Offset @Count-1 ROWS FETCH NEXT 1 ROWS ONLY
				UPDATE Cars SET Cost = CONVERT(INT, @NewPrice  * 1.05) WHERE EquipmentId = @EquipmentID AND State = 'Наявний' AND Kilometrage = 0;
				SET @Count = @Count - 1
			END
	END
END
GO
Update Equipments SET Price = 150000 WHERE EquipmentId = 7
Update Cars SET  Cost = 51000 WHERE EquipmentId = 2 AND State = 'Наявний' AND Kilometrage = 0;
Update Equipments SET  Additional = 'Панорамний дах' WHERE EquipmentId = 2
SELECT * FROM Cars
SELECT * FROM Equipments

--Тригер для встановлення дати при додаванні в таблицю CarFromTheClient
GO
CREATE TRIGGER SetCarFromTheClientDate
ON CarFromTheClient
AFTER INSERT, UPDATE AS
BEGIN
	DECLARE @Counter INT
	SELECT @Counter = COUNT(*) FROM inserted 
	DECLARE @Id INT
	DECLARE @Date DATETIME2
	DECLARE @CarId INT
	WHILE @Counter > 0
	BEGIN
		SELECT @Id = CarFromTheClientId FROM inserted ORDER BY inserted.CarFromTheClientId Offset @Counter-1 ROWS FETCH NEXT 1 ROWS ONLY 
		SELECT @Date = Date FROM CarFromTheClient WHERE @Id = CarFromTheClientId
		SELECT @CarId = CarId FROM CarFromTheClient WHERE @Id = CarFromTheClientId

		IF @Date IS NULL
			UPDATE CarFromTheClient SET Date = CURRENT_TIMESTAMP WHERE CarFromTheClientId = @Id
		ELSE
		BEGIN
			IF @Date > CURRENT_TIMESTAMP
			BEGIN
				DELETE CarFromTheClient WHERE CarFromTheClientId = @Id
				DELETE Cars WHERE CarId = @CarId
				PRINT 'Date has to be in the past'
			END
		END

		SET @Counter = @Counter - 1
	END
END
GO
SELECT * FROM CarFromTheClient
UPDATE CarFromTheClient SET Date = DATEADD(HH,1,CURRENT_TIMESTAMP) WHERE CarFromTheClientId = 1 


Select * from CarFromTheClient

--Триггер для додавання нового замовлення
GO
CREATE TRIGGER SetCustomerStateAndDate
ON CustomerOrders
AFTER INSERT AS
BEGIN
	DECLARE @Count INT
	SELECT @Count = COUNT(*) FROM inserted
	DECLARE @Date DATETIME2
	DECLARE @Id INT
	DECLARE @Amount INT
	DECLARE @State NVARCHAR(255)
	WHILE @Count > 0
	BEGIN
		SELECT @Id = CustomerOrderId FROM inserted ORDER BY inserted.CustomerOrderId Offset @Count-1 ROWS FETCH NEXT 1 ROWS ONLY 
		SELECT @Amount = Amount FROM CustomerOrders WHERE CustomerOrderId = @Id
		SELECT @Date = OrderDate FROM CustomerOrders WHERE CustomerOrderId = @Id
		SELECT @State = State FROM CustomerOrders WHERE CustomerOrderId = @Id
		IF @Amount > 0
		BEGIN
			SELECT @Date = OrderDate FROM CustomerOrders WHERE CustomerOrderId = @Id
			IF	@Date IS NULL
				UPDATE CustomerOrders SET OrderDate = CURRENT_TIMESTAMP WHERE CustomerOrderId = @Id
			ELSE IF @Date > CURRENT_TIMESTAMP
			BEGIN
				DELETE CustomerOrders WHERE CustomerOrderId = @Id
				PRINT 'Date has to be in the past'
			END
			IF @State IS NULL
				UPDATE CustomerOrders SET State = 'Оброблюється' WHERE CustomerOrderId = @Id
		END
		ELSE
		BEGIN
			PRINT 'Amount has to be more than 0!' 
			DELETE CustomerOrders WHERE CustomerOrderId = @Id
		END
		SET @Count = @Count - 1
	END
END
GO

UPDATE CustomerOrders Set CarId = 4 WHERE CustomerOrderId = 3
SELECT * FROM CustomerOrders

--Тригер для оновлення замовлення
GO
CREATE TRIGGER UpdateCustomerStateAndDate
ON CustomerOrders
AFTER UPDATE AS
BEGIN
	DECLARE @Count INT
	SELECT @Count = COUNT(*) FROM inserted
	DECLARE @Date DATETIME2
	DECLARE @Id INT
	DECLARE @Amount INT
	DECLARE @State NVARCHAR(255)
	DECLARE @OldDate DATETIME2
	DECLARE @OldAmount INT
	DECLARE @CarId INT
	WHILE @Count > 0
	BEGIN
		SELECT @Id = CustomerOrderId FROM inserted ORDER BY inserted.CustomerOrderId Offset @Count-1 ROWS FETCH NEXT 1 ROWS ONLY 
		SELECT @Amount = Amount FROM CustomerOrders WHERE CustomerOrderId = @Id
		SELECT @Date = OrderDate FROM CustomerOrders WHERE CustomerOrderId = @Id
		SELECT @State = State FROM CustomerOrders WHERE CustomerOrderId = @Id
		SELECT @OldDate = OrderDate FROM deleted WHERE CustomerOrderId = @Id
		SELECT @OldAmount = Amount FROM deleted WHERE CustomerOrderId = @Id
		SELECT @CarId = CarId FROM deleted WHERE CustomerOrderId = @Id
		IF UPDATE(CarId)
		BEGIN
			PRINT 'You can`t change carId!'
			UPDATE CustomerOrders SET CarId = @CarId WHERE CustomerOrderId = @Id
		END
		IF @Amount > 0
		BEGIN
			SELECT @Date = OrderDate FROM CustomerOrders WHERE CustomerOrderId = @Id
			IF	@Date > CURRENT_TIMESTAMP
				BEGIN
				PRINT 'Date has to be in the past'
				UPDATE CustomerOrders SET OrderDate = @OldDate WHERE CustomerOrderId = @Id
				END
			ELSE IF @Date IS NULL 
				UPDATE CustomerOrders SET OrderDate = CURRENT_TIMESTAMP WHERE CustomerOrderId = @Id
			IF @State IS NULL
				UPDATE CustomerOrders SET State = 'Оброблюється' WHERE CustomerOrderId = @Id
		END
		ELSE
		BEGIN
			PRINT 'Amount has to be more than 0!' 
			UPDATE CustomerOrders SET Amount = @OldAmount WHERE CustomerOrderId = @Id
		END
		SET @Count = @Count - 1
	END
END
GO

--Тригер при додаванні гарантійного випадку
CREATE TRIGGER SetGuaranteeCase
ON GuaranteeCases
AFTER INSERT,Update AS
BEGIN
	DECLARE @Count INT
	SELECT @Count = COUNT(*) FROM inserted
	DECLARE @Date DATETIME2
	DECLARE @Id INT
	WHILE @Count > 0
	BEGIN
		SELECT @Id = GuaranteeCaseId FROM inserted ORDER BY inserted.GuaranteeCaseId Offset @Count-1 ROWS FETCH NEXT 1 ROWS ONLY 
		SELECT @Date = Date FROM GuaranteeCases WHERE GuaranteeCaseId = @Id

			IF	@Date IS NULL
				UPDATE GuaranteeCases SET Date = CURRENT_TIMESTAMP WHERE GuaranteeCaseId = @Id
			ELSE IF @Date > CURRENT_TIMESTAMP
			BEGIN
				DELETE GuaranteeCases WHERE GuaranteeCaseId = @Id
				PRINT 'Date has to be in the past'
			END
		SET @Count = @Count - 1
	END
END
INSERT INTO GuaranteeCases(ClientId, CarId, Date, Status, Description)
Values
(1,5, DATEADD(HH, 1, CURRENT_TIMESTAMP), 'Обробка', 'dd')
SELECT * FROM GuaranteeCases

--Тригер для видалення Замовлення клієнта
GO
CREATE TRIGGER DeleteCustomerOrder
ON CustomerOrders
FOR DELETE AS
BEGIN
	DECLARE @Count INT
	SELECT @Count = COUNT(*) FROM deleted
	DECLARE @Id INT
	DECLARE @CarId INT
	WHILE @Count > 0
	BEGIN
		SELECT @Id = CustomerOrderId FROM deleted ORDER BY deleted.CustomerOrderId Offset @Count-1 ROWS FETCH NEXT 1 ROWS ONLY 
		SELECT @CarId = CarId FROM deleted WHERE CustomerOrderId = @Id
		DELETE Cars WHERE CarId = @CarId
		SET @Count = @Count - 1
	END
END
GO

DELETE CustomerOrders WHERE CustomerOrderId = 11
SELECT * FROM Cars
SELECT * FROM CustomerOrders

--

CREATE NONCLUSTERED INDEX idx_CarsColorCost ON Cars (Color,Cost)
SELECT CarId FROM Cars
WHERE Cost > 55000 AND Color IN ('Green','Blue', 'Teal','Yellow', 'Goldenrod')

SELECT CarId FROM Cars
WHERE CarId > 20

DROP INDEX idx_CarsCost ON Cars 
DROP INDEX idx_CarsColor ON Cars 
DROP INDEX idx_CarsColorCost ON Cars 

DELETE Cars WHERE CarId > 18

--Представлення для перегляду авто які є в наявності, або були продані до 7 днів тому
GO
CREATE VIEW ShowableCars AS 
SELECT m.Name, Cars.Cost, Cars.Color, Cars.State FROM Sales 
	RIGHT JOIN Cars ON Sales.CarId = Cars.CarId
	INNER JOIN Equipments AS e ON e.EquipmentId = Cars.EquipmentId
	INNER JOIN Models AS m ON m.ModelId = e.ModelId
	WHERE DATEDIFF(DAY, Sales.SalesDate, CURRENT_TIMESTAMP) < 7 OR State = 'Наявний'
GO
SELECT * FROM ShowableCars

SELECT * FROM Cars
SELECT * FROM Sales

--Представлення для відображення всіх бонусів (для аміна)
GO 
CREATE VIEW ShowEmployeeCompensations AS
SELECT e.Name, ec.Value, Models.Name AS 'Model name', c.Cost AS 'Car price' FROM EmployeeCompensations AS ec
INNER JOIN Sales AS s ON ec.SaleId = s.SaleId
INNER JOIN Cars AS c ON c.CarId = s.CarId
JOIN Employees AS e ON e.EmployeeId = ec.EmployeeId
JOIN Equipments ON Equipments.EquipmentId = c.EquipmentId
JOIN Models ON Models.ModelId = Equipments.ModelId
GO

SELECT * FROM ShowEmployeeCompensations 

--Представлення для відображення наявних авто з пробігом
GO
CREATE VIEW ShowUsedCars AS
SELECT m.Name, c.Color, c.Cost, en.Power, e.FuelConsumption FROM Cars AS c 
JOIN Equipments AS e ON e.EquipmentId = c.EquipmentId
JOIN Models AS m ON m.ModelId = e.ModelId
Join Engines AS en ON en.EngineId = e.EngineId
WHERE State = 'Наявний' AND Kilometrage > 0
GO
SELECT * FROM ShowUsedCars

CREATE NONCLUSTERED INDEX idx_CarsColorCost ON Cars (Color,Cost)

SELECT CarId FROM Cars
WHERE Cost > 55000 AND Color IN ('Green','Blue', 'Teal','Yellow', 'Goldenrod')