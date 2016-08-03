
/*
Create three stored procedures:
a. Determine EmployeeID when passed @EmpFname, @EmpLname, and @EmpDOB
b. Determine FlightID when passed @DepartAirport, @ArrivalAirport and @DepartTime
c. INSERT a new row into FLIGHT_EMPLOYEE when passed @EmployeeID (called from stored procedure #1), @FlightID (called from stored procedure #2) and @RoleName

• Use error-handling with Control of Flow to enforce:
A) No employee can be on the same flight in two different roles  
B) No employee can be greater than 70 years’ old if they are listed as ‘Pilot’
C) Neither FlightID nor EmployeeID may be NULL
*/


CREATE PROC DetEmpID
	@EmpFname varchar(25),
	@EmpLname varchar(25),
	@EmpDOB date,
	@EmpID INT OUTPUT
AS
BEGIN
	BEGIN TRY
		SET @EmpID = 
			CASE
				WHEN EXISTS(SELECT * FROM EMPLOYEE E
							JOIN FLIGHT_EMPLOYEE FE ON E.EmployeeID = FE.EmployeeID
							JOIN [ROLE] R ON FE.RoleID = R.RoleID
							WHERE E.EmployeeFname = @EmpFname
							AND E.EmployeeLname = @EmpLname
							AND E.EmployeeDOB = @EmpDOB
							AND @EmpDOB > (GETDATE() - 365.25 * 70)
							AND R.RoleName = 'Pilot')
							THEN NULL

		
		(SELECT EmployeeID FROM EMPLOYEE E
					JOIN FLIGHT_EMPLOYEE FE ON E.EmployeeID = FE.EmployeeID
					JOIN [ROLE] R ON FE.RoleID = R.RoleID
					WHERE E.EmployeeFname = @EmpFname
					AND E.EmployeeLname = @EmpLname
					AND E.EmployeeDOB = @EmpDOB

	END TRY

	BEGIN CATCH
		THROW 55555, 'ERROR!', 1;
	END CATCH
END