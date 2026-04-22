USE WechatProject;

SET @db_name = DATABASE();
SET @barcode_column_exists = (
  SELECT COUNT(1)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @db_name
    AND TABLE_NAME = 'clinic_medicine'
    AND COLUMN_NAME = 'barcode'
);
SET @barcode_column_sql = IF(
  @barcode_column_exists = 0,
  'ALTER TABLE clinic_medicine ADD COLUMN barcode VARCHAR(64) NULL COMMENT ''药品条码'' AFTER manufacturer',
  'SELECT ''clinic_medicine.barcode already exists'''
);
PREPARE stmt_barcode_column FROM @barcode_column_sql;
EXECUTE stmt_barcode_column;
DEALLOCATE PREPARE stmt_barcode_column;

SET @barcode_index_exists = (
  SELECT COUNT(1)
  FROM information_schema.STATISTICS
  WHERE TABLE_SCHEMA = @db_name
    AND TABLE_NAME = 'clinic_medicine'
    AND INDEX_NAME = 'idx_barcode'
);
SET @barcode_index_sql = IF(
  @barcode_index_exists = 0,
  'CREATE INDEX idx_barcode ON clinic_medicine(barcode)',
  'SELECT ''idx_barcode already exists'''
);
PREPARE stmt_barcode_index FROM @barcode_index_sql;
EXECUTE stmt_barcode_index;
DEALLOCATE PREPARE stmt_barcode_index;
