/*
First stored procedure
*/

use [CAMP_ORKILA]

CREATE PROCEDURE gthayAddIncident
@IncidentName varchar(50),
@ITN varchar(50),
@IncidentDescr varchar(1000),
@IncidentDate Date
AS
BEGIN TRAN T1
INSERT INTO INCIDENT (IncidentName, IncidentTypeID, IncidentDate, IncidentDescr)
VALUES (@IncidentName, (SELECT IncidentTypeID FROM INCIDENT_TYPE WHERE IncidentTypeName = @ITN),
@IncidentDate, @IncidentDescr)

IF @@ERROR <> 0
	ROLLBACK TRAN T1
ELSE
	COMMIT TRAN T1

　
/*
Second stored procedure
*/

CREATE PROCEDURE gthayAddIncCampAct
	@IncidentName varchar(50),
	@Fname varchar(35),
	@Lname varchar(35),
	@ActivityName varchar(50)
AS

DECLARE @IncidentID INT
DECLARE @CampActID INT

SET @CampActID = 
	(SELECT CampActID FROM CAMPER_ACTIVITY CA
		JOIN CAMPER C ON CA.CamperID = C.CamperID
		JOIN ACTIVITY A ON CA.ActivityID = A.ActivityID
		WHERE A.ActivityName = @ActivityName
		AND C.CamperFname = @Fname
		AND C.CamperLname = @Lname)

SET @IncidentID = 
	(SELECT IncidentID FROM INCIDENT 
		WHERE IncidentName = @IncidentName)

Begin Tran T1

INSERT INTO CAMPER_ACTIVITY_INCIDENT (CampActID, IncidentID)
	VALUES (@CampActID, @IncidentID)
IF @@ERROR <> 0
	ROLLBACK Tran T1
ELSE
	COMMIT Tran T1

/*
Now...execute the stored procedure with appropriate values that exist in the CAMPER and ACTIVITY tables
*/

EXECUTE gthayAddIncident 
		@IncidentName = 'Greg winged lab again',
		@ITN = 'Academic',
		@IncidentDescr= 'Greg was thinking it would be fun to have Julie make up a type of database',
		@IncidentDate = 'July 6, 2016'