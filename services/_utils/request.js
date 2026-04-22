const { STORAGE_KEYS, getStoredConfig } = require('../config/index');
const {
  getApiBaseUrl,
  getBootstrapBaseUrl
} = require('../../config/env');

const DEFAULT_TIMEOUT = 15000;
let isHandling401 = false;

const ERROR_TYPE = {
  TIMEOUT: 'timeout',
  NETWORK: 'network',
  UNAUTH: 'unauth',
  SERVER: 'server',
  BUSINESS: 'business',
  FORBIDDEN: 'forbidden',
  KICKOUT: 'kickout'
};

const KICKOUT_ERROR_TYPES = ['ACCOUNT_KICKOUT', 'KICKOUT', 'FORCED_LOGOUT'];

const getMissingApiAddressMessage = () => {
  const systemConfig = getStoredConfig();
  const systemApiBaseUrl = systemConfig.effectiveApiBaseUrl || systemConfig.apiBaseUrl || systemConfig.tunnelBaseUrl || '';
  const bootstrapBaseUrl = getBootstrapBaseUrl();

  if (systemApiBaseUrl) {
    return '当前系统配置中的小程序接口地址暂时不可用，请确认后台服务已启动，并检查系统配置中的“小程序 API 地址”。';
  }
  if (bootstrapBaseUrl) {
    return '当前无法读取最新系统配置，请确认部署时提供的小程序接口地址可访问，然后重新打开小程序。';
  }
  return '当前未配置可用的小程序接口地址，请先在后台系统配置中填写“小程序 API 地址”。';
};

const isPermissionDeniedMessage = (msg = '') => {
  if (!msg) return false;
  return /forbidden|permission denied|no permission|unauthorized|暂无权限|权限不足|无权|禁止访问/i.test(String(msg));
};

const isKickoutMessage = (msg = '') => {
  if (!msg) return false;
  return /kickout|login elsewhere|session invalid|forced logout|relogin required|其他设备登录|异地登录|会话失效|强制下线|重新登录|已下线/i.test(String(msg));
};

const getRequestUrl = (path) => {
  if (/^https?:\/\//.test(path)) {
    return path;
  }
  const baseUrl = getApiBaseUrl();
  return baseUrl ? `${baseUrl}${path}` : '';
};

const createNonce = () => `${Date.now()}_${Math.random().toString(36).slice(2, 10)}`;

const navigateToLogin = () => {
  wx.reLaunch({
    url: '/pages/login/index',
    fail: () => {
      wx.redirectTo({ url: '/pages/login/index' });
    }
  });
};

const clearAuthStorage = () => {
  wx.removeStorageSync(STORAGE_KEYS.TOKEN);
  wx.removeStorageSync(STORAGE_KEYS.USER_INFO);
  wx.removeStorageSync(STORAGE_KEYS.CLIENT_KEY);
};

const handle401 = (message = '登录已失效，请重新登录') => {
  if (isHandling401) return;
  isHandling401 = true;

  clearAuthStorage();
  wx.showToast({ title: message, icon: 'none' });

  setTimeout(() => {
    navigateToLogin();
    isHandling401 = false;
  }, 1200);
};

