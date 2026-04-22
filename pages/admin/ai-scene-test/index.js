const Toast = require('tdesign-miniprogram/toast/index').default;
const { getAiScenes, getAiConfig, testAiScene } = require('../../../services/ai-config/index');

Page({
  data: {
    uiState: 'loading',
    errorText: '',
    loading: false,
    testing: false,
    scenes: [],
    sceneIndex: 0,
    form: {
      question: '',
      prompt: ''
    },
    result: {
      model: '',
      reply: ''
    },
    texts: {
      loading: '加载中...',
      loadFailed: '加载失败',
      retry: '重试'
    }
  },

  async onLoad() {
    await this.initData();
  },

  async initData() {
    this.setData({ loading: true, uiState: 'loading', errorText: '' });
    try {
      const [sceneRes, cfgRes] = await Promise.all([getAiScenes(), getAiConfig()]);
      const scenes = sceneRes?.data || [];
      const cfg = cfgRes?.data || {};
      this.setData({
        scenes,
        sceneIndex: 0,
        'form.prompt': cfg.aiPromptTemplateBusiness || cfg.aiPromptTemplateGeneral || '',
        uiState: 'ready',
        errorText: ''
      });
    } catch (error) {
      const message = error.message || this.data.texts.loadFailed;
      this.setData({
        uiState: 'error',
        errorText: message
      });
      Toast({ context: this, selector: '#t-toast', message });
    } finally {
      this.setData({ loading: false });
    }
  },

  onRetry() {
    this.initData();
  },

  onQuestionInput(e) {
    this.setData({ 'form.question': e.detail.value });
  },

  onPromptInput(e) {
    this.setData({ 'form.prompt': e.detail.value });
  },

  onSceneChange(e) {
    this.setData({ sceneIndex: Number(e.detail.value || 0) });
  },

  async onTest() {
    if (!this.data.form.question.trim()) {
      Toast({ context: this, selector: '#t-toast', message: '请输入测试问题' });
      return;
    }
    this.setData({ testing: true });
    try {
      const scene = this.data.scenes[this.data.sceneIndex] || {};
      const res = await testAiScene({
        sceneCode: scene.sceneCode,
        prompt: this.data.form.prompt,
        question: this.data.form.question
      });
      this.setData({
        result: {
          model: res?.data?.model || '',
          reply: res?.data?.reply || ''
        }
      });
    } catch (error) {
      Toast({ context: this, selector: '#t-toast', message: error.message || '测试失败' });
    } finally {
      this.setData({ testing: false });
    }
  }
});
