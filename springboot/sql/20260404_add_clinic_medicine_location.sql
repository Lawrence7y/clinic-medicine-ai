USE WechatProject;

SET @db_name = DATABASE();
SET @location_column_exists = (
  SELECT COUNT(1)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @db_name
    AND TABLE_NAME = 'clinic_medicine'
    AND COLUMN_NAME = 'location'
);
SET @location_column_sql = IF(
  @location_column_exists = 0,
  'ALTER TABLE clinic_medicine ADD COLUMN location VARCHAR(100) NULL COMMENT ''存放位置'' AFTER category',
  'SELECT ''clinic_medicine.location already exists'''
);
PREPARE stmt_location_column FROM @location_column_sql;
EXECUTE stmt_location_column;
DEALLOCATE PREPARE stmt_location_column;
