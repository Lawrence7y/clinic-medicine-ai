const Toast = require('tdesign-miniprogram/toast/index').default;

Page({
  data: {
    uiState: 'loading',
    errorText: '',
    recordId: '',
    items: [],
    parseError: false,
    texts: {
      title: '处方详情',
      recordId: '病历 ID：',
      parseFailedInline: '处方数据解析失败，已使用空列表。',
      loading: '正在加载处方数据...',
      loadFailed: '处方数据加载失败',
      retry: '重试',
      goBack: '返回上一页',
      empty: '暂无处方药品',
      medicine: '药品',
      dosage: '用法用量',
      frequency: '频次',
      days: '天数',
      openMedicine: '查看药品',
      parseFailed: '处方数据解析失败，请返回上一页后重试。',
      medicineIdMissing: '药品 ID 缺失'
    }
  },

  onLoad(options = {}) {
    this.routeOptions = options || {};
    this.initPage();
  },

  initPage() {
    const { texts } = this.data;
    this.setData({
      uiState: 'loading',
      errorText: '',
      recordId: '',
      items: [],
      parseError: false
    });

    const options = this.routeOptions || {};
    const recordId = String(options.recordId || '').trim();
    let items = [];
    let parseError = false;

    try {
      items = options.items ? JSON.parse(decodeURIComponent(options.items)) : [];
    } catch (error) {
      parseError = true;
      items = [];
    }

    const normalizedItems = Array.isArray(items) ? items : [];
    const nextState = parseError
      ? 'error'
      : normalizedItems.length > 0
        ? 'ready'
        : 'empty';

    this.setData({
      recordId,
      parseError,
      items: normalizedItems,
      uiState: nextState,
      errorText: parseError ? texts.parseFailed : ''
    });

    if (parseError) {
      Toast({ context: this, selector: '#t-toast', message: texts.parseFailed });
    }
  },

  onRetryLoad() {
    this.initPage();
  },

  goBack() {
    wx.navigateBack();
  },

  openMedicine(e) {
    const medicineId = e.currentTarget.dataset.medicineId;
    if (!medicineId) {
      Toast({ context: this, selector: '#t-toast', message: this.data.texts.medicineIdMissing });
      return;
    }
    wx.navigateTo({ url: `/pages/medicine/detail/index?id=${medicineId}` });
  }
});
