-- ============================================
-- 诊所管理系统 - 完整数据初始化脚本
-- 依赖: ry_20250416.sql (RuoYi基础框架)
-- 执行顺序: 1. ry_20250416.sql  2. clinic_data_init.sql
-- ============================================

USE WechatProject;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================
-- 第1部分：创建诊所管理系统表
-- ============================================

-- 患者表
DROP TABLE IF EXISTS `clinic_patient`;
CREATE TABLE `clinic_patient` (
  `patient_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '患者ID',
  `user_id` bigint(20) DEFAULT NULL COMMENT '关联用户ID',
  `name` varchar(50) NOT NULL COMMENT '患者姓名',
  `gender` varchar(10) DEFAULT NULL COMMENT '性别',
  `age` int(11) DEFAULT NULL COMMENT '年龄',
  `phone` varchar(20) DEFAULT NULL COMMENT '联系电话',
  `birthday` date DEFAULT NULL COMMENT '出生日期',
  `address` varchar(255) DEFAULT NULL COMMENT '地址',
  `allergy_history` text COMMENT '过敏史',
  `past_history` text COMMENT '既往史',
  `blood_type` varchar(10) DEFAULT NULL COMMENT '血型',
  `wechat` varchar(50) DEFAULT NULL COMMENT '微信号',
  `avatar` varchar(255) DEFAULT NULL COMMENT '头像',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`patient_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_phone` (`phone`)
) ENGINE=InnoDB AUTO_INCREMENT=100 COMMENT='患者信息表';

-- 药品表
DROP TABLE IF EXISTS `clinic_medicine`;
CREATE TABLE `clinic_medicine` (
  `medicine_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '药品ID',
  `name` varchar(100) NOT NULL COMMENT '药品名称',
  `specification` varchar(100) DEFAULT NULL COMMENT '规格',
  `dosage_form` varchar(50) DEFAULT NULL COMMENT '剂型',
  `form` varchar(50) DEFAULT NULL COMMENT '形式',
  `manufacturer` varchar(100) DEFAULT NULL COMMENT '生产厂家',
  `expiry_date` date DEFAULT NULL COMMENT '有效期',
  `price` decimal(10,2) DEFAULT NULL COMMENT '价格',
  `stock` int(11) DEFAULT 0 COMMENT '库存数量',
  `warning_stock` int(11) DEFAULT 10 COMMENT '预警库存',
  `warning_threshold` int(11) DEFAULT 10 COMMENT '预警阈值',
  `min_stock` int(11) DEFAULT 10 COMMENT '最小库存',
  `unit` varchar(20) DEFAULT NULL COMMENT '单位',
  `pharmacology` text COMMENT '药理作用',
  `indications` text COMMENT '适应症',
  `dosage` text COMMENT '用法用量',
  `side_effects` text COMMENT '不良反应',
  `storage` varchar(255) DEFAULT NULL COMMENT '储存条件',
  `status` varchar(20) DEFAULT 'active' COMMENT '状态：active, inactive',
  `is_prescription` tinyint(1) DEFAULT 0 COMMENT '是否处方药',
  `category` varchar(50) DEFAULT NULL COMMENT '药品分类',
  `location` varchar(100) DEFAULT NULL COMMENT '存放位置',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`medicine_id`),
  KEY `idx_name` (`name`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=100 COMMENT='药品信息表';

-- 库存记录表
DROP TABLE IF EXISTS `clinic_stock_record`;
CREATE TABLE `clinic_stock_record` (
  `record_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `medicine_id` bigint(20) NOT NULL COMMENT '药品ID',
  `medicine_name` varchar(100) DEFAULT NULL COMMENT '药品名称',
  `operation_type` varchar(20) NOT NULL COMMENT '操作类型：in, out, check',
  `quantity` int(11) NOT NULL COMMENT '数量',
  `before_stock` int(11) DEFAULT NULL COMMENT '操作前库存',
  `after_stock` int(11) DEFAULT NULL COMMENT '操作后库存',
  `supplier` varchar(100) DEFAULT NULL COMMENT '供应商（入库用）',
  `purchase_price` decimal(10,2) DEFAULT NULL COMMENT '进货价格',
  `batch_number` varchar(50) DEFAULT NULL COMMENT '批号',
  `expiry_date` date DEFAULT NULL COMMENT '有效期',
  `operator_id` bigint(20) DEFAULT NULL COMMENT '操作人ID',
  `operator_name` varchar(50) DEFAULT NULL COMMENT '操作人姓名',
  `patient_name` varchar(50) DEFAULT NULL COMMENT '患者姓名（出库用）',
  `patient_id` bigint(20) DEFAULT NULL COMMENT '患者档案ID',
  `doctor_name` varchar(50) DEFAULT NULL COMMENT '医生姓名（出库用）',
  `doctor_id` bigint(20) DEFAULT NULL COMMENT '医生用户ID',
  `related_record_id` varchar(50) DEFAULT NULL COMMENT '关联记录ID',
  `related_record_type` varchar(50) DEFAULT NULL COMMENT '关联记录类型',
  `is_pack_medicine` tinyint(1) DEFAULT 0 COMMENT '是否包药（1=包药，0=普通出库）',
  `pack_items` text COMMENT '包药明细JSON（is_pack_medicine=1时使用）',
  `remark` text COMMENT '备注',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`record_id`),
  KEY `idx_medicine_id` (`medicine_id`),
  KEY `idx_operation_type` (`operation_type`),
  KEY `idx_create_time` (`create_time`),
  KEY `idx_clinic_stock_record_patient_id` (`patient_id`),
  KEY `idx_clinic_stock_record_doctor_id` (`doctor_id`)
) ENGINE=InnoDB AUTO_INCREMENT=100 COMMENT='库存记录表';

-- 包药损耗记录表
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

-- 批次库存表
DROP TABLE IF EXISTS `clinic_stock_batch`;
CREATE TABLE `clinic_stock_batch` (
  `batch_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '批次ID',
  `medicine_id` bigint(20) NOT NULL COMMENT '药品ID',
  `batch_number` varchar(50) NOT NULL COMMENT '批号',
  `expiry_date` date NOT NULL COMMENT '批次有效期',
  `remaining_quantity` int(11) NOT NULL DEFAULT 0 COMMENT '批次剩余库存',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`batch_id`),
  UNIQUE KEY `uk_medicine_batch_expiry` (`medicine_id`,`batch_number`,`expiry_date`),
  KEY `idx_medicine_expiry` (`medicine_id`,`expiry_date`)
) ENGINE=InnoDB AUTO_INCREMENT=100 COMMENT='批次库存表';

-- 药品使用记录表
DROP TABLE IF EXISTS `clinic_usage_record`;
CREATE TABLE `clinic_usage_record` (
  `usage_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '使用记录ID',
  `medicine_id` bigint(20) NOT NULL COMMENT '药品ID',
  `medicine_name` varchar(100) DEFAULT NULL COMMENT '药品名称',
  `specification` varchar(100) DEFAULT NULL COMMENT '规格',
  `quantity` int(11) NOT NULL COMMENT '数量',
  `patient_id` bigint(20) DEFAULT NULL COMMENT '患者ID',
  `patient_name` varchar(50) DEFAULT NULL COMMENT '患者姓名',
  `medical_record_id` varchar(50) DEFAULT NULL COMMENT '病历ID',
  `doctor_id` bigint(20) DEFAULT NULL COMMENT '医生ID',
  `doctor_name` varchar(50) DEFAULT NULL COMMENT '医生姓名',
  `issue_time` datetime DEFAULT NULL COMMENT '发药时间',
  `issuer_id` bigint(20) DEFAULT NULL COMMENT '发药人ID',
  `issuer_name` varchar(50) DEFAULT NULL COMMENT '发药人姓名',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`usage_id`),
  KEY `idx_medicine_id` (`medicine_id`),
  KEY `idx_patient_id` (`patient_id`),
  KEY `idx_issue_time` (`issue_time`)
) ENGINE=InnoDB AUTO_INCREMENT=100 COMMENT='药品使用记录表';

-- 病历表
DROP TABLE IF EXISTS `clinic_medical_record`;
CREATE TABLE `clinic_medical_record` (
  `record_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '病历ID',
  `patient_id` bigint(20) NOT NULL COMMENT '患者ID',
  `patient_name` varchar(50) DEFAULT NULL COMMENT '患者姓名',
  `patient_gender` varchar(10) DEFAULT NULL COMMENT '患者性别',
  `patient_age` int(11) DEFAULT NULL COMMENT '患者年龄',
  `patient_phone` varchar(20) DEFAULT NULL COMMENT '患者电话',
  `patient_birthday` date DEFAULT NULL COMMENT '患者生日',
  `patient_blood_type` varchar(10) DEFAULT NULL COMMENT '患者血型',
  `doctor_id` bigint(20) DEFAULT NULL COMMENT '医生ID',
  `doctor_name` varchar(50) DEFAULT NULL COMMENT '医生姓名',
  `visit_time` datetime DEFAULT NULL COMMENT '就诊时间',
  `chief_complaint` text COMMENT '主诉',
  `present_illness` text COMMENT '现病史',
  `past_history` text COMMENT '既往史',
  `allergy_history` text COMMENT '过敏史',
  `physical_exam` text COMMENT '体格检查',
  `diagnosis` text COMMENT '诊断',
  `treatment` text COMMENT '治疗方案',
  `prescription` text COMMENT '处方（JSON格式）',
  `attachments` text COMMENT '附件（JSON格式）',
  `follow_up` text COMMENT '随访计划',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`record_id`),
  KEY `idx_patient_id` (`patient_id`),
  KEY `idx_doctor_id` (`doctor_id`),
  KEY `idx_visit_time` (`visit_time`)
) ENGINE=InnoDB AUTO_INCREMENT=100 COMMENT='病历记录表';

