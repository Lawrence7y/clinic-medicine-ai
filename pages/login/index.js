import Toast from 'tdesign-miniprogram/toast/index';
import {
  LOGIN_COPY,
  getLoginCaptcha,
  getPasswordMinLengthText,
  isLoggedIn,
  login
} from '../../services/auth/index';
import {
  getStoredConfig,
  subscribeSystemConfig,
  syncSystemConfig as syncGlobalSystemConfig
} from '../../services/config/index';

Page({
  data: {
    loading: false,
    captchaLoading: false,
    systemConfig: {},
    apiReady: true,
    apiErrorText: '',
    captchaEnabled: true,
    captchaId: '',
    captchaImage: '',
    loginSecurity: {
      maxFailCount: 5,
      lockMinutes: 5,
      maxSessionCount: 2,
      kickoutAfterNewLogin: false
    },
    securityTip: '登录失败累计 5 次将锁定 5 分钟',
    texts: {
      title: '诊所管理系统',
      subtitle: '统一使用手机号登录，保留 admin 账号登录',
      accountPlaceholder: LOGIN_COPY.accountPlaceholder,
      passwordPlaceholder: LOGIN_COPY.passwordRequired,
      captchaPlaceholder: LOGIN_COPY.captchaRequired,
      captchaRefresh: '点击刷新',
      captchaLoading: '加载中...',
      captchaTip: '看不清可点击验证码图片刷新',
      apiConfigTitle: '接口地址未就绪',
      apiConfigGuide: '请联系管理员检查后台系统配置中的“小程序 API 地址”并确认服务可访问。',
      retryApi: '重新检测接口',
      loginButton: '登录',
      loggingIn: '登录中...',
      adminDemo: '管理员：admin / 123456',
      clinicAdminDemo: '诊所管理员：13800138001 / 123456',
      lockRetry: '账号已锁定，请稍后重试'
    },
    lockInfo: {
      locked: false,
      lockUntil: 0,
      retryAfterSeconds: 0,
      text: ''
    },
    loginForm: {
      account: '',
      password: '',
      captchaCode: ''
    }
  },

  onLoad() {
    this.applySystemConfig(getStoredConfig());
    this.subscribeConfigUpdates();
    this.syncSystemConfig();

    setTimeout(() => {
      if (isLoggedIn()) {
        wx.switchTab({ url: '/pages/home/home', fail: () => {} });
        return;
      }
      this.refreshCaptcha();
    }, 80);
  },

  onHide() {
    this.stopLockCountdown();
  },

  onUnload() {
    this.stopLockCountdown();
    this.cleanupCaptchaFile(this.data.captchaImage);
    if (typeof this._unsubscribeConfig === 'function') {
      this._unsubscribeConfig();
      this._unsubscribeConfig = null;
    }
  },

  subscribeConfigUpdates() {
    if (typeof this._unsubscribeConfig === 'function') return;
    this._unsubscribeConfig = subscribeSystemConfig((config) => {
      this.applySystemConfig(config || getStoredConfig());
    });
  },

  applySystemConfig(config = {}) {
    this.setData({ systemConfig: config || {} });
  },

  async syncSystemConfig() {
    try {
      const res = await syncGlobalSystemConfig({ silent: true });
      this.applySystemConfig((res && res.data) || getStoredConfig());
    } catch (error) {
      this.applySystemConfig(getStoredConfig());
    }
  },

  onAccountChange(e) {
    this.setData({ 'loginForm.account': e.detail.value || '' });
  },

  onPasswordChange(e) {
    this.setData({ 'loginForm.password': e.detail.value || '' });
  },

  onCaptchaChange(e) {
    this.setData({ 'loginForm.captchaCode': e.detail.value || '' });
  },

  buildSecurityTip(payload = {}) {
    const maxFailCount = Number(payload.maxFailCount || 5);
    const lockMinutes = Number(payload.lockMinutes || 5);
    const maxSessionCount = Number(payload.maxSessionCount || 2);
    const kickoutAfterNewLogin = !!payload.kickoutAfterNewLogin;
    const strategyText = kickoutAfterNewLogin ? '超出后自动下线最早登录设备' : '达到上限后禁止新设备登录';
    return `登录失败累计 ${maxFailCount} 次将锁定 ${lockMinutes} 分钟；最多保留 ${maxSessionCount} 个会话，${strategyText}`;
  },

  async refreshCaptcha() {
    if (this.data.captchaLoading) return;
    this.setData({ captchaLoading: true });

    try {
      const res = await getLoginCaptcha();
      const payload = (res && res.data) || {};
      const captchaEnabled = payload.captchaEnabled !== false;
      const maxFailCount = Number(payload.maxFailCount || this.data.loginSecurity.maxFailCount || 5);
      const lockMinutes = Number(payload.lockMinutes || this.data.loginSecurity.lockMinutes || 5);
      const maxSessionCount = Number(payload.maxSessionCount || this.data.loginSecurity.maxSessionCount || 2);
      const kickoutAfterNewLogin = !!payload.kickoutAfterNewLogin;
      const securityTip = this.buildSecurityTip({
        maxFailCount,
        lockMinutes,
        maxSessionCount,
        kickoutAfterNewLogin
      });

      if (!captchaEnabled) {
        this.cleanupCaptchaFile(this.data.captchaImage);
        this.setData({
          captchaEnabled: false,
          captchaId: '',
          captchaImage: '',
          loginSecurity: {
            maxFailCount,
            lockMinutes,
            maxSessionCount,
            kickoutAfterNewLogin
          },
          securityTip,
          'loginForm.captchaCode': ''
        });
        return;
      }

      const captchaImage = await this.persistCaptchaImage(payload.imageBase64 || '');
      this.cleanupCaptchaFile(this.data.captchaImage);
      this.setData({
        apiReady: true,
        apiErrorText: '',
        captchaEnabled: true,
        captchaId: payload.captchaId || '',
        captchaImage,
        loginSecurity: {
          maxFailCount,
          lockMinutes,
          maxSessionCount,
          kickoutAfterNewLogin
        },
        securityTip,
        'loginForm.captchaCode': ''
      });
    } catch (error) {
      const message = (error && error.message) || LOGIN_COPY.captchaLoadFailed;
      const missingApiAddress = /API 地址/.test(message);
      this.cleanupCaptchaFile(this.data.captchaImage);
      this.setData({
        apiReady: missingApiAddress ? false : this.data.apiReady,
        apiErrorText: missingApiAddress ? message : this.data.apiErrorText,
        captchaEnabled: false,
        captchaId: '',
        captchaImage: '',
        'loginForm.captchaCode': ''
      });
      if (!missingApiAddress) {
        Toast({
          context: this,
          selector: '#t-toast',
          message
        });
      }
    } finally {
      this.setData({ captchaLoading: false });
    }
  },

  persistCaptchaImage(imageBase64) {
    return new Promise((resolve, reject) => {
      if (!imageBase64) {
        reject(new Error(LOGIN_COPY.captchaImageEmpty));
        return;
      }

      try {
        const fsm = wx.getFileSystemManager();
        const filePath = `${wx.env.USER_DATA_PATH}/login-captcha-${Date.now()}.jpg`;
        const arrayBuffer = wx.base64ToArrayBuffer(imageBase64);
        fsm.writeFile({
          filePath,
          data: arrayBuffer,
          encoding: 'binary',
          success: () => resolve(filePath),
          fail: reject
        });
      } catch (error) {
        reject(error);
      }
    });
  },

  cleanupCaptchaFile(filePath) {
    if (!filePath || !filePath.startsWith(wx.env.USER_DATA_PATH)) return;
    try {
      wx.getFileSystemManager().unlink({ filePath, fail: () => {} });
    } catch (error) {
      // ignore
    }
  },

  applyAccountLock(payload = {}) {
    const retryAfterSeconds = Math.max(0, Number(payload.retryAfterSeconds || 0));
    const lockUntil = Number(payload.lockedUntil || 0);
    const lockUntilTs = lockUntil > 0 ? lockUntil : Date.now() + retryAfterSeconds * 1000;
    this.setData({
      lockInfo: {
        locked: true,
        lockUntil: lockUntilTs,
        retryAfterSeconds,
        text: ''
      }
    });
    this.updateLockCountdown();
    this.startLockCountdown();
  },

  startLockCountdown() {
    this.stopLockCountdown();
    this.lockTimer = setInterval(() => this.updateLockCountdown(), 1000);
  },

  stopLockCountdown() {
    if (this.lockTimer) {
      clearInterval(this.lockTimer);
      this.lockTimer = null;
    }
  },

  updateLockCountdown() {
    const lockUntil = Number(this.data.lockInfo.lockUntil || 0);
    if (!lockUntil || lockUntil <= Date.now()) {
      this.stopLockCountdown();
      this.setData({
        lockInfo: {
          locked: false,
          lockUntil: 0,
          retryAfterSeconds: 0,
          text: ''
        }
      });
      return;
    }

    const remainingSeconds = Math.max(1, Math.ceil((lockUntil - Date.now()) / 1000));
    const minutes = Math.floor(remainingSeconds / 60);
    const seconds = remainingSeconds % 60;
    const text = `账号已锁定，请在 ${minutes}分${String(seconds).padStart(2, '0')}秒 后重试`;

    this.setData({
      lockInfo: {
        locked: true,
        lockUntil,
        retryAfterSeconds: remainingSeconds,
        text
      }
    });
  },

  validateInput() {
    const { account, password, captchaCode } = this.data.loginForm;
    const { captchaEnabled, captchaId, lockInfo } = this.data;
    const username = String(account || '').trim();
    const isAdminLogin = username.toLowerCase() === 'admin';

    if (lockInfo && lockInfo.locked) {
      throw new Error(lockInfo.text || this.data.texts.lockRetry);
    }
    if (!username) {
      throw new Error(LOGIN_COPY.accountRequired);
    }
    if (!isAdminLogin && !/^1\d{10}$/.test(username)) {
      throw new Error(LOGIN_COPY.phoneLoginOnly);
    }
    if (!password) {
      throw new Error(LOGIN_COPY.passwordRequired);
    }
    if (String(password).length < 6) {
      throw new Error(getPasswordMinLengthText(6));
    }
    if (captchaEnabled && !captchaCode) {
      throw new Error(LOGIN_COPY.captchaRequired);
    }
    if (captchaEnabled && !captchaId) {
      throw new Error(LOGIN_COPY.captchaNotReady);
    }

    return { username, password, captchaCode, captchaId };
  },

  formatLoginError(error) {
    if (!error) return LOGIN_COPY.loginFailed;
    const payload = error.payload || {};
    const errorType = error.errorType || payload.errorType || '';
    const fallbackMaxFailCount = Number(payload.maxFailCount || this.data.loginSecurity.maxFailCount || 5);
    const maxFailCount = Number.isFinite(fallbackMaxFailCount) ? fallbackMaxFailCount : 5;

    if (errorType === 'ACCOUNT_LOCKED') {
      this.applyAccountLock(payload);
      const retryAfterSeconds = Number(payload.retryAfterSeconds || 0);
      if (retryAfterSeconds > 0) {
        const minutes = Math.max(1, Math.ceil(retryAfterSeconds / 60));
        return `登录失败次数过多，账号已锁定，约 ${minutes} 分钟后可重试`;
      }
      return `登录失败次数过多（阈值 ${maxFailCount} 次），账号已被临时锁定`;
    }

    if (errorType === 'LOGIN_FAILED') {
      const remaining = Number(payload.remainingAttempts);
      if (Number.isFinite(remaining) && remaining >= 0) {
        return `账号、密码或验证码错误，剩余尝试次数：${remaining}`;
      }
    }

    if (errorType === 'CAPTCHA_INVALID') {
      return LOGIN_COPY.captchaInvalidOrExpired;
    }

    if (errorType === 'SESSION_LIMIT_EXCEEDED') {
      const maxSessionCount = Number(payload.maxSessionCount || this.data.loginSecurity.maxSessionCount || 2);
      const onlineSessionCount = Number(payload.onlineSessionCount || 0);
      if (onlineSessionCount > 0) {
        return `当前在线会话已达上限（${onlineSessionCount}/${maxSessionCount}），请先在“会话安全”中下线其他设备后再登录`;
      }
      return `当前在线会话已达上限（最多 ${maxSessionCount} 个），请稍后重试`;
    }

    if (error.type === 'kickout') {
      return '账号已在其他设备登录，请重新登录';
    }
    if (error.type === 'forbidden') {
      return '暂无权限登录，请联系管理员';
    }

    return error.message || LOGIN_COPY.loginFailed;
  },

  async handleAccountLogin() {
    if (this.data.loading) return;
    if (!this.data.apiReady) {
      Toast({
        context: this,
        selector: '#t-toast',
        message: this.data.apiErrorText || '接口地址未就绪，请联系管理员检查系统配置。'
      });
      return;
    }

    let form;
    try {
      form = this.validateInput();
    } catch (error) {
      Toast({ context: this, selector: '#t-toast', message: error.message });
      return;
    }

    this.setData({ loading: true });
    try {
      const result = await login(form.username, form.password, form.captchaCode, form.captchaId);
      const sessionPolicy = (result && result.data && result.data.sessionPolicy) || {};
      const kickedSessionCount = Number(sessionPolicy.kickedSessionCount || 0);
      this.stopLockCountdown();
      this.setData({
        lockInfo: { locked: false, lockUntil: 0, retryAfterSeconds: 0, text: '' }
      });
      const successMessage = kickedSessionCount > 0
        ? `${LOGIN_COPY.loginSuccess}，并已下线 ${kickedSessionCount} 个旧会话`
        : LOGIN_COPY.loginSuccess;
      Toast({ context: this, selector: '#t-toast', message: successMessage, theme: 'success' });
      setTimeout(() => wx.switchTab({ url: '/pages/home/home' }), 500);
    } catch (error) {
      Toast({
        context: this,
        selector: '#t-toast',
        message: this.formatLoginError(error)
      });
      if (this.data.captchaEnabled) {
        await this.refreshCaptcha();
      }
    } finally {
      this.setData({ loading: false });
    }
  },

  fillDemoAccount(e) {
    const { account = '' } = e.currentTarget.dataset;
    if (!account) return;
    this.setData({
      'loginForm.account': account,
      'loginForm.password': '123456'
    });
  }
});
