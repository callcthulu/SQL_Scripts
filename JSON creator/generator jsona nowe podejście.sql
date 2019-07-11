
--dane ogólne
@NazwaKonfiguracji = ''
@WersjaKonfiguracji = 1
@NazwaAdaptera = ''

--dane o kluczu
@NazwaKlucza = 'Id'
@TypDanych ='integer'


ELECT
/* do włączenia jak będzie obsługa wielu tabel, ale to wymaga jakiejś procedurki żeby zrobić pętle
CONCAT(
--'{ ',
'"Tables": [ ',
*/
STUFF(
	(SELECT
	--lista tabel
		REVERSE(
		STUFF(
		REVERSE(
		CONCAT(
			'{ "TableName": "', 
			tb.[Name],
			'", ',

	--lista kluczy- do poprawienia - uprościć
			'"PrimaryKey": [',
				REVERSE(
				STUFF(
				REVERSE(
				STUFF(
				(
					SELECT
						CASE
								WHEN c.CONSTRAINT_NAME IS NULL
								THEN ''
						ELSE
							a.json_column
						END
					FROM
							(SELECT
								COLUMN_NAME,
								ORDINAL_POSITION,
								TABLE_NAME,
								CONCAT(
								'{ "ColumnName": "',
								a.COLUMN_NAME,
								'", "Ordinal": ',
								a.ORDINAL_POSITION-1,
								', "Type": "',
								CASE
									WHEN a.DATA_TYPE = 'nvarchar'
									THEN 'text'
									ELSE a.DATA_TYPE
								END,
								'"',
								CASE
									WHEN a.DATA_TYPE = 'nvarchar'
									THEN CONCAT(', "Lenght": ',
										CASE
											WHEN a.CHARACTER_MAXIMUM_LENGTH = -1 OR a.CHARACTER_MAXIMUM_LENGTH > 4000
											THEN 4000
											ELSE a.CHARACTER_MAXIMUM_LENGTH
										END)
									WHEN a.DATA_TYPE = 'decimal'
									THEN CONCAT(', "Scale": ', a.NUMERIC_SCALE, ', "Precision": ', a.NUMERIC_PRECISION)
									ELSE ''
								END,
								', "Mandatory": ',
								CASE
									WHEN a.IS_NULLABLE = 'NO'
									THEN 'true'
									ELSE 'false'
								END,
								', "IsDefaultNaturalKey": false }, ') AS json_column
							FROM
								INFORMATION_SCHEMA.COLUMNS AS a
							WHERE 
								a.TABLE_NAME = @tableName
							) AS a
					LEFT JOIN 
							INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS c ON a.TABLE_NAME = c.TABLE_NAME AND a.COLUMN_NAME = c.COLUMN_NAME
					ORDER BY a.ORDINAL_POSITION
					for xml path('')
				)
				, 1, 0, '') 
				)
				, 1, 2, '')
				),
			'],',

		--lista kolumn
			'"Columns":[ ',
				REVERSE(
				STUFF(
				REVERSE(
				STUFF(
				(
					SELECT
						CASE
								WHEN c.CONSTRAINT_NAME IS NOT NULL
								THEN ''
						ELSE
							a.json_column
						END
					FROM
							(SELECT
								COLUMN_NAME,
								ORDINAL_POSITION,
								TABLE_NAME,
								CONCAT(
								'{ "ColumnName": "',
								a.COLUMN_NAME,
								'", "Ordinal": ',
								a.ORDINAL_POSITION-1,
								', "Type": "',
								CASE
									WHEN a.DATA_TYPE = 'nvarchar'
									THEN 'text'
									ELSE a.DATA_TYPE
								END,
								'"',
								CASE
									WHEN a.DATA_TYPE = 'nvarchar'
									THEN CONCAT(', "Lenght": ',
										CASE
											WHEN a.CHARACTER_MAXIMUM_LENGTH = -1 OR a.CHARACTER_MAXIMUM_LENGTH > 4000
											THEN 4000
											ELSE a.CHARACTER_MAXIMUM_LENGTH
										END)
									WHEN a.DATA_TYPE = 'decimal'
									THEN CONCAT(', "Scale": ', a.NUMERIC_SCALE, ', "Precision": ', a.NUMERIC_PRECISION)
									ELSE ''
								END,
								', "Mandatory": ',
								CASE
									WHEN a.IS_NULLABLE = 'NO'
									THEN 'true'
									ELSE 'false'
								END,
								', "IsDefaultNaturalKey": false }, ') AS json_column
							FROM
								INFORMATION_SCHEMA.COLUMNS AS a
							WHERE 
								a.TABLE_NAME = @tableName
							) AS a
					LEFT JOIN 
							INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS c ON a.TABLE_NAME = c.TABLE_NAME AND a.COLUMN_NAME = c.COLUMN_NAME
					ORDER BY a.ORDINAL_POSITION
					for xml path('')
				)
				, 1, 0, '') 
				)
				, 1, 2, '')
				),
			' ]',
			' }, '
		)
		)
		, 1, 2, '')
		)
	FROM
		INFORMATION_SCHEMA.TABLES AS b
	WHERE 
		TABLE_NAME = @tableName
	ORDER BY b.TABLE_NAME
	FOR XML PATH('')
	)
, 1, 0, '')
/*do włączenia jak będzie obsługa wielu tabel, ale to wymaga procedurki
--,
--'], ',
--'"Relations":[ ] }'
--)
*/
FROM INFORMATION_SCHEMA.TABLES AS d
WHERE
	TABLE_NAME = @tableName
FOR XML PATH('')



tb.[Name],
col.name,
col.OrderNumber,
col.DataType, --słownik: 0 - boolean, 4 - text, 5 - datetime, 3 - decimal, 1 - integer, 6 - uniquercośtam, 7 - date, 2 - Long?
col.Lenght,
col.Scale,
col.Precision,
col.Mandatory --0 albo 1
--gdzie jest klucz!?

[IMP_ImportProcessConfig] AS name
[IMP_ImportProcessConfigVersion] AS v
[IMP_AdapterMapping] AS map
[IMP_AdapterColumnMapping] AS mapcol
[IMP_RawDataTable] AS tb
[IMP_RawDataTableColumn] AS col

name.[ImportProcessConfigId] =  v.[ImportProcessConfigId]
v.[ImportProcessConfigVersionId] = map.[ImportProcessConfigVersionId]
map.[AdapterMappingId] = mapcol.[AdapterMappingId]
mapcol.[TaxTableRdtColumnId] = col.[RawDataTableColumnId]
map.[TaxTableRdtSchemaId] = tb.[TaxTableRdtSchemaId]

WHERE
name.[Name] = @NazwaKonfiguracji
v.[VersionNumber] = @WersjaKonfiguracji
tb.[Name] = @NazwaAdaptera







klucz główny - poza strkturą, definiuje programista