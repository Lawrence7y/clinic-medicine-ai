USE WechatProject;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI 服务商配置';

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI 模型配置';

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

INSERT INTO clinic_ai_provider (
  provider_code, provider_name, api_base_url, api_key, enabled, remark, create_by, create_time, update_by, update_time
)
SELECT 'openai', 'OpenAI 兼容服务', '', '', 0, '请先配置 apiBaseUrl 与 apiKey，再启用服务商。', 'system', NOW(), 'system', NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM clinic_ai_provider WHERE provider_code = 'openai');

INSERT INTO clinic_ai_provider (
  provider_code, provider_name, api_base_url, api_key, enabled, remark, create_by, create_time, update_by, update_time
)
SELECT 'minimax', 'MiniMax', '', '', 0, '请先配置 apiBaseUrl 与 apiKey，再启用服务商。', 'system', NOW(), 'system', NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM clinic_ai_provider WHERE provider_code = 'minimax');

INSERT INTO clinic_ai_model (
  provider_id, model_code, model_name, supports_vision, supports_web_search, supports_json_schema,
  enabled, remark, create_by, create_time, update_by, update_time
)
SELECT p.provider_id, 'gpt-5.4', 'gpt-5.4', 1, 1, 1, 0, '默认初始化模型。', 'system', NOW(), 'system', NOW()
FROM clinic_ai_provider p
WHERE p.provider_code = 'openai'
  AND NOT EXISTS (SELECT 1 FROM clinic_ai_model m WHERE m.provider_id = p.provider_id AND m.model_code = 'gpt-5.4');

INSERT INTO clinic_ai_model (
  provider_id, model_code, model_name, supports_vision, supports_web_search, supports_json_schema,
  enabled, remark, create_by, create_time, update_by, update_time
)
SELECT p.provider_id, 'minimax-M2.7', 'minimax-M2.7', 1, 1, 1, 0, '默认初始化模型。', 'system', NOW(), 'system', NOW()
FROM clinic_ai_provider p
WHERE p.provider_code = 'minimax'
  AND NOT EXISTS (SELECT 1 FROM clinic_ai_model m WHERE m.provider_id = p.provider_id AND m.model_code = 'minimax-M2.7');

INSERT INTO clinic_ai_scene_binding (
  scene_code, scene_name, execution_mode, primary_model_id, fallback_model_id,
  candidate_limit, timeout_ms, enabled, remark, create_by, create_time, update_by, update_time
)
SELECT 'medicine_create_code', '药品新建-扫码识别', 'local_then_model', pm.model_id, fm.model_id,
       3, 15000, 1, '默认药品新建扫码识别场景。', 'system', NOW(), 'system', NOW()
FROM (SELECT 1) seed
LEFT JOIN clinic_ai_model pm ON pm.model_code = 'gpt-5.4'
LEFT JOIN clinic_ai_model fm ON fm.model_code = 'minimax-M2.7'
WHERE NOT EXISTS (SELECT 1 FROM clinic_ai_scene_binding WHERE scene_code = 'medicine_create_code');

INSERT INTO clinic_ai_scene_binding (
  scene_code, scene_name, execution_mode, primary_model_id, fallback_model_id,
  candidate_limit, timeout_ms, enabled, remark, create_by, create_time, update_by, update_time
)
SELECT 'medicine_create_image', '药品新建-拍照识别', 'model_only', pm.model_id, fm.model_id,
       3, 90000, 1, '默认药品新建拍照识别场景。', 'system', NOW(), 'system', NOW()
FROM (SELECT 1) seed
LEFT JOIN clinic_ai_model pm ON pm.model_code = 'gpt-5.4'
LEFT JOIN clinic_ai_model fm ON fm.model_code = 'minimax-M2.7'
WHERE NOT EXISTS (SELECT 1 FROM clinic_ai_scene_binding WHERE scene_code = 'medicine_create_image');

