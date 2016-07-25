
--anyone less than 12, from IDAHO
CREATE FUNCTION fn_NoOneLessThan12FromIdaho()
RETURNS INT
BEGIN

DECLARE @RET INT = 0

IF EXISTS(
	SELECT *
	FROM   [dbo].[New_Cust] NC
	WHERE DATEDIFF(YY, NC.DateOfBirth, GETDATE()) < 12
	AND NC.CustomerState = 'Idaho, ID'
)
SET @RET = 1

RETURN @RET
END

ALTER TABLE [dbo].[New_Cust] WITH NOCHECK
ADD CONSTRAINT CK_NoOneLessThan12FromIdaho
CHECK (dbo.fn_NoOneLessThan12FromIdaho() = 0)