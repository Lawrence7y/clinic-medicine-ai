USE WechatProject;

UPDATE clinic_ai_model
SET supports_vision = 1,
    update_by = 'admin',
    update_time = NOW()
WHERE model_code = 'MiniMax-M2.7';

UPDATE clinic_ai_scene_binding
SET timeout_ms = CASE
        WHEN scene_code = 'medicine_create_image' THEN 60000
        ELSE GREATEST(IFNULL(timeout_ms, 0), 30000)
    END,
    update_by = 'admin',
    update_time = NOW()
WHERE scene_code IN (
    'medicine_create_code',
    'medicine_create_image',
    'medicine_stock_in_code',
    'medicine_stock_out_code'
);
