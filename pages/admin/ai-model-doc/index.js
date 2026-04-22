const Toast = require('tdesign-miniprogram/toast/index').default;
const { getAiConfig, saveAiConfig, getAiModels } = require('../../../services/ai-config/index');

Page({
  data: {
    uiState: 'loading',
    errorText: '',
    loading: false,
    saving: false,
    doc: '',
    models: [],
    texts: {
      loading: '加载中...',
      loadFailed: '加载失败',
      retry: '重试'
    }
  },

  onLoad() {
    this.loadData();
  },

  async loadData() {
    this.setData({ loading: true, uiState: 'loading', errorText: '' });
    try {
      const [cfgRes, modelRes] = await Promise.all([getAiConfig(), getAiModels()]);
      this.setData({
        doc: cfgRes?.data?.aiModelDescriptionDoc || '',
        models: modelRes?.data || [],
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
    this.loadData();
  },

  onDocInput(e) {
    this.setData({ doc: e.detail.value });
  },

  async onSaveDoc() {
    this.setData({ saving: true });
    try {
      await saveAiConfig({ aiModelDescriptionDoc: this.data.doc });
      Toast({ context: this, selector: '#t-toast', message: '保存成功', theme: 'success' });
    } catch (error) {
      Toast({ context: this, selector: '#t-toast', message: error.message || '保存失败' });
    } finally {
      this.setData({ saving: false });
    }
  }
});
