-- 1)	Create a stored procedure to hire a new person to an existing staff position. 
CREATE PROC AddPerson
	@StaffFname varchar(25),
	@StaffLname varchar(25),
	@PositionName varchar(25).
	@DeptName varchar(25)
AS
BEGIN
	BEGIN TRY
		DECLARE @PositionID INT
		DECLARE @StaffID INT
		DECLARE @DeptID INT
		SET @PositionID = (SELECT PositionID FROM POSITION P 
							WHERE P.PositionName = @PositionName)
		SET @DeptID = (SELECT DeptID FROM DEPARTMENT D
						WHERE D.DeptName = @DeptName)
		BEGIN Tran T1
		INSERT INTO STAFF(StaffFname, StaffLname)
		VALUES(@StaffFname, @StaffLname)
		SET @StaffID = SCOPE_IDENTITY()

		INSERT INTO STAFF_POSITION(StaffID, PositionID, DeptID, StaffPosBeginDate)
		VALUES (@StaffID, @PositionID, @DeptID, GETDATE())
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

ALTER TABLE CLASS_LIST
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

--7)	Write the code to determine the total number of dorm rooms that are of type ‘triple?for McMahon Hall.
SELECT SUM(*) FROM ROOM_TYPE RT
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

/*11)	Create the following 3 stored procedures:
	a.GetEmployeeID (pass in @Fname, @Lname, @EmpTypeName, @EmpDOB; Pass out @EmpID)
	b.GetVehicleID (pass in @VehicleSerialNum; pass out @VehicleID)
	c.CreateTrip (pass in all required parameters to leverage GetEmployeeID and GetVehicleID and 
	INSERT a new row in TRIP entity.
*/
 CREATE PROC usp_getEmpID
	@Fname varchar(25),
	@Lname varchar(25),
	@EmpTypeName varchar(25),
	@EmpDOB date,
	@EmpID INT OUTPUT
 AS
 BEGIN
	SET @EmpID = (SELECT E.EmpID FROM EMPLOYEE E
			JOIN EMPLOYEE_TYPE EP ON E.EmpTypeID = EP.EmpTypeID
			WHERE E.EmpFname = @Fname
			AND E.EmpLname = @Lname
			AND EP.EmpTypeName = @EmpTypeName
			AND E.EmpDOB = @EmpDOB)
END
GO

CREATE PROC usp_getVehicleID
	@VehicleSerialNum varchar(10),
	@VehicleID INT OUTPUT
AS
BEGIN
	SET @VehicleID = (SELECT VehicleID FROM VEHICLE
					WHERE VehicleSerialNum = @VehicleSerialNum)
END
GO

CREATE PROC usp_CreateTrip
	@Fname1 varchar(25),
	@Lname1 varchar(25),
	@EmpTypeName1 varchar(25),
	@EmpDOB1 date,
	@VehicleSerialNum1 varchar(10),
	@TripDate date
AS
BEGIN
	BEGIN TRY
	DECLARE @getEmpID INT
	DECLARE @getVehicleID INT

	EXEC usp_getEmpID
		@Fname = @Fname1,
		@Lname = @Lname1,
		@EmpTypeName = @EmpTypeName1,
		@EmpDOB = @EmpDOB1,
		@EmpID = @getEmpID OUTPUT

	EXEC usp_getVehicleID
		@VehicleSerialNum = @VehicleSerialNum1,
		@VehicleID = @getVehicleID OUTPUT

	BEGIN TRAN T1
		INSERT INTO TRIP(EmpID, VehicleID, TripDate)
		VALUES(@getEmpID, @getVehicleID, @TripDate)
		COMMIT TranT1
	END TRY

	BEGIN CATCH
		IF(@@trancount <> 0 or Xact_State <> 0) OR @@ERROR <> 0
		THROW 58891, 'Error!', 1
		ROLLBACK Tran T1
	END CATCH
END
GO

