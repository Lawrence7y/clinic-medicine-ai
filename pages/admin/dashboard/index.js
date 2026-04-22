const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser } = require('../../../services/auth/index');
const { USER_ROLES } = require('../../../services/config/index');
const { getAppointmentList } = require('../../../services/appointment/index');
const { getPatientList } = require('../../../services/patient/index');
const { getMedicineList } = require('../../../services/medicine/index');

Page({
  data: {
    uiState: 'loading',
    errorText: '',
    userInfo: null,
    currentDate: '',
    stats: {
      todayAppointments: 0,
      totalPatients: 0,
      totalMedicines: 0,
      pendingAppointments: 0
    },
    recentAppointments: [],
    loading: false,
    texts: {
      noPermission: '暂无权限',
      loadFailed: '加载失败',
      loading: '加载中...',
      loadingDesc: '正在加载工作台数据...',
      retry: '重新加载',
      welcomePrefix: '欢迎，',
      defaultAdminName: '管理员',
      dateLabel: '日期：',
      todayAppointments: '今日预约',
      totalPatients: '患者总数',
      totalMedicines: '药品总数',
      pendingAppointments: '待确认预约',
      quickEntry: '快捷入口',
      scheduleManage: '排班管理',
      userManage: '用户管理',
      medicineManage: '药品管理',
      systemConfig: '系统配置',
      auditCenter: '审计中心',
      reports: '报表统计',
      aiAssistant: 'AI 助手',
      recentAppointments: '最近预约',
      emptyAppointments: '暂无记录',
      pending: '待确认',
      confirmed: '已确认',
      busyHint: '系统繁忙，请稍后重试。'
    }
  },

  onLoad() {
    this.initPage();
  },

  onShow() {
    this.loadDashboardData();
  },

  onPullDownRefresh() {
    this.loadDashboardData().finally(() => wx.stopPullDownRefresh());
  },

  initPage() {
    const userInfo = getCurrentUser();
    if (!userInfo) {
      wx.redirectTo({ url: '/pages/login/index' });
      return;
    }

    const isAdmin =
      userInfo.role === USER_ROLES.SUPER_ADMIN || userInfo.role === USER_ROLES.CLINIC_ADMIN;
    if (!isAdmin) {
      wx.showToast({ title: this.data.texts.noPermission, icon: 'none' });
      setTimeout(() => wx.navigateBack(), 800);
      return;
    }

    this.setData({
      uiState: 'loading',
      errorText: '',
      userInfo,
      currentDate: this.formatDate(new Date())
    });
    this.loadDashboardData();
  },

  async loadDashboardData() {
    this.setData({ loading: true, uiState: 'loading', errorText: '' });
    try {
      const todayStr = this.formatYmd(new Date());
      const [patientRes, medicineRes, apptRes] = await Promise.all([
        getPatientList({ page: 1, pageSize: 1 }),
        getMedicineList({ page: 1, pageSize: 1 }),
        getAppointmentList({ page: 1, pageSize: 20, date: todayStr })
      ]);

      const appts = Array.isArray(apptRes?.data?.list) ? apptRes.data.list : [];
      this.setData({
        stats: {
          todayAppointments: appts.length,
          totalPatients: Number(patientRes?.data?.total || 0),
          totalMedicines: Number(medicineRes?.data?.total || 0),
          pendingAppointments: appts.filter((a) => a.status === 'pending').length
        },
        recentAppointments: appts.slice(0, 5),
        uiState: 'ready',
        errorText: ''
      });
    } catch (error) {
      const message = (error && error.message) || this.data.texts.loadFailed;
      this.setData({
        uiState: 'error',
        errorText: message
      });
      Toast({ context: this, selector: '#t-toast', message });
    } finally {
      this.setData({ loading: false });
    }
  },

  retryLoad() {
    this.loadDashboardData();
  },

  formatYmd(date) {
    const y = date.getFullYear();
    const m = String(date.getMonth() + 1).padStart(2, '0');
    const d = String(date.getDate()).padStart(2, '0');
    return `${y}-${m}-${d}`;
  },

  formatDate(date) {
    return this.formatYmd(date);
  },

  goToAppointments() { wx.navigateTo({ url: '/pages/appointment/my-appointments/index' }); },
  goToPatients() { wx.navigateTo({ url: '/pages/patient/list/index' }); },
  goToMedicines() { wx.switchTab({ url: '/pages/medicine-main/index' }); },
  goToScheduleManage() { wx.navigateTo({ url: '/pages/appointment/schedule-manage/index' }); },
  goToUserManage() { wx.navigateTo({ url: '/pages/user/user-list/index' }); },
  goToSystemConfig() { wx.navigateTo({ url: '/pages/admin/system-config/index' }); },
  goToAuditCenter() { wx.navigateTo({ url: '/pages/admin/audit-center/index' }); },
  goToReports() { wx.navigateTo({ url: '/pages/admin/reports/index' }); },
  goToAiAssistantHub() { wx.navigateTo({ url: '/pages/admin/ai-assistant/index' }); }
});
