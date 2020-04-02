/*
v 0.13 08.01
*/
--paste catalog name below:
--USE
--[42cc123c-8e9d-4df3-ba3e-54b3324d95a5]
--GO

DECLARE @collationa nvarchar(256)
--paste correct collation below as value of variable:
SET @collationa = 'Polish_CI_AS'

/* 
--alternatively use function below to set variable as collation of current database catalog:
SET @collationa = SELECT DATABASEPROPERTYEX(DB_NAME, 'Collation')
*/

/*STEP 1: DROP INDEXES, PK, FK, CONTRAINS */

--FK
SELECT
CONCAT(
	'ALTER TABLE [',tableschema,'].[',a.tablename,'] DROP CONSTRAINT [',a.fk,'];',char(13)
	)
FROM
	(
	SELECT TABLE_NAME as tablename, CONSTRAINT_NAME as fk, TABLE_SCHEMA as tableschema
	FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
	WHERE CONSTRAINT_TYPE = 'FOREIGN KEY'
	) as a;

--PK
SELECT
CONCAT(
	'ALTER TABLE [',tableschema,'].[',a.tablename,'] DROP CONSTRAINT [',a.pk,'];',char(13)
	)
FROM
	(
	SELECT TABLE_NAME as tablename, CONSTRAINT_NAME as pk, TABLE_SCHEMA as tableschema
	FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
	WHERE CONSTRAINT_TYPE = 'PRIMARY KEY'
	) as a;

--INDEXES
SELECT
CONCAT(
	'DROP INDEX [',a.indexname,'] ON [',tableschema,'].[',a.tablename,'];',char(13)
	)
FROM
	(
	SELECT i.name as indexname, i.type, OBJECT_NAME(i.object_id) as tablename, OBJECT_SCHEMA_NAME(i.object_id) AS tableschema
	FROM sys.indexes as i
	INNER JOIN sys.tables t ON i.object_id = t.object_id
	WHERE i.is_primary_key = 0
	) as a;


/* STEP 2: ALTER COLLATION*/
SELECT
CONCAT(
	'ALTER TABLE [',TABLE_SCHEMA,'].[',TABLE_NAME,'] ALTER COLUMN [',COLUMN_NAME,'] ',DATA_TYPE, --ADD SCHEMA NAME IF NECESSARY!
	'(',CASE WHEN CHARACTER_MAXIMUM_LENGTH = -1 THEN 'MAX' ELSE CHARACTER_MAXIMUM_LENGTH END,') ',
	'COLLATE ',@collationa,
	' ', CASE WHEN IS_NULLABLE = 'NO' THEN 'NOT NULL' ELSE 'NULL' END,
	';',char(13)
	)
	
FROM(
	SELECT TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, COLLATION_NAME, DATA_TYPE, CAST(CHARACTER_MAXIMUM_LENGTH AS NVARCHAR(256)) AS CHARACTER_MAXIMUM_LENGTH , IS_NULLABLE
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE collation_name != @collationa
	AND collation_name IS NOT NULL) as a;

