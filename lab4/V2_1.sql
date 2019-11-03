USE AdventureWorks2012
GO

/*
Создайте таблицу Production.LocationHst, 
которая будет хранить информацию об изменениях 
в таблице Production.Location.

Обязательные поля, которые должны присутствовать в таблице:
ID — первичный ключ IDENTITY(1,1);
Action — совершенное действие (insert, update или delete);
ModifiedDate — дата и время, когда была совершена операция; SourceID — первичный ключ исходной таблицы; UserName — имя пользователя, совершившего операцию. Создайте другие поля, если считаете их нужными.
*/
CREATE TABLE Production.LocationHist (
	ID INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	Action CHAR(6) NOT NULL CHECK (Action IN ('INSERT', 'UPDATE', 'DELETE')),
	ModifiedDate DATETIME NOT NULL,
	SourceID INT NOT NULL,
	UserName NVARCHAR(50) NOT NULL
)
/*
Создайте один AFTER триггер для трех операций INSERT, UPDATE, DELETE
Для таблицы Production.Location.
Триггер должен заполнять таблицу Production.LocationHst 
с указанием типа операции в поле Action в зависимости от оператора, вызвавшего триггер.
*/
CREATE TRIGGER Production.LocationAfterTrigger
ON Production.Location
AFTER INSERT, UPDATE, DELETE AS
	INSERT INTO Production.LocationHist	(Action, ModifiedDate, SourceID, UserName)
	SELECT
		CASE 
			WHEN inserted.LocationID IS NULL THEN 'DELETE'
			WHEN deleted.LocationID IS NULL THEN 'INSERT'
											ELSE 'UPDATE'
		END AS Action,
	GETDATE(),
	COALESCE(inserted.LocationID, deleted.LocationID),
	User_Name()
	FROM inserted FULL OUTER JOIN 
		deleted
		ON inserted.LocationID = deleted.LocationID
/*
Создайте представление VIEW, отображающее все поля таблицы Production.Location.
*/
CREATE VIEW Production.LocationView AS
(SELECT * FROM Production.Location)

/*
Вставьте новую строку в Production.Location через представление. 
Обновите вставленную строку. 
Удалите вставленную строку. 
Убедитесь, что все три операции отображены в Production.LocationHst.
*/
INSERT INTO Production.LocationView (Name, CostRate, Availability, ModifiedDate)
VALUES ('John Doe', 120, 120, GETDATE())

UPDATE Production.LocationView
SET
	CostRate = 15000
WHERE Name = 'John Doe'

DELETE Production.LocationView
WHERE Name = 'John Doe'
