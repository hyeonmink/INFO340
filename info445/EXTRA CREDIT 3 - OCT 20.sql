CREATE TABLE CLASS

CREATE TABLE STUDENT
(StudentID INT identity(1,1) not null primary key,
 Fname varchar(35) not null,
 Lname varchar(35) not null,
 DOB DATE not null)
GO

CREATE TABLE CLASS
(ClassID INT identity(1,1) not null primary key,
 CourseName varchar(35) not null,
 Semester varchar(35) not null)
GO

CREATE TABLE CLASS_LIST
(ClassListID INT identity(1,1) not null,
 StudentID INT FOREIGN KEY REFERENCES STUDENT(StudentID) not null,
 ClassID INT FOREIGN KEY REFERENCES CLASS(ClassID) not null)
GO

INSERT INTO STUDENT(Fname, Lname, DOB)
VALUES ('Nathan', 'Yin', getdate())

INSERT INTO STUDENT(Fname, Lname, DOB)
VALUES ('Jimi', 'Hendrix', 'Nov 27, 1942')

INSERT INTO STUDENT(Fname, Lname, DOB)
VALUES ('Bruce', 'Lee', 'Nov 27, 1940')

INSERT INTO CLASS(CourseName, Semester)
VALUES ('INFO340', 'Autumn')

INSERT INTO CLASS(CourseName, Semester)
VALUES ('INFO310', 'Winter')

INSERT INTO CLASS(CourseName, Semester)
VALUES ('INFO343', 'Spring')
GO

CREATE PROC addClassList
@Fname varchar(35),
@Lname varchar(35),
@DOB DATE,
@CourseName varchar(35),
@Semester varchar(35)

AS
BEGIN
	BEGIN TRY
		DECLARE @StudentID INT
		DECLARE @ClassID INT
		
		SET @StudentID = (SELECT StudentID FROM STUDENT
						  WHERE @Fname = Fname
						  AND @Lname = Lname
						  AND @DOB = DOB)
		SET @ClassID = (SELECT ClassID FROM CLASS
						 WHERE @CourseName = CourseName
						 AND @Semester = Semester)
		BEGIN TRAN T1
		INSERT INTO CLASS_LIST(StudentID, ClassID)
		VALUES(@StudentID, @ClassID)
		COMMIT Tran T1
	END TRY

	BEGIN CATCH
		IF @@ERROR <> 0
		THROW 58888, 'Error!', 1
		ROLLBACK Tran T1
	END CATCH
END

SELECT * FROM STUDENT
SELECT * FROM CLASS

EXEC addClassList 
@Fname = 'Nathan',
@Lname = 'Yin',
@DOB = '2016-10-20',
@CourseName = 'INFO340',
@Semester = 'Autumn'

EXEC addClassList 
@Fname = 'Bruce',
@Lname = 'Lee',
@DOB = '1940-11-27',
@CourseName = 'INFO310',
@Semester = 'Winter' 

EXEC addClassList 
@Fname = 'Jimi',
@Lname = 'Hendrix',
@DOB = '1942-11-27',
@CourseName = 'INFO343',
@Semester = 'Spring' 

SELECT * FROM CLASS_LIST