INSERT INTO clinic_ai_scene_binding (
  scene_code, scene_name, execution_mode, primary_model_id, fallback_model_id,
  candidate_limit, timeout_ms, enabled, remark, create_by, create_time, update_by, update_time
)
SELECT 'medicine_stock_in_code', '药品入库-扫码识别', 'local_only', NULL, NULL,
       3, 15000, 1, '默认药品入库扫码识别场景。', 'system', NOW(), 'system', NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM clinic_ai_scene_binding WHERE scene_code = 'medicine_stock_in_code');

INSERT INTO clinic_ai_scene_binding (
  scene_code, scene_name, execution_mode, primary_model_id, fallback_model_id,
  candidate_limit, timeout_ms, enabled, remark, create_by, create_time, update_by, update_time
)
SELECT 'medicine_stock_out_code', '药品出库-扫码识别', 'local_only', NULL, NULL,
       3, 15000, 1, '默认药品出库扫码识别场景。', 'system', NOW(), 'system', NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM clinic_ai_scene_binding WHERE scene_code = 'medicine_stock_out_code');

INSERT INTO clinic_ai_scene_binding (
  scene_code, scene_name, execution_mode, primary_model_id, fallback_model_id,
  candidate_limit, timeout_ms, enabled, remark, create_by, create_time, update_by, update_time
)
SELECT 'medicine_create_ocr', '药品说明书 OCR 识别', 'model_only', pm.model_id, fm.model_id,
       3, 90000, 1, '默认药品说明书 OCR 识别场景。', 'system', NOW(), 'system', NOW()
FROM (SELECT 1) seed
LEFT JOIN clinic_ai_model pm ON pm.model_code = 'gpt-5.4'
LEFT JOIN clinic_ai_model fm ON fm.model_code = 'minimax-M2.7'
WHERE NOT EXISTS (SELECT 1 FROM clinic_ai_scene_binding WHERE scene_code = 'medicine_create_ocr');

INSERT INTO clinic_ai_scene_binding (
  scene_code, scene_name, execution_mode, primary_model_id, fallback_model_id,
  candidate_limit, timeout_ms, enabled, remark, create_by, create_time, update_by, update_time
)
SELECT 'medicine_create_package', '药品包装图识别', 'model_only', pm.model_id, fm.model_id,
       3, 90000, 1, '默认药品包装图识别场景。', 'system', NOW(), 'system', NOW()
FROM (SELECT 1) seed
LEFT JOIN clinic_ai_model pm ON pm.model_code = 'gpt-5.4'
LEFT JOIN clinic_ai_model fm ON fm.model_code = 'minimax-M2.7'
WHERE NOT EXISTS (SELECT 1 FROM clinic_ai_scene_binding WHERE scene_code = 'medicine_create_package');

INSERT INTO clinic_ai_scene_binding (
  scene_code, scene_name, execution_mode, primary_model_id, fallback_model_id,
  candidate_limit, timeout_ms, enabled, remark, create_by, create_time, update_by, update_time
)
SELECT 'medicine_create_multi_image', '药品多图识别', 'model_only', pm.model_id, fm.model_id,
       3, 90000, 1, '默认药品多图识别场景。', 'system', NOW(), 'system', NOW()
FROM (SELECT 1) seed
LEFT JOIN clinic_ai_model pm ON pm.model_code = 'gpt-5.4'
LEFT JOIN clinic_ai_model fm ON fm.model_code = 'minimax-M2.7'
WHERE NOT EXISTS (SELECT 1 FROM clinic_ai_scene_binding WHERE scene_code = 'medicine_create_multi_image');

INSERT INTO clinic_ai_scene_binding (
  scene_code, scene_name, execution_mode, primary_model_id, fallback_model_id,
  candidate_limit, timeout_ms, enabled, remark, create_by, create_time, update_by, update_time
)
SELECT 'medicine_create_voice_text', '药品语音转写识别', 'model_only', pm.model_id, fm.model_id,
       3, 30000, 1, '默认药品语音转写识别场景。', 'system', NOW(), 'system', NOW()