-- 预约表
DROP TABLE IF EXISTS `clinic_appointment`;
CREATE TABLE `clinic_appointment` (
  `appointment_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '预约ID',
  `patient_id` bigint(20) NOT NULL COMMENT '患者ID',
  `patient_name` varchar(50) DEFAULT NULL COMMENT '患者姓名',
  `patient_phone` varchar(20) DEFAULT NULL COMMENT '患者电话',
  `doctor_id` bigint(20) NOT NULL COMMENT '医生ID',
  `doctor_name` varchar(50) DEFAULT NULL COMMENT '医生姓名',
  `schedule_id` bigint(20) DEFAULT NULL COMMENT '排班ID',
  `appointment_date` date DEFAULT NULL COMMENT '预约日期',
  `appointment_time` varchar(20) DEFAULT NULL COMMENT '预约时间段',
  `sequence_number` int(11) DEFAULT NULL COMMENT '序号',
  `status` varchar(20) DEFAULT 'pending' COMMENT '状态：pending, confirmed, completed, cancelled',
  `is_offline` tinyint(1) DEFAULT 0 COMMENT '是否线下',
  `called` tinyint(1) DEFAULT 0 COMMENT '是否被叫号',
  `called_time` datetime DEFAULT NULL COMMENT '叫号时间',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`appointment_id`),
  KEY `idx_patient_id` (`patient_id`),
  KEY `idx_doctor_id` (`doctor_id`),
  KEY `idx_appointment_date` (`appointment_date`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=100 COMMENT='预约记录表';

-- 排班表
DROP TABLE IF EXISTS `clinic_schedule`;
CREATE TABLE `clinic_schedule` (
  `schedule_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '排班ID',
  `doctor_id` bigint(20) NOT NULL COMMENT '医生ID',
  `doctor_name` varchar(50) DEFAULT NULL COMMENT '医生姓名',
  `title` varchar(50) DEFAULT NULL COMMENT '职称',
  `schedule_date` date DEFAULT NULL COMMENT '排班日期',
  `start_time` varchar(10) DEFAULT NULL COMMENT '开始时间',
  `end_time` varchar(10) DEFAULT NULL COMMENT '结束时间',
  `total_slots` int(11) DEFAULT 20 COMMENT '总号源数',
  `booked_slots` int(11) DEFAULT 0 COMMENT '已预约数',
  `status` varchar(20) DEFAULT 'active' COMMENT '状态：active, inactive',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`schedule_id`),
  KEY `idx_doctor_id` (`doctor_id`),
  KEY `idx_schedule_date` (`schedule_date`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=100 COMMENT='排班表';

-- 系统配置表
DROP TABLE IF EXISTS `clinic_config`;
CREATE TABLE `clinic_config` (
  `config_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '配置ID',
  `config_key` varchar(100) NOT NULL COMMENT '配置键',
  `config_value` text COMMENT '配置值',
  `description` varchar(255) DEFAULT NULL COMMENT '描述',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`config_id`),
  UNIQUE KEY `uk_config_key` (`config_key`)
) ENGINE=InnoDB AUTO_INCREMENT=100 COMMENT='系统配置表';

-- ============================================
-- 第2部分：创建诊所菜单
-- ============================================

-- 删除旧菜单配置
DELETE FROM sys_role_menu WHERE menu_id >= 2000 AND menu_id <= 2099;
DELETE FROM sys_menu WHERE menu_id >= 2000 AND menu_id <= 2099;

-- 插入诊所管理一级菜单
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, url, target, menu_type, visible, is_refresh, perms, icon, create_by, create_time, update_by, update_time, remark) VALUES
(2000, '诊所管理', 0, 10, '', '', 'M', '0', '1', '', 'fa fa-hospital-o', 'admin', NOW(), '', NULL, '诊所管理菜单');

-- 插入患者管理菜单
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, url, target, menu_type, visible, is_refresh, perms, icon, create_by, create_time, update_by, update_time, remark) VALUES
(2001, '患者管理', 2000, 1, 'clinic/patient', '', 'C', '0', '1', 'clinic:patient:view', 'fa fa-user-md', 'admin', NOW(), '', NULL, '患者管理菜单'),
(2002, '患者查询', 2001, 1, '', '', 'F', '0', '1', 'clinic:patient:list', '#', 'admin', NOW(), '', NULL, ''),
(2003, '患者新增', 2001, 2, '', '', 'F', '0', '1', 'clinic:patient:add', '#', 'admin', NOW(), '', NULL, ''),
(2004, '患者修改', 2001, 3, '', '', 'F', '0', '1', 'clinic:patient:edit', '#', 'admin', NOW(), '', NULL, ''),
(2005, '患者删除', 2001, 4, '', '', 'F', '0', '1', 'clinic:patient:remove', '#', 'admin', NOW(), '', NULL, ''),
(2006, '患者导出', 2001, 5, '', '', 'F', '0', '1', 'clinic:patient:export', '#', 'admin', NOW(), '', NULL, '');

-- 插入药品管理菜单
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, url, target, menu_type, visible, is_refresh, perms, icon, create_by, create_time, update_by, update_time, remark) VALUES
(2010, '药品管理', 2000, 2, 'clinic/medicine', '', 'C', '0', '1', 'clinic:medicine:view', 'fa fa-medkit', 'admin', NOW(), '', NULL, '药品管理菜单'),
(2011, '药品查询', 2010, 1, '', '', 'F', '0', '1', 'clinic:medicine:list', '#', 'admin', NOW(), '', NULL, ''),
(2012, '药品新增', 2010, 2, '', '', 'F', '0', '1', 'clinic:medicine:add', '#', 'admin', NOW(), '', NULL, ''),
(2013, '药品修改', 2010, 3, '', '', 'F', '0', '1', 'clinic:medicine:edit', '#', 'admin', NOW(), '', NULL, ''),
(2014, '药品删除', 2010, 4, '', '', 'F', '0', '1', 'clinic:medicine:remove', '#', 'admin', NOW(), '', NULL, ''),
(2015, '药品导出', 2010, 5, '', '', 'F', '0', '1', 'clinic:medicine:export', '#', 'admin', NOW(), '', NULL, '');

-- 插入病历管理菜单
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, url, target, menu_type, visible, is_refresh, perms, icon, create_by, create_time, update_by, update_time, remark) VALUES
(2030, '病历管理', 2000, 3, 'clinic/medical', '', 'C', '0', '1', 'clinic:medical:view', 'fa fa-file-text', 'admin', NOW(), '', NULL, '病历管理菜单'),
(2031, '病历查询', 2030, 1, '', '', 'F', '0', '1', 'clinic:medical:list', '#', 'admin', NOW(), '', NULL, ''),
(2032, '病历新增', 2030, 2, '', '', 'F', '0', '1', 'clinic:medical:add', '#', 'admin', NOW(), '', NULL, ''),
(2033, '病历修改', 2030, 3, '', '', 'F', '0', '1', 'clinic:medical:edit', '#', 'admin', NOW(), '', NULL, ''),
(2034, '病历删除', 2030, 4, '', '', 'F', '0', '1', 'clinic:medical:remove', '#', 'admin', NOW(), '', NULL, '');

-- 插入预约管理菜单
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, url, target, menu_type, visible, is_refresh, perms, icon, create_by, create_time, update_by, update_time, remark) VALUES
(2040, '预约管理', 2000, 4, 'clinic/appointment', '', 'C', '0', '1', 'clinic:appointment:view', 'fa fa-calendar', 'admin', NOW(), '', NULL, '预约管理菜单'),
(2041, '预约查询', 2040, 1, '', '', 'F', '0', '1', 'clinic:appointment:list', '#', 'admin', NOW(), '', NULL, ''),
(2042, '预约新增', 2040, 2, '', '', 'F', '0', '1', 'clinic:appointment:add', '#', 'admin', NOW(), '', NULL, ''),
(2043, '预约修改', 2040, 3, '', '', 'F', '0', '1', 'clinic:appointment:edit', '#', 'admin', NOW(), '', NULL, ''),
(2044, '预约删除', 2040, 4, '', '', 'F', '0', '1', 'clinic:appointment:remove', '#', 'admin', NOW(), '', NULL, '');

-- 插入排班管理菜单
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, url, target, menu_type, visible, is_refresh, perms, icon, create_by, create_time, update_by, update_time, remark) VALUES
(2050, '排班管理', 2000, 5, 'clinic/schedule', '', 'C', '0', '1', 'clinic:schedule:view', 'fa fa-clock-o', 'admin', NOW(), '', NULL, '排班管理菜单'),
(2051, '排班查询', 2050, 1, '', '', 'F', '0', '1', 'clinic:schedule:list', '#', 'admin', NOW(), '', NULL, ''),
(2052, '排班新增', 2050, 2, '', '', 'F', '0', '1', 'clinic:schedule:add', '#', 'admin', NOW(), '', NULL, ''),
(2053, '排班修改', 2050, 3, '', '', 'F', '0', '1', 'clinic:schedule:edit', '#', 'admin', NOW(), '', NULL, ''),
(2054, '排班删除', 2050, 4, '', '', 'F', '0', '1', 'clinic:schedule:remove', '#', 'admin', NOW(), '', NULL, '');

-- ============================================
-- 第3部分：分配菜单权限
-- ============================================

-- 超级管理员角色(role_id=1)分配所有诊所管理菜单权限
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) VALUES
(1, 2000), (1, 2001), (1, 2002), (1, 2003), (1, 2004), (1, 2005), (1, 2006),
(1, 2010), (1, 2011), (1, 2012), (1, 2013), (1, 2014), (1, 2015),
(1, 2030), (1, 2031), (1, 2032), (1, 2033), (1, 2034),
(1, 2040), (1, 2041), (1, 2042), (1, 2043), (1, 2044),
(1, 2050), (1, 2051), (1, 2052), (1, 2053), (1, 2054);

-- 普通角色(role_id=2)分配诊所管理菜单权限（诊所管理员）
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) VALUES
(2, 2000), (2, 2001), (2, 2002), (2, 2003), (2, 2004), (2, 2005), (2, 2006),
(2, 2010), (2, 2011), (2, 2012), (2, 2013), (2, 2014), (2, 2015),
(2, 2030), (2, 2031), (2, 2032), (2, 2033), (2, 2034),
(2, 2040), (2, 2041), (2, 2042), (2, 2043), (2, 2044),
(2, 2050), (2, 2051), (2, 2052), (2, 2053), (2, 2054);

-- 医生角色(role_id=3)分配菜单权限
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) VALUES
(3, 2000), 
(3, 2001), (3, 2002), (3, 2003), 
(3, 2010), (3, 2011),
(3, 2030), (3, 2031), (3, 2032), (3, 2033),
(3, 2040), (3, 2041), (3, 2042), (3, 2043),
(3, 2050), (3, 2051), (3, 2052), (3, 2053);

-- 患者角色(role_id=4)分配菜单权限
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) VALUES
(4, 2000),
(4, 2030), (4, 2031),
(4, 2040), (4, 2041), (4, 2042), (4, 2043),
(4, 2050), (4, 2051);

-- ============================================
-- 第4部分：创建医生和患者角色
-- ============================================

INSERT IGNORE INTO sys_role (role_id, role_name, role_key, role_sort, data_scope, status, del_flag, create_by, create_time, remark) VALUES
(3, '医生', 'doctor', 3, 1, '0', '0', 'admin', NOW(), '医生角色'),
(4, '患者', 'patient', 4, 1, '0', '0', 'admin', NOW(), '患者角色');

-- ============================================
-- 第5部分：创建用户账号（密码统一为 123456）
-- ============================================

-- 诊所管理员
INSERT IGNORE INTO sys_user (user_id, dept_id, login_name, user_name, user_type, email, phonenumber, sex, avatar, password, salt, status, del_flag, create_by, create_time, remark) VALUES
(100, 100, '13800138001', '诊所管理员', '00', 'admin@clinic.com', '13800138001', '0', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '诊所管理员');

-- 医生账号
INSERT IGNORE INTO sys_user (user_id, dept_id, login_name, user_name, user_type, email, phonenumber, sex, avatar, password, salt, status, del_flag, create_by, create_time, remark) VALUES
(101, 103, '13800138002', '李医生', '00', 'doctor1@clinic.com', '13800138002', '0', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '内科医生'),
(102, 103, '13800138003', '王医生', '00', 'doctor2@clinic.com', '13800138003', '1', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '外科医生'),
(103, 103, '13800138004', '张医生', '00', 'doctor3@clinic.com', '13800138004', '0', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '儿科医生');

-- 患者账号
INSERT IGNORE INTO sys_user (user_id, dept_id, login_name, user_name, user_type, email, phonenumber, sex, avatar, password, salt, status, del_flag, create_by, create_time, remark) VALUES
(200, 103, '13800138005', '赵明', '01', 'patient1@clinic.com', '13800138005', '0', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '患者账号'),
(201, 103, '13800138006', '钱红', '01', 'patient2@clinic.com', '13800138006', '1', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '患者账号'),
(202, 103, '13800138007', '孙伟', '01', 'patient3@clinic.com', '13800138007', '0', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '患者账号'),
(203, 103, '13800138008', '李静', '01', 'patient4@clinic.com', '13800138008', '1', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '患者账号'),
(204, 103, '13800138009', '周强', '01', 'patient5@clinic.com', '13800138009', '0', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '患者账号'),
(205, 103, '13800138010', '吴婷', '01', 'patient6@clinic.com', '13800138010', '1', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '患者账号'),
(206, 103, '13800138011', '郑峰', '01', 'patient7@clinic.com', '13800138011', '0', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '患者账号'),
(207, 103, '13800138012', '王芳', '01', 'patient8@clinic.com', '13800138012', '1', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '患者账号'),
(208, 103, '13800138013', '何磊', '01', 'patient9@clinic.com', '13800138013', '0', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '患者账号'),
(209, 103, '13800138014', '郭敏', '01', 'patient10@clinic.com', '13800138014', '1', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '患者账号'),
(210, 103, '13800138015', '陈旭', '01', 'patient11@clinic.com', '13800138015', '0', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '患者账号'),
(211, 103, '13800138016', '宋雨', '01', 'patient12@clinic.com', '13800138016', '1', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '患者账号');

-- ============================================
-- 第6部分：分配用户角色
-- ============================================

INSERT IGNORE INTO sys_user_role (user_id, role_id) VALUES
(100, 2),         -- 诊所管理员 - 普通角色
(101, 3),         -- 李医生 - 医生
(102, 3),         -- 王医生 - 医生
(103, 3),         -- 张医生 - 医生
(200, 4),         -- 赵明 - 患者
(201, 4),         -- 钱红 - 患者
(202, 4),         -- 孙伟 - 患者
(203, 4),         -- 李静 - 患者
(204, 4),         -- 周强 - 患者
(205, 4),         -- 吴婷 - 患者
(206, 4),         -- 郑峰 - 患者
(207, 4),         -- 王芳 - 患者
(208, 4),         -- 何磊 - 患者
(209, 4),         -- 郭敏 - 患者
(210, 4),         -- 陈旭 - 患者
(211, 4);         -- 宋雨 - 患者

-- ============================================
-- 第7部分：系统配置
-- ============================================

INSERT INTO clinic_config (config_key, config_value, description, create_time, update_time) VALUES
('clinic.stockWarningThreshold', '10', '库存预警阈值', NOW(), NOW()),
('clinic.appointmentDays', '14', '可预约天数', NOW(), NOW()),
('clinic_name', '阳光社区诊所', '诊所名称', NOW(), NOW()),
('clinic_address', '北京市朝阳区建国路88号', '诊所地址', NOW(), NOW()),
('clinic_phone', '010-88888888', '诊所电话', NOW(), NOW());

-- ============================================
-- 第8部分：药品数据（带完整信息）
-- ============================================

INSERT INTO clinic_medicine (medicine_id, name, specification, dosage_form, form, manufacturer, expiry_date, price, stock, warning_stock, warning_threshold, min_stock, unit, pharmacology, indications, dosage, side_effects, storage, status, is_prescription, category, location, create_by, create_time, update_by, update_time, remark) VALUES
(100, '复方感冒灵颗粒(白云山)', '10g*9袋', '颗粒剂', '内服', '广州白云山制药总厂', '2027-06-15', 15.80, 300, 75, 38, 38, '盒', '中西药复方制剂，金银花、五指柑、野菊花、三叉苦、南板蓝根、岗梅等中药成分具有清热解毒功效；对乙酰氨基酚、马来酸氯苯那敏能缓解感冒症状。', '用于风热感冒之发热、微恶风寒、鼻塞流涕、咽喉肿痛等症。', '开水冲服，一次1袋，一日3次。', '可见困倦、嗜睡、口渴、虚弱感；偶见皮疹、瘙痒、食欲不振、恶心等。', '密封，置阴凉干燥处（不超过20℃）。', 'active', 0, '内服药', 'A-01', 'admin', NOW(), 'admin', NOW(), '常用感冒药'),
(101, '感冒灵颗粒(999)', '10g*9袋', '颗粒剂', '内服', '华润三九医药股份有限公司', '2027-05-20', 12.50, 350, 88, 44, 44, '盒', '中西药复方制剂，含三叉苦、金盏开、四季青等中药成分，以及对乙酰氨基酚、马来酸氯苯那敏、咖啡因等西药成分，具有解热镇痛作用。', '用于感冒引起的头痛、发热、鼻塞、流涕、咽喉痛等症状。', '开水冲服，一次1袋，一日3次。', '可见困倦、嗜睡、口渴、虚弱感；偶见皮疹、瘙痒等过敏反应。', '密封，置阴凉干燥处（不超过20℃）。', 'active', 0, '内服药', 'A-02', 'admin', NOW(), 'admin', NOW(), '常用感冒药'),
(102, '连花清瘟胶囊(以岭)', '0.35g*24粒', '胶囊剂', '内服', '石家庄以岭药业股份有限公司', '2027-08-10', 23.50, 280, 70, 35, 35, '盒', '主要成分包括金银花、连翘、麻黄、杏仁、石膏、板蓝根、鱼腥草等，具有清热解毒、宣肺泄热功效。现代药理研究表明其具有抗菌、抗病毒、解热、镇咳祛痰作用。', '用于治疗流行性感冒属热毒袭肺证，症见发热或高热、恶寒、肌肉酸痛、鼻塞流涕、咳嗽、头痛、咽干咽痛等。', '口服，一次4粒，一日3次。', '偶见胃肠道不适，如恶心、腹泻等；罕见皮疹、瘙痒等过敏反应。', '密封，置阴凉干燥处。', 'active', 0, '内服药', 'A-03', 'admin', NOW(), 'admin', NOW(), '流感用药'),
(103, '板蓝根颗粒(香雪)', '10g*20袋', '颗粒剂', '内服', '香雪制药股份有限公司', '2027-04-25', 18.90, 400, 100, 50, 50, '盒', '主要成分为板蓝根，具有清热解毒、凉血利咽功效。现代药理研究表明其具有抗菌、抗病毒、增强免疫力作用。', '用于肺胃热盛所致的咽喉肿痛、口咽干燥；急性扁桃体炎、腮腺炎见上述证候者。', '开水冲服，一次5-10g，一日3-4次。', '偶见胃肠道不适，罕见皮疹等过敏反应。', '密封，置阴凉干燥处。', 'active', 0, '内服药', 'A-04', 'admin', NOW(), 'admin', NOW(), '常用清热药'),
(104, '维C银翘片(贵州百灵)', '12片*2板', '片剂', '内服', '贵州百灵企业集团制药股份有限公司', '2027-03-15', 8.50, 450, 113, 57, 57, '盒', '中西药复方制剂，含金银花、连翘、维生素C等中药成分，以及对乙酰氨基酚、马来酸氯苯那敏等西药成分，具有解热镇痛、抗过敏作用。', '用于风热感冒引起的发热、头痛、咳嗽、口干、咽喉疼痛。', '口服，一次2片，一日3次。', '可见困倦、嗜睡、口渴；偶见皮疹、瘙痒等过敏反应。', '密封，置干燥处。', 'active', 0, '内服药', 'A-05', 'admin', NOW(), 'admin', NOW(), '常用感冒药'),
(105, '阿莫西林胶囊(联邦制药)', '0.25g*24粒', '胶囊剂', '内服', '珠海联邦制药股份有限公司', '2027-06-25', 18.50, 500, 125, 63, 63, '盒', '青霉素类抗生素，通过抑制细菌细胞壁合成发挥杀菌作用。对革兰氏阳性菌和部分革兰氏阴性菌有抗菌活性。', '用于敏感菌引起的呼吸道感染、泌尿生殖道感染、皮肤软组织感染、急性单纯性淋病等。', '口服，成人一次0.5g，每6-8小时一次；儿童按体重一次6.7-13.3mg/kg，每8小时一次。', '常见过敏反应如皮疹、瘙痒、荨麻疹；恶心、腹泻等胃肠道反应；严重者可致过敏性休克。', '遮光，密封，在干燥处保存。', 'active', 1, '内服药', 'B-01', 'admin', NOW(), 'admin', NOW(), '抗生素'),
(106, '头孢克肟分散片(石药集团)', '0.1g*6片', '片剂', '内服', '石药集团中诺药业(石家庄)有限公司', '2027-07-15', 28.80, 320, 80, 40, 40, '盒', '第三代头孢菌素类抗生素，通过抑制细菌细胞壁合成发挥杀菌作用。对多种革兰氏阳性菌和革兰氏阴性菌有抗菌活性。', '用于敏感菌引起的支气管炎、肺炎、胆囊炎、尿路感染、中耳炎、鼻窦炎等。', '口服，成人一次0.1g，一日2次；儿童按体重一次1.5-3mg/kg，一日2次。', '常见皮疹、瘙痒等过敏反应；恶心、腹泻等胃肠道反应；偶见肝功能异常、血液系统改变。', '遮光，密封，在干燥处保存。', 'active', 1, '内服药', 'B-02', 'admin', NOW(), 'admin', NOW(), '抗生素'),
(107, '罗红霉素分散片(西南药业)', '0.15g*12片', '片剂', '内服', '西南药业股份有限公司', '2027-08-20', 21.30, 290, 73, 37, 37, '盒', '大环内酯类抗生素，通过抑制细菌蛋白质合成发挥抑菌作用。对多种革兰氏阳性菌、部分革兰氏阴性菌及支原体、衣原体有抗菌活性。', '用于敏感菌引起的咽炎、扁桃体炎、鼻窦炎、急性支气管炎、肺炎、皮肤软组织感染、淋病等。', '口服，成人一次0.15g，一日2次；儿童按体重一次2.5-5mg/kg，一日2次。', '常见恶心、呕吐、腹痛、腹泻等胃肠道反应；偶见皮疹、瘙痒等过敏反应；罕见肝功能异常。', '密封，在干燥处保存。', 'active', 1, '内服药', 'B-03', 'admin', NOW(), 'admin', NOW(), '抗生素'),
(108, '阿奇霉素片(辉瑞)', '0.25g*6片', '片剂', '内服', '辉瑞制药有限公司', '2027-09-10', 35.60, 200, 50, 25, 25, '盒', '大环内酯类抗生素，通过抑制细菌蛋白质合成发挥抑菌作用。对多种革兰氏阳性菌、部分革兰氏阴性菌及支原体、衣原体有抗菌活性。', '用于敏感菌引起的社区获得性肺炎、盆腔炎、宫颈炎、非淋菌性尿道炎等。', '口服，成人一次0.25g，一日1次，或一次0.5g，一日1次。', '常见恶心、呕吐、腹痛、腹泻等胃肠道反应；偶见皮疹、瘙痒等过敏反应；罕见肝功能异常、QT间期延长。', '密封，在干燥处保存。', 'active', 1, '内服药', 'B-04', 'admin', NOW(), 'admin', NOW(), '抗生素'),
(109, '左氧氟沙星片(第一三共)', '0.5g*6片', '片剂', '内服', '第一三共制药(上海)有限公司', '2027-05-25', 24.90, 310, 78, 39, 39, '盒', '氟喹诺酮类抗菌药，通过抑制细菌DNA旋转酶和拓扑异构酶IV发挥杀菌作用。对多种革兰氏阳性菌和革兰氏阴性菌有抗菌活性。', '用于敏感菌引起的呼吸道感染、泌尿生殖道感染、消化道感染、骨关节感染、皮肤软组织感染等。', '口服，成人一次0.5g，一日1次。', '常见恶心、呕吐、腹痛、腹泻等胃肠道反应；头晕、头痛、失眠等神经系统反应；偶见皮疹、瘙痒等过敏反应；罕见肌腱炎、QT间期延长。', '遮光，密封，在干燥处保存。', 'active', 1, '内服药', 'B-05', 'admin', NOW(), 'admin', NOW(), '抗生素'),
(110, '甲硝唑片(石药集团)', '0.2g*100片', '片剂', '内服', '石药集团中诺药业(石家庄)有限公司', '2027-05-15', 6.50, 500, 125, 63, 63, '瓶', '硝基咪唑类抗厌氧菌药，具有抗厌氧菌作用，对脆弱拟杆菌、梭形杆菌等厌氧菌有较强抗菌活性。', '用于治疗厌氧菌感染，如腹腔感染、盆腔感染、肺脓肿、脑膜炎、败血症等；也用于预防术后厌氧菌感染。', '口服，成人一次0.2-0.4g，一日3次。', '常见恶心、呕吐、腹痛、腹泻等胃肠道反应；口中金属味；偶见皮疹、瘙痒等过敏反应；长期大剂量使用可致神经系统毒性。', '遮光，密封，在干燥处保存。', 'active', 1, '内服药', 'B-06', 'admin', NOW(), 'admin', NOW(), '抗生素'),
(111, '维生素C片(华中药业)', '0.1g*100片', '片剂', '内服', '华中药业股份有限公司', '2027-12-30', 5.20, 500, 125, 63, 63, '瓶', '维生素类药物，参与机体氧化还原反应和多种代谢过程，具有抗氧化作用。', '用于预防和治疗维生素C缺乏症，如坏血病；也可用于补充维生素C，如急慢性传染病、紫癜等。', '口服，成人一次50-100mg，一日2-3次。', '过量服用可引起恶心、呕吐、腹泻、皮疹等；长期大量服用可引起肾结石。', '遮光，密封，在干燥处保存。', 'active', 0, '内服药', 'C-01', 'admin', NOW(), 'admin', NOW(), '维生素'),
(112, '复合维生素B片(汤臣倍健)', '100片', '片剂', '内服', '汤臣倍健股份有限公司', '2027-11-15', 28.50, 380, 95, 48, 48, '瓶', 'B族维生素复合制剂，参与机体糖、脂肪、蛋白质代谢，维持机体正常生理功能。', '用于预防和治疗B族维生素缺乏症，如脚气病、糙皮病、营养不良等。', '口服，成人一次1-3片，一日3次。', '偶见皮肤潮红、瘙痒等过敏反应；尿液呈黄色为正常现象。', '遮光，密封，在干燥处保存。', 'active', 0, '内服药', 'C-02', 'admin', NOW(), 'admin', NOW(), '维生素'),
(113, '蒙脱石散(博福-益普生)', '3g*10袋', '其他', '内服', '博福-益普生(天津)制药有限公司', '2027-05-12', 26.30, 380, 95, 48, 48, '盒', '消化道黏膜保护剂，具有层纹状结构和非均匀性电荷分布，能吸附消化道内的病毒、细菌及其毒素。', '用于急慢性腹泻，如急慢性腹泻、肠易激综合征、结肠炎、胃炎等。', '口服，成人一次1袋，一日2-3次，将本品倒入温开水50ml中服用。', '可见便秘、粪便量减少等；偶见恶心、腹胀、腹痛等。', '密封，在干燥处保存。', 'active', 0, '内服药', 'D-01', 'admin', NOW(), 'admin', NOW(), '消化药'),
(114, '奥美拉唑肠溶胶囊(阿斯利康)', '20mg*14粒', '胶囊剂', '内服', '阿斯利康制药有限公司', '2027-06-22', 42.50, 280, 70, 35, 35, '盒', '质子泵抑制剂，通过抑制胃壁细胞H+/K+-ATP酶活性，减少胃酸分泌。具有强效抑酸作用。', '用于胃溃疡、十二指肠溃疡、应激性溃疡、反流性食管炎、卓-艾综合征等。', '口服，成人一次20mg，一日1-2次。', '常见头痛、腹泻、恶心、呕吐、便秘等；偶见皮疹、瘙痒等过敏反应；罕见肝功能异常、血液系统改变。', '遮光，密封，在干燥处保存。', 'active', 1, '内服药', 'D-02', 'admin', NOW(), 'admin', NOW(), '胃药'),
(115, '复方丹参滴丸(天士力)', '27mg*180粒', '其他', '内服', '天士力医药集团股份有限公司', '2027-06-15', 29.80, 320, 80, 40, 40, '瓶', '活血化瘀类中成药，主要成分为丹参、三七、冰片，具有活血化瘀、理气止痛功效。现代药理研究表明其能扩张冠状动脉、改善心肌缺血。', '用于气滞血瘀所致的胸痹，症见胸闷、心前区刺痛；冠心病心绞痛见上述证候者。', '口服或舌下含服，一次10丸，一日3次。', '偶见胃肠道不适，如恶心、腹痛等；罕见皮疹、瘙痒等过敏反应。', '密封，置阴凉干燥处。', 'active', 0, '内服药', 'E-01', 'admin', NOW(), 'admin', NOW(), '心脑血管'),
(116, '氯雷他定片(扬子江)', '10mg*6片', '片剂', '内服', '扬子江药业集团有限公司', '2027-04-20', 18.90, 280, 70, 35, 35, '盒', '抗组胺药，通过选择性阻断外周H1受体，缓解过敏症状。', '用于过敏性鼻炎、荨麻疹、湿疹、皮炎、皮肤瘙痒等过敏症状。', '口服，成人一次10mg，一日1次。', '常见乏力、头痛、嗜睡、口干、胃肠道不适等；偶见皮疹、瘙痒等过敏反应。', '密封，在干燥处保存。', 'active', 0, '内服药', 'F-01', 'admin', NOW(), 'admin', NOW(), '抗过敏药'),
(117, '云南白药气雾剂(云南白药)', '50g+30g', '喷雾剂', '外用', '云南白药集团股份有限公司', '2027-12-31', 35.00, 150, 38, 19, 19, '盒', '活血化瘀、消肿止痛类中成药，用于跌打损伤、瘀血肿痛。', '用于跌打损伤、瘀血肿痛、肌肉酸痛、风湿痹痛等。', '外用，喷于伤患处，一日3-5次。', '罕见皮疹、瘙痒等过敏反应；偶见局部刺痛。', '密封，置阴凉干燥处。', 'active', 0, '外用药', 'G-01', 'admin', NOW(), 'admin', NOW(), '外用药'),
(118, '碘伏消毒液(利康)', '100ml', '外用剂', '外用', '北京利康 sanitizer 有限公司', '2027-05-31', 12.00, 200, 50, 25, 25, '瓶', '消毒防腐药，碘与表面活性剂结合，具有广谱杀菌作用，能杀灭细菌、病毒、真菌、阿米巴原虫等。', '用于皮肤消毒、黏膜消毒、伤口清洁；也用于治疗皮肤黏膜真菌感染。', '外用，局部涂擦，一日1-2次。', '偶见皮肤刺激如烧灼感、红肿等；罕见皮疹、瘙痒等过敏反应。', '遮光，密封，在凉暗处保存。', 'active', 0, '外用药', 'G-02', 'admin', NOW(), 'admin', NOW(), '消毒药'),
(119, '布洛芬缓释胶囊(中美史克)', '0.3g*20粒', '胶囊剂', '内服', '中美天津史克制药有限公司', '2027-06-30', 28.00, 200, 50, 25, 25, '盒', '非甾体抗炎药，通过抑制环氧合酶，减少前列腺素合成，具有解热、镇痛、抗炎作用。', '用于缓解轻至中度疼痛如头痛、关节痛、偏头痛、牙痛、肌肉痛、神经痛、痛经；也用于普通感冒或流行性感冒引起的发热。', '口服，成人一次1粒，一日2次（早晚各一次）。', '常见恶心、呕吐、腹胀、腹泻、便秘等胃肠道反应；可见头晕、头痛、嗜睡等；偶见皮疹、瘙痒等过敏反应。', '密封，在干燥处保存。', 'active', 0, '内服药', 'H-01', 'admin', NOW(), 'admin', NOW(), '止痛药'),
(120, '氨咖黄敏胶囊(感冒灵)', '12粒', '胶囊剂', '内服', '华润三九医药股份有限公司', '2027-03-15', 8.00, 400, 100, 50, 50, '盒', '中西药复方制剂，含对乙酰氨基酚、咖啡因、马来酸氯苯那敏、人工牛黄等，具有解热镇痛作用。', '用于缓解普通感冒或流行性感冒引起的发热、头痛、鼻塞、咽痛等症状。', '口服，成人一次1-2粒，一日3次。', '可见困倦、嗜睡、口渴、虚弱感；偶见皮疹、瘙痒等过敏反应。', '密封，在干燥处保存。', 'active', 0, '内服药', 'A-06', 'admin', NOW(), 'admin', NOW(), '感冒药');

-- ============================================
-- 第9部分：批次库存数据
-- ============================================

INSERT INTO clinic_stock_batch (batch_id, medicine_id, batch_number, expiry_date, remaining_quantity, create_time, update_time) VALUES
(100, 100, 'B2027A001', '2027-06-15', 120, NOW(), NOW()),
(101, 100, 'B2027A002', '2027-08-20', 180, NOW(), NOW()),
(102, 101, 'B2027B001', '2027-05-20', 350, NOW(), NOW()),
(103, 102, 'B2027C001', '2027-08-10', 280, NOW(), NOW()),
(104, 103, 'B2027D001', '2027-04-25', 400, NOW(), NOW()),
(105, 104, 'B2027E001', '2027-03-15', 450, NOW(), NOW()),
(106, 105, 'B2027F001', '2027-06-25', 500, NOW(), NOW()),
(107, 106, 'B2027G001', '2027-07-15', 320, NOW(), NOW()),
(108, 107, 'B2027H001', '2027-08-20', 290, NOW(), NOW()),
(109, 108, 'B2027I001', '2027-09-10', 200, NOW(), NOW()),
(110, 109, 'B2027J001', '2027-05-25', 310, NOW(), NOW()),
(111, 110, 'B2027K001', '2027-05-15', 500, NOW(), NOW()),
(112, 111, 'B2027L001', '2027-12-30', 500, NOW(), NOW()),
(113, 112, 'B2027M001', '2027-11-15', 380, NOW(), NOW()),
(114, 113, 'B2027N001', '2027-05-12', 380, NOW(), NOW()),
(115, 114, 'B2027O001', '2027-06-22', 280, NOW(), NOW()),
(116, 115, 'B2027P001', '2027-06-15', 320, NOW(), NOW()),
(117, 116, 'B2027Q001', '2027-04-20', 280, NOW(), NOW()),
(118, 117, 'B2027R001', '2027-12-31', 150, NOW(), NOW()),
(119, 118, 'B2027S001', '2027-05-31', 200, NOW(), NOW()),
(120, 119, 'B2027T001', '2027-06-30', 200, NOW(), NOW()),
(121, 120, 'B2027U001', '2027-03-15', 400, NOW(), NOW());

-- ============================================
-- 第10部分：患者数据
-- ============================================

INSERT INTO clinic_patient (patient_id, user_id, name, gender, age, phone, birthday, address, allergy_history, past_history, blood_type, wechat, avatar, create_by, create_time, update_by, update_time, remark) VALUES
(100, 200, '赵明', '男', 40, '13800138005', '1986-03-15', '北京市朝阳区建国路88号', '青霉素过敏', '高血压病史5年，规律服药', 'A', 'zhaoming86', '', 'admin', NOW(), 'admin', NOW(), '慢病管理'),
(101, 201, '钱红', '女', 34, '13800138006', '1992-07-22', '北京市海淀区中关村大街1号', '海鲜过敏', '无特殊病史', 'B', 'qianhong92', '', 'admin', NOW(), 'admin', NOW(), '普通患者'),
(102, 202, '孙伟', '男', 46, '13800138007', '1980-11-08', '北京市东城区王府井大街255号', '花粉过敏', '哮喘病史3年，季节性发作', 'O', 'sunwei80', '', 'admin', NOW(), 'admin', NOW(), '呼吸科'),
(103, 203, '李静', '女', 29, '13800138008', '1997-04-02', '北京市丰台区西客站南路1号', '无', '胃炎病史', 'AB', 'lijing97', '', 'admin', NOW(), 'admin', NOW(), '消化科'),
(104, 204, '周强', '男', 52, '13800138009', '1974-10-10', '北京市昌平区立汤路168号', '无', '糖尿病病史', 'A', 'zhouqiang74', '', 'admin', NOW(), 'admin', NOW(), '慢病管理'),
(105, 205, '吴婷', '女', 31, '13800138010', '1995-12-01', '北京市通州区新华大街256号', '头孢过敏', '甲状腺结节', 'B', 'wuting95', '', 'admin', NOW(), 'admin', NOW(), '复诊'),
(106, 206, '郑峰', '男', 38, '13800138011', '1988-01-23', '北京市顺义区新顺南大街288号', '无', '无', 'O', 'zhengfeng88', '', 'admin', NOW(), 'admin', NOW(), '普通患者'),
(107, 207, '王芳', '女', 44, '13800138012', '1982-06-16', '北京市大兴区兴政街12号', '无', '偏头痛病史', 'AB', 'wangfang82', '', 'admin', NOW(), 'admin', NOW(), '神经内科'),
(108, 208, '何磊', '男', 27, '13800138013', '1999-09-12', '北京市石景山区石景山路56号', '尘螨过敏', '鼻炎病史', 'A', 'helei99', '', 'admin', NOW(), 'admin', NOW(), '过敏门诊'),
(109, 209, '郭敏', '女', 36, '13800138014', '1990-02-19', '北京市门头沟区新桥南大街88号', '无', '无', 'B', 'guomin90', '', 'admin', NOW(), 'admin', NOW(), '普通患者'),
(110, 210, '陈旭', '男', 33, '13800138015', '1993-08-25', '北京市房山区良乡拱辰南大街1号', '无', '腰肌劳损', 'O', 'chenxu93', '', 'admin', NOW(), 'admin', NOW(), '康复门诊'),
(111, 211, '宋雨', '女', 25, '13800138016', '2001-05-03', '北京市延庆区百泉街10号', '青霉素过敏', '无', 'AB', 'songyu01', '', 'admin', NOW(), 'admin', NOW(), '普通患者');

-- ============================================
-- 第11部分：医生排班数据
-- ============================================

INSERT INTO clinic_schedule (schedule_id, doctor_id, doctor_name, title, schedule_date, start_time, end_time, total_slots, booked_slots, status, create_by, create_time, update_by, update_time, remark) VALUES
(100, 101, '李医生', '内科主治医师', CURDATE(), '08:00', '12:00', 20, 6, 'active', 'admin', NOW(), 'admin', NOW(), '上午门诊'),
(101, 101, '李医生', '内科主治医师', CURDATE(), '14:00', '17:30', 15, 4, 'active', 'admin', NOW(), 'admin', NOW(), '下午门诊'),
(102, 101, '李医生', '内科主治医师', DATE_ADD(CURDATE(), INTERVAL 1 DAY), '08:30', '12:00', 18, 1, 'active', 'admin', NOW(), 'admin', NOW(), '次日门诊'),
(103, 102, '王医生', '外科主治医师', CURDATE(), '08:30', '12:00', 18, 5, 'active', 'admin', NOW(), 'admin', NOW(), '外科门诊'),
(104, 102, '王医生', '外科主治医师', DATE_ADD(CURDATE(), INTERVAL 1 DAY), '14:00', '17:30', 16, 3, 'active', 'admin', NOW(), 'admin', NOW(), '复诊门诊'),
(105, 103, '张医生', '儿科主治医师', CURDATE(), '09:00', '12:00', 22, 7, 'active', 'admin', NOW(), 'admin', NOW(), '儿科门诊'),
(106, 103, '张医生', '儿科主治医师', DATE_ADD(CURDATE(), INTERVAL 1 DAY), '14:00', '17:30', 20, 2, 'active', 'admin', NOW(), 'admin', NOW(), '儿科复诊');

-- ============================================
-- 第12部分：预约数据
-- ============================================

INSERT INTO clinic_appointment (appointment_id, patient_id, patient_name, patient_phone, doctor_id, doctor_name, schedule_id, appointment_date, appointment_time, sequence_number, status, is_offline, create_by, create_time, update_by, update_time, remark) VALUES
(100, 100, '赵明', '13800138005', 101, '李医生', 100, CURDATE(), '08:30-08:45', 1, 'confirmed', 0, 'admin', NOW(), 'admin', NOW(), '线上预约'),
(101, 101, '钱红', '13800138006', 101, '李医生', 100, CURDATE(), '08:45-09:00', 2, 'completed', 1, 'admin', NOW(), 'admin', NOW(), '线下已就诊'),
(102, 102, '孙伟', '13800138007', 102, '王医生', 103, CURDATE(), '09:00-09:15', 1, 'pending', 0, 'admin', NOW(), 'admin', NOW(), '待确认'),
(103, 103, '李静', '13800138008', 102, '王医生', 103, CURDATE(), '09:15-09:30', 2, 'cancelled', 0, 'admin', NOW(), 'admin', NOW(), '用户取消'),
(104, 104, '周强', '13800138009', 103, '张医生', 105, CURDATE(), '09:30-09:45', 1, 'completed', 1, 'admin', NOW(), 'admin', NOW(), '儿科家属陪诊'),
(105, 105, '吴婷', '13800138010', 101, '李医生', 101, CURDATE(), '14:00-14:15', 1, 'confirmed', 0, 'admin', NOW(), 'admin', NOW(), '复诊预约');

-- ============================================
-- 第13部分：病历数据
-- ============================================

INSERT INTO clinic_medical_record (record_id, patient_id, patient_name, patient_gender, patient_age, patient_phone, patient_birthday, patient_blood_type, doctor_id, doctor_name, visit_time, chief_complaint, present_illness, past_history, allergy_history, physical_exam, diagnosis, treatment, prescription, attachments, follow_up, create_by, create_time, update_by, update_time, remark) VALUES
(100, 100, '赵明', '男', 40, '13800138005', '1986-03-15', 'A', 101, '李医生', DATE_SUB(NOW(), INTERVAL 3 DAY), '发热咳嗽2天', '咽痛、低热', '高血压', '青霉素过敏', '体温37.8℃，咽部充血', '上呼吸道感染', '对症治疗，多饮水', '[{"medicineId":100,"name":"复方感冒灵颗粒","specification":"10g*9袋","dosage":"1袋","frequency":"每日3次","days":3},{"medicineId":119,"name":"布洛芬缓释胶囊","specification":"0.3g*20粒","dosage":"1粒","frequency":"必要时","days":2}]', '[]', '3天后复诊，如症状加重随时就诊', 'admin', NOW(), 'admin', NOW(), '首诊'),
(101, 101, '钱红', '女', 34, '13800138006', '1992-07-22', 'B', 101, '李医生', DATE_SUB(NOW(), INTERVAL 2 DAY), '胃部不适1周', '反酸、嗳气', '无', '海鲜过敏', '上腹轻压痛', '慢性胃炎', '抑酸+饮食调整', '[{"medicineId":114,"name":"奥美拉唑肠溶胶囊","specification":"20mg*14粒","dosage":"1粒","frequency":"每日1次","days":14}]', '[]', '2周后复诊，如症状加重随时就诊', 'admin', NOW(), 'admin', NOW(), '慢病随访'),
(102, 102, '孙伟', '男', 46, '13800138007', '1980-11-08', 'O', 102, '王医生', DATE_SUB(NOW(), INTERVAL 1 DAY), '咽痛伴发热', '起病急', '哮喘病史', '花粉过敏', '咽部红肿', '急性咽炎', '抗感染治疗', '[{"medicineId":106,"name":"头孢克肟分散片","specification":"0.1g*6片","dosage":"1片","frequency":"每日2次","days":5}]', '[]', '必要时复诊', 'admin', NOW(), 'admin', NOW(), '普通门诊'),
(103, 104, '周强', '男', 52, '13800138009', '1974-10-10', 'A', 103, '张医生', NOW(), '咳嗽3天', '夜间加重', '糖尿病病史', '无', '双肺呼吸音粗', '急性支气管炎', '止咳化痰', '[{"medicineId":105,"name":"阿莫西林胶囊","specification":"0.25g*24粒","dosage":"2粒","frequency":"每日3次","days":5},{"medicineId":105,"name":"复方甘草片","specification":"100片","dosage":"2片","frequency":"每日3次","days":4}]', '[]', '1周后复诊', 'admin', NOW(), 'admin', NOW(), '已开药');

-- ============================================
-- 第14部分：库存记录数据
-- ============================================

INSERT INTO clinic_stock_record (record_id, medicine_id, medicine_name, operation_type, quantity, before_stock, after_stock, supplier, purchase_price, batch_number, expiry_date, operator_id, operator_name, patient_name, doctor_name, related_record_id, related_record_type, remark, create_time) VALUES
(100, 100, '复方感冒灵颗粒(白云山)', 'in', 100, 200, 300, '国药控股', 12.00, 'B2027A002', '2027-08-20', 100, '诊所管理员', NULL, NULL, NULL, NULL, '常规入库', DATE_SUB(NOW(), INTERVAL 10 DAY)),
(101, 105, '阿莫西林胶囊(联邦制药)', 'in', 200, 300, 500, '国药控股', 14.00, 'B2027F001', '2027-06-25', 100, '诊所管理员', NULL, NULL, NULL, NULL, '常规入库', DATE_SUB(NOW(), INTERVAL 9 DAY)),
(102, 100, '复方感冒灵颗粒(白云山)', 'out', 3, 303, 300, NULL, NULL, 'B2027A001', '2027-06-15', 101, '李医生', '赵明', '李医生', '100', 'medical', '处方发药', DATE_SUB(NOW(), INTERVAL 3 DAY)),
(103, 119, '布洛芬缓释胶囊(中美史克)', 'out', 2, 202, 200, NULL, NULL, 'B2027T001', '2027-06-30', 101, '李医生', '赵明', '李医生', '100', 'medical', '处方发药', DATE_SUB(NOW(), INTERVAL 3 DAY)),
(104, 114, '奥美拉唑肠溶胶囊(阿斯利康)', 'out', 14, 294, 280, NULL, NULL, 'B2027O001', '2027-06-22', 101, '李医生', '钱红', '李医生', '101', 'medical', '处方发药', DATE_SUB(NOW(), INTERVAL 2 DAY)),
(105, 106, '头孢克肟分散片(石药集团)', 'out', 5, 325, 320, NULL, NULL, 'B2027G001', '2027-07-15', 102, '王医生', '孙伟', '王医生', '102', 'medical', '处方发药', DATE_SUB(NOW(), INTERVAL 1 DAY)),
(106, 118, '碘伏消毒液(利康)', 'check', 0, 200, 200, NULL, NULL, 'B2027S001', '2027-05-31', 100, '诊所管理员', NULL, NULL, NULL, NULL, '库存盘点正常', NOW());

-- ============================================
-- 第15部分：药品使用记录
-- ============================================

INSERT INTO clinic_usage_record (usage_id, medicine_id, medicine_name, specification, quantity, patient_id, patient_name, medical_record_id, doctor_id, doctor_name, issue_time, issuer_id, issuer_name, create_time) VALUES
(100, 100, '复方感冒灵颗粒(白云山)', '10g*9袋', 3, 100, '赵明', '100', 101, '李医生', DATE_SUB(NOW(), INTERVAL 3 DAY), 100, '诊所管理员', NOW()),
(101, 119, '布洛芬缓释胶囊(中美史克)', '0.3g*20粒', 2, 100, '赵明', '100', 101, '李医生', DATE_SUB(NOW(), INTERVAL 3 DAY), 100, '诊所管理员', NOW()),
(102, 114, '奥美拉唑肠溶胶囊(阿斯利康)', '20mg*14粒', 14, 101, '钱红', '101', 101, '李医生', DATE_SUB(NOW(), INTERVAL 2 DAY), 100, '诊所管理员', NOW()),
(103, 106, '头孢克肟分散片(石药集团)', '0.1g*6片', 5, 102, '孙伟', '102', 102, '王医生', DATE_SUB(NOW(), INTERVAL 1 DAY), 100, '诊所管理员', NOW());

-- ============================================
-- 启用外键检查
-- ============================================
SET FOREIGN_KEY_CHECKS = 1;

SELECT '诊所管理系统数据初始化完成！' AS message;
SELECT '执行顺序: 1. ry_20250416.sql (RuoYi基础框架)  2. clinic_data_init.sql (诊所业务数据)' AS message;

-- ============================================
-- 2026-04-04 medicine recognition additions
-- ============================================

SET @db_name = DATABASE();
SET @barcode_column_exists = (
  SELECT COUNT(1) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @db_name AND TABLE_NAME = 'clinic_medicine' AND COLUMN_NAME = 'barcode'
);
SET @barcode_column_sql = IF(
  @barcode_column_exists = 0,
  'ALTER TABLE clinic_medicine ADD COLUMN barcode VARCHAR(64) NULL COMMENT ''药品条码'' AFTER manufacturer',
  'SELECT ''clinic_medicine.barcode already exists'''
);
PREPARE stmt_clinic_barcode_column FROM @barcode_column_sql;
EXECUTE stmt_clinic_barcode_column;
DEALLOCATE PREPARE stmt_clinic_barcode_column;

SET @barcode_index_exists = (
  SELECT COUNT(1) FROM information_schema.STATISTICS
  WHERE TABLE_SCHEMA = @db_name AND TABLE_NAME = 'clinic_medicine' AND INDEX_NAME = 'idx_barcode'
);
SET @barcode_index_sql = IF(
  @barcode_index_exists = 0,
  'CREATE INDEX idx_barcode ON clinic_medicine(barcode)',
  'SELECT ''idx_barcode already exists'''
);
PREPARE stmt_clinic_barcode_index FROM @barcode_index_sql;
EXECUTE stmt_clinic_barcode_index;
DEALLOCATE PREPARE stmt_clinic_barcode_index;

CREATE TABLE IF NOT EXISTS clinic_ai_provider (
  provider_id BIGINT(20) NOT NULL AUTO_INCREMENT,
  provider_code VARCHAR(64) NOT NULL,
  provider_name VARCHAR(128) NOT NULL,
  api_base_url VARCHAR(255) DEFAULT NULL,
  api_key VARCHAR(512) DEFAULT NULL,
  enabled TINYINT(1) NOT NULL DEFAULT 1,
  remark VARCHAR(500) DEFAULT NULL,
  create_by VARCHAR(64) DEFAULT NULL,
  create_time DATETIME DEFAULT NULL,
  update_by VARCHAR(64) DEFAULT NULL,
  update_time DATETIME DEFAULT NULL,
  PRIMARY KEY (provider_id),
  UNIQUE KEY uk_provider_code (provider_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI Provider 配置';

CREATE TABLE IF NOT EXISTS clinic_ai_model (
  model_id BIGINT(20) NOT NULL AUTO_INCREMENT,
  provider_id BIGINT(20) NOT NULL,
  model_code VARCHAR(128) NOT NULL,
  model_name VARCHAR(128) NOT NULL,
  supports_vision TINYINT(1) NOT NULL DEFAULT 0,
  supports_web_search TINYINT(1) NOT NULL DEFAULT 0,
  supports_json_schema TINYINT(1) NOT NULL DEFAULT 0,
  enabled TINYINT(1) NOT NULL DEFAULT 1,
  remark VARCHAR(500) DEFAULT NULL,
  create_by VARCHAR(64) DEFAULT NULL,
  create_time DATETIME DEFAULT NULL,
  update_by VARCHAR(64) DEFAULT NULL,
  update_time DATETIME DEFAULT NULL,
  PRIMARY KEY (model_id),
  KEY idx_provider_id (provider_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI Model 配置';

CREATE TABLE IF NOT EXISTS clinic_ai_scene_binding (
  scene_id BIGINT(20) NOT NULL AUTO_INCREMENT,
  scene_code VARCHAR(64) NOT NULL,
  scene_name VARCHAR(128) NOT NULL,
  execution_mode VARCHAR(32) NOT NULL,
  primary_model_id BIGINT(20) DEFAULT NULL,
  fallback_model_id BIGINT(20) DEFAULT NULL,
  candidate_limit INT NOT NULL DEFAULT 3,
  timeout_ms INT NOT NULL DEFAULT 15000,
  enabled TINYINT(1) NOT NULL DEFAULT 1,
  remark VARCHAR(500) DEFAULT NULL,
  create_by VARCHAR(64) DEFAULT NULL,
  create_time DATETIME DEFAULT NULL,
  update_by VARCHAR(64) DEFAULT NULL,
  update_time DATETIME DEFAULT NULL,
  PRIMARY KEY (scene_id),
  UNIQUE KEY uk_scene_code (scene_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI 场景绑定';

INSERT IGNORE INTO sys_menu (menu_id, menu_name, parent_id, order_num, url, target, menu_type, visible, is_refresh, perms, icon, create_by, create_time, update_by, update_time, remark) VALUES
(2060, 'AI模型配置', 2000, 6, '#', '', 'M', '0', '1', '', 'fa fa-robot', 'admin', NOW(), '', NULL, 'AI 模型配置目录'),
(2061, 'Provider配置', 2060, 1, 'clinic/ai/provider', '', 'C', '0', '1', 'clinic:ai:provider:view', 'fa fa-plug', 'admin', NOW(), '', NULL, 'AI Provider 配置'),
(2062, 'Model配置', 2060, 2, 'clinic/ai/model', '', 'C', '0', '1', 'clinic:ai:model:view', 'fa fa-cube', 'admin', NOW(), '', NULL, 'AI Model 配置'),
(2063, '场景绑定', 2060, 3, 'clinic/ai/scene', '', 'C', '0', '1', 'clinic:ai:scene:view', 'fa fa-random', 'admin', NOW(), '', NULL, 'AI 场景绑定'),
(2064, 'Provider查询', 2061, 1, '', '', 'F', '0', '1', 'clinic:ai:provider:list', '#', 'admin', NOW(), '', NULL, ''),
(2065, 'Provider新增', 2061, 2, '', '', 'F', '0', '1', 'clinic:ai:provider:add', '#', 'admin', NOW(), '', NULL, ''),
(2066, 'Provider修改', 2061, 3, '', '', 'F', '0', '1', 'clinic:ai:provider:edit', '#', 'admin', NOW(), '', NULL, ''),
(2067, 'Provider删除', 2061, 4, '', '', 'F', '0', '1', 'clinic:ai:provider:remove', '#', 'admin', NOW(), '', NULL, ''),
(2068, 'Provider测试', 2061, 5, '', '', 'F', '0', '1', 'clinic:ai:provider:test', '#', 'admin', NOW(), '', NULL, ''),
(2069, 'Model查询', 2062, 1, '', '', 'F', '0', '1', 'clinic:ai:model:list', '#', 'admin', NOW(), '', NULL, ''),
(2070, 'Model新增', 2062, 2, '', '', 'F', '0', '1', 'clinic:ai:model:add', '#', 'admin', NOW(), '', NULL, ''),
(2071, 'Model修改', 2062, 3, '', '', 'F', '0', '1', 'clinic:ai:model:edit', '#', 'admin', NOW(), '', NULL, ''),
(2072, 'Model删除', 2062, 4, '', '', 'F', '0', '1', 'clinic:ai:model:remove', '#', 'admin', NOW(), '', NULL, ''),
(2073, '场景查询', 2063, 1, '', '', 'F', '0', '1', 'clinic:ai:scene:list', '#', 'admin', NOW(), '', NULL, ''),
(2074, '场景新增', 2063, 2, '', '', 'F', '0', '1', 'clinic:ai:scene:add', '#', 'admin', NOW(), '', NULL, ''),
(2075, '场景修改', 2063, 3, '', '', 'F', '0', '1', 'clinic:ai:scene:edit', '#', 'admin', NOW(), '', NULL, ''),
(2076, '场景删除', 2063, 4, '', '', 'F', '0', '1', 'clinic:ai:scene:remove', '#', 'admin', NOW(), '', NULL, '');

INSERT IGNORE INTO sys_role_menu (role_id, menu_id) VALUES
(1, 2060), (1, 2061), (1, 2062), (1, 2063), (1, 2064), (1, 2065), (1, 2066), (1, 2067), (1, 2068),
(1, 2069), (1, 2070), (1, 2071), (1, 2072), (1, 2073), (1, 2074), (1, 2075), (1, 2076),
(2, 2060), (2, 2061), (2, 2062), (2, 2063), (2, 2064), (2, 2065), (2, 2066), (2, 2067), (2, 2068),
(2, 2069), (2, 2070), (2, 2071), (2, 2072), (2, 2073), (2, 2074), (2, 2075), (2, 2076);

-- 2026-04-04 medicine recognition ai seed
INSERT INTO clinic_ai_provider (provider_code, provider_name, api_base_url, api_key, enabled, remark, create_by, create_time, update_by, update_time)
SELECT 'openai', 'OpenAI 兼容服务', '', '', 0, '请先配置 apiBaseUrl 与 apiKey，再启用服务商。', 'system', NOW(), 'system', NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM clinic_ai_provider WHERE provider_code = 'openai');

INSERT INTO clinic_ai_provider (provider_code, provider_name, api_base_url, api_key, enabled, remark, create_by, create_time, update_by, update_time)
SELECT 'minimax', 'MiniMax', '', '', 0, '请先配置 apiBaseUrl 与 apiKey，再启用服务商。', 'system', NOW(), 'system', NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM clinic_ai_provider WHERE provider_code = 'minimax');

INSERT INTO clinic_ai_model (provider_id, model_code, model_name, supports_vision, supports_web_search, supports_json_schema, enabled, remark, create_by, create_time, update_by, update_time)
SELECT p.provider_id, 'gpt-5.4', 'gpt-5.4', 1, 1, 1, 0, '默认初始化模型。', 'system', NOW(), 'system', NOW()
FROM clinic_ai_provider p
WHERE p.provider_code = 'openai'
  AND NOT EXISTS (SELECT 1 FROM clinic_ai_model m WHERE m.provider_id = p.provider_id AND m.model_code = 'gpt-5.4');

INSERT INTO clinic_ai_model (provider_id, model_code, model_name, supports_vision, supports_web_search, supports_json_schema, enabled, remark, create_by, create_time, update_by, update_time)
SELECT p.provider_id, 'minimax-M2.7', 'minimax-M2.7', 1, 1, 1, 0, '默认初始化模型。', 'system', NOW(), 'system', NOW()
FROM clinic_ai_provider p
WHERE p.provider_code = 'minimax'
  AND NOT EXISTS (SELECT 1 FROM clinic_ai_model m WHERE m.provider_id = p.provider_id AND m.model_code = 'minimax-M2.7');

INSERT INTO clinic_ai_scene_binding (scene_code, scene_name, execution_mode, primary_model_id, fallback_model_id, candidate_limit, timeout_ms, enabled, remark, create_by, create_time, update_by, update_time)
SELECT 'medicine_create_code', '药品建档-扫码识别', 'local_then_model', pm.model_id, fm.model_id, 3, 15000, 1, '默认建档扫码识别场景。', 'system', NOW(), 'system', NOW()
FROM (SELECT 1) seed
LEFT JOIN clinic_ai_model pm ON pm.model_code = 'gpt-5.4'
LEFT JOIN clinic_ai_model fm ON fm.model_code = 'minimax-M2.7'
WHERE NOT EXISTS (SELECT 1 FROM clinic_ai_scene_binding WHERE scene_code = 'medicine_create_code');

INSERT INTO clinic_ai_scene_binding (scene_code, scene_name, execution_mode, primary_model_id, fallback_model_id, candidate_limit, timeout_ms, enabled, remark, create_by, create_time, update_by, update_time)
SELECT 'medicine_create_image', '药品建档-图片识别', 'model_only', pm.model_id, fm.model_id, 3, 15000, 1, '默认建档图片识别场景。', 'system', NOW(), 'system', NOW()
FROM (SELECT 1) seed
LEFT JOIN clinic_ai_model pm ON pm.model_code = 'gpt-5.4'
LEFT JOIN clinic_ai_model fm ON fm.model_code = 'minimax-M2.7'
WHERE NOT EXISTS (SELECT 1 FROM clinic_ai_scene_binding WHERE scene_code = 'medicine_create_image');

INSERT INTO clinic_ai_scene_binding (scene_code, scene_name, execution_mode, primary_model_id, fallback_model_id, candidate_limit, timeout_ms, enabled, remark, create_by, create_time, update_by, update_time)
SELECT 'medicine_stock_in_code', '药品入库-扫码识别', 'local_only', NULL, NULL, 3, 15000, 1, '默认入库扫码识别场景。', 'system', NOW(), 'system', NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM clinic_ai_scene_binding WHERE scene_code = 'medicine_stock_in_code');

INSERT INTO clinic_ai_scene_binding (scene_code, scene_name, execution_mode, primary_model_id, fallback_model_id, candidate_limit, timeout_ms, enabled, remark, create_by, create_time, update_by, update_time)
SELECT 'medicine_stock_out_code', '药品出库-扫码识别', 'local_only', NULL, NULL, 3, 15000, 1, '默认出库扫码识别场景。', 'system', NOW(), 'system', NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM clinic_ai_scene_binding WHERE scene_code = 'medicine_stock_out_code');

-- 2026-04-05 收口 AI 配置与 AI 助手菜单
INSERT INTO sys_menu (
  menu_id, menu_name, parent_id, order_num, url, target, menu_type, visible, is_refresh, perms, icon,
  create_by, create_time, update_by, update_time, remark
)
SELECT 2060, 'AI 配置', 2000, 7, '#', '', 'M', '0', '1', '', 'fa fa-sliders',
       'admin', NOW(), '', NULL, 'AI 配置入口'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_id = 2060);

UPDATE sys_menu
SET menu_name = 'AI 配置',
    parent_id = 2000,
    order_num = 7,
    url = '#',
    menu_type = 'M',
    perms = '',
    icon = 'fa fa-sliders',
    remark = 'AI 配置入口'
WHERE menu_id = 2060;

UPDATE sys_menu SET parent_id = 2060, order_num = 1, menu_name = '服务商配置', url = 'clinic/ai/provider' WHERE menu_id = 2061;
UPDATE sys_menu SET parent_id = 2060, order_num = 2, menu_name = '模型配置', url = 'clinic/ai/model' WHERE menu_id = 2062;
UPDATE sys_menu SET parent_id = 2060, order_num = 3, menu_name = '场景绑定', url = 'clinic/ai/scene' WHERE menu_id = 2063;

INSERT INTO sys_menu (
  menu_id, menu_name, parent_id, order_num, url, target, menu_type, visible, is_refresh, perms, icon,
  create_by, create_time, update_by, update_time, remark
)
SELECT 2079, 'AI 助手', 2000, 6, 'clinic/ai/assistant', '', 'C', '0', '1', 'clinic:ai:assistant:view', 'fa fa-robot',
       'admin', NOW(), '', NULL, 'AI 助手独立入口'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_id = 2079);

UPDATE sys_menu
SET menu_name = 'AI 助手',
    parent_id = 2000,
    order_num = 6,
    url = 'clinic/ai/assistant',
    menu_type = 'C',
    perms = 'clinic:ai:assistant:view',
    icon = 'fa fa-robot',
    remark = 'AI 助手独立入口'
WHERE menu_id = 2079;

INSERT IGNORE INTO sys_role_menu (role_id, menu_id) VALUES (1, 2060), (2, 2060), (1, 2079), (2, 2079);
