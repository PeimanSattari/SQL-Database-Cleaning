-- ÍÐÝ ÓÊæäåÇíí ßå ãÞÇÏíÑ ËÇÈÊ ÏÇÑäÏ

SET NOCOUNT ON;
IF OBJECT_ID('tempdb..#tmpScript', 'u') > 0 
    DROP TABLE #tmpScript;
CREATE TABLE #tmpScript ( Script NVARCHAR(MAX) );
IF OBJECT_ID('tempdb..#tmp1', 'u') > 0 
    DROP TABLE #tmp1;
SELECT  IDENTITY( INT, 1, 1 ) RownNumber ,
		OBJECT_SCHEMA_NAME(object_id) SchemaName ,
        OBJECT_NAME(object_id) TableName ,
        Name ColumnName
INTO    #tmp1
FROM    sys.all_columns
WHERE   object_id IN ( SELECT   ID
                       FROM     sysobjects
                       WHERE    XTYPE = 'U' )
        AND system_type_id NOT IN ( 35, 34 )
        AND OBJECT_NAME(object_id) NOT LIKE 'sys%'
        AND system_type_id <> 241;

DECLARE @counter1 INT ,
		@SchemaName sysname ,
		@TableName sysname ,
		@ColumnName sysname ,
		@Flag int = 0 ,
		@TotalCount int = 0 ,
		@CheckString NVARCHAR(max) ,
		@QueryString nvarchar(max);

SELECT  @counter1 = MIN(RownNumber)
FROM    #tmp1;
WHILE @counter1 IS NOT NULL 
    BEGIN
		SELECT  @SchemaName = SchemaName ,
		        @TableName = TableName ,
		        @ColumnName = ColumnName
		FROM #tmp1
		WHERE RownNumber = @counter1

        SET @CheckString = 
        'IF  ( SELECT  COUNT(DISTINCT' + QUOTENAME(@ColumnName) + ') 
                     FROM ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + '
                     HAVING  COUNT(*) > 1 ) = 1
                    set @xFlag = 1 else
                    set @xFlag = 0;'
        EXEC sp_executesql @CheckString, N'@xFlag int OUTPUT', @Flag OUTPUT

        IF @Flag = 1 
			BEGIN
				SET @TotalCount += 1;
				SET @QueryString = '';
				IF EXISTS ( SELECT 1
							FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE
							WHERE TABLE_SCHEMA = @SchemaName
							  AND TABLE_NAME = @TableName
							  AND COLUMN_NAME = @ColumnName 
						  ) 
						BEGIN
							SELECT @QueryString = @QueryString + 
								' ALTER TABLE ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + ' DROP CONSTRAINT ' + QUOTENAME(CONSTRAINT_NAME) + ';' 
							FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE
							WHERE TABLE_SCHEMA = @SchemaName
							  AND TABLE_NAME = @TableName
							  AND COLUMN_NAME = @ColumnName 
						END
		             
				IF EXISTS ( SELECT 1
							FROM    sys.sysobjects a
									INNER JOIN ( SELECT name ,
														id
												 FROM   sys.sysobjects
												 WHERE  xtype = 'U'
											   ) b ON ( a.parent_obj = b.id )
									INNER JOIN sys.syscomments c ON ( a.id = c.id )
									INNER JOIN sys.syscolumns d ON ( d.cdefault = a.id )
							WHERE   a.xtype = 'D'
									AND OBJECT_SCHEMA_NAME(b.id) = @SchemaName
									AND b.name = @TableName
									AND d.name = @ColumnName
						  ) 
						BEGIN
							SELECT @QueryString = @QueryString + 
								' ALTER TABLE ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + ' DROP CONSTRAINT ' + QUOTENAME(a.name) + ';' 
							FROM    sys.sysobjects a
									INNER JOIN ( SELECT name ,
														id
												 FROM   sys.sysobjects
												 WHERE  xtype = 'U'
											   ) b ON ( a.parent_obj = b.id )
									INNER JOIN sys.syscomments c ON ( a.id = c.id )
									INNER JOIN sys.syscolumns d ON ( d.cdefault = a.id )
							WHERE   a.xtype = 'D'
									AND OBJECT_SCHEMA_NAME(b.id) = @SchemaName
									AND b.name = @TableName
									AND d.name = @ColumnName
						END
		             
				IF EXISTS ( SELECT  1
							FROM    sys.indexes i
									INNER JOIN sys.tables t ON i.object_id = t.object_id
									INNER JOIN sys.index_columns ic ON ic.object_id = t.object_id
																	   AND ic.index_id = i.index_id
									INNER JOIN sys.columns c ON c.object_id = t.object_id
																AND ic.column_id = c.column_id
							WHERE   SCHEMA_NAME(schema_id) = @SchemaName
									AND OBJECT_NAME(t.object_id) = @TableName
									AND c.name = @ColumnName
						  ) 
						BEGIN
							SELECT @QueryString = @QueryString + 
								 ' DROP INDEX ' + QUOTENAME(i.Name) + ' on ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + ';'
							FROM    sys.indexes i
									INNER JOIN sys.tables t ON i.object_id = t.object_id
									INNER JOIN sys.index_columns ic ON ic.object_id = t.object_id
																	   AND ic.index_id = i.index_id
									INNER JOIN sys.columns c ON c.object_id = t.object_id
																AND ic.column_id = c.column_id
							WHERE   SCHEMA_NAME(schema_id) = @SchemaName
									AND OBJECT_NAME(t.object_id) = @TableName
									AND c.name = @ColumnName
						END

					SET @QueryString = @QueryString + 
					' ALTER TABLE ' + QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName) + ' DROP COLUMN ' + QUOTENAME(@ColumnName) + ';'
					--end;' ;
					--PRINT @QueryString;
					--EXEC sys.sp_executesql @QueryString;
					INSERT INTO  #tmpScript 
						VALUES(@QueryString)
			END    
        SELECT  @counter1 = MIN(RownNumber)
        FROM    #tmp1
        WHERE   RownNumber > @counter1;
    END;
SELECT  @TotalCount [Total count of  columns!!!];

SELECT  ' Begin Try ' + Script + ' end Try  begin catch print ''' + script + ''' end catch' 
FROM    #tmpScript;

DROP TABLE #tmp1

drop TABLE #tmpScript