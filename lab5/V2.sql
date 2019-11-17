USE AdventureWorks2012
GO

/*
Создайте scalar-valued функцию,
которая будет принимать в качестве входного параметра
id отдела (HumanResources.Department.DepartmentID) и
возвращать количество сотрудников, работающих в отделе.
*/

CREATE FUNCTION HumanResources.DepartmentEmployeeCount (@DepId SMALLINT)
RETURNS INT AS
BEGIN
	DECLARE @ret INT
	SET @ret =
	(
		SELECT COUNT(BusinessEntityID)
		FROM HumanResources.EmployeeDepartmentHistory AS EDepHist
		WHERE EDepHist.DepartmentID = @DepId
			  AND EDepHist.EndDate IS NULL
	)

	RETURN @ret
END;
GO

/*
Создайте inline table-valued функцию,
которая будет принимать в качестве входного
параметра id отдела (HumanResources.Department.DepartmentID),
а возвращать сотрудников, которые работают в отделе более 11 лет.
*/

CREATE FUNCTION HumanResources.OldDepEmployee(@DepId SMALLINT)
RETURNS TABLE
AS
RETURN
	SELECT BusinessEntityID
	FROM HumanResources.EmployeeDepartmentHistory
	WHERE DepartmentID = @DepId
		  AND DATEDIFF(year, StartDate, GETDATE()) > 11
		  AND EndDate IS NULL
GO

/*
Вызовите функцию для каждого отдела,
применив оператор CROSS APPLY.
Вызовите функцию для каждого отдела, применив оператор OUTER APPLY.
*/

SELECT * FROM HumanResources.Department
	CROSS APPLY HumanResources.OldDepEmployee(DepartmentID) AS OldDep
	ORDER BY OldDep.DepartmentID

SELECT * FROM HumanResources.Department
	OUTER APPLY HumanResources.OldDepEmployee(DepartmentID) AS OldDep
	ORDER BY OldDep.DepartmentID
GO

/*
Измените созданную inline table-valued функцию,
сделав ее multistatement table-valued
(предварительно сохранив для проверки код создания inline table-valued функции).
*/

CREATE FUNCTION HumanResources.OldDepEmployeeSecond(@DepId SMALLINT)
	RETURNS @oldEmployees TABLE (
		BusinessEntityID INT NOT NULL
	)
AS
BEGIN
	INSERT INTO @oldEmployees
	SELECT
		BusinessEntityID
	FROM
		HumanResources.EmployeeDepartmentHistory
	WHERE
		DepartmentID = @DepId
		AND DATEDIFF(year, StartDate, GETDATE()) > 11
		AND EndDate IS NULL
	RETURN
END;
