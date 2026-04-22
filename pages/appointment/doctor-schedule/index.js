const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser } = require('../../../services/auth/index');
const { USER_ROLES, getConfig, getStoredConfig, subscribeSystemConfig } = require('../../../services/config/index');
const { getDoctorScheduleList, createOfflineAppointment } = require('../../../services/appointment/index');

const WEEK_LABELS = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];

const getAppointmentDays = () => {
  const config = getStoredConfig();
  const days = Number(config.appointmentDays);
  if (!Number.isFinite(days) || days < 1) return 7;
  return Math.min(Math.floor(days), 30);
};

Page({
  data: {
    uiState: 'loading',
    errorMessage: '',
    loading: false,
    scheduleList: [],
    doctorId: '',
    selectedDate: '',
    dateList: [],
    currentDateIndex: 0,
    showOfflineModal: false,
    offlineSubmitting: false,
    offlineScheduleId: '',
    offlineForm: {
      patientPhone: '',
      patientName: ''
    }
  },

  onLoad(options = {}) {
    this.initDateList(options.date);

    const patch = {};
    if (options.doctorId) {
      patch.doctorId = options.doctorId;
    }
    if (options.date) {
      const idx = this.data.dateList.findIndex((item) => item.date === options.date);
      if (idx >= 0) {
        patch.selectedDate = options.date;
        patch.currentDateIndex = idx;
      }
    }
    if (Object.keys(patch).length > 0) {
      this.setData(patch);
    }

    this.unsubscribeSystemConfig = subscribeSystemConfig(() => {
      this.initDateList(this.data.selectedDate);
      this.loadScheduleList();
    });

    this.initPage();
    this.syncSystemConfig(options.date);
  },

  onUnload() {
    if (typeof this.unsubscribeSystemConfig === 'function') {
      this.unsubscribeSystemConfig();
      this.unsubscribeSystemConfig = null;
    }
  },

  onShow() {
    this.syncSystemConfig(this.data.selectedDate).finally(() => this.loadScheduleList());
  },

  initDateList(preferredDate) {
    const today = new Date();
    const dateList = [];
    const days = getAppointmentDays();

    for (let offset = 0; offset < days; offset += 1) {
      const date = new Date(today);
      date.setDate(today.getDate() + offset);
      const y = date.getFullYear();
      const m = `${date.getMonth() + 1}`.padStart(2, '0');
      const d = `${date.getDate()}`.padStart(2, '0');
      dateList.push({
        date: `${y}-${m}-${d}`,
        displayDate: `${m}-${d}`,
        weekDay: offset === 0 ? '今天' : WEEK_LABELS[date.getDay()],
        isToday: offset === 0
      });
    }

    const selectedDate = preferredDate && dateList.some((item) => item.date === preferredDate)
      ? preferredDate
      : (dateList[0] ? dateList[0].date : '');
    const currentDateIndex = Math.max(0, dateList.findIndex((item) => item.date === selectedDate));

    this.setData({
      dateList,
      selectedDate,
      currentDateIndex
    });
  },

  async syncSystemConfig(preferredDate) {
    try {
      await getConfig();
    } catch (error) {
      // getConfig internally falls back to local cache
    } finally {
      this.initDateList(preferredDate || this.data.selectedDate);
    }
  },

  initPage() {
    const userInfo = getCurrentUser();
    if (!userInfo) {
      wx.redirectTo({ url: '/pages/login/index' });
    }
  },

  async loadScheduleList() {
    if (!this.data.selectedDate) return;
    this.setData({ loading: true, uiState: 'loading', errorMessage: '' });
    try {
      const response = await getDoctorScheduleList({
        date: this.data.selectedDate,
        doctorId: this.data.doctorId || undefined
      });
      this.setData({
        scheduleList: response.data || [],
        uiState: 'ready'
      });
    } catch (error) {
      this.setData({
        uiState: 'error',
        errorMessage: error.message || '加载排班失败'
      });
    } finally {
      this.setData({ loading: false });
    }
  },

  onRetry() {
    this.loadScheduleList();
  },

  onDateSelect(e) {
    const index = Number(e.currentTarget.dataset.index);
    if (!Number.isFinite(index) || !this.data.dateList[index]) return;
    this.setData({
      currentDateIndex: index,
      selectedDate: this.data.dateList[index].date
    });
    this.loadScheduleList();
  },

  goToAppointment(e) {
    const { schedule } = e.currentTarget.dataset;
    if (!schedule || !schedule.id) return;
    if (Number(schedule.bookedSlots) >= Number(schedule.totalSlots)) {
      Toast({ context: this, selector: '#t-toast', message: '该时段号源已满' });
      return;
    }

    const userInfo = getCurrentUser();
    if (!userInfo) {
      wx.redirectTo({ url: '/pages/login/index' });
      return;
    }

    if (userInfo.role === USER_ROLES.PATIENT) {
      wx.navigateTo({
        url: `/pages/appointment/appointment-confirm/index?scheduleId=${schedule.id}`
      });
      return;
    }

    this.openOfflineModal(schedule.id);
  },

  openOfflineModal(scheduleId) {
    this.setData({
      showOfflineModal: true,
      offlineScheduleId: scheduleId,
      offlineForm: {
        patientPhone: '',
        patientName: ''
      }
    });
  },

  closeOfflineModal() {
    this.setData({
      showOfflineModal: false,
      offlineSubmitting: false
    });
  },

  onOfflinePhoneChange(e) {
    this.setData({ 'offlineForm.patientPhone': (e.detail.value || '').trim() });
  },

  onOfflineNameChange(e) {
    this.setData({ 'offlineForm.patientName': (e.detail.value || '').trim() });
  },

  async submitOfflineRegistration() {
    const { offlineScheduleId, offlineForm } = this.data;
    const patientPhone = (offlineForm.patientPhone || '').trim();
    const patientName = (offlineForm.patientName || '').trim();

    if (!/^\d{11}$/.test(patientPhone)) {
      Toast({ context: this, selector: '#t-toast', message: '请输入11位手机号' });
      return;
    }

    this.setData({ offlineSubmitting: true });
    try {
      const response = await createOfflineAppointment({
        scheduleId: offlineScheduleId,
        patientPhone,
        patientName
      });
      Toast({ context: this, selector: '#t-toast', message: '加号成功', theme: 'success' });
      this.closeOfflineModal();
      this.loadScheduleList();
      const appointmentId = response && response.data && (response.data.id || response.data.appointmentId);
      if (appointmentId) {
        wx.navigateTo({ url: `/pages/appointment/appointment-detail/index?id=${appointmentId}` });
      }
    } catch (error) {
      Toast({ context: this, selector: '#t-toast', message: error.message || '加号失败' });
    } finally {
      this.setData({ offlineSubmitting: false });
    }
  }
});
