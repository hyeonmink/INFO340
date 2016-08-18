

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
	IF @BirthDate > (SELECT GetDate() - (365.25 *18)) OR
	(@BirthDate > (SELECT GetDate() - (365.25 *21)) AND @JobTitle NOT LIKE '%Assistant')
		GOTO ERROR

BEGIN TRAN T1
	INSERT INTO [HumanResources].[Employee] (NationalIdNumber, LoginID, JobTitle, BirthDate,
					BirthDate, MaritalStatus, Gender, HireDate, SalariedFlag,
					VacationHours, SickLeaveHours, CurrentFlag, rowguid,
					ModifiedDate)
	VALUES(
		@NationalIdNumber,
		@LoginID,
		@JobTitle,
		@BirthDate,
		@MaritalStatus,
		@Gender,
		@HireDate,
		@SalariedFlag,
		@VacationHours,
		@SickLeaveHours,
		@CurrentFlag,
		@rowguid,
		@ModifiedDate
	)
	IF @@ERROR <> 0
	GOTO ERROR
	ELSE 
	COMMIT Tran T1

ERROR:
IF (@@EEROR <> 0)


BEGIN
	RAISERROR (54891,12,1)
	ROLLBACK Tran T1
END