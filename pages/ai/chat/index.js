const Toast = require('tdesign-miniprogram/toast/index').default;
const {
  USER_ROLES,
  syncSystemConfig: syncGlobalSystemConfig,
  getStoredConfig,
  subscribeSystemConfig
} = require('../../../services/config/index');
const { getCurrentUser } = require('../../../services/auth/index');
const {
  resolveAiAssistantName,
  sendChatMessage,
  getChatHistory,
  getChatConversations,
  getChatTemplates,
  getChatCapability,
  clearChatConversation,
  getAiLogs
} = require('../../../services/ai/index');

const PATIENT_BLOCKED_KEYWORDS = [
  '库存',
  '入库',
  '出库',
  '过期',
  '药品预警',
  '报表',
  '统计',
  '营收',
  'ai调用日志',
  '模型配置',
  '排班管理',
  '医生待办',
  '诊所运营',
  'admin',
  '管理员',
  'inventory',
  'stock in',
  'stock out',
  'expiry',
  'report',
  'revenue',
  'model config',
  'doctor todo',
  'operation dashboard'
];

const fallbackQuickActions = (role) => {
  if (role === USER_ROLES.PATIENT) {
    return [
      '如何预约医生？',
      '取药流程是什么？',
      '复诊前需要准备什么？'
    ];
  }
  return [
    '总结今天的预约情况',
    '当前有哪些库存风险？',
    '列出当前待处理事项'
  ];
};

const isLikelyBusinessQuestion = (message = '') => {
  const content = String(message || '').trim().toLowerCase();
  if (!content) return false;
  return PATIENT_BLOCKED_KEYWORDS.some((keyword) => content.includes(String(keyword).toLowerCase()));
};

const buildWelcomeText = (role, assistantName) => {
  const safeName = assistantName || 'AI 助手';
  if (role === USER_ROLES.PATIENT) {
    return `${safeName}可以为你提供就诊咨询和流程问答。`;
  }
  return `${safeName}可以提供就诊咨询、流程问答和业务辅助。`;
};

