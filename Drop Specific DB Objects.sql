SELECT 'DROP ' + CASE type
                     WHEN 'fn' THEN
                         'FUNCTION'
                     WHEN 'P' THEN
                         'PROCEDURE'
                     WHEN 'U' THEN
                         'TABLE'
                     WHEN 'V' THEN
                         'VIEW'
                     WHEN 'TR' THEN
                         'TRIGGER'
                     WHEN 'F' THEN
                         'Constraint'
                     WHEN 'D' THEN
                         'Default'
			         WHEN 'PK' THEN
						 'PRIMARY KEY'
			         WHEN 'UQ' THEN
						 'UNIQE Constraint'
					 WHEN 'SO' THEN
						 'SEQUENCE'

                 END + ' ' + OBJECT_SCHEMA_NAME(object_id)+ '.' +
       OBJECT_NAME(object_id),
       type
FROM sys.objects
WHERE (
          OBJECT_SCHEMA_NAME(object_id) NOT IN
          (
              SELECT SchemaName FROM gnd_egsys.tblSystem
          )
          AND OBJECT_SCHEMA_NAME(object_id) NOT IN
              (
                  SELECT REPLACE(SchemaName, 'gnd', 'gnu')FROM gnd_egsys.tblSystem
              )
      )
      AND OBJECT_SCHEMA_NAME(object_id) LIKE 'gn%'
      AND OBJECT_SCHEMA_NAME(object_id)NOT LIKE '%med%'
      AND OBJECT_SCHEMA_NAME(object_id)NOT LIKE 'gnp%'
ORDER BY type,
         1



SELECT DISTINCT 'DROP ' + CASE type
                     WHEN 'fn' THEN
                         'FUNCTION'
                     WHEN 'P' THEN
                         'PROCEDURE'
                     WHEN 'U' THEN
                         'TABLE'
                     WHEN 'V' THEN
                         'VIEW'
                     WHEN 'TR' THEN
                         'TRIGGER'
                     WHEN 'F' THEN
                         'Constraint'
                     WHEN 'D' THEN
                         'Default'
			         WHEN 'PK' THEN
						 'PRIMARY KEY'
			         WHEN 'UQ' THEN
						 'UNIQE Constraint'
					 WHEN 'SO' THEN
						 'SEQUENCE'

                 END + ' ' + OBJECT_SCHEMA_NAME(object_id)+ '.' +
       OBJECT_NAME(object_id) + ';',
       type
FROM sys.objects so INNER JOIN sys.syscomments sc ON sc.id = so.object_id
WHERE sc.text LIKE '%SalesInvocie%'
ORDER BY type,
         1


		