const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser } = require('../../services/auth/index');
const {
  AI_ROUTES,
  DEFAULT_AI_NAME,
  buildAiChatPath,
  pushRecentAiFeature,
  resolveAiAssistantName
} = require('../../services/ai/index');
const {
  USER_ROLES,
  getStoredConfig,
  subscribeSystemConfig,
  syncSystemConfig
} = require('../../services/config/index');
const {
  getMedicineList,
  getStockWarnings,
  getMedicineStatistics,
  getPatientDispensedExpirySummary
} = require('../../services/medicine/index');
const { getMyPatientInfo } = require('../../services/patient/index');
const { getMedicalRecordList } = require('../../services/medical-record/index');

const DOSAGE_FORMS = ['\u5168\u90e8', '\u9897\u7c92', '\u80f6\u56ca', '\u7247\u5242', '\u6ce8\u5c04\u5242', '\u55b7\u96fe\u5242', '\u53e3\u670d\u6db2', '\u5916\u7528', '\u5176\u4ed6'];
const EXPIRY_WARNING_DAYS = 30;

Page({
  data: {
    searchKeyword: '',
    dosageForms: DOSAGE_FORMS,
    dosageFormIndex: -1,
    showWarningOnly: false,
    medicineList: [],
    warningMedicines: [],
    loading: false,
    canManageMedicine: false,
    isPatient: false,
    systemConfig: {},
    prescriptionMedicines: [],
    filteredPrescriptionMedicines: [],
    stats: {
      totalMedicines: 0,
      warningCount: 0,
      totalStockValue: '0.00'
    },
    stateMode: 'loading',
    stateTitle: '',
    stateDescription: '',
    stateButtonText: '',
    texts: {
      loadingTitle: '\u6b63\u5728\u52a0\u8f7d\u836f\u54c1',
      loadingDesc: '\u8bf7\u7a0d\u5019...',
      retry: '\u91cd\u8bd5',
      loadFailed: '\u52a0\u8f7d\u5931\u8d25',
      empty: '\u6682\u65e0\u6570\u636e',
      needLogin: '\u8bf7\u5148\u767b\u5f55',
      patientProfileEmpty: '\u6682\u65e0\u60a3\u8005\u6863\u6848',
      patientProfileHint: '\u8bf7\u5148\u7ed1\u5b9a\u60a3\u8005\u4fe1\u606f\u3002',
      noPrescription: '\u6682\u65e0\u5904\u65b9\u836f\u54c1',
      noPrescriptionHint: '\u5904\u65b9\u836f\u4f1a\u663e\u793a\u5728\u8fd9\u91cc\u3002',
      patientLoadFailed: '\u5904\u65b9\u836f\u52a0\u8f7d\u5931\u8d25',
      patientLoadFailedHint: '\u8bf7\u7a0d\u540e\u91cd\u8bd5\u3002',
      unknownMedicine: '\u672a\u77e5\u836f\u54c1',
      expired: '\u5df2\u8fc7\u671f',
      expiresIn: '\u8ddd\u8fc7\u671f',
      days: '\u5929',
      medicineEmpty: '\u6682\u65e0\u836f\u54c1\u6570\u636e',
      medicineEmptyHint: '\u8bf7\u8c03\u6574\u7b5b\u9009\u6216\u65b0\u589e\u836f\u54c1\u3002',
      noPermissionTitle: '\u65e0\u6743\u9650\u8bbf\u95ee',
      noPermissionHint: '\u5f53\u524d\u8d26\u53f7\u65e0\u6743\u67e5\u770b\u836f\u54c1\u6570\u636e\u3002',
      medicineLoadFailed: '\u836f\u54c1\u52a0\u8f7d\u5931\u8d25',
      medicineLoadFailedHint: '\u8bf7\u7a0d\u540e\u91cd\u8bd5\u3002',
      noMatchedMedicine: '\u65e0\u5339\u914d\u836f\u54c1',
      noMatchedHint: '\u8bf7\u5c1d\u8bd5\u5176\u4ed6\u5173\u952e\u8bcd\u3002',
      patientSearchPlaceholder: '\u641c\u7d22\u5904\u65b9\u836f\u54c1',
      medicineSearchPlaceholder: '\u641c\u7d22\u836f\u54c1',
      statTotal: '\u603b\u6570',
      statWarning: '\u9884\u8b66',
      statStockValue: '\u5e93\u5b58\u4ef7\u503c',
      addMedicine: '\u65b0\u589e\u836f\u54c1',
      stockIn: '\u5165\u5e93',
      stockOut: '\u51fa\u5e93',
      inventory: '\u5e93\u5b58',
      recognitionHistory: '\u8bc6\u522b\u5386\u53f2',
      continueAskAi: '\u7ee7\u7eed\u95ee AI',
      warningNoticePrefix: '\u5f53\u524d\u6709 ',
      warningNoticeSuffix: ' \u79cd\u836f\u54c1\u9700\u8981\u5173\u6ce8\u3002',
      allDosageForms: '\u5168\u90e8\u5242\u578b',
      warningToggleOn: '\u4ec5\u770b\u9884\u8b66\uff1a\u5f00',
      warningToggleOff: '\u4ec5\u770b\u9884\u8b66\uff1a\u5173',
      myPrescription: '\u6211\u7684\u5904\u65b9\u836f',
      usage: '\u7528\u6cd5\uff1a',
      doctor: '\u533b\u751f\uff1a',
      expiryDate: '\u6709\u6548\u671f\uff1a',
      lowStock: '\u5e93\u5b58\u4e0d\u8db3',
      dosageForm: '\u5242\u578b\uff1a',
      stockLabel: '\u5e93\u5b58',
      priceLabel: '\u4ef7\u683c',
      yuan: '\u00a5',
      inStockStatus: '\u5e93\u5b58\u5145\u8db3',
      lowStockStatus: '\u5e93\u5b58\u504f\u4f4e',
      noStockStatus: '\u65e0\u5e93\u5b58',
      medicineConsult: '\u836f\u54c1\u54a8\u8be2'
    }
  },

  onLoad() {
    this._configSyncWarned = false;
    this.safeInitTabBar();
    this.applySystemConfig(getStoredConfig());
    this.subscribeConfigUpdates();
    this.initPage();
  },

  onShow() {
    this.safeInitTabBar();
    this.applySystemConfig(getStoredConfig());
    this.syncSystemConfig().catch(() => {});
  },

  onUnload() {
    if (typeof this._unsubscribeConfig === 'function') {
      this._unsubscribeConfig();
      this._unsubscribeConfig = null;
    }
  },

  onPullDownRefresh() {
    Promise.resolve(this.initPage()).finally(() => wx.stopPullDownRefresh());
  },

  safeInitTabBar() {
    const tabBar = this.getTabBar && this.getTabBar();
    if (tabBar && typeof tabBar.init === 'function') tabBar.init();
  },

  setAsyncState(stateMode, options = {}) {
    const { texts } = this.data;
    this.setData({
      stateMode,
      stateTitle: options.title || (stateMode === 'error' ? texts.loadFailed : stateMode === 'empty' ? texts.empty : texts.loadingTitle),
      stateDescription: options.description || (stateMode === 'error' ? texts.patientLoadFailedHint : ''),
      stateButtonText: options.buttonText || texts.retry
    });
  },

  async initPage() {
    const currentUser = getCurrentUser();
    const { texts } = this.data;
    if (!currentUser) {
      wx.showToast({ title: texts.needLogin, icon: 'none' });
      setTimeout(() => wx.redirectTo({ url: '/pages/login/index' }), 800);
      return false;
    }

    const isPatient = currentUser.role === USER_ROLES.PATIENT;
    const canManageMedicine = currentUser.role === USER_ROLES.SUPER_ADMIN || currentUser.role === USER_ROLES.CLINIC_ADMIN;
    this.setData({ isPatient, canManageMedicine });
    await this.syncSystemConfig().catch(() => {});
    this.setAsyncState('loading', { title: texts.loadingTitle, description: texts.loadingDesc });

    if (isPatient) {
      return this.loadPatientMedicineList();
    }

    await Promise.allSettled([this.loadStatistics(), this.loadWarningMedicines()]);
    return this.refreshMedicineList();
  },

  async loadPatientMedicineList() {
    const { texts } = this.data;
    try {
      const myPatientRes = await getMyPatientInfo();
      const patientInfo = myPatientRes && myPatientRes.data ? myPatientRes.data : null;
      if (!patientInfo) {
        this.setData({ prescriptionMedicines: [], filteredPrescriptionMedicines: [] });
        this.setAsyncState('empty', { title: texts.patientProfileEmpty, description: texts.patientProfileHint });
        return true;
      }

      const response = await getMedicalRecordList({ patientId: patientInfo.id });
      const medicalRecords = (response.data && response.data.list) || [];
      if (!medicalRecords.length) {
        this.setData({ prescriptionMedicines: [], filteredPrescriptionMedicines: [] });
        this.setAsyncState('empty', { title: texts.noPrescription, description: texts.noPrescriptionHint });
        return true;
      }

      const medicineMap = new Map();
      const prescriptionMedicines = [];
      for (const record of medicalRecords) {
        if (!record.prescription || record.prescription.length === 0) continue;
        for (const item of record.prescription) {
          const medicineId = item && item.medicineId ? String(item.medicineId) : '';
          if (!medicineId || medicineMap.has(medicineId)) continue;
          prescriptionMedicines.push({
            id: medicineId,
            name: item.name || texts.unknownMedicine,
            specification: item.specification || '',
            dosage: item.dosage,
            frequency: item.frequency,
            days: item.days,
            recordId: record.id,
            visitTime: record.visitTime,
            doctorName: record.doctorName
          });
          medicineMap.set(medicineId, true);
        }
      }

      const medicineIds = prescriptionMedicines.map((item) => Number(item.id)).filter((item) => Number.isFinite(item));
      let dispensedExpiryMap = {};
      try {
        const summaryRes = await getPatientDispensedExpirySummary({ patientId: patientInfo.id, medicineIds });
        dispensedExpiryMap = summaryRes.data || {};
      } catch (error) {
        dispensedExpiryMap = {};
      }

      const finalMedicines = prescriptionMedicines.map((item) => {
        const stockOutExpiryDate = dispensedExpiryMap[String(item.id)] || '';
        return {
          ...item,
          stockOutExpiryDate,
          expiryReminder: this.buildExpiryReminder(stockOutExpiryDate)
        };
      });

      this.setData({
        prescriptionMedicines: finalMedicines,
        filteredPrescriptionMedicines: finalMedicines
      });

      if (!finalMedicines.length) {
        this.setAsyncState('empty', { title: texts.noPrescription, description: texts.noPrescriptionHint });
      } else {
        this.setAsyncState('success', { title: '', description: '' });
      }
      return true;
    } catch (error) {
      this.setData({ prescriptionMedicines: [], filteredPrescriptionMedicines: [] });
      this.setAsyncState('error', { title: texts.patientLoadFailed, description: texts.patientLoadFailedHint });
      Toast({ context: this, selector: '#t-toast', message: texts.patientLoadFailed });
      return false;
    }
  },

  buildExpiryReminder(expiryDate) {
    if (!expiryDate) return null;
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const expiry = new Date(expiryDate);
    expiry.setHours(0, 0, 0, 0);
    const daysToExpiry = Math.floor((expiry.getTime() - today.getTime()) / (24 * 60 * 60 * 1000));
    if (Number.isNaN(daysToExpiry)) return null;
    if (daysToExpiry < 0) return { theme: 'danger', text: this.data.texts.expired };
    if (daysToExpiry <= EXPIRY_WARNING_DAYS) return { theme: 'warning', text: `${this.data.texts.expiresIn}${daysToExpiry}${this.data.texts.days}` };
    return null;
  },

  async loadStatistics() {
    try {
      const response = await getMedicineStatistics();
      const stats = response.data || {};
      this.setData({
        'stats.totalMedicines': Number(stats.totalMedicines || 0),
        'stats.warningCount': Number(stats.warningCount || 0),
        'stats.totalStockValue': Number(stats.totalStockValue || 0).toFixed(2)
      });
      return true;
    } catch (error) {
      return false;
    }
  },

  async loadWarningMedicines() {
    try {
      const response = await getStockWarnings();
      this.setData({ warningMedicines: response.data || [] });
      return true;
    } catch (error) {
      return false;
    }
  },

  async refreshMedicineList() {
    if (this.data.loading) return false;
    const { texts } = this.data;
    this.setData({ loading: true });
    try {
      const requestParams = { page: 1, pageSize: 10000 };
      const keyword = (this.data.searchKeyword || '').trim();
      if (keyword) requestParams.name = keyword;
      const dosageFormIndex = this.data.dosageFormIndex;
      const dosageForms = this.data.dosageForms;
      const isOtherSelected = dosageFormIndex === dosageForms.length - 1;
      const isSpecificForm = dosageFormIndex > 0 && dosageFormIndex < dosageForms.length - 1;
      if (isSpecificForm) requestParams.dosageForm = dosageForms[dosageFormIndex];
      if (this.data.showWarningOnly) requestParams.warningOnly = true;

      const response = await getMedicineList(requestParams);
      let medicineList = (response.data && response.data.list) || [];
      if (isOtherSelected) {
        const predefinedForms = dosageForms.slice(1, -1);
        medicineList = medicineList.filter((item) => !predefinedForms.includes(item.dosageForm || ''));
      }
      this.setData({ medicineList });
      if (medicineList.length === 0) {
        this.setAsyncState('empty', { title: texts.medicineEmpty, description: texts.medicineEmptyHint });
      } else {
        this.setAsyncState('success', { title: '', description: '' });
      }
      return true;
    } catch (error) {
      if (error && error.type === 'forbidden') {
        this.setData({ medicineList: [] });
        this.setAsyncState('empty', { title: texts.noPermissionTitle, description: texts.noPermissionHint });
        return false;
      }
      this.setData({ medicineList: [] });
      this.setAsyncState('error', { title: texts.medicineLoadFailed, description: texts.medicineLoadFailedHint });
      Toast({ context: this, selector: '#t-toast', message: error && error.message ? error.message : texts.loadFailed });
      return false;
    } finally {
      this.setData({ loading: false });
    }
  },

  onSearchChange(e) {
    this.setData({ searchKeyword: e.detail.value });
  },

  applyPatientSearch(keyword) {
    const searchText = (keyword || '').trim().toLowerCase();
    const { texts } = this.data;
    if (!searchText) {
      const all = this.data.prescriptionMedicines;
      this.setData({ filteredPrescriptionMedicines: all });
      if (all.length > 0) this.setAsyncState('success', { title: '', description: '' });
      else this.setAsyncState('empty', { title: texts.noPrescription, description: texts.noPrescriptionHint });
      return;
    }
    const filteredList = this.data.prescriptionMedicines.filter((item) => {
      const name = (item.name || '').toLowerCase();
      const spec = (item.specification || '').toLowerCase();
      const doctorName = (item.doctorName || '').toLowerCase();
      return name.includes(searchText) || spec.includes(searchText) || doctorName.includes(searchText);
    });
    this.setData({ filteredPrescriptionMedicines: filteredList });
    if (filteredList.length > 0) this.setAsyncState('success', { title: '', description: '' });
    else this.setAsyncState('empty', { title: texts.noMatchedMedicine, description: texts.noMatchedHint });
  },

  onSearch() {
    if (this.data.isPatient) {
      this.applyPatientSearch(this.data.searchKeyword);
      return;
    }
    this.refreshMedicineList();
  },

  onDosageFormChange(e) {
    this.setData({ dosageFormIndex: Number(e.detail.value) }, () => this.refreshMedicineList());
  },

  onWarningToggle() {
    this.setData({ showWarningOnly: !this.data.showWarningOnly }, () => this.refreshMedicineList());
  },

  onStateRetry() {
    this.initPage();
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

  goToAddMedicine() { wx.navigateTo({ url: '/pages/medicine/edit/index' }); },
  goToStockIn() { wx.navigateTo({ url: '/pages/medicine/stock-in/index' }); },
  goToStockOut() { wx.navigateTo({ url: '/pages/medicine/stock-out/index' }); },
  goToInventory() { wx.navigateTo({ url: '/pages/medicine/inventory/index' }); },
  goToRecognitionHistory() {
    pushRecentAiFeature('药品识别历史', AI_ROUTES.RECOGNITION_HISTORY);
    wx.navigateTo({ url: AI_ROUTES.RECOGNITION_HISTORY });
  },
  goToAiAssistant() {
    const contextKeyword = (this.data.searchKeyword || '').trim();
    const context = contextKeyword ? `${this.data.texts.medicineConsult}：${contextKeyword}` : this.data.texts.medicineConsult;
    const aiName = resolveAiAssistantName(this.data.systemConfig, DEFAULT_AI_NAME);
    pushRecentAiFeature(aiName, AI_ROUTES.CHAT);
    wx.navigateTo({ url: buildAiChatPath(context) });
  },
  goToMedicineDetail(e) {
    const { id } = e.currentTarget.dataset;
    wx.navigateTo({ url: `/pages/medicine/detail/index?id=${id}` });
  }
});
