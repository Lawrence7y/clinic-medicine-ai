const { isLoggedIn } = require('./services/auth/index');
const { getConfigVersion, getStoredConfig, syncSystemConfig, publishRuntimeConfig, STORAGE_KEYS } = require('./services/config/index');

const CONFIG_FULL_SYNC_INTERVAL = 30000;
const CONFIG_VERSION_CHECK_INTERVAL = 5000;
const CONFIG_MIN_SYNC_INTERVAL = 2000;

App({
  onLaunch() {
    this.setupGlobalErrorHandlers();
    this.preloadSystemConfig({ force: true });
    this.startSystemConfigAutoSync();
  },

  onShow() {
    this.checkLoginStatus();
    this.preloadSystemConfig({ force: true });
    this.startSystemConfigAutoSync();
  },

  onHide() {
    this.stopSystemConfigAutoSync();
  },

  async preloadSystemConfig(options = {}) {
    const { force = false } = options;
    const now = Date.now();
    if (!force && this._configSyncing) return;
    if (!force && this._lastConfigSyncAt && now - this._lastConfigSyncAt < CONFIG_MIN_SYNC_INTERVAL) return;

    this._configSyncing = true;
    this._lastConfigSyncAt = now;
    try {
      const res = await syncSystemConfig({ force, silent: true });
      const systemConfig = res.data || {};
      const configUpdatedAt = Number(systemConfig.configUpdatedAt || 0) || Date.now();
      this.globalData.systemConfig = systemConfig;
      this.globalData.systemConfigUpdatedAt = configUpdatedAt;
    } catch (error) {
      const fallback = getStoredConfig();
      publishRuntimeConfig(fallback);
      this.globalData.systemConfig = fallback;
      this.globalData.systemConfigUpdatedAt = Number(fallback.configUpdatedAt || 0) || this.globalData.systemConfigUpdatedAt || 0;
    } finally {
      this._configSyncing = false;
    }
  },

  async checkSystemConfigVersion() {
    if (!isLoggedIn()) return;
    if (this._configVersionChecking) return;
    this._configVersionChecking = true;
    try {
      const res = await getConfigVersion();
      const remoteUpdatedAt = Number(res?.data?.configUpdatedAt || 0);
      const localConfigUpdatedAt = Number(this.globalData?.systemConfig?.configUpdatedAt || 0);
      const localUpdatedAt = Number(this.globalData?.systemConfigUpdatedAt || 0);
      const currentVersion = Math.max(localConfigUpdatedAt, localUpdatedAt);

      if (remoteUpdatedAt > 0 && remoteUpdatedAt > currentVersion) {
        await this.preloadSystemConfig({ force: true });
      }
    } catch (error) {
      // ignore version check error
    } finally {
      this._configVersionChecking = false;
    }
  },

  checkLoginStatus() {
    if (this._loginStatusChecked) return;
    this._loginStatusChecked = true;

    if (!isLoggedIn()) return;
    const pages = getCurrentPages();
    const currentPage = pages[pages.length - 1];
    if (currentPage && currentPage.route === 'pages/login/index') {
      wx.switchTab({ url: '/pages/home/home' });
    }
  },

  startSystemConfigAutoSync() {
    if (!this._configSyncTimer) {
      this._configSyncTimer = setInterval(() => {
        this.preloadSystemConfig().catch(() => {});
      }, CONFIG_FULL_SYNC_INTERVAL);
    }
    if (!this._configVersionTimer) {
      this._configVersionTimer = setInterval(() => {
        this.checkSystemConfigVersion().catch(() => {});
      }, CONFIG_VERSION_CHECK_INTERVAL);
    }
  },

  stopSystemConfigAutoSync() {
    if (this._configSyncTimer) {
      clearInterval(this._configSyncTimer);
      this._configSyncTimer = null;
    }
    if (this._configVersionTimer) {
      clearInterval(this._configVersionTimer);
      this._configVersionTimer = null;
    }
  },

  setupGlobalErrorHandlers() {
    const forceReLogin = (message) => {
      if (this._reloginHandling) return;
      this._reloginHandling = true;
      wx.removeStorageSync(STORAGE_KEYS.TOKEN);
      wx.removeStorageSync(STORAGE_KEYS.USER_INFO);
      wx.removeStorageSync(STORAGE_KEYS.CLIENT_KEY);
      wx.showToast({ title: message, icon: 'none' });
      setTimeout(() => {
        wx.reLaunch({
          url: '/pages/login/index',
          fail: () => wx.redirectTo({ url: '/pages/login/index' })
        });
        this._reloginHandling = false;
      }, 1200);
    };

    const handleUnhandledRejection = (evt = {}) => {
      const reason = evt.reason || {};
      const message = String(reason.message || '');
      const type = String(reason.type || '');

      const isForbidden = type === 'forbidden'
        || /forbidden|permission denied|no permission|暂无权限|权限不足|无权|禁止访问/i.test(message);
      const isKickout = type === 'kickout'
        || /kickout|login elsewhere|session invalid|forced logout|其他设备登录|异地登录|会话失效|强制下线|重新登录|已下线/i.test(message);

      if (isKickout) {
        forceReLogin(message || '账号已在其他设备登录，请重新登录');
        return;
      }

      if (isForbidden) {
        wx.showToast({ title: '暂无权限访问', icon: 'none' });
      }
    };

    if (typeof wx.onUnhandledRejection === 'function') {
      wx.onUnhandledRejection(handleUnhandledRejection);
    }
  },

  globalData: {
    userInfo: null,
    systemConfig: {},
    systemConfigUpdatedAt: 0,
    systemConfigListeners: []
  }
});
