

--emp must be 21
--warehouse (18)
CREATE PROC AddEmp
	@NationalIdNumber nvarchar(15),
	@LoginID nvarchar(235),
	@JobTitle nvarchar(50),
	@BirthDate date,
	@MaritalStatus nchar(1),
	@Gender nchar(1),
	@HireDate date,
	@SalariedFlag Flag(bit),
	@VacationHours smallint,
	@SickLeaveHours smallint,
	@CurrentFlag Flag(bit),
	@rowguid uniqueidentifier,
	@ModifiedDate datetime
AS
BEGIN TRAN T1
IF(@BirthDate < getDate() - 365.25*20)
	BEGIN
		GOTO PROBLEM
	END
IF(@BirthDate > getDate() - 365.25 * 18)
	BEGIN
		IF(JobTitle LIKE '%Assistant')
			BEGIN
				INSERT INTO [HumanResources].[Employee] (NationalIdNumber, LoginID, JobTitle, BirthDate,
								BirthDate, MaritalStatus, Gender, HireDate, SalariedFlag,
								VacationHours, SickLeaveHours, CurrentFlag, rowguid,
								ModifiedDate)
			END
	END



PROBLEM:
IF (@@EEROR <> 0)
BEGIN
	PRINT ''
	ROLLBACK TRAN
END
