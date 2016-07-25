
--06/29/2016 LAB

use hyeonmin


CREATE TABLE CUSTOMER
(CustomerID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
CustFName varchar(35) NOT NULL,
CustLName varchar(35) NOT NULL,
CustBirth date NULL,
CustEmail varchar(100) NULL,
CustAddress varchar(100) NOT NULL,
CustCity varchar(50) NOT NULL,
CustState varchar(30) NOT NULL,
CustZip VARCHAR(12) NOT NULL)


/*
INSERT INTO CUSTOMER (CustFName, CustLName,CustEmail,CustAddress, CustCity, CustState, CustZip)
VALUES('Rocko', 'Bell', 'rocko.bell@uw.edu', '4145 11th ave ne', 'Seattle', 'WA', '98105')
*/ 

INSERT INTO CUSTOMER (CustFName, CustLName, CustBirth, CustEmail,CustAddress, CustCity, CustState, CustZip)
SELECT CustomerFname, CustomerLname, DateOfBirth ,Email, CustomerAddress, CustomerCity, CustomerState, CustomerZIP
FROM [CUSTOMER_BUILD].dbo.[tblCUSTOMER]
WHERE CustomerState = 'WAshington, WA'
OR CustomerState= 'California, CA'
OR CustomerState = 'Nebraska, NE'

DELETE CUSTOMER
WHERE CustState <> 'Washington, WA'
AND CustState <> 'California%'
AND CustState <> 'Nebraska%'


SELECT CustState, Count(*) as [people]
FROM CUSTOMER
GROUP BY CustState
HAVING Count(*) > 75
ORDER BY Count(*) DESC




/*
--People born in Utah in 1960s
SELECT *
FROM [dbo].[CUSTOMER]
WHERE CustState = 'Utah, UT'
--AND CustBirth Between 'Jan 1 1960' AND 'Dec 31, 1969'
AND YEAR(CustBirth) Between '1960' AND '1969' 
ORDER BY CustBirth ASC
*/ 

/*
--Delete the people from Idaho, born before marh 3, 1980
Delete FROM CUSTOMER
WHERE CustState = 'Idaho, ID'
AND CustBirth < 'March 3, 1980'
*/

--city of Hawaii

/*
--change the address of people from Alaska to Pearl Harbor, Hawaii
UPDATE CUSTOMER
SET CustCity = 'Pearl Harbor', CustState = 'Hawaii, HI', CustZip = '96860'
WHERE Custstate = 'Alaska, AK'
*/


UPDATE CUSTOMER
SET 
WHERE

SELECT *
FROM CUSTOMER