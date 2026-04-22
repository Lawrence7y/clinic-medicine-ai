const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser } = require('../../../services/auth/index');
const { USER_ROLES } = require('../../../services/config/index');
const { getOperationsAssistantSuggestion, pushRecentAiFeature } = require('../../../services/ai/index');

Page({
  data: {
    uiState: 'loading',
    errorText: '',
    question: '',
    loading: false,
    quickQuestions: [
      '今天预约情况怎么样？',
      '哪些药品近效期风险最高？',
      '库存异常有哪些，优先处理什么？'
    ],
    result: {
      answer: '',
      keyPoints: [],
      todo: [],
      model: ''
    },
    snapshot: null,
    texts: {
      loading: '运营助手加载中...',
      loadFailed: '运营助手加载失败',
      retry: '重试',
      noPermission: '仅医生或管理员可使用',
      placeholder: '输入运营问题，例如：今天预约情况怎么样？',
      askButton: '提问',
      answerTitle: 'AI 分析结论',
      keyPointsTitle: '关键观察',
      todoTitle: '建议待办',
      snapshotTitle: '实时数据快照'
    }
  },

  onLoad() {
    this.initPage();
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

    try {
      await this.askQuestion(this.data.quickQuestions[0]);
      this.setData({ uiState: 'ready' });
      pushRecentAiFeature('AI 运营助手', '/pages/admin/ai-operations/index');
    } catch (error) {
      this.setData({
        uiState: 'error',
        errorText: (error && error.message) || this.data.texts.loadFailed
      });
    }
  },

  onQuestionChange(e) {
    this.setData({ question: e.detail.value || '' });
  },

  useQuickQuestion(e) {
    const question = (e.currentTarget.dataset.question || '').trim();
    if (!question) return;
    this.askQuestion(question);
  },

  async submitQuestion() {
    const question = String(this.data.question || '').trim();
    if (!question) {
      Toast({ context: this, selector: '#t-toast', message: '请输入问题' });
      return;
    }
    this.askQuestion(question);
  },

  async askQuestion(question) {
    if (this.data.loading) return;
    this.setData({ loading: true, question });
    try {
      const res = await getOperationsAssistantSuggestion({ question });
      const payload = (res && res.data) || {};
      this.setData({
        result: {
          answer: payload.answer || '',
          keyPoints: Array.isArray(payload.keyPoints) ? payload.keyPoints : [],
          todo: Array.isArray(payload.todo) ? payload.todo : [],
          model: payload.model || ''
        },
        snapshot: payload.snapshot || null
      });
    } catch (error) {
      Toast({
        context: this,
        selector: '#t-toast',
        message: (error && error.message) || '提问失败'
      });
      throw error;
    } finally {
      this.setData({ loading: false });
    }
  },

  retryLoad() {
    this.initPage();
  }
});
