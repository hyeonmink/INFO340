-- 1)	Create a stored procedure to hire a new person to an existing staff position. 
CREATE PROC AddPerson
	@StaffFname varchar(25),
	@StaffLname varchar(25),
	@PositionName varchar(25)
AS
BEGIN
	BEGIN TRY
		DECLARE @PositionID INT
		DECLARE @StaffID INT
		SET @PositionID = (SELECT PositionID FROM POSITION P 
							WHERE P.PositionName = @PositionName) 
		BEGIN Tran T1
		INSERT INTO STAFF(StaffFname, StaffLname)
		VALUES(@StaffFname, @StaffLname)
		SET @StaffID = SCOPE_IDENTITY()

		INSERT INTO STAFF_POSITION(StaffID, PositionID, StaffPosBeginDate)
		VALUES (@StaffID, @PositionID, GETDATE())
		COMMIT Tran T1

	END TRY

	BEGIN CATCH
		IF(@@trancount <> 0 or Xact_State <> 0) OR @@ERROR <> 0
		THROW 58888, 'Error!', 1
		ROLLBACK Tran T1
	END CATCH
END
GO

--2)	Create a stored procedure to create a new class of an existing course.
CREATE PROC addClass
	@ClassName varchar(25),
	@ClassYear INT,
	@Section varchar(25),
	@CourseName varchar(25),
	@QuarterName varchar(10),
	@RoomName varchar(10),
	@ScheduleName varchar(25),
	@FormatName varchar(25),
	@BeginDate DATE
AS
BEGIN
	BEGIN TRY
		DECLARE @CourseID INT
		DECLARE @QuarterID INT
		DECLARE @RoomID INT
		DECLARE @ScheduleID INT
		DECLARE @FormatID INT

		SET @CourseID = (SELECT CourseID FROM COURSE C WHERE C.CourseName = @CourseName)
		SET @QuarterID = (SELECT QuarterID FROM [QUARTER] Q WHERE Q.QuarterName = @QuarterName)
		SET @RoomID = (SELECT RoomID FROM ROOM R WHERE R.RoomName = @RoomName)
		SET @ScheduleID = (SELECT ScheduleID FROM SCHEDULE S WHERE S.ScheduleName = @ScheduleName)
		SET @FormatID = (SELECT FormatID FROM [FORMAT] F WHERE F.FormatName = @FormatName)
		
		BEGIN TRAN T1
		INSERT INTO CLASS(ClassName, ClassYear, Section, CourseID, QuarterID, RoomID, ScheduleID, FormatID, BeginDate)
		VALUES(@ClassName, @ClassYear, @Section, @CourseID, @QuarterID, @RoomID, @ScheduleID, @FormatID, @BeginDate)
		COMMIT TRAN T1
	END TRY

	BEGIN CATCH
		IF(@@trancount <> 0 or Xact_State <> 0) OR @@ERROR <> 0
		THROW 58889, 'Error!', 1
		ROLLBACK Tran T1
	END CATCH
END
GO

--3)	Create a stored procedure to register an existing student to an existing class.
CREATE PROC register
	@RoleName varchar(25),
	@Fname varchar(25),
	@Lname varchar(25),
	@ClassName varchar(25)
AS
BEGIN
	BEGIN TRY
		DECLARE @PersonID INT
		DECLARE @RoleID INT
		DECLARE @ClassID INT
		DECLARE @PersonRoleID INT

		SET @PersonID = (SELECT PersonID FROM PERSON P 
							WHERE P.Fname = @Fname 
							AND P.Lname = @Lname)
		SET @RoleID = (SELECT RoleID FROM [ROLE] R
							WHERE R.RoleName = @RoleName)
		SET @ClassID = (SELECT ClassID FROM CLASS C
							WHERE C.ClassName = @ClassName)

		BEGIN Tran T1
		SET @PersonRoleID = (SELECT PersonRoleID FROM PERSON_ROLE PR WHERE PR.PersonID = @PersonID
																	   AND PR.RoleID = @RoleID)

		INSERT INTO CLASS_LIST(ClassID, PersonRoleID, RegistrationDate)
		VALEUS (@ClassID, @PersonRoleID, GETDATE())
		COMMIT TRAN T1
	END TRY

	BEGIN CATCH
		IF(@@trancount <> 0 or Xact_State <> 0) OR @@ERROR <> 0
		THROW 58890, 'Error!', 1
		ROLLBACK Tran T1
	END CATCH
END
GO

/*4)	Create the check constraint to restrict the type of instructor assigned 
		to 400-level courses in Biology or Philosophy courses during summer quarters to Assistant or Associate Professor.
*/
CREATE FUNCTION fn_NoBioPhilDudingSummer()
RETURNS INT
AS
BEGIN
	DECLARE @RET INT = 0
	IF EXISTS(SELECT * FROM [QUARTER] Q
			 JOIN CLASS C ON Q.QuarterID = C.QuarterID
			 JOIN COURSE CS ON C.CourseID = CS.CourseID
			 JOIN DEPARTMENT D ON C.DeptID = D.DeptID
			 JOIN CLASS_LIST CL ON C.ClassID = CL.ClassID
			 JOIN PERSON_ROLE PR ON CL.PersonRoleID = PR.PersonRoleID
			 JOIN Role R ON PR.RoleID = R.RoleID
			 WHERE D.DeptName IN ('Biology', 'Philosophy')
			 AND Q.QuarterName = 'SUMMER'
			 AND RoleName IN ('Assistant', 'Associate Professor')
			 AND C.CourseName LIKE '%4__'))
		SET @RET = 1
	RETURN @RET
