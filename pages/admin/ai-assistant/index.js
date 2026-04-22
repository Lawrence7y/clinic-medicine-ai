const { getCurrentUser } = require('../../../services/auth/index');
const {
  USER_ROLES,
  getStoredConfig,
  subscribeSystemConfig,
  syncSystemConfig
} = require('../../../services/config/index');
const {
  AI_ROUTES,
  getRecentAiFeatures,
  pushRecentAiFeature,
  resolveAiAssistantName
} = require('../../../services/ai/index');

const FEATURE_ROUTES = {
  chat: { name: 'AI 助手', path: AI_ROUTES.CHAT },
  operations: { name: 'AI 运营助手', path: AI_ROUTES.OPERATIONS_ASSISTANT },
  logs: { name: '调用日志', path: AI_ROUTES.AI_LOGS },
  prompts: { name: '提示词管理', path: AI_ROUTES.AI_PROMPTS },
  sceneTest: { name: '场景测试', path: AI_ROUTES.AI_SCENE_TEST },
  modelDoc: { name: '模型说明', path: AI_ROUTES.AI_MODEL_DOC }
};

Page({
  data: {
    uiState: 'loading',
    errorMessage: '',
    recentAiFeatures: [],
    systemConfig: {},
    assistantName: 'AI 助手',
    texts: {
      loading: '加载中...',
      retry: '重试',
      loadFailed: '加载失败',
      noRecent: '暂无最近使用记录',
      noPermission: '暂无权限访问'
    }
  },

  onLoad() {
    this.applySystemConfig(getStoredConfig());
    this.subscribeConfigUpdates();
    this.syncSystemConfig();
    this.initPage();
  },

  onShow() {
    this.setData({ recentAiFeatures: getRecentAiFeatures() });
  },

  onUnload() {
    if (typeof this._unsubscribeConfig === 'function') {
      this._unsubscribeConfig();
      this._unsubscribeConfig = null;
    }
  },

  subscribeConfigUpdates() {
    if (typeof this._unsubscribeConfig === 'function') return;
    this._unsubscribeConfig = subscribeSystemConfig((config) => {
      this.applySystemConfig(config || getStoredConfig());
    });
  },

  applySystemConfig(config = {}) {
    this.setData({
      systemConfig: config || {},
      assistantName: resolveAiAssistantName(config, 'AI 助手')
    });
  },

  async syncSystemConfig() {
    try {
      const res = await syncSystemConfig({ silent: true });
      this.applySystemConfig((res && res.data) || getStoredConfig());
    } catch (error) {
      this.applySystemConfig(getStoredConfig());
    }
  },

  initPage() {
    const userInfo = getCurrentUser();
    if (!userInfo) {
      wx.redirectTo({ url: '/pages/login/index' });
      return;
    }
    const isAdmin = userInfo.role === USER_ROLES.SUPER_ADMIN || userInfo.role === USER_ROLES.CLINIC_ADMIN;
    const isDoctor = userInfo.role === USER_ROLES.DOCTOR;
    if (!isAdmin && !isDoctor) {
      this.setData({
        uiState: 'error',
        errorMessage: this.data.texts.noPermission
      });
      return;
    }
    this.setData({
      uiState: 'ready',
      errorMessage: '',
      recentAiFeatures: getRecentAiFeatures()
    });
  },

  retryInit() {
    this.setData({ uiState: 'loading', errorMessage: '' });
    this.initPage();
  },

  openFeature(feature) {
    if (!feature || !feature.path) return;
    const recent = pushRecentAiFeature(feature.name, feature.path);
    this.setData({ recentAiFeatures: recent });
    wx.navigateTo({ url: feature.path });
  },

  openRecentAi(e) {
    const path = e.currentTarget.dataset.path;
    const name = e.currentTarget.dataset.name;
    if (!path) return;
    this.openFeature({ name, path });
  },

  goToAiChat() {
    this.openFeature({
      ...FEATURE_ROUTES.chat,
      name: this.data.assistantName || FEATURE_ROUTES.chat.name
    });
  },

  goToAiLogs() {
    this.openFeature(FEATURE_ROUTES.logs);
  },

  goToAiOperations() {
    this.openFeature(FEATURE_ROUTES.operations);
  },

  goToAiPrompts() {
    this.openFeature(FEATURE_ROUTES.prompts);
  },

  goToAiSceneTest() {
    this.openFeature(FEATURE_ROUTES.sceneTest);
  },

  goToAiModelDoc() {
    this.openFeature(FEATURE_ROUTES.modelDoc);
  }
});
