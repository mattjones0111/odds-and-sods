-- Run the same command for each database

DECLARE @command VARCHAR(1000)
SELECT @command = 'USE ? SELECT name FROM sysobjects WHERE xtype = ''U'' ORDER BY name' 
EXEC sp_MSforeachdb @command 

-- Find all columns of a given type in all databases

DECLARE @command VARCHAR(1000)

SELECT @command = '
USE [?] SELECT ''?'' as db, o.name as [table], s.name as [schema], c.name as [column], t.name as [type]
FROM sys.columns c
INNER JOIN sys.types t ON c.system_type_id = t.system_type_id
INNER JOIN sys.objects o ON c.object_id = o.object_id
INNER JOIN sys.schemas s ON s.schema_id = o.schema_id
WHERE s.name = ''dbo''
AND t.[name] IN (''ntext'',''text'',''image'')
ORDER BY o.name'

EXEC sp_MSforeachdb @command