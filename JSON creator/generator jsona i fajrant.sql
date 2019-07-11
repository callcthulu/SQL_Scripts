/*
INFO:
Poniżej znajduje sięwersja apha generatora jsona na bazie definicji tabeli na bazie sql server. Obecnie generuje on deifincje dla jednej tabeli na raz. Enjoy!
*/

USE [42cc123c-8e9d-4df3-ba3e-54b3324d95a5] -- <<<<<TU WPISZ BAZĘ GDZIE JEST TABELA DLA KTÓREJ GENERUJESZ JSONA
GO

declare @tableName nvarchar(4000)
set @tableName = 'JPK_VatInvoices' -- <<<<<TU WPISZ NAZWĘ TABELI DLA KTÓREJ CHCESZ GENEROWAĆ JSONA

-- a teraz odpal zapytanie i idź do Nero na kawę. Normalnie zajęłoby Ci to parę godzin :P

/*
generator JSONa, po co pracować skoro mozna udawać, że się pracuje?


                                                                    ..%%%%%
                                                          ...    .%%%%%%""
                                                       .%%%%%%%/%%%%%"
                                     .....           .%%%%%%%%%%%%%%\
                                ..:::::::::::..      :;""  {_}\%%/%%%%%%..
                              .:::::::::::::::::.            {_}/{_}%%%%%%%
                             :::::::::::::::::::::            \\//    """\::
                            :::::::::::::::::::::::           \\//
---____-----__---------_____----....-----..--.....~-----_____-\\//---_____-
-----___---___----____--__--_.----...----...----..---__--_-___\\//--___--__
--____----__-___-----____----_...-----..--..---..___-------__\\//_-----____
___----____------____---__--___..--..-..----....___-----___--\\//_---__----
---___--___--__---__----___---___..----------._---____-----__\\//___---__--
--___---_-___-------______------___--___----___--__------___-\\//__--__----
____------____----_________------__                         \\//
--_____--__--____                              '            \\//  _
__---                 @            ,                  "          {_}
             .                            '                            cgmm

*/
SELECT
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
			b.TABLE_NAME,
			'", ',

	--lista kluczy
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