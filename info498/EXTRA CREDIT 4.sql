/*
Annual Promotions for Employees !! :-)

Stored procedure 1: Identify the oldest person per department

Stored procedure 2: Increase these people's PayRate by 10%

Error-Handling 1): Employee must be current

Error-Handling 2): Employee must be younger than 85

Error-Handling 3): PayRate may not exceed $250,000

*/



CREATE PROC uspFindOldestEMP
	@DeptID SMALLINT,
	@EmpID INT OUTPUT
AS
	BEGIN
	SET @EmpID = 
	(SELECT TOP 1 E.BusinessEntityID FROM [HumanResources].[Employee] E
	JOIN HumanResources.EmployeeDepartmentHistory EH ON E.BusinessEntityID = EH.BusinessEntityID
	WHERE EH.DepartmentID = @DeptID
	AND EH.EndDate IS NULL										--Error-Handling 1
	AND E.BirthDate > (SELECT GetDate() - 365.25*85)			--Error-Handling 2
	ORDER BY E.BirthDate ASC)
	END
GO

CREATE PROC uspRaiseOldEmp
	@EmpID INT,
	@Percentage Numeric(2,2)
AS
BEGIN
DECLARE @Rate MONEY
SET @Rate = (SELECT RATE FROM [HumanResources].[EmployeePayHistory] EPH
			WHERE EPH.BusinessEntityID = @EmpID) * (1 + @Percentage)

IF(SELECT E.[CurrentFlag] FROM [HumanResources].[Employee] E
	WHERE E.BusinessEntityID = @EmpID) = 0
	BEGIN
		GOTO ERROR
	END

IF(SELECT E.BirthDate FROM [HumanResources].[Employee] E
	WHERE E.BusinessEntityID = @EmpID) > (SELECT GETDATE() - 365.25 * 85) 
	BEGIN
		GOTO ERROR
	END

IF(@RATE > 250000)
	BEGIN
		GOTO ERROR
	END

BEGIN TRAN T1
	UPDATE [HumanResources].[EmployeePayHistory]
	SET [Rate] = @Rate
	WHERE BusinessEntityID = @EmpID

	UPDATE [HumanResources].[EmployeePayHistory]
	SET RateChangeDate = GETDATE()
	WHERE BusinessEntityID = @EmpID

IF @@ERROR <> 0
	ROLLBACK TRAN T1
ELSE
	COMMIT TRAN T1

ERROR:
	THROW 51000, 'ERROR ERROR', 1

