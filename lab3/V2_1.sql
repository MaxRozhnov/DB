USE AdventureWorks2012;
GO

/*
Добавьте в таблицу dbo.PersonPhone поле HireDate типа date;
*/
ALTER TABLE dbo.PersonPhone
ADD HireDate DATE

/*
Объявите табличную переменную с такой же структурой как dbo.PersonPhone и заполните ее данными из dbo.PersonPhone.
Заполните поле HireDate значениями из поля HireDate таблицы HumanResources.Employee
*/
DECLARE @TabVar TABLE (
	BusinessEntityID INT NOT NULL,
	PhoneNumber NVARCHAR(25) NULL,
	PhoneNumberTypeID INT NOT NULL,
	ModifiedDate DATETIME NOT NULL,
	ID BIGINT NULL,
	HireDate DATE NULL
);

INSERT INTO @TabVar  (
	BusinessEntityID,
	PhoneNumber,
	PhoneNumberTypeID,
	ModifiedDate,
	HireDate
) SELECT
	BusinessEntityID,
	PhoneNumber,
	PhoneNumberTypeID,
	ModifiedDate,
	(SELECT HireDate FROM HumanResources.Employee 
		WHERE HumanResources.Employee.BusinessEntityID = dbo.PersonPhone.BusinessEntityID)
FROM dbo.PersonPhone	
/*
Обновите HireDate в dbo.PersonPhone данными из табличной переменной, добавив к HireDate один день
*/
UPDATE dbo.PersonPhone
SET dbo.PersonPhone.HireDate = DATEADD(dd, 1, TabVar.HireDate)
FROM @TabVar AS TabVar
WHERE dbo.PersonPhone.BusinessEntityID = TabVar.BusinessEntityID

/*
Удалите данные из dbo.PersonPhone, для тех сотрудников, у которых почасовая ставка в таблице HumanResources.EmployeePayHistory больше 50
*/
DELETE dbo.PersonPhone
FROM dbo.PersonPhone INNER JOIN
	HumanResources.EmployeePayHistory
	ON dbo.PersonPhone.BusinessEntityID = HumanResources.EmployeePayHistory.BusinessEntityID
WHERE HumanResources.EmployeePayHistory.Rate > 50

/*
Удалите все созданные ограничения и значения по умолчанию. После этого, удалите поле ID
*/
ALTER TABLE dbo.PersonPhone DROP CONSTRAINT IX_PersonPhone_ID
ALTER TABLE dbo.PersonPhone DROP CONSTRAINT PhoneNumber
ALTER TABLE dbo.PersonPhone DROP CONSTRAINT PK_PersonPhone_BusinessEntityID_PhoneNumberTypeID
ALTER TABLE dbo.PersonPhone DROP CONSTRAINT DF_PhoneNumberTypeID
ALTER TABLE dbo.PersonPhone DROP COLUMN ID

/*
Удалите таблицу dbo.PersonPhone.
*/
DROP TABLE dbo.PersonPhone