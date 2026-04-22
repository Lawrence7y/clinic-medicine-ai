USE WechatProject;

SET @minimax_model_id = (
  SELECT model_id
  FROM clinic_ai_model
  WHERE enabled = 1
    AND model_code = 'MiniMax-M2.7'
  ORDER BY model_id ASC
  LIMIT 1
);

SET @openai_model_id = (
  SELECT model_id
  FROM clinic_ai_model
  WHERE enabled = 1
    AND model_code = 'gpt-5.4'
  ORDER BY model_id ASC
  LIMIT 1
);

UPDATE clinic_ai_scene_binding
SET primary_model_id = @minimax_model_id,
    fallback_model_id = @openai_model_id,
    update_by = 'admin',
    update_time = NOW()
WHERE @minimax_model_id IS NOT NULL;