/*STEP 3: CREATE INDEXES, PK, FK, CONSTRAINS*/
--PK
SELECT
CONCAT(
	'ALTER TABLE [',a.tableschema,'].[',a.tablename, ']',char(13),'ADD CONSTRAINT [',a.pk, 
	']',char(13),'PRIMARY KEY ', CASE WHEN a.indextype = 1 THEN 'CLUSTERED' ELSE '' END,
	' (', a.columnname,')',char(13),
	CASE WHEN a.index_object_id IS NOT NULL
	THEN CONCAT(
		'WITH',char(13),
		'(',char(13),
		'PAD_INDEX = ',
		CASE WHEN a.is_padded = 1 THEN 'ON' ELSE 'OFF' END,char(13),
		CASE WHEN a.fill_factor > 0 THEN CONCAT(', FILLFACTOR =', a.fill_factor,char(13)) ELSE '' END,
		', IGNORE_DUP_KEY = ',
		CASE WHEN a.ignore_dup_key = 1 THEN 'ON' ELSE 'OFF' END,char(13),
		', ALLOW_ROW_LOCKS = ',
		CASE WHEN a.allow_row_locks = 1 THEN 'ON' ELSE 'OFF' END,char(13),
		', ALLOW_PAGE_LOCKS = ',
		CASE WHEN a.allow_page_locks = 1 THEN 'ON' ELSE 'OFF' END,char(13),
		', DATA_COMPRESSION = ',
		CASE WHEN a.data_compression = 1 THEN 'ROW' WHEN a.data_compression = 2 THEN 'PAGE' ELSE 'NONE' END,char(13),
		--there is no support for 'ON PARTITION' parameter in current version
		')'
	) ELSE '' END,
	';',char(13))
	FROM 
	(
	SELECT c.TABLE_NAME as tablename, c.TABLE_SCHEMA as tableschema, c.CONSTRAINT_NAME as pk,
	i.type as indextype, i.allow_row_locks, i.allow_page_locks, i.ignore_dup_key, i.fill_factor, i.is_padded, p.data_compression, i.object_id as index_object_id,
	STUFF(
	(SELECT
		CASE
			WHEN column_name IS NOT NULL
			THEN
			CONCAT(', [',COLUMN_NAME,']')
			ELSE NULL
		END
		FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE AS col
		WHERE c.CONSTRAINT_NAME = col.CONSTRAINT_NAME
		AND c.TABLE_NAME = col.TABLE_NAME
		FOR XML PATH ('')
	),1,2,'') AS columnname
	FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS c
	--LEFT JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS AS rc ON c.CONSTRAINT_NAME = rc.CONSTRAINT_NAME --there is no update or delete rule for pk
	LEFT JOIN [sys].[key_constraints] as kc ON kc.type = 'PK' AND kc.name = c.CONSTRAINT_NAME --v0.12
	LEFT JOIN [sys].[indexes] as i ON kc.parent_object_id = i.object_id AND kc.unique_index_id = i.index_id AND i.is_primary_key = 1 --v0.12
	LEFT JOIN
	--in this version there is no support for multiple ways of data_compression or few partitions to one index
	(SELECT
		object_id,
		index_id,
		MAX(data_compression) AS data_compression
	FROM sys.partitions
	GROUP BY object_id, index_id) AS p ON i.index_id = p.index_id AND i.object_id = p.object_id
	WHERE c.CONSTRAINT_TYPE = 'PRIMARY KEY'
	) as a

--FK
SELECT
CONCAT(
	'ALTER TABLE [',a.tableschema,'].[',a.tablename,']',CASE WHEN a.is_not_trusted = 0 THEN 'WITH CHECK' ELSE 'WITH NOCHECK' END, char(13),
	'ADD ', ' CONSTRAINT [',a.fk, '] FOREIGN KEY (', a.columnname,')',
	char(13),'REFERENCES ',
	'[',a.referenceschema,'].[',a.referencetable,']',
	' (',a.referencecolumn,')',
	CASE WHEN a.update_rule = 'NO ACTION' THEN '' ELSE CONCAT(char(13),' ON UPDATE ',a.update_rule) END,
	CASE WHEN a.delete_rule = 'NO ACTION' THEN '' ELSE CONCAT(char(13),' ON DELETE ',a.delete_rule) END,
	';',char(13))
	FROM 
	(
	SELECT c.TABLE_NAME as tablename, c.TABLE_SCHEMA as tableschema, c.CONSTRAINT_NAME as fk, sysfk.is_not_trusted, --v0.12
	STUFF(
	(SELECT
		CASE
			WHEN col.column_name IS NOT NULL
			THEN
			CONCAT(', [',col.COLUMN_NAME,']')
			ELSE NULL
		END
		FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE AS col
		WHERE c.CONSTRAINT_NAME = col.CONSTRAINT_NAME
		AND c.TABLE_NAME = col.TABLE_NAME
		FOR XML PATH ('')
	),1,2,'') AS columnname,
	STUFF(
	(SELECT
		CASE
			WHEN col2.column_name IS NOT NULL
			THEN
			CONCAT(', [',col2.COLUMN_NAME,']')
			ELSE NULL
		END
		FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE AS col2
		WHERE rc.UNIQUE_CONSTRAINT_NAME = col2.CONSTRAINT_NAME
		--AND rc.TABLE_NAME = col.TABLE_NAME --there no info about unique coinstraint table in rc view
		FOR XML PATH ('')
	),1,2,'') AS referencecolumn,
	pkt.TABLE_SCHEMA as referenceschema,
	pkt.TABLE_NAME AS referencetable,
	rc.delete_rule,
	rc.update_rule
	FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS c
	LEFT JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS AS rc ON c.CONSTRAINT_NAME = rc.CONSTRAINT_NAME
	LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS pkt ON rc.UNIQUE_CONSTRAINT_NAME = pkt.CONSTRAINT_NAME
	LEFT JOIN sys.foreign_keys AS sysfk ON sysfk.type = 'F' AND sysfk.name = c.CONSTRAINT_NAME --v0.12
	WHERE c.CONSTRAINT_TYPE = 'FOREIGN KEY'
	) as a
	
