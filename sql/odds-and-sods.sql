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

-- Check the progress of an index creation

DECLARE @SPID INT = 126;

WITH agg AS
(
    SELECT SUM(qp.[row_count]) AS [RowsProcessed],
            SUM(qp.[estimate_row_count]) AS [TotalRows],
            MAX(qp.last_active_time) - MIN(qp.first_active_time) AS [ElapsedMS],
            MAX(IIF(qp.[close_time] = 0 AND qp.[first_row_time] > 0,
                    [physical_operator_name],
                    N'<Transition>')) AS [CurrentStep]
    FROM sys.dm_exec_query_profiles qp
    WHERE qp.[physical_operator_name] IN (N'Table Scan', N'Clustered Index Scan',
        N'Index Scan',  N'Sort')
    AND   qp.[session_id] = @SPID
), comp AS
(
    SELECT *,
        ([TotalRows] - [RowsProcessed]) AS [RowsLeft],
        ([ElapsedMS] / 1000.0) AS [ElapsedSeconds]
    FROM agg
)
SELECT [CurrentStep],
    [TotalRows],
    [RowsProcessed],
    [RowsLeft],
    CONVERT(DECIMAL(5, 2),
               (([RowsProcessed] * 1.0) / [TotalRows]) * 100) AS [PercentComplete],
    [ElapsedSeconds],
       (([ElapsedSeconds] / [RowsProcessed]) * [RowsLeft]) AS [EstimatedSecondsLeft],
    DATEADD(SECOND,
               (([ElapsedSeconds] / [RowsProcessed]) * [RowsLeft]),
            GETDATE()) AS [EstimatedCompletionTime]
FROM   comp;

-- show db users and roles

SELECT isnull (DP2.name, 'No members') AS [User],
    DP1.name AS [Role]
FROM sys.database_role_members AS DRM  
RIGHT OUTER JOIN sys.database_principals AS DP1  
    ON DRM.role_principal_id = DP1.principal_id  
LEFT OUTER JOIN sys.database_principals AS DP2  
    ON DRM.member_principal_id = DP2.principal_id  
WHERE DP1.type = 'R'
ORDER BY DP2.name;  