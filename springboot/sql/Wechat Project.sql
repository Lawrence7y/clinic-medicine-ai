/*
 Navicat Premium Data Transfer

 Source Server         : ruoyi
 Source Server Type    : MySQL
 Source Server Version : 80035
 Source Host           : localhost:3306
 Source Schema         : ry

 Target Server Type    : MySQL
 Target Server Version : 80035
 File Encoding         : 65001

 Date: 03/04/2026 11:42:55
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for clinic_appointment
-- ----------------------------
DROP TABLE IF EXISTS `clinic_appointment`;
CREATE TABLE `clinic_appointment`  (
  `appointment_id` bigint NOT NULL AUTO_INCREMENT COMMENT '预约ID',
  `patient_id` bigint NOT NULL COMMENT '患者ID',
  `patient_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '患者姓名',
  `patient_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '患者电话',
  `doctor_id` bigint NOT NULL COMMENT '医生ID',
  `doctor_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '医生姓名',
  `schedule_id` bigint NULL DEFAULT NULL COMMENT '排班ID',
  `appointment_date` date NULL DEFAULT NULL COMMENT '预约日期',
  `appointment_time` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '预约时间段',
  `sequence_number` int NULL DEFAULT NULL COMMENT '序号',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'pending' COMMENT '状态：pending, confirmed, completed, cancelled',
  `is_offline` tinyint(1) NULL DEFAULT 0 COMMENT '是否线下',
  `called` tinyint(1) NULL DEFAULT 0 COMMENT '是否被叫号',
  `called_time` datetime NULL DEFAULT NULL COMMENT '叫号时间',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`appointment_id`) USING BTREE,
  INDEX `idx_patient_id`(`patient_id`) USING BTREE,
  INDEX `idx_doctor_id`(`doctor_id`) USING BTREE,
  INDEX `idx_appointment_date`(`appointment_date`) USING BTREE,
  INDEX `idx_status`(`status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 227 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '预约记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of clinic_appointment
-- ----------------------------
INSERT INTO `clinic_appointment` VALUES (100, 100, '赵明', '13800138005', 101, '李医生', 100, '2026-04-01', '08:30-08:45', 1, 'confirmed', 0, 1, '2026-04-03 00:45:17', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '线上预约');
INSERT INTO `clinic_appointment` VALUES (101, 101, '钱红', '13800138006', 101, '李医生', 100, '2026-04-01', '08:45-09:00', 2, 'completed', 1, 0, NULL, 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '线下已就诊');
INSERT INTO `clinic_appointment` VALUES (102, 102, '孙伟', '13800138007', 102, '王医生', 103, '2026-04-01', '09:00-09:15', 1, 'pending', 0, 0, NULL, 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '待确认');
INSERT INTO `clinic_appointment` VALUES (103, 103, '李静', '13800138008', 102, '王医生', 103, '2026-04-01', '09:15-09:30', 2, 'cancelled', 0, 0, NULL, 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '用户取消');
INSERT INTO `clinic_appointment` VALUES (104, 104, '周强', '13800138009', 103, '张医生', 105, '2026-04-01', '09:30-09:45', 1, 'completed', 1, 0, NULL, 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '儿科家属陪诊');
INSERT INTO `clinic_appointment` VALUES (105, 105, '吴婷', '13800138010', 101, '李医生', 101, '2026-04-01', '14:00-14:15', 1, 'confirmed', 0, 0, NULL, 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '复诊预约');
INSERT INTO `clinic_appointment` VALUES (106, 200, '赵明', '13800138005', 101, '李医生', 100, '2026-03-31', '08:30-08:45', 1, 'completed', 0, 0, NULL, 'admin', '2026-03-28 10:00:00', 'admin', '2026-03-31 09:00:00', '初诊');
INSERT INTO `clinic_appointment` VALUES (107, 201, '钱红', '13800138006', 101, '李医生', 100, '2026-03-31', '08:45-09:00', 2, 'completed', 1, 0, NULL, 'admin', '2026-03-28 11:00:00', 'admin', '2026-03-31 10:00:00', '线下就诊');
INSERT INTO `clinic_appointment` VALUES (108, 202, '孙伟', '13800138007', 102, '王医生', 101, '2026-03-31', '14:30-14:45', 3, 'cancelled', 0, 0, NULL, 'admin', '2026-03-28 14:00:00', 'admin', '2026-03-30 08:00:00', '用户取消');
INSERT INTO `clinic_appointment` VALUES (109, 200, '赵明', '13800138005', 101, '李医生', 102, '2026-04-01', '09:00-09:15', 1, 'completed', 0, 0, NULL, 'admin', '2026-03-29 10:00:00', 'admin', '2026-04-01 09:30:00', '复诊');
INSERT INTO `clinic_appointment` VALUES (110, 203, '李静', '13800138008', 103, '张医生', 103, '2026-04-01', '14:00-14:15', 1, 'completed', 0, 0, NULL, 'admin', '2026-03-29 15:00:00', 'admin', '2026-04-01 14:30:00', '感冒复诊');
INSERT INTO `clinic_appointment` VALUES (111, 204, '周强', '13800138009', 103, '张医生', 103, '2026-04-01', '14:15-14:30', 2, 'completed', 1, 0, NULL, 'admin', '2026-03-30 08:00:00', 'admin', '2026-04-01 15:00:00', '高血压复诊');
INSERT INTO `clinic_appointment` VALUES (112, 205, '吴婷', '13800138010', 103, '张医生', 103, '2026-04-01', '14:30-14:45', 3, 'completed', 0, 0, NULL, 'admin', '2026-03-30 09:00:00', 'admin', '2026-04-01 16:00:00', '甲状腺复查');
INSERT INTO `clinic_appointment` VALUES (113, 206, '郑峰', '13800138011', 102, '王医生', 104, '2026-04-02', '08:30-08:45', 1, 'completed', 0, 0, NULL, 'admin', '2026-03-30 10:00:00', 'admin', '2026-04-02 09:00:00', '外伤');
INSERT INTO `clinic_appointment` VALUES (114, 207, '王芳', '13800138012', 101, '李医生', 105, '2026-04-02', '14:00-14:15', 1, 'completed', 0, 0, NULL, 'admin', '2026-03-30 11:00:00', 'admin', '2026-04-02 14:30:00', '头痛复诊');
INSERT INTO `clinic_appointment` VALUES (115, 208, '何磊', '13800138013', 102, '王医生', 104, '2026-04-02', '08:45-09:00', 2, 'completed', 0, 0, NULL, 'admin', '2026-03-30 14:00:00', 'admin', '2026-04-02 10:00:00', '鼻炎复诊');
INSERT INTO `clinic_appointment` VALUES (116, 209, '郭敏', '13800138014', 103, '张医生', 106, '2026-04-03', '08:30-08:45', 1, 'completed', 0, 0, NULL, 'admin', '2026-03-31 09:00:00', 'admin', '2026-04-03 09:00:00', '体检');
INSERT INTO `clinic_appointment` VALUES (117, 210, '陈旭', '13800138015', 102, '王医生', 107, '2026-04-03', '14:00-14:15', 1, 'completed', 1, 0, NULL, 'admin', '2026-03-31 10:00:00', 'admin', '2026-04-03 14:30:00', '腰肌劳损');
INSERT INTO `clinic_appointment` VALUES (118, 211, '宋雨', '13800138016', 103, '张医生', 106, '2026-04-03', '08:45-09:00', 2, 'cancelled', 0, 0, NULL, 'admin', '2026-03-31 11:00:00', 'admin', '2026-04-02 08:00:00', '时间冲突取消');
INSERT INTO `clinic_appointment` VALUES (119, 200, '赵明', '13800138005', 101, '李医生', 108, '2026-04-04', '09:30-09:45', 1, 'completed', 0, 0, NULL, 'admin', '2026-04-01 10:00:00', 'admin', '2026-04-04 10:00:00', '高血压复查');
INSERT INTO `clinic_appointment` VALUES (120, 201, '钱红', '13800138006', 101, '李医生', 108, '2026-04-04', '09:45-10:00', 2, 'completed', 0, 0, NULL, 'admin', '2026-04-01 11:00:00', 'admin', '2026-04-04 10:30:00', '胃炎复诊');
INSERT INTO `clinic_appointment` VALUES (121, 203, '李静', '13800138008', 103, '张医生', 109, '2026-04-05', '09:00-09:15', 1, 'completed', 0, 0, NULL, 'admin', '2026-04-02 09:00:00', 'admin', '2026-04-05 09:30:00', '消化不良');
INSERT INTO `clinic_appointment` VALUES (122, 204, '周强', '13800138009', 103, '张医生', 109, '2026-04-05', '09:15-09:30', 2, 'completed', 0, 0, NULL, 'admin', '2026-04-02 10:00:00', 'admin', '2026-04-05 10:00:00', '糖尿病复诊');
INSERT INTO `clinic_appointment` VALUES (123, 205, '吴婷', '13800138010', 101, '李医生', 110, '2026-04-06', '08:30-08:45', 1, 'completed', 0, 0, NULL, 'admin', '2026-04-03 09:00:00', 'admin', '2026-04-06 09:00:00', '甲状腺复查');
INSERT INTO `clinic_appointment` VALUES (124, 206, '郑峰', '13800138011', 102, '王医生', 111, '2026-04-06', '14:30-14:45', 3, 'completed', 0, 0, NULL, 'admin', '2026-04-03 10:00:00', 'admin', '2026-04-06 15:00:00', '手指划伤');
INSERT INTO `clinic_appointment` VALUES (125, 207, '王芳', '13800138012', 101, '李医生', 110, '2026-04-06', '08:45-09:00', 2, 'completed', 1, 0, NULL, 'admin', '2026-04-03 11:00:00', 'admin', '2026-04-06 09:30:00', '偏头痛复诊');
INSERT INTO `clinic_appointment` VALUES (126, 208, '何磊', '13800138013', 103, '张医生', 112, '2026-04-07', '08:30-08:45', 1, 'completed', 0, 0, NULL, 'admin', '2026-04-04 09:00:00', 'admin', '2026-04-07 09:00:00', '过敏性鼻炎');
INSERT INTO `clinic_appointment` VALUES (127, 209, '郭敏', '13800138014', 101, '李医生', 113, '2026-04-07', '14:00-14:15', 1, 'completed', 0, 0, NULL, 'admin', '2026-04-04 10:00:00', 'admin', '2026-04-07 14:30:00', '感冒');
INSERT INTO `clinic_appointment` VALUES (128, 210, '陈旭', '13800138015', 103, '张医生', 112, '2026-04-07', '08:45-09:00', 2, 'completed', 0, 0, NULL, 'admin', '2026-04-04 11:00:00', 'admin', '2026-04-07 09:30:00', '腰肌劳损复诊');
INSERT INTO `clinic_appointment` VALUES (129, 211, '宋雨', '13800138016', 102, '王医生', 114, '2026-04-08', '08:30-08:45', 1, 'completed', 0, 0, NULL, 'admin', '2026-04-05 09:00:00', 'admin', '2026-04-08 09:00:00', '皮肤过敏');
INSERT INTO `clinic_appointment` VALUES (130, 200, '赵明', '13800138005', 103, '张医生', 115, '2026-04-08', '14:30-14:45', 3, 'completed', 0, 0, NULL, 'admin', '2026-04-05 10:00:00', 'admin', '2026-04-08 15:00:00', '高血压复诊');
INSERT INTO `clinic_appointment` VALUES (131, 201, '钱红', '13800138006', 102, '王医生', 114, '2026-04-08', '08:45-09:00', 2, 'completed', 0, 0, NULL, 'admin', '2026-04-05 11:00:00', 'admin', '2026-04-08 09:30:00', '胃部不适');
INSERT INTO `clinic_appointment` VALUES (132, 202, '孙伟', '13800138007', 101, '李医生', 116, '2026-04-09', '08:30-08:45', 1, 'completed', 0, 0, NULL, 'admin', '2026-04-06 09:00:00', 'admin', '2026-04-09 09:00:00', '哮喘复诊');
INSERT INTO `clinic_appointment` VALUES (133, 203, '李静', '13800138008', 102, '王医生', 117, '2026-04-09', '14:00-14:15', 1, 'completed', 1, 0, NULL, 'admin', '2026-04-06 10:00:00', 'admin', '2026-04-09 14:30:00', '胃炎复查');
INSERT INTO `clinic_appointment` VALUES (134, 204, '周强', '13800138009', 101, '李医生', 116, '2026-04-09', '08:45-09:00', 2, 'cancelled', 0, 0, NULL, 'admin', '2026-04-06 11:00:00', 'admin', '2026-04-08 08:00:00', '时间冲突取消');
INSERT INTO `clinic_appointment` VALUES (135, 205, '吴婷', '13800138010', 103, '张医生', 118, '2026-04-10', '08:30-08:45', 1, 'completed', 0, 0, NULL, 'admin', '2026-04-07 09:00:00', 'admin', '2026-04-10 09:00:00', '甲状腺复查');
INSERT INTO `clinic_appointment` VALUES (136, 206, '郑峰', '13800138011', 103, '张医生', 118, '2026-04-10', '08:45-09:00', 2, 'completed', 0, 0, NULL, 'admin', '2026-04-07 10:00:00', 'admin', '2026-04-10 09:30:00', '摔伤');
INSERT INTO `clinic_appointment` VALUES (137, 207, '王芳', '13800138012', 103, '张医生', 118, '2026-04-10', '09:00-09:15', 3, 'completed', 0, 0, NULL, 'admin', '2026-04-07 11:00:00', 'admin', '2026-04-10 10:00:00', '头痛');
INSERT INTO `clinic_appointment` VALUES (138, 208, '何磊', '13800138013', 102, '王医生', 119, '2026-04-11', '09:00-09:15', 1, 'completed', 0, 0, NULL, 'admin', '2026-04-08 09:00:00', 'admin', '2026-04-11 09:30:00', '鼻炎复诊');
INSERT INTO `clinic_appointment` VALUES (139, 209, '郭敏', '13800138014', 102, '王医生', 119, '2026-04-11', '09:15-09:30', 2, 'cancelled', 0, 0, NULL, 'admin', '2026-04-08 10:00:00', 'admin', '2026-04-10 08:00:00', '改为线下就诊');
INSERT INTO `clinic_appointment` VALUES (140, 210, '陈旭', '13800138015', 101, '李医生', 120, '2026-04-12', '09:00-09:15', 1, 'completed', 0, 0, NULL, 'admin', '2026-04-09 09:00:00', 'admin', '2026-04-12 09:30:00', '腰肌劳损');
INSERT INTO `clinic_appointment` VALUES (141, 211, '宋雨', '13800138016', 101, '李医生', 120, '2026-04-12', '09:15-09:30', 2, 'completed', 0, 0, NULL, 'admin', '2026-04-09 10:00:00', 'admin', '2026-04-12 10:00:00', '感冒');
INSERT INTO `clinic_appointment` VALUES (142, 200, '赵明', '13800138005', 103, '张医生', 121, '2026-04-13', '08:30-08:45', 1, 'completed', 0, 0, NULL, 'admin', '2026-04-10 09:00:00', 'admin', '2026-04-13 09:00:00', '高血压复查');
INSERT INTO `clinic_appointment` VALUES (143, 201, '钱红', '13800138006', 102, '王医生', 122, '2026-04-13', '14:30-14:45', 3, 'completed', 0, 0, NULL, 'admin', '2026-04-10 10:00:00', 'admin', '2026-04-13 15:00:00', '胃炎复诊');
INSERT INTO `clinic_appointment` VALUES (144, 202, '孙伟', '13800138007', 103, '张医生', 121, '2026-04-13', '08:45-09:00', 2, 'completed', 0, 0, NULL, 'admin', '2026-04-10 11:00:00', 'admin', '2026-04-13 09:30:00', '咽炎');
INSERT INTO `clinic_appointment` VALUES (145, 203, '李静', '13800138008', 101, '李医生', 123, '2026-04-14', '08:30-08:45', 1, 'completed', 0, 0, NULL, 'admin', '2026-04-11 09:00:00', 'admin', '2026-04-14 09:00:00', '消化不良');
INSERT INTO `clinic_appointment` VALUES (146, 204, '周强', '13800138009', 103, '张医生', 124, '2026-04-14', '14:30-14:45', 3, 'completed', 1, 0, NULL, 'admin', '2026-04-11 10:00:00', 'admin', '2026-04-14 15:00:00', '糖尿病复查');
INSERT INTO `clinic_appointment` VALUES (147, 205, '吴婷', '13800138010', 101, '李医生', 123, '2026-04-14', '08:45-09:00', 2, 'completed', 0, 0, NULL, 'admin', '2026-04-11 11:00:00', 'admin', '2026-04-14 09:30:00', '头痛');
INSERT INTO `clinic_appointment` VALUES (148, 206, '郑峰', '13800138011', 102, '王医生', 125, '2026-04-15', '08:30-08:45', 1, 'completed', 0, 0, NULL, 'admin', '2026-04-12 09:00:00', 'admin', '2026-04-15 09:00:00', '手指划伤');
INSERT INTO `clinic_appointment` VALUES (149, 207, '王芳', '13800138012', 101, '李医生', 126, '2026-04-15', '14:00-14:15', 1, 'completed', 0, 0, NULL, 'admin', '2026-04-12 10:00:00', 'admin', '2026-04-15 14:30:00', '偏头痛复诊');
INSERT INTO `clinic_appointment` VALUES (150, 208, '何磊', '13800138013', 102, '王医生', 125, '2026-04-15', '08:45-09:00', 2, 'completed', 0, 0, NULL, 'admin', '2026-04-12 11:00:00', 'admin', '2026-04-15 09:30:00', '过敏复诊');
INSERT INTO `clinic_appointment` VALUES (151, 209, '郭敏', '13800138014', 103, '张医生', 127, '2026-04-16', '08:30-08:45', 1, 'completed', 0, 0, NULL, 'admin', '2026-04-13 09:00:00', 'admin', '2026-04-16 09:00:00', '感冒');
INSERT INTO `clinic_appointment` VALUES (152, 210, '陈旭', '13800138015', 102, '王医生', 128, '2026-04-16', '14:00-14:15', 1, 'completed', 0, 0, NULL, 'admin', '2026-04-13 10:00:00', 'admin', '2026-04-16 14:30:00', '腰伤');
INSERT INTO `clinic_appointment` VALUES (153, 211, '宋雨', '13800138016', 103, '张医生', 127, '2026-04-16', '08:45-09:00', 2, 'completed', 1, 0, NULL, 'admin', '2026-04-13 11:00:00', 'admin', '2026-04-16 09:30:00', '过敏');
INSERT INTO `clinic_appointment` VALUES (154, 200, '赵明', '13800138005', 101, '李医生', 129, '2026-04-17', '08:30-08:45', 1, 'completed', 0, 0, NULL, 'admin', '2026-04-14 09:00:00', 'admin', '2026-04-17 09:00:00', '高血压');
INSERT INTO `clinic_appointment` VALUES (155, 201, '钱红', '13800138006', 103, '张医生', 130, '2026-04-17', '14:30-14:45', 3, 'completed', 0, 0, NULL, 'admin', '2026-04-14 10:00:00', 'admin', '2026-04-17 15:00:00', '胃部不适');
INSERT INTO `clinic_appointment` VALUES (156, 202, '孙伟', '13800138007', 101, '李医生', 129, '2026-04-17', '08:45-09:00', 2, 'cancelled', 0, 0, NULL, 'admin', '2026-04-14 11:00:00', 'admin', '2026-04-16 08:00:00', '时间冲突');
INSERT INTO `clinic_appointment` VALUES (157, 203, '李静', '13800138008', 102, '王医生', 131, '2026-04-18', '09:00-09:15', 1, 'completed', 0, 0, NULL, 'admin', '2026-04-15 09:00:00', 'admin', '2026-04-18 09:30:00', '胃炎');
INSERT INTO `clinic_appointment` VALUES (158, 204, '周强', '13800138009', 101, '李医生', 132, '2026-04-19', '09:15-09:30', 2, 'completed', 0, 0, NULL, 'admin', '2026-04-15 10:00:00', 'admin', '2026-04-19 10:00:00', '糖尿病');
INSERT INTO `clinic_appointment` VALUES (159, 205, '吴婷', '13800138010', 103, '张医生', 133, '2026-04-20', '08:30-08:45', 1, 'completed', 0, 0, NULL, 'admin', '2026-04-16 09:00:00', 'admin', '2026-04-20 09:00:00', '甲状腺');
INSERT INTO `clinic_appointment` VALUES (160, 206, '郑峰', '13800138011', 103, '张医生', 134, '2026-04-21', '14:30-14:45', 3, 'completed', 0, 0, NULL, 'admin', '2026-04-17 09:00:00', 'admin', '2026-04-21 15:00:00', '摔伤');
INSERT INTO `clinic_appointment` VALUES (161, 207, '王芳', '13800138012', 101, '李医生', 135, '2026-04-21', '08:30-08:45', 1, 'completed', 0, 0, NULL, 'admin', '2026-04-17 10:00:00', 'admin', '2026-04-21 09:00:00', '头痛');
INSERT INTO `clinic_appointment` VALUES (162, 208, '何磊', '13800138013', 102, '王医生', 136, '2026-04-22', '08:30-08:45', 1, 'completed', 1, 0, NULL, 'admin', '2026-04-18 09:00:00', 'admin', '2026-04-22 09:00:00', '鼻炎');
INSERT INTO `clinic_appointment` VALUES (163, 209, '郭敏', '13800138014', 101, '李医生', 137, '2026-04-22', '14:00-14:15', 1, 'completed', 0, 0, NULL, 'admin', '2026-04-18 10:00:00', 'admin', '2026-04-22 14:30:00', '感冒');
INSERT INTO `clinic_appointment` VALUES (164, 210, '陈旭', '13800138015', 103, '张医生', 138, '2026-04-23', '08:30-08:45', 1, 'completed', 0, 0, NULL, 'admin', '2026-04-19 09:00:00', 'admin', '2026-04-23 09:00:00', '腰痛');
INSERT INTO `clinic_appointment` VALUES (165, 211, '宋雨', '13800138016', 102, '王医生', 139, '2026-04-24', '09:00-09:15', 1, 'completed', 0, 0, NULL, 'admin', '2026-04-20 09:00:00', 'admin', '2026-04-24 09:30:00', '皮疹');
INSERT INTO `clinic_appointment` VALUES (166, 200, '赵明', '13800138005', 103, '张医生', 140, '2026-04-25', '09:00-09:15', 1, 'completed', 0, 0, NULL, 'admin', '2026-04-21 09:00:00', 'admin', '2026-04-25 09:30:00', '高血压复诊');
INSERT INTO `clinic_appointment` VALUES (167, 201, '钱红', '13800138006', 102, '王医生', 141, '2026-04-26', '09:15-09:30', 2, 'completed', 0, 0, NULL, 'admin', '2026-04-21 10:00:00', 'admin', '2026-04-26 10:00:00', '胃炎');
INSERT INTO `clinic_appointment` VALUES (168, 202, '孙伟', '13800138007', 103, '张医生', 142, '2026-04-27', '08:30-08:45', 1, 'completed', 0, 0, NULL, 'admin', '2026-04-22 09:00:00', 'admin', '2026-04-27 09:00:00', '哮喘');
INSERT INTO `clinic_appointment` VALUES (169, 203, '李静', '13800138008', 101, '李医生', 143, '2026-04-27', '14:30-14:45', 3, 'completed', 1, 0, NULL, 'admin', '2026-04-22 10:00:00', 'admin', '2026-04-27 15:00:00', '消化不良');
INSERT INTO `clinic_appointment` VALUES (170, 204, '周强', '13800138009', 103, '张医生', 144, '2026-04-28', '14:30-14:45', 3, 'completed', 0, 0, NULL, 'admin', '2026-04-23 09:00:00', 'admin', '2026-04-28 15:00:00', '糖尿病复诊');
INSERT INTO `clinic_appointment` VALUES (171, 205, '吴婷', '13800138010', 102, '王医生', 145, '2026-04-29', '08:30-08:45', 1, 'completed', 0, 0, NULL, 'admin', '2026-04-24 09:00:00', 'admin', '2026-04-29 09:00:00', '甲状腺复查');
INSERT INTO `clinic_appointment` VALUES (172, 206, '郑峰', '13800138011', 101, '李医生', 146, '2026-04-29', '14:00-14:15', 1, 'completed', 0, 0, NULL, 'admin', '2026-04-24 10:00:00', 'admin', '2026-04-29 14:30:00', '手指划伤');
INSERT INTO `clinic_appointment` VALUES (173, 207, '王芳', '13800138012', 103, '张医生', 147, '2026-04-30', '08:30-08:45', 1, 'completed', 0, 0, NULL, 'admin', '2026-04-25 09:00:00', 'admin', '2026-04-30 09:00:00', '头痛复诊');
INSERT INTO `clinic_appointment` VALUES (174, 208, '何磊', '13800138013', 102, '王医生', 148, '2026-04-30', '14:30-14:45', 3, 'completed', 0, 0, NULL, 'admin', '2026-04-25 10:00:00', 'admin', '2026-04-30 15:00:00', '过敏性鼻炎');
INSERT INTO `clinic_appointment` VALUES (175, 209, '郭敏', '13800138014', 103, '张医生', 149, '2026-05-01', '09:00-09:15', 1, 'completed', 0, 0, NULL, 'admin', '2026-04-26 09:00:00', 'admin', '2026-05-01 09:30:00', '体检');
INSERT INTO `clinic_appointment` VALUES (176, 210, '陈旭', '13800138015', 102, '王医生', 150, '2026-05-02', '08:30-08:45', 1, 'completed', 0, 0, NULL, 'admin', '2026-04-27 09:00:00', 'admin', '2026-05-02 09:00:00', '腰肌劳损');
INSERT INTO `clinic_appointment` VALUES (177, 211, '宋雨', '13800138016', 101, '李医生', 151, '2026-05-02', '14:00-14:15', 1, 'completed', 0, 0, NULL, 'admin', '2026-04-27 10:00:00', 'admin', '2026-05-02 14:30:00', '感冒');
INSERT INTO `clinic_appointment` VALUES (178, 200, '赵明', '13800138005', 103, '张医生', 152, '2026-05-03', '08:30-08:45', 1, 'completed', 1, 0, NULL, 'admin', '2026-04-28 09:00:00', 'admin', '2026-05-03 09:00:00', '高血压复诊');
INSERT INTO `clinic_appointment` VALUES (179, 201, '钱红', '13800138006', 101, '李医生', 153, '2026-05-03', '14:30-14:45', 3, 'completed', 0, 0, NULL, 'admin', '2026-04-28 10:00:00', 'admin', '2026-05-03 15:00:00', '胃炎');
INSERT INTO `clinic_appointment` VALUES (180, 202, '孙伟', '13800138007', 102, '王医生', 154, '2026-05-04', '08:30-08:45', 1, 'confirmed', 0, 0, NULL, 'admin', '2026-04-29 09:00:00', 'admin', '2026-04-29 09:00:00', '哮喘复查');
INSERT INTO `clinic_appointment` VALUES (181, 203, '李静', '13800138008', 103, '张医生', 155, '2026-05-04', '14:00-14:15', 1, 'confirmed', 0, 0, NULL, 'admin', '2026-04-29 10:00:00', 'admin', '2026-04-29 10:00:00', '胃炎复查');
INSERT INTO `clinic_appointment` VALUES (182, 204, '周强', '13800138009', 101, '李医生', 156, '2026-05-05', '08:30-08:45', 1, 'confirmed', 0, 0, NULL, 'admin', '2026-04-30 09:00:00', 'admin', '2026-04-30 09:00:00', '糖尿病复查');
INSERT INTO `clinic_appointment` VALUES (183, 205, '吴婷', '13800138010', 103, '张医生', 157, '2026-05-05', '14:30-14:45', 3, 'pending', 0, 0, NULL, 'admin', '2026-04-30 10:00:00', 'admin', '2026-04-30 10:00:00', '甲状腺');
INSERT INTO `clinic_appointment` VALUES (184, 206, '郑峰', '13800138011', 102, '王医生', 158, '2026-05-06', '08:30-08:45', 1, 'pending', 0, 0, NULL, 'admin', '2026-05-01 09:00:00', 'admin', '2026-05-01 09:00:00', '外伤复诊');
INSERT INTO `clinic_appointment` VALUES (185, 207, '王芳', '13800138012', 101, '李医生', 159, '2026-05-06', '14:00-14:15', 1, 'pending', 0, 0, NULL, 'admin', '2026-05-01 10:00:00', 'admin', '2026-05-01 10:00:00', '头痛');
INSERT INTO `clinic_appointment` VALUES (186, 208, '何磊', '13800138013', 103, '张医生', 160, '2026-05-07', '08:30-08:45', 1, 'pending', 0, 0, NULL, 'admin', '2026-05-02 09:00:00', 'admin', '2026-05-02 09:00:00', '鼻炎');
INSERT INTO `clinic_appointment` VALUES (187, 209, '郭敏', '13800138014', 102, '王医生', 161, '2026-05-07', '14:00-14:15', 1, 'pending', 0, 0, NULL, 'admin', '2026-05-02 10:00:00', 'admin', '2026-05-02 10:00:00', '感冒');
INSERT INTO `clinic_appointment` VALUES (188, 210, '陈旭', '13800138015', 101, '李医生', 162, '2026-05-08', '08:30-08:45', 1, 'pending', 0, 0, NULL, 'admin', '2026-05-03 09:00:00', 'admin', '2026-05-03 09:00:00', '腰痛');
INSERT INTO `clinic_appointment` VALUES (189, 211, '宋雨', '13800138016', 103, '张医生', 163, '2026-05-08', '14:00-14:15', 1, 'pending', 0, 0, NULL, 'admin', '2026-05-03 10:00:00', 'admin', '2026-05-03 10:00:00', '皮疹');
INSERT INTO `clinic_appointment` VALUES (190, 200, '赵明', '13800138005', 101, '李医生', 164, '2026-05-09', '08:30-08:45', 1, 'pending', 0, 0, NULL, 'admin', '2026-05-04 09:00:00', 'admin', '2026-05-04 09:00:00', '高血压');
INSERT INTO `clinic_appointment` VALUES (191, 201, '钱红', '13800138006', 103, '张医生', 165, '2026-05-09', '14:30-14:45', 3, 'pending', 0, 0, NULL, 'admin', '2026-05-04 10:00:00', 'admin', '2026-05-04 10:00:00', '胃部不适');
INSERT INTO `clinic_appointment` VALUES (192, 202, '孙伟', '13800138007', 102, '王医生', 167, '2026-05-11', '08:30-08:45', 1, 'pending', 0, 0, NULL, 'admin', '2026-05-05 09:00:00', 'admin', '2026-05-05 09:00:00', '咽炎');
INSERT INTO `clinic_appointment` VALUES (193, 203, '李静', '13800138008', 101, '李医生', 168, '2026-05-11', '14:00-14:15', 1, 'pending', 0, 0, NULL, 'admin', '2026-05-05 10:00:00', 'admin', '2026-05-05 10:00:00', '消化不良');
INSERT INTO `clinic_appointment` VALUES (194, 204, '周强', '13800138009', 103, '张医生', 169, '2026-05-12', '08:30-08:45', 1, 'pending', 0, 0, NULL, 'admin', '2026-05-06 09:00:00', 'admin', '2026-05-06 09:00:00', '糖尿病');
INSERT INTO `clinic_appointment` VALUES (195, 205, '吴婷', '13800138010', 102, '王医生', 171, '2026-05-13', '08:30-08:45', 1, 'pending', 0, 0, NULL, 'admin', '2026-05-07 09:00:00', 'admin', '2026-05-07 09:00:00', '甲状腺复查');
INSERT INTO `clinic_appointment` VALUES (196, 206, '郑峰', '13800138011', 101, '李医生', 172, '2026-05-13', '14:00-14:15', 1, 'pending', 0, 0, NULL, 'admin', '2026-05-07 10:00:00', 'admin', '2026-05-07 10:00:00', '手指划伤');
INSERT INTO `clinic_appointment` VALUES (197, 207, '王芳', '13800138012', 103, '张医生', 173, '2026-05-14', '08:30-08:45', 1, 'pending', 0, 0, NULL, 'admin', '2026-05-08 09:00:00', 'admin', '2026-05-08 09:00:00', '头痛复诊');
INSERT INTO `clinic_appointment` VALUES (198, 208, '何磊', '13800138013', 102, '王医生', 174, '2026-05-14', '14:00-14:15', 1, 'pending', 0, 0, NULL, 'admin', '2026-05-08 10:00:00', 'admin', '2026-05-08 10:00:00', '过敏');
INSERT INTO `clinic_appointment` VALUES (199, 209, '郭敏', '13800138014', 101, '李医生', 175, '2026-05-15', '08:30-08:45', 1, 'pending', 0, 0, NULL, 'admin', '2026-05-09 09:00:00', 'admin', '2026-05-09 09:00:00', '感冒复诊');
INSERT INTO `clinic_appointment` VALUES (200, 210, '陈旭', '13800138015', 103, '张医生', 176, '2026-05-15', '14:00-14:15', 1, 'pending', 0, 0, NULL, 'admin', '2026-05-09 10:00:00', 'admin', '2026-05-09 10:00:00', '腰伤');
INSERT INTO `clinic_appointment` VALUES (201, 211, '宋雨', '13800138016', 102, '王医生', 177, '2026-05-16', '08:30-08:45', 1, 'pending', 0, 0, NULL, 'admin', '2026-05-10 09:00:00', 'admin', '2026-05-10 09:00:00', '皮疹复诊');
INSERT INTO `clinic_appointment` VALUES (202, 200, '赵明', '13800138005', 103, '张医生', 178, '2026-05-16', '14:00-14:15', 1, 'pending', 0, 0, NULL, 'admin', '2026-05-10 10:00:00', 'admin', '2026-05-10 10:00:00', '高血压复查');
INSERT INTO `clinic_appointment` VALUES (203, 201, '钱红', '13800138006', 101, '李医生', 179, '2026-05-17', '08:30-08:45', 1, 'pending', 0, 0, NULL, 'admin', '2026-05-11 09:00:00', 'admin', '2026-05-11 09:00:00', '胃炎');
INSERT INTO `clinic_appointment` VALUES (204, 202, '孙伟', '13800138007', 102, '王医生', 180, '2026-05-17', '14:00-14:15', 1, 'pending', 0, 0, NULL, 'admin', '2026-05-11 10:00:00', 'admin', '2026-05-11 10:00:00', '哮喘');
INSERT INTO `clinic_appointment` VALUES (205, 203, '李静', '13800138008', 103, '张医生', 182, '2026-05-18', '14:00-14:15', 1, 'pending', 0, 0, NULL, 'admin', '2026-05-12 09:00:00', 'admin', '2026-05-12 09:00:00', '胃炎');
INSERT INTO `clinic_appointment` VALUES (206, 204, '周强', '13800138009', 101, '李医生', 183, '2026-05-19', '08:30-08:45', 1, 'pending', 0, 0, NULL, 'admin', '2026-05-12 10:00:00', 'admin', '2026-05-12 10:00:00', '糖尿病复诊');
INSERT INTO `clinic_appointment` VALUES (207, 205, '吴婷', '13800138010', 103, '张医生', 184, '2026-05-20', '08:30-08:45', 1, 'pending', 0, 0, NULL, 'admin', '2026-05-13 09:00:00', 'admin', '2026-05-13 09:00:00', '甲状腺');
INSERT INTO `clinic_appointment` VALUES (208, 206, '郑峰', '13800138011', 102, '王医生', 185, '2026-05-20', '14:00-14:15', 1, 'pending', 0, 0, NULL, 'admin', '2026-05-13 10:00:00', 'admin', '2026-05-13 10:00:00', '手指');
INSERT INTO `clinic_appointment` VALUES (209, 207, '王芳', '13800138012', 101, '李医生', 186, '2026-05-21', '08:30-08:45', 1, 'pending', 0, 0, NULL, 'admin', '2026-05-14 09:00:00', 'admin', '2026-05-14 09:00:00', '头痛');
INSERT INTO `clinic_appointment` VALUES (210, 208, '何磊', '13800138013', 103, '张医生', 187, '2026-05-21', '14:00-14:15', 1, 'pending', 0, 0, NULL, 'admin', '2026-05-14 10:00:00', 'admin', '2026-05-14 10:00:00', '鼻炎');
INSERT INTO `clinic_appointment` VALUES (211, 209, '郭敏', '13800138014', 102, '王医生', 188, '2026-05-22', '08:30-08:45', 1, 'pending', 0, 0, NULL, 'admin', '2026-05-15 09:00:00', 'admin', '2026-05-15 09:00:00', '感冒');
INSERT INTO `clinic_appointment` VALUES (212, 210, '陈旭', '13800138015', 101, '李医生', 189, '2026-05-22', '14:00-14:15', 1, 'pending', 0, 0, NULL, 'admin', '2026-05-15 10:00:00', 'admin', '2026-05-15 10:00:00', '腰');
INSERT INTO `clinic_appointment` VALUES (213, 211, '宋雨', '13800138016', 103, '张医生', 190, '2026-05-23', '08:30-08:45', 1, 'pending', 0, 0, NULL, 'admin', '2026-05-16 09:00:00', 'admin', '2026-05-16 09:00:00', '皮疹');
INSERT INTO `clinic_appointment` VALUES (214, 200, '赵明', '13800138005', 101, '李医生', 192, '2026-05-25', '08:30-08:45', 1, 'pending', 0, 0, NULL, 'admin', '2026-05-17 09:00:00', 'admin', '2026-05-17 09:00:00', '高血压');
INSERT INTO `clinic_appointment` VALUES (215, 201, '钱红', '13800138006', 103, '张医生', 193, '2026-05-25', '14:00-14:15', 1, 'pending', 0, 0, NULL, 'admin', '2026-05-17 10:00:00', 'admin', '2026-05-17 10:00:00', '胃部不适');
INSERT INTO `clinic_appointment` VALUES (216, 202, '孙伟', '13800138007', 102, '王医生', 194, '2026-05-26', '08:30-08:45', 1, 'confirmed', 0, 1, '2026-04-01 18:45:09', 'admin', '2026-05-18 09:00:00', 'admin', '2026-04-01 18:45:08', '咽炎');
INSERT INTO `clinic_appointment` VALUES (217, 203, '李静', '13800138008', 101, '李医生', 195, '2026-05-26', '14:00-14:15', 1, 'pending', 0, 0, NULL, 'admin', '2026-05-18 10:00:00', 'admin', '2026-05-18 10:00:00', '消化不良');
INSERT INTO `clinic_appointment` VALUES (218, 204, '周强', '13800138009', 103, '张医生', 196, '2026-05-27', '08:30-08:45', 1, 'confirmed', 0, 1, '2026-04-01 18:45:03', 'admin', '2026-05-19 09:00:00', 'admin', '2026-04-01 18:45:01', '糖尿病');
INSERT INTO `clinic_appointment` VALUES (219, 205, '吴婷', '13800138010', 102, '王医生', 197, '2026-05-27', '14:00-14:15', 1, 'pending', 0, 0, NULL, 'admin', '2026-05-19 10:00:00', 'admin', '2026-05-19 10:00:00', '甲状腺');
INSERT INTO `clinic_appointment` VALUES (220, 206, '郑峰', '13800138011', 101, '李医生', 198, '2026-05-28', '08:30-08:45', 1, 'pending', 0, 0, NULL, 'admin', '2026-05-20 09:00:00', 'admin', '2026-05-20 09:00:00', '外伤');
INSERT INTO `clinic_appointment` VALUES (221, 207, '王芳', '13800138012', 103, '张医生', 199, '2026-05-28', '14:00-14:15', 1, 'confirmed', 0, 0, NULL, 'admin', '2026-05-20 10:00:00', 'admin', '2026-04-01 18:44:56', '头痛');
INSERT INTO `clinic_appointment` VALUES (222, 208, '何磊', '13800138013', 102, '王医生', 200, '2026-05-29', '08:30-08:45', 1, 'pending', 0, 0, NULL, 'admin', '2026-05-21 09:00:00', 'admin', '2026-05-21 09:00:00', '鼻炎');
INSERT INTO `clinic_appointment` VALUES (223, 209, '郭敏', '13800138014', 101, '李医生', 201, '2026-05-29', '14:00-14:15', 1, 'pending', 0, 0, NULL, 'admin', '2026-05-21 10:00:00', '13800138001', '2026-04-03 02:11:32', '感冒');
INSERT INTO `clinic_appointment` VALUES (224, 210, '陈旭', '13800138015', 103, '张医生', 202, '2026-05-30', '08:30-08:45', 1, 'completed', 0, 0, NULL, 'admin', '2026-05-22 09:00:00', '13800138001', '2026-04-03 02:48:00', '腰');
INSERT INTO `clinic_appointment` VALUES (225, 211, '宋雨', '13800138016', 102, '王医生', 204, '2026-05-31', '09:00-09:15', 1, 'confirmed', 0, 1, '2026-04-03 00:34:23', 'admin', '2026-05-23 09:00:00', '13800138001', '2026-04-03 00:34:14', '皮疹');
INSERT INTO `clinic_appointment` VALUES (226, 211, '宋雨', '13800138111', 101, '李医生', 100, '2026-04-01', '08:00-12:00', 7, 'confirmed', NULL, 1, '2026-04-01 20:59:29', '13800138111', '2026-04-01 20:58:03', 'admin', '2026-04-01 20:59:27', NULL);
INSERT INTO `clinic_appointment` VALUES (227, 101, '钱红', NULL, 101, '李医生', 102, '2026-04-02', '08:30 - 12:00', 2, 'pending', NULL, 0, NULL, 'admin', '2026-04-03 00:29:58', '', NULL, NULL);
INSERT INTO `clinic_appointment` VALUES (228, 100, '赵明', '13800138005', 102, '王医生', 114, '2026-04-03', '14:00-18:00', 9, 'pending', NULL, 0, NULL, '13800138100', '2026-04-03 02:29:06', '', NULL, NULL);
INSERT INTO `clinic_appointment` VALUES (229, 100, 'TestPatient', '13800138005', 101, 'Doctor101', 219, '2026-04-03', '00:55-06:55', 1, 'completed', NULL, 0, NULL, '13800138100', '2026-04-03 02:41:39', '13800138001', '2026-04-03 02:41:39', NULL);
INSERT INTO `clinic_appointment` VALUES (230, 100, '赵明', '13800138005', 101, '李医生', 219, '2026-04-03', '00:55-06:55', 2, 'pending', NULL, 0, NULL, '13800138100', '2026-04-03 03:01:22', '', NULL, NULL);

-- ----------------------------
-- Table structure for clinic_config
-- ----------------------------
DROP TABLE IF EXISTS `clinic_config`;
CREATE TABLE `clinic_config`  (
  `config_id` bigint NOT NULL AUTO_INCREMENT COMMENT '配置ID',
  `config_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '配置键',
  `config_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '配置值',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '描述',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`config_id`) USING BTREE,
  UNIQUE INDEX `uk_config_key`(`config_key`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 105 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of clinic_config
-- ----------------------------
INSERT INTO `clinic_config` VALUES (100, 'clinic.stockWarningThreshold', '10', '库存预警阈值', '2026-04-01 17:23:23', '2026-04-01 17:23:23');
INSERT INTO `clinic_config` VALUES (101, 'clinic.appointmentDays', '14', '可预约天数', '2026-04-01 17:23:23', '2026-04-01 17:23:23');
INSERT INTO `clinic_config` VALUES (102, 'clinic_name', '阳光社区诊所', '诊所名称', '2026-04-01 17:23:23', '2026-04-01 17:23:23');
INSERT INTO `clinic_config` VALUES (103, 'clinic_address', '北京市朝阳区建国路88号', '诊所地址', '2026-04-01 17:23:23', '2026-04-01 17:23:23');
INSERT INTO `clinic_config` VALUES (104, 'clinic_phone', '010-88888888', '诊所电话', '2026-04-01 17:23:23', '2026-04-01 17:23:23');

-- ----------------------------
-- Table structure for clinic_medical_record
-- ----------------------------
DROP TABLE IF EXISTS `clinic_medical_record`;
CREATE TABLE `clinic_medical_record`  (
  `record_id` bigint NOT NULL AUTO_INCREMENT COMMENT '病历ID',
  `patient_id` bigint NOT NULL COMMENT '患者ID',
  `patient_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '患者姓名',
  `patient_gender` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '患者性别',
  `patient_age` int NULL DEFAULT NULL COMMENT '患者年龄',
  `patient_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '患者电话',
  `patient_birthday` date NULL DEFAULT NULL COMMENT '患者生日',
  `patient_blood_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '患者血型',
  `doctor_id` bigint NULL DEFAULT NULL COMMENT '医生ID',
  `doctor_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '医生姓名',
  `visit_time` datetime NULL DEFAULT NULL COMMENT '就诊时间',
  `chief_complaint` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '主诉',
  `present_illness` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '现病史',
  `past_history` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '既往史',
  `allergy_history` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '过敏史',
  `physical_exam` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '体格检查',
  `diagnosis` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '诊断',
  `treatment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '治疗方案',
  `prescription` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '处方（JSON格式）',
  `attachments` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '附件（JSON格式）',
  `follow_up` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '随访计划',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`record_id`) USING BTREE,
  INDEX `idx_patient_id`(`patient_id`) USING BTREE,
  INDEX `idx_doctor_id`(`doctor_id`) USING BTREE,
  INDEX `idx_visit_time`(`visit_time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 131 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '病历记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of clinic_medical_record
-- ----------------------------
INSERT INTO `clinic_medical_record` VALUES (100, 100, '赵明', '男', 40, '13800138005', '1986-03-15', 'A', 101, '李医生', '2026-03-29 17:23:23', '发热咳嗽2天', '咽痛、低热', '高血压', '青霉素过敏', '体温37.8℃，咽部充血', '上呼吸道感染', '对症治疗，多饮水', '[{\"medicineId\":100,\"name\":\"复方感冒灵颗粒\",\"specification\":\"10g*9袋\",\"dosage\":\"1袋\",\"frequency\":\"每日3次\",\"days\":3},{\"medicineId\":119,\"name\":\"布洛芬缓释胶囊\",\"specification\":\"0.3g*20粒\",\"dosage\":\"1粒\",\"frequency\":\"必要时\",\"days\":2}]', '[]', '3天后复诊，如症状加重随时就诊', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '首诊');
INSERT INTO `clinic_medical_record` VALUES (101, 101, '钱红', '女', 34, '13800138006', '1992-07-22', 'B', 101, '李医生', '2026-03-30 17:23:23', '胃部不适1周', '反酸、嗳气', '无', '海鲜过敏', '上腹轻压痛', '慢性胃炎', '抑酸+饮食调整', '[{\"medicineId\":114,\"name\":\"奥美拉唑肠溶胶囊\",\"specification\":\"20mg*14粒\",\"dosage\":\"1粒\",\"frequency\":\"每日1次\",\"days\":14}]', '[]', '2周后复诊，如症状加重随时就诊', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '慢病随访');
INSERT INTO `clinic_medical_record` VALUES (102, 102, '孙伟', '男', 46, '13800138007', '1980-11-08', 'O', 102, '王医生', '2026-03-31 17:23:23', '咽痛伴发热', '起病急', '哮喘病史', '花粉过敏', '咽部红肿', '急性咽炎', '抗感染治疗', '[{\"medicineId\":106,\"name\":\"头孢克肟分散片\",\"specification\":\"0.1g*6片\",\"dosage\":\"1片\",\"frequency\":\"每日2次\",\"days\":5}]', '[]', '必要时复诊', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '普通门诊');
INSERT INTO `clinic_medical_record` VALUES (103, 104, '周强', '男', 52, '13800138009', '1974-10-10', 'A', 103, '张医生', '2026-04-01 17:23:23', '咳嗽3天', '夜间加重', '糖尿病病史', '无', '双肺呼吸音粗', '急性支气管炎', '止咳化痰', '[{\"medicineId\":105,\"name\":\"阿莫西林胶囊\",\"specification\":\"0.25g*24粒\",\"dosage\":\"2粒\",\"frequency\":\"每日3次\",\"days\":5},{\"medicineId\":105,\"name\":\"复方甘草片\",\"specification\":\"100片\",\"dosage\":\"2片\",\"frequency\":\"每日3次\",\"days\":4}]', '[]', '1周后复诊', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '已开药');
INSERT INTO `clinic_medical_record` VALUES (104, 200, '赵明', '男', 40, '13800138005', '1986-03-15', 'A', 101, '李医生', '2026-03-15 09:30:00', '头痛发热2天', '患者2天前受凉后出现头痛、发热，体温38.2℃，伴鼻塞流涕', '高血压病史5年，规律服用硝苯地平缓释片', '青霉素过敏', '体温38.2℃，咽部轻度充血，心肺未见异常', '急性上呼吸道感染', '对症治疗，给予复方感冒灵颗粒和布洛芬', '[{\"medicineId\":100,\"name\":\"复方感冒灵颗粒(白云山)\",\"specification\":\"10g*9袋\",\"dosage\":\"1袋\",\"frequency\":\"每日3次\",\"days\":5},{\"medicineId\":119,\"name\":\"布洛芬缓释胶囊(中美史克)\",\"specification\":\"0.3g*20粒\",\"dosage\":\"1粒\",\"frequency\":\"必要时\",\"days\":3}]', '[]', '5天后复诊，如症状加重随时就诊', 'admin', '2026-03-15 10:00:00', 'admin', '2026-03-15 10:00:00', '初诊');
INSERT INTO `clinic_medical_record` VALUES (105, 200, '赵明', '男', 40, '13800138005', '1986-03-15', 'A', 101, '李医生', '2026-03-22 10:00:00', '感冒复诊', '服药后体温恢复正常，头痛减轻，仍有轻微鼻塞', '高血压病史5年', '青霉素过敏', '体温36.8℃，咽部无明显充血，心肺正常', '急性上呼吸道感染（好转）', '继续服用复方感冒灵颗粒巩固治疗', '[{\"medicineId\":100,\"name\":\"复方感冒灵颗粒(白云山)\",\"specification\":\"10g*9袋\",\"dosage\":\"1袋\",\"frequency\":\"每日3次\",\"days\":3}]', '[]', '注意休息，多饮水，不适随诊', 'admin', '2026-03-22 10:30:00', 'admin', '2026-03-22 10:30:00', '复诊');
INSERT INTO `clinic_medical_record` VALUES (106, 200, '赵明', '男', 40, '13800138005', '1986-03-15', 'A', 101, '李医生', '2026-04-01 09:00:00', '高血压复诊', '血压控制尚可，近两周自行监测血压波动在130-145/85-95mmHg', '高血压病史5年，服用硝苯地平缓释片', '青霉素过敏', '血压140/92mmHg，心肺未见异常', '原发性高血压（血压控制一般）', '继续当前降压方案，加用贝那普利片', '[{\"medicineId\":152,\"name\":\"贝那普利片(诺华)\",\"specification\":\"10mg*7片\",\"dosage\":\"1片\",\"frequency\":\"每日1次\",\"days\":7}]', '[]', '1周后复查血压，规律服药', 'admin', '2026-04-01 09:30:00', 'admin', '2026-04-01 09:30:00', '慢病随访');
INSERT INTO `clinic_medical_record` VALUES (107, 201, '钱红', '女', 34, '13800138006', '1992-07-22', 'B', 101, '李医生', '2026-03-20 14:00:00', '胃部不适1周', '患者1周前开始出现胃部不适，表现为反酸、嗳气，饭后加重', '无特殊病史', '海鲜过敏', '上腹轻压痛，无反跳痛', '慢性胃炎', '抑酸护胃治疗，铝碳酸镁片+奥美拉唑', '[{\"medicineId\":144,\"name\":\"铝碳酸镁片(拜耳)\",\"specification\":\"0.5g*20片\",\"dosage\":\"2片\",\"frequency\":\"每日3次\",\"days\":7},{\"medicineId\":142,\"name\":\"奥美拉唑肠溶胶囊(阿斯利康)\",\"specification\":\"20mg*14粒\",\"dosage\":\"1粒\",\"frequency\":\"每日1次\",\"days\":14}]', '[]', '2周后复诊，如症状加重随时就诊', 'admin', '2026-03-20 14:30:00', 'admin', '2026-03-20 14:30:00', '初诊');
INSERT INTO `clinic_medical_record` VALUES (108, 201, '钱红', '女', 34, '13800138006', '1992-07-22', 'B', 101, '李医生', '2026-04-04 10:00:00', '胃炎复诊', '服药后反酸嗳气症状明显好转，胃部不适感消失', '无特殊病史', '海鲜过敏', '上腹无压痛', '慢性胃炎（好转）', '继续服用奥美拉唑肠溶胶囊', '[{\"medicineId\":142,\"name\":\"奥美拉唑肠溶胶囊(阿斯利康)\",\"specification\":\"20mg*14粒\",\"dosage\":\"1粒\",\"frequency\":\"每日1次\",\"days\":14}]', '[]', '注意饮食规律，避免辛辣刺激食物', 'admin', '2026-04-04 10:30:00', 'admin', '2026-04-04 10:30:00', '复诊');
INSERT INTO `clinic_medical_record` VALUES (109, 202, '孙伟', '男', 46, '13800138007', '1980-11-08', 'O', 103, '张医生', '2026-03-18 09:00:00', '咽痛伴发热3天', '患者3天前开始咽痛，吞咽时加重，伴发热，体温37.8℃', '哮喘病史3年，季节性发作', '花粉过敏', '咽部红肿，扁桃体I度肿大', '急性咽炎', '抗感染治疗，头孢克肟分散片', '[{\"medicineId\":106,\"name\":\"头孢克肟分散片(石药集团)\",\"specification\":\"0.1g*6片\",\"dosage\":\"1片\",\"frequency\":\"每日2次\",\"days\":5}]', '[]', '5天后复诊，如症状加重随时就诊', 'admin', '2026-03-18 09:30:00', 'admin', '2026-03-18 09:30:00', '普通门诊');
INSERT INTO `clinic_medical_record` VALUES (110, 202, '孙伟', '男', 46, '13800138007', '1980-11-08', 'O', 103, '张医生', '2026-04-10 09:00:00', '咽炎复诊', '服药后咽痛明显减轻，体温恢复正常', '哮喘病史3年', '花粉过敏', '咽部轻度充血，扁桃体无肿大', '急性咽炎（痊愈）', '无需继续用药，注意休息', '[]', '[]', '不适随诊', 'admin', '2026-04-10 09:30:00', 'admin', '2026-04-10 09:30:00', '复诊');
INSERT INTO `clinic_medical_record` VALUES (111, 203, '李静', '女', 29, '13800138008', '1997-04-02', 'AB', 102, '王医生', '2026-03-25 10:00:00', '胃部不适伴消化不良', '患者近2周出现胃部不适，表现为餐后腹胀、嗳气，食欲下降', '胃炎病史1年', '无', '上腹轻压痛，肠鸣音正常', '功能性消化不良', '促消化治疗，健胃消食片', '[{\"medicineId\":135,\"name\":\"999感冒灵颗粒(华润三九)\",\"specification\":\"10g*9袋\",\"dosage\":\"1袋\",\"frequency\":\"每日3次\",\"days\":5}]', '[]', '注意饮食规律，必要时复查胃镜', 'admin', '2026-03-25 10:30:00', 'admin', '2026-03-25 10:30:00', '初诊');
INSERT INTO `clinic_medical_record` VALUES (112, 203, '李静', '女', 29, '13800138008', '1997-04-02', 'AB', 101, '李医生', '2026-04-08 14:00:00', '消化不良复诊', '服药后腹胀症状有所改善，食欲有所恢复', '胃炎病史1年', '无', '上腹无明显压痛', '功能性消化不良（好转）', '继续服用健胃消食片', '[{\"medicineId\":135,\"name\":\"999感冒灵颗粒(华润三九)\",\"specification\":\"10g*9袋\",\"dosage\":\"1袋\",\"frequency\":\"每日3次\",\"days\":5}]', '[]', '注意饮食规律', 'admin', '2026-04-08 14:30:00', 'admin', '2026-04-08 14:30:00', '复诊');
INSERT INTO `clinic_medical_record` VALUES (113, 204, '周强', '男', 52, '13800138009', '1974-10-10', 'A', 103, '张医生', '2026-03-28 10:00:00', '多饮多尿半月', '患者半月前开始出现口干、多饮、多尿症状，体重无明显变化', '糖尿病病史3年，口服二甲双胍', '无', '空腹血糖8.5mmol/L，血压正常', '2型糖尿病（血糖控制不佳）', '调整降糖方案，加用阿卡波糖', '[{\"medicineId\":155,\"name\":\"辛伐他汀片(默沙东)\",\"specification\":\"20mg*7片\",\"dosage\":\"1片\",\"frequency\":\"每日1次\",\"days\":14}]', '[]', '1周后复查血糖，规律服药', 'admin', '2026-03-28 10:30:00', 'admin', '2026-03-28 10:30:00', '慢病随访');
INSERT INTO `clinic_medical_record` VALUES (114, 204, '周强', '男', 52, '13800138009', '1974-10-10', 'A', 103, '张医生', '2026-04-15 10:00:00', '糖尿病复诊', '调整用药后口干多饮症状有所改善，空腹血糖7.2mmol/L', '糖尿病病史3年', '无', '空腹血糖7.2mmol/L，血压正常', '2型糖尿病（血糖控制改善）', '继续当前降糖方案', '[{\"medicineId\":155,\"name\":\"辛伐他汀片(默沙东)\",\"specification\":\"20mg*7片\",\"dosage\":\"1片\",\"frequency\":\"每日1次\",\"days\":14}]', '[]', '继续监测血糖，2周后复诊', 'admin', '2026-04-15 10:30:00', 'admin', '2026-04-15 10:30:00', '复诊');
INSERT INTO `clinic_medical_record` VALUES (115, 205, '吴婷', '女', 31, '13800138010', '1995-12-01', 'B', 101, '李医生', '2026-04-01 14:00:00', '头痛1周', '患者1周前开始出现头部胀痛，以双侧太阳穴为主，休息后缓解', '甲状腺结节病史', '头孢过敏', '神志清，颅神经(-)，心肺未见异常', '紧张性头痛', '对症治疗，布洛芬颗粒', '[{\"medicineId\":125,\"name\":\"布洛芬颗粒(扬子江)\",\"specification\":\"0.2g*12袋\",\"dosage\":\"1袋\",\"frequency\":\"每日3次\",\"days\":3}]', '[]', '注意休息，避免熬夜', 'admin', '2026-04-01 14:30:00', 'admin', '2026-04-01 14:30:00', '普通门诊');
INSERT INTO `clinic_medical_record` VALUES (116, 205, '吴婷', '女', 31, '13800138010', '1995-12-01', 'B', 103, '张医生', '2026-04-20 09:00:00', '头痛复诊', '服药后头痛症状明显减轻，继续服用以巩固疗效', '甲状腺结节病史', '头孢过敏', '神志清，头痛缓解', '紧张性头痛（好转）', '继续服用布洛芬颗粒', '[{\"medicineId\":125,\"name\":\"布洛芬颗粒(扬子江)\",\"specification\":\"0.2g*12袋\",\"dosage\":\"1袋\",\"frequency\":\"每日3次\",\"days\":3}]', '[]', '避免精神紧张，保持良好作息', 'admin', '2026-04-20 09:30:00', 'admin', '2026-04-20 09:30:00', '复诊');
INSERT INTO `clinic_medical_record` VALUES (117, 206, '郑峰', '男', 38, '13800138011', '1988-01-23', 'O', 102, '王医生', '2026-04-02 08:30:00', '右手食指划伤2小时', '患者2小时前在厨房切菜时不慎划伤右手食指，伤口约1.5cm，出血不多', '无特殊病史', '无', '右手食指见长约1.5cm伤口，局部无红肿', '皮肤软组织损伤', '伤口清创处理，碘伏消毒，必要时口服抗生素', '[{\"medicineId\":201,\"name\":\"碘伏消毒液(利尔康)\",\"specification\":\"100ml\",\"dosage\":\"适量\",\"frequency\":\"每日2次\",\"days\":7}]', '[]', '2天后复查伤口', 'admin', '2026-04-02 09:00:00', 'admin', '2026-04-02 09:00:00', '外伤');
INSERT INTO `clinic_medical_record` VALUES (118, 206, '郑峰', '男', 38, '13800138011', '1988-01-23', 'O', 102, '王医生', '2026-04-05 08:30:00', '手指划伤复诊', '伤口愈合良好，无红肿渗出', '无特殊病史', '无', '右手食指伤口已结痂愈合', '皮肤软组织损伤（痊愈）', '无需继续用药', '[]', '[]', '已愈', 'admin', '2026-04-05 09:00:00', 'admin', '2026-04-05 09:00:00', '复诊');
INSERT INTO `clinic_medical_record` VALUES (119, 207, '王芳', '女', 44, '13800138012', '1982-06-16', 'AB', 101, '李医生', '2026-04-07 14:00:00', '反复头痛2月', '患者近2月反复出现头痛，呈搏动性，以右侧为主，休息后可缓解', '偏头痛病史5年', '无', '神志清，颅神经(-)，心肺未见异常', '偏头痛', '对症治疗，苯磺酸氨氯地平片', '[{\"medicineId\":156,\"name\":\"苯磺酸氨氯地平片(络活喜)\",\"specification\":\"5mg*7片\",\"dosage\":\"1片\",\"frequency\":\"每日1次\",\"days\":7}]', '[]', '避免诱发因素，如症状频繁发作需进一步检查', 'admin', '2026-04-07 14:30:00', 'admin', '2026-04-07 14:30:00', '普通门诊');
INSERT INTO `clinic_medical_record` VALUES (120, 207, '王芳', '女', 44, '13800138012', '1982-06-16', 'AB', 101, '李医生', '2026-04-21 09:00:00', '头痛复诊', '服药后头痛发作频率减少，疼痛程度减轻', '偏头痛病史5年', '无', '神志清，无明显阳性体征', '偏头痛（好转）', '继续服用苯磺酸氨氯地平片', '[{\"medicineId\":156,\"name\":\"苯磺酸氨氯地平片(络活喜)\",\"specification\":\"5mg*7片\",\"dosage\":\"1片\",\"frequency\":\"每日1次\",\"days\":7}]', '[]', '记录头痛日记，避免诱因', 'admin', '2026-04-21 09:30:00', 'admin', '2026-04-21 09:30:00', '复诊');
INSERT INTO `clinic_medical_record` VALUES (121, 208, '何磊', '男', 27, '13800138013', '1999-09-12', 'A', 102, '王医生', '2026-04-08 09:00:00', '鼻塞流涕1周', '患者1周前开始出现鼻塞流涕，伴打喷嚏，无发热', '过敏性鼻炎病史2年', '尘螨过敏', '鼻黏膜苍白水肿，双侧下鼻甲肿大', '过敏性鼻炎', '抗过敏治疗，氯雷他定片+布地奈德鼻喷雾剂', '[{\"medicineId\":116,\"name\":\"氯雷他定片(扬子江)\",\"specification\":\"10mg*6片\",\"dosage\":\"1片\",\"frequency\":\"每日1次\",\"days\":7},{\"medicineId\":182,\"name\":\"布地奈德鼻喷雾剂(阿斯利康)\",\"specification\":\"32μg*120喷\",\"dosage\":\"每侧1喷\",\"frequency\":\"每日2次\",\"days\":7}]', '[]', '避免接触过敏原', 'admin', '2026-04-08 09:30:00', 'admin', '2026-04-08 09:30:00', '初诊');
INSERT INTO `clinic_medical_record` VALUES (122, 208, '何磊', '男', 27, '13800138013', '1999-09-12', 'A', 103, '张医生', '2026-04-23 09:00:00', '鼻炎复诊', '用药后鼻塞流涕症状明显改善，喷嚏减少', '过敏性鼻炎病史2年', '尘螨过敏', '鼻黏膜苍白减轻，双侧下鼻甲肿大减轻', '过敏性鼻炎（好转）', '继续使用布地奈德鼻喷雾剂', '[{\"medicineId\":182,\"name\":\"布地奈德鼻喷雾剂(阿斯利康)\",\"specification\":\"32μg*120喷\",\"dosage\":\"每侧1喷\",\"frequency\":\"每日2次\",\"days\":7}]', '[]', '注意鼻腔清洁，避免接触过敏原', 'admin', '2026-04-23 09:30:00', 'admin', '2026-04-23 09:30:00', '复诊');
INSERT INTO `clinic_medical_record` VALUES (123, 209, '郭敏', '女', 36, '13800138014', '1990-02-19', 'B', 101, '李医生', '2026-04-12 10:00:00', '发热咽痛2天', '患者2天前开始发热，体温37.8℃，伴咽痛吞咽困难', '无特殊病史', '无', '体温37.8℃，咽部红肿，双侧扁桃体II度肿大', '急性扁桃体炎', '抗感染治疗，头孢氨苄胶囊', '[{\"medicineId\":136,\"name\":\"头孢氨苄胶囊(华北制药)\",\"specification\":\"0.25g*24粒\",\"dosage\":\"2粒\",\"frequency\":\"每日4次\",\"days\":5}]', '[]', '5天后复诊，多饮水', 'admin', '2026-04-12 10:30:00', 'admin', '2026-04-12 10:30:00', '普通门诊');
INSERT INTO `clinic_medical_record` VALUES (124, 209, '郭敏', '女', 36, '13800138014', '1990-02-19', 'B', 103, '张医生', '2026-04-30 09:00:00', '感冒复诊', '服药后体温恢复正常，咽痛明显减轻', '无特殊病史', '无', '体温36.6℃，咽部轻度充血，扁桃体I度肿大', '急性扁桃体炎（好转）', '无需继续用药', '[{\"name\":\"包药\",\"dosage\":\"2片\",\"frequency\":\"每日3次\",\"days\":\"\",\"isPackMedicine\":1,\"packItems\":[{\"medicineId\":104,\"name\":\"维C银翘片(贵州百灵)（贵州百灵企业集团制药股份有限公司）\",\"specification\":\"12片*2板\",\"quantity\":1,\"batchId\":105,\"batchNumber\":\"B2027E001\"},{\"medicineId\":111,\"name\":\"维生素C片(华中药业)（华中药业股份有限公司）\",\"specification\":\"0.1g*100片\",\"quantity\":1,\"batchId\":112,\"batchNumber\":\"B2027L001\"}]}]', '[]', '注意保暖，适量运动', 'admin', '2026-05-01 09:30:00', 'admin', '2026-04-01 18:28:50', '复诊');
INSERT INTO `clinic_medical_record` VALUES (125, 210, '陈旭', '男', 33, '13800138015', '1993-08-25', 'O', 103, '张医生', '2026-04-16 14:00:00', '腰痛3天', '患者3天前搬家后出现腰部疼痛，活动受限，休息后不缓解', '腰肌劳损病史1年', '无', '腰椎旁压痛，无下肢放射痛，直腿抬高试验(-)', '急性腰肌劳损', '对症治疗，外用云南白药气雾剂+口服布洛芬', '[{\"medicineId\":181,\"name\":\"云南白药气雾剂(云南白药)\",\"specification\":\"50g+30g\",\"dosage\":\"适量\",\"frequency\":\"每日3-5次\",\"days\":7},{\"medicineId\":119,\"name\":\"布洛芬缓释胶囊(中美史克)\",\"specification\":\"0.3g*20粒\",\"dosage\":\"1粒\",\"frequency\":\"每日2次\",\"days\":5}]', '[]', '避免弯腰负重，适当休息', 'admin', '2026-04-16 14:30:00', 'admin', '2026-04-16 14:30:00', '初诊');
INSERT INTO `clinic_medical_record` VALUES (126, 210, '陈旭', '男', 33, '13800138015', '1993-08-25', 'O', 102, '王医生', '2026-04-23 09:00:00', '腰痛复诊', '用药后腰痛明显减轻，活动受限改善', '腰肌劳损病史1年', '无', '腰椎旁压痛减轻', '急性腰肌劳损（好转）', '继续外用云南白药气雾剂', '[{\"medicineId\":181,\"name\":\"云南白药气雾剂(云南白药)\",\"specification\":\"50g+30g\",\"dosage\":\"适量\",\"frequency\":\"每日3次\",\"days\":5}]', '[]', '避免劳累，适当腰背肌锻炼', 'admin', '2026-04-23 09:30:00', 'admin', '2026-04-23 09:30:00', '复诊');
INSERT INTO `clinic_medical_record` VALUES (127, 211, '宋雨', '女', 25, '13800138016', '2001-05-03', 'AB', 102, '王医生', '2026-04-12 15:00:00', '面部皮疹3天', '患者3天前面部出现红斑、丘疹，伴轻度瘙痒', '无特殊病史', '青霉素过敏', '面部见散在红斑、丘疹，无水泡渗出', '面部皮炎', '抗过敏治疗，氯雷他定片+外用氧化锌软膏', '[{\"medicineId\":116,\"name\":\"氯雷他定片(扬子江)\",\"specification\":\"10mg*6片\",\"dosage\":\"1片\",\"frequency\":\"每日1次\",\"days\":5}]', '[]', '避免搔抓，3天后复诊', 'admin', '2026-04-12 15:30:00', 'admin', '2026-04-12 15:30:00', '皮肤门诊');
INSERT INTO `clinic_medical_record` VALUES (128, 211, '宋雨', '女', 25, '13800138016', '2001-05-03', 'AB', 101, '李医生', '2026-04-19 10:00:00', '皮疹复诊', '面部红斑丘疹明显消退，瘙痒缓解', '无特殊病史', '青霉素过敏', '面部皮疹基本消退，轻度红斑', '面部皮炎（好转）', '继续口服氯雷他定片', '[{\"medicineId\":116,\"name\":\"氯雷他定片(扬子江)\",\"specification\":\"10mg*6片\",\"dosage\":\"1片\",\"frequency\":\"每日1次\",\"days\":3}]', '[]', '注意皮肤护理，避免刺激性护肤品', 'admin', '2026-04-19 10:30:00', 'admin', '2026-04-19 10:30:00', '复诊');
INSERT INTO `clinic_medical_record` VALUES (129, 111, '宋雨', 'female', 24, '13800138016', '2001-05-03', 'AB', 1, 'admin', '2026-04-01 18:39:00', '1', '1', '无', '青霉素过敏', '1', '1', '1', '[{\"medicineId\":\"100\",\"name\":\"复方感冒灵颗粒(白云山)\",\"dosage\":\"1\",\"frequency\":\"1\",\"days\":\"1\"},{\"medicineId\":\"\",\"name\":\"包药\",\"dosage\":\"2片\",\"frequency\":\"每日3次\",\"days\":\"4\"},{\"medicineId\":\"104,111\",\"name\":\"[包药] 维C银翘片(贵州百灵)（贵州百灵企业集团制药股份有限公司）×3片 + 维生素C片(华中药业)（华中药业股份有限公司）×1片\",\"dosage\":\"1\",\"frequency\":\"1\",\"days\":\"\"}]', '[]', '', 'admin', '2026-04-01 18:10:33', 'admin', '2026-04-01 18:40:59', NULL);
INSERT INTO `clinic_medical_record` VALUES (130, 100, '赵明', NULL, NULL, '13800138005', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '[{\"isPackMedicine\":1,\"packDetails\":[{\"medicineId\":100,\"name\":\"复方感冒灵颗粒\",\"quantity\":1}]}]', NULL, NULL, 'admin', '2026-04-01 18:53:14', '', NULL, NULL);
INSERT INTO `clinic_medical_record` VALUES (131, 101, '钱红', 'female', 33, '13800138006', '1992-07-22', 'B', NULL, '李医生', NULL, '12', '12', '无特殊病史', '海鲜过敏', '2', '12', '2', '[{\"name\":\"包药\",\"dosage\":\"2片\",\"frequency\":\"每日3次\",\"days\":\"\",\"isPackMedicine\":1,\"packItems\":[{\"medicineId\":104,\"name\":\"维C银翘片(贵州百灵)（贵州百灵企业集团制药股份有限公司）\",\"specification\":\"12片*2板\",\"quantity\":1,\"batchId\":105,\"batchNumber\":\"B2027E001\"},{\"medicineId\":111,\"name\":\"维生素C片(华中药业)（华中药业股份有限公司）\",\"specification\":\"0.1g*100片\",\"quantity\":1,\"batchId\":133,\"batchNumber\":\"BL20271230001\"}]},{\"medicineId\":\"109\",\"name\":\"左氧氟沙星片(第一三共)（第一三共制药(上海)有限公司）\",\"specification\":\"0.5g*6片\",\"dosage\":\"1\",\"frequency\":\"1\",\"days\":\"1\",\"isPackMedicine\":0}]', NULL, '', 'admin', '2026-04-03 00:29:35', '', NULL, NULL);
INSERT INTO `clinic_medical_record` VALUES (132, 111, '包药', 'female', 24, '13800138000', '2001-05-03', 'AB', 101, '李医生', '2026-04-03 00:48:00', '111', '111', '无', '青霉素过敏', '11', '11', '11', '[{\"medicineId\":\"111,104\",\"name\":\"[包药] 维生素C片(华中药业)（华中药业股份有限公司）×1片 + 维C银翘片(贵州百灵)（贵州百灵企业集团制药股份有限公司）×1片\",\"dosage\":\"1\",\"frequency\":\"1\",\"days\":\"1\",\"isPackMedicine\":1,\"packDetails\":[{\"medicineId\":\"111\",\"name\":\"维生素C片(华中药业)（华中药业股份有限公司）\",\"quantity\":1,\"batchId\":\"133\",\"batchNumber\":\"BL20271230001\"},{\"medicineId\":\"104\",\"name\":\"维C银翘片(贵州百灵)（贵州百灵企业集团制药股份有限公司）\",\"quantity\":1,\"batchId\":\"105\",\"batchNumber\":\"B2027E001\"}]},{\"medicineId\":\"173\",\"name\":\"维生素C注射液(华中药业)（华中药业股份有限公司）\",\"dosage\":\"1\",\"frequency\":\"1\",\"days\":\"1\"}]', '[]', '11', '13800138002', '2026-04-03 00:49:26', '', NULL, NULL);

-- ----------------------------
-- Table structure for clinic_medicine
-- ----------------------------
DROP TABLE IF EXISTS `clinic_medicine`;
CREATE TABLE `clinic_medicine`  (
  `medicine_id` bigint NOT NULL AUTO_INCREMENT COMMENT '药品ID',
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '药品名称',
  `specification` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '规格',
  `dosage_form` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '剂型',
  `form` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '形式',
  `manufacturer` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生产厂家',
  `expiry_date` date NULL DEFAULT NULL COMMENT '有效期',
  `price` decimal(10, 2) NULL DEFAULT NULL COMMENT '价格',
  `stock` int NULL DEFAULT 0 COMMENT '库存数量',
  `warning_stock` int NULL DEFAULT 10 COMMENT '预警库存',
  `warning_threshold` int NULL DEFAULT 10 COMMENT '预警阈值',
  `min_stock` int NULL DEFAULT 10 COMMENT '最小库存',
  `unit` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '单位',
  `pharmacology` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '药理作用',
  `indications` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '适应症',
  `dosage` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '用法用量',
  `side_effects` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '不良反应',
  `storage` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '储存条件',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'active' COMMENT '状态：active, inactive',
  `is_prescription` tinyint(1) NULL DEFAULT 0 COMMENT '是否处方药',
  `category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '药品分类',
  `location` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '存放位置',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`medicine_id`) USING BTREE,
  INDEX `idx_name`(`name`) USING BTREE,
  INDEX `idx_status`(`status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 222 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '药品信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of clinic_medicine
-- ----------------------------
INSERT INTO `clinic_medicine` VALUES (100, '复方感冒灵颗粒(白云山)（广州白云山制药总厂）', '10g*9袋', '颗粒剂', '', '广州白云山制药总厂', '2026-06-15', 15.80, 299, 75, 38, 38, '盒', '中西药复方制剂，金银花、五指柑、野菊花、三叉苦、南板蓝根、岗梅等中药成分具有清热解毒功效；对乙酰氨基酚、马来酸氯苯那敏能缓解感冒症状。', '用于风热感冒之发热、微恶风寒、鼻塞流涕、咽喉肿痛等症。', '开水冲服，一次1袋，一日3次', '可见困倦、嗜睡、口渴、虚弱感；偶见皮疹、瘙痒、食欲不振、恶心等。', '密封，置阴凉干燥处（不超过20℃）。', 'active', 0, '内服药', 'A-01', 'admin', '2026-04-01 17:23:23', '诊所管理员', '2026-04-03 01:30:42', '常用感冒药');
INSERT INTO `clinic_medicine` VALUES (101, '感冒灵颗粒(999)（华润三九医药股份有限公司）', '10g*9袋', '颗粒剂', '内服', '华润三九医药股份有限公司', '2027-05-20', 12.50, 350, 88, 44, 44, '盒', '中西药复方制剂，含三叉苦、金盏开、四季青等中药成分，以及对乙酰氨基酚、马来酸氯苯那敏、咖啡因等西药成分，具有解热镇痛作用。', '用于感冒引起的头痛、发热、鼻塞、流涕、咽喉痛等症状。', '开水冲服，一次1袋，一日3次。', '可见困倦、嗜睡、口渴、虚弱感；偶见皮疹、瘙痒等过敏反应。', '密封，置阴凉干燥处（不超过20℃）。', 'active', 0, '内服药', 'A-02', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '常用感冒药');
INSERT INTO `clinic_medicine` VALUES (102, '连花清瘟胶囊(以岭)（石家庄以岭药业股份有限公司）', '0.35g*24粒', '胶囊剂', '内服', '石家庄以岭药业股份有限公司', '2027-08-10', 23.50, 280, 70, 35, 35, '盒', '主要成分包括金银花、连翘、麻黄、杏仁、石膏、板蓝根、鱼腥草等，具有清热解毒、宣肺泄热功效。现代药理研究表明其具有抗菌、抗病毒、解热、镇咳祛痰作用。', '用于治疗流行性感冒属热毒袭肺证，症见发热或高热、恶寒、肌肉酸痛、鼻塞流涕、咳嗽、头痛、咽干咽痛等。', '口服，一次4粒，一日3次。', '偶见胃肠道不适，如恶心、腹泻等；罕见皮疹、瘙痒等过敏反应。', '密封，置阴凉干燥处。', 'active', 0, '内服药', 'A-03', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '流感用药');
INSERT INTO `clinic_medicine` VALUES (103, '板蓝根颗粒(香雪)（香雪制药股份有限公司）', '10g*20袋', '颗粒剂', '内服', '香雪制药股份有限公司', '2027-04-25', 18.90, 400, 100, 50, 50, '盒', '主要成分为板蓝根，具有清热解毒、凉血利咽功效。现代药理研究表明其具有抗菌、抗病毒、增强免疫力作用。', '用于肺胃热盛所致的咽喉肿痛、口咽干燥；急性扁桃体炎、腮腺炎见上述证候者。', '开水冲服，一次5-10g，一日3-4次。', '偶见胃肠道不适，罕见皮疹等过敏反应。', '密封，置阴凉干燥处。', 'active', 0, '内服药', 'A-04', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '常用清热药');
INSERT INTO `clinic_medicine` VALUES (104, '维C银翘片(贵州百灵)（贵州百灵企业集团制药股份有限公司）', '12片*2板', '片剂', '内服', '贵州百灵企业集团制药股份有限公司', '2027-03-15', 8.50, 449, 113, 57, 57, '盒', '中西药复方制剂，含金银花、连翘、维生素C等中药成分，以及对乙酰氨基酚、马来酸氯苯那敏等西药成分，具有解热镇痛、抗过敏作用。', '用于风热感冒引起的发热、头痛、咳嗽、口干、咽喉疼痛。', '口服，一次2片，一日3次。', '可见困倦、嗜睡、口渴；偶见皮疹、瘙痒等过敏反应。', '密封，置干燥处。', 'active', 0, '内服药', 'A-05', 'admin', '2026-04-01 17:23:23', '若依', '2026-04-01 18:54:00', '常用感冒药');
INSERT INTO `clinic_medicine` VALUES (105, '阿莫西林胶囊(联邦制药)（珠海联邦制药股份有限公司）', '0.25g*24粒', '胶囊剂', '内服', '珠海联邦制药股份有限公司', '2027-06-25', 18.50, 500, 125, 63, 63, '盒', '青霉素类抗生素，通过抑制细菌细胞壁合成发挥杀菌作用。对革兰氏阳性菌和部分革兰氏阴性菌有抗菌活性。', '用于敏感菌引起的呼吸道感染、泌尿生殖道感染、皮肤软组织感染、急性单纯性淋病等。', '口服，成人一次0.5g，每6-8小时一次；儿童按体重一次6.7-13.3mg/kg，每8小时一次。', '常见过敏反应如皮疹、瘙痒、荨麻疹；恶心、腹泻等胃肠道反应；严重者可致过敏性休克。', '遮光，密封，在干燥处保存。', 'active', 1, '内服药', 'B-01', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '抗生素');
INSERT INTO `clinic_medicine` VALUES (106, '头孢克肟分散片(石药集团)（石药集团中诺药业(石家庄)有限公司）', '0.1g*6片', '片剂', '内服', '石药集团中诺药业(石家庄)有限公司', '2027-07-15', 28.80, 320, 80, 40, 40, '盒', '第三代头孢菌素类抗生素，通过抑制细菌细胞壁合成发挥杀菌作用。对多种革兰氏阳性菌和革兰氏阴性菌有抗菌活性。', '用于敏感菌引起的支气管炎、肺炎、胆囊炎、尿路感染、中耳炎、鼻窦炎等。', '口服，成人一次0.1g，一日2次；儿童按体重一次1.5-3mg/kg，一日2次。', '常见皮疹、瘙痒等过敏反应；恶心、腹泻等胃肠道反应；偶见肝功能异常、血液系统改变。', '遮光，密封，在干燥处保存。', 'active', 1, '内服药', 'B-02', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '抗生素');
INSERT INTO `clinic_medicine` VALUES (107, '罗红霉素分散片(西南药业)（西南药业股份有限公司）', '0.15g*12片', '片剂', '内服', '西南药业股份有限公司', '2027-08-20', 21.30, 290, 73, 37, 37, '盒', '大环内酯类抗生素，通过抑制细菌蛋白质合成发挥抑菌作用。对多种革兰氏阳性菌、部分革兰氏阴性菌及支原体、衣原体有抗菌活性。', '用于敏感菌引起的咽炎、扁桃体炎、鼻窦炎、急性支气管炎、肺炎、皮肤软组织感染、淋病等。', '口服，成人一次0.15g，一日2次；儿童按体重一次2.5-5mg/kg，一日2次。', '常见恶心、呕吐、腹痛、腹泻等胃肠道反应；偶见皮疹、瘙痒等过敏反应；罕见肝功能异常。', '密封，在干燥处保存。', 'active', 1, '内服药', 'B-03', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '抗生素');
INSERT INTO `clinic_medicine` VALUES (108, '阿奇霉素片(辉瑞)（辉瑞制药有限公司）', '0.25g*6片', '片剂', '内服', '辉瑞制药有限公司', '2027-09-10', 35.60, 200, 50, 25, 25, '盒', '大环内酯类抗生素，通过抑制细菌蛋白质合成发挥抑菌作用。对多种革兰氏阳性菌、部分革兰氏阴性菌及支原体、衣原体有抗菌活性。', '用于敏感菌引起的社区获得性肺炎、盆腔炎、宫颈炎、非淋菌性尿道炎等。', '口服，成人一次0.25g，一日1次，或一次0.5g，一日1次。', '常见恶心、呕吐、腹痛、腹泻等胃肠道反应；偶见皮疹、瘙痒等过敏反应；罕见肝功能异常、QT间期延长。', '密封，在干燥处保存。', 'active', 1, '内服药', 'B-04', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '抗生素');
INSERT INTO `clinic_medicine` VALUES (109, '左氧氟沙星片(第一三共)（第一三共制药(上海)有限公司）', '0.5g*6片', '片剂', '内服', '第一三共制药(上海)有限公司', '2027-05-25', 24.90, 310, 78, 39, 39, '盒', '氟喹诺酮类抗菌药，通过抑制细菌DNA旋转酶和拓扑异构酶IV发挥杀菌作用。对多种革兰氏阳性菌和革兰氏阴性菌有抗菌活性。', '用于敏感菌引起的呼吸道感染、泌尿生殖道感染、消化道感染、骨关节感染、皮肤软组织感染等。', '口服，成人一次0.5g，一日1次。', '常见恶心、呕吐、腹痛、腹泻等胃肠道反应；头晕、头痛、失眠等神经系统反应；偶见皮疹、瘙痒等过敏反应；罕见肌腱炎、QT间期延长。', '遮光，密封，在干燥处保存。', 'active', 1, '内服药', 'B-05', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '抗生素');
INSERT INTO `clinic_medicine` VALUES (110, '甲硝唑片(石药集团)（石药集团中诺药业(石家庄)有限公司）', '0.2g*100片', '片剂', '内服', '石药集团中诺药业(石家庄)有限公司', '2027-05-15', 6.50, 500, 125, 63, 63, '瓶', '硝基咪唑类抗厌氧菌药，具有抗厌氧菌作用，对脆弱拟杆菌、梭形杆菌等厌氧菌有较强抗菌活性。', '用于治疗厌氧菌感染，如腹腔感染、盆腔感染、肺脓肿、脑膜炎、败血症等；也用于预防术后厌氧菌感染。', '口服，成人一次0.2-0.4g，一日3次。', '常见恶心、呕吐、腹痛、腹泻等胃肠道反应；口中金属味；偶见皮疹、瘙痒等过敏反应；长期大剂量使用可致神经系统毒性。', '遮光，密封，在干燥处保存。', 'active', 1, '内服药', 'B-06', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '抗生素');
INSERT INTO `clinic_medicine` VALUES (111, '维生素C片(华中药业)（华中药业股份有限公司）', '0.1g*100片', '片剂', '内服', '华中药业股份有限公司', '2027-12-30', 5.20, 500, 125, 63, 63, '瓶', '维生素类药物，参与机体氧化还原反应和多种代谢过程，具有抗氧化作用。', '用于预防和治疗维生素C缺乏症，如坏血病；也可用于补充维生素C，如急慢性传染病、紫癜等。', '口服，成人一次50-100mg，一日2-3次。', '过量服用可引起恶心、呕吐、腹泻、皮疹等；长期大量服用可引起肾结石。', '遮光，密封，在干燥处保存。', 'active', 0, '内服药', 'C-01', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '维生素');
INSERT INTO `clinic_medicine` VALUES (112, '复合维生素B片(汤臣倍健)（汤臣倍健股份有限公司）', '100片', '片剂', '内服', '汤臣倍健股份有限公司', '2027-11-15', 28.50, 380, 95, 48, 48, '瓶', 'B族维生素复合制剂，参与机体糖、脂肪、蛋白质代谢，维持机体正常生理功能。', '用于预防和治疗B族维生素缺乏症，如脚气病、糙皮病、营养不良等。', '口服，成人一次1-3片，一日3次。', '偶见皮肤潮红、瘙痒等过敏反应；尿液呈黄色为正常现象。', '遮光，密封，在干燥处保存。', 'active', 0, '内服药', 'C-02', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '维生素');
INSERT INTO `clinic_medicine` VALUES (113, '蒙脱石散(博福-益普生)（博福-益普生(天津)制药有限公司）', '3g*10袋', '其他', '内服', '博福-益普生(天津)制药有限公司', '2027-05-12', 26.30, 380, 95, 48, 48, '盒', '消化道黏膜保护剂，具有层纹状结构和非均匀性电荷分布，能吸附消化道内的病毒、细菌及其毒素。', '用于急慢性腹泻，如急慢性腹泻、肠易激综合征、结肠炎、胃炎等。', '口服，成人一次1袋，一日2-3次，将本品倒入温开水50ml中服用。', '可见便秘、粪便量减少等；偶见恶心、腹胀、腹痛等。', '密封，在干燥处保存。', 'active', 0, '内服药', 'D-01', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '消化药');
INSERT INTO `clinic_medicine` VALUES (114, '奥美拉唑肠溶胶囊(阿斯利康)（阿斯利康制药有限公司）', '20mg*14粒', '胶囊剂', '内服', '阿斯利康制药有限公司', '2027-06-22', 42.50, 280, 70, 35, 35, '盒', '质子泵抑制剂，通过抑制胃壁细胞H+/K+-ATP酶活性，减少胃酸分泌。具有强效抑酸作用。', '用于胃溃疡、十二指肠溃疡、应激性溃疡、反流性食管炎、卓-艾综合征等。', '口服，成人一次20mg，一日1-2次。', '常见头痛、腹泻、恶心、呕吐、便秘等；偶见皮疹、瘙痒等过敏反应；罕见肝功能异常、血液系统改变。', '遮光，密封，在干燥处保存。', 'active', 1, '内服药', 'D-02', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '胃药');
INSERT INTO `clinic_medicine` VALUES (115, '复方丹参滴丸(天士力)（天士力医药集团股份有限公司）', '27mg*180粒', '其他', '内服', '天士力医药集团股份有限公司', '2027-06-15', 29.80, 320, 80, 40, 40, '瓶', '活血化瘀类中成药，主要成分为丹参、三七、冰片，具有活血化瘀、理气止痛功效。现代药理研究表明其能扩张冠状动脉、改善心肌缺血。', '用于气滞血瘀所致的胸痹，症见胸闷、心前区刺痛；冠心病心绞痛见上述证候者。', '口服或舌下含服，一次10丸，一日3次。', '偶见胃肠道不适，如恶心、腹痛等；罕见皮疹、瘙痒等过敏反应。', '密封，置阴凉干燥处。', 'active', 0, '内服药', 'E-01', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '心脑血管');
INSERT INTO `clinic_medicine` VALUES (116, '氯雷他定片(扬子江)（扬子江药业集团有限公司）', '10mg*6片', '片剂', '内服', '扬子江药业集团有限公司', '2027-04-20', 18.90, 280, 70, 35, 35, '盒', '抗组胺药，通过选择性阻断外周H1受体，缓解过敏症状。', '用于过敏性鼻炎、荨麻疹、湿疹、皮炎、皮肤瘙痒等过敏症状。', '口服，成人一次10mg，一日1次。', '常见乏力、头痛、嗜睡、口干、胃肠道不适等；偶见皮疹、瘙痒等过敏反应。', '密封，在干燥处保存。', 'active', 0, '内服药', 'F-01', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '抗过敏药');
INSERT INTO `clinic_medicine` VALUES (117, '云南白药气雾剂(云南白药)（云南白药集团股份有限公司）', '50g+30g', '喷雾剂', '外用', '云南白药集团股份有限公司', '2027-12-31', 35.00, 150, 38, 19, 19, '盒', '活血化瘀、消肿止痛类中成药，用于跌打损伤、瘀血肿痛。', '用于跌打损伤、瘀血肿痛、肌肉酸痛、风湿痹痛等。', '外用，喷于伤患处，一日3-5次。', '罕见皮疹、瘙痒等过敏反应；偶见局部刺痛。', '密封，置阴凉干燥处。', 'active', 0, '外用药', 'G-01', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '外用药');
INSERT INTO `clinic_medicine` VALUES (118, '碘伏消毒液(利康)（北京利康 sanitizer 有限公司）', '100ml', '外用剂', '外用', '北京利康 sanitizer 有限公司', '2027-05-31', 12.00, 200, 50, 25, 25, '瓶', '消毒防腐药，碘与表面活性剂结合，具有广谱杀菌作用，能杀灭细菌、病毒、真菌、阿米巴原虫等。', '用于皮肤消毒、黏膜消毒、伤口清洁；也用于治疗皮肤黏膜真菌感染。', '外用，局部涂擦，一日1-2次。', '偶见皮肤刺激如烧灼感、红肿等；罕见皮疹、瘙痒等过敏反应。', '遮光，密封，在凉暗处保存。', 'active', 0, '外用药', 'G-02', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '消毒药');
INSERT INTO `clinic_medicine` VALUES (119, '布洛芬缓释胶囊(中美史克)（中美天津史克制药有限公司）', '0.3g*20粒', '胶囊剂', '内服', '中美天津史克制药有限公司', '2027-06-30', 28.00, 200, 50, 25, 25, '盒', '非甾体抗炎药，通过抑制环氧合酶，减少前列腺素合成，具有解热、镇痛、抗炎作用。', '用于缓解轻至中度疼痛如头痛、关节痛、偏头痛、牙痛、肌肉痛、神经痛、痛经；也用于普通感冒或流行性感冒引起的发热。', '口服，成人一次1粒，一日2次（早晚各一次）。', '常见恶心、呕吐、腹胀、腹泻、便秘等胃肠道反应；可见头晕、头痛、嗜睡等；偶见皮疹、瘙痒等过敏反应。', '密封，在干燥处保存。', 'active', 0, '内服药', 'H-01', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '止痛药');
INSERT INTO `clinic_medicine` VALUES (120, '氨咖黄敏胶囊(感冒灵)（华润三九医药股份有限公司）', '12粒', '胶囊剂', '内服', '华润三九医药股份有限公司', '2027-03-15', 8.00, 400, 100, 50, 50, '盒', '中西药复方制剂，含对乙酰氨基酚、咖啡因、马来酸氯苯那敏、人工牛黄等，具有解热镇痛作用。', '用于缓解普通感冒或流行性感冒引起的发热、头痛、鼻塞、咽痛等症状。', '口服，成人一次1-2粒，一日3次。', '可见困倦、嗜睡、口渴、虚弱感；偶见皮疹、瘙痒等过敏反应。', '密封，在干燥处保存。', 'active', 0, '内服药', 'A-06', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '感冒药');
INSERT INTO `clinic_medicine` VALUES (121, '蒙脱石散(博福-益普生)（博福-益普生(天津)制药有限公司）', '3g*10袋', '颗粒剂', '内服', '博福-益普生(天津)制药有限公司', '2027-05-12', 26.30, 300, 75, 38, 38, '盒', '消化道黏膜保护剂，具有层纹状结构和非均匀性电荷分布，能吸附消化道内的病毒、细菌及其毒素。', '用于急慢性腹泻、肠易激综合征、结肠炎等。', '口服，成人一次1袋，一日2-3次。', '可见便秘、粪便量减少等。', '密封，在干燥处保存。', 'active', 0, '内服药', 'A-01-01', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (122, '阿莫西林克拉维酸钾颗粒(联邦制药)（珠海联邦制药股份有限公司）', '0.15625g*9袋', '颗粒剂', '内服', '珠海联邦制药股份有限公司', '2027-06-15', 32.50, 250, 63, 32, 32, '盒', '青霉素类抗生素复方制剂，具有广谱抗菌作用。', '用于敏感菌引起的呼吸道感染、泌尿系统感染等。', '口服，按体重计算，一日3次。', '常见胃肠道反应、过敏反应等。', '遮光，密封，在干燥处保存。', 'active', 1, '内服药', 'A-01-02', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (123, '头孢克肟颗粒(石药集团)（石药集团中诺药业(石家庄)有限公司）', '50mg*6袋', '颗粒剂', '内服', '石药集团中诺药业(石家庄)有限公司', '2027-07-20', 28.80, 280, 70, 35, 35, '盒', '第三代头孢菌素类抗生素，对多种细菌有抗菌活性。', '用于敏感菌引起的支气管炎、肺炎、中耳炎等。', '口服，按体重计算，一日2次。', '常见皮疹、腹泻等。', '遮光，密封，在干燥处保存。', 'active', 1, '内服药', 'A-01-03', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (124, '阿奇霉素颗粒(辉瑞)（辉瑞制药有限公司）', '0.1g*6袋', '颗粒剂', '内服', '辉瑞制药有限公司', '2027-09-15', 38.50, 200, 50, 25, 25, '盒', '大环内酯类抗生素，抑制细菌蛋白质合成。', '用于敏感菌引起的呼吸道感染、皮肤软组织感染等。', '口服，一日1次，连服3天。', '常见胃肠道反应等。', '密封，在干燥处保存。', 'active', 1, '内服药', 'A-01-04', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (125, '布洛芬颗粒(扬子江)（扬子江药业集团有限公司）', '0.2g*12袋', '颗粒剂', '内服', '扬子江药业集团有限公司', '2027-06-30', 18.90, 350, 88, 44, 44, '盒', '非甾体抗炎药，具有解热、镇痛、抗炎作用。', '用于缓解轻至中度疼痛，如头痛、关节痛等。', '口服，按体重计算，一日3次。', '可见胃肠道不适等。', '密封，在干燥处保存。', 'active', 0, '内服药', 'A-01-05', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (126, '对乙酰氨基酚颗粒(华中药业)（华中药业股份有限公司）', '0.1g*12袋', '颗粒剂', '内服', '华中药业股份有限公司', '2027-12-01', 8.50, 400, 100, 50, 50, '盒', '解热镇痛药，通过抑制前列腺素合成发挥解热镇痛作用。', '用于普通感冒或流行性感冒引起的发热。', '口服，按体重计算，一日3-4次。', '偶见恶心、呕吐等。', '密封，在干燥处保存。', 'active', 0, '内服药', 'A-01-06', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (127, '柴黄颗粒(康弘)（四川康弘制药有限公司）', '4g*12袋', '颗粒剂', '内服', '四川康弘制药有限公司', '2027-08-15', 24.50, 260, 65, 33, 33, '盒', '中成药，具有清热解毒功效。', '用于感冒引起的发热、头痛、咽喉肿痛等。', '口服，一次1袋，一日3次。', '偶见胃肠道不适。', '密封，置阴凉干燥处。', 'active', 0, '内服药', 'A-01-07', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (128, '清开灵颗粒(济民可信)（济民可信集团有限公司）', '3g*10袋', '颗粒剂', '内服', '济民可信集团有限公司', '2027-05-25', 22.80, 290, 73, 37, 37, '盒', '中成药，具有清热解毒、镇静安神功效。', '用于外感风热所致感冒、咽喉肿痛等。', '口服，一次1-2袋，一日2-3次。', '偶见腹泻等。', '密封，置阴凉干燥处。', 'active', 0, '内服药', 'A-01-08', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (129, '板蓝根颗粒(香雪)（香雪制药股份有限公司）', '10g*20袋', '颗粒剂', '内服', '香雪制药股份有限公司', '2027-04-25', 18.90, 380, 95, 48, 48, '盒', '清热解毒中成药，具有抗病毒作用。', '用于肺胃热盛所致的咽喉肿痛、口咽干燥。', '开水冲服，一次5-10g，一日3-4次。', '偶见胃肠道不适。', '密封，置阴凉干燥处。', 'active', 0, '内服药', 'A-01-09', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (130, '金银花颗粒(本草纲目)（江西本草纲目药业有限公司）', '10g*12袋', '颗粒剂', '内服', '江西本草纲目药业有限公司', '2027-06-10', 16.50, 270, 68, 34, 34, '盒', '清热解毒中成药。', '用于发热口渴、咽喉肿痛等。', '口服，一次1袋，一日3次。', '偶见皮疹等。', '密封，置阴凉干燥处。', 'active', 0, '内服药', 'A-01-10', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (131, '蒲地蓝消炎颗粒(济川)（济川药业集团有限公司）', '5g*9袋', '颗粒剂', '内服', '济川药业集团有限公司', '2027-07-25', 26.80, 240, 60, 30, 30, '盒', '清热解毒中成药，具有抗炎消肿作用。', '用于疖肿、腮腺炎、咽炎、扁桃体炎等。', '口服，一次1袋，一日3次。', '偶见腹泻等。', '密封，置阴凉干燥处。', 'active', 0, '内服药', 'A-01-11', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (132, '夏桑菊颗粒(香雪)（香雪制药股份有限公司）', '10g*20袋', '颗粒剂', '内服', '香雪制药股份有限公司', '2027-08-30', 19.50, 320, 80, 40, 40, '盒', '清热解毒中成药，具有清肝明目、疏风散热作用。', '用于风热感冒、头晕目眩、耳鸣等。', '口服，一次1-2袋，一日3次。', '偶见胃肠道不适。', '密封，置阴凉干燥处。', 'active', 0, '内服药', 'A-01-12', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (133, '玄宁颗粒(以岭)（石家庄以岭药业股份有限公司）', '5g*10袋', '颗粒剂', '内服', '石家庄以岭药业股份有限公司', '2027-09-20', 35.60, 180, 45, 23, 23, '盒', '中成药，具有活血通络作用。', '用于瘀血阻络所致的头晕头痛等。', '口服，一次1袋，一日2次。', '偶见皮疹等。', '密封，置阴凉干燥处。', 'active', 0, '内服药', 'A-01-13', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (134, '小柴胡颗粒(云丰)（云南白药集团股份有限公司）', '10g*9袋', '颗粒剂', '内服', '云南白药集团股份有限公司', '2027-05-15', 15.80, 340, 85, 43, 43, '盒', '中成药，具有解表散热、疏肝和胃功效。', '用于寒热往来、心烦喜吐、口苦咽干等。', '口服，一次1-2袋，一日3次。', '偶见皮疹等。', '密封，置阴凉干燥处。', 'active', 0, '内服药', 'A-01-14', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (135, '999感冒灵颗粒(华润三九)（华润三九医药股份有限公司）', '10g*9袋', '颗粒剂', '内服', '华润三九医药股份有限公司', '2027-05-20', 12.50, 450, 113, 57, 57, '盒', '中西药复方制剂，具有解热镇痛作用。', '用于感冒引起的头痛、发热、鼻塞等症状。', '开水冲服，一次1袋，一日3次。', '可见困倦、嗜睡等。', '密封，置阴凉干燥处。', 'active', 0, '内服药', 'A-01-15', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (136, '头孢氨苄胶囊(华北制药)（华北制药股份有限公司）', '0.25g*24粒', '胶囊剂', '内服', '华北制药股份有限公司', '2027-06-25', 22.80, 320, 80, 40, 40, '盒', '第一代头孢菌素类抗生素，抑制细菌细胞壁合成。', '用于敏感菌引起的呼吸道感染、泌尿系统感染等。', '口服，成人一次0.25-0.5g，每6小时一次。', '常见胃肠道反应、过敏反应等。', '遮光，密封，在干燥处保存。', 'active', 1, '内服药', 'B-02-01', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (137, '头孢拉定胶囊(中美华东)（中美华东制药有限公司）', '0.25g*24粒', '胶囊剂', '内服', '中美华东制药有限公司', '2027-07-10', 21.50, 280, 70, 35, 35, '盒', '第一代头孢菌素类抗生素，具有抗菌作用。', '用于敏感菌引起的呼吸道感染、皮肤软组织感染等。', '口服，成人一次0.25-0.5g，每6小时一次。', '常见胃肠道反应等。', '遮光，密封，在干燥处保存。', 'active', 1, '内服药', 'B-02-02', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (138, '克拉霉素片(雅培)（雅培制药有限公司）', '0.25g*6片', '胶囊剂', '内服', '雅培制药有限公司', '2027-08-20', 38.90, 220, 55, 28, 28, '盒', '大环内酯类抗生素，抑制细菌蛋白质合成。', '用于敏感菌引起的呼吸道感染、皮肤软组织感染等。', '口服，成人一次0.25g，一日2次。', '常见胃肠道反应等。', '密封，在干燥处保存。', 'active', 1, '内服药', 'B-02-03', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (139, '诺氟沙星胶囊(浙江医药)（浙江医药股份有限公司）', '0.1g*24粒', '胶囊剂', '内服', '浙江医药股份有限公司', '2027-05-15', 12.80, 350, 88, 44, 44, '盒', '氟喹诺酮类抗菌药，抑制细菌DNA旋转酶。', '用于敏感菌引起的尿路感染、肠道感染等。', '口服，成人一次0.2-0.4g，一日2次。', '常见胃肠道反应、头晕等。', '遮光，密封，在干燥处保存。', 'active', 1, '内服药', 'B-02-04', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (140, '盐酸多西环素胶囊(恒瑞)（江苏恒瑞医药股份有限公司）', '0.1g*12粒', '胶囊剂', '内服', '江苏恒瑞医药股份有限公司', '2027-09-10', 25.60, 200, 50, 25, 25, '盒', '四环素类抗生素，具有广谱抗菌作用。', '用于敏感菌引起的呼吸道感染、泌尿系统感染等。', '口服，成人一次0.1g，一日2次。', '常见胃肠道反应、光敏反应等。', '遮光，密封，在干燥处保存。', 'active', 1, '内服药', 'B-02-05', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (141, '左氧氟沙星胶囊(第一三共)（第一三共制药(上海)有限公司）', '0.5g*6粒', '胶囊剂', '内服', '第一三共制药(上海)有限公司', '2027-05-25', 28.50, 260, 65, 33, 33, '盒', '氟喹诺酮类抗菌药，具有广谱抗菌作用。', '用于敏感菌引起的呼吸道感染、泌尿系统感染等。', '口服，成人一次0.5g，一日1次。', '常见恶心、呕吐、腹泻等。', '遮光，密封，在干燥处保存。', 'active', 1, '内服药', 'B-02-06', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (142, '奥美拉唑肠溶胶囊(阿斯利康)（阿斯利康制药有限公司）', '20mg*14粒', '胶囊剂', '内服', '阿斯利康制药有限公司', '2027-06-22', 42.50, 300, 75, 38, 38, '盒', '质子泵抑制剂，抑制胃酸分泌。', '用于胃溃疡、十二指肠溃疡、反流性食管炎等。', '口服，成人一次20mg，一日1-2次。', '常见头痛、腹泻、恶心等。', '遮光，密封，在干燥处保存。', 'active', 1, '内服药', 'B-02-07', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (143, '埃索美拉唑胶囊(阿斯利康)（阿斯利康制药有限公司）', '20mg*7粒', '胶囊剂', '内服', '阿斯利康制药有限公司', '2027-07-18', 56.80, 180, 45, 23, 23, '盒', '质子泵抑制剂，具有强效抑酸作用。', '用于胃食管反流病、消化性溃疡等。', '口服，成人一次20mg，一日1次。', '常见头痛、腹泻、恶心等。', '遮光，密封，在干燥处保存。', 'active', 1, '内服药', 'B-02-08', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (144, '铝碳酸镁片(拜耳)（拜耳医药保健有限公司）', '0.5g*20片', '胶囊剂', '内服', '拜耳医药保健有限公司', '2027-06-30', 28.90, 250, 63, 32, 32, '盒', '抗酸药，中和胃酸，保护胃黏膜。', '用于胃溃疡、十二指肠溃疡、胃酸过多等。', '口服，成人一次0.5-1g，一日3次。', '偶见便秘等。', '密封，在干燥处保存。', 'active', 0, '内服药', 'B-02-09', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (145, '双歧杆菌三联活菌胶囊(晋城海斯)（晋城海斯制药有限公司）', '0.21g*24粒', '胶囊剂', '内服', '晋城海斯制药有限公司', '2027-05-10', 45.60, 200, 50, 25, 25, '盒', '益生菌制剂，调节肠道菌群平衡。', '用于肠道菌群失调引起的腹泻、便秘等。', '口服，成人一次2-4粒，一日2次。', '未见明显不良反应。', '冷藏（2-8℃）保存。', 'active', 0, '内服药', 'B-02-10', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (146, '枯草杆菌二联活菌颗粒(妈咪爱)（北京韩美药品有限公司）', '1g*10袋', '胶囊剂', '内服', '北京韩美药品有限公司', '2027-04-20', 38.50, 220, 55, 28, 28, '盒', '益生菌制剂，调节肠道菌群。', '用于消化不良、食欲不振等。', '口服，2岁以下儿童一次1袋，一日2次。', '未见明显不良反应。', '冷藏（2-8℃）保存。', 'active', 0, '内服药', 'B-02-11', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (147, '盐酸雷尼替丁胶囊(赛诺菲)（赛诺菲(北京)制药有限公司）', '0.15g*30粒', '胶囊剂', '内服', '赛诺菲(北京)制药有限公司', '2027-08-25', 18.90, 280, 70, 35, 35, '盒', 'H2受体拮抗剂，抑制胃酸分泌。', '用于胃溃疡、十二指肠溃疡、应激性溃疡等。', '口服，成人一次0.15g，一日2次。', '常见头晕、嗜睡等。', '遮光，密封，在干燥处保存。', 'active', 0, '内服药', 'B-02-12', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (148, '法莫替丁胶囊(亚宝)（亚宝药业集团股份有限公司）', '20mg*12粒', '胶囊剂', '内服', '亚宝药业集团股份有限公司', '2027-07-15', 15.60, 320, 80, 40, 40, '盒', 'H2受体拮抗剂，抑制胃酸分泌。', '用于胃溃疡、十二指肠溃疡等。', '口服，成人一次20mg，一日2次。', '常见头晕、头痛等。', '遮光，密封，在干燥处保存。', 'active', 0, '内服药', 'B-02-13', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (149, '泮托拉唑钠肠溶胶囊(武田)（武田药品工业株式会社）', '40mg*7粒', '胶囊剂', '内服', '武田药品工业株式会社', '2027-09-20', 52.30, 160, 40, 20, 20, '盒', '质子泵抑制剂，强效抑酸。', '用于胃溃疡、十二指肠溃疡、反流性食管炎等。', '口服，成人一次40mg，一日1次。', '常见头痛、腹泻等。', '遮光，密封，在干燥处保存。', 'active', 1, '内服药', 'B-02-14', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (150, '兰索拉唑胶囊(天津武田)（天津武田药品工业株式会社）', '30mg*7粒', '胶囊剂', '内服', '天津武田药品工业株式会社', '2027-08-18', 48.90, 180, 45, 23, 23, '盒', '质子泵抑制剂，抑制胃酸分泌。', '用于胃溃疡、十二指肠溃疡、反流性食管炎等。', '口服，成人一次30mg，一日1次。', '常见腹泻、恶心等。', '遮光，密封，在干燥处保存。', 'active', 1, '内服药', 'B-02-15', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (151, '硝苯地平缓释片(拜耳)（拜耳医药保健有限公司）', '20mg*30片', '片剂', '内服', '拜耳医药保健有限公司', '2027-06-30', 38.50, 280, 70, 35, 35, '盒', '钙通道阻滞剂，具有扩张血管作用。', '用于高血压、心绞痛等。', '口服，成人一次20mg，一日2次。', '常见踝部水肿、头痛等。', '遮光，密封，在干燥处保存。', 'active', 1, '内服药', 'C-03-01', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (152, '贝那普利片(诺华)（诺华制药有限公司）', '10mg*7片', '片剂', '内服', '诺华制药有限公司', '2027-07-25', 45.80, 200, 50, 25, 25, '盒', '血管紧张素转换酶抑制剂，具有降压作用。', '用于高血压、心力衰竭等。', '口服，成人一次10mg，一日1次。', '常见咳嗽、头晕等。', '遮光，密封，在干燥处保存。', 'active', 1, '内服药', 'C-03-02', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (153, '阿托伐他汀钙片(辉瑞)（辉瑞制药有限公司）', '20mg*7片', '片剂', '内服', '辉瑞制药有限公司', '2027-08-15', 58.60, 220, 55, 28, 28, '盒', '他汀类降脂药，抑制胆固醇合成。', '用于高胆固醇血症、冠心病等。', '口服，成人一次20mg，一日1次。', '常见肌肉疼痛、转氨酶升高等。', '遮光，密封，在干燥处保存。', 'active', 1, '内服药', 'C-03-03', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (154, '氯吡格雷片(赛诺菲)（赛诺菲(北京)制药有限公司）', '75mg*7片', '片剂', '内服', '赛诺菲(北京)制药有限公司', '2027-09-10', 65.80, 180, 45, 23, 23, '盒', '抗血小板药，抑制血小板聚集。', '用于预防动脉粥样硬化血栓形成等。', '口服，成人一次75mg，一日1次。', '常见出血风险增加等。', '遮光，密封，在干燥处保存。', 'active', 1, '内服药', 'C-03-04', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (155, '辛伐他汀片(默沙东)（默沙东制药有限公司）', '20mg*7片', '片剂', '内服', '默沙东制药有限公司', '2027-06-20', 42.30, 240, 60, 30, 30, '盒', '他汀类降脂药，降低胆固醇。', '用于高胆固醇血症等。', '口服，成人一次20mg，一日1次。', '常见肌肉疼痛、转氨酶升高等。', '遮光，密封，在干燥处保存。', 'active', 1, '内服药', 'C-03-05', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (156, '苯磺酸氨氯地平片(络活喜)（辉瑞制药有限公司）', '5mg*7片', '片剂', '内服', '辉瑞制药有限公司', '2027-07-30', 35.90, 300, 75, 38, 38, '盒', '钙通道阻滞剂，具有长效降压作用。', '用于高血压、心绞痛等。', '口服，成人一次5mg，一日1次。', '常见踝部水肿、头痛等。', '遮光，密封，在干燥处保存。', 'active', 1, '内服药', 'C-03-06', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (157, '盐酸氟桂利嗪胶囊(西安杨森)（西安杨森制药有限公司）', '5mg*20片', '片剂', '内服', '西安杨森制药有限公司', '2027-05-15', 22.80, 260, 65, 33, 33, '盒', '钙通道阻滞剂，改善脑循环。', '用于脑供血不足、椎动脉缺血等。', '口服，成人一次5-10mg，一日1次。', '常见嗜睡、疲惫感等。', '遮光，密封，在干燥处保存。', 'active', 0, '内服药', 'C-03-07', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (158, '甲钴胺片(卫材)（卫材(中国)药业有限公司）', '0.5mg*20片', '片剂', '内服', '卫材(中国)药业有限公司', '2027-08-20', 28.50, 320, 80, 40, 40, '盒', '维生素类药，促进神经细胞代谢。', '用于周围神经病、糖尿病神经病变等。', '口服，成人一次0.5mg，一日3次。', '偶见食欲不振、恶心等。', '密封，在干燥处保存。', 'active', 0, '内服药', 'C-03-08', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (159, '维生素B1片(华中药业)（华中药业股份有限公司）', '10mg*100片', '片剂', '内服', '华中药业股份有限公司', '2027-12-30', 5.20, 500, 125, 63, 63, '瓶', '维生素类药，维持正常糖代谢。', '用于预防和治疗维生素B1缺乏症。', '口服，成人一次10mg，一日3次。', '未见明显不良反应。', '遮光，密封，在干燥处保存。', 'active', 0, '内服药', 'C-03-09', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (160, '维生素B2片(华中药业)（华中药业股份有限公司）', '5mg*100片', '片剂', '内服', '华中药业股份有限公司', '2027-12-30', 4.80, 500, 125, 63, 63, '瓶', '维生素类药，参与糖、蛋白质代谢。', '用于预防和治疗维生素B2缺乏症。', '口服，成人一次5-10mg，一日3次。', '尿液呈黄色为正常现象。', '遮光，密封，在干燥处保存。', 'active', 0, '内服药', 'C-03-10', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (161, '维生素B6片(华中药业)（华中药业股份有限公司）', '10mg*100片', '片剂', '内服', '华中药业股份有限公司', '2027-12-30', 4.50, 500, 125, 63, 63, '瓶', '维生素类药，参与氨基酸代谢。', '用于预防和治疗维生素B6缺乏症。', '口服，成人一次10-20mg，一日3次。', '长期大量使用可致周围神经炎等。', '遮光，密封，在干燥处保存。', 'active', 0, '内服药', 'C-03-11', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (162, '维生素AD软胶囊(青岛双鲸)（青岛双鲸药业股份有限公司）', '100粒', '片剂', '内服', '青岛双鲸药业股份有限公司', '2027-11-15', 28.00, 350, 88, 44, 44, '盒', '维生素类药，维持正常生长发育。', '用于预防和治疗维生素A及D缺乏症。', '口服，成人一次1粒，一日1次。', '偶见胃肠道不适等。', '遮光，密封，在阴凉干燥处保存。', 'active', 0, '内服药', 'C-03-12', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (163, '维生素E软胶囊(浙江医药)（浙江医药股份有限公司）', '100mg*30粒', '片剂', '内服', '浙江医药股份有限公司', '2027-10-20', 22.50, 380, 95, 48, 48, '盒', '维生素类药，具有抗氧化作用。', '用于心脑血管疾病、习惯性流产等。', '口服，成人一次1粒，一日1次。', '偶见恶心、呕吐等。', '遮光，密封，在阴凉干燥处保存。', 'active', 0, '内服药', 'C-03-13', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (164, '钙尔奇D片(惠氏)（惠氏制药有限公司）', '600mg*60片', '片剂', '内服', '惠氏制药有限公司', '2027-09-15', 68.00, 280, 70, 35, 35, '盒', '钙补充剂，预防和治疗骨质疏松。', '用于钙缺乏症、妊娠期补钙等。', '口服，成人一次1片，一日1-2次。', '可见嗳气、便秘等。', '密封，在干燥处保存。', 'active', 0, '内服药', 'C-03-14', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (165, '复合维生素B片(汤臣倍健)（汤臣倍健股份有限公司）', '100片', '片剂', '内服', '汤臣倍健股份有限公司', '2027-11-15', 28.50, 400, 100, 50, 50, '瓶', 'B族维生素复合制剂，参与代谢。', '用于预防和治疗B族维生素缺乏症。', '口服，成人一次1-3片，一日3次。', '尿液呈黄色为正常现象。', '遮光，密封，在干燥处保存。', 'active', 0, '内服药', 'C-03-15', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (166, '0.9%氯化钠注射液250ml(科伦)（四川科伦药业股份有限公司）', '250ml:2.25g', '注射剂', '注射', '四川科伦药业股份有限公司', '2027-06-15', 3.50, 800, 200, 100, 100, '瓶', '电解质补充药，调节水电解质平衡。', '用于各种原因所致的低血容量休克等。', '静脉滴注，用量视病情而定。', '可见注射部位疼痛等。', '遮光，密封保存。', 'active', 0, '注射用药', 'D-04-01', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (167, '5%葡萄糖注射液250ml(华润双鹤)（华润双鹤药业股份有限公司）', '250ml:12.5g', '注射剂', '注射', '华润双鹤药业股份有限公司', '2027-07-20', 3.20, 750, 188, 94, 94, '瓶', '补液药，提供能量和水分。', '用于补充能量和体液等。', '静脉滴注，用量视病情而定。', '可见注射部位疼痛等。', '遮光，密封保存。', 'active', 0, '注射用药', 'D-04-02', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (168, '葡萄糖氯化钠注射液250ml(华润双鹤)（华润双鹤药业股份有限公司）', '250ml', '注射剂', '注射', '华润双鹤药业股份有限公司', '2027-08-10', 3.80, 700, 175, 88, 88, '瓶', '补液药，补充能量和电解质。', '用于脱水症、术后补液等。', '静脉滴注，用量视病情而定。', '可见注射部位疼痛等。', '遮光，密封保存。', 'active', 0, '注射用药', 'D-04-03', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (169, '地塞米松磷酸钠注射液(仙琚制药)（浙江仙琚制药股份有限公司）', '1ml:5mg', '注射剂', '注射', '浙江仙琚制药股份有限公司', '2027-05-25', 2.80, 500, 125, 63, 63, '支', '糖皮质激素类药，具有抗炎、免疫抑制作用。', '用于严重细菌感染、严重过敏反应等。', '肌注或静注，用量视病情而定。', '可见注射部位疼痛等。', '遮光，密封保存。', 'active', 1, '注射用药', 'D-04-04', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (170, '注射用头孢曲松钠(罗氏)（上海罗氏制药有限公司）', '1g', '注射剂', '注射', '上海罗氏制药有限公司', '2027-09-15', 58.50, 300, 75, 38, 38, '支', '第三代头孢菌素类抗生素，具有广谱抗菌作用。', '用于敏感菌引起的呼吸道感染、泌尿系统感染等。', '肌注或静注，一日1-2g。', '常见皮疹、瘙痒等过敏反应。', '遮光，密封保存。', 'active', 1, '注射用药', 'D-04-05', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (171, '注射用阿莫西林钠(华北制药)（华北制药股份有限公司）', '1g', '注射剂', '注射', '华北制药股份有限公司', '2027-06-30', 28.80, 350, 88, 44, 44, '支', '青霉素类抗生素，具有抗菌作用。', '用于敏感菌引起的呼吸道感染、泌尿系统感染等。', '肌注或静注，一日3-4g。', '常见过敏反应等。', '遮光，密封，在干燥处保存。', 'active', 1, '注射用药', 'D-04-06', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (172, '硫酸阿米卡星注射液(苏州第一制药)（苏州第一制药有限公司）', '2ml:0.2g', '注射剂', '注射', '苏州第一制药有限公司', '2027-05-15', 4.50, 400, 100, 50, 50, '支', '氨基糖苷类抗生素，具有广谱抗菌作用。', '用于敏感菌引起的呼吸道感染、泌尿系统感染等。', '肌注或静注，一日0.5-1g。', '可见耳毒性、肾毒性等。', '遮光，密封保存。', 'active', 1, '注射用药', 'D-04-07', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (173, '维生素C注射液(华中药业)（华中药业股份有限公司）', '5ml:1g', '注射剂', '注射', '华中药业股份有限公司', '2027-12-01', 3.20, 450, 113, 57, 57, '支', '维生素类药，参与机体氧化还原反应。', '用于坏血病、急慢性中毒等。', '肌注或静注，一日1-2g。', '可见注射部位疼痛等。', '遮光，密封保存。', 'active', 0, '注射用药', 'D-04-08', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (174, '氨茶碱注射液(天津力生)（天津力生制药有限公司）', '2ml:0.25g', '注射剂', '注射', '天津力生制药有限公司', '2027-06-20', 3.80, 380, 95, 48, 48, '支', '平喘药，扩张支气管平滑肌。', '用于支气管哮喘、喘息性支气管炎等。', '静注或静滴，用量视病情而定。', '可见恶心、呕吐等。', '遮光，密封保存。', 'active', 1, '注射用药', 'D-04-09', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (175, '西咪替丁注射液(西南药业)（西南药业股份有限公司）', '2ml:0.2g', '注射剂', '注射', '西南药业股份有限公司', '2027-07-15', 4.20, 350, 88, 44, 44, '支', 'H2受体拮抗剂，抑制胃酸分泌。', '用于消化性溃疡出血、应激状态等。', '肌注或静注，用量视病情而定。', '可见头晕、嗜睡等。', '遮光，密封保存。', 'active', 0, '注射用药', 'D-04-10', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (176, '硫酸庆大霉素注射液(古田)（古田药业有限公司）', '2ml:8万单位', '注射剂', '注射', '古田药业有限公司', '2027-05-30', 2.50, 420, 105, 53, 53, '支', '氨基糖苷类抗生素，具有广谱抗菌作用。', '用于敏感菌引起的肠道感染、尿路感染等。', '肌注，一日8万-16万单位。', '可见耳毒性、肾毒性等。', '遮光，密封保存。', 'active', 1, '注射用药', 'D-04-11', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (177, '克林霉素磷酸酯注射液(华北制药)（华北制药股份有限公司）', '2ml:0.3g', '注射剂', '注射', '华北制药股份有限公司', '2027-08-25', 8.80, 280, 70, 35, 35, '支', '林可霉素类抗生素，具有抗菌作用。', '用于敏感菌引起的呼吸道感染、骨髓炎等。', '肌注或静注，一日0.6-1.2g。', '可见注射部位疼痛等。', '遮光，密封保存。', 'active', 1, '注射用药', 'D-04-12', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (178, '乳酸左氧氟沙星注射液(浙江医药)（浙江医药股份有限公司）', '100ml:0.3g', '注射剂', '注射', '浙江医药股份有限公司', '2027-09-10', 28.50, 220, 55, 28, 28, '瓶', '氟喹诺酮类抗菌药，具有广谱抗菌作用。', '用于敏感菌引起的呼吸道感染、泌尿系统感染等。', '静滴，一日0.3-0.6g。', '可见恶心、呕吐等。', '遮光，密封保存。', 'active', 1, '注射用药', 'D-04-13', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (179, '甲硝唑注射液(四川科伦)（四川科伦药业股份有限公司）', '100ml:0.5g', '注射剂', '注射', '四川科伦药业股份有限公司', '2027-06-15', 5.80, 380, 95, 48, 48, '瓶', '抗厌氧菌药，具有抗厌氧菌作用。', '用于厌氧菌感染、术后预防用药等。', '静滴，一日1-2g。', '可见恶心、呕吐等。', '遮光，密封保存。', 'active', 1, '注射用药', 'D-04-14', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (180, '清开灵注射液(济民可信)（济民可信集团有限公司）', '2ml', '注射剂', '注射', '济民可信集团有限公司', '2027-04-20', 8.50, 300, 75, 38, 38, '支', '中成药，具有清热解毒功效。', '用于热病、神昏、中风偏瘫等。', '肌注或静滴，用量视病情而定。', '可见皮疹、瘙痒等过敏反应。', '遮光，密封保存。', 'active', 1, '注射用药', 'D-04-15', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (181, '云南白药气雾剂(云南白药)（云南白药集团股份有限公司）', '50g+30g', '喷雾剂', '外用', '云南白药集团股份有限公司', '2027-12-31', 35.00, 200, 50, 25, 25, '盒', '活血化瘀中成药，具有消肿止痛作用。', '用于跌打损伤、瘀血肿痛、肌肉酸痛等。', '外用，喷于伤患处，一日3-5次。', '罕见皮疹、瘙痒等过敏反应。', '密封，置阴凉干燥处。', 'active', 0, '外用药', 'E-05-01', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (182, '布地奈德鼻喷雾剂(阿斯利康)（阿斯利康制药有限公司）', '32μg*120喷', '喷雾剂', '外用', '阿斯利康制药有限公司', '2027-06-30', 68.50, 150, 38, 19, 19, '盒', '糖皮质激素类药，具有抗炎、抗过敏作用。', '用于过敏性鼻炎、血管运动性鼻炎等。', '喷鼻，成人一次1喷，一日2次。', '可能出现鼻出血、局部刺激等。', '遮光，密封，在30℃以下保存。', 'active', 1, '外用药', 'E-05-02', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (183, '丙酸氟替卡松鼻喷雾剂(葛兰素史克)（葛兰素史克制药有限公司）', '50μg*60喷', '喷雾剂', '外用', '葛兰素史克制药有限公司', '2027-07-20', 72.80, 120, 30, 15, 15, '盒', '糖皮质激素类药，具有局部抗炎作用。', '用于季节性过敏性鼻炎、常年性过敏性鼻炎等。', '喷鼻，成人一次2喷，一日1次。', '可能出现鼻出血、局部刺激等。', '遮光，密封，在30℃以下保存。', 'active', 1, '外用药', 'E-05-03', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (184, '沙丁胺醇气雾剂(葛兰素史克)（葛兰素史克制药有限公司）', '100μg*200掀', '喷雾剂', '外用', '葛兰素史克制药有限公司', '2027-08-15', 38.90, 180, 45, 23, 23, '盒', 'β2受体激动剂，扩张支气管平滑肌。', '用于缓解支气管哮喘、喘息性支气管炎的气道阻塞症状。', '吸入，成人一次1-2掀，必要时使用。', '可见心悸、手抖等。', '遮光，密封，在干燥处保存。', 'active', 1, '外用药', 'E-05-04', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (185, '异丙托溴铵气雾剂(勃林格殷格翰)（勃林格殷格翰制药有限公司）', '20μg*200掀', '喷雾剂', '外用', '勃林格殷格翰制药有限公司', '2027-09-10', 42.50, 140, 35, 18, 18, '盒', '抗胆碱药，扩张支气管平滑肌。', '用于慢性阻塞性肺疾病、支气管哮喘等。', '吸入，成人一次2掀，一日3-4次。', '可见口干、咳嗽等。', '遮光，密封，在干燥处保存。', 'active', 1, '外用药', 'E-05-05', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (186, '开喉剑喷雾剂(贵州三力)（贵州三力制药股份有限公司）', '20ml', '喷雾剂', '外用', '贵州三力制药股份有限公司', '2027-05-25', 28.80, 220, 55, 28, 28, '盒', '中成药，具有清热解毒、消肿止痛作用。', '用于口腔溃疡、牙龈肿痛、咽喉肿痛等。', '喷于患处，一日数次。', '罕见皮疹等过敏反应。', '密封，置阴凉干燥处。', 'active', 0, '外用药', 'E-05-06', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (187, '利巴韦林气雾剂(山东鲁抗)（山东鲁抗医药股份有限公司）', '10mg*200掀', '喷雾剂', '外用', '山东鲁抗医药股份有限公司', '2027-06-18', 22.50, 160, 40, 20, 20, '盒', '抗病毒药，抑制病毒复制。', '用于病毒性上呼吸道感染、口腔疱疹等。', '喷于患处，一日数次。', '罕见皮疹等过敏反应。', '遮光，密封，在干燥处保存。', 'active', 0, '外用药', 'E-05-07', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (188, '口腔炎喷雾剂(天津药业)（天津药业集团有限公司）', '20ml', '喷雾剂', '外用', '天津药业集团有限公司', '2027-07-30', 25.60, 200, 50, 25, 25, '盒', '中成药，具有清热解毒、消炎止痛作用。', '用于口腔炎、口腔溃疡、咽喉炎等。', '喷于患处，一日3-4次。', '罕见皮疹等过敏反应。', '密封，置阴凉干燥处。', 'active', 0, '外用药', 'E-05-08', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (189, '硝酸甘油气雾剂(北京益民)（北京益民药业有限公司）', '0.5mg*200掀', '喷雾剂', '外用', '北京益民药业有限公司', '2027-08-20', 45.80, 100, 25, 13, 13, '盒', '血管扩张药，缓解心绞痛。', '用于预防和缓解心绞痛症状。', '舌下喷雾，成人一次1掀。', '可见头痛、眩晕等。', '遮光，密封，在阴凉处保存。', 'active', 1, '外用药', 'E-05-09', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (190, '呋喃西林溶液气雾剂(新乡康达)（新乡康达药业有限公司）', '100ml', '喷雾剂', '外用', '新乡康达药业有限公司', '2027-05-15', 18.90, 180, 45, 23, 23, '盒', '消毒防腐药，具有抗菌作用。', '用于创面、伤口的清洁消毒。', '外用，喷于患处。', '可见局部刺激等。', '遮光，密封，在阴凉处保存。', 'active', 0, '外用药', 'E-05-10', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (191, '抗病毒口服液(香雪)（香雪制药股份有限公司）', '10ml*12支', '口服液', '内服', '香雪制药股份有限公司', '2027-05-20', 24.80, 320, 80, 40, 40, '盒', '中成药，具有清热祛湿、凉血解毒功效。', '用于风热感冒、流感所致的发热、微恶风寒等。', '口服，成人一次10ml，一日2-3次。', '偶见恶心、腹泻等。', '密封，置阴凉干燥处。', 'active', 0, '内服药', 'F-06-01', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (192, '双黄连口服液(哈药集团)（哈药集团制药六厂）', '10ml*12支', '口服液', '内服', '哈药集团制药六厂', '2027-04-25', 26.50, 350, 88, 44, 44, '盒', '中成药，具有清热解毒功效。', '用于外感风热所致的感冒、发热、咳嗽等。', '口服，成人一次20ml，一日3次。', '偶见恶心、腹泻等。', '密封，置阴凉干燥处。', 'active', 0, '内服药', 'F-06-02', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (193, '京都念慈菴川贝枇杷膏(京都念慈菴)（京都念慈菴制药厂有限公司）', '300ml', '口服液', '内服', '京都念慈菴制药厂有限公司', '2027-09-15', 45.80, 280, 70, 35, 35, '盒', '中成药，具有润肺化痰、止咳平喘功效。', '用于风热感冒、支气管炎等所致的咳嗽痰多等。', '口服，成人一次15ml，一日3次。', '可见恶心、胃部不适等。', '密封，置阴凉干燥处。', 'active', 0, '内服药', 'F-06-03', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (194, '急支糖浆(太极)（太极集团四川绵阳制药有限公司）', '100ml', '口服液', '内服', '太极集团四川绵阳制药有限公司', '2027-06-30', 18.50, 300, 75, 38, 38, '瓶', '中成药，具有清热化痰、宣肺止咳功效。', '用于外感风热所致的咳嗽、发热等。', '口服，成人一次20-30ml，一日3次。', '可见恶心、胃部不适等。', '密封，置阴凉干燥处。', 'active', 0, '内服药', 'F-06-04', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (195, '强力枇杷露(神奇)（神奇制药有限公司）', '100ml', '口服液', '内服', '神奇制药有限公司', '2027-05-15', 16.80, 340, 85, 43, 43, '瓶', '中成药，具有养阴敛肺、止咳祛痰功效。', '用于咳嗽、支气管炎等。', '口服，成人一次15ml，一日3次。', '可见恶心等。', '密封，置阴凉干燥处。', 'active', 0, '内服药', 'F-06-05', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (196, '复方甘草口服溶液(太极)（太极集团四川绵阳制药有限公司）', '100ml', '口服液', '内服', '太极集团四川绵阳制药有限公司', '2027-07-20', 8.50, 400, 100, 50, 50, '瓶', '中成药，具有镇咳祛痰作用。', '用于上呼吸道感染、支气管炎等所致的咳嗽。', '口服，成人一次5-10ml，一日3次。', '可见恶心、呕吐等。', '密封，置阴凉干燥处。', 'active', 0, '内服药', 'F-06-06', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (197, '藿香正气水(太极)（太极集团四川绵阳制药有限公司）', '10ml*10支', '口服液', '内服', '太极集团四川绵阳制药有限公司', '2027-06-25', 12.80, 380, 95, 48, 48, '盒', '中成药，具有解表化湿、理气和中功效。', '用于外感风寒、内伤湿滞所致的感冒、呕吐、腹泻等。', '口服，成人一次5-10ml，一日2次。', '可见恶心、呕吐等。', '密封，置阴凉干燥处。', 'active', 0, '内服药', 'F-06-07', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (198, '补中益气口服液(北京同仁堂)（北京同仁堂股份有限公司）', '10ml*12支', '口服液', '内服', '北京同仁堂股份有限公司', '2027-08-30', 32.50, 260, 65, 33, 33, '盒', '中成药，具有补中益气、升阳举陷功效。', '用于脾胃虚弱、中气下陷所致的体倦乏力等。', '口服，成人一次10ml，一日2-3次。', '可见恶心、头痛等。', '密封，置阴凉干燥处。', 'active', 0, '内服药', 'F-06-08', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (199, '生脉饮口服液(北京同仁堂)（北京同仁堂股份有限公司）', '10ml*12支', '口服液', '内服', '北京同仁堂股份有限公司', '2027-09-10', 28.80, 240, 60, 30, 30, '盒', '中成药，具有益气复脉、养阴生津功效。', '用于气阴两亏、心悸气短、脉微自汗等。', '口服，成人一次10ml，一日3次。', '未见明显不良反应。', '密封，置阴凉干燥处。', 'active', 0, '内服药', 'F-06-09', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (200, '盐酸氨溴索口服溶液(勃林格殷格翰)（勃林格殷格翰制药有限公司）', '100ml:0.6g', '口服液', '内服', '勃林格殷格翰制药有限公司', '2027-07-15', 35.60, 220, 55, 28, 28, '瓶', '祛痰药，稀释痰液，促进排痰。', '用于急慢性支气管炎、支气管哮喘等。', '口服，成人一次10ml，一日3次。', '可见恶心、胃部不适等。', '遮光，密封，在干燥处保存。', 'active', 0, '内服药', 'F-06-10', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (201, '碘伏消毒液(利尔康)（山东利尔康医疗科技股份有限公司）', '100ml', '外用剂', '外用', '山东利尔康医疗科技股份有限公司', '2027-05-31', 12.00, 400, 100, 50, 50, '瓶', '消毒防腐药，具有广谱杀菌作用。', '用于皮肤消毒、黏膜消毒、伤口清洁。', '外用，局部涂擦，一日1-2次。', '偶见皮肤刺激等。', '遮光，密封，在凉暗处保存。', 'active', 0, '外用药', 'G-07-01', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (202, '酒精消毒液(利尔康)（山东利尔康医疗科技股份有限公司）', '100ml:75%', '外用剂', '外用', '山东利尔康医疗科技股份有限公司', '2027-12-31', 8.50, 500, 125, 63, 63, '瓶', '消毒防腐药，用于皮肤消毒。', '用于注射、穿刺部位的皮肤消毒。', '外用，局部涂擦。', '偶见皮肤刺激等。', '遮光，密封，在阴凉处保存。', 'active', 0, '外用药', 'G-07-02', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (203, '红霉素软膏(马应龙)（马应龙药业集团股份有限公司）', '10g:1%', '外用剂', '外用', '马应龙药业集团股份有限公司', '2027-06-20', 8.00, 450, 113, 57, 57, '支', '大环内酯类抗生素，用于皮肤感染。', '用于脓疱疮等化脓性皮肤病、轻度烧伤等。', '外用，涂于患处，一日2次。', '可见局部刺激、过敏反应等。', '密封，在阴凉处保存。', 'active', 0, '外用药', 'G-07-03', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (204, '莫匹罗星软膏(中美史克)（中美天津史克制药有限公司）', '5g:2%', '外用剂', '外用', '中美天津史克制药有限公司', '2027-07-15', 28.50, 280, 70, 35, 35, '支', '抗菌药，用于皮肤感染。', '用于毛囊炎、疖肿、汗腺炎等原发性皮肤感染。', '外用，涂于患处，一日2-3次。', '可见局部刺激、过敏反应等。', '密封，在阴凉处保存。', 'active', 0, '外用药', 'G-07-04', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (205, '硝酸咪康唑乳膏(西安杨森)（西安杨森制药有限公司）', '20g:2%', '外用剂', '外用', '西安杨森制药有限公司', '2027-08-25', 22.80, 320, 80, 40, 40, '支', '抗真菌药，用于皮肤真菌感染。', '用于体癣、股癣、手足癣、花斑癣等。', '外用，涂于患处，一日2次。', '可见局部刺激、过敏反应等。', '密封，在阴凉处保存。', 'active', 0, '外用药', 'G-07-05', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (206, '酮康唑乳膏(西安杨森)（西安杨森制药有限公司）', '10g:2%', '外用剂', '外用', '西安杨森制药有限公司', '2027-09-10', 18.90, 300, 75, 38, 38, '支', '抗真菌药，用于皮肤真菌感染。', '用于体癣、股癣、手足癣等。', '外用，涂于患处，一日2次。', '可见局部刺激、过敏反应等。', '密封，在阴凉处保存。', 'active', 0, '外用药', 'G-07-06', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (207, '999皮炎平软膏(华润三九)（华润三九医药股份有限公司）', '20g:0.075%', '外用剂', '外用', '华润三九医药股份有限公司', '2027-06-30', 15.80, 380, 95, 48, 48, '支', '糖皮质激素类药，具有抗炎抗过敏作用。', '用于局限性瘙痒症、神经性皮炎、接触性皮炎等。', '外用，涂于患处，一日2-3次。', '可见毛囊炎、皮肤萎缩等。', '密封，在阴凉处保存。', 'active', 0, '外用药', 'G-07-07', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (208, '炉甘石洗剂(江苏联环)（江苏联环药业股份有限公司）', '100ml', '外用剂', '外用', '江苏联环药业股份有限公司', '2027-05-25', 12.50, 350, 88, 44, 44, '瓶', '收敛保护药，具有止痒作用。', '用于急性瘙痒性皮肤病，如湿疹、痱子等。', '外用，摇匀后涂于患处，一日2-3次。', '可见局部刺激等。', '密封，在阴凉处保存。', 'active', 0, '外用药', 'G-07-08', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (209, '过氧化氢溶液(广东恒健)（广东恒健制药有限公司）', '100ml:3%', '外用剂', '外用', '广东恒健制药有限公司', '2027-12-15', 6.50, 400, 100, 50, 50, '瓶', '消毒防腐药，用于创面清洁。', '用于化脓性外耳道炎、扁桃体炎等。', '外用，清洗创面，一日数次。', '可见局部刺激等。', '遮光，密封，在阴凉处保存。', 'active', 0, '外用药', 'G-07-09', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (210, '苯扎氯铵溶液(广东恒健)（广东恒健制药有限公司）', '50ml:0.1%', '外用剂', '外用', '广东恒健制药有限公司', '2027-06-20', 9.80, 380, 95, 48, 48, '瓶', '消毒防腐药，具有杀菌作用。', '用于皮肤黏膜消毒、创面冲洗等。', '外用，稀释后使用。', '偶见局部刺激等。', '遮光，密封，在阴凉处保存。', 'active', 0, '外用药', 'G-07-10', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (211, '复方氨林巴比妥注射液(西南药业)（西南药业股份有限公司）', '2ml', '其他', '注射', '西南药业股份有限公司', '2027-05-15', 3.50, 450, 113, 57, 57, '支', '解热镇痛药，用于发热、疼痛。', '用于发热、头痛、关节痛、痛经等。', '肌注，一次2ml。', '可见注射部位疼痛等。', '遮光，密封保存。', 'active', 0, '注射用药', 'H-08-01', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (212, '复方甘油灌肠剂(上海运佳)（上海运佳黄浦制药有限公司）', '110ml', '其他', '外用', '上海运佳黄浦制药有限公司', '2027-06-30', 8.50, 280, 70, 35, 35, '瓶', '润滑性泻药，用于便秘。', '用于各种便秘、X线检查前的肠道清洁。', '直肠给药，一次110ml。', '可见局部刺激等。', '密封，在阴凉处保存。', 'active', 0, '内服药', 'H-08-02', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (213, '开塞露(含甘油)(北京渤海)（北京渤海制药有限公司）', '20ml', '其他', '外用', '北京渤海制药有限公司', '2027-05-20', 3.00, 500, 125, 63, 63, '支', '润滑性泻药，用于便秘。', '用于大便干结、排便困难等。', '直肠给药，一次1支。', '可见局部刺激等。', '密封，在30℃以下保存。', 'active', 0, '内服药', 'H-08-03', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (214, '生理盐水鼻腔喷雾器(舒德尔玛)（希腊Laboratoires Giffard）', '50ml', '其他', '外用', '希腊Laboratoires Giffard', '2027-08-15', 45.00, 180, 45, 23, 23, '盒', '等渗海水鼻腔喷雾，用于鼻腔清洁。', '用于鼻腔干燥、鼻炎、感冒时的鼻腔清洁。', '喷鼻，一次2-3喷，一日数次。', '未见明显不良反应。', '遮光，密封，在阴凉处保存。', 'active', 0, '外用药', 'H-08-04', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (215, '羧甲司坦口服溶液(广州一品红)（广州一品红制药有限公司）', '10ml:0.5g', '其他', '内服', '广州一品红制药有限公司', '2027-07-25', 22.80, 240, 60, 30, 30, '盒', '祛痰药，溶解黏痰。', '用于慢性支气管炎、支气管哮喘等所致的痰液黏稠。', '口服，成人一次10ml，一日3次。', '可见恶心、胃部不适等。', '密封，在干燥处保存。', 'active', 0, '内服药', 'H-08-05', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (216, '乙酰半胱氨酸泡腾片(浙江金华)（浙江金华康恩贝生物制药有限公司）', '0.6g*6片', '其他', '内服', '浙江金华康恩贝生物制药有限公司', '2027-09-20', 28.50, 200, 50, 25, 25, '盒', '祛痰药，溶解黏痰。', '用于急慢性支气管炎、支气管扩张等所致的痰液黏稠。', '口服，一次0.6g，一日1-2次。', '可见恶心、呕吐等。', '密封，在干燥处保存。', 'active', 0, '内服药', 'H-08-06', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (217, '硫酸沙丁胺醇片(葛兰素史克)（葛兰素史克制药有限公司）', '2mg*100片', '其他', '内服', '葛兰素史克制药有限公司', '2027-08-30', 18.90, 280, 70, 35, 35, '瓶', 'β2受体激动剂，扩张支气管。', '用于缓解支气管哮喘、喘息性支气管炎的支气管痉挛。', '口服，成人一次2-4mg，一日3-4次。', '可见心悸、手抖等。', '遮光，密封，在干燥处保存。', 'active', 1, '内服药', 'H-08-07', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (218, '茶碱缓释片(上海信谊)（上海信谊药厂有限公司）', '0.1g*24片', '其他', '内服', '上海信谊药厂有限公司', '2027-07-15', 15.60, 320, 80, 40, 40, '盒', '平喘药，松弛支气管平滑肌。', '用于支气管哮喘、喘息性支气管炎等。', '口服，成人一次0.1-0.2g，一日2次。', '可见恶心、呕吐等。', '遮光，密封，在干燥处保存。', 'active', 1, '内服药', 'H-08-08', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (219, '硫酸特布他林雾化液(阿斯利康)（阿斯利康制药有限公司）', '2ml:5mg', '其他', '注射', '阿斯利康制药有限公司', '2027-06-25', 38.80, 160, 40, 20, 20, '盒', 'β2受体激动剂，扩张支气管。', '用于支气管哮喘、COPD等。', '雾化吸入，一次1-2ml，一日2-3次。', '可见心悸、震颤等。', '遮光，密封保存。', 'active', 1, '注射用药', 'H-08-09', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (220, '噻托溴铵粉雾剂(勃林格殷格翰)（勃林格殷格翰制药有限公司）', '18μg*30粒', '其他', '内服', '勃林格殷格翰制药有限公司', '2027-09-15', 168.00, 80, 20, 10, 10, '盒', '抗胆碱药，扩张支气管。', '用于慢性阻塞性肺疾病(COPD)的维持治疗。', '吸入，一次1粒，一日1次。', '可见口干、便秘等。', '遮光，密封，在干燥处保存。', 'active', 1, '内服药', 'H-08-10', 'admin', '2026-04-01 18:04:48', 'admin', '2026-04-01 18:04:48', '');
INSERT INTO `clinic_medicine` VALUES (221, '1', '1', NULL, '其他', NULL, '2026-04-30', 1.00, 30, 10, 10, 10, NULL, '', '', '', '', '', 'active', 0, '1', NULL, 'admin', '2026-04-01 19:50:55', '若依', '2026-04-01 19:51:31', NULL);
INSERT INTO `clinic_medicine` VALUES (222, '2', '2', NULL, '其他', NULL, '2026-04-03', 2.00, 10, 10, 10, 10, '2', '2', '2', '2', '2', '22', 'active', 0, '2', '2', '13800138001', '2026-04-03 00:38:25', '若依', '2026-04-03 00:54:20', NULL);

-- ----------------------------
-- Table structure for clinic_pack_loss_record
-- ----------------------------
DROP TABLE IF EXISTS `clinic_pack_loss_record`;
CREATE TABLE `clinic_pack_loss_record`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `medicine_id` bigint NULL DEFAULT NULL COMMENT '药品ID',
  `medicine_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '药品名称',
  `loss_quantity` int NULL DEFAULT NULL COMMENT '损耗数量',
  `related_record_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '关联记录ID',
  `batch_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '批次号',
  `is_processed` int NULL DEFAULT 0 COMMENT '是否处理（0=未处理，1=已处理）',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `operator_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作员名称',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_medicine_id`(`medicine_id`) USING BTREE,
  INDEX `idx_is_processed`(`is_processed`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '包药损耗记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of clinic_pack_loss_record
-- ----------------------------
INSERT INTO `clinic_pack_loss_record` VALUES (1, 104, '维C银翘片(贵州百灵)', 1, '129', 'B2027E001', 1, '2026-04-01 18:36:34', '若依');
INSERT INTO `clinic_pack_loss_record` VALUES (2, 111, '维生素C片(华中药业)', 1, '129', 'BL20271230001', 0, '2026-04-01 18:36:34', '若依');
INSERT INTO `clinic_pack_loss_record` VALUES (3, 104, '维C银翘片(贵州百灵)（贵州百灵企业集团制药股份有限公司）', 1, '131', 'B2027E001', 0, '2026-04-03 00:55:03', '若依');
INSERT INTO `clinic_pack_loss_record` VALUES (4, 111, '维生素C片(华中药业)（华中药业股份有限公司）', 1, '131', 'BL20271230001', 0, '2026-04-03 00:55:03', '若依');

-- ----------------------------
-- Table structure for clinic_patient
-- ----------------------------
DROP TABLE IF EXISTS `clinic_patient`;
CREATE TABLE `clinic_patient`  (
  `patient_id` bigint NOT NULL AUTO_INCREMENT COMMENT '患者ID',
  `user_id` bigint NULL DEFAULT NULL COMMENT '关联用户ID',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '患者姓名',
  `gender` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '性别',
  `age` int NULL DEFAULT NULL COMMENT '年龄',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系电话',
  `birthday` date NULL DEFAULT NULL COMMENT '出生日期',
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '地址',
  `allergy_history` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '过敏史',
  `past_history` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '既往史',
  `blood_type` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '血型',
  `wechat` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '微信号',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`patient_id`) USING BTREE,
  INDEX `idx_user_id`(`user_id`) USING BTREE,
  INDEX `idx_phone`(`phone`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 112 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '患者信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of clinic_patient
-- ----------------------------
INSERT INTO `clinic_patient` VALUES (100, 200, '赵明', 'male', 40, '13800138005', '1986-03-15', 'åäº¬å¸æé³åºå»ºå½è·¯88å·', '海鲜桂敏', 'é«è¡åçå²5å¹´ï¼è§å¾æè¯', 'A', 'zhaoming8', '', 'admin', '2026-04-01 17:23:23', '13800138100', '2026-04-03 02:19:21', '慢病管理');
INSERT INTO `clinic_patient` VALUES (101, 201, '钱红', '女', 34, '13800138006', '1992-07-22', '北京市海淀区中关村大街1号', '海鲜过敏', '无特殊病史', 'B', 'qianhong92', '', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '普通患者');
INSERT INTO `clinic_patient` VALUES (102, 202, '孙伟', '男', 46, '13800138007', '1980-11-08', '北京市东城区王府井大街255号', '花粉过敏', '哮喘病史3年，季节性发作', 'O', 'sunwei80', '', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '呼吸科');
INSERT INTO `clinic_patient` VALUES (103, 203, '李静', '女', 29, '13800138008', '1997-04-02', '北京市丰台区西客站南路1号', '无', '胃炎病史', 'AB', 'lijing97', '', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '消化科');
INSERT INTO `clinic_patient` VALUES (104, 204, '周强', '男', 52, '13800138009', '1974-10-10', '北京市昌平区立汤路168号', '无', '糖尿病病史', 'A', 'zhouqiang74', '', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '慢病管理');
INSERT INTO `clinic_patient` VALUES (105, 205, '吴婷', '女', 31, '13800138010', '1995-12-01', '北京市通州区新华大街256号', '头孢过敏', '甲状腺结节', 'B', 'wuting95', '', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '复诊');
INSERT INTO `clinic_patient` VALUES (106, 206, '郑峰', '男', 38, '13800138011', '1988-01-23', '北京市顺义区新顺南大街288号', '无', '无', 'O', 'zhengfeng88', '', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '普通患者');
INSERT INTO `clinic_patient` VALUES (107, 207, '王芳', '女', 44, '13800138012', '1982-06-16', '北京市大兴区兴政街12号', '无', '偏头痛病史', 'AB', 'wangfang82', '', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '神经内科');
INSERT INTO `clinic_patient` VALUES (108, 208, '何磊', '男', 27, '13800138013', '1999-09-12', '北京市石景山区石景山路56号', '尘螨过敏', '鼻炎病史', 'A', 'helei99', '', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '过敏门诊');
INSERT INTO `clinic_patient` VALUES (109, 209, '郭敏', '女', 36, '13800138014', '1990-02-19', '北京市门头沟区新桥南大街88号', '无', '无', 'B', 'guomin90', '', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '普通患者');
INSERT INTO `clinic_patient` VALUES (110, 210, '陈旭', '男', 33, '13800138015', '1993-08-25', '北京市房山区良乡拱辰南大街1号', '无', '腰肌劳损', 'O', 'chenxu93', '', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '康复门诊');
INSERT INTO `clinic_patient` VALUES (111, 211, '宋雨', '女', 25, '13800138016', '2001-05-03', '北京市延庆区百泉街10号', '青霉素过敏', '无', 'AB', 'songyu01', '', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '普通患者');

-- ----------------------------
-- Table structure for clinic_schedule
-- ----------------------------
DROP TABLE IF EXISTS `clinic_schedule`;
CREATE TABLE `clinic_schedule`  (
  `schedule_id` bigint NOT NULL AUTO_INCREMENT COMMENT '排班ID',
  `doctor_id` bigint NOT NULL COMMENT '医生ID',
  `doctor_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '医生姓名',
  `title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '职称',
  `schedule_date` date NULL DEFAULT NULL COMMENT '排班日期',
  `start_time` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '开始时间',
  `end_time` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '结束时间',
  `total_slots` int NULL DEFAULT 20 COMMENT '总号源数',
  `booked_slots` int NULL DEFAULT 0 COMMENT '已预约数',
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'active' COMMENT '状态：active, inactive',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`schedule_id`) USING BTREE,
  INDEX `idx_doctor_id`(`doctor_id`) USING BTREE,
  INDEX `idx_schedule_date`(`schedule_date`) USING BTREE,
  INDEX `idx_status`(`status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 219 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '排班表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of clinic_schedule
-- ----------------------------
INSERT INTO `clinic_schedule` VALUES (100, 101, '李医生', '内科主治医师', '2026-04-01', '08:00', '12:00', 20, 7, 'active', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (101, 101, '李医生', '内科主治医师', '2026-04-01', '14:00', '17:30', 15, 4, 'active', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (102, 101, '李医生', '内科主治医师', '2026-04-02', '08:30', '12:00', 18, 2, 'active', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '次日门诊');
INSERT INTO `clinic_schedule` VALUES (103, 102, '王医生', '外科主治医师', '2026-04-01', '08:30', '12:00', 18, 5, 'active', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '外科门诊');
INSERT INTO `clinic_schedule` VALUES (104, 102, '王医生', '外科主治医师', '2026-04-02', '14:00', '17:30', 16, 3, 'active', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '复诊门诊');
INSERT INTO `clinic_schedule` VALUES (105, 103, '张医生', '儿科主治医师', '2026-04-01', '09:00', '12:00', 22, 7, 'active', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '儿科门诊');
INSERT INTO `clinic_schedule` VALUES (106, 103, '张医生', '儿科主治医师', '2026-04-02', '14:00', '17:30', 20, 2, 'active', 'admin', '2026-04-01 17:23:23', 'admin', '2026-04-01 17:23:23', '儿科复诊');
INSERT INTO `clinic_schedule` VALUES (107, 101, '李医生', '内科主治医师', '2026-03-31', '08:00', '12:00', 20, 18, 'active', 'admin', '2026-03-25 08:00:00', 'admin', '2026-03-25 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (108, 102, '王医生', '外科主治医师', '2026-03-31', '14:00', '18:00', 20, 15, 'active', 'admin', '2026-03-25 08:00:00', 'admin', '2026-03-25 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (109, 101, '李医生', '内科主治医师', '2026-04-01', '08:00', '12:00', 20, 20, 'active', 'admin', '2026-03-26 08:00:00', 'admin', '2026-03-26 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (110, 103, '张医生', '儿科主治医师', '2026-04-01', '14:00', '18:00', 20, 12, 'active', 'admin', '2026-03-26 08:00:00', 'admin', '2026-03-26 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (111, 102, '王医生', '外科主治医师', '2026-04-02', '08:00', '12:00', 20, 16, 'active', 'admin', '2026-03-27 08:00:00', 'admin', '2026-03-27 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (112, 101, '李医生', '内科主治医师', '2026-04-02', '14:00', '18:00', 20, 10, 'active', 'admin', '2026-03-27 08:00:00', 'admin', '2026-03-27 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (113, 103, '张医生', '儿科主治医师', '2026-04-03', '08:00', '12:00', 20, 14, 'active', 'admin', '2026-03-28 08:00:00', 'admin', '2026-03-28 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (114, 102, '王医生', '外科主治医师', '2026-04-03', '14:00', '18:00', 20, 9, 'active', 'admin', '2026-03-28 08:00:00', 'admin', '2026-03-28 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (115, 101, '李医生', '内科主治医师', '2026-04-04', '09:00', '12:00', 15, 10, 'active', 'admin', '2026-03-29 08:00:00', 'admin', '2026-03-29 08:00:00', '周末门诊');
INSERT INTO `clinic_schedule` VALUES (116, 103, '张医生', '儿科主治医师', '2026-04-05', '09:00', '12:00', 15, 12, 'active', 'admin', '2026-03-29 08:00:00', 'admin', '2026-03-29 08:00:00', '周末门诊');
INSERT INTO `clinic_schedule` VALUES (117, 101, '李医生', '内科主治医师', '2026-04-06', '08:00', '12:00', 20, 19, 'active', 'admin', '2026-03-30 08:00:00', 'admin', '2026-03-30 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (118, 102, '王医生', '外科主治医师', '2026-04-06', '14:00', '18:00', 20, 17, 'active', 'admin', '2026-03-30 08:00:00', 'admin', '2026-03-30 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (119, 103, '张医生', '儿科主治医师', '2026-04-07', '08:00', '12:00', 20, 15, 'active', 'admin', '2026-03-31 08:00:00', 'admin', '2026-03-31 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (120, 101, '李医生', '内科主治医师', '2026-04-07', '14:00', '18:00', 20, 11, 'active', 'admin', '2026-03-31 08:00:00', 'admin', '2026-03-31 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (121, 102, '王医生', '外科主治医师', '2026-04-08', '08:00', '12:00', 20, 18, 'active', 'admin', '2026-04-01 08:00:00', 'admin', '2026-04-01 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (122, 103, '张医生', '儿科主治医师', '2026-04-08', '14:00', '18:00', 20, 13, 'active', 'admin', '2026-04-01 08:00:00', 'admin', '2026-04-01 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (123, 101, '李医生', '内科主治医师', '2026-04-09', '08:00', '12:00', 20, 16, 'active', 'admin', '2026-04-02 08:00:00', 'admin', '2026-04-02 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (124, 102, '王医生', '外科主治医师', '2026-04-09', '14:00', '18:00', 20, 9, 'active', 'admin', '2026-04-02 08:00:00', 'admin', '2026-04-02 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (125, 103, '张医生', '儿科主治医师', '2026-04-10', '08:00', '12:00', 20, 20, 'active', 'admin', '2026-04-03 08:00:00', 'admin', '2026-04-03 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (126, 101, '李医生', '内科主治医师', '2026-04-10', '14:00', '18:00', 20, 14, 'active', 'admin', '2026-04-03 08:00:00', 'admin', '2026-04-03 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (127, 102, '王医生', '外科主治医师', '2026-04-11', '09:00', '12:00', 15, 8, 'active', 'admin', '2026-04-04 08:00:00', 'admin', '2026-04-04 08:00:00', '周末门诊');
INSERT INTO `clinic_schedule` VALUES (128, 101, '李医生', '内科主治医师', '2026-04-12', '09:00', '12:00', 15, 15, 'active', 'admin', '2026-04-04 08:00:00', 'admin', '2026-04-04 08:00:00', '周末门诊');
INSERT INTO `clinic_schedule` VALUES (129, 103, '张医生', '儿科主治医师', '2026-04-13', '08:00', '12:00', 20, 17, 'active', 'admin', '2026-04-06 08:00:00', 'admin', '2026-04-06 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (130, 102, '王医生', '外科主治医师', '2026-04-13', '14:00', '18:00', 20, 12, 'active', 'admin', '2026-04-06 08:00:00', 'admin', '2026-04-06 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (131, 101, '李医生', '内科主治医师', '2026-04-14', '08:00', '12:00', 20, 19, 'active', 'admin', '2026-04-07 08:00:00', 'admin', '2026-04-07 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (132, 103, '张医生', '儿科主治医师', '2026-04-14', '14:00', '18:00', 20, 16, 'active', 'admin', '2026-04-07 08:00:00', 'admin', '2026-04-07 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (133, 102, '王医生', '外科主治医师', '2026-04-15', '08:00', '12:00', 20, 14, 'active', 'admin', '2026-04-08 08:00:00', 'admin', '2026-04-08 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (134, 101, '李医生', '内科主治医师', '2026-04-15', '14:00', '18:00', 20, 18, 'active', 'admin', '2026-04-08 08:00:00', 'admin', '2026-04-08 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (135, 103, '张医生', '儿科主治医师', '2026-04-16', '08:00', '12:00', 20, 15, 'active', 'admin', '2026-04-09 08:00:00', 'admin', '2026-04-09 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (136, 102, '王医生', '外科主治医师', '2026-04-16', '14:00', '18:00', 20, 10, 'active', 'admin', '2026-04-09 08:00:00', 'admin', '2026-04-09 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (137, 101, '李医生', '内科主治医师', '2026-04-17', '08:00', '12:00', 20, 17, 'active', 'admin', '2026-04-10 08:00:00', 'admin', '2026-04-10 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (138, 103, '张医生', '儿科主治医师', '2026-04-17', '14:00', '18:00', 20, 13, 'active', 'admin', '2026-04-10 08:00:00', 'admin', '2026-04-10 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (139, 102, '王医生', '外科主治医师', '2026-04-18', '09:00', '12:00', 15, 6, 'active', 'admin', '2026-04-11 08:00:00', 'admin', '2026-04-11 08:00:00', '周末门诊');
INSERT INTO `clinic_schedule` VALUES (140, 101, '李医生', '内科主治医师', '2026-04-19', '09:00', '12:00', 15, 11, 'active', 'admin', '2026-04-11 08:00:00', 'admin', '2026-04-11 08:00:00', '周末门诊');
INSERT INTO `clinic_schedule` VALUES (141, 103, '张医生', '儿科主治医师', '2026-04-20', '08:00', '12:00', 20, 18, 'active', 'admin', '2026-04-13 08:00:00', 'admin', '2026-04-13 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (142, 102, '王医生', '外科主治医师', '2026-04-20', '14:00', '18:00', 20, 14, 'active', 'admin', '2026-04-13 08:00:00', 'admin', '2026-04-13 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (143, 101, '李医生', '内科主治医师', '2026-04-21', '08:00', '12:00', 20, 20, 'active', 'admin', '2026-04-14 08:00:00', 'admin', '2026-04-14 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (144, 103, '张医生', '儿科主治医师', '2026-04-21', '14:00', '18:00', 20, 15, 'active', 'admin', '2026-04-14 08:00:00', 'admin', '2026-04-14 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (145, 102, '王医生', '外科主治医师', '2026-04-22', '08:00', '12:00', 20, 16, 'active', 'admin', '2026-04-15 08:00:00', 'admin', '2026-04-15 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (146, 101, '李医生', '内科主治医师', '2026-04-22', '14:00', '18:00', 20, 12, 'active', 'admin', '2026-04-15 08:00:00', 'admin', '2026-04-15 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (147, 103, '张医生', '儿科主治医师', '2026-04-23', '08:00', '12:00', 20, 17, 'active', 'admin', '2026-04-16 08:00:00', 'admin', '2026-04-16 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (148, 102, '王医生', '外科主治医师', '2026-04-23', '14:00', '18:00', 20, 11, 'active', 'admin', '2026-04-16 08:00:00', 'admin', '2026-04-16 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (149, 101, '李医生', '内科主治医师', '2026-04-24', '08:00', '12:00', 20, 19, 'active', 'admin', '2026-04-17 08:00:00', 'admin', '2026-04-17 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (150, 103, '张医生', '儿科主治医师', '2026-04-24', '14:00', '18:00', 20, 14, 'active', 'admin', '2026-04-17 08:00:00', 'admin', '2026-04-17 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (151, 102, '王医生', '外科主治医师', '2026-04-25', '09:00', '12:00', 15, 9, 'active', 'admin', '2026-04-18 08:00:00', 'admin', '2026-04-18 08:00:00', '周末门诊');
INSERT INTO `clinic_schedule` VALUES (152, 101, '李医生', '内科主治医师', '2026-04-26', '09:00', '12:00', 15, 13, 'active', 'admin', '2026-04-18 08:00:00', 'admin', '2026-04-18 08:00:00', '周末门诊');
INSERT INTO `clinic_schedule` VALUES (153, 103, '张医生', '儿科主治医师', '2026-04-27', '08:00', '12:00', 20, 16, 'active', 'admin', '2026-04-20 08:00:00', 'admin', '2026-04-20 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (154, 102, '王医生', '外科主治医师', '2026-04-27', '14:00', '18:00', 20, 15, 'active', 'admin', '2026-04-20 08:00:00', 'admin', '2026-04-20 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (155, 101, '李医生', '内科主治医师', '2026-04-28', '08:00', '12:00', 20, 18, 'active', 'admin', '2026-04-21 08:00:00', 'admin', '2026-04-21 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (156, 103, '张医生', '儿科主治医师', '2026-04-28', '14:00', '18:00', 20, 12, 'active', 'admin', '2026-04-21 08:00:00', 'admin', '2026-04-21 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (157, 102, '王医生', '外科主治医师', '2026-04-29', '08:00', '12:00', 20, 17, 'active', 'admin', '2026-04-22 08:00:00', 'admin', '2026-04-22 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (158, 101, '李医生', '内科主治医师', '2026-04-29', '14:00', '18:00', 20, 10, 'active', 'admin', '2026-04-22 08:00:00', 'admin', '2026-04-22 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (159, 103, '张医生', '儿科主治医师', '2026-04-30', '08:00', '12:00', 20, 19, 'active', 'admin', '2026-04-23 08:00:00', 'admin', '2026-04-23 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (160, 102, '王医生', '外科主治医师', '2026-04-30', '14:00', '18:00', 20, 13, 'active', 'admin', '2026-04-23 08:00:00', 'admin', '2026-04-23 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (161, 101, '李医生', '内科主治医师', '2026-05-01', '09:00', '12:00', 15, 8, 'active', 'admin', '2026-04-24 08:00:00', 'admin', '2026-04-24 08:00:00', '节假日门诊');
INSERT INTO `clinic_schedule` VALUES (162, 103, '张医生', '儿科主治医师', '2026-05-02', '08:00', '12:00', 20, 14, 'active', 'admin', '2026-04-25 08:00:00', 'admin', '2026-04-25 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (163, 102, '王医生', '外科主治医师', '2026-05-02', '14:00', '18:00', 20, 11, 'active', 'admin', '2026-04-25 08:00:00', 'admin', '2026-04-25 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (164, 101, '李医生', '内科主治医师', '2026-05-03', '08:00', '12:00', 20, 16, 'active', 'admin', '2026-04-26 08:00:00', 'admin', '2026-04-26 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (165, 103, '张医生', '儿科主治医师', '2026-05-03', '14:00', '18:00', 20, 15, 'active', 'admin', '2026-04-26 08:00:00', 'admin', '2026-04-26 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (166, 102, '王医生', '外科主治医师', '2026-05-04', '08:00', '12:00', 20, 18, 'active', 'admin', '2026-04-27 08:00:00', 'admin', '2026-04-27 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (167, 101, '李医生', '内科主治医师', '2026-05-04', '14:00', '18:00', 20, 12, 'active', 'admin', '2026-04-27 08:00:00', 'admin', '2026-04-27 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (168, 103, '张医生', '儿科主治医师', '2026-05-05', '08:00', '12:00', 20, 17, 'active', 'admin', '2026-04-28 08:00:00', 'admin', '2026-04-28 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (169, 102, '王医生', '外科主治医师', '2026-05-05', '14:00', '18:00', 20, 14, 'active', 'admin', '2026-04-28 08:00:00', 'admin', '2026-04-28 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (170, 101, '李医生', '内科主治医师', '2026-05-06', '08:00', '12:00', 20, 19, 'active', 'admin', '2026-04-29 08:00:00', 'admin', '2026-04-29 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (171, 103, '张医生', '儿科主治医师', '2026-05-06', '14:00', '18:00', 20, 10, 'active', 'admin', '2026-04-29 08:00:00', 'admin', '2026-04-29 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (172, 102, '王医生', '外科主治医师', '2026-05-07', '08:00', '12:00', 20, 15, 'active', 'admin', '2026-04-30 08:00:00', 'admin', '2026-04-30 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (173, 101, '李医生', '内科主治医师', '2026-05-07', '14:00', '18:00', 20, 13, 'active', 'admin', '2026-04-30 08:00:00', 'admin', '2026-04-30 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (174, 103, '张医生', '儿科主治医师', '2026-05-08', '08:00', '12:00', 20, 16, 'active', 'admin', '2026-05-01 08:00:00', 'admin', '2026-05-01 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (175, 102, '王医生', '外科主治医师', '2026-05-08', '14:00', '18:00', 20, 11, 'active', 'admin', '2026-05-01 08:00:00', 'admin', '2026-05-01 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (176, 101, '李医生', '内科主治医师', '2026-05-09', '08:00', '12:00', 20, 18, 'active', 'admin', '2026-05-02 08:00:00', 'admin', '2026-05-02 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (177, 103, '张医生', '儿科主治医师', '2026-05-09', '14:00', '18:00', 20, 14, 'active', 'admin', '2026-05-02 08:00:00', 'admin', '2026-05-02 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (178, 102, '王医生', '外科主治医师', '2026-05-10', '09:00', '12:00', 15, 7, 'active', 'admin', '2026-05-03 08:00:00', 'admin', '2026-05-03 08:00:00', '周末门诊');
INSERT INTO `clinic_schedule` VALUES (179, 101, '李医生', '内科主治医师', '2026-05-11', '08:00', '12:00', 20, 17, 'active', 'admin', '2026-05-04 08:00:00', 'admin', '2026-05-04 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (180, 103, '张医生', '儿科主治医师', '2026-05-11', '14:00', '18:00', 20, 15, 'active', 'admin', '2026-05-04 08:00:00', 'admin', '2026-05-04 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (181, 102, '王医生', '外科主治医师', '2026-05-12', '08:00', '12:00', 20, 16, 'active', 'admin', '2026-05-05 08:00:00', 'admin', '2026-05-05 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (182, 101, '李医生', '内科主治医师', '2026-05-12', '14:00', '18:00', 20, 12, 'active', 'admin', '2026-05-05 08:00:00', 'admin', '2026-05-05 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (183, 103, '张医生', '儿科主治医师', '2026-05-13', '08:00', '12:00', 20, 18, 'active', 'admin', '2026-05-06 08:00:00', 'admin', '2026-05-06 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (184, 102, '王医生', '外科主治医师', '2026-05-13', '14:00', '18:00', 20, 13, 'active', 'admin', '2026-05-06 08:00:00', 'admin', '2026-05-06 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (185, 101, '李医生', '内科主治医师', '2026-05-14', '08:00', '12:00', 20, 19, 'active', 'admin', '2026-05-07 08:00:00', 'admin', '2026-05-07 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (186, 103, '张医生', '儿科主治医师', '2026-05-14', '14:00', '18:00', 20, 11, 'active', 'admin', '2026-05-07 08:00:00', 'admin', '2026-05-07 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (187, 102, '王医生', '外科主治医师', '2026-05-15', '08:00', '12:00', 20, 15, 'active', 'admin', '2026-05-08 08:00:00', 'admin', '2026-05-08 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (188, 101, '李医生', '内科主治医师', '2026-05-15', '14:00', '18:00', 20, 14, 'active', 'admin', '2026-05-08 08:00:00', 'admin', '2026-05-08 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (189, 103, '张医生', '儿科主治医师', '2026-05-16', '08:00', '12:00', 20, 17, 'active', 'admin', '2026-05-09 08:00:00', 'admin', '2026-05-09 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (190, 102, '王医生', '外科主治医师', '2026-05-16', '14:00', '18:00', 20, 10, 'active', 'admin', '2026-05-09 08:00:00', 'admin', '2026-05-09 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (191, 101, '李医生', '内科主治医师', '2026-05-17', '08:00', '12:00', 20, 16, 'active', 'admin', '2026-05-10 08:00:00', 'admin', '2026-05-10 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (192, 103, '张医生', '儿科主治医师', '2026-05-17', '14:00', '18:00', 20, 13, 'active', 'admin', '2026-05-10 08:00:00', 'admin', '2026-05-10 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (193, 102, '王医生', '外科主治医师', '2026-05-18', '08:00', '12:00', 20, 18, 'active', 'admin', '2026-05-11 08:00:00', 'admin', '2026-05-11 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (194, 101, '李医生', '内科主治医师', '2026-05-18', '14:00', '18:00', 20, 12, 'active', 'admin', '2026-05-11 08:00:00', 'admin', '2026-05-11 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (195, 103, '张医生', '儿科主治医师', '2026-05-19', '08:00', '12:00', 20, 15, 'active', 'admin', '2026-05-12 08:00:00', 'admin', '2026-05-12 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (196, 102, '王医生', '外科主治医师', '2026-05-19', '14:00', '18:00', 20, 9, 'active', 'admin', '2026-05-12 08:00:00', 'admin', '2026-05-12 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (197, 101, '李医生', '内科主治医师', '2026-05-20', '08:00', '12:00', 20, 17, 'active', 'admin', '2026-05-13 08:00:00', 'admin', '2026-05-13 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (198, 103, '张医生', '儿科主治医师', '2026-05-20', '14:00', '18:00', 20, 14, 'active', 'admin', '2026-05-13 08:00:00', 'admin', '2026-05-13 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (199, 102, '王医生', '外科主治医师', '2026-05-21', '08:00', '12:00', 20, 16, 'active', 'admin', '2026-05-14 08:00:00', 'admin', '2026-05-14 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (200, 101, '李医生', '内科主治医师', '2026-05-21', '14:00', '18:00', 20, 11, 'active', 'admin', '2026-05-14 08:00:00', 'admin', '2026-05-14 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (201, 103, '张医生', '儿科主治医师', '2026-05-22', '08:00', '12:00', 20, 18, 'active', 'admin', '2026-05-15 08:00:00', 'admin', '2026-05-15 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (202, 102, '王医生', '外科主治医师', '2026-05-22', '14:00', '18:00', 20, 13, 'active', 'admin', '2026-05-15 08:00:00', 'admin', '2026-05-15 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (203, 101, '李医生', '内科主治医师', '2026-05-23', '08:00', '12:00', 20, 15, 'active', 'admin', '2026-05-16 08:00:00', 'admin', '2026-05-16 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (204, 103, '张医生', '儿科主治医师', '2026-05-23', '14:00', '18:00', 20, 10, 'active', 'admin', '2026-05-16 08:00:00', 'admin', '2026-05-16 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (205, 102, '王医生', '外科主治医师', '2026-05-24', '09:00', '12:00', 15, 8, 'active', 'admin', '2026-05-17 08:00:00', 'admin', '2026-05-17 08:00:00', '周末门诊');
INSERT INTO `clinic_schedule` VALUES (206, 101, '李医生', '内科主治医师', '2026-05-25', '08:00', '12:00', 20, 16, 'active', 'admin', '2026-05-18 08:00:00', 'admin', '2026-05-18 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (207, 103, '张医生', '儿科主治医师', '2026-05-25', '14:00', '18:00', 20, 14, 'active', 'admin', '2026-05-18 08:00:00', 'admin', '2026-05-18 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (208, 102, '王医生', '外科主治医师', '2026-05-26', '08:00', '12:00', 20, 17, 'active', 'admin', '2026-05-19 08:00:00', 'admin', '2026-05-19 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (209, 101, '李医生', '内科主治医师', '2026-05-26', '14:00', '18:00', 20, 12, 'active', 'admin', '2026-05-19 08:00:00', 'admin', '2026-05-19 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (210, 103, '张医生', '儿科主治医师', '2026-05-27', '08:00', '12:00', 20, 15, 'active', 'admin', '2026-05-20 08:00:00', 'admin', '2026-05-20 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (211, 102, '王医生', '外科主治医师', '2026-05-27', '14:00', '18:00', 20, 11, 'active', 'admin', '2026-05-20 08:00:00', 'admin', '2026-05-20 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (212, 101, '李医生', '内科主治医师', '2026-05-28', '08:00', '12:00', 20, 18, 'active', 'admin', '2026-05-21 08:00:00', 'admin', '2026-05-21 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (213, 103, '张医生', '儿科主治医师', '2026-05-28', '14:00', '18:00', 20, 13, 'active', 'admin', '2026-05-21 08:00:00', 'admin', '2026-05-21 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (214, 102, '王医生', '外科主治医师', '2026-05-29', '08:00', '12:00', 20, 16, 'active', 'admin', '2026-05-22 08:00:00', 'admin', '2026-05-22 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (215, 101, '李医生', '内科主治医师', '2026-05-29', '14:00', '18:00', 20, 14, 'active', 'admin', '2026-05-22 08:00:00', 'admin', '2026-05-22 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (216, 103, '张医生', '儿科主治医师', '2026-05-30', '08:00', '12:00', 20, 17, 'active', 'admin', '2026-05-23 08:00:00', 'admin', '2026-05-23 08:00:00', '上午门诊');
INSERT INTO `clinic_schedule` VALUES (217, 102, '王医生', '外科主治医师', '2026-05-30', '14:00', '18:00', 20, 10, 'active', 'admin', '2026-05-23 08:00:00', 'admin', '2026-05-23 08:00:00', '下午门诊');
INSERT INTO `clinic_schedule` VALUES (218, 101, '李医生', '内科主治医师', '2026-05-31', '09:00', '12:00', 15, 9, 'active', 'admin', '2026-05-24 08:00:00', 'admin', '2026-05-24 08:00:00', '周末门诊');
INSERT INTO `clinic_schedule` VALUES (219, 101, '李医生', NULL, '2026-04-03', '00:55', '06:55', 20, 2, 'active', 'admin', '2026-04-03 00:55:40', '', NULL, NULL);
INSERT INTO `clinic_schedule` VALUES (220, 101, '李医生', NULL, '2026-04-03', '08:00', '12:00', 20, 0, 'active', '13800138001', '2026-04-03 02:57:29', '', NULL, NULL);

-- ----------------------------
-- Table structure for clinic_stock_batch
-- ----------------------------
DROP TABLE IF EXISTS `clinic_stock_batch`;
CREATE TABLE `clinic_stock_batch`  (
  `batch_id` bigint NOT NULL AUTO_INCREMENT COMMENT '批次ID',
  `medicine_id` bigint NOT NULL COMMENT '药品ID',
  `batch_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '批号',
  `expiry_date` date NOT NULL COMMENT '批次有效期',
  `remaining_quantity` int NOT NULL DEFAULT 0 COMMENT '批次剩余库存',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`batch_id`) USING BTREE,
  UNIQUE INDEX `uk_medicine_batch_expiry`(`medicine_id`, `batch_number`, `expiry_date`) USING BTREE,
  INDEX `idx_medicine_expiry`(`medicine_id`, `expiry_date`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 347 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '批次库存表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of clinic_stock_batch
-- ----------------------------
INSERT INTO `clinic_stock_batch` VALUES (100, 100, 'B2027A001', '2027-06-15', 120, '2026-04-01 17:23:23', '2026-04-01 17:23:23');
INSERT INTO `clinic_stock_batch` VALUES (101, 100, 'B2027A002', '2027-08-20', 180, '2026-04-01 17:23:23', '2026-04-01 17:23:23');
INSERT INTO `clinic_stock_batch` VALUES (102, 101, 'B2027B001', '2027-05-20', 350, '2026-04-01 17:23:23', '2026-04-01 17:23:23');
INSERT INTO `clinic_stock_batch` VALUES (103, 102, 'B2027C001', '2027-08-10', 280, '2026-04-01 17:23:23', '2026-04-01 17:23:23');
INSERT INTO `clinic_stock_batch` VALUES (104, 103, 'B2027D001', '2027-04-25', 400, '2026-04-01 17:23:23', '2026-04-01 17:23:23');
INSERT INTO `clinic_stock_batch` VALUES (105, 104, 'B2027E001', '2027-03-15', 449, '2026-04-01 17:23:23', '2026-04-01 18:54:00');
INSERT INTO `clinic_stock_batch` VALUES (106, 105, 'B2027F001', '2027-06-25', 500, '2026-04-01 17:23:23', '2026-04-01 17:23:23');
INSERT INTO `clinic_stock_batch` VALUES (107, 106, 'B2027G001', '2027-07-15', 320, '2026-04-01 17:23:23', '2026-04-01 17:23:23');
INSERT INTO `clinic_stock_batch` VALUES (108, 107, 'B2027H001', '2027-08-20', 290, '2026-04-01 17:23:23', '2026-04-01 17:23:23');
INSERT INTO `clinic_stock_batch` VALUES (109, 108, 'B2027I001', '2027-09-10', 200, '2026-04-01 17:23:23', '2026-04-01 17:23:23');
INSERT INTO `clinic_stock_batch` VALUES (110, 109, 'B2027J001', '2027-05-25', 310, '2026-04-01 17:23:23', '2026-04-01 17:23:23');
INSERT INTO `clinic_stock_batch` VALUES (111, 110, 'B2027K001', '2027-05-15', 500, '2026-04-01 17:23:23', '2026-04-01 17:23:23');
INSERT INTO `clinic_stock_batch` VALUES (112, 111, 'B2027L001', '2027-12-30', 500, '2026-04-01 17:23:23', '2026-04-01 17:23:23');
INSERT INTO `clinic_stock_batch` VALUES (113, 112, 'B2027M001', '2027-11-15', 380, '2026-04-01 17:23:23', '2026-04-01 17:23:23');
INSERT INTO `clinic_stock_batch` VALUES (114, 113, 'B2027N001', '2027-05-12', 380, '2026-04-01 17:23:23', '2026-04-01 17:23:23');
INSERT INTO `clinic_stock_batch` VALUES (115, 114, 'B2027O001', '2027-06-22', 280, '2026-04-01 17:23:23', '2026-04-01 17:23:23');
INSERT INTO `clinic_stock_batch` VALUES (116, 115, 'B2027P001', '2027-06-15', 320, '2026-04-01 17:23:23', '2026-04-01 17:23:23');
INSERT INTO `clinic_stock_batch` VALUES (117, 116, 'B2027Q001', '2027-04-20', 280, '2026-04-01 17:23:23', '2026-04-01 17:23:23');
INSERT INTO `clinic_stock_batch` VALUES (118, 117, 'B2027R001', '2027-12-31', 150, '2026-04-01 17:23:23', '2026-04-01 17:23:23');
INSERT INTO `clinic_stock_batch` VALUES (119, 118, 'B2027S001', '2027-05-31', 200, '2026-04-01 17:23:23', '2026-04-01 17:23:23');
INSERT INTO `clinic_stock_batch` VALUES (120, 119, 'B2027T001', '2027-06-30', 200, '2026-04-01 17:23:23', '2026-04-01 17:23:23');
INSERT INTO `clinic_stock_batch` VALUES (121, 120, 'B2027U001', '2027-03-15', 400, '2026-04-01 17:23:23', '2026-04-01 17:23:23');
INSERT INTO `clinic_stock_batch` VALUES (122, 100, 'BL20260615001', '2026-06-15', 68, '2026-01-10 09:00:00', '2026-04-03 01:30:42');
INSERT INTO `clinic_stock_batch` VALUES (123, 100, 'BL20270820001', '2027-08-20', 120, '2026-02-15 10:30:00', '2026-02-15 10:30:00');
INSERT INTO `clinic_stock_batch` VALUES (124, 100, 'BL20280110001', '2028-01-10', 100, '2026-03-01 14:00:00', '2026-03-01 14:00:00');
INSERT INTO `clinic_stock_batch` VALUES (125, 101, 'BL20270520001', '2027-05-20', 200, '2026-01-15 08:00:00', '2026-01-15 08:00:00');
INSERT INTO `clinic_stock_batch` VALUES (126, 101, 'BL20280315001', '2028-03-15', 150, '2026-02-20 09:00:00', '2026-02-20 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (127, 102, 'BL20270810001', '2027-08-10', 150, '2026-01-20 10:00:00', '2026-01-20 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (128, 102, 'BL20281225001', '2028-12-25', 130, '2026-03-05 11:00:00', '2026-03-05 11:00:00');
INSERT INTO `clinic_stock_batch` VALUES (129, 105, 'BL20270625001', '2027-06-25', 250, '2026-01-05 08:30:00', '2026-01-05 08:30:00');
INSERT INTO `clinic_stock_batch` VALUES (130, 105, 'BL20280320001', '2028-03-20', 250, '2026-02-10 14:00:00', '2026-02-10 14:00:00');
INSERT INTO `clinic_stock_batch` VALUES (131, 106, 'BL20270715001', '2027-07-15', 180, '2026-01-25 09:00:00', '2026-01-25 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (132, 106, 'BL20290110001', '2029-01-10', 140, '2026-02-28 10:00:00', '2026-02-28 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (133, 111, 'BL20271230001', '2027-12-30', 300, '2026-02-01 08:00:00', '2026-02-01 08:00:00');
INSERT INTO `clinic_stock_batch` VALUES (134, 111, 'BL20260205001', '2026-02-05', 200, '2025-08-01 09:00:00', '2025-08-01 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (135, 114, 'BL20270622001', '2027-06-22', 150, '2026-01-18 10:00:00', '2026-01-18 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (136, 114, 'BL20290120001', '2029-01-20', 130, '2026-03-10 14:00:00', '2026-03-10 14:00:00');
INSERT INTO `clinic_stock_batch` VALUES (137, 117, 'BL20271231001', '2027-12-31', 100, '2026-02-05 08:30:00', '2026-02-05 08:30:00');
INSERT INTO `clinic_stock_batch` VALUES (138, 117, 'BL20260115001', '2026-01-15', 50, '2025-07-15 09:00:00', '2025-07-15 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (139, 118, 'BL20270531001', '2027-05-31', 120, '2026-01-12 11:00:00', '2026-01-12 11:00:00');
INSERT INTO `clinic_stock_batch` VALUES (140, 118, 'BL20260130001', '2026-01-30', 80, '2025-08-10 08:00:00', '2025-08-10 08:00:00');
INSERT INTO `clinic_stock_batch` VALUES (141, 119, 'BL20270630001', '2027-06-30', 120, '2026-02-08 09:30:00', '2026-02-08 09:30:00');
INSERT INTO `clinic_stock_batch` VALUES (142, 119, 'BL20290215001', '2029-02-15', 80, '2026-03-15 10:00:00', '2026-03-15 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (143, 120, 'BL20270315001', '2027-03-15', 250, '2026-01-22 08:00:00', '2026-01-22 08:00:00');
INSERT INTO `clinic_stock_batch` VALUES (144, 120, 'BL20280105001', '2028-01-05', 150, '2026-03-01 09:00:00', '2026-03-01 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (145, 121, 'BL20270512001', '2027-05-12', 150, '2026-02-10 09:00:00', '2026-02-10 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (146, 121, 'BL20281220001', '2028-12-20', 150, '2026-03-15 10:00:00', '2026-03-15 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (147, 122, 'BL20270615001', '2027-06-15', 120, '2026-02-05 08:30:00', '2026-02-05 08:30:00');
INSERT INTO `clinic_stock_batch` VALUES (148, 122, 'BL20290110001', '2029-01-10', 130, '2026-03-10 14:00:00', '2026-03-10 14:00:00');
INSERT INTO `clinic_stock_batch` VALUES (149, 123, 'BL20270720001', '2027-07-20', 140, '2026-02-12 09:00:00', '2026-02-12 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (150, 123, 'BL20290225001', '2029-02-25', 140, '2026-03-20 11:00:00', '2026-03-20 11:00:00');
INSERT INTO `clinic_stock_batch` VALUES (151, 124, 'BL20270915001', '2027-09-15', 100, '2026-02-20 10:00:00', '2026-02-20 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (152, 124, 'BL20260210001', '2026-02-10', 100, '2025-08-15 09:00:00', '2025-08-15 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (153, 125, 'BL20270630001', '2027-06-30', 180, '2026-02-15 08:00:00', '2026-02-15 08:00:00');
INSERT INTO `clinic_stock_batch` VALUES (154, 125, 'BL20281215001', '2028-12-15', 170, '2026-03-10 10:30:00', '2026-03-10 10:30:00');
INSERT INTO `clinic_stock_batch` VALUES (155, 126, 'BL20271201001', '2027-12-01', 200, '2026-02-08 09:00:00', '2026-02-08 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (156, 126, 'BL20290120001', '2029-01-20', 200, '2026-03-15 11:00:00', '2026-03-15 11:00:00');
INSERT INTO `clinic_stock_batch` VALUES (157, 127, 'BL20270815001', '2027-08-15', 130, '2026-02-18 10:00:00', '2026-02-18 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (158, 127, 'BL20260105001', '2026-01-05', 130, '2025-07-20 08:30:00', '2025-07-20 08:30:00');
INSERT INTO `clinic_stock_batch` VALUES (159, 128, 'BL20270525001', '2027-05-25', 150, '2026-02-10 09:30:00', '2026-02-10 09:30:00');
INSERT INTO `clinic_stock_batch` VALUES (160, 128, 'BL20281230001', '2028-12-30', 140, '2026-03-18 14:00:00', '2026-03-18 14:00:00');
INSERT INTO `clinic_stock_batch` VALUES (161, 129, 'BL20270425001', '2027-04-25', 200, '2026-01-28 08:00:00', '2026-01-28 08:00:00');
INSERT INTO `clinic_stock_batch` VALUES (162, 129, 'BL20290110001', '2029-01-10', 180, '2026-03-12 10:00:00', '2026-03-12 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (163, 130, 'BL20270610001', '2027-06-10', 140, '2026-02-22 09:00:00', '2026-02-22 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (164, 130, 'BL20281205001', '2028-12-05', 130, '2026-03-20 11:30:00', '2026-03-20 11:30:00');
INSERT INTO `clinic_stock_batch` VALUES (165, 131, 'BL20270725001', '2027-07-25', 120, '2026-02-25 10:00:00', '2026-02-25 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (166, 131, 'BL20260315001', '2026-03-15', 120, '2025-09-10 08:30:00', '2025-09-10 08:30:00');
INSERT INTO `clinic_stock_batch` VALUES (167, 132, 'BL20270830001', '2027-08-30', 160, '2026-02-28 09:00:00', '2026-02-28 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (168, 132, 'BL20290115001', '2029-01-15', 160, '2026-03-15 14:00:00', '2026-03-15 14:00:00');
INSERT INTO `clinic_stock_batch` VALUES (169, 133, 'BL20270920001', '2027-09-20', 90, '2026-03-05 10:00:00', '2026-03-05 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (170, 133, 'BL20260228001', '2026-02-28', 90, '2025-08-25 09:00:00', '2025-08-25 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (171, 134, 'BL20270515001', '2027-05-15', 170, '2026-02-12 08:30:00', '2026-02-12 08:30:00');
INSERT INTO `clinic_stock_batch` VALUES (172, 134, 'BL20290105001', '2029-01-05', 170, '2026-03-10 11:00:00', '2026-03-10 11:00:00');
INSERT INTO `clinic_stock_batch` VALUES (173, 135, 'BL20270520001', '2027-05-20', 230, '2026-02-08 09:00:00', '2026-02-08 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (174, 135, 'BL20281210001', '2028-12-10', 220, '2026-03-18 14:30:00', '2026-03-18 14:30:00');
INSERT INTO `clinic_stock_batch` VALUES (175, 136, 'BL20270625001', '2027-06-25', 160, '2026-02-15 10:00:00', '2026-02-15 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (176, 136, 'BL20290210001', '2029-02-10', 160, '2026-03-20 09:00:00', '2026-03-20 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (177, 137, 'BL20270710001', '2027-07-10', 140, '2026-02-18 08:30:00', '2026-02-18 08:30:00');
INSERT INTO `clinic_stock_batch` VALUES (178, 137, 'BL20260305001', '2026-03-05', 140, '2025-09-05 10:00:00', '2025-09-05 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (179, 138, 'BL20270820001', '2027-08-20', 110, '2026-02-22 09:00:00', '2026-02-22 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (180, 138, 'BL20281215001', '2028-12-15', 110, '2026-03-15 11:00:00', '2026-03-15 11:00:00');
INSERT INTO `clinic_stock_batch` VALUES (181, 139, 'BL20270515001', '2027-05-15', 180, '2026-02-05 08:00:00', '2026-02-05 08:00:00');
INSERT INTO `clinic_stock_batch` VALUES (182, 139, 'BL20290108001', '2029-01-08', 170, '2026-03-12 10:30:00', '2026-03-12 10:30:00');
INSERT INTO `clinic_stock_batch` VALUES (183, 140, 'BL20270910001', '2027-09-10', 100, '2026-02-25 09:00:00', '2026-02-25 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (184, 140, 'BL20260320001', '2026-03-20', 100, '2025-09-15 08:30:00', '2025-09-15 08:30:00');
INSERT INTO `clinic_stock_batch` VALUES (185, 141, 'BL20270525001', '2027-05-25', 130, '2026-02-10 10:00:00', '2026-02-10 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (186, 141, 'BL20281220001', '2028-12-20', 130, '2026-03-18 11:00:00', '2026-03-18 11:00:00');
INSERT INTO `clinic_stock_batch` VALUES (187, 142, 'BL20270622001', '2027-06-22', 150, '2026-02-15 08:30:00', '2026-02-15 08:30:00');
INSERT INTO `clinic_stock_batch` VALUES (188, 142, 'BL20290118001', '2029-01-18', 150, '2026-03-20 09:30:00', '2026-03-20 09:30:00');
INSERT INTO `clinic_stock_batch` VALUES (189, 143, 'BL20270718001', '2027-07-18', 90, '2026-02-28 10:00:00', '2026-02-28 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (190, 143, 'BL20281210001', '2028-12-10', 90, '2026-03-15 14:00:00', '2026-03-15 14:00:00');
INSERT INTO `clinic_stock_batch` VALUES (191, 144, 'BL20270630001', '2027-06-30', 130, '2026-02-20 09:00:00', '2026-02-20 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (192, 144, 'BL20260325001', '2026-03-25', 120, '2025-09-20 08:00:00', '2025-09-20 08:00:00');
INSERT INTO `clinic_stock_batch` VALUES (193, 145, 'BL20270510001', '2027-05-10', 100, '2026-03-01 08:30:00', '2026-03-01 08:30:00');
INSERT INTO `clinic_stock_batch` VALUES (194, 145, 'BL20281228001', '2028-12-28', 100, '2026-03-25 10:00:00', '2026-03-25 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (195, 146, 'BL20270420001', '2027-04-20', 110, '2026-02-25 09:30:00', '2026-02-25 09:30:00');
INSERT INTO `clinic_stock_batch` VALUES (196, 146, 'BL20290112001', '2029-01-12', 110, '2026-03-22 11:00:00', '2026-03-22 11:00:00');
INSERT INTO `clinic_stock_batch` VALUES (197, 147, 'BL20270825001', '2027-08-25', 140, '2026-02-15 10:30:00', '2026-02-15 10:30:00');
INSERT INTO `clinic_stock_batch` VALUES (198, 147, 'BL20260218001', '2026-02-18', 140, '2025-08-20 09:00:00', '2025-08-20 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (199, 148, 'BL20270715001', '2027-07-15', 160, '2026-02-10 08:00:00', '2026-02-10 08:00:00');
INSERT INTO `clinic_stock_batch` VALUES (200, 148, 'BL20281205001', '2028-12-05', 160, '2026-03-12 10:00:00', '2026-03-12 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (201, 149, 'BL20270920001', '2027-09-20', 80, '2026-02-28 09:30:00', '2026-02-28 09:30:00');
INSERT INTO `clinic_stock_batch` VALUES (202, 149, 'BL20260310001', '2026-03-10', 80, '2025-09-10 08:30:00', '2025-09-10 08:30:00');
INSERT INTO `clinic_stock_batch` VALUES (203, 150, 'BL20270818001', '2027-08-18', 90, '2026-03-05 10:00:00', '2026-03-05 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (204, 150, 'BL20290108001', '2029-01-08', 90, '2026-03-28 11:00:00', '2026-03-28 11:00:00');
INSERT INTO `clinic_stock_batch` VALUES (205, 151, 'BL20270630001', '2027-06-30', 140, '2026-02-12 09:00:00', '2026-02-12 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (206, 151, 'BL20281215001', '2028-12-15', 140, '2026-03-10 11:00:00', '2026-03-10 11:00:00');
INSERT INTO `clinic_stock_batch` VALUES (207, 152, 'BL20270725001', '2027-07-25', 100, '2026-02-18 08:30:00', '2026-02-18 08:30:00');
INSERT INTO `clinic_stock_batch` VALUES (208, 152, 'BL20260305001', '2026-03-05', 100, '2025-09-05 10:00:00', '2025-09-05 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (209, 153, 'BL20270815001', '2027-08-15', 110, '2026-02-22 09:00:00', '2026-02-22 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (210, 153, 'BL20281210001', '2028-12-10', 110, '2026-03-15 10:30:00', '2026-03-15 10:30:00');
INSERT INTO `clinic_stock_batch` VALUES (211, 154, 'BL20270910001', '2027-09-10', 90, '2026-02-25 10:00:00', '2026-02-25 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (212, 154, 'BL20290125001', '2029-01-25', 90, '2026-03-20 11:00:00', '2026-03-20 11:00:00');
INSERT INTO `clinic_stock_batch` VALUES (213, 155, 'BL20270620001', '2027-06-20', 120, '2026-02-10 08:00:00', '2026-02-10 08:00:00');
INSERT INTO `clinic_stock_batch` VALUES (214, 155, 'BL20281208001', '2028-12-08', 120, '2026-03-12 09:30:00', '2026-03-12 09:30:00');
INSERT INTO `clinic_stock_batch` VALUES (215, 156, 'BL20270730001', '2027-07-30', 150, '2026-02-15 09:00:00', '2026-02-15 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (216, 156, 'BL20260318001', '2026-03-18', 150, '2025-09-15 08:30:00', '2025-09-15 08:30:00');
INSERT INTO `clinic_stock_batch` VALUES (217, 157, 'BL20270515001', '2027-05-15', 130, '2026-02-20 10:00:00', '2026-02-20 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (218, 157, 'BL20281228001', '2028-12-28', 130, '2026-03-18 11:00:00', '2026-03-18 11:00:00');
INSERT INTO `clinic_stock_batch` VALUES (219, 158, 'BL20270820001', '2027-08-20', 160, '2026-02-08 08:30:00', '2026-02-08 08:30:00');
INSERT INTO `clinic_stock_batch` VALUES (220, 158, 'BL20290115001', '2029-01-15', 160, '2026-03-10 10:00:00', '2026-03-10 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (221, 159, 'BL20271230001', '2027-12-30', 250, '2026-02-05 09:00:00', '2026-02-05 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (222, 159, 'BL20260328001', '2026-03-28', 250, '2025-09-25 08:00:00', '2025-09-25 08:00:00');
INSERT INTO `clinic_stock_batch` VALUES (223, 160, 'BL20271230001', '2027-12-30', 250, '2026-02-05 09:30:00', '2026-02-05 09:30:00');
INSERT INTO `clinic_stock_batch` VALUES (224, 160, 'BL20290220001', '2029-02-20', 250, '2026-03-15 10:30:00', '2026-03-15 10:30:00');
INSERT INTO `clinic_stock_batch` VALUES (225, 161, 'BL20271230001', '2027-12-30', 250, '2026-02-05 10:00:00', '2026-02-05 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (226, 161, 'BL20260210001', '2026-02-10', 250, '2025-08-10 08:30:00', '2025-08-10 08:30:00');
INSERT INTO `clinic_stock_batch` VALUES (227, 162, 'BL20271115001', '2027-11-15', 180, '2026-02-18 09:00:00', '2026-02-18 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (228, 162, 'BL20290120001', '2029-01-20', 170, '2026-03-12 11:00:00', '2026-03-12 11:00:00');
INSERT INTO `clinic_stock_batch` VALUES (229, 163, 'BL20271020001', '2027-10-20', 190, '2026-02-22 08:30:00', '2026-02-22 08:30:00');
INSERT INTO `clinic_stock_batch` VALUES (230, 163, 'BL20281210001', '2028-12-10', 190, '2026-03-18 10:00:00', '2026-03-18 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (231, 164, 'BL20270915001', '2027-09-15', 140, '2026-02-28 09:00:00', '2026-02-28 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (232, 164, 'BL20260315001', '2026-03-15', 140, '2025-09-12 08:00:00', '2025-09-12 08:00:00');
INSERT INTO `clinic_stock_batch` VALUES (233, 165, 'BL20271115001', '2027-11-15', 200, '2026-02-12 10:00:00', '2026-02-12 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (234, 165, 'BL20281205001', '2028-12-05', 200, '2026-03-10 11:30:00', '2026-03-10 11:30:00');
INSERT INTO `clinic_stock_batch` VALUES (235, 166, 'BL20270615001', '2027-06-15', 400, '2026-02-05 08:00:00', '2026-02-05 08:00:00');
INSERT INTO `clinic_stock_batch` VALUES (236, 166, 'BL20290110001', '2029-01-10', 400, '2026-03-15 09:00:00', '2026-03-15 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (237, 167, 'BL20270720001', '2027-07-20', 380, '2026-02-08 09:00:00', '2026-02-08 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (238, 167, 'BL20281225001', '2028-12-25', 370, '2026-03-20 10:00:00', '2026-03-20 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (239, 168, 'BL20270810001', '2027-08-10', 350, '2026-02-12 08:30:00', '2026-02-12 08:30:00');
INSERT INTO `clinic_stock_batch` VALUES (240, 168, 'BL20260320001', '2026-03-20', 350, '2025-09-18 09:00:00', '2025-09-18 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (241, 169, 'BL20270525001', '2027-05-25', 250, '2026-02-15 10:00:00', '2026-02-15 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (242, 169, 'BL20281215001', '2028-12-15', 250, '2026-03-18 11:00:00', '2026-03-18 11:00:00');
INSERT INTO `clinic_stock_batch` VALUES (243, 170, 'BL20270915001', '2027-09-15', 150, '2026-02-22 09:00:00', '2026-02-22 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (244, 170, 'BL20290125001', '2029-01-25', 150, '2026-03-20 10:30:00', '2026-03-20 10:30:00');
INSERT INTO `clinic_stock_batch` VALUES (245, 171, 'BL20270630001', '2027-06-30', 180, '2026-02-18 08:30:00', '2026-02-18 08:30:00');
INSERT INTO `clinic_stock_batch` VALUES (246, 171, 'BL20260225001', '2026-02-25', 170, '2025-08-22 09:00:00', '2025-08-22 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (247, 172, 'BL20270515001', '2027-05-15', 200, '2026-02-25 09:00:00', '2026-02-25 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (248, 172, 'BL20281210001', '2028-12-10', 200, '2026-03-22 10:00:00', '2026-03-22 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (249, 173, 'BL20271201001', '2027-12-01', 230, '2026-02-10 10:30:00', '2026-02-10 10:30:00');
INSERT INTO `clinic_stock_batch` VALUES (250, 173, 'BL20290120001', '2029-01-20', 220, '2026-03-15 11:00:00', '2026-03-15 11:00:00');
INSERT INTO `clinic_stock_batch` VALUES (251, 174, 'BL20270620001', '2027-06-20', 190, '2026-02-05 08:00:00', '2026-02-05 08:00:00');
INSERT INTO `clinic_stock_batch` VALUES (252, 174, 'BL20281205001', '2028-12-05', 190, '2026-03-12 09:30:00', '2026-03-12 09:30:00');
INSERT INTO `clinic_stock_batch` VALUES (253, 175, 'BL20270715001', '2027-07-15', 180, '2026-02-15 09:00:00', '2026-02-15 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (254, 175, 'BL20260310001', '2026-03-10', 170, '2025-09-08 08:30:00', '2025-09-08 08:30:00');
INSERT INTO `clinic_stock_batch` VALUES (255, 176, 'BL20270530001', '2027-05-30', 210, '2026-02-20 10:00:00', '2026-02-20 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (256, 176, 'BL20281220001', '2028-12-20', 210, '2026-03-18 11:00:00', '2026-03-18 11:00:00');
INSERT INTO `clinic_stock_batch` VALUES (257, 177, 'BL20270825001', '2027-08-25', 140, '2026-02-28 09:00:00', '2026-02-28 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (258, 177, 'BL20290112001', '2029-01-12', 140, '2026-03-25 10:30:00', '2026-03-25 10:30:00');
INSERT INTO `clinic_stock_batch` VALUES (259, 178, 'BL20270910001', '2027-09-10', 110, '2026-03-01 08:30:00', '2026-03-01 08:30:00');
INSERT INTO `clinic_stock_batch` VALUES (260, 178, 'BL20260228001', '2026-02-28', 110, '2025-08-25 09:00:00', '2025-08-25 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (261, 179, 'BL20270615001', '2027-06-15', 190, '2026-02-10 09:00:00', '2026-02-10 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (262, 179, 'BL20281210001', '2028-12-10', 190, '2026-03-15 10:00:00', '2026-03-15 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (263, 180, 'BL20270420001', '2027-04-20', 150, '2026-02-18 08:30:00', '2026-02-18 08:30:00');
INSERT INTO `clinic_stock_batch` VALUES (264, 180, 'BL20281225001', '2028-12-25', 150, '2026-03-20 09:30:00', '2026-03-20 09:30:00');
INSERT INTO `clinic_stock_batch` VALUES (265, 181, 'BL20271231001', '2027-12-31', 100, '2026-02-05 09:00:00', '2026-02-05 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (266, 181, 'BL20260315001', '2026-03-15', 100, '2025-09-12 08:30:00', '2025-09-12 08:30:00');
INSERT INTO `clinic_stock_batch` VALUES (267, 182, 'BL20270630001', '2027-06-30', 75, '2026-02-15 10:00:00', '2026-02-15 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (268, 182, 'BL20281220001', '2028-12-20', 75, '2026-03-18 11:00:00', '2026-03-18 11:00:00');
INSERT INTO `clinic_stock_batch` VALUES (269, 183, 'BL20270720001', '2027-07-20', 60, '2026-02-22 09:00:00', '2026-02-22 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (270, 183, 'BL20290110001', '2029-01-10', 60, '2026-03-22 10:30:00', '2026-03-22 10:30:00');
INSERT INTO `clinic_stock_batch` VALUES (271, 184, 'BL20270815001', '2027-08-15', 90, '2026-02-25 08:30:00', '2026-02-25 08:30:00');
INSERT INTO `clinic_stock_batch` VALUES (272, 184, 'BL20281205001', '2028-12-05', 90, '2026-03-28 09:00:00', '2026-03-28 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (273, 185, 'BL20270910001', '2027-09-10', 70, '2026-03-01 09:00:00', '2026-03-01 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (274, 185, 'BL20260220001', '2026-02-20', 70, '2025-08-18 08:30:00', '2025-08-18 08:30:00');
INSERT INTO `clinic_stock_batch` VALUES (275, 186, 'BL20270525001', '2027-05-25', 110, '2026-02-08 10:00:00', '2026-02-08 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (276, 186, 'BL20281210001', '2028-12-10', 110, '2026-03-10 11:00:00', '2026-03-10 11:00:00');
INSERT INTO `clinic_stock_batch` VALUES (277, 187, 'BL20270618001', '2027-06-18', 80, '2026-02-12 09:30:00', '2026-02-12 09:30:00');
INSERT INTO `clinic_stock_batch` VALUES (278, 187, 'BL20290125001', '2029-01-25', 80, '2026-03-15 10:00:00', '2026-03-15 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (279, 188, 'BL20270730001', '2027-07-30', 100, '2026-02-18 08:00:00', '2026-02-18 08:00:00');
INSERT INTO `clinic_stock_batch` VALUES (280, 188, 'BL20260305001', '2026-03-05', 100, '2025-09-05 09:30:00', '2025-09-05 09:30:00');
INSERT INTO `clinic_stock_batch` VALUES (281, 189, 'BL20270820001', '2027-08-20', 50, '2026-02-28 09:00:00', '2026-02-28 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (282, 189, 'BL20281215001', '2028-12-15', 50, '2026-03-20 10:30:00', '2026-03-20 10:30:00');
INSERT INTO `clinic_stock_batch` VALUES (283, 190, 'BL20270515001', '2027-05-15', 90, '2026-02-05 10:30:00', '2026-02-05 10:30:00');
INSERT INTO `clinic_stock_batch` VALUES (284, 190, 'BL20290108001', '2029-01-08', 90, '2026-03-12 11:00:00', '2026-03-12 11:00:00');
INSERT INTO `clinic_stock_batch` VALUES (285, 191, 'BL20270520001', '2027-05-20', 160, '2026-02-10 08:00:00', '2026-02-10 08:00:00');
INSERT INTO `clinic_stock_batch` VALUES (286, 191, 'BL20281210001', '2028-12-10', 160, '2026-03-15 09:30:00', '2026-03-15 09:30:00');
INSERT INTO `clinic_stock_batch` VALUES (287, 192, 'BL20270425001', '2027-04-25', 180, '2026-02-15 09:00:00', '2026-02-15 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (288, 192, 'BL20290115001', '2029-01-15', 170, '2026-03-18 10:00:00', '2026-03-18 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (289, 193, 'BL20270915001', '2027-09-15', 140, '2026-02-22 08:30:00', '2026-02-22 08:30:00');
INSERT INTO `clinic_stock_batch` VALUES (290, 193, 'BL20260205001', '2026-02-05', 140, '2025-08-05 09:00:00', '2025-08-05 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (291, 194, 'BL20270630001', '2027-06-30', 150, '2026-02-25 09:00:00', '2026-02-25 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (292, 194, 'BL20281220001', '2028-12-20', 150, '2026-03-22 10:30:00', '2026-03-22 10:30:00');
INSERT INTO `clinic_stock_batch` VALUES (293, 195, 'BL20270515001', '2027-05-15', 170, '2026-03-01 08:00:00', '2026-03-01 08:00:00');
INSERT INTO `clinic_stock_batch` VALUES (294, 195, 'BL20290110001', '2029-01-10', 170, '2026-03-25 09:00:00', '2026-03-25 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (295, 196, 'BL20270720001', '2027-07-20', 200, '2026-02-08 09:30:00', '2026-02-08 09:30:00');
INSERT INTO `clinic_stock_batch` VALUES (296, 196, 'BL20281205001', '2028-12-05', 200, '2026-03-12 10:00:00', '2026-03-12 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (297, 197, 'BL20270625001', '2027-06-25', 190, '2026-02-12 08:00:00', '2026-02-12 08:00:00');
INSERT INTO `clinic_stock_batch` VALUES (298, 197, 'BL20260320001', '2026-03-20', 190, '2025-09-18 09:30:00', '2025-09-18 09:30:00');
INSERT INTO `clinic_stock_batch` VALUES (299, 198, 'BL20270830001', '2027-08-30', 130, '2026-02-18 09:00:00', '2026-02-18 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (300, 198, 'BL20290125001', '2029-01-25', 130, '2026-03-20 11:00:00', '2026-03-20 11:00:00');
INSERT INTO `clinic_stock_batch` VALUES (301, 199, 'BL20270910001', '2027-09-10', 120, '2026-02-28 10:00:00', '2026-02-28 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (302, 199, 'BL20281210001', '2028-12-10', 120, '2026-03-28 09:30:00', '2026-03-28 09:30:00');
INSERT INTO `clinic_stock_batch` VALUES (303, 200, 'BL20270715001', '2027-07-15', 110, '2026-03-05 08:30:00', '2026-03-05 08:30:00');
INSERT INTO `clinic_stock_batch` VALUES (304, 200, 'BL20260225001', '2026-02-25', 110, '2025-08-22 10:00:00', '2025-08-22 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (305, 201, 'BL20270531001', '2027-05-31', 200, '2026-02-05 09:00:00', '2026-02-05 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (306, 201, 'BL20290120001', '2029-01-20', 200, '2026-03-15 10:00:00', '2026-03-15 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (307, 202, 'BL20271231001', '2027-12-31', 250, '2026-02-10 08:30:00', '2026-02-10 08:30:00');
INSERT INTO `clinic_stock_batch` VALUES (308, 202, 'BL20281215001', '2028-12-15', 250, '2026-03-18 09:30:00', '2026-03-18 09:30:00');
INSERT INTO `clinic_stock_batch` VALUES (309, 203, 'BL20270620001', '2027-06-20', 230, '2026-02-15 09:00:00', '2026-02-15 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (310, 203, 'BL20260325001', '2026-03-25', 220, '2025-09-22 08:00:00', '2025-09-22 08:00:00');
INSERT INTO `clinic_stock_batch` VALUES (311, 204, 'BL20270715001', '2027-07-15', 140, '2026-02-22 10:00:00', '2026-02-22 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (312, 204, 'BL20281205001', '2028-12-05', 140, '2026-03-20 11:00:00', '2026-03-20 11:00:00');
INSERT INTO `clinic_stock_batch` VALUES (313, 205, 'BL20270825001', '2027-08-25', 160, '2026-02-25 08:30:00', '2026-02-25 08:30:00');
INSERT INTO `clinic_stock_batch` VALUES (314, 205, 'BL20290112001', '2029-01-12', 160, '2026-03-25 09:30:00', '2026-03-25 09:30:00');
INSERT INTO `clinic_stock_batch` VALUES (315, 206, 'BL20270910001', '2027-09-10', 150, '2026-03-01 09:00:00', '2026-03-01 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (316, 206, 'BL20260218001', '2026-02-18', 150, '2025-08-15 10:00:00', '2025-08-15 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (317, 207, 'BL20270630001', '2027-06-30', 190, '2026-02-08 08:00:00', '2026-02-08 08:00:00');
INSERT INTO `clinic_stock_batch` VALUES (318, 207, 'BL20281210001', '2028-12-10', 190, '2026-03-12 09:30:00', '2026-03-12 09:30:00');
INSERT INTO `clinic_stock_batch` VALUES (319, 208, 'BL20270525001', '2027-05-25', 175, '2026-02-12 09:00:00', '2026-02-12 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (320, 208, 'BL20290115001', '2029-01-15', 175, '2026-03-15 10:30:00', '2026-03-15 10:30:00');
INSERT INTO `clinic_stock_batch` VALUES (321, 209, 'BL20271215001', '2027-12-15', 200, '2026-02-18 10:00:00', '2026-02-18 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (322, 209, 'BL20260305001', '2026-03-05', 200, '2025-09-02 08:30:00', '2025-09-02 08:30:00');
INSERT INTO `clinic_stock_batch` VALUES (323, 210, 'BL20270620001', '2027-06-20', 190, '2026-02-28 09:00:00', '2026-02-28 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (324, 210, 'BL20281225001', '2028-12-25', 190, '2026-03-22 11:00:00', '2026-03-22 11:00:00');
INSERT INTO `clinic_stock_batch` VALUES (325, 211, 'BL20270515001', '2027-05-15', 225, '2026-02-05 08:30:00', '2026-02-05 08:30:00');
INSERT INTO `clinic_stock_batch` VALUES (326, 211, 'BL20281210001', '2028-12-10', 225, '2026-03-10 09:00:00', '2026-03-10 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (327, 212, 'BL20270630001', '2027-06-30', 140, '2026-02-12 09:00:00', '2026-02-12 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (328, 212, 'BL20290120001', '2029-01-20', 140, '2026-03-18 10:00:00', '2026-03-18 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (329, 213, 'BL20270520001', '2027-05-20', 250, '2026-02-15 08:00:00', '2026-02-15 08:00:00');
INSERT INTO `clinic_stock_batch` VALUES (330, 213, 'BL20281215001', '2028-12-15', 250, '2026-03-20 09:30:00', '2026-03-20 09:30:00');
INSERT INTO `clinic_stock_batch` VALUES (331, 214, 'BL20270815001', '2027-08-15', 90, '2026-02-22 09:00:00', '2026-02-22 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (332, 214, 'BL20260310001', '2026-03-10', 90, '2025-09-08 08:30:00', '2025-09-08 08:30:00');
INSERT INTO `clinic_stock_batch` VALUES (333, 215, 'BL20270725001', '2027-07-25', 120, '2026-02-25 10:00:00', '2026-02-25 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (334, 215, 'BL20281205001', '2028-12-05', 120, '2026-03-22 11:00:00', '2026-03-22 11:00:00');
INSERT INTO `clinic_stock_batch` VALUES (335, 216, 'BL20270920001', '2027-09-20', 100, '2026-03-01 08:30:00', '2026-03-01 08:30:00');
INSERT INTO `clinic_stock_batch` VALUES (336, 216, 'BL20260210001', '2026-02-10', 100, '2025-08-10 09:00:00', '2025-08-10 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (337, 217, 'BL20270830001', '2027-08-30', 140, '2026-02-08 09:00:00', '2026-02-08 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (338, 217, 'BL20290115001', '2029-01-15', 140, '2026-03-15 10:00:00', '2026-03-15 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (339, 218, 'BL20270715001', '2027-07-15', 160, '2026-02-12 08:30:00', '2026-02-12 08:30:00');
INSERT INTO `clinic_stock_batch` VALUES (340, 218, 'BL20281210001', '2028-12-10', 160, '2026-03-10 09:30:00', '2026-03-10 09:30:00');
INSERT INTO `clinic_stock_batch` VALUES (341, 219, 'BL20270625001', '2027-06-25', 80, '2026-02-18 09:00:00', '2026-02-18 09:00:00');
INSERT INTO `clinic_stock_batch` VALUES (342, 219, 'BL20290110001', '2029-01-10', 80, '2026-03-20 10:30:00', '2026-03-20 10:30:00');
INSERT INTO `clinic_stock_batch` VALUES (343, 220, 'BL20270915001', '2027-09-15', 40, '2026-02-28 10:00:00', '2026-02-28 10:00:00');
INSERT INTO `clinic_stock_batch` VALUES (344, 220, 'BL20260320001', '2026-03-20', 40, '2025-09-18 08:00:00', '2025-09-18 08:00:00');
INSERT INTO `clinic_stock_batch` VALUES (345, 221, '2026-04-01', '2028-10-01', 10, '2026-04-01 19:51:15', '2026-04-01 19:51:15');
INSERT INTO `clinic_stock_batch` VALUES (346, 221, '2026-04-01', '2026-04-30', 20, '2026-04-01 19:51:31', '2026-04-01 19:51:31');
INSERT INTO `clinic_stock_batch` VALUES (348, 222, '222', '2026-04-03', 10, '2026-04-03 00:54:20', '2026-04-03 00:54:20');
INSERT INTO `clinic_stock_batch` VALUES (349, 100, 'AUTO-20260403-01', '2027-12-31', 11, '2026-04-03 01:26:47', '2026-04-03 01:26:47');

-- ----------------------------
-- Table structure for clinic_stock_record
-- ----------------------------
DROP TABLE IF EXISTS `clinic_stock_record`;
CREATE TABLE `clinic_stock_record`  (
  `record_id` bigint NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `medicine_id` bigint NOT NULL COMMENT '药品ID',
  `medicine_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '药品名称',
  `operation_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '操作类型：in, out, check',
  `quantity` int NOT NULL COMMENT '数量',
  `before_stock` int NULL DEFAULT NULL COMMENT '操作前库存',
  `after_stock` int NULL DEFAULT NULL COMMENT '操作后库存',
  `supplier` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '供应商（入库用）',
  `purchase_price` decimal(10, 2) NULL DEFAULT NULL COMMENT '进货价格',
  `batch_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '批号',
  `expiry_date` date NULL DEFAULT NULL COMMENT '有效期',
  `operator_id` bigint NULL DEFAULT NULL COMMENT '操作人ID',
  `operator_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作人姓名',
  `patient_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '患者姓名（出库用）',
  `patient_id` bigint NULL DEFAULT NULL COMMENT '患者档案ID',
  `doctor_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '医生姓名（出库用）',
  `doctor_id` bigint NULL DEFAULT NULL COMMENT '医生用户ID',
  `related_record_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '关联记录ID',
  `related_record_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '关联记录类型',
  `is_pack_medicine` tinyint(1) NULL DEFAULT 0 COMMENT '是否包药（1=包药，0=普通出库）',
  `pack_items` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '包药明细JSON（is_pack_medicine=1时使用）',
  `remark` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '备注',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`record_id`) USING BTREE,
  INDEX `idx_medicine_id`(`medicine_id`) USING BTREE,
  INDEX `idx_operation_type`(`operation_type`) USING BTREE,
  INDEX `idx_create_time`(`create_time`) USING BTREE,
  INDEX `idx_clinic_stock_record_patient_id`(`patient_id`) USING BTREE,
  INDEX `idx_clinic_stock_record_doctor_id`(`doctor_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 197 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '库存记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of clinic_stock_record
-- ----------------------------
INSERT INTO `clinic_stock_record` VALUES (100, 100, '复方感冒灵颗粒(白云山)', 'in', 100, 200, 300, '国药控股', 12.00, 'B2027A002', '2027-08-20', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '常规入库', '2026-03-22 17:23:23');
INSERT INTO `clinic_stock_record` VALUES (101, 105, '阿莫西林胶囊(联邦制药)', 'in', 200, 300, 500, '国药控股', 14.00, 'B2027F001', '2027-06-25', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '常规入库', '2026-03-23 17:23:23');
INSERT INTO `clinic_stock_record` VALUES (102, 100, '复方感冒灵颗粒(白云山)', 'out', 3, 303, 300, NULL, NULL, 'B2027A001', '2027-06-15', 101, '李医生', '赵明', NULL, '李医生', NULL, '100', 'medical', 0, NULL, '处方发药', '2026-03-29 17:23:23');
INSERT INTO `clinic_stock_record` VALUES (103, 119, '布洛芬缓释胶囊(中美史克)', 'out', 2, 202, 200, NULL, NULL, 'B2027T001', '2027-06-30', 101, '李医生', '赵明', NULL, '李医生', NULL, '100', 'medical', 0, NULL, '处方发药', '2026-03-29 17:23:23');
INSERT INTO `clinic_stock_record` VALUES (104, 114, '奥美拉唑肠溶胶囊(阿斯利康)', 'out', 14, 294, 280, NULL, NULL, 'B2027O001', '2027-06-22', 101, '李医生', '钱红', NULL, '李医生', NULL, '101', 'medical', 0, NULL, '处方发药', '2026-03-30 17:23:23');
INSERT INTO `clinic_stock_record` VALUES (105, 106, '头孢克肟分散片(石药集团)', 'out', 5, 325, 320, NULL, NULL, 'B2027G001', '2027-07-15', 102, '王医生', '孙伟', NULL, '王医生', NULL, '102', 'medical', 0, NULL, '处方发药', '2026-03-31 17:23:23');
INSERT INTO `clinic_stock_record` VALUES (106, 118, '碘伏消毒液(利康)', 'check', 0, 200, 200, NULL, NULL, 'B2027S001', '2027-05-31', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '库存盘点正常', '2026-04-01 17:23:23');
INSERT INTO `clinic_stock_record` VALUES (107, 100, '复方感冒灵颗粒(白云山)', 'in', 100, 200, 300, '国药控股有限公司', 12.00, 'BL20270820001', '2027-08-20', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '新批次入库', '2026-02-10 09:00:00');
INSERT INTO `clinic_stock_record` VALUES (108, 100, '复方感冒灵颗粒(白云山)', 'in', 80, 300, 380, '国药控股有限公司', 12.00, 'BL20260615001', '2026-06-15', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '新批次入库', '2026-02-15 10:00:00');
INSERT INTO `clinic_stock_record` VALUES (109, 101, '感冒灵颗粒(999)', 'in', 200, 150, 350, '华润三九医药股份有限公司', 10.00, 'BL20270520001', '2027-05-20', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '新批次入库', '2026-02-05 09:00:00');
INSERT INTO `clinic_stock_record` VALUES (110, 102, '连花清瘟胶囊(以岭)', 'in', 150, 130, 280, '石家庄以岭药业股份有限公司', 19.00, 'BL20270810001', '2027-08-10', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '新批次入库', '2026-01-20 10:00:00');
INSERT INTO `clinic_stock_record` VALUES (111, 105, '阿莫西林胶囊(联邦制药)', 'in', 250, 250, 500, '珠海联邦制药股份有限公司', 14.00, 'BL20270625001', '2027-06-25', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '新批次入库', '2026-02-01 09:00:00');
INSERT INTO `clinic_stock_record` VALUES (112, 106, '头孢克肟分散片(石药集团)', 'in', 180, 140, 320, '石药集团中诺药业(石家庄)有限公司', 22.00, 'BL20270715001', '2027-07-15', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '新批次入库', '2026-01-25 10:00:00');
INSERT INTO `clinic_stock_record` VALUES (113, 111, '维生素C片(华中药业)', 'in', 300, 200, 500, '华中药业股份有限公司', 4.00, 'BL20271230001', '2027-12-30', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '新批次入库', '2026-02-08 09:00:00');
INSERT INTO `clinic_stock_record` VALUES (114, 114, '奥美拉唑肠溶胶囊(阿斯利康)', 'in', 150, 130, 280, '阿斯利康制药有限公司', 35.00, 'BL20270622001', '2027-06-22', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '新批次入库', '2026-02-15 10:00:00');
INSERT INTO `clinic_stock_record` VALUES (115, 117, '云南白药气雾剂(云南白药)', 'in', 100, 50, 150, '云南白药集团股份有限公司', 28.00, 'BL20271231001', '2027-12-31', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '新批次入库', '2026-02-05 09:00:00');
INSERT INTO `clinic_stock_record` VALUES (116, 118, '碘伏消毒液(利尔康)', 'in', 120, 80, 200, '山东利尔康医疗科技股份有限公司', 9.00, 'BL20270531001', '2027-05-31', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '新批次入库', '2026-01-12 11:00:00');
INSERT INTO `clinic_stock_record` VALUES (117, 119, '布洛芬缓释胶囊(中美史克)', 'in', 120, 80, 200, '中美天津史克制药有限公司', 22.00, 'BL20270630001', '2027-06-30', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '新批次入库', '2026-02-08 09:00:00');
INSERT INTO `clinic_stock_record` VALUES (118, 120, '氨咖黄敏胶囊(感冒灵)', 'in', 250, 150, 400, '华润三九医药股份有限公司', 6.50, 'BL20270315001', '2027-03-15', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '新批次入库', '2026-01-22 08:00:00');
INSERT INTO `clinic_stock_record` VALUES (119, 121, '蒙脱石散(博福-益普生)', 'in', 150, 150, 300, '博福-益普生(天津)制药有限公司', 20.00, 'BL20270512001', '2027-05-12', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '新批次入库', '2026-02-10 09:00:00');
INSERT INTO `clinic_stock_record` VALUES (120, 122, '阿莫西林克拉维酸钾颗粒(联邦制药)', 'in', 120, 130, 250, '珠海联邦制药股份有限公司', 26.00, 'BL20270615001', '2027-06-15', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '新批次入库', '2026-02-05 08:30:00');
INSERT INTO `clinic_stock_record` VALUES (121, 125, '布洛芬颗粒(扬子江)', 'in', 180, 170, 350, '扬子江药业集团有限公司', 15.00, 'BL20270630001', '2027-06-30', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '新批次入库', '2026-02-15 08:00:00');
INSERT INTO `clinic_stock_record` VALUES (122, 136, '头孢氨苄胶囊(华北制药)', 'in', 160, 160, 320, '华北制药股份有限公司', 18.00, 'BL20270625001', '2027-06-25', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '新批次入库', '2026-02-15 10:00:00');
INSERT INTO `clinic_stock_record` VALUES (123, 142, '奥美拉唑肠溶胶囊(阿斯利康)', 'in', 150, 150, 300, '阿斯利康制药有限公司', 35.00, 'BL20270622001', '2027-06-22', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '新批次入库', '2026-02-15 08:30:00');
INSERT INTO `clinic_stock_record` VALUES (124, 144, '铝碳酸镁片(拜耳)', 'in', 130, 120, 250, '拜耳医药保健有限公司', 22.00, 'BL20270630001', '2027-06-30', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '新批次入库', '2026-02-20 09:00:00');
INSERT INTO `clinic_stock_record` VALUES (125, 151, '硝苯地平缓释片(拜耳)', 'in', 140, 140, 280, '拜耳医药保健有限公司', 30.00, 'BL20270630001', '2027-06-30', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '新批次入库', '2026-02-12 09:00:00');
INSERT INTO `clinic_stock_record` VALUES (126, 152, '贝那普利片(诺华)', 'in', 100, 100, 200, '诺华制药有限公司', 38.00, 'BL20270725001', '2027-07-25', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '新批次入库', '2026-02-18 08:30:00');
INSERT INTO `clinic_stock_record` VALUES (127, 156, '苯磺酸氨氯地平片(络活喜)', 'in', 150, 150, 300, '辉瑞制药有限公司', 28.00, 'BL20270730001', '2027-07-30', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '新批次入库', '2026-02-15 09:00:00');
INSERT INTO `clinic_stock_record` VALUES (128, 166, '0.9%氯化钠注射液250ml(科伦)', 'in', 400, 400, 800, '四川科伦药业股份有限公司', 2.50, 'BL20270615001', '2027-06-15', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '新批次入库', '2026-02-05 08:00:00');
INSERT INTO `clinic_stock_record` VALUES (129, 167, '5%葡萄糖注射液250ml(华润双鹤)', 'in', 380, 370, 750, '华润双鹤药业股份有限公司', 2.30, 'BL20270720001', '2027-07-20', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '新批次入库', '2026-02-08 09:00:00');
INSERT INTO `clinic_stock_record` VALUES (130, 169, '地塞米松磷酸钠注射液(仙琚制药)', 'in', 250, 250, 500, '浙江仙琚制药股份有限公司', 2.00, 'BL20270525001', '2027-05-25', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '新批次入库', '2026-02-15 10:00:00');
INSERT INTO `clinic_stock_record` VALUES (131, 170, '注射用头孢曲松钠(罗氏)', 'in', 150, 150, 300, '上海罗氏制药有限公司', 48.00, 'BL20270915001', '2027-09-15', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '新批次入库', '2026-02-22 09:00:00');
INSERT INTO `clinic_stock_record` VALUES (132, 181, '云南白药气雾剂(云南白药)', 'in', 100, 100, 200, '云南白药集团股份有限公司', 28.00, 'BL20271231001', '2027-12-31', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '新批次入库', '2026-02-05 09:00:00');
INSERT INTO `clinic_stock_record` VALUES (133, 182, '布地奈德鼻喷雾剂(阿斯利康)', 'in', 75, 75, 150, '阿斯利康制药有限公司', 55.00, 'BL20270630001', '2027-06-30', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '新批次入库', '2026-02-15 10:00:00');
INSERT INTO `clinic_stock_record` VALUES (134, 191, '抗病毒口服液(香雪)', 'in', 160, 160, 320, '香雪制药股份有限公司', 20.00, 'BL20270520001', '2027-05-20', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '新批次入库', '2026-02-10 08:00:00');
INSERT INTO `clinic_stock_record` VALUES (135, 192, '双黄连口服液(哈药集团)', 'in', 180, 170, 350, '哈药集团制药六厂', 22.00, 'BL20270425001', '2027-04-25', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '新批次入库', '2026-02-15 09:00:00');
INSERT INTO `clinic_stock_record` VALUES (136, 201, '碘伏消毒液(利尔康)', 'in', 200, 200, 400, '山东利尔康医疗科技股份有限公司', 9.00, 'BL20270531001', '2027-05-31', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '新批次入库', '2026-02-05 09:00:00');
INSERT INTO `clinic_stock_record` VALUES (137, 202, '酒精消毒液(利尔康)', 'in', 250, 250, 500, '山东利尔康医疗科技股份有限公司', 6.00, 'BL20271231001', '2027-12-31', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '新批次入库', '2026-02-10 08:30:00');
INSERT INTO `clinic_stock_record` VALUES (138, 100, '复方感冒灵颗粒(白云山)', 'out', 3, 303, 300, NULL, NULL, 'BL20260615001', '2026-06-15', 101, '李医生', '赵明', NULL, '李医生', NULL, '100', 'medical', 0, NULL, '处方发药', '2026-03-15 10:30:00');
INSERT INTO `clinic_stock_record` VALUES (139, 119, '布洛芬缓释胶囊(中美史克)', 'out', 2, 202, 200, NULL, NULL, 'BL20270630001', '2027-06-30', 101, '李医生', '赵明', NULL, '李医生', NULL, '100', 'medical', 0, NULL, '处方发药', '2026-03-15 10:30:00');
INSERT INTO `clinic_stock_record` VALUES (140, 144, '铝碳酸镁片(拜耳)', 'out', 4, 254, 250, NULL, NULL, 'BL20270630001', '2027-06-30', 101, '李医生', '钱红', NULL, '李医生', NULL, '101', 'medical', 0, NULL, '处方发药', '2026-03-20 15:00:00');
INSERT INTO `clinic_stock_record` VALUES (141, 142, '奥美拉唑肠溶胶囊(阿斯利康)', 'out', 2, 302, 300, NULL, NULL, 'BL20270622001', '2027-06-22', 101, '李医生', '钱红', NULL, '李医生', NULL, '101', 'medical', 0, NULL, '处方发药', '2026-03-20 15:00:00');
INSERT INTO `clinic_stock_record` VALUES (142, 106, '头孢克肟分散片(石药集团)', 'out', 5, 325, 320, NULL, NULL, 'BL20270715001', '2027-07-15', 103, '张医生', '孙伟', NULL, '张医生', NULL, '102', 'medical', 0, NULL, '处方发药', '2026-03-18 10:00:00');
INSERT INTO `clinic_stock_record` VALUES (143, 135, '999感冒灵颗粒(华润三九)', 'out', 3, 403, 400, NULL, NULL, 'BL20270315001', '2027-03-15', 102, '王医生', '李静', NULL, '王医生', NULL, '103', 'medical', 0, NULL, '处方发药', '2026-03-25 11:00:00');
INSERT INTO `clinic_stock_record` VALUES (144, 155, '辛伐他汀片(默沙东)', 'out', 2, 242, 240, NULL, NULL, 'BL20270620001', '2027-06-20', 103, '张医生', '周强', NULL, '张医生', NULL, '104', 'medical', 0, NULL, '处方发药', '2026-03-28 11:00:00');
INSERT INTO `clinic_stock_record` VALUES (145, 125, '布洛芬颗粒(扬子江)', 'out', 3, 353, 350, NULL, NULL, 'BL20270630001', '2027-06-30', 101, '李医生', '吴婷', NULL, '李医生', NULL, '105', 'medical', 0, NULL, '处方发药', '2026-04-01 15:00:00');
INSERT INTO `clinic_stock_record` VALUES (146, 201, '碘伏消毒液(利尔康)', 'out', 1, 401, 400, NULL, NULL, 'BL20270531001', '2027-05-31', 102, '王医生', '郑峰', NULL, '王医生', NULL, '106', 'medical', 0, NULL, '处方发药', '2026-04-02 09:30:00');
INSERT INTO `clinic_stock_record` VALUES (147, 156, '苯磺酸氨氯地平片(络活喜)', 'out', 1, 301, 300, NULL, NULL, 'BL20270730001', '2027-07-30', 101, '李医生', '王芳', NULL, '李医生', NULL, '107', 'medical', 0, NULL, '处方发药', '2026-04-07 15:00:00');
INSERT INTO `clinic_stock_record` VALUES (148, 116, '氯雷他定片(扬子江)', 'out', 1, 281, 280, NULL, NULL, 'BL20270515001', '2027-05-15', 102, '王医生', '何磊', NULL, '王医生', NULL, '108', 'medical', 0, NULL, '处方发药', '2026-04-08 10:00:00');
INSERT INTO `clinic_stock_record` VALUES (149, 182, '布地奈德鼻喷雾剂(阿斯利康)', 'out', 1, 151, 150, NULL, NULL, 'BL20270630001', '2027-06-30', 102, '王医生', '何磊', NULL, '王医生', NULL, '108', 'medical', 0, NULL, '处方发药', '2026-04-08 10:00:00');
INSERT INTO `clinic_stock_record` VALUES (150, 136, '头孢氨苄胶囊(华北制药)', 'out', 8, 328, 320, NULL, NULL, 'BL20270625001', '2027-06-25', 101, '李医生', '郭敏', NULL, '李医生', NULL, '109', 'medical', 0, NULL, '处方发药', '2026-04-12 11:00:00');
INSERT INTO `clinic_stock_record` VALUES (151, 181, '云南白药气雾剂(云南白药)', 'out', 1, 201, 200, NULL, NULL, 'BL20271231001', '2027-12-31', 103, '张医生', '陈旭', NULL, '张医生', NULL, '110', 'medical', 0, NULL, '处方发药', '2026-04-16 15:00:00');
INSERT INTO `clinic_stock_record` VALUES (152, 119, '布洛芬缓释胶囊(中美史克)', 'out', 3, 203, 200, NULL, NULL, 'BL20270630001', '2027-06-30', 103, '张医生', '陈旭', NULL, '张医生', NULL, '110', 'medical', 0, NULL, '处方发药', '2026-04-16 15:00:00');
INSERT INTO `clinic_stock_record` VALUES (153, 116, '氯雷他定片(扬子江)', 'out', 1, 280, 279, NULL, NULL, 'BL20270515001', '2027-05-15', 102, '王医生', '宋雨', NULL, '王医生', NULL, '111', 'medical', 0, NULL, '处方发药', '2026-04-12 16:00:00');
INSERT INTO `clinic_stock_record` VALUES (154, 152, '贝那普利片(诺华)', 'out', 1, 201, 200, NULL, NULL, 'BL20270725001', '2027-07-25', 101, '李医生', '赵明', NULL, '李医生', NULL, '100', 'medical', 0, NULL, '处方发药', '2026-04-01 10:00:00');
INSERT INTO `clinic_stock_record` VALUES (155, 142, '奥美拉唑肠溶胶囊(阿斯利康)', 'out', 2, 300, 298, NULL, NULL, 'BL20270622001', '2027-06-22', 101, '李医生', '钱红', NULL, '李医生', NULL, '101', 'medical', 0, NULL, '处方发药', '2026-04-04 11:00:00');
INSERT INTO `clinic_stock_record` VALUES (156, 155, '辛伐他汀片(默沙东)', 'out', 2, 240, 238, NULL, NULL, 'BL20270620001', '2027-06-20', 103, '张医生', '周强', NULL, '张医生', NULL, '104', 'medical', 0, NULL, '处方发药', '2026-04-15 11:00:00');
INSERT INTO `clinic_stock_record` VALUES (157, 125, '布洛芬颗粒(扬子江)', 'out', 3, 350, 347, NULL, NULL, 'BL20270630001', '2027-06-30', 103, '张医生', '吴婷', NULL, '张医生', NULL, '105', 'medical', 0, NULL, '处方发药', '2026-04-20 10:00:00');
INSERT INTO `clinic_stock_record` VALUES (158, 156, '苯磺酸氨氯地平片(络活喜)', 'out', 1, 300, 299, NULL, NULL, 'BL20270730001', '2027-07-30', 101, '李医生', '王芳', NULL, '李医生', NULL, '107', 'medical', 0, NULL, '处方发药', '2026-04-21 10:00:00');
INSERT INTO `clinic_stock_record` VALUES (159, 182, '布地奈德鼻喷雾剂(阿斯利康)', 'out', 1, 150, 149, NULL, NULL, 'BL20270630001', '2027-06-30', 103, '张医生', '何磊', NULL, '张医生', NULL, '108', 'medical', 0, NULL, '处方发药', '2026-04-23 10:00:00');
INSERT INTO `clinic_stock_record` VALUES (160, 181, '云南白药气雾剂(云南白药)', 'out', 1, 200, 199, NULL, NULL, 'BL20271231001', '2027-12-31', 102, '王医生', '陈旭', NULL, '王医生', NULL, '110', 'medical', 0, NULL, '处方发药', '2026-04-23 10:00:00');
INSERT INTO `clinic_stock_record` VALUES (161, 116, '氯雷他定片(扬子江)', 'out', 1, 279, 278, NULL, NULL, 'BL20270515001', '2027-05-15', 101, '李医生', '宋雨', NULL, '李医生', NULL, '111', 'medical', 0, NULL, '处方发药', '2026-04-19 11:00:00');
INSERT INTO `clinic_stock_record` VALUES (162, 100, '复方感冒灵颗粒(白云山)', 'check', 0, 380, 380, NULL, NULL, NULL, NULL, 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '库存盘点正常', '2026-03-25 10:00:00');
INSERT INTO `clinic_stock_record` VALUES (163, 101, '感冒灵颗粒(999)', 'check', 0, 350, 350, NULL, NULL, NULL, NULL, 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '库存盘点正常', '2026-03-25 10:30:00');
INSERT INTO `clinic_stock_record` VALUES (164, 102, '连花清瘟胶囊(以岭)', 'check', 0, 280, 280, NULL, NULL, NULL, NULL, 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '库存盘点正常', '2026-03-25 11:00:00');
INSERT INTO `clinic_stock_record` VALUES (165, 105, '阿莫西林胶囊(联邦制药)', 'check', 0, 500, 500, NULL, NULL, NULL, NULL, 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '库存盘点正常', '2026-03-25 11:30:00');
INSERT INTO `clinic_stock_record` VALUES (166, 106, '头孢克肟分散片(石药集团)', 'check', 0, 320, 320, NULL, NULL, NULL, NULL, 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '库存盘点正常', '2026-03-25 14:00:00');
INSERT INTO `clinic_stock_record` VALUES (167, 111, '维生素C片(华中药业)', 'check', 0, 500, 500, NULL, NULL, NULL, NULL, 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '库存盘点正常', '2026-03-25 14:30:00');
INSERT INTO `clinic_stock_record` VALUES (168, 114, '奥美拉唑肠溶胶囊(阿斯利康)', 'check', 0, 280, 280, NULL, NULL, NULL, NULL, 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '库存盘点正常', '2026-03-25 15:00:00');
INSERT INTO `clinic_stock_record` VALUES (169, 117, '云南白药气雾剂(云南白药)', 'check', 0, 150, 150, NULL, NULL, NULL, NULL, 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '库存盘点正常', '2026-03-25 15:30:00');
INSERT INTO `clinic_stock_record` VALUES (170, 118, '碘伏消毒液(利尔康)', 'check', 0, 200, 200, NULL, NULL, NULL, NULL, 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '库存盘点正常', '2026-03-25 16:00:00');
INSERT INTO `clinic_stock_record` VALUES (171, 119, '布洛芬缓释胶囊(中美史克)', 'check', 0, 200, 200, NULL, NULL, NULL, NULL, 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '库存盘点正常', '2026-03-25 16:30:00');
INSERT INTO `clinic_stock_record` VALUES (172, 120, '氨咖黄敏胶囊(感冒灵)', 'check', 0, 400, 400, NULL, NULL, NULL, NULL, 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '库存盘点正常', '2026-03-25 17:00:00');
INSERT INTO `clinic_stock_record` VALUES (173, 121, '蒙脱石散(博福-益普生)', 'check', 0, 300, 300, NULL, NULL, NULL, NULL, 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '库存盘点正常', '2026-03-26 09:00:00');
INSERT INTO `clinic_stock_record` VALUES (174, 122, '阿莫西林克拉维酸钾颗粒(联邦制药)', 'check', 0, 250, 250, NULL, NULL, NULL, NULL, 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '库存盘点正常', '2026-03-26 09:30:00');
INSERT INTO `clinic_stock_record` VALUES (175, 125, '布洛芬颗粒(扬子江)', 'check', 0, 350, 350, NULL, NULL, NULL, NULL, 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '库存盘点正常', '2026-03-26 10:00:00');
INSERT INTO `clinic_stock_record` VALUES (176, 136, '头孢氨苄胶囊(华北制药)', 'check', 0, 320, 320, NULL, NULL, NULL, NULL, 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '库存盘点正常', '2026-03-26 10:30:00');
INSERT INTO `clinic_stock_record` VALUES (177, 142, '奥美拉唑肠溶胶囊(阿斯利康)', 'check', 0, 300, 300, NULL, NULL, NULL, NULL, 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '库存盘点正常', '2026-03-26 11:00:00');
INSERT INTO `clinic_stock_record` VALUES (178, 144, '铝碳酸镁片(拜耳)', 'check', 0, 250, 250, NULL, NULL, NULL, NULL, 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '库存盘点正常', '2026-03-26 11:30:00');
INSERT INTO `clinic_stock_record` VALUES (179, 151, '硝苯地平缓释片(拜耳)', 'check', 0, 280, 280, NULL, NULL, NULL, NULL, 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '库存盘点正常', '2026-03-26 14:00:00');
INSERT INTO `clinic_stock_record` VALUES (180, 152, '贝那普利片(诺华)', 'check', 0, 200, 200, NULL, NULL, NULL, NULL, 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '库存盘点正常', '2026-03-26 14:30:00');
INSERT INTO `clinic_stock_record` VALUES (181, 156, '苯磺酸氨氯地平片(络活喜)', 'check', 0, 300, 300, NULL, NULL, NULL, NULL, 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '库存盘点正常', '2026-03-26 15:00:00');
INSERT INTO `clinic_stock_record` VALUES (182, 166, '0.9%氯化钠注射液250ml(科伦)', 'check', 0, 800, 800, NULL, NULL, NULL, NULL, 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '库存盘点正常', '2026-03-26 15:30:00');
INSERT INTO `clinic_stock_record` VALUES (183, 167, '5%葡萄糖注射液250ml(华润双鹤)', 'check', 0, 750, 750, NULL, NULL, NULL, NULL, 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '库存盘点正常', '2026-03-26 16:00:00');
INSERT INTO `clinic_stock_record` VALUES (184, 169, '地塞米松磷酸钠注射液(仙琚制药)', 'check', 0, 500, 500, NULL, NULL, NULL, NULL, 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '库存盘点正常', '2026-03-26 16:30:00');
INSERT INTO `clinic_stock_record` VALUES (185, 170, '注射用头孢曲松钠(罗氏)', 'check', 0, 300, 300, NULL, NULL, NULL, NULL, 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '库存盘点正常', '2026-03-26 17:00:00');
INSERT INTO `clinic_stock_record` VALUES (186, 181, '云南白药气雾剂(云南白药)', 'check', 0, 200, 200, NULL, NULL, NULL, NULL, 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '库存盘点正常', '2026-03-27 09:00:00');
INSERT INTO `clinic_stock_record` VALUES (187, 182, '布地奈德鼻喷雾剂(阿斯利康)', 'check', 0, 150, 150, NULL, NULL, NULL, NULL, 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '库存盘点正常', '2026-03-27 09:30:00');
INSERT INTO `clinic_stock_record` VALUES (188, 191, '抗病毒口服液(香雪)', 'check', 0, 320, 320, NULL, NULL, NULL, NULL, 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '库存盘点正常', '2026-03-27 10:00:00');
INSERT INTO `clinic_stock_record` VALUES (189, 192, '双黄连口服液(哈药集团)', 'check', 0, 350, 350, NULL, NULL, NULL, NULL, 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '库存盘点正常', '2026-03-27 10:30:00');
INSERT INTO `clinic_stock_record` VALUES (190, 201, '碘伏消毒液(利尔康)', 'check', 0, 400, 400, NULL, NULL, NULL, NULL, 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '库存盘点正常', '2026-03-27 11:00:00');
INSERT INTO `clinic_stock_record` VALUES (191, 202, '酒精消毒液(利尔康)', 'check', 0, 500, 500, NULL, NULL, NULL, NULL, 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, '库存盘点正常', '2026-03-27 11:30:00');
INSERT INTO `clinic_stock_record` VALUES (192, 100, '复方感冒灵颗粒(白云山)（广州白云山制药总厂）', 'out', 10, 300, 290, NULL, NULL, 'BL20260615001', '2026-06-15', 100, '诊所管理员', '钱红', NULL, NULL, NULL, '129', 'medical_record', NULL, NULL, NULL, '2026-04-01 18:32:41');
INSERT INTO `clinic_stock_record` VALUES (193, 104, '维C银翘片(贵州百灵)（贵州百灵企业集团制药股份有限公司）', 'out', 2, 450, 450, NULL, NULL, 'B2027E001', '2027-03-15', 1, '若依', '钱红', NULL, '张医生', NULL, '129', 'medical', 1, NULL, '每日3次 [包药不计库存]', '2026-04-01 18:36:34');
INSERT INTO `clinic_stock_record` VALUES (194, 104, '维C银翘片(贵州百灵)（贵州百灵企业集团制药股份有限公司）', 'out', 1, 450, 449, NULL, NULL, 'B2027E001', '2027-03-15', NULL, '若依', '包药损耗', NULL, '若依', NULL, NULL, NULL, 0, NULL, '包药损耗出库', '2026-04-01 18:54:00');
INSERT INTO `clinic_stock_record` VALUES (195, 221, '1', 'in', 10, 0, 10, NULL, NULL, '2026-04-01', '2028-10-01', 1, '若依', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-04-01 19:51:15');
INSERT INTO `clinic_stock_record` VALUES (196, 221, '1', 'in', 20, 10, 30, NULL, NULL, '2026-04-01', '2026-04-30', 1, '若依', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-04-01 19:51:31');
INSERT INTO `clinic_stock_record` VALUES (197, 222, '2', 'in', 10, 0, 10, NULL, NULL, '222', '2026-04-03', 1, '若依', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-04-03 00:54:20');
INSERT INTO `clinic_stock_record` VALUES (198, 104, '维C银翘片(贵州百灵)（贵州百灵企业集团制药股份有限公司）', 'out', 2, 449, 449, NULL, NULL, 'B2027E001', '2027-03-15', 1, '若依', '钱红', 101, '李医生', NULL, '131', 'medical_record', 1, '[{\"medicineId\":104,\"name\":\"维C银翘片(贵州百灵)（贵州百灵企业集团制药股份有限公司）\",\"specification\":\"12片*2板\",\"quantity\":1,\"batchId\":105,\"batchNumber\":\"B2027E001\"},{\"medicineId\":111,\"name\":\"维生素C片(华中药业)（华中药业股份有限公司）\",\"specification\":\"0.1g*100片\",\"quantity\":1,\"batchId\":133,\"batchNumber\":\"BL20271230001\"}]', '每日3次 [包药不计库存]', '2026-04-03 00:55:03');
INSERT INTO `clinic_stock_record` VALUES (199, 100, '复方感冒灵颗粒(白云山)（广州白云山制药总厂）', 'in', 11, 290, 301, 'Codex手测供应商', 12.34, 'AUTO-20260403-01', '2027-12-31', 100, '诊所管理员', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'opencli浏览器手测', '2026-04-03 01:26:47');
INSERT INTO `clinic_stock_record` VALUES (200, 100, '复方感冒灵颗粒(白云山)（广州白云山制药总厂）', 'out', 2, 301, 299, NULL, NULL, 'BL20260615001', '2026-06-15', 100, '诊所管理员', '浏览器手测患者', NULL, '浏览器手测医生', NULL, NULL, NULL, 0, NULL, 'opencli浏览器手测', '2026-04-03 01:30:42');

-- ----------------------------
-- Table structure for clinic_usage_record
-- ----------------------------
DROP TABLE IF EXISTS `clinic_usage_record`;
CREATE TABLE `clinic_usage_record`  (
  `usage_id` bigint NOT NULL AUTO_INCREMENT COMMENT '使用记录ID',
  `medicine_id` bigint NOT NULL COMMENT '药品ID',
  `medicine_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '药品名称',
  `specification` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '规格',
  `quantity` int NOT NULL COMMENT '数量',
  `patient_id` bigint NULL DEFAULT NULL COMMENT '患者ID',
  `patient_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '患者姓名',
  `medical_record_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '病历ID',
  `doctor_id` bigint NULL DEFAULT NULL COMMENT '医生ID',
  `doctor_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '医生姓名',
  `issue_time` datetime NULL DEFAULT NULL COMMENT '发药时间',
  `issuer_id` bigint NULL DEFAULT NULL COMMENT '发药人ID',
  `issuer_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '发药人姓名',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`usage_id`) USING BTREE,
  INDEX `idx_medicine_id`(`medicine_id`) USING BTREE,
  INDEX `idx_patient_id`(`patient_id`) USING BTREE,
  INDEX `idx_issue_time`(`issue_time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 104 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '药品使用记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of clinic_usage_record
-- ----------------------------
INSERT INTO `clinic_usage_record` VALUES (100, 100, '复方感冒灵颗粒(白云山)', '10g*9袋', 3, 100, '赵明', '100', 101, '李医生', '2026-03-29 17:23:23', 100, '诊所管理员', '2026-04-01 17:23:23');
INSERT INTO `clinic_usage_record` VALUES (101, 119, '布洛芬缓释胶囊(中美史克)', '0.3g*20粒', 2, 100, '赵明', '100', 101, '李医生', '2026-03-29 17:23:23', 100, '诊所管理员', '2026-04-01 17:23:23');
INSERT INTO `clinic_usage_record` VALUES (102, 114, '奥美拉唑肠溶胶囊(阿斯利康)', '20mg*14粒', 14, 101, '钱红', '101', 101, '李医生', '2026-03-30 17:23:23', 100, '诊所管理员', '2026-04-01 17:23:23');
INSERT INTO `clinic_usage_record` VALUES (103, 106, '头孢克肟分散片(石药集团)', '0.1g*6片', 5, 102, '孙伟', '102', 102, '王医生', '2026-03-31 17:23:23', 100, '诊所管理员', '2026-04-01 17:23:23');

-- ----------------------------
-- Table structure for gen_table
-- ----------------------------
DROP TABLE IF EXISTS `gen_table`;
CREATE TABLE `gen_table`  (
  `table_id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `table_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '表名称',
  `table_comment` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '表描述',
  `sub_table_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '关联子表的表名',
  `sub_table_fk_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '子表关联的外键名',
  `class_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '实体类名称',
  `tpl_category` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'crud' COMMENT '使用的模板（crud单表操作 tree树表操作 sub主子表操作）',
  `package_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成包路径',
  `module_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成模块名',
  `business_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成业务名',
  `function_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成功能名',
  `function_author` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '生成功能作者',
  `form_col_num` int NULL DEFAULT 1 COMMENT '表单布局（单列 双列 三列）',
  `gen_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '生成代码方式（0zip压缩包 1自定义路径）',
  `gen_path` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '/' COMMENT '生成路径（不填默认项目路径）',
  `options` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '其它生成选项',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`table_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '代码生成业务表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of gen_table
-- ----------------------------

-- ----------------------------
-- Table structure for gen_table_column
-- ----------------------------
DROP TABLE IF EXISTS `gen_table_column`;
CREATE TABLE `gen_table_column`  (
  `column_id` bigint NOT NULL AUTO_INCREMENT COMMENT '编号',
  `table_id` bigint NULL DEFAULT NULL COMMENT '归属表编号',
  `column_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '列名称',
  `column_comment` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '列描述',
  `column_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '列类型',
  `java_type` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'JAVA类型',
  `java_field` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'JAVA字段名',
  `is_pk` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否主键（1是）',
  `is_increment` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否自增（1是）',
  `is_required` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否必填（1是）',
  `is_insert` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否为插入字段（1是）',
  `is_edit` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否编辑字段（1是）',
  `is_list` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否列表字段（1是）',
  `is_query` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否查询字段（1是）',
  `query_type` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'EQ' COMMENT '查询方式（等于、不等于、大于、小于、范围）',
  `html_type` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '显示类型（文本框、文本域、下拉框、复选框、单选框、日期控件）',
  `dict_type` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典类型',
  `sort` int NULL DEFAULT NULL COMMENT '排序',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`column_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '代码生成业务表字段' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of gen_table_column
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_blob_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_blob_triggers`;
CREATE TABLE `qrtz_blob_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `blob_data` blob NULL COMMENT '存放持久化Trigger对象',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  CONSTRAINT `qrtz_blob_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Blob类型的触发器表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_blob_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_calendars
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_calendars`;
CREATE TABLE `qrtz_calendars`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `calendar_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '日历名称',
  `calendar` blob NOT NULL COMMENT '存放持久化calendar对象',
  PRIMARY KEY (`sched_name`, `calendar_name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '日历信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_calendars
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_cron_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_cron_triggers`;
CREATE TABLE `qrtz_cron_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `cron_expression` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'cron表达式',
  `time_zone_id` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '时区',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  CONSTRAINT `qrtz_cron_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Cron类型的触发器表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_cron_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_fired_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_fired_triggers`;
CREATE TABLE `qrtz_fired_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `entry_id` varchar(95) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度器实例id',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `instance_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度器实例名',
  `fired_time` bigint NOT NULL COMMENT '触发的时间',
  `sched_time` bigint NOT NULL COMMENT '定时器制定的时间',
  `priority` int NOT NULL COMMENT '优先级',
  `state` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '状态',
  `job_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '任务名称',
  `job_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '任务组名',
  `is_nonconcurrent` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否并发',
  `requests_recovery` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '是否接受恢复执行',
  PRIMARY KEY (`sched_name`, `entry_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '已触发的触发器表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_fired_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_job_details
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_job_details`;
CREATE TABLE `qrtz_job_details`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `job_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务名称',
  `job_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务组名',
  `description` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '相关介绍',
  `job_class_name` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '执行任务类名称',
  `is_durable` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '是否持久化',
  `is_nonconcurrent` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '是否并发',
  `is_update_data` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '是否更新数据',
  `requests_recovery` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '是否接受恢复执行',
  `job_data` blob NULL COMMENT '存放持久化job对象',
  PRIMARY KEY (`sched_name`, `job_name`, `job_group`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '任务详细信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_job_details
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_locks
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_locks`;
CREATE TABLE `qrtz_locks`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `lock_name` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '悲观锁名称',
  PRIMARY KEY (`sched_name`, `lock_name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '存储的悲观锁信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_locks
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_paused_trigger_grps
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_paused_trigger_grps`;
CREATE TABLE `qrtz_paused_trigger_grps`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  PRIMARY KEY (`sched_name`, `trigger_group`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '暂停的触发器表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_paused_trigger_grps
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_scheduler_state
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_scheduler_state`;
CREATE TABLE `qrtz_scheduler_state`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `instance_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '实例名称',
  `last_checkin_time` bigint NOT NULL COMMENT '上次检查时间',
  `checkin_interval` bigint NOT NULL COMMENT '检查间隔时间',
  PRIMARY KEY (`sched_name`, `instance_name`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '调度器状态表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_scheduler_state
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_simple_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_simple_triggers`;
CREATE TABLE `qrtz_simple_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `repeat_count` bigint NOT NULL COMMENT '重复的次数统计',
  `repeat_interval` bigint NOT NULL COMMENT '重复的间隔时间',
  `times_triggered` bigint NOT NULL COMMENT '已经触发的次数',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  CONSTRAINT `qrtz_simple_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '简单触发器的信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_simple_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_simprop_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_simprop_triggers`;
CREATE TABLE `qrtz_simprop_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_name的外键',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_triggers表trigger_group的外键',
  `str_prop_1` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'String类型的trigger的第一个参数',
  `str_prop_2` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'String类型的trigger的第二个参数',
  `str_prop_3` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'String类型的trigger的第三个参数',
  `int_prop_1` int NULL DEFAULT NULL COMMENT 'int类型的trigger的第一个参数',
  `int_prop_2` int NULL DEFAULT NULL COMMENT 'int类型的trigger的第二个参数',
  `long_prop_1` bigint NULL DEFAULT NULL COMMENT 'long类型的trigger的第一个参数',
  `long_prop_2` bigint NULL DEFAULT NULL COMMENT 'long类型的trigger的第二个参数',
  `dec_prop_1` decimal(13, 4) NULL DEFAULT NULL COMMENT 'decimal类型的trigger的第一个参数',
  `dec_prop_2` decimal(13, 4) NULL DEFAULT NULL COMMENT 'decimal类型的trigger的第二个参数',
  `bool_prop_1` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'Boolean类型的trigger的第一个参数',
  `bool_prop_2` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'Boolean类型的trigger的第二个参数',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  CONSTRAINT `qrtz_simprop_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `trigger_name`, `trigger_group`) REFERENCES `qrtz_triggers` (`sched_name`, `trigger_name`, `trigger_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '同步机制的行锁表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_simprop_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_triggers`;
CREATE TABLE `qrtz_triggers`  (
  `sched_name` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调度名称',
  `trigger_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '触发器的名字',
  `trigger_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '触发器所属组的名字',
  `job_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_job_details表job_name的外键',
  `job_group` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'qrtz_job_details表job_group的外键',
  `description` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '相关介绍',
  `next_fire_time` bigint NULL DEFAULT NULL COMMENT '上一次触发时间（毫秒）',
  `prev_fire_time` bigint NULL DEFAULT NULL COMMENT '下一次触发时间（默认为-1表示不触发）',
  `priority` int NULL DEFAULT NULL COMMENT '优先级',
  `trigger_state` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '触发器状态',
  `trigger_type` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '触发器的类型',
  `start_time` bigint NOT NULL COMMENT '开始时间',
  `end_time` bigint NULL DEFAULT NULL COMMENT '结束时间',
  `calendar_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '日程表名称',
  `misfire_instr` smallint NULL DEFAULT NULL COMMENT '补偿执行的策略',
  `job_data` blob NULL COMMENT '存放持久化job对象',
  PRIMARY KEY (`sched_name`, `trigger_name`, `trigger_group`) USING BTREE,
  INDEX `sched_name`(`sched_name`, `job_name`, `job_group`) USING BTREE,
  CONSTRAINT `qrtz_triggers_ibfk_1` FOREIGN KEY (`sched_name`, `job_name`, `job_group`) REFERENCES `qrtz_job_details` (`sched_name`, `job_name`, `job_group`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '触发器详细信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of qrtz_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for sys_config
-- ----------------------------
DROP TABLE IF EXISTS `sys_config`;
CREATE TABLE `sys_config`  (
  `config_id` int NOT NULL AUTO_INCREMENT COMMENT '参数主键',
  `config_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '参数名称',
  `config_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '参数键名',
  `config_value` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '参数键值',
  `config_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'N' COMMENT '系统内置（Y是 N否）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`config_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '参数配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_config
-- ----------------------------
INSERT INTO `sys_config` VALUES (1, '主框架页-默认皮肤样式名称', 'sys.index.skinName', 'skin-blue', 'Y', 'admin', '2026-04-01 17:23:08', '', NULL, '蓝色 skin-blue、绿色 skin-green、紫色 skin-purple、红色 skin-red、黄色 skin-yellow');
INSERT INTO `sys_config` VALUES (2, '用户管理-账号初始密码', 'sys.user.initPassword', '123456', 'Y', 'admin', '2026-04-01 17:23:08', '', NULL, '初始化密码 123456');
INSERT INTO `sys_config` VALUES (3, '主框架页-侧边栏主题', 'sys.index.sideTheme', 'theme-dark', 'Y', 'admin', '2026-04-01 17:23:08', '', NULL, '深黑主题theme-dark，浅色主题theme-light，深蓝主题theme-blue');
INSERT INTO `sys_config` VALUES (4, '账号自助-是否开启用户注册功能', 'sys.account.registerUser', 'false', 'Y', 'admin', '2026-04-01 17:23:08', '', NULL, '是否开启注册用户功能（true开启，false关闭）');
INSERT INTO `sys_config` VALUES (5, '用户管理-密码字符范围', 'sys.account.chrtype', '0', 'Y', 'admin', '2026-04-01 17:23:08', '', NULL, '默认任意字符范围，0任意（密码可以输入任意字符），1数字（密码只能为0-9数字），2英文字母（密码只能为a-z和A-Z字母），3字母和数字（密码必须包含字母，数字）,4字母数字和特殊字符（目前支持的特殊字符包括：~!@#$%^&*()-=_+）');
INSERT INTO `sys_config` VALUES (6, '用户管理-初始密码修改策略', 'sys.account.initPasswordModify', '1', 'Y', 'admin', '2026-04-01 17:23:08', '', NULL, '0：初始密码修改策略关闭，没有任何提示，1：提醒用户，如果未修改初始密码，则在登录时就会提醒修改密码对话框');
INSERT INTO `sys_config` VALUES (7, '用户管理-账号密码更新周期', 'sys.account.passwordValidateDays', '0', 'Y', 'admin', '2026-04-01 17:23:08', '', NULL, '密码更新周期（填写数字，数据初始化值为0不限制，若修改必须为大于0小于365的正整数），如果超过这个周期登录系统时，则在登录时就会提醒修改密码对话框');
INSERT INTO `sys_config` VALUES (8, '主框架页-菜单导航显示风格', 'sys.index.menuStyle', 'default', 'Y', 'admin', '2026-04-01 17:23:08', '', NULL, '菜单导航显示风格（default为左侧导航菜单，topnav为顶部导航菜单）');
INSERT INTO `sys_config` VALUES (9, '主框架页-是否开启页脚', 'sys.index.footer', 'true', 'Y', 'admin', '2026-04-01 17:23:08', '', NULL, '是否开启底部页脚显示（true显示，false隐藏）');
INSERT INTO `sys_config` VALUES (10, '主框架页-是否开启页签', 'sys.index.tagsView', 'true', 'Y', 'admin', '2026-04-01 17:23:08', '', NULL, '是否开启菜单多页签显示（true显示，false隐藏）');
INSERT INTO `sys_config` VALUES (11, '用户登录-黑名单列表', 'sys.login.blackIPList', '', 'Y', 'admin', '2026-04-01 17:23:08', '', NULL, '设置登录IP黑名单限制，多个匹配项以;分隔，支持匹配（*通配、网段）');

-- ----------------------------
-- Table structure for sys_dept
-- ----------------------------
DROP TABLE IF EXISTS `sys_dept`;
CREATE TABLE `sys_dept`  (
  `dept_id` bigint NOT NULL AUTO_INCREMENT COMMENT '部门id',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父部门id',
  `ancestors` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '祖级列表',
  `dept_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '部门名称',
  `order_num` int NULL DEFAULT 0 COMMENT '显示顺序',
  `leader` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '负责人',
  `phone` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '联系电话',
  `email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '邮箱',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '部门状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`dept_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 200 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '部门表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dept
-- ----------------------------
INSERT INTO `sys_dept` VALUES (100, 0, '0', '若依科技', 0, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-04-01 17:23:08', '', NULL);
INSERT INTO `sys_dept` VALUES (101, 100, '0,100', '深圳总公司', 1, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-04-01 17:23:08', '', NULL);
INSERT INTO `sys_dept` VALUES (102, 100, '0,100', '长沙分公司', 2, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-04-01 17:23:08', '', NULL);
INSERT INTO `sys_dept` VALUES (103, 101, '0,100,101', '研发部门', 1, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-04-01 17:23:08', '', NULL);
INSERT INTO `sys_dept` VALUES (104, 101, '0,100,101', '市场部门', 2, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-04-01 17:23:08', '', NULL);
INSERT INTO `sys_dept` VALUES (105, 101, '0,100,101', '测试部门', 3, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-04-01 17:23:08', '', NULL);
INSERT INTO `sys_dept` VALUES (106, 101, '0,100,101', '财务部门', 4, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-04-01 17:23:08', '', NULL);
INSERT INTO `sys_dept` VALUES (107, 101, '0,100,101', '运维部门', 5, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-04-01 17:23:08', '', NULL);
INSERT INTO `sys_dept` VALUES (108, 102, '0,100,102', '市场部门', 1, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-04-01 17:23:08', '', NULL);
INSERT INTO `sys_dept` VALUES (109, 102, '0,100,102', '财务部门', 2, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2026-04-01 17:23:08', '', NULL);

-- ----------------------------
-- Table structure for sys_dict_data
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_data`;
CREATE TABLE `sys_dict_data`  (
  `dict_code` bigint NOT NULL AUTO_INCREMENT COMMENT '字典编码',
  `dict_sort` int NULL DEFAULT 0 COMMENT '字典排序',
  `dict_label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典标签',
  `dict_value` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典键值',
  `dict_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典类型',
  `css_class` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '样式属性（其他样式扩展）',
  `list_class` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '表格回显样式',
  `is_default` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT 'N' COMMENT '是否默认（Y是 N否）',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`dict_code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '字典数据表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dict_data
-- ----------------------------
INSERT INTO `sys_dict_data` VALUES (1, 1, '男', '0', 'sys_user_sex', '', '', 'Y', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '性别男');
INSERT INTO `sys_dict_data` VALUES (2, 2, '女', '1', 'sys_user_sex', '', '', 'N', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '性别女');
INSERT INTO `sys_dict_data` VALUES (3, 3, '未知', '2', 'sys_user_sex', '', '', 'N', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '性别未知');
INSERT INTO `sys_dict_data` VALUES (4, 1, '显示', '0', 'sys_show_hide', '', 'primary', 'Y', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '显示菜单');
INSERT INTO `sys_dict_data` VALUES (5, 2, '隐藏', '1', 'sys_show_hide', '', 'danger', 'N', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '隐藏菜单');
INSERT INTO `sys_dict_data` VALUES (6, 1, '正常', '0', 'sys_normal_disable', '', 'primary', 'Y', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (7, 2, '停用', '1', 'sys_normal_disable', '', 'danger', 'N', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '停用状态');
INSERT INTO `sys_dict_data` VALUES (8, 1, '正常', '0', 'sys_job_status', '', 'primary', 'Y', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (9, 2, '暂停', '1', 'sys_job_status', '', 'danger', 'N', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '停用状态');
INSERT INTO `sys_dict_data` VALUES (10, 1, '默认', 'DEFAULT', 'sys_job_group', '', '', 'Y', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '默认分组');
INSERT INTO `sys_dict_data` VALUES (11, 2, '系统', 'SYSTEM', 'sys_job_group', '', '', 'N', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '系统分组');
INSERT INTO `sys_dict_data` VALUES (12, 1, '是', 'Y', 'sys_yes_no', '', 'primary', 'Y', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '系统默认是');
INSERT INTO `sys_dict_data` VALUES (13, 2, '否', 'N', 'sys_yes_no', '', 'danger', 'N', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '系统默认否');
INSERT INTO `sys_dict_data` VALUES (14, 1, '通知', '1', 'sys_notice_type', '', 'warning', 'Y', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '通知');
INSERT INTO `sys_dict_data` VALUES (15, 2, '公告', '2', 'sys_notice_type', '', 'success', 'N', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '公告');
INSERT INTO `sys_dict_data` VALUES (16, 1, '正常', '0', 'sys_notice_status', '', 'primary', 'Y', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (17, 2, '关闭', '1', 'sys_notice_status', '', 'danger', 'N', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '关闭状态');
INSERT INTO `sys_dict_data` VALUES (18, 99, '其他', '0', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '其他操作');
INSERT INTO `sys_dict_data` VALUES (19, 1, '新增', '1', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '新增操作');
INSERT INTO `sys_dict_data` VALUES (20, 2, '修改', '2', 'sys_oper_type', '', 'info', 'N', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '修改操作');
INSERT INTO `sys_dict_data` VALUES (21, 3, '删除', '3', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '删除操作');
INSERT INTO `sys_dict_data` VALUES (22, 4, '授权', '4', 'sys_oper_type', '', 'primary', 'N', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '授权操作');
INSERT INTO `sys_dict_data` VALUES (23, 5, '导出', '5', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '导出操作');
INSERT INTO `sys_dict_data` VALUES (24, 6, '导入', '6', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '导入操作');
INSERT INTO `sys_dict_data` VALUES (25, 7, '强退', '7', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '强退操作');
INSERT INTO `sys_dict_data` VALUES (26, 8, '生成代码', '8', 'sys_oper_type', '', 'warning', 'N', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '生成操作');
INSERT INTO `sys_dict_data` VALUES (27, 9, '清空数据', '9', 'sys_oper_type', '', 'danger', 'N', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '清空操作');
INSERT INTO `sys_dict_data` VALUES (28, 1, '成功', '0', 'sys_common_status', '', 'primary', 'N', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (29, 2, '失败', '1', 'sys_common_status', '', 'danger', 'N', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '停用状态');

-- ----------------------------
-- Table structure for sys_dict_type
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_type`;
CREATE TABLE `sys_dict_type`  (
  `dict_id` bigint NOT NULL AUTO_INCREMENT COMMENT '字典主键',
  `dict_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典名称',
  `dict_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '字典类型',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`dict_id`) USING BTREE,
  UNIQUE INDEX `dict_type`(`dict_type`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '字典类型表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_dict_type
-- ----------------------------
INSERT INTO `sys_dict_type` VALUES (1, '用户性别', 'sys_user_sex', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '用户性别列表');
INSERT INTO `sys_dict_type` VALUES (2, '菜单状态', 'sys_show_hide', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '菜单状态列表');
INSERT INTO `sys_dict_type` VALUES (3, '系统开关', 'sys_normal_disable', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '系统开关列表');
INSERT INTO `sys_dict_type` VALUES (4, '任务状态', 'sys_job_status', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '任务状态列表');
INSERT INTO `sys_dict_type` VALUES (5, '任务分组', 'sys_job_group', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '任务分组列表');
INSERT INTO `sys_dict_type` VALUES (6, '系统是否', 'sys_yes_no', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '系统是否列表');
INSERT INTO `sys_dict_type` VALUES (7, '通知类型', 'sys_notice_type', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '通知类型列表');
INSERT INTO `sys_dict_type` VALUES (8, '通知状态', 'sys_notice_status', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '通知状态列表');
INSERT INTO `sys_dict_type` VALUES (9, '操作类型', 'sys_oper_type', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '操作类型列表');
INSERT INTO `sys_dict_type` VALUES (10, '系统状态', 'sys_common_status', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '登录状态列表');

-- ----------------------------
-- Table structure for sys_job
-- ----------------------------
DROP TABLE IF EXISTS `sys_job`;
CREATE TABLE `sys_job`  (
  `job_id` bigint NOT NULL AUTO_INCREMENT COMMENT '任务ID',
  `job_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '任务名称',
  `job_group` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT 'DEFAULT' COMMENT '任务组名',
  `invoke_target` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调用目标字符串',
  `cron_expression` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT 'cron执行表达式',
  `misfire_policy` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '3' COMMENT '计划执行错误策略（1立即执行 2执行一次 3放弃执行）',
  `concurrent` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '1' COMMENT '是否并发执行（0允许 1禁止）',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '状态（0正常 1暂停）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '备注信息',
  PRIMARY KEY (`job_id`, `job_name`, `job_group`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '定时任务调度表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_job
-- ----------------------------
INSERT INTO `sys_job` VALUES (1, '系统默认（无参）', 'DEFAULT', 'ryTask.ryNoParams', '0/10 * * * * ?', '3', '1', '1', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_job` VALUES (2, '系统默认（有参）', 'DEFAULT', 'ryTask.ryParams(\'ry\')', '0/15 * * * * ?', '3', '1', '1', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_job` VALUES (3, '系统默认（多参）', 'DEFAULT', 'ryTask.ryMultipleParams(\'ry\', true, 2000L, 316.50D, 100)', '0/20 * * * * ?', '3', '1', '1', 'admin', '2026-04-01 17:23:08', '', NULL, '');

-- ----------------------------
-- Table structure for sys_job_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_job_log`;
CREATE TABLE `sys_job_log`  (
  `job_log_id` bigint NOT NULL AUTO_INCREMENT COMMENT '任务日志ID',
  `job_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务名称',
  `job_group` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '任务组名',
  `invoke_target` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '调用目标字符串',
  `job_message` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '日志信息',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '执行状态（0正常 1失败）',
  `exception_info` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '异常信息',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`job_log_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '定时任务调度日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_job_log
-- ----------------------------

-- ----------------------------
-- Table structure for sys_logininfor
-- ----------------------------
DROP TABLE IF EXISTS `sys_logininfor`;
CREATE TABLE `sys_logininfor`  (
  `info_id` bigint NOT NULL AUTO_INCREMENT COMMENT '访问ID',
  `login_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '登录账号',
  `ipaddr` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '登录IP地址',
  `login_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '登录地点',
  `browser` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '浏览器类型',
  `os` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '操作系统',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '登录状态（0成功 1失败）',
  `msg` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '提示消息',
  `login_time` datetime NULL DEFAULT NULL COMMENT '访问时间',
  PRIMARY KEY (`info_id`) USING BTREE,
  INDEX `idx_sys_logininfor_s`(`status`) USING BTREE,
  INDEX `idx_sys_logininfor_lt`(`login_time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 114 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '系统访问记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_logininfor
-- ----------------------------
INSERT INTO `sys_logininfor` VALUES (100, '13800138001', '127.0.0.1', '内网IP', 'Mobile Safari', 'Mac OS X (iPhone)', '0', '登录成功', '2026-04-01 18:11:30');
INSERT INTO `sys_logininfor` VALUES (101, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-04-01 18:28:08');
INSERT INTO `sys_logininfor` VALUES (102, '13800138001', '127.0.0.1', '内网IP', 'Mobile Safari', 'Mac OS X (iPhone)', '0', '登录成功', '2026-04-01 18:31:57');
INSERT INTO `sys_logininfor` VALUES (103, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-04-01 18:35:32');
INSERT INTO `sys_logininfor` VALUES (104, 'admin', '127.0.0.1', '内网IP', 'Mobile Safari', 'Mac OS X (iPhone)', '0', '登录成功', '2026-04-01 18:37:17');
INSERT INTO `sys_logininfor` VALUES (105, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-04-01 19:29:00');
INSERT INTO `sys_logininfor` VALUES (106, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-04-01 19:47:35');
INSERT INTO `sys_logininfor` VALUES (107, '13800138001', '127.0.0.1', '内网IP', 'Mobile Safari', 'Mac OS X (iPhone)', '0', '登录成功', '2026-04-01 19:55:26');
INSERT INTO `sys_logininfor` VALUES (108, '13800138001', '127.0.0.1', '内网IP', 'Mobile Safari', 'Mac OS X (iPhone)', '0', '登录成功', '2026-04-01 20:39:45');
INSERT INTO `sys_logininfor` VALUES (109, '13800138001', '127.0.0.1', '内网IP', 'Mobile Safari', 'Mac OS X (iPhone)', '0', '登录成功', '2026-04-01 20:50:16');
INSERT INTO `sys_logininfor` VALUES (110, '13800138001', '127.0.0.1', '内网IP', 'Mobile Safari', 'Mac OS X (iPhone)', '0', '登录成功', '2026-04-01 20:56:23');
INSERT INTO `sys_logininfor` VALUES (111, '13800138111', '127.0.0.1', '内网IP', 'Mobile Safari', 'Mac OS X (iPhone)', '0', '登录成功', '2026-04-01 20:57:22');
INSERT INTO `sys_logininfor` VALUES (112, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-04-01 20:58:20');
INSERT INTO `sys_logininfor` VALUES (113, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-04-02 16:52:38');
INSERT INTO `sys_logininfor` VALUES (114, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-04-03 00:26:47');
INSERT INTO `sys_logininfor` VALUES (115, '13800138001', '127.0.0.1', '内网IP', 'Mobile Safari', 'Mac OS X (iPhone)', '0', '登录成功', '2026-04-03 00:31:14');
INSERT INTO `sys_logininfor` VALUES (116, '13800138100', '127.0.0.1', '内网IP', 'Mobile Safari', 'Mac OS X (iPhone)', '0', '登录成功', '2026-04-03 00:42:16');
INSERT INTO `sys_logininfor` VALUES (117, '13800138002', '127.0.0.1', '内网IP', 'Mobile Safari', 'Mac OS X (iPhone)', '0', '登录成功', '2026-04-03 00:46:42');
INSERT INTO `sys_logininfor` VALUES (118, '13800138001', '127.0.0.1', '内网IP', 'Mobile Safari', 'Mac OS X (iPhone)', '0', '登录成功', '2026-04-03 00:51:27');
INSERT INTO `sys_logininfor` VALUES (119, 'admin', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-04-03 00:53:49');
INSERT INTO `sys_logininfor` VALUES (120, '13800138001', '127.0.0.1', '内网IP', 'Mozilla', 'Windows 10', '1', '验证码错误', '2026-04-03 01:06:46');
INSERT INTO `sys_logininfor` VALUES (121, '13800138001', '127.0.0.1', '内网IP', 'Mozilla', 'Windows 10', '1', '验证码错误', '2026-04-03 01:07:39');
INSERT INTO `sys_logininfor` VALUES (122, '13800138001', '127.0.0.1', '内网IP', 'Mozilla', 'Windows 10', '1', '验证码错误', '2026-04-03 01:08:09');
INSERT INTO `sys_logininfor` VALUES (123, '13800138001', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-04-03 01:23:39');
INSERT INTO `sys_logininfor` VALUES (124, '13800138001', '127.0.0.1', '内网IP', 'Mobile Safari', 'Mac OS X (iPhone)', '0', '登录成功', '2026-04-03 01:33:52');
INSERT INTO `sys_logininfor` VALUES (125, '13800138001', '127.0.0.1', '内网IP', 'Mobile Safari', 'Mac OS X (iPhone)', '0', '登录成功', '2026-04-03 01:36:41');
INSERT INTO `sys_logininfor` VALUES (126, '13800138001', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '1', '验证码错误', '2026-04-03 01:39:55');
INSERT INTO `sys_logininfor` VALUES (127, '13800138001', '127.0.0.1', '内网IP', 'Mobile Safari', 'Mac OS X (iPhone)', '0', '登录成功', '2026-04-03 01:40:13');
INSERT INTO `sys_logininfor` VALUES (128, '13800138001', '127.0.0.1', '内网IP', 'Mobile Safari', 'Mac OS X (iPhone)', '0', '登录成功', '2026-04-03 01:41:51');
INSERT INTO `sys_logininfor` VALUES (129, '13800138001', '127.0.0.1', '内网IP', 'Mobile Safari', 'Mac OS X (iPhone)', '0', '登录成功', '2026-04-03 01:46:36');
INSERT INTO `sys_logininfor` VALUES (130, 'admin', '127.0.0.1', '内网IP', 'Mozilla', 'Windows 10', '0', '登录成功', '2026-04-03 02:00:36');
INSERT INTO `sys_logininfor` VALUES (131, 'admin', '127.0.0.1', '内网IP', 'Mozilla', 'Windows 10', '0', '登录成功', '2026-04-03 02:00:54');
INSERT INTO `sys_logininfor` VALUES (132, '13800138001', '127.0.0.1', '内网IP', 'Mozilla', 'Windows 10', '0', '登录成功', '2026-04-03 02:01:20');
INSERT INTO `sys_logininfor` VALUES (133, '13800138002', '127.0.0.1', '内网IP', 'Mozilla', 'Windows 10', '0', '登录成功', '2026-04-03 02:01:20');
INSERT INTO `sys_logininfor` VALUES (134, '13800138001', '127.0.0.1', '内网IP', 'Mozilla', 'Windows 10', '0', '登录成功', '2026-04-03 02:09:57');
INSERT INTO `sys_logininfor` VALUES (135, '13800138100', '127.0.0.1', '内网IP', 'Mozilla', 'Windows 10', '0', '登录成功', '2026-04-03 02:10:22');
INSERT INTO `sys_logininfor` VALUES (136, '13800138100', '127.0.0.1', '内网IP', 'Mozilla', 'Windows 10', '0', '登录成功', '2026-04-03 02:10:42');
INSERT INTO `sys_logininfor` VALUES (137, '13800138100', '127.0.0.1', '内网IP', 'Mozilla', 'Windows 10', '0', '登录成功', '2026-04-03 02:11:09');
INSERT INTO `sys_logininfor` VALUES (138, '13800138001', '127.0.0.1', '内网IP', 'Mozilla', 'Windows 10', '0', '登录成功', '2026-04-03 02:11:31');
INSERT INTO `sys_logininfor` VALUES (139, '13800138001', '127.0.0.1', '内网IP', 'Mobile Safari', 'Mac OS X (iPhone)', '0', '登录成功', '2026-04-03 02:14:10');
INSERT INTO `sys_logininfor` VALUES (140, '13800138100', '127.0.0.1', '内网IP', 'Mobile Safari', 'Mac OS X (iPhone)', '0', '登录成功', '2026-04-03 02:17:38');
INSERT INTO `sys_logininfor` VALUES (141, '13800138001', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-04-03 02:18:31');
INSERT INTO `sys_logininfor` VALUES (142, '13800138002', '127.0.0.1', '内网IP', 'Mobile Safari', 'Mac OS X (iPhone)', '0', '登录成功', '2026-04-03 02:21:55');
INSERT INTO `sys_logininfor` VALUES (143, '13800138001', '127.0.0.1', '内网IP', 'Mozilla', 'Windows 10', '0', '登录成功', '2026-04-03 02:28:23');
INSERT INTO `sys_logininfor` VALUES (144, '13800138001', '127.0.0.1', '内网IP', 'Mozilla', 'Windows 10', '0', '登录成功', '2026-04-03 02:28:23');
INSERT INTO `sys_logininfor` VALUES (145, '13800138001', '127.0.0.1', '内网IP', 'Mozilla', 'Windows 10', '0', '登录成功', '2026-04-03 02:28:23');
INSERT INTO `sys_logininfor` VALUES (146, '13800138100', '127.0.0.1', '内网IP', 'Mozilla', 'Windows 10', '0', '登录成功', '2026-04-03 02:28:50');
INSERT INTO `sys_logininfor` VALUES (147, '13800138100', '127.0.0.1', '内网IP', 'Mozilla', 'Windows 10', '0', '登录成功', '2026-04-03 02:28:50');
INSERT INTO `sys_logininfor` VALUES (148, '13800138100', '127.0.0.1', '内网IP', 'Mozilla', 'Windows 10', '0', '登录成功', '2026-04-03 02:28:50');
INSERT INTO `sys_logininfor` VALUES (149, '13800138100', '127.0.0.1', '内网IP', 'Mozilla', 'Windows 10', '0', '登录成功', '2026-04-03 02:29:05');
INSERT INTO `sys_logininfor` VALUES (150, '13800138001', '127.0.0.1', '内网IP', 'Mozilla', 'Windows 10', '0', '登录成功', '2026-04-03 02:29:35');
INSERT INTO `sys_logininfor` VALUES (151, '13800138100', '127.0.0.1', '内网IP', 'Mozilla', 'Windows 10', '0', '登录成功', '2026-04-03 02:41:38');
INSERT INTO `sys_logininfor` VALUES (152, '13800138001', '127.0.0.1', '内网IP', 'Mozilla', 'Windows 10', '0', '登录成功', '2026-04-03 02:41:38');
INSERT INTO `sys_logininfor` VALUES (153, '13800138001', '127.0.0.1', '内网IP', 'Mozilla', 'Windows 10', '0', '登录成功', '2026-04-03 02:41:38');
INSERT INTO `sys_logininfor` VALUES (154, '13800138001', '127.0.0.1', '内网IP', 'Mozilla', 'Windows 10', '0', '登录成功', '2026-04-03 02:41:38');
INSERT INTO `sys_logininfor` VALUES (155, '13800138001', '127.0.0.1', '内网IP', 'Mozilla', 'Windows 10', '0', '登录成功', '2026-04-03 02:42:14');
INSERT INTO `sys_logininfor` VALUES (156, '13800138001', '127.0.0.1', '内网IP', 'Mobile Safari', 'Mac OS X (iPhone)', '0', '登录成功', '2026-04-03 02:47:40');
INSERT INTO `sys_logininfor` VALUES (157, '13800138001', '127.0.0.1', '内网IP', 'Mobile Safari', 'Mac OS X (iPhone)', '0', '登录成功', '2026-04-03 02:55:01');
INSERT INTO `sys_logininfor` VALUES (158, '13800138002', '127.0.0.1', '内网IP', 'Mobile Safari', 'Mac OS X (iPhone)', '0', '登录成功', '2026-04-03 02:58:13');
INSERT INTO `sys_logininfor` VALUES (159, '13800138100', '127.0.0.1', '内网IP', 'Mobile Safari', 'Mac OS X (iPhone)', '0', '登录成功', '2026-04-03 03:01:07');
INSERT INTO `sys_logininfor` VALUES (160, '13800138001', '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', '0', '登录成功', '2026-04-03 11:11:34');
INSERT INTO `sys_logininfor` VALUES (161, '13800138001', '127.0.0.1', '内网IP', 'Mobile Safari', 'Mac OS X (iPhone)', '0', '登录成功', '2026-04-03 11:33:21');

-- ----------------------------
-- Table structure for sys_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu`  (
  `menu_id` bigint NOT NULL AUTO_INCREMENT COMMENT '菜单ID',
  `menu_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '菜单名称',
  `parent_id` bigint NULL DEFAULT 0 COMMENT '父菜单ID',
  `order_num` int NULL DEFAULT 0 COMMENT '显示顺序',
  `url` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '#' COMMENT '请求地址',
  `target` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '打开方式（menuItem页签 menuBlank新窗口）',
  `menu_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '菜单类型（M目录 C菜单 F按钮）',
  `visible` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '菜单状态（0显示 1隐藏）',
  `is_refresh` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '1' COMMENT '是否刷新（0刷新 1不刷新）',
  `perms` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '权限标识',
  `icon` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '#' COMMENT '菜单图标',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '备注',
  PRIMARY KEY (`menu_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2055 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '菜单权限表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_menu
-- ----------------------------
INSERT INTO `sys_menu` VALUES (1, '系统管理', 0, 1, '#', '', 'M', '0', '1', '', 'fa fa-gear', 'admin', '2026-04-01 17:23:08', '', NULL, '系统管理目录');
INSERT INTO `sys_menu` VALUES (2, '系统监控', 0, 2, '#', 'menuItem', 'M', '1', '1', '', 'fa fa-video-camera', 'admin', '2026-04-01 17:23:08', 'admin', '2026-04-01 18:06:53', '系统监控目录');
INSERT INTO `sys_menu` VALUES (3, '系统工具', 0, 3, '#', 'menuItem', 'M', '1', '1', '', 'fa fa-bars', 'admin', '2026-04-01 17:23:08', 'admin', '2026-04-01 18:06:57', '系统工具目录');
INSERT INTO `sys_menu` VALUES (4, '若依官网', 0, 4, 'http://ruoyi.vip', 'menuBlank', 'C', '1', '1', '', 'fa fa-location-arrow', 'admin', '2026-04-01 17:23:08', 'admin', '2026-04-01 18:07:00', '若依官网地址');
INSERT INTO `sys_menu` VALUES (100, '用户管理', 1, 1, '/system/user', '', 'C', '0', '1', 'system:user:view', 'fa fa-user-o', 'admin', '2026-04-01 17:23:08', '', NULL, '用户管理菜单');
INSERT INTO `sys_menu` VALUES (101, '角色管理', 1, 2, '/system/role', '', 'C', '0', '1', 'system:role:view', 'fa fa-user-secret', 'admin', '2026-04-01 17:23:08', '', NULL, '角色管理菜单');
INSERT INTO `sys_menu` VALUES (102, '菜单管理', 1, 3, '/system/menu', '', 'C', '0', '1', 'system:menu:view', 'fa fa-th-list', 'admin', '2026-04-01 17:23:08', '', NULL, '菜单管理菜单');
INSERT INTO `sys_menu` VALUES (103, '部门管理', 1, 4, '/system/dept', 'menuItem', 'C', '1', '1', 'system:dept:view', 'fa fa-outdent', 'admin', '2026-04-01 17:23:08', 'admin', '2026-04-01 18:07:07', '部门管理菜单');
INSERT INTO `sys_menu` VALUES (104, '岗位管理', 1, 5, '/system/post', 'menuItem', 'C', '1', '1', 'system:post:view', 'fa fa-address-card-o', 'admin', '2026-04-01 17:23:08', 'admin', '2026-04-01 18:07:13', '岗位管理菜单');
INSERT INTO `sys_menu` VALUES (105, '字典管理', 1, 6, '/system/dict', 'menuItem', 'C', '1', '1', 'system:dict:view', 'fa fa-bookmark-o', 'admin', '2026-04-01 17:23:08', 'admin', '2026-04-01 18:07:18', '字典管理菜单');
INSERT INTO `sys_menu` VALUES (106, '参数设置', 1, 7, '/system/config', 'menuItem', 'C', '1', '1', 'system:config:view', 'fa fa-sun-o', 'admin', '2026-04-01 17:23:08', 'admin', '2026-04-01 18:07:25', '参数设置菜单');
INSERT INTO `sys_menu` VALUES (107, '通知公告', 1, 8, '/system/notice', 'menuItem', 'C', '1', '1', 'system:notice:view', 'fa fa-bullhorn', 'admin', '2026-04-01 17:23:08', 'admin', '2026-04-01 18:07:32', '通知公告菜单');
INSERT INTO `sys_menu` VALUES (108, '日志管理', 1, 9, '#', '', 'M', '0', '1', '', 'fa fa-pencil-square-o', 'admin', '2026-04-01 17:23:08', '', NULL, '日志管理菜单');
INSERT INTO `sys_menu` VALUES (109, '在线用户', 2, 1, '/monitor/online', '', 'C', '0', '1', 'monitor:online:view', 'fa fa-user-circle', 'admin', '2026-04-01 17:23:08', '', NULL, '在线用户菜单');
INSERT INTO `sys_menu` VALUES (110, '定时任务', 2, 2, '/monitor/job', '', 'C', '0', '1', 'monitor:job:view', 'fa fa-tasks', 'admin', '2026-04-01 17:23:08', '', NULL, '定时任务菜单');
INSERT INTO `sys_menu` VALUES (111, '数据监控', 2, 3, '/monitor/data', '', 'C', '0', '1', 'monitor:data:view', 'fa fa-bug', 'admin', '2026-04-01 17:23:08', '', NULL, '数据监控菜单');
INSERT INTO `sys_menu` VALUES (112, '服务监控', 2, 4, '/monitor/server', '', 'C', '0', '1', 'monitor:server:view', 'fa fa-server', 'admin', '2026-04-01 17:23:08', '', NULL, '服务监控菜单');
INSERT INTO `sys_menu` VALUES (113, '缓存监控', 2, 5, '/monitor/cache', '', 'C', '0', '1', 'monitor:cache:view', 'fa fa-cube', 'admin', '2026-04-01 17:23:08', '', NULL, '缓存监控菜单');
INSERT INTO `sys_menu` VALUES (114, '表单构建', 3, 1, '/tool/build', '', 'C', '0', '1', 'tool:build:view', 'fa fa-wpforms', 'admin', '2026-04-01 17:23:08', '', NULL, '表单构建菜单');
INSERT INTO `sys_menu` VALUES (115, '代码生成', 3, 2, '/tool/gen', '', 'C', '0', '1', 'tool:gen:view', 'fa fa-code', 'admin', '2026-04-01 17:23:08', '', NULL, '代码生成菜单');
INSERT INTO `sys_menu` VALUES (116, '系统接口', 3, 3, '/tool/swagger', '', 'C', '0', '1', 'tool:swagger:view', 'fa fa-gg', 'admin', '2026-04-01 17:23:08', '', NULL, '系统接口菜单');
INSERT INTO `sys_menu` VALUES (500, '操作日志', 108, 1, '/monitor/operlog', '', 'C', '0', '1', 'monitor:operlog:view', 'fa fa-address-book', 'admin', '2026-04-01 17:23:08', '', NULL, '操作日志菜单');
INSERT INTO `sys_menu` VALUES (501, '登录日志', 108, 2, '/monitor/logininfor', '', 'C', '0', '1', 'monitor:logininfor:view', 'fa fa-file-image-o', 'admin', '2026-04-01 17:23:08', '', NULL, '登录日志菜单');
INSERT INTO `sys_menu` VALUES (1000, '用户查询', 100, 1, '#', '', 'F', '0', '1', 'system:user:list', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1001, '用户新增', 100, 2, '#', '', 'F', '0', '1', 'system:user:add', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1002, '用户修改', 100, 3, '#', '', 'F', '0', '1', 'system:user:edit', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1003, '用户删除', 100, 4, '#', '', 'F', '0', '1', 'system:user:remove', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1004, '用户导出', 100, 5, '#', '', 'F', '0', '1', 'system:user:export', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1005, '用户导入', 100, 6, '#', '', 'F', '0', '1', 'system:user:import', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1006, '重置密码', 100, 7, '#', '', 'F', '0', '1', 'system:user:resetPwd', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1007, '角色查询', 101, 1, '#', '', 'F', '0', '1', 'system:role:list', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1008, '角色新增', 101, 2, '#', '', 'F', '0', '1', 'system:role:add', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1009, '角色修改', 101, 3, '#', '', 'F', '0', '1', 'system:role:edit', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1010, '角色删除', 101, 4, '#', '', 'F', '0', '1', 'system:role:remove', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1011, '角色导出', 101, 5, '#', '', 'F', '0', '1', 'system:role:export', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1012, '菜单查询', 102, 1, '#', '', 'F', '0', '1', 'system:menu:list', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1013, '菜单新增', 102, 2, '#', '', 'F', '0', '1', 'system:menu:add', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1014, '菜单修改', 102, 3, '#', '', 'F', '0', '1', 'system:menu:edit', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1015, '菜单删除', 102, 4, '#', '', 'F', '0', '1', 'system:menu:remove', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1016, '部门查询', 103, 1, '#', '', 'F', '0', '1', 'system:dept:list', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1017, '部门新增', 103, 2, '#', '', 'F', '0', '1', 'system:dept:add', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1018, '部门修改', 103, 3, '#', '', 'F', '0', '1', 'system:dept:edit', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1019, '部门删除', 103, 4, '#', '', 'F', '0', '1', 'system:dept:remove', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1020, '岗位查询', 104, 1, '#', '', 'F', '0', '1', 'system:post:list', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1021, '岗位新增', 104, 2, '#', '', 'F', '0', '1', 'system:post:add', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1022, '岗位修改', 104, 3, '#', '', 'F', '0', '1', 'system:post:edit', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1023, '岗位删除', 104, 4, '#', '', 'F', '0', '1', 'system:post:remove', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1024, '岗位导出', 104, 5, '#', '', 'F', '0', '1', 'system:post:export', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1025, '字典查询', 105, 1, '#', '', 'F', '0', '1', 'system:dict:list', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1026, '字典新增', 105, 2, '#', '', 'F', '0', '1', 'system:dict:add', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1027, '字典修改', 105, 3, '#', '', 'F', '0', '1', 'system:dict:edit', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1028, '字典删除', 105, 4, '#', '', 'F', '0', '1', 'system:dict:remove', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1029, '字典导出', 105, 5, '#', '', 'F', '0', '1', 'system:dict:export', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1030, '参数查询', 106, 1, '#', '', 'F', '0', '1', 'system:config:list', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1031, '参数新增', 106, 2, '#', '', 'F', '0', '1', 'system:config:add', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1032, '参数修改', 106, 3, '#', '', 'F', '0', '1', 'system:config:edit', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1033, '参数删除', 106, 4, '#', '', 'F', '0', '1', 'system:config:remove', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1034, '参数导出', 106, 5, '#', '', 'F', '0', '1', 'system:config:export', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1035, '公告查询', 107, 1, '#', '', 'F', '0', '1', 'system:notice:list', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1036, '公告新增', 107, 2, '#', '', 'F', '0', '1', 'system:notice:add', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1037, '公告修改', 107, 3, '#', '', 'F', '0', '1', 'system:notice:edit', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1038, '公告删除', 107, 4, '#', '', 'F', '0', '1', 'system:notice:remove', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1039, '操作查询', 500, 1, '#', '', 'F', '0', '1', 'monitor:operlog:list', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1040, '操作删除', 500, 2, '#', '', 'F', '0', '1', 'monitor:operlog:remove', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1041, '详细信息', 500, 3, '#', '', 'F', '0', '1', 'monitor:operlog:detail', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1042, '日志导出', 500, 4, '#', '', 'F', '0', '1', 'monitor:operlog:export', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1043, '登录查询', 501, 1, '#', '', 'F', '0', '1', 'monitor:logininfor:list', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1044, '登录删除', 501, 2, '#', '', 'F', '0', '1', 'monitor:logininfor:remove', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1045, '日志导出', 501, 3, '#', '', 'F', '0', '1', 'monitor:logininfor:export', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1046, '账户解锁', 501, 4, '#', '', 'F', '0', '1', 'monitor:logininfor:unlock', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1047, '在线查询', 109, 1, '#', '', 'F', '0', '1', 'monitor:online:list', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1048, '批量强退', 109, 2, '#', '', 'F', '0', '1', 'monitor:online:batchForceLogout', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1049, '单条强退', 109, 3, '#', '', 'F', '0', '1', 'monitor:online:forceLogout', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1050, '任务查询', 110, 1, '#', '', 'F', '0', '1', 'monitor:job:list', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1051, '任务新增', 110, 2, '#', '', 'F', '0', '1', 'monitor:job:add', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1052, '任务修改', 110, 3, '#', '', 'F', '0', '1', 'monitor:job:edit', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1053, '任务删除', 110, 4, '#', '', 'F', '0', '1', 'monitor:job:remove', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1054, '状态修改', 110, 5, '#', '', 'F', '0', '1', 'monitor:job:changeStatus', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1055, '任务详细', 110, 6, '#', '', 'F', '0', '1', 'monitor:job:detail', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1056, '任务导出', 110, 7, '#', '', 'F', '0', '1', 'monitor:job:export', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1057, '生成查询', 115, 1, '#', '', 'F', '0', '1', 'tool:gen:list', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1058, '生成修改', 115, 2, '#', '', 'F', '0', '1', 'tool:gen:edit', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1059, '生成删除', 115, 3, '#', '', 'F', '0', '1', 'tool:gen:remove', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1060, '预览代码', 115, 4, '#', '', 'F', '0', '1', 'tool:gen:preview', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (1061, '生成代码', 115, 5, '#', '', 'F', '0', '1', 'tool:gen:code', '#', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2000, '诊所管理', 0, 10, '', '', 'M', '0', '1', '', 'fa fa-hospital-o', 'admin', '2026-04-01 17:23:23', '', NULL, '诊所管理菜单');
INSERT INTO `sys_menu` VALUES (2001, '患者管理', 2000, 1, 'clinic/patient', '', 'C', '0', '1', 'clinic:patient:view', 'fa fa-user-md', 'admin', '2026-04-01 17:23:23', '', NULL, '患者管理菜单');
INSERT INTO `sys_menu` VALUES (2002, '患者查询', 2001, 1, '', '', 'F', '0', '1', 'clinic:patient:list', '#', 'admin', '2026-04-01 17:23:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2003, '患者新增', 2001, 2, '', '', 'F', '0', '1', 'clinic:patient:add', '#', 'admin', '2026-04-01 17:23:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2004, '患者修改', 2001, 3, '', '', 'F', '0', '1', 'clinic:patient:edit', '#', 'admin', '2026-04-01 17:23:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2005, '患者删除', 2001, 4, '', '', 'F', '0', '1', 'clinic:patient:remove', '#', 'admin', '2026-04-01 17:23:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2006, '患者导出', 2001, 5, '', '', 'F', '0', '1', 'clinic:patient:export', '#', 'admin', '2026-04-01 17:23:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2010, '药品管理', 2000, 2, 'clinic/medicine', '', 'C', '0', '1', 'clinic:medicine:view', 'fa fa-medkit', 'admin', '2026-04-01 17:23:23', '', NULL, '药品管理菜单');
INSERT INTO `sys_menu` VALUES (2011, '药品查询', 2010, 1, '', '', 'F', '0', '1', 'clinic:medicine:list', '#', 'admin', '2026-04-01 17:23:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2012, '药品新增', 2010, 2, '', '', 'F', '0', '1', 'clinic:medicine:add', '#', 'admin', '2026-04-01 17:23:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2013, '药品修改', 2010, 3, '', '', 'F', '0', '1', 'clinic:medicine:edit', '#', 'admin', '2026-04-01 17:23:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2014, '药品删除', 2010, 4, '', '', 'F', '0', '1', 'clinic:medicine:remove', '#', 'admin', '2026-04-01 17:23:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2015, '药品导出', 2010, 5, '', '', 'F', '0', '1', 'clinic:medicine:export', '#', 'admin', '2026-04-01 17:23:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2030, '病历管理', 2000, 3, 'clinic/medical', '', 'C', '0', '1', 'clinic:medical:view', 'fa fa-file-text', 'admin', '2026-04-01 17:23:23', '', NULL, '病历管理菜单');
INSERT INTO `sys_menu` VALUES (2031, '病历查询', 2030, 1, '', '', 'F', '0', '1', 'clinic:medical:list', '#', 'admin', '2026-04-01 17:23:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2032, '病历新增', 2030, 2, '', '', 'F', '0', '1', 'clinic:medical:add', '#', 'admin', '2026-04-01 17:23:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2033, '病历修改', 2030, 3, '', '', 'F', '0', '1', 'clinic:medical:edit', '#', 'admin', '2026-04-01 17:23:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2034, '病历删除', 2030, 4, '', '', 'F', '0', '1', 'clinic:medical:remove', '#', 'admin', '2026-04-01 17:23:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2040, '预约管理', 2000, 4, 'clinic/appointment', '', 'C', '0', '1', 'clinic:appointment:view', 'fa fa-calendar', 'admin', '2026-04-01 17:23:23', '', NULL, '预约管理菜单');
INSERT INTO `sys_menu` VALUES (2041, '预约查询', 2040, 1, '', '', 'F', '0', '1', 'clinic:appointment:list', '#', 'admin', '2026-04-01 17:23:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2042, '预约新增', 2040, 2, '', '', 'F', '0', '1', 'clinic:appointment:add', '#', 'admin', '2026-04-01 17:23:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2043, '预约修改', 2040, 3, '', '', 'F', '0', '1', 'clinic:appointment:edit', '#', 'admin', '2026-04-01 17:23:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2044, '预约删除', 2040, 4, '', '', 'F', '0', '1', 'clinic:appointment:remove', '#', 'admin', '2026-04-01 17:23:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2050, '排班管理', 2000, 5, 'clinic/schedule', '', 'C', '0', '1', 'clinic:schedule:view', 'fa fa-clock-o', 'admin', '2026-04-01 17:23:23', '', NULL, '排班管理菜单');
INSERT INTO `sys_menu` VALUES (2051, '排班查询', 2050, 1, '', '', 'F', '0', '1', 'clinic:schedule:list', '#', 'admin', '2026-04-01 17:23:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2052, '排班新增', 2050, 2, '', '', 'F', '0', '1', 'clinic:schedule:add', '#', 'admin', '2026-04-01 17:23:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2053, '排班修改', 2050, 3, '', '', 'F', '0', '1', 'clinic:schedule:edit', '#', 'admin', '2026-04-01 17:23:23', '', NULL, '');
INSERT INTO `sys_menu` VALUES (2054, '排班删除', 2050, 4, '', '', 'F', '0', '1', 'clinic:schedule:remove', '#', 'admin', '2026-04-01 17:23:23', '', NULL, '');

-- ----------------------------
-- Table structure for sys_notice
-- ----------------------------
DROP TABLE IF EXISTS `sys_notice`;
CREATE TABLE `sys_notice`  (
  `notice_id` int NOT NULL AUTO_INCREMENT COMMENT '公告ID',
  `notice_title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '公告标题',
  `notice_type` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '公告类型（1通知 2公告）',
  `notice_content` longblob NULL COMMENT '公告内容',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '公告状态（0正常 1关闭）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`notice_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '通知公告表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_notice
-- ----------------------------
INSERT INTO `sys_notice` VALUES (1, '温馨提醒：2018-07-01 若依新版本发布啦', '2', 0xE696B0E78988E69CACE58685E5AEB9, '0', 'admin', '2026-04-01 17:23:09', '', NULL, '管理员');
INSERT INTO `sys_notice` VALUES (2, '维护通知：2018-07-01 若依系统凌晨维护', '1', 0xE7BBB4E68AA4E58685E5AEB9, '0', 'admin', '2026-04-01 17:23:09', '', NULL, '管理员');
INSERT INTO `sys_notice` VALUES (3, '若依开源框架介绍', '1', 0x3C703E3C7370616E207374796C653D22636F6C6F723A20726762283233302C20302C2030293B223EE9A1B9E79BAEE4BB8BE7BB8D3C2F7370616E3E3C2F703E3C703E3C666F6E7420636F6C6F723D2223333333333333223E52756F5969E5BC80E6BA90E9A1B9E79BAEE698AFE4B8BAE4BC81E4B89AE794A8E688B7E5AE9AE588B6E79A84E5908EE58FB0E8849AE6898BE69EB6E6A186E69EB6EFBC8CE4B8BAE4BC81E4B89AE68993E980A0E79A84E4B880E7AB99E5BC8FE8A7A3E586B3E696B9E6A188EFBC8CE9998DE4BD8EE4BC81E4B89AE5BC80E58F91E68890E69CACEFBC8CE68F90E58D87E5BC80E58F91E69588E78E87E38082E4B8BBE8A681E58C85E68BACE794A8E688B7E7AEA1E79086E38081E8A792E889B2E7AEA1E79086E38081E983A8E997A8E7AEA1E79086E38081E88F9CE58D95E7AEA1E79086E38081E58F82E695B0E7AEA1E79086E38081E5AD97E585B8E7AEA1E79086E380813C2F666F6E743E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE5B297E4BD8DE7AEA1E790863C2F7370616E3E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE38081E5AE9AE697B6E4BBBBE58AA13C2F7370616E3E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE380813C2F7370616E3E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE69C8DE58AA1E79B91E68EA7E38081E799BBE5BD95E697A5E5BF97E38081E6938DE4BD9CE697A5E5BF97E38081E4BBA3E7A081E7949FE68890E7AD89E58A9FE883BDE38082E585B6E4B8ADEFBC8CE8BF98E694AFE68C81E5A49AE695B0E68DAEE6BA90E38081E695B0E68DAEE69D83E99990E38081E59BBDE99985E58C96E380815265646973E7BC93E5AD98E38081446F636B6572E983A8E7BDB2E38081E6BB91E58AA8E9AA8CE8AF81E7A081E38081E7ACACE4B889E696B9E8AEA4E8AF81E799BBE5BD95E38081E58886E5B883E5BC8FE4BA8BE58AA1E380813C2F7370616E3E3C666F6E7420636F6C6F723D2223333333333333223EE58886E5B883E5BC8FE69687E4BBB6E5AD98E582A83C2F666F6E743E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE38081E58886E5BA93E58886E8A1A8E5A484E79086E7AD89E68A80E69CAFE789B9E782B9E380823C2F7370616E3E3C2F703E3C703E3C696D67207372633D2268747470733A2F2F666F727564612E67697465652E636F6D2F696D616765732F313730353033303538333937373430313635312F35656435646236615F313135313030342E706E6722207374796C653D2277696474683A20363470783B223E3C62723E3C2F703E3C703E3C7370616E207374796C653D22636F6C6F723A20726762283233302C20302C2030293B223EE5AE98E7BD91E58F8AE6BC94E7A4BA3C2F7370616E3E3C2F703E3C703E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE88BA5E4BE9DE5AE98E7BD91E59CB0E59D80EFBC9A266E6273703B3C2F7370616E3E3C6120687265663D22687474703A2F2F72756F79692E76697022207461726765743D225F626C616E6B223E687474703A2F2F72756F79692E7669703C2F613E3C6120687265663D22687474703A2F2F72756F79692E76697022207461726765743D225F626C616E6B223E3C2F613E3C2F703E3C703E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE88BA5E4BE9DE69687E6A1A3E59CB0E59D80EFBC9A266E6273703B3C2F7370616E3E3C6120687265663D22687474703A2F2F646F632E72756F79692E76697022207461726765743D225F626C616E6B223E687474703A2F2F646F632E72756F79692E7669703C2F613E3C62723E3C2F703E3C703E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE6BC94E7A4BAE59CB0E59D80E38090E4B88DE58886E7A6BBE78988E38091EFBC9A266E6273703B3C2F7370616E3E3C6120687265663D22687474703A2F2F64656D6F2E72756F79692E76697022207461726765743D225F626C616E6B223E687474703A2F2F64656D6F2E72756F79692E7669703C2F613E3C2F703E3C703E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE6BC94E7A4BAE59CB0E59D80E38090E58886E7A6BBE78988E69CACE38091EFBC9A266E6273703B3C2F7370616E3E3C6120687265663D22687474703A2F2F7675652E72756F79692E76697022207461726765743D225F626C616E6B223E687474703A2F2F7675652E72756F79692E7669703C2F613E3C2F703E3C703E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE6BC94E7A4BAE59CB0E59D80E38090E5BEAEE69C8DE58AA1E78988E38091EFBC9A266E6273703B3C2F7370616E3E3C6120687265663D22687474703A2F2F636C6F75642E72756F79692E76697022207461726765743D225F626C616E6B223E687474703A2F2F636C6F75642E72756F79692E7669703C2F613E3C2F703E3C703E3C7370616E207374796C653D22636F6C6F723A207267622835312C2035312C203531293B223EE6BC94E7A4BAE59CB0E59D80E38090E7A7BBE58AA8E7ABAFE78988E38091EFBC9A266E6273703B3C2F7370616E3E3C6120687265663D22687474703A2F2F68352E72756F79692E76697022207461726765743D225F626C616E6B223E687474703A2F2F68352E72756F79692E7669703C2F613E3C2F703E3C703E3C6272207374796C653D22636F6C6F723A207267622834382C2034392C203531293B20666F6E742D66616D696C793A202671756F743B48656C766574696361204E6575652671756F743B2C2048656C7665746963612C20417269616C2C2073616E732D73657269663B20666F6E742D73697A653A20313270783B223E3C2F703E, '0', 'admin', '2026-04-01 17:23:09', '', NULL, '管理员');

-- ----------------------------
-- Table structure for sys_oper_log
-- ----------------------------
DROP TABLE IF EXISTS `sys_oper_log`;
CREATE TABLE `sys_oper_log`  (
  `oper_id` bigint NOT NULL AUTO_INCREMENT COMMENT '日志主键',
  `title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '模块标题',
  `business_type` int NULL DEFAULT 0 COMMENT '业务类型（0其它 1新增 2修改 3删除）',
  `method` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '方法名称',
  `request_method` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '请求方式',
  `operator_type` int NULL DEFAULT 0 COMMENT '操作类别（0其它 1后台用户 2手机端用户）',
  `oper_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '操作人员',
  `dept_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '部门名称',
  `oper_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '请求URL',
  `oper_ip` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '主机地址',
  `oper_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '操作地点',
  `oper_param` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '请求参数',
  `json_result` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '返回参数',
  `status` int NULL DEFAULT 0 COMMENT '操作状态（0正常 1异常）',
  `error_msg` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '错误消息',
  `oper_time` datetime NULL DEFAULT NULL COMMENT '操作时间',
  `cost_time` bigint NULL DEFAULT 0 COMMENT '消耗时间',
  PRIMARY KEY (`oper_id`) USING BTREE,
  INDEX `idx_sys_oper_log_bt`(`business_type`) USING BTREE,
  INDEX `idx_sys_oper_log_s`(`status`) USING BTREE,
  INDEX `idx_sys_oper_log_ot`(`oper_time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 124 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '操作日志记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_oper_log
-- ----------------------------
INSERT INTO `sys_oper_log` VALUES (100, '菜单管理', 2, 'com.ruoyi.project.system.menu.controller.MenuController.editSave()', 'POST', 1, 'admin', NULL, '/system/menu/edit', '127.0.0.1', '内网IP', '{\"menuId\":[\"2\"],\"parentId\":[\"0\"],\"menuType\":[\"M\"],\"menuName\":[\"系统监控\"],\"url\":[\"#\"],\"target\":[\"menuItem\"],\"perms\":[\"\"],\"orderNum\":[\"2\"],\"icon\":[\"fa fa-video-camera\"],\"visible\":[\"1\"],\"isRefresh\":[\"1\"]}', '{\"msg\":\"操作成功\",\"code\":0}', 0, NULL, '2026-04-01 18:06:53', 76);
INSERT INTO `sys_oper_log` VALUES (101, '菜单管理', 2, 'com.ruoyi.project.system.menu.controller.MenuController.editSave()', 'POST', 1, 'admin', NULL, '/system/menu/edit', '127.0.0.1', '内网IP', '{\"menuId\":[\"3\"],\"parentId\":[\"0\"],\"menuType\":[\"M\"],\"menuName\":[\"系统工具\"],\"url\":[\"#\"],\"target\":[\"menuItem\"],\"perms\":[\"\"],\"orderNum\":[\"3\"],\"icon\":[\"fa fa-bars\"],\"visible\":[\"1\"],\"isRefresh\":[\"1\"]}', '{\"msg\":\"操作成功\",\"code\":0}', 0, NULL, '2026-04-01 18:06:57', 11);
INSERT INTO `sys_oper_log` VALUES (102, '菜单管理', 2, 'com.ruoyi.project.system.menu.controller.MenuController.editSave()', 'POST', 1, 'admin', NULL, '/system/menu/edit', '127.0.0.1', '内网IP', '{\"menuId\":[\"4\"],\"parentId\":[\"0\"],\"menuType\":[\"C\"],\"menuName\":[\"若依官网\"],\"url\":[\"http://ruoyi.vip\"],\"target\":[\"menuBlank\"],\"perms\":[\"\"],\"orderNum\":[\"4\"],\"icon\":[\"fa fa-location-arrow\"],\"visible\":[\"1\"],\"isRefresh\":[\"1\"]}', '{\"msg\":\"操作成功\",\"code\":0}', 0, NULL, '2026-04-01 18:07:00', 12);
INSERT INTO `sys_oper_log` VALUES (103, '菜单管理', 2, 'com.ruoyi.project.system.menu.controller.MenuController.editSave()', 'POST', 1, 'admin', NULL, '/system/menu/edit', '127.0.0.1', '内网IP', '{\"menuId\":[\"103\"],\"parentId\":[\"1\"],\"menuType\":[\"C\"],\"menuName\":[\"部门管理\"],\"url\":[\"/system/dept\"],\"target\":[\"menuItem\"],\"perms\":[\"system:dept:view\"],\"orderNum\":[\"4\"],\"icon\":[\"fa fa-outdent\"],\"visible\":[\"1\"],\"isRefresh\":[\"1\"]}', '{\"msg\":\"操作成功\",\"code\":0}', 0, NULL, '2026-04-01 18:07:07', 8);
INSERT INTO `sys_oper_log` VALUES (104, '菜单管理', 2, 'com.ruoyi.project.system.menu.controller.MenuController.editSave()', 'POST', 1, 'admin', NULL, '/system/menu/edit', '127.0.0.1', '内网IP', '{\"menuId\":[\"104\"],\"parentId\":[\"1\"],\"menuType\":[\"C\"],\"menuName\":[\"岗位管理\"],\"url\":[\"/system/post\"],\"target\":[\"menuItem\"],\"perms\":[\"system:post:view\"],\"orderNum\":[\"5\"],\"icon\":[\"fa fa-address-card-o\"],\"visible\":[\"1\"],\"isRefresh\":[\"1\"]}', '{\"msg\":\"操作成功\",\"code\":0}', 0, NULL, '2026-04-01 18:07:13', 11);
INSERT INTO `sys_oper_log` VALUES (105, '菜单管理', 2, 'com.ruoyi.project.system.menu.controller.MenuController.editSave()', 'POST', 1, 'admin', NULL, '/system/menu/edit', '127.0.0.1', '内网IP', '{\"menuId\":[\"105\"],\"parentId\":[\"1\"],\"menuType\":[\"C\"],\"menuName\":[\"字典管理\"],\"url\":[\"/system/dict\"],\"target\":[\"menuItem\"],\"perms\":[\"system:dict:view\"],\"orderNum\":[\"6\"],\"icon\":[\"fa fa-bookmark-o\"],\"visible\":[\"1\"],\"isRefresh\":[\"1\"]}', '{\"msg\":\"操作成功\",\"code\":0}', 0, NULL, '2026-04-01 18:07:18', 10);
INSERT INTO `sys_oper_log` VALUES (106, '菜单管理', 2, 'com.ruoyi.project.system.menu.controller.MenuController.editSave()', 'POST', 1, 'admin', NULL, '/system/menu/edit', '127.0.0.1', '内网IP', '{\"menuId\":[\"106\"],\"parentId\":[\"1\"],\"menuType\":[\"C\"],\"menuName\":[\"参数设置\"],\"url\":[\"/system/config\"],\"target\":[\"menuItem\"],\"perms\":[\"system:config:view\"],\"orderNum\":[\"7\"],\"icon\":[\"fa fa-sun-o\"],\"visible\":[\"1\"],\"isRefresh\":[\"1\"]}', '{\"msg\":\"操作成功\",\"code\":0}', 0, NULL, '2026-04-01 18:07:25', 8);
INSERT INTO `sys_oper_log` VALUES (107, '菜单管理', 2, 'com.ruoyi.project.system.menu.controller.MenuController.editSave()', 'POST', 1, 'admin', NULL, '/system/menu/edit', '127.0.0.1', '内网IP', '{\"menuId\":[\"107\"],\"parentId\":[\"1\"],\"menuType\":[\"C\"],\"menuName\":[\"通知公告\"],\"url\":[\"/system/notice\"],\"target\":[\"menuItem\"],\"perms\":[\"system:notice:view\"],\"orderNum\":[\"8\"],\"icon\":[\"fa fa-bullhorn\"],\"visible\":[\"1\"],\"isRefresh\":[\"1\"]}', '{\"msg\":\"操作成功\",\"code\":0}', 0, NULL, '2026-04-01 18:07:32', 8);
INSERT INTO `sys_oper_log` VALUES (108, '病历管理', 1, 'com.ruoyi.project.clinic.medical.controller.ClinicMedicalRecordController.addSave()', 'POST', 1, 'admin', NULL, '/clinic/medical/add', '127.0.0.1', '内网IP', '{\"patientId\":[\"101\"],\"patientName\":[\"钱红\"],\"patientGender\":[\"female\"],\"patientAge\":[\"33\"],\"patientPhone\":[\"13800138006\"],\"patientBirthday\":[\"1992-07-22\"],\"patientBloodType\":[\"B\"],\"allergyHistory\":[\"海鲜过敏\"],\"pastHistory\":[\"无特殊病史\"],\"doctorName\":[\"\"],\"visitTime\":[\"2026-04-01T18:09\"],\"chiefComplaint\":[\"1\"],\"presentIllness\":[\"1\"],\"physicalExam\":[\"1\"],\"diagnosis\":[\"1\"],\"treatment\":[\"1\"],\"followUp\":[\"\"],\"prescription\":[\"[{\\\"medicineId\\\":\\\"100\\\",\\\"name\\\":\\\"复方感冒灵颗粒(白云山)\\\",\\\"specification\\\":\\\"10g*9袋\\\",\\\"dosage\\\":\\\"1\\\",\\\"frequency\\\":\\\"1\\\",\\\"days\\\":\\\"1\\\",\\\"isPackMedicine\\\":0},{\\\"name\\\":\\\"包药\\\",\\\"dosage\\\":\\\"2片\\\",\\\"frequency\\\":\\\"每日3次\\\",\\\"days\\\":\\\"4\\\",\\\"isPackMedicine\\\":1,\\\"packItems\\\":[{\\\"medicineId\\\":104,\\\"name\\\":\\\"维C银翘片(贵州百灵)\\\",\\\"specification\\\":\\\"12片*2板\\\",\\\"quantity\\\":1,\\\"batchId\\\":105,\\\"batchNumber\\\":\\\"B2027E001\\\"},{\\\"medicineId\\\":111,\\\"name\\\":\\\"维生素C片(华中药业)\\\",\\\"specification\\\":\\\"0.1g*100片\\\",\\\"quantity\\\":1,\\\"batchId\\\":133,\\\"batchNumber\\\":\\\"BL20271230001\\\"}]}]\"]}', '{\"msg\":\"操作成功\",\"code\":0}', 0, NULL, '2026-04-01 18:10:32', 15);
INSERT INTO `sys_oper_log` VALUES (109, '病历管理', 2, 'com.ruoyi.project.clinic.medical.controller.ClinicMedicalRecordController.editSave()', 'POST', 1, 'admin', NULL, '/clinic/medical/edit', '127.0.0.1', '内网IP', '{\"recordId\":[\"124\"],\"patientId\":[\"209\"],\"patientName\":[\"郭敏\"],\"doctorName\":[\"张医生\"],\"visitTime\":[\"2026-05-01 01:00:00\"],\"chiefComplaint\":[\"感冒复诊\"],\"presentIllness\":[\"服药后体温恢复正常，咽痛明显减轻\"],\"physicalExam\":[\"体温36.6℃，咽部轻度充血，扁桃体I度肿大\"],\"diagnosis\":[\"急性扁桃体炎（好转）\"],\"treatment\":[\"无需继续用药\"],\"followUp\":[\"注意保暖，适量运动\"],\"prescription\":[\"[{\\\"name\\\":\\\"包药\\\",\\\"dosage\\\":\\\"2片\\\",\\\"frequency\\\":\\\"每日3次\\\",\\\"days\\\":\\\"\\\",\\\"isPackMedicine\\\":1,\\\"packItems\\\":[{\\\"medicineId\\\":104,\\\"name\\\":\\\"维C银翘片(贵州百灵)\\\",\\\"specification\\\":\\\"12片*2板\\\",\\\"quantity\\\":1,\\\"batchId\\\":105,\\\"batchNumber\\\":\\\"B2027E001\\\"},{\\\"medicineId\\\":111,\\\"name\\\":\\\"维生素C片(华中药业)\\\",\\\"specification\\\":\\\"0.1g*100片\\\",\\\"quantity\\\":1,\\\"batchId\\\":112,\\\"batchNumber\\\":\\\"B2027L001\\\"}]}]\"]}', '{\"msg\":\"操作成功\",\"code\":0}', 0, NULL, '2026-04-01 18:17:45', 12);
INSERT INTO `sys_oper_log` VALUES (110, '病历管理', 2, 'com.ruoyi.project.clinic.medical.controller.ClinicMedicalRecordController.editSave()', 'POST', 1, 'admin', NULL, '/clinic/medical/edit', '127.0.0.1', '内网IP', '{\"recordId\":[\"124\"],\"patientId\":[\"209\"],\"patientName\":[\"郭敏\"],\"doctorName\":[\"张医生\"],\"visitTime\":[\"2026-04-30 17:00:00\"],\"chiefComplaint\":[\"感冒复诊\"],\"presentIllness\":[\"服药后体温恢复正常，咽痛明显减轻\"],\"physicalExam\":[\"体温36.6℃，咽部轻度充血，扁桃体I度肿大\"],\"diagnosis\":[\"急性扁桃体炎（好转）\"],\"treatment\":[\"无需继续用药\"],\"followUp\":[\"注意保暖，适量运动\"],\"prescription\":[\"[{\\\"name\\\":\\\"包药\\\",\\\"dosage\\\":\\\"3片\\\",\\\"frequency\\\":\\\"每日3次\\\",\\\"days\\\":\\\"\\\",\\\"isPackMedicine\\\":1,\\\"packItems\\\":[{\\\"medicineId\\\":104,\\\"name\\\":\\\"维C银翘片(贵州百灵)\\\",\\\"specification\\\":\\\"12片*2板\\\",\\\"quantity\\\":2,\\\"batchId\\\":105,\\\"batchNumber\\\":\\\"B2027E001\\\"},{\\\"medicineId\\\":111,\\\"name\\\":\\\"维生素C片(华中药业)\\\",\\\"specification\\\":\\\"0.1g*100片\\\",\\\"quantity\\\":1,\\\"batchId\\\":112,\\\"batchNumber\\\":\\\"B2027L001\\\"}]}]\"]}', '{\"msg\":\"操作成功\",\"code\":0}', 0, NULL, '2026-04-01 18:19:31', 8);
INSERT INTO `sys_oper_log` VALUES (111, '病历管理', 2, 'com.ruoyi.project.clinic.medical.controller.ClinicMedicalRecordController.editSave()', 'POST', 1, 'admin', NULL, '/clinic/medical/edit', '127.0.0.1', '内网IP', '{\"recordId\":[\"124\"],\"patientId\":[\"209\"],\"patientName\":[\"郭敏\"],\"doctorName\":[\"张医生\"],\"visitTime\":[\"2026-04-30 09:00:00\"],\"chiefComplaint\":[\"感冒复诊\"],\"presentIllness\":[\"服药后体温恢复正常，咽痛明显减轻\"],\"physicalExam\":[\"体温36.6℃，咽部轻度充血，扁桃体I度肿大\"],\"diagnosis\":[\"急性扁桃体炎（好转）\"],\"treatment\":[\"无需继续用药\"],\"followUp\":[\"注意保暖，适量运动\"],\"prescription\":[\"[{\\\"name\\\":\\\"包药\\\",\\\"dosage\\\":\\\"2片\\\",\\\"frequency\\\":\\\"每日3次\\\",\\\"days\\\":\\\"\\\",\\\"isPackMedicine\\\":1,\\\"packItems\\\":[{\\\"medicineId\\\":104,\\\"name\\\":\\\"维C银翘片(贵州百灵)（贵州百灵企业集团制药股份有限公司）\\\",\\\"specification\\\":\\\"12片*2板\\\",\\\"quantity\\\":1,\\\"batchId\\\":105,\\\"batchNumber\\\":\\\"B2027E001\\\"},{\\\"medicineId\\\":111,\\\"name\\\":\\\"维生素C片(华中药业)（华中药业股份有限公司）\\\",\\\"specification\\\":\\\"0.1g*100片\\\",\\\"quantity\\\":1,\\\"batchId\\\":112,\\\"batchNumber\\\":\\\"B2027L001\\\"}]}]\"]}', '{\"msg\":\"操作成功\",\"code\":0}', 0, NULL, '2026-04-01 18:28:50', 70);
INSERT INTO `sys_oper_log` VALUES (112, '预约管理', 2, 'com.ruoyi.project.clinic.appointment.controller.ClinicAppointmentController.editSave()', 'POST', 1, 'admin', NULL, '/clinic/appointment/edit', '127.0.0.1', '内网IP', '{\"appointmentId\":[\"221\"],\"status\":[\"confirmed\"]}', '{\"msg\":\"操作成功\",\"code\":0}', 0, NULL, '2026-04-01 18:44:55', 15);
INSERT INTO `sys_oper_log` VALUES (113, '预约管理', 2, 'com.ruoyi.project.clinic.appointment.controller.ClinicAppointmentController.editSave()', 'POST', 1, 'admin', NULL, '/clinic/appointment/edit', '127.0.0.1', '内网IP', '{\"appointmentId\":[\"224\"],\"status\":[\"confirmed\"]}', '{\"msg\":\"操作成功\",\"code\":0}', 0, NULL, '2026-04-01 18:45:00', 7);
INSERT INTO `sys_oper_log` VALUES (114, '预约管理', 2, 'com.ruoyi.project.clinic.appointment.controller.ClinicAppointmentController.editSave()', 'POST', 1, 'admin', NULL, '/clinic/appointment/edit', '127.0.0.1', '内网IP', '{\"appointmentId\":[\"218\"],\"status\":[\"confirmed\"]}', '{\"msg\":\"操作成功\",\"code\":0}', 0, NULL, '2026-04-01 18:45:00', 6);
INSERT INTO `sys_oper_log` VALUES (115, '预约管理-叫号', 2, 'com.ruoyi.project.clinic.appointment.controller.ClinicAppointmentController.callAppointment()', 'POST', 1, 'admin', NULL, '/clinic/appointment/call/218', '127.0.0.1', '内网IP', '218', '{\"msg\":\"叫号成功\",\"code\":0}', 0, NULL, '2026-04-01 18:45:02', 8);
INSERT INTO `sys_oper_log` VALUES (116, '预约管理', 2, 'com.ruoyi.project.clinic.appointment.controller.ClinicAppointmentController.editSave()', 'POST', 1, 'admin', NULL, '/clinic/appointment/edit', '127.0.0.1', '内网IP', '{\"appointmentId\":[\"216\"],\"status\":[\"confirmed\"]}', '{\"msg\":\"操作成功\",\"code\":0}', 0, NULL, '2026-04-01 18:45:08', 8);
INSERT INTO `sys_oper_log` VALUES (117, '预约管理-叫号', 2, 'com.ruoyi.project.clinic.appointment.controller.ClinicAppointmentController.callAppointment()', 'POST', 1, 'admin', NULL, '/clinic/appointment/call/216', '127.0.0.1', '内网IP', '216', '{\"msg\":\"叫号成功\",\"code\":0}', 0, NULL, '2026-04-01 18:45:08', 12);
INSERT INTO `sys_oper_log` VALUES (118, '预约管理-完成就诊', 2, 'com.ruoyi.project.clinic.appointment.controller.ClinicAppointmentController.completeAppointment()', 'POST', 1, 'admin', NULL, '/clinic/appointment/complete/216', '127.0.0.1', '内网IP', '216', '{\"msg\":\"nested exception is org.apache.ibatis.binding.BindingException: Parameter \'updateTime\' not found. Available parameters are [updateBy, appointmentId, param1, param2]\",\"code\":500}', 0, NULL, '2026-04-01 18:45:09', 3);
INSERT INTO `sys_oper_log` VALUES (119, '预约管理-完成就诊', 2, 'com.ruoyi.project.clinic.appointment.controller.ClinicAppointmentController.completeAppointment()', 'POST', 1, 'admin', NULL, '/clinic/appointment/complete/216', '127.0.0.1', '内网IP', '216', '{\"msg\":\"nested exception is org.apache.ibatis.binding.BindingException: Parameter \'updateTime\' not found. Available parameters are [updateBy, appointmentId, param1, param2]\",\"code\":500}', 0, NULL, '2026-04-01 18:45:12', 3);
INSERT INTO `sys_oper_log` VALUES (120, '患者管理', 5, 'com.ruoyi.project.clinic.patient.controller.ClinicPatientController.export()', 'POST', 1, 'admin', NULL, '/clinic/patient/export', '127.0.0.1', '内网IP', '{\"name\":[\"\"],\"phone\":[\"\"],\"orderByColumn\":[\"createTime\"],\"isAsc\":[\"desc\"]}', '{\"msg\":\"ae380b3e-69aa-43d6-ad62-df79974078bb_患者数据.xlsx\",\"code\":0}', 0, NULL, '2026-04-01 19:47:59', 531);
INSERT INTO `sys_oper_log` VALUES (121, '药品管理', 1, 'com.ruoyi.project.clinic.medicine.controller.ClinicMedicineController.addSave()', 'POST', 1, 'admin', NULL, '/clinic/medicine/add', '127.0.0.1', '内网IP', '{\"name\":[\"1\"],\"specification\":[\"1\"],\"form\":[\"其他\"],\"price\":[\"1\"],\"warningThreshold\":[\"10\"],\"category\":[\"1\"],\"isPrescription\":[\"0\"],\"pharmacology\":[\"\"],\"indications\":[\"\"],\"dosage\":[\"\"],\"sideEffects\":[\"\"],\"storage\":[\"\"]}', '{\"msg\":\"操作成功\",\"code\":0}', 0, NULL, '2026-04-01 19:50:54', 11);
INSERT INTO `sys_oper_log` VALUES (122, '预约管理', 2, 'com.ruoyi.project.clinic.appointment.controller.ClinicAppointmentController.editSave()', 'POST', 1, 'admin', NULL, '/clinic/appointment/edit', '127.0.0.1', '内网IP', '{\"appointmentId\":[\"226\"],\"status\":[\"confirmed\"]}', '{\"msg\":\"操作成功\",\"code\":0}', 0, NULL, '2026-04-01 20:59:27', 62);
INSERT INTO `sys_oper_log` VALUES (123, '预约管理-叫号', 2, 'com.ruoyi.project.clinic.appointment.controller.ClinicAppointmentController.callAppointment()', 'POST', 1, 'admin', NULL, '/clinic/appointment/call/226', '127.0.0.1', '内网IP', '226', '{\"msg\":\"叫号成功\",\"code\":0}', 0, NULL, '2026-04-01 20:59:28', 8);
INSERT INTO `sys_oper_log` VALUES (124, '患者管理', 2, 'com.ruoyi.project.clinic.patient.controller.ClinicPatientController.editSave()', 'POST', 1, 'admin', NULL, '/clinic/patient/edit', '127.0.0.1', '内网IP', '{\"patientId\":[\"100\"],\"name\":[\"赵明\"],\"gender\":[\"male\"],\"birthday\":[\"1986-03-15\"],\"age\":[\"40\"],\"phone\":[\"13800138005\"],\"address\":[\"北京市朝阳区建国路88号\"],\"allergyHistory\":[\"青霉素过敏\"],\"pastHistory\":[\"高血压病史5年，规律服药\"],\"bloodType\":[\"A\"],\"wechat\":[\"zhaoming8\"]}', '{\"msg\":\"操作成功\",\"code\":0}', 0, NULL, '2026-04-03 00:27:06', 132);
INSERT INTO `sys_oper_log` VALUES (125, '药品管理', 2, 'com.ruoyi.project.clinic.medicine.controller.ClinicMedicineController.editSave()', 'POST', 1, 'admin', NULL, '/clinic/medicine/edit', '127.0.0.1', '内网IP', '{\"medicineId\":[\"100\"],\"stock\":[\"290\"],\"name\":[\"复方感冒灵颗粒(白云山)（广州白云山制药总厂）\"],\"specification\":[\"10g*9袋\"],\"form\":[\"\"],\"price\":[\"15.80\"],\"warningThreshold\":[\"38\"],\"category\":[\"内服药\"],\"isPrescription\":[\"0\"],\"pharmacology\":[\"中西药复方制剂，金银花、五指柑、野菊花、三叉苦、南板蓝根、岗梅等中药成分具有清热解毒功效；对乙酰氨基酚、马来酸氯苯那敏能缓解感冒症状。\"],\"indications\":[\"用于风热感冒之发热、微恶风寒、鼻塞流涕、咽喉肿痛等症。\"],\"dosage\":[\"开水冲服，一次1袋，一日3次\"],\"sideEffects\":[\"可见困倦、嗜睡、口渴、虚弱感；偶见皮疹、瘙痒、食欲不振、恶心等。\"],\"storage\":[\"密封，置阴凉干燥处（不超过20℃）。\"]}', '{\"msg\":\"操作成功\",\"code\":0}', 0, NULL, '2026-04-03 00:27:17', 33);
INSERT INTO `sys_oper_log` VALUES (126, '病历管理', 1, 'com.ruoyi.project.clinic.medical.controller.ClinicMedicalRecordController.addSave()', 'POST', 1, 'admin', NULL, '/clinic/medical/add', '127.0.0.1', '内网IP', '{\"patientId\":[\"101\"],\"patientName\":[\"钱红\"],\"patientGender\":[\"female\"],\"patientAge\":[\"33\"],\"patientPhone\":[\"13800138006\"],\"patientBirthday\":[\"1992-07-22\"],\"patientBloodType\":[\"B\"],\"allergyHistory\":[\"海鲜过敏\"],\"pastHistory\":[\"无特殊病史\"],\"doctorName\":[\"李医生\"],\"visitTime\":[\"2026-04-03T00:29\"],\"chiefComplaint\":[\"12\"],\"presentIllness\":[\"12\"],\"physicalExam\":[\"2\"],\"diagnosis\":[\"12\"],\"treatment\":[\"2\"],\"followUp\":[\"\"],\"prescription\":[\"[{\\\"name\\\":\\\"包药\\\",\\\"dosage\\\":\\\"2片\\\",\\\"frequency\\\":\\\"每日3次\\\",\\\"days\\\":\\\"\\\",\\\"isPackMedicine\\\":1,\\\"packItems\\\":[{\\\"medicineId\\\":104,\\\"name\\\":\\\"维C银翘片(贵州百灵)（贵州百灵企业集团制药股份有限公司）\\\",\\\"specification\\\":\\\"12片*2板\\\",\\\"quantity\\\":1,\\\"batchId\\\":105,\\\"batchNumber\\\":\\\"B2027E001\\\"},{\\\"medicineId\\\":111,\\\"name\\\":\\\"维生素C片(华中药业)（华中药业股份有限公司）\\\",\\\"specification\\\":\\\"0.1g*100片\\\",\\\"quantity\\\":1,\\\"batchId\\\":133,\\\"batchNumber\\\":\\\"BL20271230001\\\"}]},{\\\"medicineId\\\":\\\"109\\\",\\\"name\\\":\\\"左氧氟沙星片(第一三共)（第一三共制药(上海)有限公司）\\\",\\\"specification\\\":\\\"0.5g*6片\\\",\\\"dosage\\\":\\\"1\\\",\\\"frequency\\\":\\\"1\\\",\\\"days\\\":\\\"1\\\",\\\"isPackMedicine\\\":0}]\"]}', '{\"msg\":\"操作成功\",\"code\":0}', 0, NULL, '2026-04-03 00:29:35', 24);
INSERT INTO `sys_oper_log` VALUES (127, '预约管理', 1, 'com.ruoyi.project.clinic.appointment.controller.ClinicAppointmentController.addSave()', 'POST', 1, 'admin', NULL, '/clinic/appointment/add', '127.0.0.1', '内网IP', '{\"patientId\":[\"101\"],\"doctorId\":[\"101\"],\"scheduleId\":[\"102\"],\"patientName\":[\"钱红\"],\"doctorName\":[\"李医生\"],\"appointmentDate\":[\"2026-04-02\"],\"appointmentTime\":[\"08:30 - 12:00\"]}', '{\"msg\":\"操作成功\",\"code\":0}', 0, NULL, '2026-04-03 00:29:57', 35);
INSERT INTO `sys_oper_log` VALUES (128, '排班管理', 1, 'com.ruoyi.project.clinic.schedule.controller.ClinicScheduleController.addSave()', 'POST', 1, 'admin', NULL, '/clinic/schedule/add', '127.0.0.1', '内网IP', '{\"doctorName\":[\"李医生\"],\"scheduleDate\":[\"2026-04-03\"],\"startTime\":[\"00:30\"],\"endTime\":[\"06:36\"],\"totalSlots\":[\"\"]}', NULL, 1, '\r\n### Error updating database.  Cause: java.sql.SQLIntegrityConstraintViolationException: Column \'doctor_id\' cannot be null\r\n### The error may exist in file [E:\\诊所管理系统\\wechatproject-1fddcb4e84ee7d18b7e079d6ec1fe0b639cb626c\\springboot\\target\\classes\\mybatis\\clinic\\ClinicScheduleMapper.xml]\r\n### The error may involve defaultParameterMap\r\n### The error occurred while setting parameters\r\n### SQL: INSERT INTO clinic_schedule(         doctor_id,         doctor_name,         schedule_date,         start_time,         end_time,         total_slots,         booked_slots,         status,         create_by,         create_time,         remark         ) VALUES (         ?,         ?,         ?,         ?,         ?,         ?,         ?,         ?,         ?,         ?,         ?         )\r\n### Cause: java.sql.SQLIntegrityConstraintViolationException: Column \'doctor_id\' cannot be null\n; Column \'doctor_id\' cannot be null; nested exception is java.sql.SQLIntegrityConstraintViolationException: Column \'doctor_id\' cannot be null', '2026-04-03 00:30:14', 16);
INSERT INTO `sys_oper_log` VALUES (129, '排班管理', 1, 'com.ruoyi.project.clinic.schedule.controller.ClinicScheduleController.addSave()', 'POST', 1, 'admin', NULL, '/clinic/schedule/add', '127.0.0.1', '内网IP', '{\"doctorName\":[\"李医生\"],\"scheduleDate\":[\"2026-04-03\"],\"startTime\":[\"00:30\"],\"endTime\":[\"06:36\"],\"totalSlots\":[\"29\"]}', NULL, 1, '\r\n### Error updating database.  Cause: java.sql.SQLIntegrityConstraintViolationException: Column \'doctor_id\' cannot be null\r\n### The error may exist in file [E:\\诊所管理系统\\wechatproject-1fddcb4e84ee7d18b7e079d6ec1fe0b639cb626c\\springboot\\target\\classes\\mybatis\\clinic\\ClinicScheduleMapper.xml]\r\n### The error may involve defaultParameterMap\r\n### The error occurred while setting parameters\r\n### SQL: INSERT INTO clinic_schedule(         doctor_id,         doctor_name,         schedule_date,         start_time,         end_time,         total_slots,         booked_slots,         status,         create_by,         create_time,         remark         ) VALUES (         ?,         ?,         ?,         ?,         ?,         ?,         ?,         ?,         ?,         ?,         ?         )\r\n### Cause: java.sql.SQLIntegrityConstraintViolationException: Column \'doctor_id\' cannot be null\n; Column \'doctor_id\' cannot be null; nested exception is java.sql.SQLIntegrityConstraintViolationException: Column \'doctor_id\' cannot be null', '2026-04-03 00:30:20', 7);
INSERT INTO `sys_oper_log` VALUES (130, '预约管理-叫号', 2, 'com.ruoyi.project.clinic.appointment.controller.ClinicAppointmentController.callAppointment()', 'POST', 1, 'admin', NULL, '/clinic/appointment/call/100', '127.0.0.1', '内网IP', '100', '{\"msg\":\"叫号成功\",\"code\":0}', 0, NULL, '2026-04-03 00:45:17', 23);
INSERT INTO `sys_oper_log` VALUES (131, '排班管理', 1, 'com.ruoyi.project.clinic.schedule.controller.ClinicScheduleController.addSave()', 'POST', 1, 'admin', NULL, '/clinic/schedule/add', '127.0.0.1', '内网IP', '{\"doctorName\":[\"李医生\"],\"doctorId\":[\"101\"],\"scheduleDate\":[\"2026-04-03\"],\"startTime\":[\"00:55\"],\"endTime\":[\"06:55\"],\"totalSlots\":[\"20\"]}', '{\"msg\":\"操作成功\",\"code\":0}', 0, NULL, '2026-04-03 00:55:40', 42);

-- ----------------------------
-- Table structure for sys_post
-- ----------------------------
DROP TABLE IF EXISTS `sys_post`;
CREATE TABLE `sys_post`  (
  `post_id` bigint NOT NULL AUTO_INCREMENT COMMENT '岗位ID',
  `post_code` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '岗位编码',
  `post_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '岗位名称',
  `post_sort` int NOT NULL COMMENT '显示顺序',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '状态（0正常 1停用）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`post_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '岗位信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_post
-- ----------------------------
INSERT INTO `sys_post` VALUES (1, 'ceo', '董事长', 1, '0', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_post` VALUES (2, 'se', '项目经理', 2, '0', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_post` VALUES (3, 'hr', '人力资源', 3, '0', 'admin', '2026-04-01 17:23:08', '', NULL, '');
INSERT INTO `sys_post` VALUES (4, 'user', '普通员工', 4, '0', 'admin', '2026-04-01 17:23:08', '', NULL, '');

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`  (
  `role_id` bigint NOT NULL AUTO_INCREMENT COMMENT '角色ID',
  `role_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色名称',
  `role_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色权限字符串',
  `role_sort` int NOT NULL COMMENT '显示顺序',
  `data_scope` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '1' COMMENT '数据范围（1：全部数据权限 2：自定数据权限 3：本部门数据权限 4：本部门及以下数据权限）',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '角色状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`role_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 100 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO `sys_role` VALUES (1, '超级管理员', 'admin', 1, '1', '0', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '超级管理员');
INSERT INTO `sys_role` VALUES (2, '普通角色', 'common', 2, '2', '0', '0', 'admin', '2026-04-01 17:23:08', '', NULL, '普通角色');
INSERT INTO `sys_role` VALUES (3, '医生', 'doctor', 3, '1', '0', '0', 'admin', '2026-04-01 17:23:10', '', NULL, '医生角色');
INSERT INTO `sys_role` VALUES (4, '患者', 'patient', 4, '1', '0', '0', 'admin', '2026-04-01 17:23:10', '', NULL, '患者角色');

-- ----------------------------
-- Table structure for sys_role_dept
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_dept`;
CREATE TABLE `sys_role_dept`  (
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `dept_id` bigint NOT NULL COMMENT '部门ID',
  PRIMARY KEY (`role_id`, `dept_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色和部门关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role_dept
-- ----------------------------
INSERT INTO `sys_role_dept` VALUES (2, 100);
INSERT INTO `sys_role_dept` VALUES (2, 101);
INSERT INTO `sys_role_dept` VALUES (2, 105);

-- ----------------------------
-- Table structure for sys_role_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_menu`;
CREATE TABLE `sys_role_menu`  (
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `menu_id` bigint NOT NULL COMMENT '菜单ID',
  PRIMARY KEY (`role_id`, `menu_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色和菜单关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_role_menu
-- ----------------------------
INSERT INTO `sys_role_menu` VALUES (1, 2000);
INSERT INTO `sys_role_menu` VALUES (1, 2001);
INSERT INTO `sys_role_menu` VALUES (1, 2002);
INSERT INTO `sys_role_menu` VALUES (1, 2003);
INSERT INTO `sys_role_menu` VALUES (1, 2004);
INSERT INTO `sys_role_menu` VALUES (1, 2005);
INSERT INTO `sys_role_menu` VALUES (1, 2006);
INSERT INTO `sys_role_menu` VALUES (1, 2010);
INSERT INTO `sys_role_menu` VALUES (1, 2011);
INSERT INTO `sys_role_menu` VALUES (1, 2012);
INSERT INTO `sys_role_menu` VALUES (1, 2013);
INSERT INTO `sys_role_menu` VALUES (1, 2014);
INSERT INTO `sys_role_menu` VALUES (1, 2015);
INSERT INTO `sys_role_menu` VALUES (1, 2030);
INSERT INTO `sys_role_menu` VALUES (1, 2031);
INSERT INTO `sys_role_menu` VALUES (1, 2032);
INSERT INTO `sys_role_menu` VALUES (1, 2033);
INSERT INTO `sys_role_menu` VALUES (1, 2034);
INSERT INTO `sys_role_menu` VALUES (1, 2040);
INSERT INTO `sys_role_menu` VALUES (1, 2041);
INSERT INTO `sys_role_menu` VALUES (1, 2042);
INSERT INTO `sys_role_menu` VALUES (1, 2043);
INSERT INTO `sys_role_menu` VALUES (1, 2044);
INSERT INTO `sys_role_menu` VALUES (1, 2050);
INSERT INTO `sys_role_menu` VALUES (1, 2051);
INSERT INTO `sys_role_menu` VALUES (1, 2052);
INSERT INTO `sys_role_menu` VALUES (1, 2053);
INSERT INTO `sys_role_menu` VALUES (1, 2054);
INSERT INTO `sys_role_menu` VALUES (2, 1);
INSERT INTO `sys_role_menu` VALUES (2, 2);
INSERT INTO `sys_role_menu` VALUES (2, 3);
INSERT INTO `sys_role_menu` VALUES (2, 4);
INSERT INTO `sys_role_menu` VALUES (2, 100);
INSERT INTO `sys_role_menu` VALUES (2, 101);
INSERT INTO `sys_role_menu` VALUES (2, 102);
INSERT INTO `sys_role_menu` VALUES (2, 103);
INSERT INTO `sys_role_menu` VALUES (2, 104);
INSERT INTO `sys_role_menu` VALUES (2, 105);
INSERT INTO `sys_role_menu` VALUES (2, 106);
INSERT INTO `sys_role_menu` VALUES (2, 107);
INSERT INTO `sys_role_menu` VALUES (2, 108);
INSERT INTO `sys_role_menu` VALUES (2, 109);
INSERT INTO `sys_role_menu` VALUES (2, 110);
INSERT INTO `sys_role_menu` VALUES (2, 111);
INSERT INTO `sys_role_menu` VALUES (2, 112);
INSERT INTO `sys_role_menu` VALUES (2, 113);
INSERT INTO `sys_role_menu` VALUES (2, 114);
INSERT INTO `sys_role_menu` VALUES (2, 115);
INSERT INTO `sys_role_menu` VALUES (2, 116);
INSERT INTO `sys_role_menu` VALUES (2, 500);
INSERT INTO `sys_role_menu` VALUES (2, 501);
INSERT INTO `sys_role_menu` VALUES (2, 1000);
INSERT INTO `sys_role_menu` VALUES (2, 1001);
INSERT INTO `sys_role_menu` VALUES (2, 1002);
INSERT INTO `sys_role_menu` VALUES (2, 1003);
INSERT INTO `sys_role_menu` VALUES (2, 1004);
INSERT INTO `sys_role_menu` VALUES (2, 1005);
INSERT INTO `sys_role_menu` VALUES (2, 1006);
INSERT INTO `sys_role_menu` VALUES (2, 1007);
INSERT INTO `sys_role_menu` VALUES (2, 1008);
INSERT INTO `sys_role_menu` VALUES (2, 1009);
INSERT INTO `sys_role_menu` VALUES (2, 1010);
INSERT INTO `sys_role_menu` VALUES (2, 1011);
INSERT INTO `sys_role_menu` VALUES (2, 1012);
INSERT INTO `sys_role_menu` VALUES (2, 1013);
INSERT INTO `sys_role_menu` VALUES (2, 1014);
INSERT INTO `sys_role_menu` VALUES (2, 1015);
INSERT INTO `sys_role_menu` VALUES (2, 1016);
INSERT INTO `sys_role_menu` VALUES (2, 1017);
INSERT INTO `sys_role_menu` VALUES (2, 1018);
INSERT INTO `sys_role_menu` VALUES (2, 1019);
INSERT INTO `sys_role_menu` VALUES (2, 1020);
INSERT INTO `sys_role_menu` VALUES (2, 1021);
INSERT INTO `sys_role_menu` VALUES (2, 1022);
INSERT INTO `sys_role_menu` VALUES (2, 1023);
INSERT INTO `sys_role_menu` VALUES (2, 1024);
INSERT INTO `sys_role_menu` VALUES (2, 1025);
INSERT INTO `sys_role_menu` VALUES (2, 1026);
INSERT INTO `sys_role_menu` VALUES (2, 1027);
INSERT INTO `sys_role_menu` VALUES (2, 1028);
INSERT INTO `sys_role_menu` VALUES (2, 1029);
INSERT INTO `sys_role_menu` VALUES (2, 1030);
INSERT INTO `sys_role_menu` VALUES (2, 1031);
INSERT INTO `sys_role_menu` VALUES (2, 1032);
INSERT INTO `sys_role_menu` VALUES (2, 1033);
INSERT INTO `sys_role_menu` VALUES (2, 1034);
INSERT INTO `sys_role_menu` VALUES (2, 1035);
INSERT INTO `sys_role_menu` VALUES (2, 1036);
INSERT INTO `sys_role_menu` VALUES (2, 1037);
INSERT INTO `sys_role_menu` VALUES (2, 1038);
INSERT INTO `sys_role_menu` VALUES (2, 1039);
INSERT INTO `sys_role_menu` VALUES (2, 1040);
INSERT INTO `sys_role_menu` VALUES (2, 1041);
INSERT INTO `sys_role_menu` VALUES (2, 1042);
INSERT INTO `sys_role_menu` VALUES (2, 1043);
INSERT INTO `sys_role_menu` VALUES (2, 1044);
INSERT INTO `sys_role_menu` VALUES (2, 1045);
INSERT INTO `sys_role_menu` VALUES (2, 1046);
INSERT INTO `sys_role_menu` VALUES (2, 1047);
INSERT INTO `sys_role_menu` VALUES (2, 1048);
INSERT INTO `sys_role_menu` VALUES (2, 1049);
INSERT INTO `sys_role_menu` VALUES (2, 1050);
INSERT INTO `sys_role_menu` VALUES (2, 1051);
INSERT INTO `sys_role_menu` VALUES (2, 1052);
INSERT INTO `sys_role_menu` VALUES (2, 1053);
INSERT INTO `sys_role_menu` VALUES (2, 1054);
INSERT INTO `sys_role_menu` VALUES (2, 1055);
INSERT INTO `sys_role_menu` VALUES (2, 1056);
INSERT INTO `sys_role_menu` VALUES (2, 1057);
INSERT INTO `sys_role_menu` VALUES (2, 1058);
INSERT INTO `sys_role_menu` VALUES (2, 1059);
INSERT INTO `sys_role_menu` VALUES (2, 1060);
INSERT INTO `sys_role_menu` VALUES (2, 1061);
INSERT INTO `sys_role_menu` VALUES (2, 2000);
INSERT INTO `sys_role_menu` VALUES (2, 2001);
INSERT INTO `sys_role_menu` VALUES (2, 2002);
INSERT INTO `sys_role_menu` VALUES (2, 2003);
INSERT INTO `sys_role_menu` VALUES (2, 2004);
INSERT INTO `sys_role_menu` VALUES (2, 2005);
INSERT INTO `sys_role_menu` VALUES (2, 2006);
INSERT INTO `sys_role_menu` VALUES (2, 2010);
INSERT INTO `sys_role_menu` VALUES (2, 2011);
INSERT INTO `sys_role_menu` VALUES (2, 2012);
INSERT INTO `sys_role_menu` VALUES (2, 2013);
INSERT INTO `sys_role_menu` VALUES (2, 2014);
INSERT INTO `sys_role_menu` VALUES (2, 2015);
INSERT INTO `sys_role_menu` VALUES (2, 2030);
INSERT INTO `sys_role_menu` VALUES (2, 2031);
INSERT INTO `sys_role_menu` VALUES (2, 2032);
INSERT INTO `sys_role_menu` VALUES (2, 2033);
INSERT INTO `sys_role_menu` VALUES (2, 2034);
INSERT INTO `sys_role_menu` VALUES (2, 2040);
INSERT INTO `sys_role_menu` VALUES (2, 2041);
INSERT INTO `sys_role_menu` VALUES (2, 2042);
INSERT INTO `sys_role_menu` VALUES (2, 2043);
INSERT INTO `sys_role_menu` VALUES (2, 2044);
INSERT INTO `sys_role_menu` VALUES (2, 2050);
INSERT INTO `sys_role_menu` VALUES (2, 2051);
INSERT INTO `sys_role_menu` VALUES (2, 2052);
INSERT INTO `sys_role_menu` VALUES (2, 2053);
INSERT INTO `sys_role_menu` VALUES (2, 2054);
INSERT INTO `sys_role_menu` VALUES (3, 2000);
INSERT INTO `sys_role_menu` VALUES (3, 2001);
INSERT INTO `sys_role_menu` VALUES (3, 2002);
INSERT INTO `sys_role_menu` VALUES (3, 2003);
INSERT INTO `sys_role_menu` VALUES (3, 2010);
INSERT INTO `sys_role_menu` VALUES (3, 2011);
INSERT INTO `sys_role_menu` VALUES (3, 2030);
INSERT INTO `sys_role_menu` VALUES (3, 2031);
INSERT INTO `sys_role_menu` VALUES (3, 2032);
INSERT INTO `sys_role_menu` VALUES (3, 2033);
INSERT INTO `sys_role_menu` VALUES (3, 2040);
INSERT INTO `sys_role_menu` VALUES (3, 2041);
INSERT INTO `sys_role_menu` VALUES (3, 2042);
INSERT INTO `sys_role_menu` VALUES (3, 2043);
INSERT INTO `sys_role_menu` VALUES (3, 2050);
INSERT INTO `sys_role_menu` VALUES (3, 2051);
INSERT INTO `sys_role_menu` VALUES (3, 2052);
INSERT INTO `sys_role_menu` VALUES (3, 2053);
INSERT INTO `sys_role_menu` VALUES (4, 2000);
INSERT INTO `sys_role_menu` VALUES (4, 2030);
INSERT INTO `sys_role_menu` VALUES (4, 2031);
INSERT INTO `sys_role_menu` VALUES (4, 2040);
INSERT INTO `sys_role_menu` VALUES (4, 2041);
INSERT INTO `sys_role_menu` VALUES (4, 2042);
INSERT INTO `sys_role_menu` VALUES (4, 2043);
INSERT INTO `sys_role_menu` VALUES (4, 2050);
INSERT INTO `sys_role_menu` VALUES (4, 2051);

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `user_id` bigint NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `dept_id` bigint NULL DEFAULT NULL COMMENT '部门ID',
  `login_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '登录账号',
  `user_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '用户昵称',
  `user_type` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '00' COMMENT '用户类型（00系统用户 01注册用户）',
  `email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '用户邮箱',
  `phonenumber` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '手机号码',
  `sex` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '用户性别（0男 1女 2未知）',
  `avatar` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '头像路径',
  `password` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '密码',
  `salt` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '盐加密',
  `status` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '账号状态（0正常 1停用）',
  `del_flag` char(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '0' COMMENT '删除标志（0代表存在 2代表删除）',
  `login_ip` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '最后登录IP',
  `login_date` datetime NULL DEFAULT NULL COMMENT '最后登录时间',
  `pwd_update_date` datetime NULL DEFAULT NULL COMMENT '密码最后更新时间',
  `create_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '创建者',
  `create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '更新者',
  `update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 212 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 103, 'admin', '若依', '00', 'ry@163.com', '15888888888', '1', '', '3d3e2e119996cedb7401025cced5c1b0', '111111', '0', '0', '127.0.0.1', '2026-04-03 02:00:54', NULL, 'admin', '2026-04-01 17:23:08', '', NULL, '管理员');
INSERT INTO `sys_user` VALUES (100, 100, '13800138001', '诊所管理员', '00', 'admin@clinic.com', '13800138001', '0', '', '88ab6f5bfc7fe477ec9b795aa9a4619d', '111111', '0', '0', '127.0.0.1', '2026-04-03 11:33:21', NULL, 'admin', '2026-04-01 17:23:10', '', NULL, '诊所管理员');
INSERT INTO `sys_user` VALUES (101, 103, '13800138002', '李医生', '00', 'doctor1@clinic.com', '13800138002', '0', '', '281a72b7b4438b444c09b118bdff5c69', '111111', '0', '0', '127.0.0.1', '2026-04-03 02:58:14', NULL, 'admin', '2026-04-01 17:23:10', '', NULL, '内科医生');
INSERT INTO `sys_user` VALUES (102, 103, '13800138003', '王医生', '00', 'doctor2@clinic.com', '13800138003', '1', '', '21653735b0ee01a9c33170340ed67d53', '111111', '0', '0', '', NULL, NULL, 'admin', '2026-04-01 17:23:10', '', NULL, '外科医生');
INSERT INTO `sys_user` VALUES (103, 103, '13800138004', '张医生', '00', 'doctor3@clinic.com', '13800138004', '0', '', 'e72ece2d1b37e95dc66b6ad0ebef95d6', '111111', '0', '0', '', NULL, NULL, 'admin', '2026-04-01 17:23:10', '', NULL, '儿科医生');
INSERT INTO `sys_user` VALUES (200, 103, '13800138100', '赵明', '01', 'patient1@clinic.com', '13800138005', '0', '', 'ba615b197d650049c6e341a3fd95bc9b', '111111', '0', '0', '127.0.0.1', '2026-04-03 03:01:07', NULL, 'admin', '2026-04-01 17:23:10', '13800138100', '2026-04-03 02:19:20', '患者账号');
INSERT INTO `sys_user` VALUES (201, 103, '13800138101', '钱红', '01', 'patient2@clinic.com', '13800138101', '1', '', 'f23b9fc19265b0ed3acaa68eb197d70e', '111111', '0', '0', '', NULL, NULL, 'admin', '2026-04-01 17:23:10', '', NULL, '患者账号');
INSERT INTO `sys_user` VALUES (202, 103, '13800138102', '孙伟', '01', 'patient3@clinic.com', '13800138102', '0', '', '0c6019ce5ea46199ae073700ba1ebc08', '111111', '0', '0', '', NULL, NULL, 'admin', '2026-04-01 17:23:10', '', NULL, '患者账号');
INSERT INTO `sys_user` VALUES (203, 103, '13800138103', '李静', '01', 'patient4@clinic.com', '13800138103', '1', '', 'c68eb5b912da03c8b200ed773617bc89', '111111', '0', '0', '', NULL, NULL, 'admin', '2026-04-01 17:23:10', '', NULL, '患者账号');
INSERT INTO `sys_user` VALUES (204, 103, '13800138104', '周强', '01', 'patient5@clinic.com', '13800138104', '0', '', '38b6d495f103fc9bd6b1fe34964c35b1', '111111', '0', '0', '', NULL, NULL, 'admin', '2026-04-01 17:23:10', '', NULL, '患者账号');
INSERT INTO `sys_user` VALUES (205, 103, '13800138105', '吴婷', '01', 'patient6@clinic.com', '13800138105', '1', '', '0c0865403895cfdd5763e430f5a6dec9', '111111', '0', '0', '', NULL, NULL, 'admin', '2026-04-01 17:23:10', '', NULL, '患者账号');
INSERT INTO `sys_user` VALUES (206, 103, '13800138106', '郑峰', '01', 'patient7@clinic.com', '13800138106', '0', '', 'e4de1f84d8e4d39bae22144f168896a2', '111111', '0', '0', '', NULL, NULL, 'admin', '2026-04-01 17:23:10', '', NULL, '患者账号');
INSERT INTO `sys_user` VALUES (207, 103, '13800138107', '王芳', '01', 'patient8@clinic.com', '13800138107', '1', '', 'ecb86b65216de97054320552496c24b7', '111111', '0', '0', '', NULL, NULL, 'admin', '2026-04-01 17:23:10', '', NULL, '患者账号');
INSERT INTO `sys_user` VALUES (208, 103, '13800138108', '何磊', '01', 'patient9@clinic.com', '13800138108', '0', '', 'd4190e46647917fa2a549f8183a9b191', '111111', '0', '0', '', NULL, NULL, 'admin', '2026-04-01 17:23:10', '', NULL, '患者账号');
INSERT INTO `sys_user` VALUES (209, 103, '13800138109', '郭敏', '01', 'patient10@clinic.com', '13800138109', '1', '', '0b3e750a27349df4fe389feb35ccd62b', '111111', '0', '0', '', NULL, NULL, 'admin', '2026-04-01 17:23:10', '', NULL, '患者账号');
INSERT INTO `sys_user` VALUES (210, 103, '13800138110', '陈旭', '01', 'patient11@clinic.com', '13800138110', '0', '', '7ca74178f4bed268744ad586dd8f38eb', '111111', '0', '0', '', NULL, NULL, 'admin', '2026-04-01 17:23:10', '', NULL, '患者账号');
INSERT INTO `sys_user` VALUES (211, 103, '13800138111', '宋雨', '01', 'patient12@clinic.com', '13800138111', '1', '', 'ee9dc20f2b1cab1d81b506146dbbb764', '111111', '0', '0', '127.0.0.1', '2026-04-01 20:57:22', NULL, 'admin', '2026-04-01 17:23:10', '', NULL, '患者账号');

-- ----------------------------
-- Table structure for sys_user_online
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_online`;
CREATE TABLE `sys_user_online`  (
  `sessionId` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '' COMMENT '用户会话id',
  `login_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '登录账号',
  `dept_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '部门名称',
  `ipaddr` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '登录IP地址',
  `login_location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '登录地点',
  `browser` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '浏览器类型',
  `os` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '操作系统',
  `status` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '' COMMENT '在线状态on_line在线off_line离线',
  `start_timestamp` datetime NULL DEFAULT NULL COMMENT 'session创建时间',
  `last_access_time` datetime NULL DEFAULT NULL COMMENT 'session最后访问时间',
  `expire_time` int NULL DEFAULT 0 COMMENT '超时时间，单位为分钟',
  PRIMARY KEY (`sessionId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '在线用户记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user_online
-- ----------------------------
INSERT INTO `sys_user_online` VALUES ('37c7c770-b341-4165-9ace-4705734e9886', '13800138001', NULL, '127.0.0.1', '内网IP', 'Chrome 14', 'Windows 10', 'on_line', '2026-04-03 11:11:20', '2026-04-03 11:11:35', 1800000);
INSERT INTO `sys_user_online` VALUES ('6403aabd-933f-4064-b1cb-5ba9f802d42e', '13800138001', NULL, '127.0.0.1', '内网IP', 'Mobile Safari', 'Mac OS X (iPhone)', 'on_line', '2026-04-03 11:33:21', '2026-04-03 11:33:30', 1800000);

-- ----------------------------
-- Table structure for sys_user_post
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_post`;
CREATE TABLE `sys_user_post`  (
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `post_id` bigint NOT NULL COMMENT '岗位ID',
  PRIMARY KEY (`user_id`, `post_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户与岗位关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user_post
-- ----------------------------
INSERT INTO `sys_user_post` VALUES (1, 1);
INSERT INTO `sys_user_post` VALUES (2, 2);

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role`  (
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`user_id`, `role_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户和角色关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sys_user_role
-- ----------------------------
INSERT INTO `sys_user_role` VALUES (1, 1);
INSERT INTO `sys_user_role` VALUES (100, 2);
INSERT INTO `sys_user_role` VALUES (101, 3);
INSERT INTO `sys_user_role` VALUES (102, 3);
INSERT INTO `sys_user_role` VALUES (103, 3);
INSERT INTO `sys_user_role` VALUES (200, 4);
INSERT INTO `sys_user_role` VALUES (201, 4);
INSERT INTO `sys_user_role` VALUES (202, 4);
INSERT INTO `sys_user_role` VALUES (203, 4);
INSERT INTO `sys_user_role` VALUES (204, 4);
INSERT INTO `sys_user_role` VALUES (205, 4);
INSERT INTO `sys_user_role` VALUES (206, 4);
INSERT INTO `sys_user_role` VALUES (207, 4);
INSERT INTO `sys_user_role` VALUES (208, 4);
INSERT INTO `sys_user_role` VALUES (209, 4);
INSERT INTO `sys_user_role` VALUES (210, 4);
INSERT INTO `sys_user_role` VALUES (211, 4);

SET FOREIGN_KEY_CHECKS = 1;
