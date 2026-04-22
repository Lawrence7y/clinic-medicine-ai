const { get, post } = require('../_utils/request');

const RECENT_AI_KEY = 'recent_ai_features';
const AI_REQUEST_TIMEOUT = 60000;
const DEFAULT_AI_NAME = 'AI 助手';

const AI_ROUTES = Object.freeze({
  CHAT: '/pages/ai/chat/index',
  MEDICAL_ASSISTANT: '/pages/ai/medical-assistant/index',
  MEDICINE_ASSISTANT: '/pages/ai/medicine-assistant/index',
  OPERATIONS_ASSISTANT: '/pages/admin/ai-operations/index',
  AI_LOGS: '/pages/admin/ai-logs/index',
  AI_PROMPTS: '/pages/admin/ai-prompts/index',
  AI_SCENE_TEST: '/pages/admin/ai-scene-test/index',
  AI_MODEL_DOC: '/pages/admin/ai-model-doc/index',
  RECOGNITION_HISTORY: '/pages/medicine/recognition-history/index'
});

const sendChatMessage = (message, conversationId = '') => post(
  '/api/clinic/ai/chat/send',
  {
    message,
    conversationId
  },
  { timeout: AI_REQUEST_TIMEOUT }
);

const getAiLogs = (params = {}) => get('/api/clinic/ai/chat/logs', params);
const getChatHistory = (conversationId) => get('/api/clinic/ai/chat/history', { conversationId });
const getChatConversations = (limit = 20) => get('/api/clinic/ai/chat/conversations', { limit });
const getChatTemplates = () => get('/api/clinic/ai/chat/templates');
const getChatCapability = () => get('/api/clinic/ai/chat/capability');
const clearChatConversation = (conversationId) => post('/api/clinic/ai/chat/clear', { conversationId });
const getMedicalAssistantSuggestion = (payload = {}) => post(
  '/api/clinic/ai/assistant/medical-record',
  payload,
  { timeout: AI_REQUEST_TIMEOUT }
);
const getMedicineAssistantSuggestion = (payload = {}) => post(
  '/api/clinic/ai/assistant/medicine',
  payload,
  { timeout: AI_REQUEST_TIMEOUT }
);
const getOperationsAssistantSuggestion = (payload = {}) => post(
  '/api/clinic/ai/assistant/operations',
  payload,
  { timeout: AI_REQUEST_TIMEOUT }
);

const resolveAiAssistantName = (config = {}, fallback = DEFAULT_AI_NAME) => {
  const preferred = String((config && config.aiAssistantName) || '').trim();
  return preferred || String(fallback || DEFAULT_AI_NAME).trim() || DEFAULT_AI_NAME;
};

const buildAiChatPath = (context = '') => {
  const safeContext = String(context || '').trim();
  if (!safeContext) return AI_ROUTES.CHAT;
  return `${AI_ROUTES.CHAT}?context=${encodeURIComponent(safeContext)}`;
};

const buildMedicineConsultContext = (medicineName, medicineId = '') => {
  const safeName = String(medicineName || '').trim() || '药品';
  const safeId = String(medicineId || '').trim();
  return safeId
    ? `药品咨询：${safeName}（药品ID：${safeId}）`
    : `药品咨询：${safeName}`;
};

const normalizeRecentPathKey = (path = '') => {
  const raw = String(path || '').trim();
  if (!raw) return '';
  const noHash = raw.split('#')[0];
  const basePath = noHash.split('?')[0];
  const normalized = basePath.replace(/\/+$/, '');
  return normalized || '/';
};

const normalizeRecentList = (list = [], limit = 5) => {
  if (!Array.isArray(list)) return [];
  const size = Number.isFinite(Number(limit)) ? Math.max(1, Number(limit)) : 5;
  const dedupMap = new Map();
  const result = [];
  for (let i = 0; i < list.length; i += 1) {
    const item = list[i] || {};
    const path = String(item.path || '').trim();
    const key = normalizeRecentPathKey(path);
    if (!key || dedupMap.has(key)) continue;
    dedupMap.set(key, true);
    result.push({
      name: String(item.name || '').trim() || 'AI 功能',
      path,
      ts: Number(item.ts || Date.now())
    });
    if (result.length >= size) break;
  }
  return result;
};

const getRecentAiFeatures = (limit = 5) => {
  const size = Number.isFinite(Number(limit)) ? Math.max(1, Number(limit)) : 5;
  try {
    const list = wx.getStorageSync(RECENT_AI_KEY);
    return normalizeRecentList(list, size);
  } catch (error) {
    return [];
  }
};

const pushRecentAiFeature = (name, path, limit = 5) => {
  const safePath = String(path || '').trim();
  const safeKey = normalizeRecentPathKey(safePath);
  if (!safePath || !safeKey) return getRecentAiFeatures(limit);

  const safeName = String(name || '').trim() || 'AI 功能';
  const size = Number.isFinite(Number(limit)) ? Math.max(1, Number(limit)) : 5;
  const current = getRecentAiFeatures(size);
  const merged = [
    { name: safeName, path: safePath, ts: Date.now() },
    ...current.filter((item) => normalizeRecentPathKey(item.path) !== safeKey)
  ].slice(0, size);

  try {
    wx.setStorageSync(RECENT_AI_KEY, merged);
  } catch (error) {
    // keep non-blocking when storage fails
  }
  return merged;
};

module.exports = {
  sendChatMessage,
  getAiLogs,
  getChatHistory,
  getChatConversations,
  getChatTemplates,
  getChatCapability,
  clearChatConversation,
  getMedicalAssistantSuggestion,
  getMedicineAssistantSuggestion,
  getOperationsAssistantSuggestion,
  getRecentAiFeatures,
  pushRecentAiFeature,
  AI_ROUTES,
  DEFAULT_AI_NAME,
  resolveAiAssistantName,
  buildAiChatPath,
  buildMedicineConsultContext
};
