--add camper activity incident
USE [CAMP_ORKILA]

CREATE PROC minAddCampActInc
	@CamperFname varchar(35),
	@CamperLname varchar(35),

	@ActivityName varchar(50),

	@IncidentTypeName varchar(50),

	@IncidentName varchar(50)

AS

DECLARE @CamperID INT
DECLARE @ActivityID INT
DECLARE @CampActID INT
DECLARE @IncidentTypeID INT
DECLARE @IncidentID INT

SET @CamperID =
	(SELECT CamperID FROM CAMPER
	WHERE CamperFname = @CamperFname
	AND CamperLname = @CamperLname)

SET @ActivityID = 
	(SELECT ActivityID FROM ACTIVITY
	WHERE ActivityName = @ActivityName)

SET @CampActID = 
	(SELECT CampActID FROM CAMPER_ACTIVITY
	WHERE CamperID = @CamperID
	AND ActivityID = @ActivityID)

SET @IncidentTypeName =
	(SELECT IncidentTypeID FROM INCIDENT_TYPE
	WHERE IncidentTypeName = @IncidentTypeName)

SET @IncidentID = 
	(SELECT IncidentID FROM INCIDENT
	WHERE IncidentTypeID = @IncidentTypeID)

BEGIN TRAN T1
INSERT INTO INCIDENT_TYPE (IncidentTypeID)
VALUES (@IncidentTypeName)

INSERT INTO INCIDENT(IncidentName, IncidentTypeID)
VALUES (@IncidentName, @IncidentTypeID)

INSERT INTO CAMPER_ACTIVITY_INCIDENT (CampActID, IncidentID)
VALUES (@CampActID, @IncidentID)
