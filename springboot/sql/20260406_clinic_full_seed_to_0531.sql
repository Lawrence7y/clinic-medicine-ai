-- ============================================================
-- Clinic full seed data (supplemental)
-- Target date range for schedule/appointment: 2026-04-06 ~ 2026-05-31
-- Execute after: ry_20250416.sql + clinic_data_init.sql
-- ============================================================

USE WechatProject;
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

SET @seed_start_date = DATE('2026-04-06');
SET @seed_end_date = DATE('2026-05-31');

-- ------------------------------------------------------------
-- Backward-compatible column guards
-- ------------------------------------------------------------
SET @db_name = DATABASE();

SET @has_medicine_barcode = (
  SELECT COUNT(1) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @db_name AND TABLE_NAME = 'clinic_medicine' AND COLUMN_NAME = 'barcode'
);
SET @sql_medicine_barcode = IF(
  @has_medicine_barcode = 0,
  'ALTER TABLE clinic_medicine ADD COLUMN barcode VARCHAR(64) NULL COMMENT ''药品条码'' AFTER manufacturer',
  'SELECT 1'
);
PREPARE stmt_medicine_barcode FROM @sql_medicine_barcode;
EXECUTE stmt_medicine_barcode;
DEALLOCATE PREPARE stmt_medicine_barcode;

SET @has_medicine_location = (
  SELECT COUNT(1) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @db_name AND TABLE_NAME = 'clinic_medicine' AND COLUMN_NAME = 'location'
);
SET @sql_medicine_location = IF(
  @has_medicine_location = 0,
  'ALTER TABLE clinic_medicine ADD COLUMN location VARCHAR(100) NULL COMMENT ''存放位置'' AFTER category',
  'SELECT 1'
);
PREPARE stmt_medicine_location FROM @sql_medicine_location;
EXECUTE stmt_medicine_location;
DEALLOCATE PREPARE stmt_medicine_location;

SET @has_appt_called = (
  SELECT COUNT(1) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @db_name AND TABLE_NAME = 'clinic_appointment' AND COLUMN_NAME = 'called'
);
SET @sql_appt_called = IF(
  @has_appt_called = 0,
  'ALTER TABLE clinic_appointment ADD COLUMN called TINYINT(1) DEFAULT 0 COMMENT ''是否叫号'' AFTER is_offline',
  'SELECT 1'
);
PREPARE stmt_appt_called FROM @sql_appt_called;
EXECUTE stmt_appt_called;
DEALLOCATE PREPARE stmt_appt_called;

SET @has_appt_called_time = (
  SELECT COUNT(1) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @db_name AND TABLE_NAME = 'clinic_appointment' AND COLUMN_NAME = 'called_time'
);
SET @sql_appt_called_time = IF(
  @has_appt_called_time = 0,
  'ALTER TABLE clinic_appointment ADD COLUMN called_time DATETIME NULL COMMENT ''叫号时间'' AFTER called',
  'SELECT 1'
);
PREPARE stmt_appt_called_time FROM @sql_appt_called_time;
EXECUTE stmt_appt_called_time;
DEALLOCATE PREPARE stmt_appt_called_time;

SET @has_stock_patient_id = (
  SELECT COUNT(1) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @db_name AND TABLE_NAME = 'clinic_stock_record' AND COLUMN_NAME = 'patient_id'
);
SET @sql_stock_patient_id = IF(
  @has_stock_patient_id = 0,
  'ALTER TABLE clinic_stock_record ADD COLUMN patient_id BIGINT(20) NULL COMMENT ''患者档案ID'' AFTER patient_name',
  'SELECT 1'
);
PREPARE stmt_stock_patient_id FROM @sql_stock_patient_id;
EXECUTE stmt_stock_patient_id;
DEALLOCATE PREPARE stmt_stock_patient_id;

SET @has_stock_doctor_id = (
  SELECT COUNT(1) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @db_name AND TABLE_NAME = 'clinic_stock_record' AND COLUMN_NAME = 'doctor_id'
);
SET @sql_stock_doctor_id = IF(
  @has_stock_doctor_id = 0,
  'ALTER TABLE clinic_stock_record ADD COLUMN doctor_id BIGINT(20) NULL COMMENT ''医生用户ID'' AFTER doctor_name',
  'SELECT 1'
);
PREPARE stmt_stock_doctor_id FROM @sql_stock_doctor_id;
EXECUTE stmt_stock_doctor_id;
DEALLOCATE PREPARE stmt_stock_doctor_id;

SET @has_stock_related_record_id = (
  SELECT COUNT(1) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @db_name AND TABLE_NAME = 'clinic_stock_record' AND COLUMN_NAME = 'related_record_id'
);
SET @sql_stock_related_record_id = IF(
  @has_stock_related_record_id = 0,
  'ALTER TABLE clinic_stock_record ADD COLUMN related_record_id VARCHAR(50) NULL COMMENT ''关联记录ID'' AFTER doctor_id',
  'SELECT 1'
);
PREPARE stmt_stock_related_record_id FROM @sql_stock_related_record_id;
EXECUTE stmt_stock_related_record_id;
DEALLOCATE PREPARE stmt_stock_related_record_id;