--12)	Write the code with a CHECK constraint to restrict values 
--		entered in the database that an employee may not be assigned more 
--		than 4 trips in any single day.
 
 CREATE FUNCTION fn_No4trips()
 RETURNS INT
 AS
 BEGIN
	DECLARE @RET INT = 0
	IF EXISTS(SELECT * FROM EMPLOYEE E
			JOIN TRIP T ON E.EmpID = T.EmpID
			GROUP BY TripDate
			HAVING count(*) > 4)
	SET @RET = 1
	RETURN @RET
 END
 GO

 ALTER TABLE EMPLOYEE
 ADD CONSTRAINT ck_No4Trips
 CHECK (dbo.fn_No4Trips() = 0)
 GO

 --13)	Write the code to create a computed column on POSITION that keeps 
 --track of the number of current employees that hold each specific position title.

 CREATE FUNCTION fn_NumberOfPosition(@PositionID)
 RETURNS INT
 AS
 BEGIN
	DECLARE @RET INT
	SET @RET = (SELECT count(*) FROM EMPLOYEE_POSITION EP
				WHERE EP.PositionID = @PositionID
				AND EP.EndDate IS NULL)
	RETURN @RET
 END
 GO

 ALTER TABLE POSITION
 ADD TotalNumberOfEmp AS dbo.fn_NumberOfPosition(PositionID)
 GO


 --14)	Write the code to create a computed column on EMPLOYEE_POSITION that 
 --keeps track of the number of years that each specific employee has been 
 --employed at their current position to the tenths of a year.

 CREATE FUNCTION fn_numberOfYear(@EmpPositionID)
 RETURNS INT
 AS
 BEGIN
	DECLARE @RET INT
	SET @RET = Round(DATEDIFF(DD, 
					(SELECT StartDate FROM EMPLOYEE_POSITION EP 
					WHERE EP.EmpPostionID = @EmpPositionID),
					(SELECT EndDate FROM EMPLOYEE_POSITION EP 
					WHERE EP.EmpPostionID = @EmpPositionID))/365.25, 1)
	RETURN @RET
 GO

ALTER TABLE EMPLOYEE_POSITION
ADD numberOfYears AS fn_numberOfYear(EmpPostionID)
GO

--15)	Write the query to return the list of routes that have at least 
--three stops between 12:30 PM and 5:15 PM in the neighborhood of Fremont.
SELECT RouteName FROM NEIGHBORHOOD N
JOIN [STOP] S ON N.NeighborhoodID = S.NeighborhoodID
JOIN SCHEDULE SC ON S.StopID = SC.StopID
JOIN [ROUTE] R ON SC.RouteID = R.RouteID
WHERE ScheduleTime BETWEEN '12:30' AND '17:15'
AND NeighborhoodName = 'Frement'
GROUP BY RouteName
HAVING Count(*) > 3

--16)	Write the query to return the list of students who had 
--at least 25 boardings on route '72 Express' in November 2015.
SELECT CustFname, CustLname, Count(*) AS number FROM CUSTOMER_TYOE CT
JOIN CUSTOMER C ON CT.CustTypeID = C.CustTypeID
JOIN BOARDING B ON C.CustID = B.CustID
JOIN SCHEDULE_TRIP ST ON B.ScheduleTripID = ST.ScheduleTripID
JOIN SCHEDULE S ON ST.ScheduleID = S.ScheduleID
JOIN [ROUTE] R ON S.RouteID = R.RouteID
JOIN ROUTE_TYPE RT ON R.RouteTypeID = RT.RouteTypeID

WHERE CT.CustTypeName = 'Student'
AND ST.ActualTime BETWEEN 'Nov 1, 2015' AND 'Nov 30, 2015'
AND RT.RouteTypeName = 'Express'
AND R.RouteName = '72'

GROUP BY CustID
HAVING Count(*) > 25

