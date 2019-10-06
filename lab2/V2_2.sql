USE AdventureWorks2012;
GO

/*
Создайте таблицу dbo.PersonPhone с такой же структурой как Person.PersonPhone, 
не включая индексы, ограничения и триггеры;
*/
CREATE TABLE dbo.PersonPhone (
	BusinessEntityID INT NOT NULL,
	PhoneNumber NVARCHAR(25) NOT NULL,
	PhoneNumberTypeID INT NOT NULL,
	ModifiedDate DATETIME NOT NULL,
	CONSTRAINT PK_PersonPhone_BusinessEntityID_PhoneNumber_PhoneNumberTypeID PRIMARY KEY CLUSTERED (BusinessEntityID, PhoneNumber, PhoneNumberTypeID)
)
/*
Используя инструкцию ALTER TABLE, добавьте в таблицу dbo.PersonPhone новое поле ID, 
которое является уникальным ограничением UNIQUE типа bigint и имеет свойство identity. 
Начальное значение для поля identity задайте 2 и приращение задайте 2;
*/
ALTER TABLE dbo.PersonPhone
ADD ID BIGINT IDENTITY(2,2)
ALTER TABLE dbo.PersonPhone
ADD CONSTRAINT IX_PersonPhone_ID UNIQUE (ID)
/*
Используя инструкцию ALTER TABLE, создайте для таблицы dbo.PersonPhone ограничение для поля PhoneNumber, 
запрещающее заполнение этого поля буквами;
*/
ALTER TABLE dbo.PersonPhone
ADD CONSTRAINT PhoneNumber CHECK(PhoneNumber LIKE '%[^a-zA-Z]%' )
/*
Используя инструкцию ALTER TABLE, создайте для таблицы dbo.PersonPhone ограничение 
DEFAULT для поля PhoneNumberTypeID, задайте значение по умолчанию 1;
*/
ALTER TABLE dbo.PersonPhone
ADD CONSTRAINT DF_PhoneNumberTypeID DEFAULT 1 FOR PhoneNumberTypeID
/*
Заполните новуютаблицу данными из Person.PersonPhone, 
где поле PhoneNumber не содержит символов '(' и ')' 
и только для тех сотрудников, которые существуют в таблице HumanResources.Employee, 
а их дата принятия на работу совпадает с датой начала работы в отделе;
*/
INSERT INTO dbo.PersonPhone(
	BusinessEntityID,
	PhoneNumber,
	PhoneNumberTypeID,
	ModifiedDate
) SELECT 
	PPPHone.BusinessEntityID,
	PPPHone.PhoneNumber,
	PPPHone.PhoneNumberTypeID,
	PPPHone.ModifiedDate
FROM Person.PersonPhone as PPPHone INNER JOIN
	HumanResources.Employee
	ON PPPHone.BusinessEntityID = HumanResources.Employee.BusinessEntityID INNER JOIN
	HumanResources.EmployeeDepartmentHistory
	ON PPPHone.BusinessEntityID = EmployeeDepartmentHistory.BusinessEntityID
WHERE 
	NOT (PhoneNumber LIKE '%(%)%')
	AND (EmployeeDepartmentHistory.StartDate = Employee.HireDate)
/*
Измените поле PhoneNumber, разрешив добавление null значение.
*/
ALTER TABLE dbo.PersonPhone DROP CONSTRAINT PK_PersonPhone_BusinessEntityID_PhoneNumber_PhoneNumberTypeID

ALTER TABLE dbo.PersonPhone
ALTER COLUMN PhoneNumber NVARCHAR(25) NULL
	
ALTER TABLE dbo.PersonPhone 
ADD CONSTRAINT PK_PersonPhone_BusinessEntityID_PhoneNumberTypeID PRIMARY KEY (BusinessEntityID, PhoneNumberTypeID)