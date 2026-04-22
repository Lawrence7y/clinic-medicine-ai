const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser } = require('../../../services/auth/index');
const { USER_ROLES } = require('../../../services/config/index');
const { getAuditLogs } = require('../../../services/audit/index');

Page({
  data: {
    uiState: 'loading',
    errorMessage: '',
    loading: false,
    logs: [],
    filterModule: '',
    filterAction: '',
    filterKeyword: '',
    filterStartDate: '',
    filterEndDate: '',
    texts: {
      noPermission: '暂无权限',
      loadFail: '审计日志加载失败',
      loading: '加载中...',
      retry: '重试',
      empty: '暂无审计日志',
      module: '模块',
      action: '动作',
      keyword: '关键字',
      operator: '操作人',
      target: '目标',
      detail: '明细',
      time: '时间',
      query: '查询',
      reset: '重置',
      startDate: '开始日期',
      endDate: '结束日期'
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
    if (!isAdmin) {
      wx.showToast({ title: this.data.texts.noPermission, icon: 'none' });
      setTimeout(() => wx.navigateBack(), 800);
      return;
    }
    this.loadLogs();
  },

  buildQuery() {
    const query = { limit: 100 };
    if (this.data.filterModule.trim()) query.module = this.data.filterModule.trim();
    if (this.data.filterAction.trim()) query.action = this.data.filterAction.trim();
    if (this.data.filterKeyword.trim()) query.keyword = this.data.filterKeyword.trim();
    if (this.data.filterStartDate) query.startTime = `${this.data.filterStartDate} 00:00:00`;
    if (this.data.filterEndDate) query.endTime = `${this.data.filterEndDate} 23:59:59`;
    return query;
  },

  async loadLogs({ preserveState = false } = {}) {
    if (this.data.loading) return;
    this.setData({
      loading: true,
      uiState: preserveState && this.data.uiState === 'ready' ? 'ready' : 'loading',
      errorMessage: preserveState ? this.data.errorMessage : ''
    });
    try {
      const res = await getAuditLogs(this.buildQuery());
      const logs = Array.isArray(res?.data) ? res.data : [];
      this.setData({
        logs,
        uiState: 'ready'
      });
    } catch (error) {
      const message = error.message || this.data.texts.loadFail;
      this.setData({
        uiState: 'error',
        errorMessage: message
      });
      Toast({ context: this, selector: '#t-toast', message });
    } finally {
      this.setData({ loading: false });
    }
  },

  onRetry() {
    this.loadLogs();
  },

  onModuleInput(e) {
    this.setData({ filterModule: e.detail.value || '' });
  },

  onActionInput(e) {
    this.setData({ filterAction: e.detail.value || '' });
  },

  onKeywordInput(e) {
    this.setData({ filterKeyword: e.detail.value || '' });
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
      filterModule: '',
      filterAction: '',
      filterKeyword: '',
      filterStartDate: '',
      filterEndDate: ''
    });
    this.loadLogs();
  }
});
