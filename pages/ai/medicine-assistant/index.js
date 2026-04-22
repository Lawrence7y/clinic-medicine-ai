const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser } = require('../../../services/auth/index');
const {
  USER_ROLES,
  getStoredConfig,
  subscribeSystemConfig,
  syncSystemConfig
} = require('../../../services/config/index');
const { getMedicineDetail } = require('../../../services/medicine/index');
const {
  AI_ROUTES,
  buildAiChatPath,
  buildMedicineConsultContext,
  getMedicineAssistantSuggestion,
  pushRecentAiFeature,
  resolveAiAssistantName
} = require('../../../services/ai/index');

Page({
  data: {
    uiState: 'loading',
    errorText: '',
    medicineId: '',
    medicineInfo: null,
    generating: false,
    aiResult: {
      similarMedicines: [],
      precautions: [],
      riskTips: [],
      model: ''
    },
    systemConfig: {},
    assistantName: 'AI 助手',
    texts: {
      loading: '药品助手加载中...',
      loadFailed: '药品助手加载失败',
      retry: '重试',
      invalidMedicineId: '药品编号无效',
      noPermission: '仅医生或管理员可使用',
      assistantDisabled: 'AI 助手已关闭，请联系管理员在系统配置中开启。',
      generateFailed: 'AI 生成失败，请稍后重试',
      generate: '重新生成建议',
      useInChat: '继续问 AI 助手',
      copyAll: '复制全部',
      similarTitle: '相似药品推荐',
      precautionsTitle: '注意事项',
      riskTitle: '用药风险提示'
    }
  },

  onLoad(options = {}) {
    const medicineId = String(options.medicineId || '').trim();
    if (!medicineId) {
      Toast({ context: this, selector: '#t-toast', message: this.data.texts.invalidMedicineId });
      setTimeout(() => wx.navigateBack(), 800);
      return;
    }
    this.setData({ medicineId });
    this.applySystemConfig(getStoredConfig());
    this.subscribeConfigUpdates();
    this.syncSystemConfig();
    this.initPage();
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
    const assistantName = resolveAiAssistantName(config, 'AI 助手');
    this.setData({
      systemConfig: config || {},
      assistantName,
      'texts.useInChat': `继续问 ${assistantName}`
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

  async initPage() {
    this.setData({ uiState: 'loading', errorText: '' });
    const user = getCurrentUser();
    if (!user) {
      wx.redirectTo({ url: '/pages/login/index' });
      return;
    }
    const canUse = user.role === USER_ROLES.SUPER_ADMIN
      || user.role === USER_ROLES.CLINIC_ADMIN
      || user.role === USER_ROLES.DOCTOR;
    if (!canUse) {
      this.setData({ uiState: 'error', errorText: this.data.texts.noPermission });
      return;
    }
    if (this.data.systemConfig.aiAssistantEnabled === false) {
      this.setData({ uiState: 'error', errorText: this.data.texts.assistantDisabled });
      return;
    }

    try {
      const medicineRes = await getMedicineDetail(this.data.medicineId);
      const medicineInfo = (medicineRes && medicineRes.data) || null;
      this.setData({ medicineInfo });
      await this.generateSuggestion();
      this.setData({ uiState: 'ready' });
      pushRecentAiFeature(
        `${this.data.assistantName}·药品助手`,
        `${AI_ROUTES.MEDICINE_ASSISTANT}?medicineId=${this.data.medicineId}`
      );
    } catch (error) {
      this.setData({
        uiState: 'error',
        errorText: (error && error.message) || this.data.texts.loadFailed
      });
    }
  },

  async generateSuggestion() {
    if (this.data.generating) return;
    this.setData({ generating: true });
    try {
      const res = await getMedicineAssistantSuggestion({ medicineId: this.data.medicineId });
      const payload = (res && res.data) || {};
      this.setData({
        aiResult: {
          similarMedicines: Array.isArray(payload.similarMedicines) ? payload.similarMedicines : [],
          precautions: Array.isArray(payload.precautions) ? payload.precautions : [],
          riskTips: Array.isArray(payload.riskTips) ? payload.riskTips : [],
          model: payload.model || ''
        }
      });
    } catch (error) {
      Toast({
        context: this,
        selector: '#t-toast',
        message: (error && error.message) || this.data.texts.generateFailed
      });
    } finally {
      this.setData({ generating: false });
    }
  },

  retryLoad() {
    this.initPage();
  },

  copyAllSuggestion() {
    const result = this.data.aiResult || {};
    const text = [
      `${this.data.texts.similarTitle}：${(result.similarMedicines || []).join('；') || '-'}`,
      `${this.data.texts.precautionsTitle}：${(result.precautions || []).join('；') || '-'}`,
      `${this.data.texts.riskTitle}：${(result.riskTips || []).join('；') || '-'}`
    ].join('\n\n');
    wx.setClipboardData({
      data: text,
      success: () => Toast({ context: this, selector: '#t-toast', message: '已复制', theme: 'success' })
    });
  },

  continueInChat() {
    const medicineName = this.data.medicineInfo?.name || '该药品';
    const context = buildMedicineConsultContext(medicineName, this.data.medicineId);
    pushRecentAiFeature(this.data.assistantName, AI_ROUTES.CHAT);
    wx.navigateTo({
      url: buildAiChatPath(context)
    });
  }
});
