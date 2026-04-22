ALTER TABLE clinic_stock_record
    ADD COLUMN patient_id BIGINT(20) NULL DEFAULT NULL COMMENT '患者档案ID' AFTER patient_name,
    ADD COLUMN doctor_id BIGINT(20) NULL DEFAULT NULL COMMENT '医生用户ID' AFTER doctor_name;

ALTER TABLE clinic_stock_record
    ADD INDEX idx_clinic_stock_record_patient_id (patient_id),
    ADD INDEX idx_clinic_stock_record_doctor_id (doctor_id);

UPDATE clinic_stock_record sr
INNER JOIN clinic_medical_record mr
    ON sr.related_record_type IN ('medical_record', 'medical')
   AND sr.related_record_id REGEXP '^[0-9]+$'
   AND CAST(sr.related_record_id AS UNSIGNED) = mr.record_id
SET sr.patient_id = COALESCE(sr.patient_id, mr.patient_id),
    sr.patient_name = COALESCE(NULLIF(sr.patient_name, ''), mr.patient_name),
    sr.doctor_id = COALESCE(sr.doctor_id, mr.doctor_id),
    sr.doctor_name = COALESCE(NULLIF(sr.doctor_name, ''), mr.doctor_name)
WHERE sr.patient_id IS NULL
   OR sr.doctor_id IS NULL
   OR sr.patient_name IS NULL
   OR sr.patient_name = ''
   OR sr.doctor_name IS NULL
   OR sr.doctor_name = '';
