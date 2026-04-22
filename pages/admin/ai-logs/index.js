const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser } = require('../../../services/auth/index');
const { USER_ROLES } = require('../../../services/config/index');
const { getAiLogs } = require('../../../services/ai/index');

const SUCCESS_OPTIONS = [
  { label: '全部状态', value: 'all' },
  { label: '仅成功', value: 'success' },
  { label: '仅失败', value: 'failed' }
];

Page({
  data: {
    uiState: 'loading',
    errorMessage: '',
    loading: false,
    limit: 100,
    logs: [],
    filterScene: '',
    filterModel: '',
    filterStartDate: '',
    filterEndDate: '',
    successOptions: SUCCESS_OPTIONS,
    successIndex: 0,
    activeSuccessValue: 'all',
    texts: {
      noPermission: '暂无权限',
      success: '成功',
      failed: '失败',
      loadFail: 'AI 调用日志加载失败',
      loading: '加载中...',
      retry: '重试',
      empty: '暂无 AI 调用日志',
      time: '时间',
      scene: '场景',
      model: '模型',
      duration: '耗时',
      failureReason: '失败原因',
      keywordScene: '场景关键字',
      keywordModel: '模型关键字',
      startDate: '开始日期',
      endDate: '结束日期',
      status: '状态筛选',
      query: '查询',
      reset: '重置',
      resultCount: '查询结果',
      recordsUnit: '条',
      security: '安全留痕'
    }
  },

  onLoad() {
    this.initPage();
  },

  onShow() {
    this.loadLogs({ preserveState: true });
  },

  onPullDownRefresh() {
    this.loadLogs({ preserveState: true }).finally(() => wx.stopPullDownRefresh());
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
      wx.showToast({ title: this.data.texts.noPermission, icon: 'none' });
      setTimeout(() => wx.navigateBack(), 800);
      return;
    }
    this.loadLogs();
  },

  buildQueryParams() {
    const params = { limit: this.data.limit };
    const scene = String(this.data.filterScene || '').trim();
    const model = String(this.data.filterModel || '').trim();
    const startDate = String(this.data.filterStartDate || '').trim();
    const endDate = String(this.data.filterEndDate || '').trim();
    if (scene) params.scene = scene;
    if (model) params.model = model;
    if (startDate) params.startTime = `${startDate} 00:00:00`;
    if (endDate) params.endTime = `${endDate} 23:59:59`;
    if (this.data.activeSuccessValue === 'success') params.success = true;
    if (this.data.activeSuccessValue === 'failed') params.success = false;
    return params;
  },

  async loadLogs({ preserveState = false } = {}) {
    if (this.data.loading) return;
    const { texts } = this.data;
    this.setData({
      loading: true,
      uiState: preserveState && this.data.uiState === 'ready' ? 'ready' : 'loading',
      errorMessage: preserveState ? this.data.errorMessage : ''
    });
    try {
      const res = await getAiLogs(this.buildQueryParams());
      const list = Array.isArray(res?.data) ? res.data : [];
      this.setData({
        logs: list.map((item) => ({
          ...item,
          displayTime: item.time || item.createdAt || '-',
          displayScene: item.scene || item.sceneCode || '-',
          displayModel: item.model || item.modelName || '-',
          successText: item.success ? texts.success : texts.failed,
          durationText: `${Number(item.durationMs || 0)} ms`,
          displayFailureReason: item.failureReason || '-',
          securityText: item.securityAction || (
            item.requestMasked || item.responseMasked
              ? `脱敏 输入${Number(item.requestMaskCount || 0)} / 输出${Number(item.responseMaskCount || 0)}`
              : '-'
          )
        })),
        uiState: 'ready'
      });
    } catch (error) {
      const failMessage = (error && error.message) || texts.loadFail;
      this.setData({
        uiState: 'error',
        errorMessage: failMessage
      });
      Toast({ context: this, selector: '#t-toast', message: failMessage });
    } finally {
      this.setData({ loading: false });
    }
  },

  onRetry() {
    this.loadLogs();
  },

  onSceneInput(e) {
    this.setData({ filterScene: e.detail.value || '' });
  },

  onModelInput(e) {
    this.setData({ filterModel: e.detail.value || '' });
  },

  onSuccessFilterChange(e) {
    const index = Number(e.detail.value);
    const option = SUCCESS_OPTIONS[index] || SUCCESS_OPTIONS[0];
    this.setData({
      successIndex: Number.isFinite(index) ? index : 0,
      activeSuccessValue: option.value
    });
  },

  onStartDateChange(e) {
    this.setData({ filterStartDate: e.detail.value || '' });
  },

  onEndDateChange(e) {
    this.setData({ filterEndDate: e.detail.value || '' });
  },

  applyFilters() {
    this.loadLogs();
  },

  resetFilters() {
    this.setData({
      filterScene: '',
      filterModel: '',
      filterStartDate: '',
      filterEndDate: '',
      successIndex: 0,
      activeSuccessValue: SUCCESS_OPTIONS[0].value
    });
    this.loadLogs();
  }
});
