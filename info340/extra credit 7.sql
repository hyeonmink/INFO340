/*
	Min KIM
	1238304
	EXTRA CREDIT 7
	07/13/2016
	1. TWO COUNSELORS FOR HORSES(CAMP ACTIVITY)
	2. STUDENTS CAN'T GO TO HORSE MORE THAN TWO TIMES
*/

CREATE FUNCTION	fn_NoMoreThanTwiceOfHorse()
RETURNS INT
AS

BEGIN
DECLARE @RET INT = 0
IF EXISTS(
	SELECT CA.CamperID
		FROM [dbo].[CAMPER_ACTIVITY] CA
		JOIN [dbo].[ACTIVITY] C ON CA.ActivityID = C.ActivityID
	WHERE C.ActivityName = 'HORSES'
	GROUP BY CA.CamperID
	HAVING Count(CA.ActivityID) > 2
)

SET @RET = 1
RETURN @RET

END



--run
SELECT dbo.fn_NoMoreThanTwiceOfHorse()





ALTER TABLE [dbo].[ACTIVITY]
ADD CONSTRAINT NoMoreThanTwoHorses
CHECK (dbo.fn_NoMoreThanTwiceOfHorse() = 0)

SELECT * FROM [dbo].[ACTIVITY]