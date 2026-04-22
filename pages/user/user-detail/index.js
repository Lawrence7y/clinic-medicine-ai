const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser, getUserDetail, deleteUser } = require('../../../services/auth/index');
const { USER_ROLES } = require('../../../services/config/index');

Page({
  data: {
    userInfo: null,
    loading: false,
    uiState: 'loading',
    errorText: '',
    editable: false,
    texts: {
      loading: '正在加载用户详情...',
      loadFailed: '用户详情加载失败',
      empty: '未找到用户信息',
      retry: '重试',
      goBack: '返回',
      editFromList: '请在用户列表中编辑用户',
      confirmDeleteTitle: '确认删除',
      confirmDeleteContent: '确定要删除该用户吗？',
      deleteSuccess: '删除成功',
      deleteFailed: '删除失败'
    }
  },

  onLoad(options = {}) {
    this.userId = options.userId || '';
    this.initPage();
  },

  initPage() {
    if (!this.userId) {
      this.setData({
        uiState: 'error',
        errorText: '缺少用户 ID，无法加载详情。'
      });
      return;
    }

    const currentUser = getCurrentUser();
    if (!currentUser) {
      wx.redirectTo({ url: '/pages/login/index' });
      return;
    }

    const isAdmin = currentUser.role === USER_ROLES.SUPER_ADMIN || currentUser.role === USER_ROLES.CLINIC_ADMIN;
    this.setData({ editable: isAdmin });
    this.loadUserDetail();
  },

  async loadUserDetail() {
    this.setData({
      loading: true,
      uiState: 'loading',
      errorText: ''
    });

    try {
      const res = await getUserDetail(this.userId);
      const rawData = (res && res.data) || {};
      const raw = rawData.raw || {};
      if (!rawData.id) {
        this.setData({
          userInfo: null,
          uiState: 'empty'
        });
        return;
      }

      this.setData({
        userInfo: {
          id: rawData.id,
          name: rawData.name || '-',
          phone: rawData.phone || '-',
          role: rawData.role || '',
          roleKey: rawData.roleKey || '',
          roleName: raw.roleName || rawData.roleName || '-',
          email: rawData.email || raw.email || '未设置',
          title: rawData.title || raw.title || '未设置',
          createTime: raw.createTime || rawData.createdAt || '-',
          lastLoginTime: raw.loginDate || raw.lastLoginTime || '-'
        },
        uiState: 'ready'
      });
    } catch (error) {
      const message = error && error.message ? error.message : this.data.texts.loadFailed;
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
    this.loadUserDetail();
  },

  editUser() {
    wx.showToast({
      title: this.data.texts.editFromList,
      icon: 'none'
    });
    setTimeout(() => {
      wx.navigateTo({
        url: '/pages/user/user-list/index'
      });
    }, 300);
  },

  resetPassword() {
    wx.navigateTo({
      url: `/pages/user/password-reset/index?id=${this.userId}`
    });
  },

  deleteUser() {
    wx.showModal({
      title: this.data.texts.confirmDeleteTitle,
      content: this.data.texts.confirmDeleteContent,
      success: async (res) => {
        if (!res.confirm) return;

        this.setData({ loading: true });
        try {
          await deleteUser(this.userId);
          Toast({
            context: this,
            selector: '#t-toast',
            message: this.data.texts.deleteSuccess,
            theme: 'success'
          });
          setTimeout(() => {
            wx.navigateBack();
          }, 1200);
        } catch (error) {
          Toast({
            context: this,
            selector: '#t-toast',
            message: (error && error.message) || this.data.texts.deleteFailed
          });
        } finally {
          this.setData({ loading: false });
        }
      }
    });
  },

  goBack() {
    wx.navigateBack();
  }
});
