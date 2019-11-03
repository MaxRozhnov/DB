USE AdventureWorks2012
GO

/*
Создайте представление VIEW, отображающее данные из таблиц Production.Location и
Production.ProductInventory, а также Name из таблицы Production.Product. 
Сделайте невозможным просмотр исходного кода представления. 
Создайте уникальный кластерный индекс в представлении по полям LocationID,ProductID.
*/
CREATE VIEW Production.Product_View
	WITH ENCRYPTION, SCHEMABINDING
	AS 
		SELECT PL.LocationID, PPI.ProductID, PP.Name as ProductName, PL.Name AS LocationName, PL.CostRate, PL.Availability,
			 PPI.Shelf, PPI.Bin, PPI.Quantity, PPI.rowguid, PPI.ModifiedDate
		FROM Production.Location AS PL INNER JOIN  
		Production.ProductInventory AS PPI
		ON PL.LocationID = PPI.LocationID INNER JOIN 
		Production.Product AS PP
		ON PPI.ProductID = PP.ProductID
GO

CREATE UNIQUE CLUSTERED INDEX IDX_LocationID_ProductID ON Production.Product_View (LocationID, ProductID)
GO
/*
Создайте три INSTEAD OF триггера для представления на операции INSERT, UPDATE, DELETE.
Каждый триггер должен выполнять соответствующие операции в таблицах Production.Location 
и Production.ProductInventory для указанного Product Name. 
Обновление и удаление строк производите только в таблицах Production.Location 
и Production.ProductInventory, но не в Production.Product.
*/
CREATE TRIGGER Production.TriggerProductViewInsteadInsert ON Production.Product_View
INSTEAD OF INSERT AS
BEGIN
	INSERT INTO Production.Location (Name, CostRate, Availability, ModifiedDate)
	SELECT LocationName, CostRate, Availability, ModifiedDate 
	FROM inserted

	INSERT INTO Production.ProductInventory (LocationID, ProductID, Shelf, Bin, Quantity, rowguid, ModifiedDate)
	SELECT PL.LocationID, PP.ProductID, Shelf, Bin, Quantity, inserted.rowguid, PL.ModifiedDate
	FROM inserted INNER JOIN
	Production.Location AS PL
	ON inserted.ModifiedDate  = PL.ModifiedDate INNER JOIN
	Production.Product AS PP
	ON inserted.ProductName = PP.Name
END
GO

CREATE TRIGGER Production.TriggerProductViewInsteadUpdate ON Production.Product_View
INSTEAD OF UPDATE AS
BEGIN
	UPDATE Production.Location
	SET
		Name = inserted.LocationName,
		CostRate = inserted.CostRate,
		Availability = inserted.Availability,
		ModifiedDate = inserted.ModifiedDate
	FROM inserted
	WHERE Production.Location.LocationID = inserted.LocationID

	UPDATE Production.ProductInventory
	SET
		Shelf = inserted.Shelf,
		Bin = inserted.Bin,
		Quantity = inserted.Quantity,
		rowguid = inserted.rowguid,
		ModifiedDate = inserted.ModifiedDate
	FROM inserted
	WHERE Production.ProductInventory.ProductID = inserted.ProductID
END
GO

CREATE TRIGGER Production.TriggerProductViewInsteadDelete ON Production.Product_View
INSTEAD OF DELETE AS
BEGIN
	DELETE Production.ProductInventory
	WHERE Production.ProductInventory.ProductID IN (SELECT ProductID FROM deleted)

	DELETE Production.Location 
	WHERE Production.Location.LocationID IN (SELECT LocationID FROM deleted)
END
GO
/*
Вставьте новую строку в представление, 
указав новые данные для Location и ProductInventory,
но для существующего Product (например для ‘Adjustable Race’).
Триггер должен добавить новые строки в таблицы Production.Location и 
Production.ProductInventory для указанного Product Name. 
Обновите вставленные строки через представление. Удалите строки.
*/
INSERT INTO Production.Product_View (
	ProductName,
	LocationName,
	CostRate,
	Availability,
	Shelf,
	Bin,
	Quantity,
	rowguid,
	ModifiedDate
) 
VALUES ('Adjustable Race', 'Minsk', 120, 120, 'A', 1, 400, '47A24246-6C43-48EB-968F-025738A8A411', GETDATE())

UPDATE Production.Product_View
SET
	LocationName = 'Gomel'
WHERE LocationName = 'Minsk'

DELETE Production.Product_View
WHERE LocationName = 'Gomel'

SELECT * FROM Production.Product_View
WHERE LocationName = 'Gomel'
