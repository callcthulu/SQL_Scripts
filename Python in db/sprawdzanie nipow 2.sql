

--table with Tax ID Numbers and versioning
/*
CREATE TABLE da.TaxIDs   
(     
   Number nvarchar(50) NOT NULL PRIMARY KEY CLUSTERED
   , Type int NOT NULL --1 - NIP, 2 - VAT UE, 0 - nieznany)
   , Status nvarchar(256) NULL --answer in response
   , VerificationDate datetime2 NULL --date when communicate was sent
   , ServerHttpStatus int NULL --server status
   , ServerHttpStatusText nvarchar(256) NULL --server status text
   , ServerResponseCode nvarchar(1) NULL --response letter code from server
   , ServerResponseText nvarchar(max) NULL --response text from server
   , SysStartTime datetime2 GENERATED ALWAYS AS ROW START NOT NULL  
   , SysEndTime datetime2 GENERATED ALWAYS AS ROW END NOT NULL  
   , PERIOD FOR SYSTEM_TIME (SysStartTime,SysEndTime)     
)    
WITH (SYSTEM_VERSIONING = ON)   
; 


--return type for proc
CREATE TYPE da.TaxIDsTableType AS TABLE
	(Number nvarchar(50) NOT NULL
   , Type int NOT NULL --1 - NIP, 2 - VAT UE, 0 - nieznany)
   , Status nvarchar(256) NULL --answer in response
   , VerificationDate datetime2 NULL --date when communicate was sent
   , ServerHttpStatus int NULL --server status
   , ServerHttpStatusText nvarchar(256) NULL --server status text
   , ServerResponseCode nvarchar(1) NULL --response letter code from server
   , ServerResponseText nvarchar(max) NULL --response text from server
   ) 



  GO

--in type for proc
CREATE TYPE da.TaxIDsIn AS TABLE
	(Number nvarchar(50) NOT NULL
   ) 

  GO
*/

ALTER PROC da.ClearTaxIDs
@InData da.TaxIDsIn READONLY
AS 
	BEGIN
		DECLARE @OutData da.TaxIDsIn
		INSERT INTO @OutData
		SELECT
			TRIM(' -_/,.' FROM Number)
		FROM @InData

		RETURN @OutData
	END


/*DECLARE @Table da.TaxIDSTableType
INSERT INTO @Table
	SELECT
		[BuyerIdentificationNumber],
		0,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL
	FROM [dbo].[JPK_VatRegisters]
	WHERE [BuyerIdentificationNumber] IS NOT NULL
EXEC da.ClearTaxIDs @Table*/

	--PROC1:
	--0. Clear special characters, white characters itp. (TRIM)
	--1. Check if VIES or NIP (CASE)
	--1a. NIP -> prefix PL or ten digits -> add type 1
	--1b. VIES -> not NIP, two letters at front --> add type 2
	--1c. Other --> add type 3
	--PROC2 - NIP:
	--2. Send data to Python
	--3. Run python Script for NIP service
	--4. Take return
	--PROC3 - VIES:
	--5. Send data to Python
	--6. Run python script for VIES service
	--7. Take return
	--REST:
	--Merge result to TaxIDs