use [UNIVERSITY]
/*
SELECT count(*) as 'total students'
FROM tblSTUDENT */

/*
SELECT count(*)
FROM tblCLASS a
JOIN tblCOURSE b
ON a.CourseID = b.CourseID
JOIN tblDEPARTMENT c
ON b.DeptID = c.DeptID
JOIN tblCOLLEGE d
ON c.CollegeID = d.CollegeID
JOIN tblQUARTER e
ON a.QuarterID = e.QuarterID

WHERE d.CollegeName = 'Business (Foster)'
AND a.YEAR >= 1950
AND e.QuarterName = 'Spring'
*/

--# of staff hired by college since 1968

-- how many courses of 400 level are in audotorium
/*
SELECT *
FROM tblCLASS a
	JOIN tblCOURSE b ON a.CourseID = b.CourseID
	JOIN tblCLASSROOM c ON a.ClassroomID = c.ClassroomID
	JOIN tblCLASSROOM_TYPE d ON c.ClassroomTypeID = d.ClassroomTypeID
	JOIN tblQUARTER e ON a.QuarterID = e.QuarterID

WHERE d.ClassroomTypeName = 'Auditorium'
AND a.YEAR = 1985
AND e.QuarterName = 'Winter'
AND b.CourseName LIKE '%4__'
*/

/*when was ENGL317 offered in SmithHall
SELECT CourseName, BuildingName, [YEAR], QuarterName
FROM tblCLASS a
	JOIN tblCOURSE b ON a.CourseID = b.CourseID
	JOIN tblCLASSROOM c ON a.ClassroomID = c.ClassroomID 
	JOIN tblBUILDING d ON d.BuildingID = c.BuildingID
	JOIN tblQUARTER e ON a.QuarterID = e.QuarterID
WHERE b.CourseName = 'ENGL317'

ORDER BY [YEAR] ASC */

--how many students live in mcmahon hall and taking psy101 not suspended
SELECT *
FROM tblSTUDENT a
JOIN tblSTUDENT_DORMROOM b ON a.StudentID = b.StudentID
JOIN tblDORMROOM c ON b.DormRoomID = c.DormRoomID
JOIN tblBUILDING d ON c.BuildingID = d.BuildingID
JOIN tblSTUDENT_STATUS e ON e.StudentID = a.StudentID
JOIN tblSTATUS f ON e.StatusID = f.StatusID






