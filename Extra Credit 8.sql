/*
Min Kim
1238304
Extra Credit 8
07/14/2016
*/



 CREATE DATABASE Min_July14
Select TOP 1 * INTO New_Cust
FROM [CUSTOMER_BUILD].[dbo].tblCUSTOMER


CREATE FUNCTION fn_NoMoreThanTenPeople()
RETURNS INT
AS

BEGIN
DECLARE @RET INT = 0
IF EXISTS(
	SELECT CustomerZip
	FROM [dbo].[New_Cust] NC
	WHERE DATEDIFF(YY, NC.DateOfBirth, GETDATE()) > 65
	GROUP BY NC.CustomerZip
	HAVING Count(NC.CustomerZip) > 10
)
SET @RET = 1

RETURN @RET
END



--2. zipcode and company name
CREATE PROC addPeople
	@CompName VARCHAR(125),
	@ZipCode VARCHAR(25)
AS

BEGIN TRAN T1
INSERT INTO [Min_July14].[dbo].[New_Cust](
			CustomerID, 
			CustomerFname, 
			CustomerLname, 
			CustomerAddress, 
			CustomerCity, 
			CustomerCounty, 
			CustomerState, 
			CustomerZIP,
			AreaCode,
			Email,
			BusinessName,
			DateOfBirth,
			PhoneNum)
SELECT 
			CustomerID, 
			CustomerFname, 
			CustomerLname, 
			CustomerAddress, 
			CustomerCity, 
			CustomerCounty, 
			CustomerState, 
			CustomerZIP,
			AreaCode,
			Email,
			BusinessName,
			DateOfBirth,
			PhoneNum
FROM [CUSTOMER_BUILD].[dbo].[tblCUSTOMER] C
WHERE C.CustomerZIP = @ZipCode
AND C.BusinessName = @CompName
 IF @@ERROR <> 0
ROLLBACK Tran G1
ELSE
COMMIT Tran G1
GO


