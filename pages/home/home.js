const { getCurrentUser, isLoggedIn } = require('../../services/auth/index');
const {
  USER_ROLES,
  ROLE_NAMES,
  getStoredConfig,
  subscribeSystemConfig,
  syncSystemConfig
} = require('../../services/config/index');
const { getAppointmentList } = require('../../services/appointment/index');
const { getStockWarnings, getExpiryWarningBatches } = require('../../services/medicine/index');
const { getPatientList } = require('../../services/patient/index');
const { getMedicalRecordList } = require('../../services/medical-record/index');
const {
  AI_ROUTES,
  getRecentAiFeatures,
  pushRecentAiFeature,
  resolveAiAssistantName
} = require('../../services/ai/index');

const WEEK_DAYS = ['\u5468\u65e5', '\u5468\u4e00', '\u5468\u4e8c', '\u5468\u4e09', '\u5468\u56db', '\u5468\u4e94', '\u5468\u516d'];
const DEFAULT_STATS = {
  todayAppointments: 0,
  todayRecords: 0,
  warningMedicines: 0,
  totalPatients: 0
};

Page({
  data: {
    userInfo: {},
    roleName: '',
    greeting: '',
    currentDate: '',
    canManagePatient: false,
    canManageMedicine: false,
    canViewStatistics: false,
    isPatient: false,
    uiState: 'loading',
    errorText: '',
    stats: { ...DEFAULT_STATS },
    pendingAppointments: [],
    warningMedicines: [],
    expiryWarningBatches: [],
    recentAiFeatures: [],
    systemConfig: {},
    texts: {
      defaultUser: '\u7528\u6237',
      loading: '\u52a0\u8f7d\u4e2d...',
      loadFailed: '\u52a0\u8f7d\u5931\u8d25',
      retry: '\u91cd\u8bd5',
      quickEntry: '\u5feb\u6377\u5165\u53e3',
      appointment: '\u9884\u7ea6',
      medicalRecord: '\u75c5\u5386',
      medicine: '\u836f\u54c1',
      patient: '\u60a3\u8005',
      notificationCenter: '\u901a\u77e5\u4e2d\u5fc3',
      recentAi: '\u6700\u8fd1\u4f7f\u7528\u7684 AI \u529f\u80fd',
      todayStats: '\u4eca\u65e5\u7edf\u8ba1',
      pendingAppointments: '\u5f85\u786e\u8ba4\u9884\u7ea6',
      pendingConfirm: '\u5f85\u786e\u8ba4',
      expiryWarning: '\u8fd1\u6548\u671f\u9884\u8b66',
      goHandle: '\u53bb\u5904\u7406',
      days: '\u5929',
      noRecentExpiryBatch: '\u8fd130\u5929\u6682\u65e0\u8fd1\u6548\u671f\u6279\u6b21',
      statAppointments: '\u9884\u7ea6',
      statRecords: '\u75c5\u5386',
      statWarnings: '\u9884\u8b66',
      aiAssistant: 'AI \u52a9\u624b',
      morning: '\u65e9\u4e0a\u597d',
      afternoon: '\u4e0b\u5348\u597d',
      evening: '\u665a\u4e0a\u597d',
      hello: '\u4f60\u597d'
    }
  },

  onLoad() {
    this._configSyncWarned = false;
    this.safeInitTabBar();
    this.subscribeConfigUpdates();
    this.initPage();
  },

  onShow() {
    this.safeInitTabBar();
    this.setData({
      recentAiFeatures: getRecentAiFeatures(),
      systemConfig: getStoredConfig()
    });
    this.loadSystemConfig();
  },

  onUnload() {
    if (typeof this._unsubscribeConfig === 'function') {
      this._unsubscribeConfig();
      this._unsubscribeConfig = null;
    }
  },

  onPullDownRefresh() {
    this.initPage().finally(() => wx.stopPullDownRefresh());
  },

  safeInitTabBar() {
    const tabBar = this.getTabBar && this.getTabBar();
    if (tabBar && typeof tabBar.init === 'function') tabBar.init();
  },

  async initPage() {
    const userInfo = getCurrentUser();
    if (!userInfo || !isLoggedIn()) {
      wx.redirectTo({ url: '/pages/login/index' });
      return;
    }

    this.setData({
      uiState: 'loading',
      errorText: '',
      userInfo,
      roleName: ROLE_NAMES[userInfo.role] || this.data.texts.defaultUser,
      recentAiFeatures: getRecentAiFeatures()
    });
    this.setGreeting();
    this.setCurrentDate();
    this.setPermissions(userInfo.role);

    try {
      const loadingTasks = [this.loadSystemConfig(), this.loadPendingAppointments()];
      if (this.data.canViewStatistics) {
        loadingTasks.push(this.loadStatistics());
      } else {
        this.setData({ stats: { ...DEFAULT_STATS } });
      }
      if (this.data.canManageMedicine || this.data.canViewStatistics) {
        loadingTasks.push(this.loadWarningMedicines());
      } else {
        this.setData({ warningMedicines: [] });
      }
      if (this.data.canManageMedicine) {
        loadingTasks.push(this.loadExpiryWarningBatches());
      } else {
        this.setData({ expiryWarningBatches: [] });
      }
      await Promise.all(loadingTasks);
      this.setData({ uiState: 'ready' });
    } catch (error) {
      this.setData({ uiState: 'error', errorText: error.message || this.data.texts.loadFailed });
    }
  },

  setGreeting() {
    const hour = new Date().getHours();
    let greeting = this.data.texts.hello;
    if (hour < 12) greeting = this.data.texts.morning;
    else if (hour < 18) greeting = this.data.texts.afternoon;
    else greeting = this.data.texts.evening;
    this.setData({ greeting });
  },

  setCurrentDate() {
    const now = new Date();
    const y = now.getFullYear();
    const m = `${now.getMonth() + 1}`.padStart(2, '0');
    const d = `${now.getDate()}`.padStart(2, '0');
    const wd = WEEK_DAYS[now.getDay()] || '';
    this.setData({ currentDate: `${y}-${m}-${d} ${wd}` });
  },

  setPermissions(role) {
    this.setData({
      canManagePatient: [USER_ROLES.SUPER_ADMIN, USER_ROLES.CLINIC_ADMIN, USER_ROLES.DOCTOR].includes(role),
      canManageMedicine: [USER_ROLES.SUPER_ADMIN, USER_ROLES.CLINIC_ADMIN].includes(role),
      canViewStatistics: [USER_ROLES.SUPER_ADMIN, USER_ROLES.CLINIC_ADMIN, USER_ROLES.DOCTOR].includes(role),
      isPatient: role === USER_ROLES.PATIENT
    });
  },

  async loadStatistics() {
    if (!this.data.canViewStatistics) {
      this.setData({ stats: { ...DEFAULT_STATS } });
      return;
    }

    const today = new Date();
    const y = today.getFullYear();
    const m = `${today.getMonth() + 1}`.padStart(2, '0');
    const d = `${today.getDate()}`.padStart(2, '0');
    const dateString = `${y}-${m}-${d}`;

    const [appointmentsRes, recordsRes, warningRes, patientRes] = await Promise.all([
      getAppointmentList({ page: 1, pageSize: 200 }),
      getMedicalRecordList({ page: 1, pageSize: 200 }),
      getStockWarnings(),
      getPatientList({ page: 1, pageSize: 1 })
    ]);

    const appointments = appointmentsRes?.data?.list || [];
    const records = recordsRes?.data?.list || [];
    const warningCount = Array.isArray(warningRes?.data) ? warningRes.data.length : 0;

    this.setData({
      'stats.todayAppointments': appointments.filter((i) => String(i.appointmentDate || '').slice(0, 10) === dateString).length,
      'stats.todayRecords': records.filter((i) => String(i.visitTime || '').slice(0, 10) === dateString).length,
      'stats.warningMedicines': warningCount,
      'stats.totalPatients': Number(patientRes?.data?.total || 0)
    });
  },

  async loadPendingAppointments() {
    const userInfo = getCurrentUser();
    const params = { status: 'pending', page: 1, pageSize: 5 };
    if (userInfo?.role === USER_ROLES.DOCTOR) params.doctorId = userInfo.id;
    const res = await getAppointmentList(params);
    this.setData({ pendingAppointments: res?.data?.list || [] });
  },

  async loadWarningMedicines() {
    if (!this.data.canManageMedicine && !this.data.canViewStatistics) {
      this.setData({ warningMedicines: [] });
      return;
    }
    const res = await getStockWarnings();
    this.setData({ warningMedicines: (res?.data || []).slice(0, 3) });
  },

  async loadExpiryWarningBatches() {
    if (!this.data.canManageMedicine) return;
    const res = await getExpiryWarningBatches({ days: 30, limit: 3 });
    this.setData({ expiryWarningBatches: res?.data || [] });
  },

  async loadSystemConfig() {
    const res = await syncSystemConfig({ silent: true });
    this.applySystemConfig(res?.data || getStoredConfig());
    if (res && res.error && !this._configSyncWarned) {
      this._configSyncWarned = true;
      wx.showToast({
        title: '配置同步失败，已使用本地配置',
        icon: 'none'
      });
    }
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

  retryLoad() {
    this.initPage();
  },

  goToAppointment() { wx.switchTab({ url: '/pages/appointment-main/index' }); },
  goToMedicalRecord() { wx.switchTab({ url: '/pages/medical-record/index' }); },
  goToMedicine() { wx.switchTab({ url: '/pages/medicine-main/index' }); },
  goToPatientList() { wx.navigateTo({ url: '/pages/patient/list/index' }); },
  goToExpiryWarning() { wx.navigateTo({ url: '/pages/medicine/expiry-warning/index' }); },
  goToRecordDetail(e) {
    const id = e.currentTarget.dataset.id;
    wx.navigateTo({ url: `/pages/medical/record-detail/index?id=${id}` });
  },
  goToAppointmentDetail(e) {
    const id = e.currentTarget.dataset.id;
    wx.navigateTo({ url: `/pages/appointment/appointment-detail/index?id=${id}` });
  },
  goToAiAssistant() {
    const aiName = resolveAiAssistantName(this.data.systemConfig, this.data.texts.aiAssistant);
    const recent = pushRecentAiFeature(aiName, AI_ROUTES.CHAT);
    this.setData({ recentAiFeatures: recent });
    wx.navigateTo({ url: AI_ROUTES.CHAT });
  },
  goToNotificationCenter() {
    wx.navigateTo({ url: '/pages/notification/index' });
  },
  openRecentAi(e) {
    const path = e.currentTarget.dataset.path;
    if (!path) return;
    const fallbackName = resolveAiAssistantName(this.data.systemConfig, this.data.texts.aiAssistant);
    const recent = pushRecentAiFeature(e.currentTarget.dataset.name || fallbackName, path);
    this.setData({ recentAiFeatures: recent });
    wx.navigateTo({ url: path });
  }
});