FROM (SELECT 1) seed
LEFT JOIN clinic_ai_model pm ON pm.model_code = 'gpt-5.4'
LEFT JOIN clinic_ai_model fm ON fm.model_code = 'minimax-M2.7'
WHERE NOT EXISTS (SELECT 1 FROM clinic_ai_scene_binding WHERE scene_code = 'medicine_create_voice_text');

INSERT INTO clinic_ai_scene_binding (
  scene_code, scene_name, execution_mode, primary_model_id, fallback_model_id,
  candidate_limit, timeout_ms, enabled, remark, create_by, create_time, update_by, update_time
)
SELECT 'clinic_ai_chat', 'AI 助手对话', 'model_only', pm.model_id, fm.model_id,
       3, 30000, 1, '默认 AI 助手对话场景。', 'system', NOW(), 'system', NOW()
FROM (SELECT 1) seed
LEFT JOIN clinic_ai_model pm ON pm.model_code = 'gpt-5.4'
LEFT JOIN clinic_ai_model fm ON fm.model_code = 'minimax-M2.7'
WHERE NOT EXISTS (SELECT 1 FROM clinic_ai_scene_binding WHERE scene_code = 'clinic_ai_chat');

INSERT INTO clinic_ai_scene_binding (
  scene_code, scene_name, execution_mode, primary_model_id, fallback_model_id,
  candidate_limit, timeout_ms, enabled, remark, create_by, create_time, update_by, update_time
)
SELECT 'clinic_ai_medical_assistant', 'AI 病历助手', 'model_only', pm.model_id, fm.model_id,
       3, 30000, 1, '默认 AI 病历助手场景。', 'system', NOW(), 'system', NOW()
FROM (SELECT 1) seed
LEFT JOIN clinic_ai_model pm ON pm.model_code = 'gpt-5.4'
LEFT JOIN clinic_ai_model fm ON fm.model_code = 'minimax-M2.7'
WHERE NOT EXISTS (SELECT 1 FROM clinic_ai_scene_binding WHERE scene_code = 'clinic_ai_medical_assistant');

INSERT INTO clinic_ai_scene_binding (
  scene_code, scene_name, execution_mode, primary_model_id, fallback_model_id,
  candidate_limit, timeout_ms, enabled, remark, create_by, create_time, update_by, update_time
)
SELECT 'clinic_ai_medicine_assistant', 'AI 药品助手', 'model_only', pm.model_id, fm.model_id,
       3, 30000, 1, '默认 AI 药品助手场景。', 'system', NOW(), 'system', NOW()
FROM (SELECT 1) seed
LEFT JOIN clinic_ai_model pm ON pm.model_code = 'gpt-5.4'
LEFT JOIN clinic_ai_model fm ON fm.model_code = 'minimax-M2.7'
WHERE NOT EXISTS (SELECT 1 FROM clinic_ai_scene_binding WHERE scene_code = 'clinic_ai_medicine_assistant');

INSERT INTO clinic_ai_scene_binding (
  scene_code, scene_name, execution_mode, primary_model_id, fallback_model_id,
  candidate_limit, timeout_ms, enabled, remark, create_by, create_time, update_by, update_time
)
SELECT 'clinic_ai_operations_assistant', 'AI 运营助手', 'model_only', pm.model_id, fm.model_id,
       3, 30000, 1, '默认 AI 运营助手场景。', 'system', NOW(), 'system', NOW()
FROM (SELECT 1) seed
LEFT JOIN clinic_ai_model pm ON pm.model_code = 'gpt-5.4'
LEFT JOIN clinic_ai_model fm ON fm.model_code = 'minimax-M2.7'
WHERE NOT EXISTS (SELECT 1 FROM clinic_ai_scene_binding WHERE scene_code = 'clinic_ai_operations_assistant');
