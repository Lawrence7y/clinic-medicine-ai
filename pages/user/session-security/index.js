const Toast = require('tdesign-miniprogram/toast/index').default;
const { getSessionList, kickoutSession, kickoutOtherSessions } = require('../../../services/auth/index');

const AUTO_REFRESH_INTERVAL = 15000;

Page({
  data: {
    uiState: 'loading',
    errorText: '',
    loading: false,
    sessions: [],
    currentSessionId: '',
    total: 0,
    maxSessionCount: 2,
    kickoutAfterNewLogin: false,
    policyText: '',
    lastUpdatedText: '',
    noticeText: '',
    noticeTheme: 'info',
    texts: {
      loadFailed: '加载登录会话失败',
      permissionDenied: '暂无权限查看会话安全信息',
      sessionInvalid: '当前登录会话已失效，请重新登录',
      forceKickTitle: '强制下线',
      forceKickOthersConfirm: '确认强制下线其他设备吗？',
      forceKickOneConfirm: '确认下线该设备会话吗？',
      kickOthersSuccess: '已下线 {count} 个会话',
      kickOthersEmpty: '没有其他在线会话',
      kickSessionSuccess: '会话已下线',
      kickFailed: '操作失败，请稍后重试'
    }
  },

  onLoad(options = {}) {
    if (options.reason === 'session_invalid' || options.reason === 'kickout' || options.reason === 'login_elsewhere') {
      this.setData({
        noticeTheme: 'warning',
        noticeText: this.data.texts.sessionInvalid
      });
    }
    this.loadSessions();
  },

  onShow() {
    this.startAutoRefresh();
    this.loadSessions({ silent: true });
  },

  onHide() {
    this.stopAutoRefresh();
  },

  onUnload() {
    this.stopAutoRefresh();
  },

  onPullDownRefresh() {
    this.loadSessions().finally(() => wx.stopPullDownRefresh());
  },

  startAutoRefresh() {
    this.stopAutoRefresh();
    this.autoRefreshTimer = setInterval(() => {
      this.loadSessions({ silent: true });
    }, AUTO_REFRESH_INTERVAL);
  },

  stopAutoRefresh() {
    if (this.autoRefreshTimer) {
      clearInterval(this.autoRefreshTimer);
      this.autoRefreshTimer = null;
    }
  },

  async loadSessions({ silent = false } = {}) {
    if (this.data.loading) return;
    this.setData({
      loading: true,
      uiState: silent && this.data.uiState === 'ready' ? 'ready' : 'loading',
      errorText: silent ? this.data.errorText : ''
    });
    try {
      const res = await getSessionList();
      const payload = (res && res.data) || {};
      const sessions = (Array.isArray(payload.sessions) ? payload.sessions : []).map((item) => this.normalizeSession(item));
      const maxSessionCount = Number(payload.maxSessionCount || 2);
      const kickoutAfterNewLogin = !!payload.kickoutAfterNewLogin;

      this.setData({
        uiState: 'ready',
        sessions,
        currentSessionId: payload.currentSessionId || '',
        total: Number(payload.total || sessions.length),
        maxSessionCount,
        kickoutAfterNewLogin,
        policyText: this.formatPolicyText(maxSessionCount, kickoutAfterNewLogin),
        lastUpdatedText: this.formatNow()
      });
    } catch (error) {
      this.setData({
        uiState: 'error',
        errorText: this.normalizeErrorMessage(error, this.data.texts.loadFailed)
      });
    } finally {
      this.setData({ loading: false });
    }
  },

  normalizeSession(session = {}) {
    const isCurrent = !!session.current;
    return {
      ...session,
      current: isCurrent,
      deviceText: this.formatDevice(session),
      loginLocationText: session.loginLocation || '-',
      ipText: session.ipaddr || '-',
      startTimeText: this.formatTime(session.startTimestamp),
      lastAccessTimeText: this.formatTime(session.lastAccessTime),
      expireTimeText: this.formatTime(session.expireTime),
      statusTagTheme: isCurrent ? 'success' : 'default',
      statusText: isCurrent ? '当前设备' : '在线会话'
    };
  },

  retryLoad() {
    this.loadSessions();
  },

  handleRefresh() {
    this.loadSessions({ silent: true });
  },

  formatDevice(session = {}) {
    const browser = session.browser || '未知浏览器';
    const os = session.os || '未知系统';
    return `${browser} / ${os}`;
  },

  formatPolicyText(maxSessionCount, kickoutAfterNewLogin) {
    const count = Number.isFinite(maxSessionCount) ? maxSessionCount : 2;
    if (kickoutAfterNewLogin) {
      return `最多保留 ${count} 个会话，超出时自动下线最早登录设备。`;
    }
    return `最多保留 ${count} 个会话，达到上限后将禁止新设备登录。`;
  },

  formatTime(value) {
    if (!value) return '-';
    if (typeof value === 'string') return value;
    const date = new Date(value);
    if (Number.isNaN(date.getTime())) return String(value);
    const y = date.getFullYear();
    const m = `${date.getMonth() + 1}`.padStart(2, '0');
    const d = `${date.getDate()}`.padStart(2, '0');
    const hh = `${date.getHours()}`.padStart(2, '0');
    const mm = `${date.getMinutes()}`.padStart(2, '0');
    const ss = `${date.getSeconds()}`.padStart(2, '0');
    return `${y}-${m}-${d} ${hh}:${mm}:${ss}`;
  },

  formatNow() {
    return this.formatTime(Date.now());
  },

  normalizeErrorMessage(error, fallback) {
    if (!error) return fallback;
    if (error.type === 'forbidden') return this.data.texts.permissionDenied;
    if (error.type === 'kickout' || error.type === 'unauth') return this.data.texts.sessionInvalid;
    return error.message || fallback;
  },

  async handleKickOthers() {
    wx.showModal({
      title: this.data.texts.forceKickTitle,
      content: this.data.texts.forceKickOthersConfirm,
      success: async (res) => {
        if (!res.confirm) return;
        this.setData({ loading: true });
        try {
          const result = await kickoutOtherSessions();
          const kickedCount = result?.data?.kickedCount ? Number(result.data.kickedCount) : 0;
          const message = kickedCount > 0
            ? this.data.texts.kickOthersSuccess.replace('{count}', String(kickedCount))
            : this.data.texts.kickOthersEmpty;
          Toast({
            context: this,
            selector: '#t-toast',
            message,
            theme: 'success'
          });
          this.setData({
            noticeTheme: 'success',
            noticeText: message
          });
          this.loadSessions({ silent: true });
        } catch (error) {
          Toast({
            context: this,
            selector: '#t-toast',
            message: this.normalizeErrorMessage(error, this.data.texts.kickFailed)
          });
        } finally {
          this.setData({ loading: false });
        }
      }
    });
  },

  handleKickSession(e) {
    const { sessionId, current } = e.currentTarget.dataset;
    if (!sessionId || current) return;
    wx.showModal({
      title: this.data.texts.forceKickTitle,
      content: this.data.texts.forceKickOneConfirm,
      success: async (res) => {
        if (!res.confirm) return;
        this.setData({ loading: true });
        try {
          await kickoutSession(sessionId);
          Toast({
            context: this,
            selector: '#t-toast',
            message: this.data.texts.kickSessionSuccess,
            theme: 'success'
          });
          this.setData({
            noticeTheme: 'success',
            noticeText: this.data.texts.kickSessionSuccess
          });
          this.loadSessions({ silent: true });
        } catch (error) {
          Toast({
            context: this,
            selector: '#t-toast',
            message: this.normalizeErrorMessage(error, this.data.texts.kickFailed)
          });
        } finally {
          this.setData({ loading: false });
        }
      }
    });
  }
});
