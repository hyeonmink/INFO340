/*
Min Kim
1238304
LAB2 - INFO340
Prof. Greg Hay
07/08/2016
*/




USE [BOOK_CLUB]

--How many reviews submitted in the past 36 months 
--are of a comment type 'Positive' for book-signing events?
SELECT Count(*) as 'number' FROM tblCOMMENT_TYPE CT
	JOIN tblCOMMENT C ON CT.CommentTypeID = C.CommentTypeID
	JOIN tblREVIEW R ON C.ReviewID = R.ReviewID
	JOIN tblEVENT E ON R.EventID = E.EventID
	JOIN tblEVENT_TYPE ET ON E.EventTypeID = ET.EventTypeID

	WHERE ET.EventTypeName = 'book-signing'
	AND CT.CommentTypeName = 'Positive'
	AND YEAR(GETDATE()) - YEAR(R.ReviewDate) < 3 



--How many publishers are in London and Paris 
--with female authors from Argentina?
SELECT Count(*) as 'Number' FROM tblPUBLISHER P
	JOIN tblBOOK B		ON P.PublisherID = B.PublisherID
	JOIN tblAUTHOR A	ON B.AuthorID = A.AuthorID
	JOIN tblGENDER G	ON A.GenderID = G.GenderID
	JOIN tblCOUNTRY C	ON A.CountryID = C.CountryID
WHERE (P.PublisherCity = 'London' OR P.PublisherCity = 'Paris')
AND G.GenderName = 'Female'
AND C.CountryName = 'Argentina'



--What is the total amount of fees collected for book 
--reviews of romance novels in 2013?
SELECT SUM(F.FeeAmount) FROM tblFEE F
	JOIN tblEVENT_FEE EF	ON F.FeeID = EF.FeeID
	JOIN tblEVENT E			ON EF.EventID = E.EventID
	JOIN tblEVENT_TYPE ET	ON E.EventTypeID = ET.EventTypeID
	JOIN tblASSIGNMENT A	On E.AssignmentID = A.AssignmentID
	JOIN tblBOOK B			On A.BookID = B.BookID
	JOIN tblGENRE G			ON B.GenreID = G.GenreID

	WHERE	ET.EventTypeName = 'Book Review'
	AND		G.GenreName = 'Romance'
	AND		E.EventDate Between 'Jan 01, 2013' AND 'DEC 31,2013'

--OR
SELECT SUM(E.TotalFeeAmount) FROM tblEVENT E
	JOIN tblEVENT_TYPE ET	ON E.EventTypeID = ET.EventTypeID
	JOIN tblASSIGNMENT A	On E.AssignmentID = A.AssignmentID
	JOIN tblBOOK B			On A.BookID = B.BookID
	JOIN tblGENRE G			ON B.GenreID = G.GenreID

	WHERE	ET.EventTypeName = 'Book Review'
	AND		G.GenreName = 'Romance'
	AND		E.EventDate Between 'Jan 01, 2013' AND 'DEC 31,2013'


--What are the three most-popular beverages for members 
--younger than 28 who reside in California?
SELECT * FROM tblPREFERENCE_TYPE PT
	JOIN tblPREFERENCE P			ON PT.PreferenceTypeID = P.PreferenceTypeID
	JOIN tblMEMBER_PREFERENCE MP	ON P.PreferenceID = MP.PreferenceID
	JOIN tblMEMBER M				ON MP.MemberID = M.MemberID
	
WHERE PT.PreferenceTypeName = 'beverages'
AND M.MemberState = 'California'
AND DATEDIFF(YY, M.BirthDate, GETDATE()) <28

GROUP By P.PreferenceName
ORDER BY Count(P.PreferenceName) DESC