--INDEXES
/*
- there are only clustered and nonclustered types of indexes
- there is no support for few partitions on one index
- there is no support for multiple data_compression types for one index
*/
SELECT
CONCAT(
	'CREATE ',
	CASE WHEN IsUniqueIndex = 1 THEN 'UNIQUE' ELSE '' END, --if unique
	' ',
	CASE WHEN a.type = 1 THEN 'CLUSTERED' WHEN a.type = 2 THEN 'NONCLUSTERED' ELSE '' END, --if clustered
	' INDEX [',a.indexname,']',CHAR(13),'ON ',
	'[',tableschema,'].[',a.tablename,'] ',
	CASE WHEN a.columnname IS NOT NULL THEN CONCAT('(',a.columnname,')') ELSE '' END, --if there are any columns in index
	CASE WHEN a.includedcolumns IS NOT NULL THEN CONCAT(char(13),'INCLUDE (',a.includedcolumns,')') ELSE '' END, --if there are any included columns in index
	char(13),'WITH',char(13),
	'(',char(13),
	'PAD_INDEX = ',
	CASE WHEN a.is_padded = 1 THEN 'ON' ELSE 'OFF' END,char(13),
	CASE WHEN a.fill_factor > 0 THEN CONCAT(', FILLFACTOR =', a.fill_factor,char(13)) ELSE '' END,
	', IGNORE_DUP_KEY = ',
	CASE WHEN a.ignore_dup_key = 1 THEN 'ON' ELSE 'OFF' END,char(13),
	', ALLOW_ROW_LOCKS = ',
	CASE WHEN a.allow_row_locks = 1 THEN 'ON' ELSE 'OFF' END,char(13),
	', ALLOW_PAGE_LOCKS = ',
	CASE WHEN a.allow_page_locks = 1 THEN 'ON' ELSE 'OFF' END,char(13),
	', DATA_COMPRESSION = ',
	CASE WHEN a.data_compression = 1 THEN 'ROW' WHEN a.data_compression = 2 THEN 'PAGE' ELSE 'NONE' END,char(13),
	--there is no support for 'ON PARTITION' parameter in current version
	')',char(13),
	';',char(13)
	)
FROM
	(
	SELECT  
		OBJECT_SCHEMA_NAME(ind.object_id) AS tableschema
      , OBJECT_NAME(ind.object_id) AS tablename
      , ind.name AS Indexname
      , ind.is_primary_key AS IsPrimaryKey
      , ind.is_unique AS IsUniqueIndex
	  , ind.type AS type
	  , ind.is_disabled
	  , ind.allow_row_locks
	  , ind.allow_page_locks
	  , ind.ignore_dup_key
	  , ind.fill_factor
	  , ind.is_padded
	  , p.data_compression
	  --COLUMNS
	  ,STUFF(
		(SELECT
		CASE
			WHEN col.name IS NOT NULL
			THEN CONCAT(', [',col.name,']',
			CASE WHEN ic.is_descending_key = 0 THEN 'ASC' ELSE 'DESC' END)
			ELSE NULL
		END
		FROM sys.index_columns ic
		INNER JOIN sys.columns col
            ON ic.object_id = col.object_id
               AND ic.column_id = col.column_id
		WHERE ind.object_id = ic.object_id
               AND ind.index_id = ic.index_id
			   AND ic.is_included_column = 0 --not included col
		ORDER BY ic.key_ordinal
		For XML PATH ('')
		), 1, 2, '') AS ColumnName,
		--INCLUDED COLUMNS
	  STUFF(
		(SELECT
		CASE
			WHEN col.name IS NOT NULL
			THEN CONCAT(', [',col.name,']')
			--CASE WHEN ic.is_descending_key = 0 THEN 'ASC' ELSE 'DESC' END) - according to SSMS documentation there's no sorting for included columns
			ELSE NULL
		END
		FROM sys.index_columns ic
		INNER JOIN sys.columns col
            ON ic.object_id = col.object_id
               AND ic.column_id = col.column_id
		WHERE ind.object_id = ic.object_id
               AND ind.index_id = ic.index_id
			   AND ic.is_included_column = 1 --included col
		ORDER BY ic.key_ordinal
		For XML PATH ('')
		), 1, 2, '') AS IncludedColumns
	FROM sys.indexes ind
	INNER JOIN sys.tables t ON ind.object_id = t.object_id
	LEFT JOIN
	--in this version there is no support for multiple ways of data_compression or few partitions to one index
	(SELECT
		object_id,
		index_id,
		MAX(data_compression) AS data_compression
	FROM sys.partitions
	GROUP BY object_id, index_id) AS p ON ind.index_id = p.index_id AND ind.object_id = p.object_id
	WHERE ind.is_primary_key = 0 --indexes on primary keys will be created when primary keys are created
		) as a
	--WHERE a.is_disabled = 0 --not sure if this parameter is necessary?;









