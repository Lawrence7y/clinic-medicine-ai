const STORAGE_KEYS = {
  SYSTEM_CONFIG: 'medical_system_config'
};

const PLACEHOLDER_BASE_URLS = new Set([
  'https://your-staging-api-domain.com',
  'https://your-api-domain.com'
]);
const LOCAL_HOST_PATTERN = /^(localhost|127(?:\.\d{1,3}){3}|0\.0\.0\.0)$/i;

const ENVIRONMENTS = {
  develop: {
    label: 'development',
    baseUrl: 'http://192.168.124.7:8090'
  },
  trial: {
    label: 'staging',
    baseUrl: ''
  },
  release: {
    label: 'production',
    baseUrl: ''
  }
};

const DEFAULT_ENV = 'develop';

const extractHost = (value = '') => {
  const normalized = String(value || '').trim().replace(/^https?:\/\//i, '');
  const hostWithPort = normalized.split('/')[0] || '';
  return hostWithPort.split(':')[0] || '';
};

const isLocalHostLike = (value = '') => LOCAL_HOST_PATTERN.test(extractHost(value));

const getMiniProgramEnvVersion = () => {
  try {
    const accountInfo = wx.getAccountInfoSync();
    return accountInfo && accountInfo.miniProgram && accountInfo.miniProgram.envVersion
      ? accountInfo.miniProgram.envVersion
      : DEFAULT_ENV;
  } catch (error) {
    return DEFAULT_ENV;
  }
};

const normalizeBaseUrl = (value) => {
  let normalized = typeof value === 'string' ? value.trim().replace(/\/+$/, '') : '';
  if (normalized && !/^https?:\/\//i.test(normalized) && /^[\w.-]+(?::\d+)?(?:\/.*)?$/i.test(normalized)) {
    normalized = `${isLocalHostLike(normalized) ? 'http' : 'https'}://${normalized}`;
  }
  if (!normalized || PLACEHOLDER_BASE_URLS.has(normalized)) {
    return '';
  }
  return normalized;
};

const getExtConfig = () => {
  try {
    return typeof wx.getExtConfigSync === 'function' ? (wx.getExtConfigSync() || {}) : {};
  } catch (error) {
    return {};
  }
};

const getBootstrapBaseUrl = () => {
  const extConfig = getExtConfig();
  const extSystemConfig = extConfig && typeof extConfig.systemConfig === 'object' ? extConfig.systemConfig : {};
  return (
    normalizeBaseUrl(extSystemConfig.effectiveApiBaseUrl) ||
    normalizeBaseUrl(extSystemConfig.apiBaseUrl) ||
    normalizeBaseUrl(extSystemConfig.tunnelBaseUrl) ||
    normalizeBaseUrl(extConfig.apiBaseUrl) ||
    normalizeBaseUrl(extConfig.tunnelBaseUrl) ||
    normalizeBaseUrl(extConfig.bootstrapApiBaseUrl)
  );
};

const getEnvironmentProfile = () => {
  const envVersion = getMiniProgramEnvVersion();
  const fallbackProfile = ENVIRONMENTS[envVersion] || ENVIRONMENTS[DEFAULT_ENV];
  return {
    ...fallbackProfile,
    baseUrl: getBootstrapBaseUrl() || normalizeBaseUrl(fallbackProfile.baseUrl)
  };
};

const getRuntimeSystemConfig = () => {
  try {
    const app = typeof getApp === 'function' ? getApp() : null;
    if (app && app.globalData && app.globalData.systemConfig) {
      return app.globalData.systemConfig;
    }
  } catch (error) {
    // ignore runtime read error
  }

  try {
    return wx.getStorageSync(STORAGE_KEYS.SYSTEM_CONFIG) || {};
  } catch (error) {
    return {};
  }
};

const getSystemConfigBaseUrl = () => {
  try {
    const systemConfig = getRuntimeSystemConfig();
    return normalizeBaseUrl(
      systemConfig.effectiveApiBaseUrl || systemConfig.apiBaseUrl || systemConfig.tunnelBaseUrl
    );
  } catch (error) {
    return '';
  }
};

const getApiBaseUrl = () => {
  return getSystemConfigBaseUrl() || getBootstrapBaseUrl() || getEnvironmentProfile().baseUrl;
};

module.exports = {
  ENVIRONMENTS,
  STORAGE_KEYS,
  normalizeBaseUrl,
  getMiniProgramEnvVersion,
  getEnvironmentProfile,
  getBootstrapBaseUrl,
  getSystemConfigBaseUrl,
  getApiBaseUrl
};
