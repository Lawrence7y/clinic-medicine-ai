const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser, logout } = require('../../services/auth/index');
const {
  USER_ROLES,
  ROLE_NAMES,
  getStoredConfig,
  subscribeSystemConfig,
  syncSystemConfig
} = require('../../services/config/index');
const {
  AI_ROUTES,
  getRecentAiFeatures,
  pushRecentAiFeature,
  resolveAiAssistantName
} = require('../../services/ai/index');

Page({
  data: {
    uiState: 'loading',
    errorText: '',
    userInfo: {},
    roleName: '',
    recentAiFeatures: [],
    systemConfig: {},
    isAdmin: false,
    isDoctor: false,
    isPatient: false,
    texts: {
      defaultUser: '\u7528\u6237',
      loading: '\u52a0\u8f7d\u4e2d...',
      loadFailed: '\u52a0\u8f7d\u5931\u8d25',
      retry: '\u91cd\u8bd5',
      adminGroup: '\u7ba1\u7406\u529f\u80fd',
      userManage: '\u7528\u6237\u7ba1\u7406',
      systemConfig: '\u7cfb\u7edf\u914d\u7f6e',
      auditCenter: '\u5ba1\u8ba1\u4e2d\u5fc3',
      aiGroup: 'AI \u529f\u80fd',
      aiAssistant: 'AI \u52a9\u624b',
      aiAssistantNote: '\u54a8\u8be2\u4e0e\u6d41\u7a0b\u95ee\u7b54',
      recentAi: '\u6700\u8fd1\u4f7f\u7528\u7684 AI \u529f\u80fd',
      serviceGroup: '\u6211\u7684\u670d\u52a1',
      myAppointments: '\u6211\u7684\u9884\u7ea6',
      notificationCenter: '\u901a\u77e5\u4e2d\u5fc3',
      patientServiceCenter: '\u60a3\u8005\u670d\u52a1\u4e2d\u5fc3',
      settingGroup: '\u8bbe\u7f6e',
      personInfo: '\u4e2a\u4eba\u4fe1\u606f',
      resetPassword: '\u91cd\u7f6e\u5bc6\u7801',
      sessionSecurity: '\u4f1a\u8bdd\u5b89\u5168',
      sessionSecurityNote: '\u7ba1\u7406\u591a\u7aef\u767b\u5f55',
      about: '\u5173\u4e8e',
      logout: '\u9000\u51fa\u767b\u5f55',
      aboutTitle: '\u5173\u4e8e',
      aboutContent: '\u8bca\u6240\u5c0f\u7a0b\u5e8f v1.0',
      logoutTitle: '\u9000\u51fa\u767b\u5f55',
      logoutConfirm: '\u786e\u8ba4\u9000\u51fa\u5f53\u524d\u8d26\u53f7\u5417\uff1f',
      logoutSuccess: '\u5df2\u9000\u51fa\u767b\u5f55'
    }
  },

  onLoad() {
    this._configSyncWarned = false;
    this.safeInitTabBar();
    this.subscribeConfigUpdates();
    this.initPage();
  },

  onShow() {
    this.safeInitTabBar();
    this.initPage();
  },

  onUnload() {
    if (typeof this._unsubscribeConfig === 'function') {
      this._unsubscribeConfig();
      this._unsubscribeConfig = null;
    }
  },

  safeInitTabBar() {
    const tabBar = this.getTabBar && this.getTabBar();
    if (tabBar && typeof tabBar.init === 'function') {
      tabBar.init();
    }
  },

  async initPage() {
    this.setData({ uiState: 'loading', errorText: '' });
    try {
      const userInfo = getCurrentUser();
      if (!userInfo) {
        wx.redirectTo({ url: '/pages/login/index' });
        return;
      }

      const role = userInfo.role;
      const systemConfig = await this.syncSystemConfig();
      this.setData({
        uiState: 'ready',
        userInfo,
        roleName: ROLE_NAMES[role] || this.data.texts.defaultUser,
        recentAiFeatures: getRecentAiFeatures(),
        systemConfig,
        isAdmin: role === USER_ROLES.SUPER_ADMIN || role === USER_ROLES.CLINIC_ADMIN,
        isDoctor: role === USER_ROLES.DOCTOR,
        isPatient: role === USER_ROLES.PATIENT
      });
    } catch (error) {
      this.setData({
        uiState: 'error',
        errorText: error && error.message ? error.message : this.data.texts.loadFailed
      });
    }
  },

  retryLoad() {
    this.initPage();
  },

  goToUserManage() { wx.navigateTo({ url: '/pages/user/user-list/index' }); },
  goToSystemConfig() { wx.navigateTo({ url: '/pages/admin/system-config/index' }); },
  goToAuditCenter() { wx.navigateTo({ url: '/pages/admin/audit-center/index' }); },
  goToAiAssistant() {
    const aiName = resolveAiAssistantName(this.data.systemConfig, this.data.texts.aiAssistant);
    const recent = pushRecentAiFeature(aiName, AI_ROUTES.CHAT);
    this.setData({ recentAiFeatures: recent });
    wx.navigateTo({ url: AI_ROUTES.CHAT });
  },
  goToMyAppointments() { wx.navigateTo({ url: '/pages/appointment/my-appointments/index' }); },
  goToNotificationCenter() { wx.navigateTo({ url: '/pages/notification/index' }); },
  goToPatientServiceCenter() { wx.navigateTo({ url: '/pages/patient/service-center/index' }); },
  goToPersonInfo() { wx.navigateTo({ url: '/pages/user/person-info/index' }); },
  goToResetPassword() { wx.navigateTo({ url: '/pages/user/password-reset/index' }); },
  goToSessionSecurity() { wx.navigateTo({ url: '/pages/user/session-security/index' }); },

  openRecentAi(e) {
    const path = e.currentTarget.dataset.path;
    if (!path) return;
    const fallbackName = resolveAiAssistantName(this.data.systemConfig, this.data.texts.aiAssistant);
    const recent = pushRecentAiFeature(e.currentTarget.dataset.name || fallbackName, path);
    this.setData({ recentAiFeatures: recent });
    wx.navigateTo({ url: path });
  },

  subscribeConfigUpdates() {
    if (typeof this._unsubscribeConfig === 'function') return;
    this._unsubscribeConfig = subscribeSystemConfig((config) => {
      this.applySystemConfig(config || {});
    });
  },

  async syncSystemConfig() {
    try {
      const res = await syncSystemConfig({ silent: true });
      const systemConfig = (res && res.data) || getStoredConfig();
      this.applySystemConfig(systemConfig);
      if (res && res.error && !this._configSyncWarned) {
        this._configSyncWarned = true;
        Toast({
          context: this,
          selector: '#t-toast',
          message: '配置同步失败，已使用本地配置'
        });
      }
      return systemConfig;
    } catch (error) {
      const fallback = getStoredConfig();
      this.applySystemConfig(fallback);
      return fallback;
    }
  },

  applySystemConfig(config = {}) {
    this.setData({ systemConfig: config || {} });
  },

  goToAbout() {
    wx.showModal({
      title: this.data.texts.aboutTitle,
      content: this.data.texts.aboutContent,
      showCancel: false
    });
  },

  handleLogout() {
    wx.showModal({
      title: this.data.texts.logoutTitle,
      content: this.data.texts.logoutConfirm,
      success: async (res) => {
        if (!res.confirm) return;
        await logout();
        Toast({ context: this, selector: '#t-toast', message: this.data.texts.logoutSuccess, theme: 'success' });
        setTimeout(() => wx.redirectTo({ url: '/pages/login/index' }), 600);
      }
    });
  }
});