const request = (options) =>
  new Promise((resolve, reject) => {
    const requestUrl = getRequestUrl(options.url);
    if (!requestUrl) {
      const err = new Error(getMissingApiAddressMessage());
      err.type = ERROR_TYPE.BUSINESS;
      reject(err);
      return;
    }

    const token = wx.getStorageSync(STORAGE_KEYS.TOKEN);
    const clientKey = wx.getStorageSync(STORAGE_KEYS.CLIENT_KEY);
    const timeout = options.timeout || DEFAULT_TIMEOUT;
    const timestamp = Math.floor(Date.now() / 1000);
    const nonce = createNonce();

    let timeoutTimer = null;
    let isRequestCompleted = false;

    timeoutTimer = setTimeout(() => {
      if (isRequestCompleted) return;
      isRequestCompleted = true;
      const err = new Error(`请求超时：${requestUrl}`);
      err.type = ERROR_TYPE.TIMEOUT;
      reject(err);
    }, timeout);

    wx.request({
      url: requestUrl,
      method: options.method || 'GET',
      data: options.data || {},
      timeout,
      header: {
        'Content-Type': 'application/json',
        ...(token ? { Authorization: token, 'X-Api-Token': token } : {}),
        ...(clientKey ? { 'X-Client-Key': clientKey } : {}),
        'X-Nonce': nonce,
        'X-Timestamp': String(timestamp),
        ...options.header
      },
      success: (res) => {
        if (isRequestCompleted) return;
        isRequestCompleted = true;
        clearTimeout(timeoutTimer);

        const message = res.data && (res.data.msg || res.data.message)
          ? String(res.data.msg || res.data.message)
          : '';

        if (res.statusCode === 200) {
          const payload = res.data && res.data.data != null ? res.data.data : res.data;
          const code = res.data && res.data.code;
          const isOkCode = code === 0 || code === 200;

          if (isOkCode || res.data.success) {
            if (payload && payload.token) wx.setStorageSync(STORAGE_KEYS.TOKEN, payload.token);
            if (payload && payload.clientKey) wx.setStorageSync(STORAGE_KEYS.CLIENT_KEY, payload.clientKey);
            resolve({ success: true, data: payload });
            return;
          }

          const err = new Error(message || '请求失败');
          err.code = code;
          err.errorType = res.data && res.data.errorType ? res.data.errorType : '';
          err.payload = res.data || {};
          if (isKickoutMessage(message)) err.type = ERROR_TYPE.KICKOUT;
          else if (isPermissionDeniedMessage(message)) err.type = ERROR_TYPE.FORBIDDEN;
          else err.type = ERROR_TYPE.BUSINESS;
          reject(err);
          return;
        }

        if (res.statusCode === 401) {
          handle401('登录已失效，请重新登录');
          const err = new Error('登录已失效，请重新登录');
          err.type = ERROR_TYPE.UNAUTH;
          reject(err);
          return;
        }

        if (res.statusCode === 403) {
          const backendErrorType = res.data && res.data.errorType ? String(res.data.errorType) : '';
          if (KICKOUT_ERROR_TYPES.includes(backendErrorType) || isKickoutMessage(message)) {
            handle401('账号已在其他设备登录，请重新登录');
            const err = new Error(message || '账号已在其他设备登录，请重新登录');
            err.type = ERROR_TYPE.KICKOUT;
            err.payload = res.data || {};
            err.errorType = backendErrorType;
            reject(err);
            return;
          }

          const err = new Error(message || '暂无权限访问该资源');
          err.type = ERROR_TYPE.FORBIDDEN;
          err.payload = res.data || {};
          reject(err);
          return;
        }

        if (res.statusCode >= 500) {
          const err = new Error(message || '系统繁忙，请稍后重试');
          err.type = ERROR_TYPE.SERVER;
          err.payload = res.data || {};
          reject(err);
          return;
        }

        const err = new Error(message || `请求失败：${res.statusCode}`);
        err.type = ERROR_TYPE.BUSINESS;
        err.payload = res.data || {};
        reject(err);
      },
      fail: (err) => {
        if (isRequestCompleted) return;
        isRequestCompleted = true;
        clearTimeout(timeoutTimer);
        const msg = err && err.errMsg ? String(err.errMsg) : 'network error';
        const error = new Error(`网络请求失败：${msg}`);
        error.type = ERROR_TYPE.NETWORK;
        reject(error);
      }
    });
  });

const get = (url, data, options = {}) => request({ ...options, url, method: 'GET', data });
const post = (url, data, options = {}) => request({ ...options, url, method: 'POST', data });
const put = (url, data, options = {}) => request({ ...options, url, method: 'PUT', data });
const del = (url, data, options = {}) => request({ ...options, url, method: 'DELETE', data });

module.exports = {
  ERROR_TYPE,
  getRequestUrl,
  request,
  get,
  post,
  put,
  del
};
