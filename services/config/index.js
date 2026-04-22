const CONFIG_KEY = 'medical_system_config';
const CONFIG_UPDATED_AT_KEY = 'medical_system_config_updated_at';
const { normalizeBaseUrl } = require('../../config/env');

const CONFIG_SYNC_MIN_INTERVAL = 1500;
let configSyncPromise = null;
let lastConfigSyncAt = 0;

const DEFAULT_CONFIG = {
  clinicName: '诊所',
  contactPhone: '400-888-8888',
  businessHours: '08:00 - 20:00',
  appointmentDays: 7,
  appointmentDuration: 30,
  pendingConfirmTimeoutMinutes: 30,
  patientCancelAdvanceMinutes: 120,
  maxSessionCount: 2,
  kickoutAfterNewLogin: false,
  loginMaxFailCount: 5,
  loginLockMinutes: 5,
  allowUserRegister: false,
  loginMode: 'phone_and_admin',
  apiBaseUrl: '',
  adminBaseUrl: '',
  miniProgramBaseUrl: '',
  tunnelBaseUrl: '',
  experienceDomain: '',
  effectiveApiBaseUrl: '',
  databaseName: '',
  configUpdatedAt: 0,
  aiAssistantEnabled: true,
  aiAssistantName: 'AI 助手',
  aiPromptTemplateGeneral: '你是诊所 AI 助手，请给出清晰、简洁且可执行的回答。',
  aiPromptTemplateBusiness: '你是诊所经营助手，请提供结构化的运营建议，优先给出可落地步骤。',
  aiModelDescriptionDoc: '请在此维护模型说明：适用场景、能力边界、风险与推荐配置。'
};

const USER_ROLES = {
  SUPER_ADMIN: 'super_admin',
  CLINIC_ADMIN: 'clinic_admin',
  DOCTOR: 'doctor',
  PATIENT: 'patient'
};

const ROLE_NAMES = {
  [USER_ROLES.SUPER_ADMIN]: '超级管理员',
  [USER_ROLES.CLINIC_ADMIN]: '诊所管理员',
  [USER_ROLES.DOCTOR]: '医生',
  [USER_ROLES.PATIENT]: '患者'
};

const APPOINTMENT_STATUS = {
  PENDING: 'pending',
  CONFIRMED: 'confirmed',
  COMPLETED: 'completed',
  CANCELLED: 'cancelled',
  EXPIRED: 'expired'
};

const APPOINTMENT_STATUS_NAMES = {
  [APPOINTMENT_STATUS.PENDING]: '待确认',
  [APPOINTMENT_STATUS.CONFIRMED]: '已确认',
  [APPOINTMENT_STATUS.COMPLETED]: '已完成',
  [APPOINTMENT_STATUS.CANCELLED]: '已取消',
  [APPOINTMENT_STATUS.EXPIRED]: '已过期'
};

const STOCK_OPERATION_TYPE = {
  IN: 'in',
  OUT: 'out',
  CHECK: 'check'
};

const GENDER = {
  MALE: 'male',
  FEMALE: 'female',
  OTHER: 'other'
};

const STORAGE_KEYS = {
  USER_INFO: 'user_info',
  TOKEN: 'token',
  CLIENT_KEY: 'client_key',
  REMEMBER_PHONE: 'remember_phone'
};

const resolveConfigUpdatedAt = (config = {}) => {
  const configUpdatedAt = Number(config.configUpdatedAt || 0);
  if (Number.isFinite(configUpdatedAt) && configUpdatedAt > 0) {
    return configUpdatedAt;
  }
  const storedUpdatedAt = Number(wx.getStorageSync(CONFIG_UPDATED_AT_KEY) || 0);
  if (Number.isFinite(storedUpdatedAt) && storedUpdatedAt > 0) {
    return storedUpdatedAt;
  }
  return Date.now();
};

const normalizeNumber = (value, fallback, min, max) => {
  const parsed = Number(value);
  if (!Number.isFinite(parsed)) return fallback;
  const rounded = Math.floor(parsed);
  if (rounded < min) return min;
  if (rounded > max) return max;
  return rounded;
};

