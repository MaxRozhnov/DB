USE AdventureWorks2012
GO

/*
Выполните код, созданный во втором задании второй лабораторной работы.
Добавьте в таблицу dbo.PersonPhone поля JobTitle NVARCHAR(50), BirthDate DATE и HireDate DATE.
Также создайте в таблице вычисляемое поле HireAge, считающее количество лет, прошедших между BirthDate и HireDate.
*/
ALTER TABLE dbo.PersonPhone
ADD JobTitle NVARCHAR(50),
	BirthDate DATE,
	HireDate DATE,
	HireAge AS DATEDIFF(year, BirthDate,HireDate)

/*
Создайте временную таблицу #PersonPhone, с первичным ключом по полю BusinessEntityID.
Временная таблица должна включать все поля таблицы dbo.PersonPhone за исключением поля HireAge.
*/
CREATE TABLE dbo.#PersonPhone(
	BusinessEntityID INT NOT NULL PRIMARY KEY,
	PhoneNumber NVARCHAR(25) NULL,
	PhoneNumberTypeID INT DEFAULT(1),
	ModifiedDate DATETIME NOT NULL,
	ID BIGINT NOT NULL,
	JobTitle NVARCHAR(50) NULL,
	BirthDate DATE NULL,
	HireDate DATE NULL
)



/*
Заполните временную таблицу данными из dbo.PersonPhone.
Поля JobTitle, BirthDate и HireDate заполните значениями из таблицы HumanResources.Employee.
Выберите только сотрудников с JobTitle = ‘Sales Representative’.
Выборку данных для вставки в табличную переменную осуществите в Common Table Expression (CTE).
*/
WITH Employee_CTE
AS 
(SELECT
	PPhone.BusinessEntityID,
	PhoneNumber,
	PhoneNumberTypeID,
	PPhone.ModifiedDate,
	ID,
	Employee.JobTitle,
	Employee.BirthDate,
	Employee.HireDate
FROM dbo.PersonPhone AS PPhone INNER JOIN
	HumanResources.Employee
	ON PPhone.BusinessEntityID = Employee.BusinessEntityID
WHERE Employee.JobTitle = 'Sales Representative')

INSERT INTO dbo.#PersonPhone (
	BusinessEntityID,
	PhoneNumber,
	PhoneNumberTypeID,
	ModifiedDate,
	ID,
	JobTitle,
	BirthDate,
	HireDate
) SELECT
	BusinessEntityID,
	PhoneNumber,
	PhoneNumberTypeID,
	ModifiedDate,
	ID,
	JobTitle,
	BirthDate,
	HireDate
FROM Employee_CTE

/*
Удалите из таблицы dbo.PersonPhone одну строку (где BusinessEntityID = 275)
*/
DELETE FROM dbo.PersonPhone WHERE BusinessEntityID = 275

/*
Напишите Merge выражение, использующее dbo.PersonPhone как target, а временную таблицу как source.
Для связи target и source используйте BusinessEntityID.
Обновите поля JobTitle, BirthDate и HireDate, если запись присутствует и в source и в target.
Если строка присутствует во временной таблице, но не существует в target, добавьте строку в dbo.PersonPhone.
Если в dbo.PersonPhone присутствует такая строка, которой не существует во временной таблице, удалите строку из dbo.PersonPhone.
*/
MERGE dbo.PersonPhone AS target
USING dbo.#PersonPhone as source
ON target.BusinessEntityID = source.BusinessEntityID
WHEN MATCHED 
	THEN UPDATE SET
		JobTitle = source.JobTitle,
		BirthDate = source.BirthDate
WHEN NOT MATCHED BY TARGET
	THEN INSERT(
			BusinessEntityID,
			PhoneNumber,
			PhoneNumberTypeID,
			ModifiedDate,
			JobTitle,
			BirthDate,
			HireDate
		)
		VALUES(
			source.BusinessEntityID,
			source.PhoneNumber,
			source.PhoneNumberTypeID,
			source.ModifiedDate,
			source.JobTitle,
			source.BirthDate,
			source.HireDate
		)
WHEN NOT MATCHED BY SOURCE
	THEN DELETE;