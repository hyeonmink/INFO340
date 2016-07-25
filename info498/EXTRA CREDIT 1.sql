/*
Min Kim
1238304
INFO498
Extra Credit 1
07/25/2016
*/

--1. Write the code to return the entire cast of every horror movie released in the 1990's by year.
SELECT DISTINCT YEAR(M.MovieReleaseDate) AS ReleasedDate, MovieName, ProFirstName, ProLastName
FROM GENRE G
	JOIN MOVIE_GENRE MG ON G.GenreID = MG.GenreID
	JOIN MOVIE M ON MG.MovieID = M.MovieID
	JOIN [CAST] C ON M.MovieID = C.MovieID
	JOIN PROFESSIONAL P ON C.ProID = P.ProID
WHERE GenreName = 'horror'
	AND YEAR(M.MovieReleaseDate) LIKE (199_) 
GROUP BY YEAR(M.MovieReleaseDate), MovieName
ORDER BY MovieReleaseDate ASC
GO
 




--2. Write the code to prevent customers from renting more than 6 romance movie in any 12-month period

CREATE FUNCTION fn_no6RomanceIn12Month()
RETURNS INT
AS
BEGIN

DECLARE @RET INT = 0
IF EXISTS(
	SELECT * FROM GENRE G
	JOIN MOVIE_GENRE MG		ON G.GenreID = MG.GenreID
	JOIN MOVIE M			ON MG.MovieID = M.MovieID
	JOIN DISC D				ON M.MovieID = D.MovieID
	JOIN RENTAL R			ON D.DiscID = R.DiscID
	WHERE DATEDIFF(MM, R.RentalDate, GETDATE()) <= 12 
	AND G.GenreName = 'Romance'
	GROUP BY R.CustomerID
	HAVING count(R.CustomerID) > 6
)
SET @RET = 1
RETURN @RET
END


ALTER TABLE RENTAL
ADD CONSTRAINT ck_no6RomanceIn12Month
CHECK(dbo.fn_no6RomanceIn12Month() = 0) 
