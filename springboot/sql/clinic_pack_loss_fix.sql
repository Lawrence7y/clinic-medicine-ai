-- ============================================
-- 诊所管理系统 - 包药功能修复脚本
-- 用于修复已存在的数据库
-- 执行前请备份数据库！
-- ============================================

USE WechatProject;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================
-- 1. 添加 clinic_pack_loss_record 表
-- ============================================
DROP TABLE IF EXISTS `clinic_pack_loss_record`;
CREATE TABLE `clinic_pack_loss_record` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `medicine_id` bigint(20) DEFAULT NULL COMMENT '药品ID',
  `medicine_name` varchar(100) DEFAULT NULL COMMENT '药品名称',
  `loss_quantity` int(11) DEFAULT NULL COMMENT '损耗数量',
  `related_record_id` varchar(50) DEFAULT NULL COMMENT '关联记录ID',
  `batch_number` varchar(50) DEFAULT NULL COMMENT '批次号',
  `is_processed` int(1) DEFAULT '0' COMMENT '是否处理（0=未处理，1=已处理）',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `operator_name` varchar(50) DEFAULT NULL COMMENT '操作员名称',
  PRIMARY KEY (`id`),
  KEY `idx_medicine_id` (`medicine_id`),
  KEY `idx_is_processed` (`is_processed`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='包药损耗记录表';

-- ============================================
-- 2. 修改 clinic_stock_record 表（字段可能已存在）
-- ============================================
-- 添加 is_pack_medicine 字段（如果不存在）
SET @sql = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
   WHERE TABLE_SCHEMA = 'ry' AND TABLE_NAME = 'clinic_stock_record' AND COLUMN_NAME = 'is_pack_medicine') = 0,
  'ALTER TABLE `clinic_stock_record` ADD COLUMN `is_pack_medicine` tinyint(1) DEFAULT 0 COMMENT ''是否包药（1=包药，0=普通出库）'' AFTER `related_record_type`',
  'SELECT ''is_pack_medicine column already exists'' as msg'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 添加 pack_items 字段（如果不存在）
SET @sql = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
   WHERE TABLE_SCHEMA = 'ry' AND TABLE_NAME = 'clinic_stock_record' AND COLUMN_NAME = 'pack_items') = 0,
  'ALTER TABLE `clinic_stock_record` ADD COLUMN `pack_items` text COMMENT ''包药明细JSON'' AFTER `is_pack_medicine`',
  'SELECT ''pack_items column already exists'' as msg'
));
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET FOREIGN_KEY_CHECKS = 1;
