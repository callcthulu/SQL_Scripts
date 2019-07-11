/*
INFO:
Poniżej znajduje się generator jsona na bazie definicji tabeli na bazie sql server. Obecnie generuje on defincje dla jednej tabeli na raz. Enjoy!

INSTRUKCJA:
1. Wpisz nazwę bazy danych po "USE"
2. Wpisz nazwę tabeli po SET @tableName = , pamiętaj o cudzysłowiu pojedynczym, np. SET @tableName = 'JPK_VatInvoices'
3. Odpal zapytanie na bazie danych w sql server
4. Kliknij na wynik, otworzy się wynik zapytania w nowej zakładce (jeżeli spróbujesz skopiować bezpośrednio wynik zapytania to najpewniej skopiujesz tylko fragment!)
5. Powtórz dla każdj tabeli w ramach danej struktury dla API
6. Uzupełnij jsona o sekcję "Tables" i "Relations" (jeśli chcesz zobaczyć jak to ma wyglądać wystarczy odkomentować zakomentowany fragment zapytania na początku i końcu)
7. Powinieneś mieć poprawnąstrkturę json dla Twojej strktury API -> dla pewności sprawdź tutaj: https://jsonformatter.curiousconcept.com/

CHANGELOG:
v0.11 OL - poprawa błędów w oparciu o walidacje jsona w oparciu o https://jsonformatter.curiousconcept.com/ 
v0.1 OL - utworzenie zapytania
*/

USE [42cc123c-8e9d-4df3-ba3e-54b3324d95a5] -- <<<<<TU WPISZ BAZĘ GDZIE JEST TABELA DLA KTÓREJ GENERUJESZ JSONA
GO

DECLARE @tableName nvarchar(4000)
SET @tableName = 'JPK_VatInvoices' -- <<<<<TU WPISZ NAZWĘ TABELI DLA KTÓREJ CHCESZ GENEROWAĆ JSONA

/* 

A teraz odpal zapytanie i idź do Nero na kawę. Normalnie zajęłoby Ci to parę godzin klepania :P

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

--Oskar L. 15.09.2017