--17)	Write the query to return the three most-common/frequent maintenance
-- tasks on 'Double Decker' busses more than 6 years old.
SELECT MaintenanceName, Count(*) AS number FROM MAINTENANCE M
JOIN VEHICLE_MAINTENANCE VM ON M.MaintenanceID = VM.MaintenanceID
JOIN VEHICLE V ON VM.VehicleID = V.VehicleID
JOIN VEHICLE_TYPE VT ON V.VehicleTypeID = VT.VehicleTypeID
WHERE VehicleTypeName LIKE 'Double Decker'
AND FLOOR(DATEDIFF(DD,DatePurchased,GETDATE())/365.25) > 6
GROUP BY MaintenanceName
ORDER BY Count(*) DESC

--18)	Write the query to return the number of trips made to the Destination 
--of 'Space Needle' that had the amenity of 'Air Conditioning' from March 9, 2013 
--through October 3, 2014.
SELECT Count(*) AS 'number of trips' FROM AMENITY A
JOIN VEHICLE_AMENITY VA ON A.AmenityID = VA.AmenityID
JOIN VEHICLE V ON VA.VehicleID = V.VehicleID
JOIN TRIP T ON V.VehicleID = T.VehicleID
JOIN SCHEDULE_TRIP ST ON T.TripID = ST.TripID
JOIN SCHEDULE S ON ST.ScheduleID = S.ScheduleID
JOIN [ROUTE] R ON S.RouteID = R.RouteID
JOIN ROUTE_DESTINATION RD ON R.RouteID = RD.RouteID
JOIN DESTINATION D ON RD.DestID = D.DestID
WHERE DestName = 'Space Needle'
AND AmenityName = 'Air Conditioning'
AND TripDate BETWEEN 'March 9, 2013' AND 'October 3, 2014'

--19)	Write the query to return the percentage of 'Commuter Vans' were never 
--reported as 'Canceled' in June of 2016?

SELECT (Count(DISTINCT VehicleID) FROM VEHICLE_TYPE VT
		JOIN VEHICLE V ON VT.VehicleID = V.VehicleId
		JOIN TRIP T ON V.VehicleID = T.VehicleID
		JOIN TRIP_STATUS TS ON T.TripID = TS.TripID
		JOIN [STATUS] S ON TS.StatusID = S.StatusID
		WHERE VT.VehicleTypeName = 'Commuter Vans'
		AND S.StatusName <> 'Canceled'
		AND TripDate BETWEEN 'June 1, 2016' AND 'June 30, 2016') 
		/
		( 
		(SELECT Count(*) FROM VEHICLE_TYPE VT
		JOIN VEHICLE V ON VT.VehicleID = V.VehicleId
		JOIN TRIP T ON V.VehicleID = T.VehicleID
		JOIN TRIP_STATUS TS ON T.TripID = TS.TripID
		JOIN [STATUS] S ON TS.StatusID = S.StatusID
		WHERE VT.VehicleTypeName = 'Commuter Vans'
		AND TripDate BETWEEN 'June 1, 2016' AND 'June 30, 2016') / 100.00)

--20)	Write the query to return the list of routes with more than 2800 
--boardings in the University District neighborhood in the last 30 days.
SELECT RouteName, count(*) as number FROM [ROUTE] R
JOIN SCHEDULE S ON R.RouteID = S.RouteID
JOIN [STOP] SP ON SP.StopID = S.StopID
JOIN NEIGHBORHOOD H ON H.NeighborhoodID = SP.NeighborhoodID
JOIN SCHEDULE_TRIP ST ON S.ScheduleID = ST.ScheduleID
JOIN BOARDING B ON ST.ScheduleTripID = B.ScheduleTripID
JOIN TRIP T ON T.TripID = ST.TripID
WHERE NeighborhoodName = 'University District'
AND DATEDIFF(DD, T.TripDate, GETDATE()) <= 30
GROUP BY BoardingID
HAVING Count(*) > 2800

SELECT 10/3.0