Page({
  data: {
    uiState: 'loading',
    errorText: '',
    inputValue: '',
    loading: false,
    conversationId: '',
    messages: [],
    quickActions: [],
    context: '',
    conversations: [],
    userRole: '',
    welcomeText: '',
    roleHint: '',
    canBusinessQa: false,
    showLogPanel: false,
    aiLogs: [],
    aiLogErrorText: '',
    systemConfig: {},
    assistantName: 'AI 助手',
    assistantStatus: {},
    assistantStatusItems: [],
    assistantEnabled: true,
    texts: {
      loading: '正在加载 AI 助手...',
      initFailed: '聊天初始化失败',
      retry: '重试',
      refreshConfig: '刷新配置',
      newConversation: '新建会话',
      clearCurrent: '清空当前会话',
      roleBoundary: '角色边界',
      quickAsk: '快捷提问',
      aiLogTitle: 'AI 调用日志',
      noLogs: '暂无调用日志',
      logLoadFailed: '调用日志加载失败，请稍后重试。',
      success: '成功',
      failed: '失败',
      sceneLabel: '场景：',
      modelLabel: '模型：',
      elapsedLabel: '耗时：',
      failureReasonLabel: '失败原因：',
      chatPlaceholder: '请输入问题',
      send: '发送',
      noBusinessPermission: '患者角色仅支持咨询与流程问答',
      loadHistoryFailed: '加载会话失败',
      clearSuccess: '当前会话已清空',
      clearFailed: '清空会话失败',
      assistantUnavailable: 'AI 助手当前不可用',
      assistantStatusTitle: '助手状态',
      assistantReady: '已就绪',
      assistantStatusOk: '正常',
      assistantStatusFailed: '未通过',
      assistantDisabled: 'AI 助手已关闭，请联系管理员在系统配置中开启。',
      emptyReply: 'AI 暂无响应，请稍后重试',
      newConversationTitle: '新会话',
      noConversation: '暂无历史会话'
    }
  },

  onLoad(options = {}) {
    this._configSyncWarned = false;
    const userInfo = getCurrentUser();
    if (!userInfo) {
      wx.redirectTo({ url: '/pages/login/index' });
      return;
    }

    const storedConfig = getStoredConfig();
    const assistantName = resolveAiAssistantName(storedConfig);
    const context = options.context ? decodeURIComponent(options.context) : '';
    const isPatient = userInfo.role === USER_ROLES.PATIENT;
    const welcomeText = buildWelcomeText(userInfo.role, assistantName);
    const roleHint = isPatient
      ? '患者角色仅支持咨询与流程问答。'
      : '医生/管理员支持咨询与业务问答。';

    this.setData({
      uiState: 'loading',
      errorText: '',
      userRole: userInfo.role,
      context,
      assistantName,
      welcomeText,
      roleHint,
      canBusinessQa: !isPatient,
      showLogPanel: !isPatient,
      messages: [{ role: 'assistant', content: welcomeText }]
    });

    this.subscribeConfigUpdates();
    this.applySystemConfig(storedConfig);
    this.initChatData();
    this.syncSystemConfig();
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
      this.applySystemConfig(config || {});
    });
  },

  applySystemConfig(config = {}) {
    const assistantEnabled = config.aiAssistantEnabled !== false;
    const assistantName = resolveAiAssistantName(config);
    const welcomeText = buildWelcomeText(this.data.userRole, assistantName);
    const nextData = {
      systemConfig: config || {},
      assistantEnabled,
      assistantName,
      welcomeText
    };
    if (Array.isArray(this.data.messages) && this.data.messages.length === 1 && this.data.messages[0].role === 'assistant') {
      nextData.messages = [{ role: 'assistant', content: welcomeText }];
    }
    this.setData({
      ...nextData
    });
    if (!assistantEnabled) {
      this.setData({
        assistantStatus: {
          available: false,
          code: 'assistant_disabled',
          message: this.data.texts.assistantDisabled
        },
        assistantStatusItems: [
          { key: 'assistantEnabled', label: '助手开关', ok: false, message: this.data.texts.assistantDisabled }
        ],
        uiState: 'error',
        errorText: this.data.texts.assistantDisabled
      });
    } else if (this.data.assistantStatus?.code === 'assistant_disabled') {
      this.setData({
        assistantStatus: {},
        assistantStatusItems: []
      });
    }
  },

  async syncSystemConfig() {
    try {
      const res = await syncGlobalSystemConfig({ silent: true });
      this.applySystemConfig((res && res.data) || getStoredConfig());
      if (res && res.error && !this._configSyncWarned) {
        this._configSyncWarned = true;
        Toast({
          context: this,
          selector: '#t-toast',
          message: '配置同步失败，已使用本地配置'
        });
      }
    } catch (error) {
      this.applySystemConfig(getStoredConfig());
      if (!this._configSyncWarned) {
        this._configSyncWarned = true;
        Toast({
          context: this,
          selector: '#t-toast',
          message: '配置同步失败，已使用本地配置'
        });
      }
    }
  },

  async initChatData() {
    if (!this.data.assistantEnabled) {
      this.setData({
        uiState: 'error',
        errorText: this.data.texts.assistantDisabled
      });
      return;
    }

    try {
      const [templateRes, conversationRes, capabilityRes] = await Promise.all([
        getChatTemplates(),
        getChatConversations(20),
        getChatCapability()
      ]);

      const templates =
        Array.isArray(templateRes?.data) && templateRes.data.length
          ? templateRes.data
          : fallbackQuickActions(this.data.userRole);
      const conversations = Array.isArray(conversationRes?.data) ? conversationRes.data : [];
      const capability = capabilityRes && capabilityRes.data ? capabilityRes.data : {};
      const assistantName = capability.assistantName || this.data.assistantName || resolveAiAssistantName(this.data.systemConfig);
      const assistantStatus = capability.assistantStatus && typeof capability.assistantStatus === 'object'
        ? capability.assistantStatus
        : {};
      const assistantStatusItems = Array.isArray(assistantStatus.items) ? assistantStatus.items : [];
      const welcomeText = buildWelcomeText(this.data.userRole, assistantName);
      const defaultCanBusinessQa = this.data.userRole !== USER_ROLES.PATIENT;
      const canBusinessQa = typeof capability.canBusinessQa === 'boolean'
        ? capability.canBusinessQa
        : defaultCanBusinessQa;
      const roleHint = capability.roleHint || this.data.roleHint;

      if (assistantStatus && assistantStatus.available === false) {
        const failedItems = assistantStatusItems
          .filter((item) => item && item.ok === false)
          .map((item) => `${item.label || '状态项'}：${item.message || '-'}`);
        const statusErrorText = [assistantStatus.message || this.data.texts.assistantUnavailable, ...failedItems]
          .filter(Boolean)
          .join('\n');
        this.setData({
          assistantName,
          assistantStatus,
          assistantStatusItems,
          welcomeText,
          messages: [{ role: 'assistant', content: welcomeText }],
          quickActions: templates,
          conversations,
          roleHint,
          canBusinessQa,
          showLogPanel: canBusinessQa,
          uiState: 'error',
          errorText: statusErrorText
        });
        return;
      }

      const nextData = {
        assistantName,
        assistantStatus,
        assistantStatusItems,
        welcomeText,
        quickActions: templates,
        conversations,
        roleHint,
        canBusinessQa,
        showLogPanel: canBusinessQa,
        uiState: 'ready',
        errorText: ''
      };
      if (!this.data.conversationId
        && Array.isArray(this.data.messages)
        && this.data.messages.length === 1
        && this.data.messages[0].role === 'assistant') {
        nextData.messages = [{ role: 'assistant', content: welcomeText }];
      }
      this.setData(nextData);

      if (conversations.length > 0 && conversations[0].conversationId) {
        await this.switchConversation(conversations[0].conversationId);
      }

      if (canBusinessQa) {
        this.loadAiLogs();
      }
    } catch (error) {
      this.setData({
        quickActions: fallbackQuickActions(this.data.userRole),
        uiState: 'error',
        errorText: error && error.message ? error.message : this.data.texts.initFailed
      });
    }
  },

  async retryInit() {
    this.setData({ uiState: 'loading', errorText: '' });
    await this.syncSystemConfig();
    this.initChatData();
  },

  async refreshConversations() {
    try {
      const conversationRes = await getChatConversations(20);
      const conversations = Array.isArray(conversationRes?.data) ? conversationRes.data : [];
      this.setData({ conversations });
    } catch (error) {
      // keep silent to avoid interrupting main flow
    }
  },

  async loadAiLogs() {
    try {
      const res = await getAiLogs({ limit: 8 });
      const rows = Array.isArray(res?.data) ? res.data : [];
      this.setData({
        aiLogErrorText: '',
        aiLogs: rows.map((item) => ({
          time: item.createdAt || item.time || '-',
          scene: item.sceneCode || item.scene || '-',
          model: item.modelName || item.model || '-',
          success: item.success === true || item.success === 1,
          reason: item.failureReason || item.reason || '',
          elapsedMs: Number(item.durationMs || item.elapsedMs || 0)
        }))
      });
    } catch (error) {
      this.setData({
        aiLogs: [],
        aiLogErrorText: this.data.texts.logLoadFailed
      });
    }
  },

  onInputChange(e) {
    this.setData({ inputValue: e.detail.value });
  },

  async switchConversation(conversationId) {
    if (!conversationId) return;

    try {
      const res = await getChatHistory(conversationId);
      const history = Array.isArray(res?.data) ? res.data : [];
      this.setData({
        conversationId,
        messages: history.length ? history : [{ role: 'assistant', content: this.data.welcomeText }]
      });
    } catch (error) {
      Toast({
        context: this,
        selector: '#t-toast',
        message: error.message || this.data.texts.loadHistoryFailed
      });
    }
  },

  selectConversation(e) {
    const { id } = e.currentTarget.dataset;
    this.switchConversation(id);
  },

  startNewConversation() {
    this.setData({
      conversationId: '',
      messages: [{ role: 'assistant', content: this.data.welcomeText }]
    });
  },

  async clearConversation() {
    if (!this.data.conversationId) {
      this.startNewConversation();
      return;
    }

    try {
      await clearChatConversation(this.data.conversationId);
      Toast({
        context: this,
        selector: '#t-toast',
        message: this.data.texts.clearSuccess,
        theme: 'success'
      });
      this.startNewConversation();
      await this.refreshConversations();
      if (this.data.showLogPanel) {
        this.loadAiLogs();
      }
    } catch (error) {
      Toast({
        context: this,
        selector: '#t-toast',
        message: error.message || this.data.texts.clearFailed
      });
    }
  },

  useQuickAction(e) {
    const { prompt = '' } = e.currentTarget.dataset;
    if (!prompt) return;
    this.setData({ inputValue: prompt });
    this.handleSend();
  },

  async handleSend() {
    if (!this.data.assistantEnabled || (this.data.assistantStatus && this.data.assistantStatus.available === false)) {
      Toast({
        context: this,
        selector: '#t-toast',
        message: this.data.assistantStatus?.message || this.data.texts.assistantDisabled
      });
      return;
    }

    const message = String(this.data.inputValue || '').trim();
    if (!message || this.data.loading) return;
    if (!this.data.canBusinessQa && isLikelyBusinessQuestion(message)) {
      Toast({
        context: this,
        selector: '#t-toast',
        message: this.data.texts.noBusinessPermission
      });
      return;
    }

    const nextMessages = [...this.data.messages, { role: 'user', content: message }];
    this.setData({
      loading: true,
      inputValue: '',
      messages: nextMessages
    });

    try {
      const prompt = this.data.context ? `${message}\n\n上下文：${this.data.context}` : message;
      const res = await sendChatMessage(prompt, this.data.conversationId);
      const payload = res?.data || {};
      this.setData({
        conversationId: payload.conversationId || this.data.conversationId,
        messages: [
          ...nextMessages,
          {
            role: 'assistant',
            content: payload.reply || this.data.texts.emptyReply
          }
        ]
      });
      await this.refreshConversations();
      if (this.data.showLogPanel) {
        this.loadAiLogs();
      }
    } catch (error) {
      Toast({
        context: this,
        selector: '#t-toast',
        message: error.message || this.data.texts.assistantUnavailable
      });
      this.setData({ messages: nextMessages });
    } finally {
      this.setData({ loading: false });
    }
  }
});
