const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser } = require('../../../services/auth/index');
const { USER_ROLES, getConfig, updateConfig } = require('../../../services/config/index');

const URL_FIELDS = ['apiBaseUrl', 'adminBaseUrl', 'miniProgramBaseUrl', 'experienceDomain', 'tunnelBaseUrl'];
const LOCAL_HOST_PATTERN = /(localhost|127\.0\.0\.1|0\.0\.0\.0)/i;

const isDevelopEnv = () => {
  try {
    const accountInfo = wx.getAccountInfoSync();
    return accountInfo && accountInfo.miniProgram && accountInfo.miniProgram.envVersion === 'develop';
  } catch (error) {
    return false;
  }
};

const normalizeUrl = (value, options = {}) => {
  const { allowLocalAddress = false } = options;
  const raw = String(value || '').trim().replace(/\/+$/, '');
  if (!raw) return '';
  let normalized = raw;
  if (!/^https?:\/\//i.test(normalized)) {
    if (!/^[\w.-]+(?::\d+)?(?:\/.*)?$/i.test(normalized)) {
      return null;
    }
    normalized = `${LOCAL_HOST_PATTERN.test(normalized) ? 'http' : 'https'}://${normalized}`;
  }
  if (!/^https?:\/\//i.test(normalized)) return null;
  const isLocalAddress = LOCAL_HOST_PATTERN.test(normalized);
  if (!allowLocalAddress && isLocalAddress) return null;
  if (!allowLocalAddress && !/^https:\/\//i.test(normalized)) return null;
  return normalized;
};

const CONFIG_SCHEMA = [
  { id: 'clinicName', name: '诊所名称', key: 'clinicName', type: 'text' },
  { id: 'contactPhone', name: '联系电话', key: 'contactPhone', type: 'text' },
  { id: 'businessHours', name: '营业时间', key: 'businessHours', type: 'text' },
  { id: 'appointmentDays', name: '可预约天数', key: 'appointmentDays', type: 'number' },
  { id: 'appointmentDuration', name: '预约时长(分钟)', key: 'appointmentDuration', type: 'number' },
  { id: 'pendingConfirmTimeoutMinutes', name: '待确认超时(分钟)', key: 'pendingConfirmTimeoutMinutes', type: 'number' },
  { id: 'patientCancelAdvanceMinutes', name: '患者取消提前(分钟)', key: 'patientCancelAdvanceMinutes', type: 'number' },
  { id: 'maxSessionCount', name: '最大并发会话数', key: 'maxSessionCount', type: 'number' },
  { id: 'kickoutAfterNewLogin', name: '超限时踢出新登录', key: 'kickoutAfterNewLogin', type: 'switch' },
  { id: 'loginMaxFailCount', name: '登录失败阈值(次)', key: 'loginMaxFailCount', type: 'number' },
  { id: 'loginLockMinutes', name: '登录锁定时长(分钟)', key: 'loginLockMinutes', type: 'number' },
  { id: 'allowUserRegister', name: '允许自助注册', key: 'allowUserRegister', type: 'switch' },
  { id: 'loginMode', name: '登录模式(固定)', key: 'loginMode', type: 'text' },
  { id: 'apiBaseUrl', name: '小程序 API 地址', key: 'apiBaseUrl', type: 'text' },
  { id: 'adminBaseUrl', name: '后台地址', key: 'adminBaseUrl', type: 'text' },
  { id: 'miniProgramBaseUrl', name: '小程序访问地址', key: 'miniProgramBaseUrl', type: 'text' },
  { id: 'experienceDomain', name: '体验版域名', key: 'experienceDomain', type: 'text' },
  { id: 'tunnelBaseUrl', name: '内网穿透地址', key: 'tunnelBaseUrl', type: 'text' },
  { id: 'databaseName', name: '数据库名称', key: 'databaseName', type: 'text' },
  { id: 'aiAssistantEnabled', name: '启用 AI 助手', key: 'aiAssistantEnabled', type: 'switch' },
  { id: 'aiAssistantName', name: 'AI 助手名称', key: 'aiAssistantName', type: 'text' },
  { id: 'aiPromptTemplateGeneral', name: 'AI 通用提示词', key: 'aiPromptTemplateGeneral', type: 'textarea' },
  { id: 'aiPromptTemplateBusiness', name: 'AI 业务提示词', key: 'aiPromptTemplateBusiness', type: 'textarea' },
  { id: 'aiModelDescriptionDoc', name: 'AI 模型说明', key: 'aiModelDescriptionDoc', type: 'textarea' }
];

Page({
  data: {
    uiState: 'loading',
    errorText: '',
    configList: CONFIG_SCHEMA.map((item) => ({ ...item, value: item.type === 'switch' ? false : '' })),
    loading: false
  },

  onLoad() {
    this.initPage();
  },

  async initPage() {
    this.setData({ uiState: 'loading', errorText: '' });
    const userInfo = getCurrentUser();
    if (!userInfo) {
      wx.redirectTo({ url: '/pages/login/index' });
      return;
    }

    const isAdmin =
      userInfo.role === USER_ROLES.SUPER_ADMIN || userInfo.role === USER_ROLES.CLINIC_ADMIN;
    if (!isAdmin) {
      wx.showToast({ title: '暂无权限', icon: 'none' });
      setTimeout(() => wx.navigateBack(), 1000);
      return;
    }

    await this.loadConfig();
  },

  async loadConfig() {
    try {
      const res = await getConfig();
      const data = (res && res.data) || {};
      const configList = CONFIG_SCHEMA.map((item) => ({
        ...item,
        value: data[item.key] !== undefined ? data[item.key] : item.type === 'switch' ? false : ''
      }));
      this.setData({ configList, uiState: 'ready' });
    } catch (error) {
      const message = error.message || '配置加载失败';
      this.setData({ uiState: 'error', errorText: message });
      Toast({ context: this, selector: '#t-toast', message });
    }
  },

  onConfigChange(e) {
    const { index } = e.currentTarget.dataset;
    if (index === undefined) return;
    const list = [...this.data.configList];
    const field = list[index];
    if (!field) return;

    const detail = e.detail;
    let value = detail;
    if (detail && typeof detail === 'object' && Object.prototype.hasOwnProperty.call(detail, 'value')) {
      value = detail.value;
    }

    if (field.type === 'number') {
      value = value === '' || value === null || value === undefined ? '' : Number(value);
    } else if (field.type === 'switch') {
      value = !!value;
    } else {
      value = value == null ? '' : String(value);
    }

    list[index] = { ...field, value };
    this.setData({ configList: list });
  },

  validateNumber(item, value) {
    if (item.key === 'appointmentDays' && (value < 1 || value > 30)) {
      return '可预约天数必须在 1 到 30 之间';
    }
    if (item.key === 'appointmentDuration' && (value < 5 || value > 240)) {
      return '预约时长必须在 5 到 240 分钟之间';
    }
    if (item.key === 'pendingConfirmTimeoutMinutes' && (value < 1 || value > 1440)) {
      return '待确认超时必须在 1 到 1440 分钟之间';
    }
    if (item.key === 'patientCancelAdvanceMinutes' && (value < 30 || value > 1440)) {
      return '患者取消提前时间必须在 30 到 1440 分钟之间';
    }
    if (item.key === 'maxSessionCount' && (value < 1 || value > 10)) {
      return '最大并发会话数必须在 1 到 10 之间';
    }
    if (item.key === 'loginMaxFailCount' && (value < 3 || value > 10)) {
      return '登录失败阈值必须在 3 到 10 次之间';
    }
    if (item.key === 'loginLockMinutes' && (value < 1 || value > 120)) {
      return '登录锁定时长必须在 1 到 120 分钟之间';
    }
    return '';
  },

  buildUpdates() {
    const updates = {};
    const allowLocalAddress = isDevelopEnv();
    for (const item of this.data.configList) {
      let value = item.value;

      if (item.type === 'text' || item.type === 'textarea') {
        value = String(value || '').trim();
      }

      if (item.type === 'number') {
        const num = Number(value);
        if (!Number.isFinite(num)) {
          throw new Error(`${item.name} 必须是有效数字`);
        }
        value = Math.floor(num);
        const numberError = this.validateNumber(item, value);
        if (numberError) {
          throw new Error(numberError);
        }
      }

      if (URL_FIELDS.includes(item.key)) {
        const normalized = normalizeUrl(value, { allowLocalAddress });
        if (normalized === null) {
          if (allowLocalAddress) {
            throw new Error(`${item.name} 必须是有效地址（支持 http/https，本地开发可使用 localhost）`);
          }
          throw new Error(`${item.name} 必须是有效 https 地址，且不能使用 localhost`);
        }
        value = normalized;
      }

      if (item.key === 'loginMode') {
        value = 'phone_and_admin';
      }
      updates[item.key] = value;
    }
    if (!updates.apiBaseUrl && !updates.tunnelBaseUrl) {
      throw new Error('小程序 API 地址与内网穿透地址至少配置一项');
    }
    return updates;
  },

  async saveConfig() {
    if (this.data.loading) return;
    let updates = {};
    try {
      updates = this.buildUpdates();
    } catch (error) {
      Toast({ context: this, selector: '#t-toast', message: error.message });
      return;
    }

    this.setData({ loading: true });
    try {
      await updateConfig(updates);
      await this.loadConfig();
      Toast({
        context: this,
        selector: '#t-toast',
        message: '保存成功，配置已同步生效',
        theme: 'success'
      });
    } catch (error) {
      Toast({
        context: this,
        selector: '#t-toast',
        message: error.message || '保存失败'
      });
    } finally {
      this.setData({ loading: false });
    }
  },

  retryLoad() {
    this.initPage();
  }
});
