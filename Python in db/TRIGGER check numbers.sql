CREATE TRIGGER ValidateNumbers
ON [dbo].[JPK_VatRegisters]
AFTER INSERT, UPDATE
AS
	BEGIN
	--clear and insert data for VIES
		INSERT INTO [da].[TaxIDs]
           ([Number]
           ,[Type]
           ,[Status]
           ,[VerificationDate]
           ,[ServerHttpStatus]
           ,[ServerHttpStatusText]
           ,[ServerResponseCode]
           ,[ServerResponseText])
		SELECT
			distinct TRIM(' _-/\,.' FROM [BuyerIdentificationNumber]),
			2,
			NULL, -- status
			NULL, --verDate
			NULL, --serverhttpstatus
			NULL, --serverhttpstatustext
			NULL, --serverResponseCode
			NULL --serverResponseText
		FROM inserted
		WHERE [BuyerIdentificationNumber] IS NOT NULL AND lower(BuyerIdentificationNumber) NOT LIKE 'pl%' AND lower(BuyerIdentificationNumber) LIKE '[a-z][a-z]%'

	--clear and insert data for NIP with PL
		INSERT INTO [da].[TaxIDs]
           ([Number]
           ,[Type]
           ,[Status]
           ,[VerificationDate]
           ,[ServerHttpStatus]
           ,[ServerHttpStatusText]
           ,[ServerResponseCode]
           ,[ServerResponseText])
		SELECT
			distinct SUBSTRING(TRIM(' _-/\,.' FROM [BuyerIdentificationNumber]),3,400),
			1,
			NULL, -- status
			NULL, --verDate
			NULL, --serverhttpstatus
			NULL, --serverhttpstatustext
			NULL, --serverResponseCode
			NULL --serverResponseText
		FROM inserted
		WHERE [BuyerIdentificationNumber] IS NOT NULL AND lower(BuyerIdentificationNumber) LIKE 'pl%'

	--clear and insert data for NIP without PL
		INSERT INTO [da].[TaxIDs]
           ([Number]
           ,[Type]
           ,[Status]
           ,[VerificationDate]
           ,[ServerHttpStatus]
           ,[ServerHttpStatusText]
           ,[ServerResponseCode]
           ,[ServerResponseText])
		SELECT
			distinct TRIM(' _-/\,.' FROM [BuyerIdentificationNumber]),
			1,
			NULL, -- status
			NULL, --verDate
			NULL, --serverhttpstatus
			NULL, --serverhttpstatustext
			NULL, --serverResponseCode
			NULL --serverResponseText
		FROM inserted
		WHERE [BuyerIdentificationNumber] IS NOT NULL AND isnumeric(TRIM(' _-/\,.' FROM [BuyerIdentificationNumber])) = 1


	END