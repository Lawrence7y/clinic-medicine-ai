const { getConfig, updateConfig } = require('../config/index');
const { sendChatMessage } = require('../ai/index');
const { get } = require('../_utils/request');

const getAiConfig = async () => {
  const res = await getConfig();
  const cfg = res?.data || {};
  return {
    success: true,
    data: {
      aiPromptTemplateGeneral: cfg.aiPromptTemplateGeneral || '',
      aiPromptTemplateBusiness: cfg.aiPromptTemplateBusiness || '',
      aiModelDescriptionDoc: cfg.aiModelDescriptionDoc || ''
    }
  };
};

const saveAiConfig = (payload = {}) => updateConfig(payload);

const getAiModels = () => get('/api/clinic/ai/config/models').then((res) => {
  const rows = res?.data || [];
  return {
    success: true,
    data: rows.map((m) => ({
      modelId: m.modelId || m.model_id,
      modelCode: m.modelCode || m.model_code,
      modelName: m.modelName || m.model_name,
      providerName: m.providerName || m.provider_name,
      supportsVision: Number(m.supportsVision || m.supports_vision || 0) === 1,
      supportsWebSearch: Number(m.supportsWebSearch || m.supports_web_search || 0) === 1,
      enabled: Number(m.enabled || 0) === 1
    }))
  };
});

const getAiScenes = () => get('/api/clinic/ai/config/scenes').then((res) => {
  const rows = res?.data || [];
  return {
    success: true,
    data: rows.map((s) => ({
      sceneId: s.sceneId || s.scene_id,
      sceneCode: s.sceneCode || s.scene_code,
      sceneName: s.sceneName || s.scene_name,
      executionMode: s.executionMode || s.execution_mode,
      primaryModelName: s.primaryModelName || s.primary_model_name,
      fallbackModelName: s.fallbackModelName || s.fallback_model_name,
      enabled: Number(s.enabled || 0) === 1
    }))
  };
});

const testAiScene = async ({ sceneCode, prompt, question }) => {
  const composed = `[scene:${sceneCode || 'clinic_ai_chat'}]\n[prompt]\n${prompt || ''}\n[user]\n${question || ''}`;
  const res = await sendChatMessage(composed);
  return {
    success: true,
    data: res?.data || {}
  };
};

module.exports = {
  getAiConfig,
  saveAiConfig,
  getAiModels,
  getAiScenes,
  testAiScene
};
