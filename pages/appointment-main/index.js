const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser } = require('../../services/auth/index');
const {
  USER_ROLES,
  getStoredConfig,
  subscribeSystemConfig,
  syncSystemConfig
} = require('../../services/config/index');
const { getMyPatientInfo } = require('../../services/patient/index');
const {
  getAppointmentList,
  createAppointment,
  confirmAppointment,
  completeAppointment,
  cancelAppointment: cancelAppointmentApi
} = require('../../services/appointment/index');
const { getScheduleList, deleteSchedule } = require('../../services/schedule/index');

const WEEK_LABELS = ['\u5468\u65e5', '\u5468\u4e00', '\u5468\u4e8c', '\u5468\u4e09', '\u5468\u56db', '\u5468\u4e94', '\u5468\u516d'];
const STATUS_OPTIONS = [
  { value: '', label: '\u5168\u90e8' },
  { value: 'pending', label: '\u5f85\u786e\u8ba4' },
  { value: 'confirmed', label: '\u5df2\u786e\u8ba4' },
  { value: 'completed', label: '\u5df2\u5b8c\u6210' },
  { value: 'cancelled', label: '\u5df2\u53d6\u6d88' },
  { value: 'expired', label: '\u5df2\u8fc7\u671f' }
];
const STATUS_MAP = {
  pending: { text: '\u5f85\u786e\u8ba4', theme: 'warning' },
  confirmed: { text: '\u5df2\u786e\u8ba4', theme: 'primary' },
  completed: { text: '\u5df2\u5b8c\u6210', theme: 'success' },
  cancelled: { text: '\u5df2\u53d6\u6d88', theme: 'default' },
  expired: { text: '\u5df2\u8fc7\u671f', theme: 'default' }
};

const getAppointmentDays = () => {
  const config = getStoredConfig();
  const days = Number(config.appointmentDays);
  if (!Number.isFinite(days) || days < 1) return 7;
  return Math.min(Math.floor(days), 30);
};

