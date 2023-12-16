-- Written by: Vahid Sadreddini 
-- 1400/06/09

SELECT OBJECT_NAME(object_id) AS TableName , name AS ColumnName FROM sys.columns c WHERE NOT EXISTS (SELECT * FROM sys.foreign_key_columns fkc WHERE c.object_id = fkc.parent_object_id AND c.column_id = fkc.parent_column_id)
AND NOT EXISTS (SELECT OBJECT_NAME(st.object_id), co.name                
    FROM   sys.columns co
               INNER JOIN sys.tables st ON st.object_id = co.object_id
               inner JOIN sys.indexes i ON i.object_id = st.object_id
                                                AND i.is_primary_key = 1 
												INNER JOIN sys.index_columns ic ON ic.object_id = st.object_id
                                                       AND ic.column_id = co.column_id
                                                       AND ic.index_id = i.index_id
                                                       AND i.is_primary_key = 1 WHERE c.object_id = co.object_id AND c.name = co.name)

--- Change following Conditions to match FK's based on naming pattern
AND OBJECT_NAME(object_id) NOT LIKE 'sys%' 
AND ( name LIKE '%[_]Code' OR name LIKE '%[_]id' OR name LIKE '%[_]no' OR name LIKE '%[_]account')
AND OBJECT_NAME(object_id) NOT LIKE 'gl[_]trans[_]%'
AND OBJECT_NAME(object_id) NOT LIKE '%jimb%'
AND OBJECT_NAME(object_id) NOT LIKE '%queue[_]messages%'
AND OBJECT_NAME(object_id) NOT LIKE '%sqlagent%'
ORDER BY c.name, 1


--- Tables without Primary Key
SELECT * 
FROM sys.tables st WHERE NOT EXISTS (SELECT * 
                                  FROM sys.indexes i WHERE is_primary_key = 1 AND st.object_id = i.object_id) ORDER BY name
