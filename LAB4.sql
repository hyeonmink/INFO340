




--1) Write the code to create a computed column to track the running total of dollars spent for each customer.
CREATE FUNCTION fn_runningTotal(@CustID INT) 
RETURNS Numeric(10,2) AS
BEGIN
RETURN 
	(SELECT SUM(Price)  
	FROM tblCUSTOMER C
	JOIN tblORDER O ON C.CustID = O.CustID
	JOIN tblLINE_ITEM LI ON O.OrderID = LI.OrderID
	JOIN tblPRODUCT_VENDOR PV ON LI.ProductVendorID = PV.ProductVendorID  
	GROUP BY CustID  
	HAVING CustID = @CustID)
END


ALTER TABLE tblCUSTOOMER ADD RunningTotal AS fn_donationTotal(CustID)
 



--2) Write the code to create a stored procedure to add a new product for an existing vendor. 
--   HINT: pass in ‘name’ values as parameters.

CREATE PROC AddProduct
@ProductTypeName varchar(35),
@ProductName varchar(35),
@ProductDescr varchar(1000),
@Price MONEY,
@VendorName varchar(35)

AS
DECLARE @ProductTypeID INT
DECLARE @ProductID INT
DECLARE @VendorID INT

SET @VendorId = (SELECT VendorID FROM tblVENDOR 
				 WHERE VendorName = @VendorName)

BEGIN Tran T1
SET @ProductTypeID = (SELECT ProductTypeID FROM tblPRODUCT_TYPE 
					  WHERE ProductTypeID = @ProductTypeID)

INSERT INTO tblPRODUCT(ProductTypeID, ProductName, ProductDescr)
VALUES (@ProductTypeID, @ProductName, @ProductDescr)
SET @ProductID = (SELECT SCOPE_IDENTITY())

INSERT INTO tblPRODUCT_VENDOR (ProductID, VendorID, Price)
VALUES (@ProductID, @VendorID, @Price)



--3) Write the query to determine the 5 most-popular products sold by 
--   all vendors since March 5, 2007 who are defined as ‘vintage re-sellers’.

SELECT *
FROM tblVENDOR_TYPE VT
JOIN tblVENDOR V ON VT.VendorTypeID = V.VendorTypeID
JOIN tblPRODUCT_VENDOR PV ON V.VendorID = PV.VendorID
JOIN tblProduct P ON P.ProductID = PV.ProductID
JOIN tblLINE_ITEM LI ON PV.ProductVendorID = LI.ProductVendorID
JOIN tblORDER O ON LI.OrderID = O.OrderID

WHERE VT.VendorTypeName = 'vintage re-sellers'
AND O.OrderDate Between 'March 5, 2007' AND 'GETDATE()'

 --TODO: FINISH NO3.

 

 

--4)     Write the query to determine the number of employees that have 
--  expert-level skills in piano or guitar repair that reside in California, 
--  Utah or Washington breaking-out results by each state.

--5) Write the code to create a business rule that limits customers from Texas from purchasing more than 6 t-shirts in the previous 3 years.

