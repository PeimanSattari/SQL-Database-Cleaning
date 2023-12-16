--Õ–› Ãœ«Ê·Ì òÂ ÂÌç ”ÿ— «ÿ·«⁄« Ì ‰œ«—‰œ
DECLARE crsTable CURSOR FOR

	SELECT SCHEMA_NAME(schema_id) + '.' + name
		FROM sys.tables
		--WHERE XTYPE = 'U'
		--	AND Name NOT LIKE 'tblGreen%'
DECLARE @TableName varchar(100)
DECLARE @strSelect nvarchar(max)
DECLARE @cnt int

OPEN crsTable
FETCH NEXT FROM crsTable INTO @TableName
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @strSelect = N'SELECT @cnt = COUNT(*) ' + CHAR(13)
			+ ' FROM ' + @TableName

	EXEC sp_executesql @strSelect, N'@cnt int OUTPUT', @cnt OUTPUT
	IF (@cnt = 0)
	BEGIN
		SET @strSelect = 'DROP TABLE ' + @TableName + ';'
		PRINT @strSelect
	END
	FETCH NEXT FROM crsTable INTO @TableName
END
CLOSE crsTable
DEALLOCATE crsTable

