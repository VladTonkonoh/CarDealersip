USE Term

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
	SELECT * FROM GetCarInfo(@carId)
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

-- 13.Запит для виведення авто проданих за тиждень до поточної дати

SELECT * FROM Sales 
INNER JOIN Cars ON Sales.CarId = Cars.CarId
WHERE DATEDIFF(DAY, Sales.SalesDate, CURRENT_TIMESTAMP) < 7

-- 14.Запит для списку отриманих від клієнта коштів

SELECT c.Name, SUM(Cars.Cost) FROM Sales AS s
INNER JOIN Clients AS c ON s.ClientId = c.ClientId
INNER JOIN Cars ON Cars.CarId = s.CarId
GROUP BY  c.Name, c.ClientId

-- 15.Запит для перегляду всіх гарантійних випадків

SELECT c.Name, gc.Status, gc.Description FROM GuaranteeCases AS gc
LEFT JOIN Clients AS c ON c.ClientId = gc.ClientId;

-- 16.Запит для переглядуВсіх моделей авто які пропонує постачальник

SELECT p.Name, m.Name FROM Models AS m
JOIN Producers AS p ON m.ProducerId = p.ProducerId
ORDER BY p.Name

-- 17.Запит для визначення кількості гарантійних випадків у моделі і порівняння їх з кількістю продажів

SELECT m.ModelId, COUNT(gc.GuaranteeCaseId) AS GuaranteeCases, COUNT(s.SaleId) AS SalesCount, CAST(CAST(COUNT(gc.GuaranteeCaseId) AS float) / COUNT(s.SaleId) * 100 AS nvarchar)  + '%' AS Percents FROM Cars AS c
RIGHT JOIN Sales AS s ON s.CarId = c.CarId
LEFT JOIN GuaranteeCases AS gc ON gc.CarId = c.CarId
INNER JOIN Equipments AS e ON e.EquipmentId = c.EquipmentId
INNER JOIN Models AS m ON m.ModelId = e.ModelId
GROUP BY m.ModelId

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

-- Функція для виведення авто дешевше ніж/ потужніше ніж
CREATE PROCEDURE GetFilteredCarsByPrice @Price INT, @More bit AS
	IF @More = 1
		SELECT * FROM Cars WHERE cars.Cost >= @Price AND Cars.State = 'Наявний'
	ELSE 
		SELECT * FROM Cars WHERE cars.Cost <= @Price AND Cars.State = 'Наявний'

EXEC GetFilteredCarsByPrice 25000, 0;

CREATE PROCEDURE GetFilteredCarsByPower @Power INT, @More bit AS
	IF @More = 1
		SELECT * FROM Cars 
		INNER JOIN Eq ON Engines. WHERE cars.Cost >= @Price AND Cars.State = 'Наявний'
	ELSE 
		SELECT * FROM Cars WHERE cars.Cost <= @Price AND Cars.State = 'Наявний'


-- Функція для виведення списку клієнтів котрі здійснили покупки бульше ніж...