const normalizeBoolean = (value, fallback = false) => {
  if (typeof value === 'boolean') return value;
  if (typeof value === 'string') {
    if (value.toLowerCase() === 'true') return true;
    if (value.toLowerCase() === 'false') return false;
  }
  return fallback;
};

const normalizeConfig = (config = {}) => ({
  ...DEFAULT_CONFIG,
  ...config,
  appointmentDays: normalizeNumber(config.appointmentDays, DEFAULT_CONFIG.appointmentDays, 1, 30),
  appointmentDuration: normalizeNumber(config.appointmentDuration, DEFAULT_CONFIG.appointmentDuration, 5, 240),
  pendingConfirmTimeoutMinutes: normalizeNumber(
    config.pendingConfirmTimeoutMinutes,
    DEFAULT_CONFIG.pendingConfirmTimeoutMinutes,
    1,
    1440
  ),
  patientCancelAdvanceMinutes: normalizeNumber(
    config.patientCancelAdvanceMinutes,
    DEFAULT_CONFIG.patientCancelAdvanceMinutes,
    30,
    1440
  ),
  maxSessionCount: normalizeNumber(config.maxSessionCount, DEFAULT_CONFIG.maxSessionCount, 1, 10),
  loginMaxFailCount: normalizeNumber(config.loginMaxFailCount, DEFAULT_CONFIG.loginMaxFailCount, 3, 10),
  loginLockMinutes: normalizeNumber(config.loginLockMinutes, DEFAULT_CONFIG.loginLockMinutes, 1, 120),
  kickoutAfterNewLogin: normalizeBoolean(config.kickoutAfterNewLogin, DEFAULT_CONFIG.kickoutAfterNewLogin),
  allowUserRegister: normalizeBoolean(config.allowUserRegister, DEFAULT_CONFIG.allowUserRegister),
  aiAssistantEnabled: normalizeBoolean(config.aiAssistantEnabled, DEFAULT_CONFIG.aiAssistantEnabled),
  effectiveApiBaseUrl: normalizeBaseUrl(
    config.effectiveApiBaseUrl || config.apiBaseUrl || config.tunnelBaseUrl
  ),
  configUpdatedAt: normalizeNumber(config.configUpdatedAt, DEFAULT_CONFIG.configUpdatedAt, 0, 4102444800000)
});

const getStoredConfig = () => {
  try {
    const app = typeof getApp === 'function' ? getApp() : null;
    if (app && app.globalData && app.globalData.systemConfig) {
      return normalizeConfig(app.globalData.systemConfig || {});
    }
  } catch (error) {
    // ignore app runtime read error
  }

  try {
    const stored = wx.getStorageSync(CONFIG_KEY) || {};
    const storedUpdatedAt = Number(wx.getStorageSync(CONFIG_UPDATED_AT_KEY) || 0);
    if ((!stored.configUpdatedAt || Number(stored.configUpdatedAt) <= 0) && storedUpdatedAt > 0) {
      stored.configUpdatedAt = storedUpdatedAt;
    }
    return normalizeConfig(stored || {});
  } catch (error) {
    return { ...DEFAULT_CONFIG };
  }
};

const saveConfig = (config) => {
  const normalized = normalizeConfig(config);
  const updatedAt = resolveConfigUpdatedAt(normalized);
  normalized.configUpdatedAt = updatedAt;
  wx.setStorageSync(CONFIG_KEY, normalized);
  wx.setStorageSync(CONFIG_UPDATED_AT_KEY, updatedAt);
  try {
    const app = typeof getApp === 'function' ? getApp() : null;
    if (app && app.globalData) {
      app.globalData.systemConfig = normalized;
      app.globalData.systemConfigUpdatedAt = updatedAt;
    }
  } catch (error) {
    // ignore app runtime write error
  }
  return normalized;
};

