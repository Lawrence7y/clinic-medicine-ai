const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser } = require('../../../services/auth/index');
const {
  USER_ROLES,
  getStoredConfig,
  subscribeSystemConfig,
  syncSystemConfig
} = require('../../../services/config/index');
const {
  AI_ROUTES,
  buildAiChatPath,
  buildMedicineConsultContext,
  pushRecentAiFeature,
  resolveAiAssistantName
} = require('../../../services/ai/index');
const { getMedicineDetail, getUsageRecords } = require('../../../services/medicine/index');

const EXPIRY_WARNING_DAYS = 30;

Page({
  data: {
    uiState: 'loading',
    errorMessage: '',
    medicineId: '',
    medicineInfo: {
      name: '',
      specification: '',
      dosageForm: '',
      expiryDate: '',
      nearestBatchExpiryDate: '',
      price: '',
      stock: 0,
      warningThreshold: 10,
      warningStock: 10,
      pharmacology: '',
      indications: '',
      dosage: '',
      sideEffects: ''
    },
    recentUsage: [],
    isAdmin: false,
    isDoctor: false,
    systemConfig: {},
    expiryReminder: {
      show: false,
      expired: false,
      daysToExpiry: null,
      text: ''
    },
    texts: {
      invalidMedicineId: '药品编号无效',
      loadFailed: '药品详情加载失败',
      loading: '加载中...',
      retry: '重试',
      loadFailedCommon: '加载失败，请稍后重试。',
      expiredHint: '该药品已过期，请勿使用。',
      expiresIn: '该药品将在',
      days: '天后过期。',
      basicInfo: '基础信息',
      name: '名称',
      prescriptionTag: '处方药',
      nonPrescriptionTag: '非处方药',
      specification: '规格',
      dosageForm: '剂型',
      location: '存放位置',
      price: '价格',
      currencyUnit: '元',
      inventoryInfo: '库存信息',
      stock: '库存',
      stockStatus: '库存状态',
      noStock: '无库存',
      lowStock: '库存偏低',
      inStock: '库存充足',
      warningThreshold: '预警阈值',
      nearestExpiry: '最近有效期',
      clinicalInfo: '临床信息',
      pharmacology: '药理作用',
      indications: '适应症',
      dosageText: '用法用量',
      sideEffects: '不良反应',
      recentUsage: '最近用药记录',
      viewAll: '查看全部',
      amount: '数量：',
      doctor: '医生：',
      emptyUsage: '暂无用药记录',
      editMedicine: '编辑药品',
      batchManage: '批次管理',
      stockIn: '入库',
      continueAskAi: '继续问 AI 助手',
      medicineAiAssistant: '药品 AI 助手',
      medicineConsult: '药品咨询',
      medicine: '药品'
    }
  },

  onLoad(options = {}) {
    this._configSyncWarned = false;
    this.applySystemConfig(getStoredConfig());
    this.subscribeConfigUpdates();
    this.syncSystemConfig().catch(() => {});
    if (!options.id) {
      Toast({ context: this, selector: '#t-toast', message: this.data.texts.invalidMedicineId });
      setTimeout(() => wx.navigateBack(), 1000);
      return;
    }
    this.setData({ medicineId: options.id });
    this.initPage();
  },

  onUnload() {
    if (typeof this._unsubscribeConfig === 'function') {
      this._unsubscribeConfig();
      this._unsubscribeConfig = null;
    }
  },

  async initPage() {
    const currentUser = getCurrentUser();
    if (!currentUser) {
      wx.redirectTo({ url: '/pages/login/index' });
      return;
    }

    const isAdmin = currentUser.role === USER_ROLES.SUPER_ADMIN || currentUser.role === USER_ROLES.CLINIC_ADMIN;
    const isDoctor = currentUser.role === USER_ROLES.DOCTOR;
    this.setData({ isAdmin, isDoctor });
    await this.loadData();
  },

  subscribeConfigUpdates() {
    if (typeof this._unsubscribeConfig === 'function') return;
    this._unsubscribeConfig = subscribeSystemConfig((config) => {
      this.applySystemConfig(config || {});
    });
  },

  applySystemConfig(config = {}) {
    this.setData({ systemConfig: config || {} });
  },

  async syncSystemConfig() {
    try {
      const res = await syncSystemConfig({ silent: true });
      this.applySystemConfig((res && res.data) || getStoredConfig());
      if (res && res.error && !this._configSyncWarned) {
        this._configSyncWarned = true;
        Toast({
          context: this,
          selector: '#t-toast',
          message: '配置同步失败，已使用本地配置'
        });
      }
      return res;
    } catch (error) {
      const fallback = getStoredConfig();
      this.applySystemConfig(fallback);
      if (!this._configSyncWarned) {
        this._configSyncWarned = true;
        Toast({
          context: this,
          selector: '#t-toast',
          message: '配置同步失败，已使用本地配置'
        });
      }
      return { success: true, data: fallback, source: 'cache', error };
    }
  },

  async loadData() {
    this.setData({ uiState: 'loading', errorMessage: '' });
    try {
      const response = await getMedicineDetail(this.data.medicineId);
      const medicineInfo = response.data || {};
      const expirySource = medicineInfo.nearestBatchExpiryDate || medicineInfo.expiryDate;
      this.setData({
        medicineInfo,
        expiryReminder: this.buildExpiryReminder(expirySource),
        uiState: 'ready'
      });
      await this.loadRecentUsage();
    } catch (error) {
      const errorMessage = (error && error.message) || this.data.texts.loadFailed;
      this.setData({ uiState: 'error', errorMessage });
      Toast({ context: this, selector: '#t-toast', message: errorMessage });
    }
  },

  onRetry() {
    this.loadData();
  },

  buildExpiryReminder(expiryDate) {
    if (!expiryDate) return { show: false, expired: false, daysToExpiry: null, text: '' };
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const expiry = new Date(expiryDate);
    expiry.setHours(0, 0, 0, 0);
    const daysToExpiry = Math.floor((expiry.getTime() - today.getTime()) / (24 * 60 * 60 * 1000));
    if (Number.isNaN(daysToExpiry)) return { show: false, expired: false, daysToExpiry: null, text: '' };
    if (daysToExpiry < 0) {
      return { show: true, expired: true, daysToExpiry, text: this.data.texts.expiredHint };
    }
    if (daysToExpiry <= EXPIRY_WARNING_DAYS) {
      return { show: true, expired: false, daysToExpiry, text: `${this.data.texts.expiresIn}${daysToExpiry}${this.data.texts.days}` };
    }
    return { show: false, expired: false, daysToExpiry: null, text: '' };
  },

  async loadRecentUsage() {
    try {
      const response = await getUsageRecords({
        medicineId: this.data.medicineId,
        page: 1,
        pageSize: 5
      });
      this.setData({ recentUsage: (response.data && response.data.list) || [] });
    } catch (error) {
      this.setData({ recentUsage: [] });
    }
  },

  goToEdit() {
    wx.navigateTo({ url: `/pages/medicine/edit/index?id=${this.data.medicineId}` });
  },

  goToStockIn() {
    wx.navigateTo({ url: `/pages/medicine/stock-in/index?medicineId=${this.data.medicineId}` });
  },

  goToUsageRecord() {
    wx.navigateTo({ url: `/pages/medicine/usage-record/index?medicineId=${this.data.medicineId}` });
  },

  goToBatchManage() {
    const medicineName = this.data.medicineInfo.name || '';
    wx.navigateTo({
      url: `/pages/medicine/batch-manage/index?id=${this.data.medicineId}&name=${encodeURIComponent(medicineName)}`
    });
  },

  goToAiAssistant() {
    const medicineName = this.data.medicineInfo.name || this.data.texts.medicine;
    const context = buildMedicineConsultContext(medicineName, this.data.medicineId);
    const assistantName = resolveAiAssistantName(this.data.systemConfig, this.data.texts.continueAskAi);
    pushRecentAiFeature(assistantName, AI_ROUTES.CHAT);
    wx.navigateTo({
      url: buildAiChatPath(context)
    });
  },

  goToAiMedicineAssistant() {
    pushRecentAiFeature(
      this.data.texts.medicineAiAssistant,
      `${AI_ROUTES.MEDICINE_ASSISTANT}?medicineId=${this.data.medicineId}`
    );
    wx.navigateTo({
      url: `${AI_ROUTES.MEDICINE_ASSISTANT}?medicineId=${this.data.medicineId}`
    });
  }
});
