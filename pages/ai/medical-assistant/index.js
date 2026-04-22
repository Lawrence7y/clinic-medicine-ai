const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser } = require('../../../services/auth/index');
const {
  USER_ROLES,
  getStoredConfig,
  subscribeSystemConfig,
  syncSystemConfig
} = require('../../../services/config/index');
const { getMedicalRecordDetail } = require('../../../services/medical-record/index');
const {
  AI_ROUTES,
  buildAiChatPath,
  getMedicalAssistantSuggestion,
  pushRecentAiFeature,
  resolveAiAssistantName
} = require('../../../services/ai/index');

Page({
  data: {
    uiState: 'loading',
    errorText: '',
    recordId: '',
    recordInfo: null,
    generating: false,
    aiResult: {
      summary: '',
      followUpAdvice: '',
      patientEducation: '',
      model: ''
    },
    systemConfig: {},
    assistantName: 'AI 助手',
    texts: {
      loading: '病历助手加载中...',
      loadFailed: '病历助手加载失败',
      retry: '重试',
      invalidRecordId: '病历编号无效',
      noPermission: '仅医生或管理员可使用',
      assistantDisabled: 'AI 助手已关闭，请联系管理员在系统配置中开启。',
      generateFailed: 'AI 生成失败，请稍后重试',
      generate: '重新生成建议',
      useInChat: '继续问 AI 助手',
      copyAll: '复制全部',
      summaryTitle: '病历摘要',
      followUpTitle: '复诊建议',
      educationTitle: '患者宣教'
    }
  },

  onLoad(options = {}) {
    const recordId = String(options.recordId || '').trim();
    if (!recordId) {
      Toast({ context: this, selector: '#t-toast', message: this.data.texts.invalidRecordId });
      setTimeout(() => wx.navigateBack(), 800);
      return;
    }

    this.setData({ recordId });
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
      const recordRes = await getMedicalRecordDetail(this.data.recordId);
      const recordInfo = (recordRes && recordRes.data) || null;
      this.setData({ recordInfo });
      await this.generateSuggestion();
      this.setData({ uiState: 'ready' });
      pushRecentAiFeature(
        `${this.data.assistantName}·病历助手`,
        `${AI_ROUTES.MEDICAL_ASSISTANT}?recordId=${this.data.recordId}`
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
      const res = await getMedicalAssistantSuggestion({ recordId: this.data.recordId });
      const payload = (res && res.data) || {};
      this.setData({
        aiResult: {
          summary: payload.summary || '暂无病历摘要',
          followUpAdvice: payload.followUpAdvice || '暂无复诊建议',
          patientEducation: payload.patientEducation || '暂无患者宣教建议',
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
      `${this.data.texts.summaryTitle}：${result.summary || '-'}`,
      `${this.data.texts.followUpTitle}：${result.followUpAdvice || '-'}`,
      `${this.data.texts.educationTitle}：${result.patientEducation || '-'}`
    ].join('\n\n');
    wx.setClipboardData({
      data: text,
      success: () => Toast({ context: this, selector: '#t-toast', message: '已复制', theme: 'success' })
    });
  },

  continueInChat() {
    const patientName = this.data.recordInfo?.patientName || '该患者';
    const context = `病历辅助分析：${patientName}（病历ID：${this.data.recordId}）`;
    pushRecentAiFeature(this.data.assistantName, AI_ROUTES.CHAT);
    wx.navigateTo({
      url: buildAiChatPath(context)
    });
  }
});