Page({
  data: {
    uiState: 'loading',
    errorText: '',
    loadingPage: false,
    scheduleLoading: false,
    appointmentLoading: false,
    userInfo: null,
    patientProfile: null,
    roleTitle: '',
    roleDescription: '',
    scheduleSectionTitle: '',
    scheduleSectionDesc: '',
    scheduleEmptyText: '',
    appointmentSectionTitle: '',
    appointmentSectionDesc: '',
    appointmentEmptyText: '',
    systemConfig: {},
    isPatient: false,
    isDoctor: false,
    isAdmin: false,
    canManageSchedule: false,
    canManageAppointment: false,
    dateList: [],
    currentDateIndex: 0,
    selectedDate: '',
    selectedStatus: '',
    appointmentStatusOptions: STATUS_OPTIONS,
    scheduleList: [],
    appointmentList: [],
    texts: {
      centerTitle: '\u9884\u7ea6\u4e2d\u5fc3',
      badgeAdmin: '\u7ba1\u7406\u5458',
      badgeDoctor: '\u533b\u751f',
      badgePatient: '\u60a3\u8005',
      loading: '\u52a0\u8f7d\u4e2d...',
      loadFailed: '\u52a0\u8f7d\u5931\u8d25',
      retry: '\u91cd\u8bd5',
      today: '\u4eca\u5929',
      roleTitleAdmin: '\u9884\u7ea6\u7ba1\u7406',
      roleTitleDoctor: '\u6392\u73ed\u4e0e\u9884\u7ea6',
      roleTitlePatient: '\u5728\u7ebf\u9884\u7ea6',
      roleDescAdmin: '\u5728\u4e00\u4e2a\u9875\u9762\u7edf\u4e00\u7ba1\u7406\u6392\u73ed\u4e0e\u9884\u7ea6\u3002',
      roleDescDoctor: '\u67e5\u770b\u6392\u73ed\u5e76\u5904\u7406\u4e2a\u4eba\u9884\u7ea6\u3002',
      roleDescPatient: '\u67e5\u770b\u53ef\u9884\u7ea6\u65f6\u6bb5\u5e76\u7ba1\u7406\u6211\u7684\u9884\u7ea6\u3002',
      scheduleTitleAdmin: '\u6392\u73ed\u7ba1\u7406',
      scheduleTitleDoctor: '\u6211\u7684\u6392\u73ed',
      scheduleTitlePatient: '\u53ef\u9884\u7ea6\u65f6\u6bb5',
      scheduleDescAdmin: '\u6309\u65e5\u671f\u67e5\u770b\u5e76\u7ef4\u62a4\u6392\u73ed\u3002',
      scheduleDescDoctor: '\u6309\u65e5\u671f\u67e5\u770b\u4e2a\u4eba\u6392\u73ed\u3002',
      scheduleDescPatient: '\u9009\u62e9\u65e5\u671f\u5e76\u9884\u7ea6\u53ef\u7528\u53f7\u6e90\u3002',
      scheduleEmptyPatient: '\u6240\u9009\u65e5\u671f\u6682\u65e0\u53ef\u9884\u7ea6\u53f7\u6e90',
      scheduleEmptyCommon: '\u6240\u9009\u65e5\u671f\u6682\u65e0\u6392\u73ed',
      appointmentTitlePatient: '\u6211\u7684\u9884\u7ea6',
      appointmentTitleManage: '\u9884\u7ea6\u7ba1\u7406',
      reminderCenter: '\u63d0\u9192\u4e2d\u5fc3',
      appointmentDescPatient: '\u67e5\u770b\u5df2\u63d0\u4ea4\u7684\u9884\u7ea6\u8bb0\u5f55\u3002',
      appointmentDescDoctor: '\u67e5\u770b\u5e76\u5904\u7406\u6211\u7684\u9884\u7ea6\u3002',
      appointmentDescAdmin: '\u67e5\u770b\u5e76\u5904\u7406\u5168\u90e8\u9884\u7ea6\u3002',
      appointmentEmptyPatient: '\u6682\u65e0\u9884\u7ea6\u8bb0\u5f55',
      appointmentEmptyNoProfile: '\u5f53\u524d\u8d26\u53f7\u672a\u7ed1\u5b9a\u60a3\u8005\u6863\u6848',
      appointmentEmptyManage: '\u6682\u65e0\u9884\u7ea6\u8bb0\u5f55',
      createSchedule: '\u65b0\u5efa\u6392\u73ed',
      loadingSchedule: '\u6b63\u5728\u52a0\u8f7d\u6392\u73ed...',
      loadingAppointment: '\u6b63\u5728\u52a0\u8f7d\u9884\u7ea6...',
      remainPrefix: '\u5269\u4f59 ',
      slotLabel: '\u53f7\u6e90',
      book: '\u9884\u7ea6',
      edit: '\u7f16\u8f91',
      remove: '\u5220\u9664',
      dateLabel: '\u65e5\u671f',
      timeLabel: '\u65f6\u95f4',
      confirm: '\u786e\u8ba4',
      finish: '\u5b8c\u6210',
      cancel: '\u53d6\u6d88',
      unknownDoctor: '\u672a\u5206\u914d\u533b\u751f',
      unknownPatient: '\u672a\u77e5\u60a3\u8005',
      noProfileTip: '\u5f53\u524d\u8d26\u53f7\u672a\u7ed1\u5b9a\u60a3\u8005\u6863\u6848',
      noSlotTip: '\u8be5\u6392\u73ed\u53f7\u6e90\u5df2\u6ee1',
      bookingTitle: '\u786e\u8ba4\u9884\u7ea6',
      bookingSuccess: '\u9884\u7ea6\u521b\u5efa\u6210\u529f',
      bookingFail: '\u9884\u7ea6\u521b\u5efa\u5931\u8d25',
      deleteScheduleTitle: '\u5220\u9664\u6392\u73ed',
      deleteScheduleContent: '\u786e\u8ba4\u5220\u9664\u8be5\u6392\u73ed\u5417\uff1f',
      deleteScheduleSuccess: '\u6392\u73ed\u5df2\u5220\u9664',
      deleteScheduleFail: '\u5220\u9664\u6392\u73ed\u5931\u8d25',
      actionFail: '\u9884\u7ea6\u64cd\u4f5c\u5931\u8d25',
      actionConfirmTitle: '\u786e\u8ba4\u9884\u7ea6',
      actionConfirmContent: '\u786e\u8ba4\u8be5\u9884\u7ea6\u5417\uff1f',
      actionConfirmSuccess: '\u9884\u7ea6\u5df2\u786e\u8ba4',
      actionCompleteTitle: '\u5b8c\u6210\u5c31\u8bca',
      actionCompleteContent: '\u786e\u8ba4\u5c06\u8be5\u9884\u7ea6\u6807\u8bb0\u4e3a\u5df2\u5b8c\u6210\u5417\uff1f',
      actionCompleteSuccess: '\u9884\u7ea6\u5df2\u5b8c\u6210',
      actionCancelTitle: '\u53d6\u6d88\u9884\u7ea6',
      actionCancelContent: '\u786e\u8ba4\u53d6\u6d88\u8be5\u9884\u7ea6\u5417\uff1f',
      actionCancelSuccess: '\u9884\u7ea6\u5df2\u53d6\u6d88'
    }
  },

  onLoad() {
    this.initTabBar();
    this.applySystemConfig(getStoredConfig());
    this.initDateList();
    this.syncSystemConfig(true);
    this.unsubscribeSystemConfig = subscribeSystemConfig(() => {
      this.applySystemConfig(getStoredConfig());
      const selectedDate = this.data.selectedDate;
      this.initDateList(selectedDate);
      if (this.data.userInfo) this.loadSchedules();
    });
  },

  onUnload() {
    if (typeof this.unsubscribeSystemConfig === 'function') {
      this.unsubscribeSystemConfig();
      this.unsubscribeSystemConfig = null;
    }
  },

  onShow() {
    this.initTabBar();
    this.syncSystemConfig(true).finally(() => this.initPage());
  },

  onPullDownRefresh() {
    this.syncSystemConfig(true)
      .finally(() => this.initPage().finally(() => wx.stopPullDownRefresh()));
  },

  initTabBar() {
    if (typeof this.getTabBar !== 'function') return;
    const tabBar = this.getTabBar();
    if (tabBar && typeof tabBar.init === 'function') tabBar.init();
  },

  initDateList(preferredDate) {
    const dateList = [];
    const today = new Date();
    const days = getAppointmentDays();
    for (let offset = 0; offset < days; offset += 1) {
      const current = new Date(today);
      current.setDate(today.getDate() + offset);
      const year = current.getFullYear();
      const month = `${current.getMonth() + 1}`.padStart(2, '0');
      const day = `${current.getDate()}`.padStart(2, '0');
      dateList.push({
        date: `${year}-${month}-${day}`,
        displayDate: `${month}-${day}`,
        weekDay: offset === 0 ? this.data.texts.today : WEEK_LABELS[current.getDay()]
      });
    }
    const selectedDate = preferredDate && dateList.some((item) => item.date === preferredDate)
      ? preferredDate
      : (dateList[0] ? dateList[0].date : '');
    const currentDateIndex = Math.max(0, dateList.findIndex((item) => item.date === selectedDate));
    this.setData({ dateList, currentDateIndex, selectedDate });
  },

  async syncSystemConfig(shouldRebuildDateList = false) {
    try {
      const res = await syncSystemConfig({ silent: true });
      this.applySystemConfig((res && res.data) || getStoredConfig());
    } catch (error) {
      // getConfig has fallback; swallow network exceptions for page continuity
    } finally {
      if (shouldRebuildDateList) {
        this.initDateList(this.data.selectedDate);
      }
    }
  },

  async initPage() {
    const userInfo = getCurrentUser();
    if (!userInfo) {
      wx.redirectTo({ url: '/pages/login/index' });
      return;
    }

    const { texts } = this.data;
    const isAdmin = userInfo.role === USER_ROLES.SUPER_ADMIN || userInfo.role === USER_ROLES.CLINIC_ADMIN;
    const isDoctor = userInfo.role === USER_ROLES.DOCTOR;
    const isPatient = userInfo.role === USER_ROLES.PATIENT;

    let patientProfile = null;
    if (isPatient) {
      try {
        const patientRes = await getMyPatientInfo();
        patientProfile = patientRes && patientRes.data ? patientRes.data : null;
      } catch (error) {
        patientProfile = null;
      }
    }

    this.setData({
      uiState: 'loading',
      errorText: '',
      loadingPage: true,
      userInfo,
      patientProfile,
      isAdmin,
      isDoctor,
      isPatient,
      canManageSchedule: isAdmin,
      canManageAppointment: isAdmin || isDoctor,
      roleTitle: isAdmin ? texts.roleTitleAdmin : isDoctor ? texts.roleTitleDoctor : texts.roleTitlePatient,
      roleDescription: isAdmin ? texts.roleDescAdmin : isDoctor ? texts.roleDescDoctor : texts.roleDescPatient,
      scheduleSectionTitle: isAdmin ? texts.scheduleTitleAdmin : isDoctor ? texts.scheduleTitleDoctor : texts.scheduleTitlePatient,
      scheduleSectionDesc: isAdmin ? texts.scheduleDescAdmin : isDoctor ? texts.scheduleDescDoctor : texts.scheduleDescPatient,
      scheduleEmptyText: isPatient ? texts.scheduleEmptyPatient : texts.scheduleEmptyCommon,
      appointmentSectionTitle: isPatient ? texts.appointmentTitlePatient : texts.appointmentTitleManage,
      appointmentSectionDesc: isPatient ? texts.appointmentDescPatient : isDoctor ? texts.appointmentDescDoctor : texts.appointmentDescAdmin,
      appointmentEmptyText: isPatient
        ? (patientProfile && patientProfile.id ? texts.appointmentEmptyPatient : texts.appointmentEmptyNoProfile)
        : texts.appointmentEmptyManage,
      appointmentStatusOptions: STATUS_OPTIONS
    });

    try {
      const [scheduleOk, appointmentOk] = await Promise.all([this.loadSchedules(), this.loadAppointments()]);
      if (!scheduleOk && !appointmentOk) {
        throw new Error(texts.loadFailed);
      }
      this.setData({ uiState: 'ready' });
    } catch (error) {
      this.setData({
        uiState: 'error',
        errorText: error && error.message ? error.message : texts.loadFailed
      });
    } finally {
      this.setData({ loadingPage: false });
    }
  },

  retryLoad() {
    this.initPage();
  },

  async loadSchedules() {
    if (!this.data.selectedDate) return true;
    const { texts } = this.data;
    this.setData({ scheduleLoading: true });
    try {
      const params = { date: this.data.selectedDate, pageSize: 50 };
      if (this.data.isDoctor && this.data.userInfo && this.data.userInfo.id) {
        params.doctorId = this.data.userInfo.id;
      }
      const response = await getScheduleList(params);
      const rawList = (response.data && response.data.list) || [];
      const scheduleList = rawList.map((item) => {
        const totalSlots = Number(item.totalSlots || 0);
        const bookedSlots = Number(item.bookedSlots || 0);
        const remainingSlots = Math.max(totalSlots - bookedSlots, 0);
        return {
          ...item,
          totalSlots,
          bookedSlots,
          remainingSlots,
          timeRange: `${item.startTime || '--:--'} - ${item.endTime || '--:--'}`
        };
      });
      this.setData({ scheduleList });
      return true;
    } catch (error) {
      this.setData({ scheduleList: [] });
      Toast({ context: this, selector: '#t-toast', message: error.message || texts.loadFailed });
      return false;
    } finally {
      this.setData({ scheduleLoading: false });
    }
  },

  async loadAppointments() {
    const { texts } = this.data;
    this.setData({ appointmentLoading: true });
    try {
      const params = { page: 1, pageSize: 50 };
      if (this.data.selectedStatus) params.status = this.data.selectedStatus;

      if (this.data.isPatient) {
        const patientProfile = this.data.patientProfile;
        if (!patientProfile || !patientProfile.id) {
          this.setData({
            appointmentList: [],
            appointmentEmptyText: texts.appointmentEmptyNoProfile
          });
          return true;
        }
        params.patientId = patientProfile.id;
      }

      const response = await getAppointmentList(params);
      const rawList = (response.data && response.data.list) || [];
      const appointmentList = rawList.map((item) => {
        const statusMeta = STATUS_MAP[item.status] || { text: item.status || '-', theme: 'default' };
        const cardSubtitle = this.data.isPatient
          ? `\u6392\u961f\u53f7\uff1a${item.sequenceNumber || '-'}`
          : (item.doctorName ? `\u533b\u751f\uff1a${item.doctorName}` : '');
        return {
          ...item,
          statusText: statusMeta.text,
          statusTheme: statusMeta.theme,
          displayName: this.data.isPatient ? (item.doctorName || texts.unknownDoctor) : (item.patientName || texts.unknownPatient),
          subTitle: cardSubtitle,
          canConfirm: this.data.canManageAppointment && item.status === 'pending',
          canComplete: this.data.canManageAppointment && item.status === 'confirmed',
          canCancel: (this.data.canManageAppointment || this.data.isPatient) && (item.status === 'pending' || item.status === 'confirmed')
        };
      });
      this.setData({ appointmentList });
      return true;
    } catch (error) {
      this.setData({ appointmentList: [] });
      Toast({ context: this, selector: '#t-toast', message: error.message || texts.loadFailed });
      return false;
    } finally {
      this.setData({ appointmentLoading: false });
    }
  },

  applySystemConfig(config = {}) {
    this.setData({ systemConfig: config || {} });
  },

  onDateSelect(e) {
    const index = Number(e.currentTarget.dataset.index || 0);
    const selectedItem = this.data.dateList[index];
    if (!selectedItem) return;
    this.setData({ currentDateIndex: index, selectedDate: selectedItem.date });
    this.loadSchedules();
  },

  selectStatus(e) {
    const status = e.currentTarget.dataset.status || '';
    this.setData({ selectedStatus: status });
    this.loadAppointments();
  },

  openCreateScheduleModal() {
    if (!this.data.canManageSchedule) return;
    wx.navigateTo({ url: '/pages/appointment/schedule-manage/index' });
  },

  openEditScheduleModal() {
    if (!this.data.canManageSchedule) return;
    wx.navigateTo({ url: '/pages/appointment/schedule-manage/index' });
  },

  deleteScheduleItem(e) {
    if (!this.data.canManageSchedule) return;
    const schedule = e.currentTarget.dataset.schedule;
    if (!schedule || !schedule.id) return;
    const { texts } = this.data;
    wx.showModal({
      title: texts.deleteScheduleTitle,
      content: texts.deleteScheduleContent,
      success: async (res) => {
        if (!res.confirm) return;
        try {
          await deleteSchedule(schedule.id);
          Toast({ context: this, selector: '#t-toast', message: texts.deleteScheduleSuccess, theme: 'success' });
          await this.loadSchedules();
        } catch (error) {
          Toast({ context: this, selector: '#t-toast', message: error.message || texts.deleteScheduleFail });
        }
      }
    });
  },

  openBookingModal(e) {
    if (!this.data.isPatient) return;
    const schedule = e.currentTarget.dataset.schedule;
    if (!schedule || !schedule.id) return;
    const { texts } = this.data;

    if (!this.data.patientProfile || !this.data.patientProfile.id) {
      Toast({ context: this, selector: '#t-toast', message: texts.noProfileTip });
      return;
    }
    if (Number(schedule.remainingSlots) <= 0) {
      Toast({ context: this, selector: '#t-toast', message: texts.noSlotTip });
      return;
    }

    const scheduleDate = schedule.date || schedule.scheduleDate || '-';
    const scheduleTime = `${schedule.startTime || '--:--'}-${schedule.endTime || '--:--'}`;
    const content = `\u786e\u8ba4\u9884\u7ea6 ${schedule.doctorName || '-'}\uff0c\u65f6\u95f4\uff1a${scheduleDate} ${scheduleTime}\uff1f`;

    wx.showModal({
      title: texts.bookingTitle,
      content,
      success: async (res) => {
        if (!res.confirm) return;
        try {
          await createAppointment({
            scheduleId: schedule.id,
            patientId: this.data.patientProfile.id,
            patientName: this.data.patientProfile.name || this.data.userInfo.name || '',
            patientPhone: this.data.patientProfile.phone || this.data.userInfo.phone || '',
            doctorId: schedule.doctorId,
            doctorName: schedule.doctorName,
            appointmentDate: scheduleDate,
            appointmentTime: scheduleTime
          });
          Toast({ context: this, selector: '#t-toast', message: texts.bookingSuccess, theme: 'success' });
          await Promise.all([this.loadSchedules(), this.loadAppointments()]);
        } catch (error) {
          Toast({ context: this, selector: '#t-toast', message: error.message || texts.bookingFail });
        }
      }
    });
  },

  handleAppointmentAction(e) {
    const action = e.currentTarget.dataset.action;
    const appointmentId = e.currentTarget.dataset.id;
    if (!appointmentId || !action) return;

    const { texts } = this.data;
    const actionMap = {
      confirm: {
        title: texts.actionConfirmTitle,
        content: texts.actionConfirmContent,
        handler: confirmAppointment,
        successMessage: texts.actionConfirmSuccess
      },
      complete: {
        title: texts.actionCompleteTitle,
        content: texts.actionCompleteContent,
        handler: completeAppointment,
        successMessage: texts.actionCompleteSuccess
      },
      cancel: {
        title: texts.actionCancelTitle,
        content: texts.actionCancelContent,
        handler: cancelAppointmentApi,
        successMessage: texts.actionCancelSuccess
      }
    };
    const currentAction = actionMap[action];
    if (!currentAction) return;

    wx.showModal({
      title: currentAction.title,
      content: currentAction.content,
      success: async (res) => {
        if (!res.confirm) return;
        try {
          await currentAction.handler(appointmentId);
          Toast({ context: this, selector: '#t-toast', message: currentAction.successMessage, theme: 'success' });
          await Promise.all([this.loadAppointments(), this.loadSchedules()]);
        } catch (error) {
          Toast({ context: this, selector: '#t-toast', message: error.message || texts.actionFail });
        }
      }
    });
  },

  goToAppointmentDetail(e) {
    const id = e.currentTarget.dataset.id;
    if (!id) return;
    wx.navigateTo({ url: `/pages/appointment/appointment-detail/index?id=${id}` });
  },

  goToReminderCenter() {
    wx.navigateTo({ url: '/pages/appointment/reminders/index' });
  },

  noop() {}
});