END
GO

ALTER TABLE STAFF
ADD CONSTRAINT ck_NoBioPhilDudingSummer
CHECK(dbo.fn_NoBioPhilDudingSummer() = 0)
GO

/*
5)	Create the check constraint to restrict students assigned to dorm-rooms on West Campus to be at least 20 years old.
*/

CREATE FUNCTION fn_WestDormOver20()
RETURNS INT
AS
BEGIN
	DECLARE @RET INT = 0
	IF EXISTS(SELECT * FROM ROOM_TYPE RT
				JOIN ROOM R ON RT.RoomTypeID = R.RoomTypeID
				JOIN BUILDING B ON R.BuildingID = B.BuildingID
				JOIN BUILDING_TYPE BT ON B.BuildingTypeID = BT.BuildingTypeID 
				JOIN LOCATION L ON L.LocationID = B.LocationID
				JOIN PERSON_ROOM PR ON R.RoomID = PR.RoomID
				JOIN PERSON_ROLE PRL ON PR.PersonRoleID = PR.PersonRoleID
				JOIN [Role] R ON PRL.RoleID = R.RoleID
			WHERE R.RoleName = 'Student'
			AND BT.BuildingTypeName = 'Dorm'
			AND L.LocationName = 'West Campus'
			AND P.DateOfBirth < (GETDATE() - 365.25 * 20))
		SET @RET = 1
	RETURN @RET
END
GO

ALTER TABLE PERSON_ROOM
ADD CONSTRAINT ck_NoWestDormOver20
CHECK(dbo.fn_WestDormOver20() = 0)
GO

--6)	Write the code to determine the oldest person registered for MATH389 Spring quarter 2016.
SELECT TOP 1 P.Fname, P.Lname FROM CLASS C
JOIN [QUARTER] Q ON C.QuarterID = Q.QuarterID
JOIN Class_LIST CL ON C.ClassID = CL.ClassID
JOIN Person_Role PR ON CL.PersonRoleID = PR.PersonRoleID
JOIN PERSON P ON PR.PersonID = P.PersonID
JOIN COURSE CS ON C.CourseID = CS.CourseID
WHERE Q.QuarterName = 'Spring'
AND C.ClassYear = 2016
AND CS.CourseName = 'MATH389'
ORDER BY P.DateOfBirth ASC

--7)	Write the code to determine the total number of dorm rooms that are of type ‘triple’ for McMahon Hall.
SELECT Count(*) FROM ROOM_TYPE RT
JOIN ROOM R ON RT.RoomTypeID = R.RoomTypeID
JOIN BUILDING B ON R.BuildingID = B.BuildingID
WHERE RT.RoomTypeName = 'Triple'
AND B.BuildingName = 'MacMahon Hall'
 
 --8)	How many Administrative staff people were hired in the Medical School between February 12, 2009 and March 28, 2013?
 SELECT count(*) FROM STAFF S
 JOIN STAFF_POSITION SP ON S.StaffID = SP.StaffID
 JOIN POSITION P ON SP.PositionID = P.PositionID
 JOIN POSITION_TYPE PT ON P.PositionTypeName = PT.PositionTypeName
 JOIN DEPARTMENT D ON D.DeptID = SP.DeptID
 WHERE StaffPosBeginDate BETWEEN 'Feb 12, 2009' AND 'March 28, 2013'
 AND PT.PositionTypeName LIKE 'Admin%'
 AND D.DeptName = 'Medical School'

 --9)	Which is the newest building on lower campus that has had a Geology class instructed by Greg Hay before winter 2015.
 SELECT TOP 1 BuildingName FROM BUILDING B
 JOIN LOCATION L ON B.LocationID = L.LocaitonID
 JOIN ROOM R ON R.BuildingID = B.BuildingID
 JOIN CLASS C ON C.RoomID = R.RoomID
 JOIN Class_LIST CL ON C.ClassID = CL.ClassID
 JOIN Person_Role PR ON CL.PersonRoleID = PR.PersonRoleID
 JOIN [ROLE] R ON R.RoleID = PR.RoleID
 JOIN PERSON P ON P.PersonID = PR.PersonID
 WHERE L.locationName = 'Lower%'
 AND C.ClassYear < 2016
 AND (R.RoleName = 'Instructor' AND P.Fname = 'Greg' AND P.Lame = 'Hay'
 AND C.ClassName = 'Geology%'
 ORDER BY B.YearOpened DESC
 
 --10)	Which instructor has had the same office in Padelford Hall the longest?
 SELECT TOP 1 S.StaffFname, S.StaffLname FROM STAFF S
 JOIN STAFF_POSITION SP ON S.StaffID = SP.StaffID
 JOIN POSITION P ON SP.PositionID = P.PositionID
 JOIN Department D ON SP.DeptID = D.DeptID
 JOIN COURSE CS ON C.DeptID = D.DeptID
 JOIN CLASS C ON C.CourseID = CS.CourseID
 JOIN ROOM R ON R.RoomID = C.RoomID
 JOIN BUILDING B ON R.BuildingID = B.BuildingID
 WHERE B.BuildingName = 'Padelford Hall'
 ORDER BY (StaffPosBeginDate - StaffPosEndDate) DESC



