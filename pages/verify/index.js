const Toast = require('tdesign-miniprogram/toast/index').default;
const {
  LOGIN_COPY,
  getPasswordMinLengthText,
  register,
  USER_ROLES
} = require('../../services/auth/index');

const PHONE_PATTERN = /^1\d{10}$/;

Page({
  data: {
    phone: '',
    password: '',
    confirmPassword: '',
    loading: false,
    stateMode: 'loading',
    stateTitle: '页面加载中',
    stateDescription: '',
    stateButtonText: '重试',
    retryAction: 'retry'
  },

  onLoad(options = {}) {
    this.lastOptions = options;
    this.initPage(options);
  },

  setAsyncState(mode, title, description = '', buttonText = '重试') {
    this.setData({
      stateMode: mode,
      stateTitle: title,
      stateDescription: description,
      stateButtonText: buttonText
    });
  },

  initPage(options = {}) {
    this.setData({ retryAction: 'retry' });
    this.setAsyncState('loading', '页面加载中', '请稍候...');

    try {
      const phone = String(options.phone || '').trim();
      if (!PHONE_PATTERN.test(phone)) {
        this.setData({ retryAction: 'login' });
        this.setAsyncState('error', '手机号无效', '请返回登录页重新获取验证码并注册。', '去登录');
        return;
      }

      this.setData({ phone, stateMode: 'success' });
      this.setAsyncState('success', '', '');
    } catch (error) {
      this.setData({ retryAction: 'retry' });
      this.setAsyncState(
        'error',
        '页面初始化失败',
        (error && error.message) || '请稍后重试。',
        '重试'
      );
    }
  },

  onStateRetry() {
    if (this.data.retryAction === 'login') {
      wx.redirectTo({ url: '/pages/login/index' });
      return;
    }
    this.initPage(this.lastOptions || {});
  },

  onPasswordChange(e) {
    this.setData({ password: e.detail.value || '' });
  },

  onConfirmPasswordChange(e) {
    this.setData({ confirmPassword: e.detail.value || '' });
  },

  async handleVerify() {
    if (this.data.stateMode !== 'success' || this.data.loading) return;

    const { phone, password, confirmPassword } = this.data;
    if (!phone || !PHONE_PATTERN.test(String(phone).trim())) {
      Toast({
        context: this,
        selector: '#t-toast',
        message: `${LOGIN_COPY.phoneInvalid}，请返回登录页重新注册。`
      });
      return;
    }
    if (!password) {
      Toast({ context: this, selector: '#t-toast', message: '请设置登录密码' });
      return;
    }
    if (String(password).length < 6) {
      Toast({ context: this, selector: '#t-toast', message: getPasswordMinLengthText(6) });
      return;
    }
    if (password !== confirmPassword) {
      Toast({ context: this, selector: '#t-toast', message: '两次输入的密码不一致' });
      return;
    }

    this.setData({ loading: true });
    try {
      await register({
        phone,
        name: `用户${String(phone).slice(-4)}`,
        role: USER_ROLES.PATIENT,
        password
      });

      Toast({ context: this, selector: '#t-toast', message: '注册成功', theme: 'success' });
      setTimeout(() => {
        wx.switchTab({ url: '/pages/home/home' });
      }, 1000);
    } catch (error) {
      Toast({ context: this, selector: '#t-toast', message: (error && error.message) || '注册失败' });
    } finally {
      this.setData({ loading: false });
    }
  }
});
