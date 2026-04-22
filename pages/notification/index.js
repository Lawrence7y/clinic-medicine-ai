const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser } = require('../../services/auth/index');
const {
  fetchNotifications,
  markAsRead,
  markAllAsRead
} = require('../../services/notification/index');

const FILTER_OPTIONS = [
  { value: 'all', label: '全部' },
  { value: 'system', label: '系统消息' },
  { value: 'appointment', label: '预约消息' },
  { value: 'todo', label: '待办消息' },
  { value: 'stock', label: '库存预警' }
];

Page({
  data: {
    uiState: 'loading',
    errorText: '',
    loading: false,
    list: [],
    visibleList: [],
    unreadCount: 0,
    filterOptions: FILTER_OPTIONS,
    filterIndex: 0,
    activeFilter: 'all',
    categoryCount: {
      all: 0,
      system: 0,
      appointment: 0,
      todo: 0,
      stock: 0
    },
    texts: {
      loading: '正在加载通知中心...',
      loadFailed: '通知加载失败',
      retry: '重试',
      empty: '暂无通知消息',
      markAllRead: '全部标记已读',
      unread: '未读',
      read: '已读',
      noPermission: '暂无权限访问',
      filter: '筛选',
      unknownJump: '该通知暂不支持跳转'
    }
  },

  onLoad() {
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
    this.loadData();
  },

  async loadData() {
    if (this.data.loading) return;
    this.setData({ loading: true, uiState: 'loading', errorText: '' });

    try {
      const result = await fetchNotifications();
      const list = Array.isArray(result.list) ? result.list : [];
      this.setData({
        list,
        unreadCount: Number(result.unreadCount || 0),
        categoryCount: result.categoryCount || this.data.categoryCount,
        uiState: list.length > 0 ? 'ready' : 'empty',
        errorText: ''
      });
      this.applyFilter(this.data.activeFilter);
    } catch (error) {
      const message = (error && error.message) || this.data.texts.loadFailed;
      this.setData({
        uiState: 'error',
        errorText: message
      });
      Toast({
        context: this,
        selector: '#t-toast',
        message
      });
    } finally {
      this.setData({ loading: false });
    }
  },

  onRetry() {
    this.loadData();
  },

  applyFilter(filterValue = 'all') {
    const list = this.data.list || [];
    const visibleList = filterValue === 'all'
      ? list
      : list.filter((item) => item.category === filterValue);
    const targetIndex = FILTER_OPTIONS.findIndex((item) => item.value === filterValue);
    this.setData({
      activeFilter: filterValue,
      filterIndex: targetIndex >= 0 ? targetIndex : 0,
      visibleList
    });
  },

  onFilterChange(e) {
    const index = Number(e.detail.value || 0);
    const selected = FILTER_OPTIONS[index] || FILTER_OPTIONS[0];
    this.applyFilter(selected.value);
  },

  markAllRead() {
    if (!this.data.list.length) return;
    markAllAsRead(this.data.list);
    const nextList = this.data.list.map((item) => ({ ...item, read: true }));
    this.setData({
      list: nextList,
      unreadCount: 0
    });
    this.applyFilter(this.data.activeFilter);
    Toast({
      context: this,
      selector: '#t-toast',
      message: '已全部标记为已读',
      theme: 'success'
    });
  },

  openNotification(e) {
    const item = e.currentTarget.dataset.item || {};
    if (!item || !item.notificationId) return;

    if (!item.read) {
      markAsRead(item.notificationId);
      const nextList = (this.data.list || []).map((row) => (
        row.notificationId === item.notificationId ? { ...row, read: true } : row
      ));
      this.setData({
        list: nextList,
        unreadCount: Math.max(0, Number(this.data.unreadCount || 0) - 1)
      });
      this.applyFilter(this.data.activeFilter);
    }

    if (item.actionType === 'appointment' && item.actionId) {
      wx.navigateTo({ url: `/pages/appointment/appointment-detail/index?id=${item.actionId}` });
      return;
    }
    if (item.actionType === 'medicine' && item.actionId) {
      wx.navigateTo({ url: `/pages/medicine/detail/index?id=${item.actionId}` });
      return;
    }
    if (item.actionType === 'admin-config') {
      wx.navigateTo({ url: '/pages/admin/system-config/index' });
      return;
    }
    if (item.actionType === 'admin-audit') {
      wx.navigateTo({ url: '/pages/admin/audit-center/index' });
      return;
    }
    if (item.actionType === 'admin-ai-logs') {
      wx.navigateTo({ url: '/pages/admin/ai-logs/index' });
      return;
    }
    if (item.actionType === 'ai-chat') {
      wx.navigateTo({ url: '/pages/ai/chat/index' });
      return;
    }
    Toast({
      context: this,
      selector: '#t-toast',
      message: this.data.texts.unknownJump
    });
  }
});
