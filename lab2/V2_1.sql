USE AdventureWorks2012;
GO

/*
Вывести на экран историю сотрудника, который работает на позиции 'Purchasging Manager'.
В каких отделах компании он работал, с указанием перодов работы в каждом отделе.
*/
SELECT EDepHist.BusinessEntityID, Employee.JobTitle, Department.Name , EDepHist.StartDate, EDepHist.EndDate
FROM HumanResources.EmployeeDepartmentHistory AS EDepHist INNER JOIN
	HumanResources.Employee 
	ON EDepHist.BusinessEntityID = Employee.BusinessEntityID INNER JOIN
	HumanResources.Department
	ON EDepHist.DepartmentID = Department.DepartmentID
WHERE JobTitle = 'Purchasing Manager'
	 
/*
Вывести на экран список сотрудников, у которых почасовая ставка изменялась хотя бы один раз.
*/
SELECT EPayHist.BusinessEntityID, Employee.JobTitle, COUNT(EPayHist.RateChangeDate) AS RateCount
FROM HumanResources.EmployeePayHistory AS EPayHist INNER JOIN
	HumanResources.Employee
	ON EPayHist.BusinessEntityID = Employee.BusinessEntityID
GROUP BY EPayHist.BusinessEntityID, Employee.JobTitle
HAVING COUNT(EPayHist.RateChangeDate) >= 2

/*
Вывести на экран максимальную почасовую ставку в каждом отделе. 
Вывести только актуальную информацию.
Если сотрудник больше не работает в отделе - не учитывать такие данные.
*/
SELECT Department.DepartmentID, Department.Name, MAX(EmployeePayHistory.Rate) AS MaxRate
FROM HumanResources.Department INNER JOIN
	HumanResources.EmployeeDepartmentHistory
	ON Department.DepartmentID = EmployeeDepartmentHistory.DepartmentID INNER JOIN
	HumanResources.EmployeePayHistory 
	ON EmployeeDepartmentHistory.BusinessEntityID = EmployeePayHistory.BusinessEntityID
WHERE EmployeeDepartmentHistory.EndDate IS NULL
GROUP BY Department.DepartmentID, Department.Name
