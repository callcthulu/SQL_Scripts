
/*
--table with Tax ID Numbers and versioning
CREATE TABLE da.TaxIDs   
(     
   Number nvarchar(50) NOT NULL
   , Type int NOT NULL /*1 - NIP, 2 - VAT UE, 0 - nieznany)*/
   , Status nvarchar(256) NULL --answer in response
   , VerificationDate datetime2 NULL --date when communicate was sent
   , ServerResponseNumber int NULL --response number from server
   , ServerResponseText nvarchar(max) NULL --response text from server?
   , SysStartTime datetime2 GENERATED ALWAYS AS ROW START NOT NULL  
   , SysEndTime datetime2 GENERATED ALWAYS AS ROW END NOT NULL  
   , PERIOD FOR SYSTEM_TIME (SysStartTime,SysEndTime)     
)    
WITH (SYSTEM_VERSIONING = ON)   
; 


--type for proc
CREATE TYPE da.TaxIDsTableType AS TABLE
	(Number nvarchar(50) NOT NULL
   , Type int NOT NULL /*1 - NIP, 2 - VAT UE, 0 - nieznany)*/
   , Status nvarchar(256) NULL --answer in response
   , VerificationDate datetime2 NULL --date when communicate was sent
   , ServerResponseNumber int NULL --response number from server
   , ServerResponseText nvarchar(max) NULL --response text from server?
   ) 

   GO
*/

CREATE PROC da.CheckTaxIds
@Table da.TaxIDSTableType
AS

	