const publishRuntimeConfig = (config) => {
  const normalized = normalizeConfig(config || {});
  const updatedAt = resolveConfigUpdatedAt(normalized);
  normalized.configUpdatedAt = updatedAt;
  try {
    const app = typeof getApp === 'function' ? getApp() : null;
    if (app && app.globalData) {
      app.globalData.systemConfig = normalized;
      app.globalData.systemConfigUpdatedAt = updatedAt;
      const listeners = Array.isArray(app.globalData.systemConfigListeners)
        ? app.globalData.systemConfigListeners
        : [];
      listeners.forEach((listener) => {
        if (typeof listener === 'function') {
          try {
            listener(normalized);
          } catch (error) {
            // ignore listener errors
          }
        }
      });
    }
  } catch (error) {
    // ignore global publish failures
  }
  return normalized;
};

const subscribeSystemConfig = (listener) => {
  if (typeof listener !== 'function') return () => {};
  try {
    const app = typeof getApp === 'function' ? getApp() : null;
    if (app && app.globalData) {
      app.globalData.systemConfigListeners = Array.isArray(app.globalData.systemConfigListeners)
        ? app.globalData.systemConfigListeners
        : [];
      app.globalData.systemConfigListeners.push(listener);
      return () => {
        try {
          const listeners = app.globalData.systemConfigListeners || [];
          app.globalData.systemConfigListeners = listeners.filter((item) => item !== listener);
        } catch (error) {
          // ignore unsubscribe errors
        }
      };
    }
  } catch (error) {
    // ignore
  }
  return () => {};
};

const getConfigVersion = () => {
  const { get } = require('../_utils/request');
  return get('/api/clinic/config/version')
    .then((res) => {
      const payload = (res && res.data) || {};
      const configUpdatedAt = normalizeNumber(payload.configUpdatedAt, 0, 0, 4102444800000);
      return {
        success: true,
        data: { configUpdatedAt }
      };
    })
    .catch(() => {
      const fallback = getStoredConfig();
      return {
        success: true,
        data: { configUpdatedAt: normalizeNumber(fallback.configUpdatedAt, 0, 0, 4102444800000) }
      };
    });
};

const syncSystemConfig = (options = {}) => {
  const { force = false, silent = false } = options;
  const now = Date.now();
  if (!force) {
    if (configSyncPromise) {
      return configSyncPromise;
    }
    if (lastConfigSyncAt > 0 && now - lastConfigSyncAt < CONFIG_SYNC_MIN_INTERVAL) {
      const cached = getStoredConfig();
      publishRuntimeConfig(cached);
      return Promise.resolve({
        success: true,
        data: cached,
        source: 'cache'
      });
    }
  }

  const { get } = require('../_utils/request');
  configSyncPromise = get('/api/clinic/config/get')
    .then((res) => {
      const normalized = saveConfig(res.data || {});
      publishRuntimeConfig(normalized);
      lastConfigSyncAt = Date.now();
      return {
        success: true,
        data: normalized,
        source: 'remote'
      };
    })
    .catch((error) => {
      const fallback = getStoredConfig();
      publishRuntimeConfig(fallback);
      if (!silent && !normalizeBaseUrl(fallback.effectiveApiBaseUrl || fallback.apiBaseUrl)) {
        throw error;
      }
      return {
        success: true,
        data: fallback,
        source: 'cache',
        error
      };
    })
    .finally(() => {
      configSyncPromise = null;
    });
  return configSyncPromise;
};

const getConfig = () => {
  return syncSystemConfig({ force: true, silent: true }).then((res) => ({
    success: true,
    data: res.data,
    source: res.source
  }));
};

const updateConfig = (updates) => {
  const { post } = require('../_utils/request');
  return post('/api/clinic/config/update', updates).then((res) => {
    const normalized = saveConfig(res.data || { ...getStoredConfig(), ...updates });
    publishRuntimeConfig(normalized);
    return {
      success: true,
      data: normalized
    };
  });
};

module.exports = {
  USER_ROLES,
  ROLE_NAMES,
  APPOINTMENT_STATUS,
  APPOINTMENT_STATUS_NAMES,
  STOCK_OPERATION_TYPE,
  GENDER,
  STORAGE_KEYS,
  DEFAULT_CONFIG,
  CONFIG_KEY,
  CONFIG_UPDATED_AT_KEY,
  getConfigVersion,
  getConfig,
  syncSystemConfig,
  updateConfig,
  getStoredConfig,
  saveConfig,
  normalizeConfig,
  publishRuntimeConfig,
  subscribeSystemConfig
};