SET @has_stock_related_record_type = (
  SELECT COUNT(1) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @db_name AND TABLE_NAME = 'clinic_stock_record' AND COLUMN_NAME = 'related_record_type'
);
SET @sql_stock_related_record_type = IF(
  @has_stock_related_record_type = 0,
  'ALTER TABLE clinic_stock_record ADD COLUMN related_record_type VARCHAR(50) NULL COMMENT ''关联记录类型'' AFTER related_record_id',
  'SELECT 1'
);
PREPARE stmt_stock_related_record_type FROM @sql_stock_related_record_type;
EXECUTE stmt_stock_related_record_type;
DEALLOCATE PREPARE stmt_stock_related_record_type;

SET @has_stock_is_pack = (
  SELECT COUNT(1) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @db_name AND TABLE_NAME = 'clinic_stock_record' AND COLUMN_NAME = 'is_pack_medicine'
);
SET @sql_stock_is_pack = IF(
  @has_stock_is_pack = 0,
  'ALTER TABLE clinic_stock_record ADD COLUMN is_pack_medicine TINYINT(1) DEFAULT 0 COMMENT ''是否包药'' AFTER related_record_type',
  'SELECT 1'
);
PREPARE stmt_stock_is_pack FROM @sql_stock_is_pack;
EXECUTE stmt_stock_is_pack;
DEALLOCATE PREPARE stmt_stock_is_pack;

SET @has_stock_pack_items = (
  SELECT COUNT(1) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @db_name AND TABLE_NAME = 'clinic_stock_record' AND COLUMN_NAME = 'pack_items'
);
SET @sql_stock_pack_items = IF(
  @has_stock_pack_items = 0,
  'ALTER TABLE clinic_stock_record ADD COLUMN pack_items TEXT NULL COMMENT ''包药明细JSON'' AFTER is_pack_medicine',
  'SELECT 1'
);
PREPARE stmt_stock_pack_items FROM @sql_stock_pack_items;
EXECUTE stmt_stock_pack_items;
DEALLOCATE PREPARE stmt_stock_pack_items;

