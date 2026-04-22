const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser } = require('../../../services/auth/index');
const { USER_ROLES } = require('../../../services/config/index');
const { getDoctorTodo } = require('../../../services/appointment/index');
const { getStockWarnings } = require('../../../services/medicine/index');

Page({
  data: {
    uiState: 'loading',
    errorText: '',
    loading: false,
    stats: {
      pendingCount: 0,
      confirmedCount: 0,
      todayCount: 0,
      nearVisitCount: 0,
      stockWarningCount: 0
    },
    todoList: [],
    stockWarnings: [],
    texts: {
      loading: '加载中...',
      loadFailed: '加载失败',
      retry: '重试'
    }
  },

  onShow() {
    this.initPage();
  },

  onPullDownRefresh() {
    this.loadData().finally(() => wx.stopPullDownRefresh());
  },

  initPage() {
    const user = getCurrentUser();
    if (!user) {
      wx.redirectTo({ url: '/pages/login/index' });
      return;
    }
    const allow = [USER_ROLES.DOCTOR, USER_ROLES.SUPER_ADMIN, USER_ROLES.CLINIC_ADMIN].includes(user.role);
    if (!allow) {
      wx.showToast({ title: '暂无权限', icon: 'none' });
      setTimeout(() => wx.navigateBack(), 800);
      return;
    }
    this.setData({ uiState: 'loading', errorText: '' });
    this.loadData();
  },

  async loadData() {
    if (this.data.loading) return;
    this.setData({ loading: true, uiState: 'loading', errorText: '' });
    try {
      const [todoRes, warningRes] = await Promise.all([
        getDoctorTodo(),
        getStockWarnings()
      ]);
      const warningList = Array.isArray(warningRes?.data)
        ? warningRes.data.map((item) => ({
            ...item,
            warningText: this.getWarningText(item)
          }))
        : [];
      this.setData({
        stats: {
          pendingCount: Number(todoRes?.data?.pendingCount || 0),
          confirmedCount: Number(todoRes?.data?.confirmedCount || 0),
          todayCount: Number(todoRes?.data?.todayCount || 0),
          nearVisitCount: Number(todoRes?.data?.nearVisitCount || 0),
          stockWarningCount: warningList.length
        },
        todoList: Array.isArray(todoRes?.data?.todoList) ? todoRes.data.todoList : [],
        stockWarnings: warningList.slice(0, 8),
        uiState: 'ready',
        errorText: ''
      });
    } catch (error) {
      this.setData({
        uiState: 'error',
        errorText: error.message || this.data.texts.loadFailed
      });
      Toast({
        context: this,
        selector: '#t-toast',
        message: error.message || this.data.texts.loadFailed
      });
    } finally {
      this.setData({ loading: false });
    }
  },

  onRetry() {
    this.loadData();
  },

  openAppointmentDetail(e) {
    const id = e.currentTarget.dataset.id;
    if (!id) return;
    wx.navigateTo({ url: `/pages/appointment/appointment-detail/index?id=${id}` });
  },

  openMedicineDetail(e) {
    const id = e.currentTarget.dataset.id;
    if (!id) return;
    wx.navigateTo({ url: `/pages/medicine/detail/index?id=${id}` });
  },

  getWarningText(item = {}) {
    if (item.warningType === 'expired') return '已过期，请优先处理';
    if (item.warningType === 'near_expiry') {
      const days = Number(item.daysToExpiry);
      if (Number.isFinite(days)) return `近效期，${days} 天后过期`;
      return '近效期，请尽快处理';
    }
    return `库存偏低：${item.stock || 0} / 阈值 ${item.warningThreshold || 10}`;
  }
});