-- ------------------------------------------------------------
-- Optional tables used by current code paths
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `clinic_prescription` (
  `prescription_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `patient_id` bigint(20) DEFAULT NULL,
  `patient_name` varchar(50) DEFAULT NULL,
  `medical_record_id` bigint(20) DEFAULT NULL,
  `doctor_id` bigint(20) DEFAULT NULL,
  `doctor_name` varchar(50) DEFAULT NULL,
  `prescription_date` datetime DEFAULT NULL,
  `diagnosis` text,
  `chief_complaint` text,
  `medical_history` text,
  `allergy_history` text,
  `category` varchar(50) DEFAULT NULL,
  `status` varchar(20) DEFAULT 'active',
  `total_amount` decimal(10,2) DEFAULT NULL,
  `medicines` text,
  `usage` text,
  `remark` text,
  `signature` varchar(255) DEFAULT NULL,
  `create_by` varchar(64) DEFAULT '',
  `create_time` datetime DEFAULT NULL,
  `update_by` varchar(64) DEFAULT '',
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`prescription_id`),
  KEY `idx_clinic_prescription_patient_id` (`patient_id`),
  KEY `idx_clinic_prescription_doctor_id` (`doctor_id`),
  KEY `idx_clinic_prescription_date` (`prescription_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Prescription';

CREATE TABLE IF NOT EXISTS `clinic_appointment_subscription` (
  `subscription_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `openid` varchar(64) DEFAULT NULL,
  `appointment_reminder` tinyint(1) DEFAULT 1,
  `remind_days_before` int(11) DEFAULT 1,
  `last_remind_time` datetime DEFAULT NULL,
  `subscribe_status` varchar(20) DEFAULT 'on',
  `template_id` varchar(128) DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`subscription_id`),
  UNIQUE KEY `uk_clinic_subscription_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Appointment subscription';

-- ------------------------------------------------------------
-- Config
-- ------------------------------------------------------------
INSERT INTO clinic_config (`config_key`, `config_value`, `description`, `create_time`, `update_time`) VALUES
('clinic.name', '康宁门诊', '诊所名称', NOW(), NOW()),
('clinic.phone', '021-66005566', '诊所联系电话', NOW(), NOW()),
('clinic.address', '上海市静安区中兴路 88 号', '诊所地址', NOW(), NOW()),
('clinic.patientCancelAdvanceMinutes', '120', '患者至少提前取消分钟数', NOW(), NOW()),
('clinic.maxSessionCount', '2', '账号最大在线会话数', NOW(), NOW()),
('clinic.kickoutAfterNewLogin', 'false', '新登录是否踢出旧会话', NOW(), NOW()),
('clinic.loginMaxFailCount', '5', '登录最大失败次数', NOW(), NOW()),
('clinic.loginLockMinutes', '5', '登录锁定分钟数', NOW(), NOW())
ON DUPLICATE KEY UPDATE
  `config_value` = VALUES(`config_value`),
  `description` = VALUES(`description`),
  `update_time` = NOW();

-- ------------------------------------------------------------
-- Patient (all attributes)
-- ------------------------------------------------------------
INSERT INTO clinic_patient (
  patient_id, user_id, name, gender, age, phone, birthday, address, allergy_history, past_history, blood_type, wechat,
  avatar, create_by, create_time, update_by, update_time, remark
) VALUES
(201, 201, '赵明', '男', 41, '13800138021', '1985-03-18', '上海市徐汇区桂林路 201 号', '青霉素过敏', '高血压 5 年', 'A', 'zhaoming_201', '/profile/avatar/201.png', 'seed', NOW(), 'seed', NOW(), '慢病复诊患者'),
(202, 202, '钱红', '女', 35, '13800138022', '1991-07-22', '上海市浦东新区锦绣路 88 号', '海鲜过敏', '慢性胃炎', 'B', 'qianhong_202', '/profile/avatar/202.png', 'seed', NOW(), 'seed', NOW(), '消化科随访'),
(203, 203, '孙伟', '男', 47, '13800138023', '1979-11-09', '上海市闵行区七莘路 300 号', '花粉过敏', '哮喘病史', 'O', 'sunwei_203', '/profile/avatar/203.png', 'seed', NOW(), 'seed', NOW(), '呼吸道敏感'),
(204, 204, '李静', '女', 30, '13800138024', '1996-05-12', '上海市杨浦区控江路 66 号', '无', '无', 'AB', 'lijing_204', '/profile/avatar/204.png', 'seed', NOW(), 'seed', NOW(), '体检后复诊'),
(205, 205, '周强', '男', 53, '13800138025', '1973-10-10', '上海市普陀区长寿路 520 号', '无', '2 型糖尿病', 'A', 'zhouqiang_205', '/profile/avatar/205.png', 'seed', NOW(), 'seed', NOW(), '儿科家属陪诊'),
(206, 206, '吴婷', '女', 29, '13800138026', '1997-02-26', '上海市宝山区友谊路 101 号', '头孢轻微不耐受', '偏头痛', 'O', 'wuting_206', '/profile/avatar/206.png', 'seed', NOW(), 'seed', NOW(), '神经内科咨询')
ON DUPLICATE KEY UPDATE
  user_id = VALUES(user_id),
  name = VALUES(name),
  gender = VALUES(gender),
  age = VALUES(age),
  phone = VALUES(phone),
  birthday = VALUES(birthday),
  address = VALUES(address),
  allergy_history = VALUES(allergy_history),
  past_history = VALUES(past_history),
  blood_type = VALUES(blood_type),
  wechat = VALUES(wechat),
  avatar = VALUES(avatar),
  update_by = VALUES(update_by),
  update_time = NOW(),
  remark = VALUES(remark);

-- ------------------------------------------------------------
-- Medicine (all attributes currently used by code)
-- ------------------------------------------------------------
INSERT INTO clinic_medicine (
  medicine_id, name, specification, dosage_form, form, manufacturer, barcode, expiry_date, price, stock, warning_stock,
  warning_threshold, min_stock, unit, pharmacology, indications, dosage, side_effects, storage, status, is_prescription,
  category, location, create_by, create_time, update_by, update_time, remark
) VALUES
(201, '阿莫西林胶囊', '0.25g*24粒', '胶囊', '口服制剂', '联邦制药', '6901234567801', '2027-12-31', 14.50, 520, 80, 80, 80, '盒', 'β-内酰胺类抗菌药', '上呼吸道感染、扁桃体炎', '一次 2 粒，每日 3 次', '胃肠道不适、皮疹', '阴凉干燥处密封保存', 'active', 1, '抗感染', 'A-01-01', 'seed', NOW(), 'seed', NOW(), '常用抗生素'),
(202, '布洛芬缓释胶囊', '0.3g*20粒', '胶囊', '口服制剂', '中美史克', '6901234567802', '2027-10-31', 22.00, 320, 60, 60, 60, '盒', '解热镇痛抗炎', '发热、头痛、肌肉痛', '发热时一次 1 粒，必要时 6-8 小时后可重复', '胃部不适', '避光保存', 'active', 0, '退热镇痛', 'A-01-02', 'seed', NOW(), 'seed', NOW(), '发热门诊高频药'),
(203, '奥美拉唑肠溶胶囊', '20mg*14粒', '胶囊', '口服制剂', '阿斯利康', '6901234567803', '2028-01-31', 36.00, 280, 40, 40, 40, '盒', '质子泵抑制剂', '胃炎、胃食管反流', '每日早餐前 1 粒', '头晕、腹泻', '常温干燥保存', 'active', 1, '消化系统', 'A-02-01', 'seed', NOW(), 'seed', NOW(), '慢病常备'),
(204, '复方甘草片', '100片', '片剂', '口服制剂', '国药集团', '6901234567804', '2027-09-30', 9.80, 460, 90, 90, 90, '瓶', '镇咳祛痰', '咳嗽、咽痛', '一次 2 片，每日 3 次', '嗜睡', '密封防潮', 'active', 0, '呼吸系统', 'A-03-01', 'seed', NOW(), 'seed', NOW(), '普通咳嗽药'),
(205, '维生素 C 片', '100mg*100片', '片剂', '口服制剂', '华润三九', '6901234567805', '2028-03-31', 16.00, 680, 120, 120, 120, '瓶', '维生素补充', '维生素 C 缺乏', '一次 1 片，每日 1-2 次', '胃酸增多', '阴凉处保存', 'active', 0, '营养补充', 'A-04-01', 'seed', NOW(), 'seed', NOW(), '保健类'),
(206, '医用碘伏消毒液', '500ml', '溶液', '外用制剂', '利康', '6901234567806', '2027-08-31', 18.50, 210, 40, 40, 40, '瓶', '外用消毒', '皮肤消毒', '局部外用', '局部刺激', '避光密封', 'active', 0, '消毒用品', 'B-01-01', 'seed', NOW(), 'seed', NOW(), '耗材型用品')
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  specification = VALUES(specification),
  dosage_form = VALUES(dosage_form),
  form = VALUES(form),
  manufacturer = VALUES(manufacturer),
  barcode = VALUES(barcode),
  expiry_date = VALUES(expiry_date),
  price = VALUES(price),
  stock = VALUES(stock),
  warning_stock = VALUES(warning_stock),
  warning_threshold = VALUES(warning_threshold),
  min_stock = VALUES(min_stock),
  unit = VALUES(unit),
  pharmacology = VALUES(pharmacology),
  indications = VALUES(indications),
  dosage = VALUES(dosage),
  side_effects = VALUES(side_effects),
  storage = VALUES(storage),
  status = VALUES(status),
  is_prescription = VALUES(is_prescription),
  category = VALUES(category),
  location = VALUES(location),
  update_by = VALUES(update_by),
  update_time = NOW(),
  remark = VALUES(remark);

-- ------------------------------------------------------------
-- Stock batch (all attributes)
-- ------------------------------------------------------------
INSERT INTO clinic_stock_batch (
  medicine_id, batch_number, expiry_date, remaining_quantity, create_time, update_time
) VALUES
(201, 'AMX-2026-01', '2027-12-31', 300, NOW(), NOW()),
(201, 'AMX-2026-02', '2028-02-28', 220, NOW(), NOW()),
(202, 'IBU-2026-01', '2027-10-31', 320, NOW(), NOW()),
(203, 'OME-2026-01', '2028-01-31', 280, NOW(), NOW()),
(204, 'GCS-2026-01', '2027-09-30', 460, NOW(), NOW()),
(205, 'VC-2026-01', '2028-03-31', 680, NOW(), NOW()),
(206, 'IOD-2026-01', '2027-08-31', 210, NOW(), NOW())
ON DUPLICATE KEY UPDATE
  remaining_quantity = VALUES(remaining_quantity),
  update_time = NOW();

-- ------------------------------------------------------------
-- Schedules to 2026-05-31 (all attributes)
-- ------------------------------------------------------------
DROP TEMPORARY TABLE IF EXISTS tmp_seed_seq;
CREATE TEMPORARY TABLE tmp_seed_seq (
  n INT NOT NULL PRIMARY KEY
);

INSERT INTO tmp_seed_seq (n)
SELECT ones.n + tens.n * 10
FROM (
  SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
  UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
) ones
CROSS JOIN (
  SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
  UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
) tens
WHERE ones.n + tens.n * 10 <= DATEDIFF(@seed_end_date, @seed_start_date);

INSERT INTO clinic_schedule (
  doctor_id, doctor_name, title, schedule_date, start_time, end_time, total_slots, booked_slots,
  status, create_by, create_time, update_by, update_time, remark
)
SELECT
  d.doctor_id,
  d.doctor_name,
  d.title,
  DATE_ADD(@seed_start_date, INTERVAL seq.n DAY) AS schedule_date,
  sft.start_time,
  sft.end_time,
  CASE WHEN WEEKDAY(DATE_ADD(@seed_start_date, INTERVAL seq.n DAY)) >= 5 THEN 8 ELSE sft.total_slots END AS total_slots,
  0 AS booked_slots,
  CASE
    WHEN DATE_ADD(@seed_start_date, INTERVAL seq.n DAY) < CURDATE() THEN 'inactive'
    ELSE 'active'
  END AS status,
  'seed',
  NOW(),
  'seed',
  NOW(),
  CONCAT('seed_', sft.shift_code, '_to_2026-05-31')
FROM tmp_seed_seq seq
JOIN (
  SELECT 101 AS doctor_id, '李医生' AS doctor_name, '内科主治医师' AS title
  UNION ALL SELECT 102, '王医生', '外科主治医师'
  UNION ALL SELECT 103, '张医生', '儿科主治医师'
) d
JOIN (
  SELECT 'AM' AS shift_code, '08:30' AS start_time, '12:00' AS end_time, 20 AS total_slots
  UNION ALL
  SELECT 'PM' AS shift_code, '14:00' AS start_time, '17:30' AS end_time, 16 AS total_slots
) sft
LEFT JOIN clinic_schedule exists_row
  ON exists_row.doctor_id = d.doctor_id
 AND exists_row.schedule_date = DATE_ADD(@seed_start_date, INTERVAL seq.n DAY)
 AND exists_row.start_time = sft.start_time
 AND exists_row.end_time = sft.end_time
WHERE exists_row.schedule_id IS NULL;

-- ------------------------------------------------------------
-- Appointments to 2026-05-31 (all attributes)
-- ------------------------------------------------------------
INSERT INTO clinic_appointment (
  patient_id, patient_name, patient_phone, doctor_id, doctor_name, schedule_id, appointment_date, appointment_time,
  sequence_number, status, is_offline, called, called_time, create_by, create_time, update_by, update_time, remark
)
SELECT
  p.patient_id,
  p.patient_name,
  p.patient_phone,
  s.doctor_id,
  s.doctor_name,
  s.schedule_id,
  s.schedule_date,
  CONCAT(
    s.start_time,
    '-',
    DATE_FORMAT(
      DATE_ADD(STR_TO_DATE(s.start_time, '%H:%i'), INTERVAL 15 MINUTE),
      '%H:%i'
    )
  ) AS appointment_time,
  1 AS sequence_number,
  CASE
    WHEN s.schedule_date < CURDATE() THEN 'completed'
    WHEN s.schedule_date = CURDATE() THEN 'confirmed'
    WHEN s.schedule_date <= DATE_ADD(CURDATE(), INTERVAL 3 DAY) THEN 'pending'
    ELSE 'confirmed'
  END AS status,
  CASE WHEN MOD(s.schedule_id, 4) = 0 THEN 1 ELSE 0 END AS is_offline,
  CASE
    WHEN s.schedule_date = CURDATE() AND MOD(s.schedule_id, 5) = 0 THEN 1
    ELSE 0
  END AS called,
  CASE
    WHEN s.schedule_date = CURDATE() AND MOD(s.schedule_id, 5) = 0 THEN NOW()
    ELSE NULL
  END AS called_time,
  'seed',
  NOW(),
  'seed',
  NOW(),
  'seed_generated_seq1'
FROM clinic_schedule s
JOIN (
  SELECT 0 AS idx, 201 AS patient_id, '赵明' AS patient_name, '13800138021' AS patient_phone
  UNION ALL SELECT 1, 202, '钱红', '13800138022'
  UNION ALL SELECT 2, 203, '孙伟', '13800138023'
  UNION ALL SELECT 3, 204, '李静', '13800138024'
  UNION ALL SELECT 4, 205, '周强', '13800138025'
  UNION ALL SELECT 5, 206, '吴婷', '13800138026'
) p
  ON p.idx = MOD(DATEDIFF(s.schedule_date, @seed_start_date) + s.doctor_id, 6)
LEFT JOIN clinic_appointment exists_row
  ON exists_row.schedule_id = s.schedule_id
 AND exists_row.sequence_number = 1
WHERE s.schedule_date BETWEEN @seed_start_date AND @seed_end_date
  AND exists_row.appointment_id IS NULL;

INSERT INTO clinic_appointment (
  patient_id, patient_name, patient_phone, doctor_id, doctor_name, schedule_id, appointment_date, appointment_time,
  sequence_number, status, is_offline, called, called_time, create_by, create_time, update_by, update_time, remark
)
SELECT
  p.patient_id,
  p.patient_name,
  p.patient_phone,
  s.doctor_id,
  s.doctor_name,
  s.schedule_id,
  s.schedule_date,
  CONCAT(
    DATE_FORMAT(
      DATE_ADD(STR_TO_DATE(s.start_time, '%H:%i'), INTERVAL 15 MINUTE),
      '%H:%i'
    ),
    '-',
    DATE_FORMAT(
      DATE_ADD(STR_TO_DATE(s.start_time, '%H:%i'), INTERVAL 30 MINUTE),
      '%H:%i'
    )
  ) AS appointment_time,
  2 AS sequence_number,
  CASE
    WHEN s.schedule_date < CURDATE() THEN 'cancelled'
    WHEN s.schedule_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY) THEN 'pending'
    ELSE 'confirmed'
  END AS status,
  0 AS is_offline,
  0 AS called,
  NULL AS called_time,
  'seed',
  NOW(),
  'seed',
  NOW(),
  'seed_generated_seq2'
FROM clinic_schedule s
JOIN (
  SELECT 0 AS idx, 206 AS patient_id, '吴婷' AS patient_name, '13800138026' AS patient_phone
  UNION ALL SELECT 1, 205, '周强', '13800138025'
  UNION ALL SELECT 2, 204, '李静', '13800138024'
  UNION ALL SELECT 3, 203, '孙伟', '13800138023'
  UNION ALL SELECT 4, 202, '钱红', '13800138022'
  UNION ALL SELECT 5, 201, '赵明', '13800138021'
) p
  ON p.idx = MOD(DATEDIFF(s.schedule_date, @seed_start_date) + s.doctor_id + 1, 6)
LEFT JOIN clinic_appointment exists_row
  ON exists_row.schedule_id = s.schedule_id
 AND exists_row.sequence_number = 2
WHERE s.schedule_date BETWEEN @seed_start_date AND @seed_end_date
  AND exists_row.appointment_id IS NULL;

-- Keep booked_slots synchronized with generated appointment volume.
UPDATE clinic_schedule s
LEFT JOIN (
  SELECT schedule_id, COUNT(*) AS cnt
  FROM clinic_appointment
  WHERE schedule_id IS NOT NULL
    AND status IN ('pending', 'confirmed', 'completed')
  GROUP BY schedule_id
) x ON x.schedule_id = s.schedule_id
SET s.booked_slots = LEAST(IFNULL(x.cnt, 0), s.total_slots),
    s.update_by = 'seed',
    s.update_time = NOW()
WHERE s.schedule_date BETWEEN @seed_start_date AND @seed_end_date;

-- ------------------------------------------------------------
-- Medical records (all attributes)
-- ------------------------------------------------------------
INSERT INTO clinic_medical_record (
  record_id, patient_id, patient_name, patient_gender, patient_age, patient_phone, patient_birthday, patient_blood_type,
  doctor_id, doctor_name, visit_time, chief_complaint, present_illness, past_history, allergy_history, physical_exam,
  diagnosis, treatment, prescription, attachments, follow_up, create_by, create_time, update_by, update_time, remark
) VALUES
(2001, 201, '赵明', '男', 41, '13800138021', '1985-03-18', 'A', 101, '李医生', '2026-04-12 09:10:00', '发热咽痛 2 天', '伴轻度头痛，无胸闷', '高血压', '青霉素过敏', '咽部充血，体温 37.9℃', '急性上呼吸道感染', '对症治疗 + 休息', '[{"medicineId":202,"name":"布洛芬缓释胶囊","qty":2}]', '[]', '3 天后复诊', 'seed', NOW(), 'seed', NOW(), '门诊首诊'),
(2002, 202, '钱红', '女', 35, '13800138022', '1991-07-22', 'B', 101, '李医生', '2026-04-18 14:25:00', '反酸、胃胀 1 周', '餐后明显，夜间偶发', '慢性胃炎', '海鲜过敏', '上腹轻压痛', '慢性胃炎活动期', '抑酸 + 饮食管理', '[{"medicineId":203,"name":"奥美拉唑肠溶胶囊","qty":14}]', '[]', '2 周后随访', 'seed', NOW(), 'seed', NOW(), '慢病管理'),
(2003, 203, '孙伟', '男', 47, '13800138023', '1979-11-09', 'O', 102, '王医生', '2026-04-23 10:05:00', '咳嗽伴咽痛', '晨起加重', '哮喘病史', '花粉过敏', '双肺呼吸音粗', '急性咽炎', '抗感染 + 雾化建议', '[{"medicineId":201,"name":"阿莫西林胶囊","qty":12}]', '[]', '必要时复诊', 'seed', NOW(), 'seed', NOW(), '呼吸道就诊'),
(2004, 204, '李静', '女', 30, '13800138024', '1996-05-12', 'AB', 103, '张医生', '2026-05-02 09:40:00', '偏头痛反复', '遇压加重，伴畏光', '无', '无', '神经系统查体未见明显异常', '偏头痛', '规律作息 + 对症止痛', '[{"medicineId":202,"name":"布洛芬缓释胶囊","qty":6}]', '[]', '1 月后复评', 'seed', NOW(), 'seed', NOW(), '神经内科咨询'),
(2005, 205, '周强', '男', 53, '13800138025', '1973-10-10', 'A', 103, '张医生', '2026-05-15 15:20:00', '咳嗽 3 天', '夜间加重', '2 型糖尿病', '无', '咽部轻红', '急性支气管炎', '止咳化痰 + 血糖监测', '[{"medicineId":204,"name":"复方甘草片","qty":1}]', '[]', '1 周后复诊', 'seed', NOW(), 'seed', NOW(), '家属陪诊'),
(2006, 206, '吴婷', '女', 29, '13800138026', '1997-02-26', 'O', 102, '王医生', '2026-05-28 08:55:00', '皮肤小擦伤', '已自行冲洗', '偏头痛', '头孢轻微不耐受', '局部红肿轻微', '浅表皮肤擦伤', '外用消毒，避免沾水', '[{"medicineId":206,"name":"医用碘伏消毒液","qty":1}]', '[]', '48 小时复查', 'seed', NOW(), 'seed', NOW(), '换药处理')
ON DUPLICATE KEY UPDATE
  patient_id = VALUES(patient_id),
  patient_name = VALUES(patient_name),
  patient_gender = VALUES(patient_gender),
  patient_age = VALUES(patient_age),
  patient_phone = VALUES(patient_phone),
  patient_birthday = VALUES(patient_birthday),
  patient_blood_type = VALUES(patient_blood_type),
  doctor_id = VALUES(doctor_id),
  doctor_name = VALUES(doctor_name),
  visit_time = VALUES(visit_time),
  chief_complaint = VALUES(chief_complaint),
  present_illness = VALUES(present_illness),
  past_history = VALUES(past_history),
  allergy_history = VALUES(allergy_history),
  physical_exam = VALUES(physical_exam),
  diagnosis = VALUES(diagnosis),
  treatment = VALUES(treatment),
  prescription = VALUES(prescription),
  attachments = VALUES(attachments),
  follow_up = VALUES(follow_up),
  update_by = VALUES(update_by),
  update_time = NOW(),
  remark = VALUES(remark);

-- ------------------------------------------------------------
-- Prescription (all attributes)
-- ------------------------------------------------------------
INSERT INTO clinic_prescription (
  prescription_id, patient_id, patient_name, medical_record_id, doctor_id, doctor_name, prescription_date, diagnosis,
  chief_complaint, medical_history, allergy_history, category, status, total_amount, medicines, `usage`, remark, signature,
  create_by, create_time, update_by, update_time
) VALUES
(3001, 201, '赵明', 2001, 101, '李医生', '2026-04-12 09:15:00', '急性上呼吸道感染', '发热咽痛', '高血压', '青霉素过敏', '西药', 'dispensed', 44.00, '[{"medicineId":202,"name":"布洛芬缓释胶囊","quantity":2}]', '按医嘱服用', '已发药', 'Dr.Li', 'seed', NOW(), 'seed', NOW()),
(3002, 202, '钱红', 2002, 101, '李医生', '2026-04-18 14:30:00', '慢性胃炎活动期', '反酸胃胀', '慢性胃炎', '海鲜过敏', '西药', 'active', 36.00, '[{"medicineId":203,"name":"奥美拉唑肠溶胶囊","quantity":1}]', '早饭前服用', '待复查', 'Dr.Li', 'seed', NOW(), 'seed', NOW()),
(3003, 203, '孙伟', 2003, 102, '王医生', '2026-04-23 10:10:00', '急性咽炎', '咳嗽咽痛', '哮喘病史', '花粉过敏', '西药', 'active', 29.00, '[{"medicineId":201,"name":"阿莫西林胶囊","quantity":1}]', '饭后服用', '注意过敏反应', 'Dr.Wang', 'seed', NOW(), 'seed', NOW()),
(3004, 204, '李静', 2004, 103, '张医生', '2026-05-02 09:45:00', '偏头痛', '反复头痛', '无', '无', '西药', 'cancelled', 22.00, '[{"medicineId":202,"name":"布洛芬缓释胶囊","quantity":1}]', '头痛时服用', '患者暂缓取药', 'Dr.Zhang', 'seed', NOW(), 'seed', NOW())
ON DUPLICATE KEY UPDATE
  patient_id = VALUES(patient_id),
  patient_name = VALUES(patient_name),
  medical_record_id = VALUES(medical_record_id),
  doctor_id = VALUES(doctor_id),
  doctor_name = VALUES(doctor_name),
  prescription_date = VALUES(prescription_date),
  diagnosis = VALUES(diagnosis),
  chief_complaint = VALUES(chief_complaint),
  medical_history = VALUES(medical_history),
  allergy_history = VALUES(allergy_history),
  category = VALUES(category),
  status = VALUES(status),
  total_amount = VALUES(total_amount),
  medicines = VALUES(medicines),
  `usage` = VALUES(`usage`),
  remark = VALUES(remark),
  signature = VALUES(signature),
  update_by = VALUES(update_by),
  update_time = NOW();

-- ------------------------------------------------------------
-- Stock records (all attributes)
-- ------------------------------------------------------------
INSERT INTO clinic_stock_record (
  record_id, medicine_id, medicine_name, operation_type, quantity, before_stock, after_stock, supplier, purchase_price,
  batch_number, expiry_date, operator_id, operator_name, patient_id, patient_name, doctor_id, doctor_name,
  related_record_id, related_record_type, is_pack_medicine, pack_items, remark, create_time
) VALUES
(4001, 201, '阿莫西林胶囊', 'in', 200, 320, 520, '国药控股', 12.00, 'AMX-2026-02', '2028-02-28', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '补货入库', '2026-04-08 10:00:00'),
(4002, 202, '布洛芬缓释胶囊', 'in', 120, 200, 320, '华东医药', 18.00, 'IBU-2026-01', '2027-10-31', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '发热门诊补货', '2026-04-08 10:20:00'),
(4003, 203, '奥美拉唑肠溶胶囊', 'out', 14, 294, 280, NULL, NULL, 'OME-2026-01', '2028-01-31', 101, '李医生', 202, '钱红', 101, '李医生', '3002', 'prescription', 0, NULL, '处方发药', '2026-04-18 14:35:00'),
(4004, 201, '阿莫西林胶囊', 'out', 12, 532, 520, NULL, NULL, 'AMX-2026-02', '2028-02-28', 102, '王医生', 203, '孙伟', 102, '王医生', '3003', 'prescription', 0, NULL, '处方发药', '2026-04-23 10:15:00'),
(4005, 206, '医用碘伏消毒液', 'out', 1, 211, 210, NULL, NULL, 'IOD-2026-01', '2027-08-31', 102, '王医生', 206, '吴婷', 102, '王医生', '2006', 'medical_record', 0, NULL, '门诊换药', '2026-05-28 09:00:00'),
(4006, 205, '维生素 C 片', 'check', 0, 680, 680, NULL, NULL, 'VC-2026-01', '2028-03-31', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '月度盘点正常', '2026-05-31 18:00:00'),
(4007, 204, '复方甘草片', 'out', 2, 462, 460, NULL, NULL, 'GCS-2026-01', '2027-09-30', 103, '张医生', 205, '周强', 103, '张医生', '2005', 'medical_record', 1, '[{"medicineId":204,"name":"复方甘草片","quantity":2}]', '包药发放', '2026-05-15 15:30:00')
ON DUPLICATE KEY UPDATE
  medicine_id = VALUES(medicine_id),
  medicine_name = VALUES(medicine_name),
  operation_type = VALUES(operation_type),
  quantity = VALUES(quantity),
  before_stock = VALUES(before_stock),
  after_stock = VALUES(after_stock),
  supplier = VALUES(supplier),
  purchase_price = VALUES(purchase_price),
  batch_number = VALUES(batch_number),
  expiry_date = VALUES(expiry_date),
  operator_id = VALUES(operator_id),
  operator_name = VALUES(operator_name),
  patient_id = VALUES(patient_id),
  patient_name = VALUES(patient_name),
  doctor_id = VALUES(doctor_id),
  doctor_name = VALUES(doctor_name),
  related_record_id = VALUES(related_record_id),
  related_record_type = VALUES(related_record_type),
  is_pack_medicine = VALUES(is_pack_medicine),
  pack_items = VALUES(pack_items),
  remark = VALUES(remark),
  create_time = VALUES(create_time);

-- ------------------------------------------------------------
-- Usage records (all attributes)
-- ------------------------------------------------------------
INSERT INTO clinic_usage_record (
  usage_id, medicine_id, medicine_name, specification, quantity, patient_id, patient_name, medical_record_id,
  doctor_id, doctor_name, issue_time, issuer_id, issuer_name, create_time
) VALUES
(5001, 202, '布洛芬缓释胶囊', '0.3g*20粒', 2, 201, '赵明', '2001', 101, '李医生', '2026-04-12 09:20:00', 100, '诊所管理员', NOW()),
(5002, 203, '奥美拉唑肠溶胶囊', '20mg*14粒', 14, 202, '钱红', '2002', 101, '李医生', '2026-04-18 14:35:00', 100, '诊所管理员', NOW()),
(5003, 201, '阿莫西林胶囊', '0.25g*24粒', 12, 203, '孙伟', '2003', 102, '王医生', '2026-04-23 10:15:00', 100, '诊所管理员', NOW()),
(5004, 206, '医用碘伏消毒液', '500ml', 1, 206, '吴婷', '2006', 102, '王医生', '2026-05-28 09:00:00', 102, '王医生', NOW())
ON DUPLICATE KEY UPDATE
  medicine_id = VALUES(medicine_id),
  medicine_name = VALUES(medicine_name),
  specification = VALUES(specification),
  quantity = VALUES(quantity),
  patient_id = VALUES(patient_id),
  patient_name = VALUES(patient_name),
  medical_record_id = VALUES(medical_record_id),
  doctor_id = VALUES(doctor_id),
  doctor_name = VALUES(doctor_name),
  issue_time = VALUES(issue_time),
  issuer_id = VALUES(issuer_id),
  issuer_name = VALUES(issuer_name),
  create_time = VALUES(create_time);

-- ------------------------------------------------------------
-- Pack loss records (all attributes)
-- ------------------------------------------------------------
INSERT INTO clinic_pack_loss_record (
  id, medicine_id, medicine_name, loss_quantity, related_record_id, batch_number, is_processed, create_time, operator_name
) VALUES
(6001, 204, '复方甘草片', 2, '4007', 'GCS-2026-01', 1, '2026-05-15 16:00:00', '张医生'),
(6002, 206, '医用碘伏消毒液', 1, '4005', 'IOD-2026-01', 0, '2026-05-28 10:00:00', '王医生')
ON DUPLICATE KEY UPDATE
  medicine_id = VALUES(medicine_id),
  medicine_name = VALUES(medicine_name),
  loss_quantity = VALUES(loss_quantity),
  related_record_id = VALUES(related_record_id),
  batch_number = VALUES(batch_number),
  is_processed = VALUES(is_processed),
  create_time = VALUES(create_time),
  operator_name = VALUES(operator_name);

-- ------------------------------------------------------------
-- Appointment subscriptions (all attributes)
-- ------------------------------------------------------------
INSERT INTO clinic_appointment_subscription (
  user_id, openid, appointment_reminder, remind_days_before, last_remind_time, subscribe_status, template_id, create_time, update_time
) VALUES
(201, 'openid_seed_201', 1, 1, '2026-05-20 09:00:00', 'on', 'tmpl_appt_reminder', NOW(), NOW()),
(202, 'openid_seed_202', 1, 2, '2026-05-21 09:00:00', 'on', 'tmpl_appt_reminder', NOW(), NOW()),
(203, 'openid_seed_203', 0, 1, NULL, 'off', 'tmpl_appt_reminder', NOW(), NOW()),
(204, 'openid_seed_204', 1, 1, '2026-05-22 09:00:00', 'on', 'tmpl_appt_reminder', NOW(), NOW()),
(205, 'openid_seed_205', 1, 3, '2026-05-23 09:00:00', 'on', 'tmpl_appt_reminder', NOW(), NOW()),
(206, 'openid_seed_206', 1, 1, NULL, 'on', 'tmpl_appt_reminder', NOW(), NOW())
ON DUPLICATE KEY UPDATE
  openid = VALUES(openid),
  appointment_reminder = VALUES(appointment_reminder),
  remind_days_before = VALUES(remind_days_before),
  last_remind_time = VALUES(last_remind_time),
  subscribe_status = VALUES(subscribe_status),
  template_id = VALUES(template_id),
  update_time = NOW();

DROP TEMPORARY TABLE IF EXISTS tmp_seed_seq;
SET FOREIGN_KEY_CHECKS = 1;

SELECT 'clinic full seed completed to 2026-05-31' AS message;
