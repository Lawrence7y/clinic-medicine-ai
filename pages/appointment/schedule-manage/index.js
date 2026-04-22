const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser } = require('../../../services/auth/index');
const { USER_ROLES, getConfig, getStoredConfig, subscribeSystemConfig } = require('../../../services/config/index');
const {
  getScheduleList,
  createSchedule,
  updateSchedule,
  deleteSchedule
} = require('../../../services/schedule/index');
const { getDoctorList } = require('../../../services/appointment/index');

const WEEK_LABELS = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];

const getAppointmentDays = () => {
  const config = getStoredConfig();
  const days = Number(config.appointmentDays);
  if (!Number.isFinite(days) || days < 1) return 14;
  return Math.min(Math.floor(days), 30);
};

Page({
  data: {
    uiState: 'loading',
    errorMessage: '',
    loading: false,
    scheduleList: [],
    selectedDate: '',
    dateList: [],
    currentDateIndex: 0,
    showAddModal: false,
    showEditModal: false,
    editingSchedule: null,
    doctorList: [],
    filterDoctorId: '',
    filterDoctorIndex: -1,
    formData: {
      doctorId: '',
      doctorName: '',
      date: '',
      startTime: '08:00',
      endTime: '12:00',
      totalSlots: 20
    }
  },

  onLoad() {
    this.initDateList();
    this.initPage();
    this.loadDoctorList();
    this.unsubscribeSystemConfig = subscribeSystemConfig(() => {
      this.initDateList(this.data.selectedDate);
      this.loadScheduleList();
    });
    this.syncSystemConfig(this.data.selectedDate);
  },

  onShow() {
    this.syncSystemConfig(this.data.selectedDate).finally(() => this.loadScheduleList());
  },

  onUnload() {
    if (typeof this.unsubscribeSystemConfig === 'function') {
      this.unsubscribeSystemConfig();
      this.unsubscribeSystemConfig = null;
    }
  },

  initDateList(preferredDate) {
    const dateList = [];
    const today = new Date();
    const days = getAppointmentDays();

    for (let i = 0; i < days; i += 1) {
      const date = new Date(today);
      date.setDate(today.getDate() + i);
      const year = date.getFullYear();
      const month = `${date.getMonth() + 1}`.padStart(2, '0');
      const day = `${date.getDate()}`.padStart(2, '0');
      dateList.push({
        date: `${year}-${month}-${day}`,
        displayDate: `${month}-${day}`,
        weekDay: i === 0 ? '今天' : WEEK_LABELS[date.getDay()],
        isToday: i === 0
      });
    }

    const selectedDate = preferredDate && dateList.some((item) => item.date === preferredDate)
      ? preferredDate
      : (dateList[0] ? dateList[0].date : '');
    const currentDateIndex = Math.max(0, dateList.findIndex((item) => item.date === selectedDate));

    this.setData({
      dateList,
      selectedDate,
      currentDateIndex,
      'formData.date': selectedDate
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
      return;
    }

    const isAdmin = userInfo.role === USER_ROLES.SUPER_ADMIN || userInfo.role === USER_ROLES.CLINIC_ADMIN;
    if (!isAdmin) {
      wx.showToast({
        title: '暂无权限',
        icon: 'none'
      });
      setTimeout(() => {
        wx.navigateBack();
      }, 1200);
    }
  },

  async loadDoctorList() {
    try {
      const res = await getDoctorList();
      const doctorList = Array.isArray(res.data) ? res.data : ((res.data && res.data.list) || []);
      this.setData({ doctorList });
    } catch (error) {
      Toast({
        context: this,
        selector: '#t-toast',
        message: error.message || '加载医生列表失败'
      });
    }
  },

  async loadScheduleList() {
    if (!this.data.selectedDate) return;
    this.setData({ loading: true, uiState: 'loading', errorMessage: '' });

    try {
      const params = {
        date: this.data.selectedDate,
        doctorId: this.data.filterDoctorId || null
      };
      const res = await getScheduleList(params);
      const list = (res.data && res.data.list) || [];
      this.setData({
        scheduleList: list,
        uiState: 'ready'
      });
    } catch (error) {
      this.setData({
        scheduleList: [],
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

  onFilterDoctorChange(e) {
    const index = Number(e.detail.value);
    const doctor = Number.isFinite(index) ? this.data.doctorList[index] : null;
    this.setData({
      filterDoctorIndex: Number.isFinite(index) ? index : -1,
      filterDoctorId: doctor ? doctor.id : '',
      selectedDate: this.data.selectedDate,
      'formData.date': this.data.selectedDate
    });
    this.loadScheduleList();
  },

  onDateSelect(e) {
    const index = Number(e.currentTarget.dataset.index);
    if (!Number.isFinite(index) || !this.data.dateList[index]) return;
    this.setData({
      currentDateIndex: index,
      selectedDate: this.data.dateList[index].date,
      'formData.date': this.data.dateList[index].date
    });
    this.loadScheduleList();
  },

  openAddModal() {
    this.setData({
      showAddModal: true,
      formData: {
        doctorId: '',
        doctorName: '',
        date: this.data.selectedDate,
        startTime: '08:00',
        endTime: '12:00',
        totalSlots: 20
      }
    });
  },

  closeAddModal() {
    this.setData({ showAddModal: false });
  },

  openEditModal(e) {
    const schedule = e.currentTarget.dataset.schedule;
    if (!schedule) return;
    this.setData({
      showEditModal: true,
      editingSchedule: schedule,
      formData: {
        doctorId: schedule.doctorId,
        doctorName: schedule.doctorName,
        date: schedule.date || schedule.scheduleDate || this.data.selectedDate,
        startTime: schedule.startTime,
        endTime: schedule.endTime,
        totalSlots: schedule.totalSlots
      }
    });
  },

  closeEditModal() {
    this.setData({
      showEditModal: false,
      editingSchedule: null
    });
  },

  onDoctorSelect(e) {
    const index = Number(e.detail.value);
    const doctor = Number.isFinite(index) ? this.data.doctorList[index] : null;
    if (!doctor) return;
    this.setData({
      'formData.doctorId': doctor.id,
      'formData.doctorName': doctor.name
    });
  },

  onFormFieldChange(e) {
    const { field } = e.currentTarget.dataset;
    const value = e.detail && Object.prototype.hasOwnProperty.call(e.detail, 'value')
      ? e.detail.value
      : e.detail;
    this.setData({
      [`formData.${field}`]: value
    });
  },

  onStartTimeChange(e) {
    this.setData({
      'formData.startTime': e.detail.value
    });
  },

  onEndTimeChange(e) {
    this.setData({
      'formData.endTime': e.detail.value
    });
  },

  validateForm(formData) {
    if (!formData.doctorId || !formData.date || !formData.startTime || !formData.endTime) {
      return '请填写完整的排班信息';
    }
    if (formData.startTime >= formData.endTime) {
      return '开始时间必须早于结束时间';
    }
    const totalSlots = Number(formData.totalSlots);
    if (!Number.isFinite(totalSlots) || totalSlots < 1) {
      return '总号源必须大于或等于1';
    }
    return '';
  },

  async handleAddSchedule() {
    const { formData } = this.data;
    const error = this.validateForm(formData);
    if (error) {
      Toast({ context: this, selector: '#t-toast', message: error });
      return;
    }

    this.setData({ loading: true });
    try {
      await createSchedule({
        ...formData,
        totalSlots: Number(formData.totalSlots)
      });
      Toast({ context: this, selector: '#t-toast', message: '排班创建成功', theme: 'success' });
      this.closeAddModal();
      this.loadScheduleList();
    } catch (apiError) {
      Toast({
        context: this,
        selector: '#t-toast',
        message: apiError.message || '创建排班失败'
      });
    } finally {
      this.setData({ loading: false });
    }
  },

  async handleEditSchedule() {
    const { formData, editingSchedule } = this.data;
    if (!editingSchedule || !editingSchedule.id) return;

    const error = this.validateForm(formData);
    if (error) {
      Toast({ context: this, selector: '#t-toast', message: error });
      return;
    }

    this.setData({ loading: true });
    try {
      await updateSchedule(editingSchedule.id, {
        ...formData,
        totalSlots: Number(formData.totalSlots)
      });
      Toast({ context: this, selector: '#t-toast', message: '排班更新成功', theme: 'success' });
      this.closeEditModal();
      this.loadScheduleList();
    } catch (apiError) {
      Toast({
        context: this,
        selector: '#t-toast',
        message: apiError.message || '更新排班失败'
      });
    } finally {
      this.setData({ loading: false });
    }
  },

  async handleDeleteSchedule(e) {
    const { schedule } = e.currentTarget.dataset;
    if (!schedule || !schedule.id) return;

    wx.showModal({
      title: '删除排班',
      content: '确定删除该排班吗？',
      success: async (res) => {
        if (!res.confirm) return;
        this.setData({ loading: true });
        try {
          await deleteSchedule(schedule.id);
          Toast({ context: this, selector: '#t-toast', message: '排班删除成功', theme: 'success' });
          this.loadScheduleList();
        } catch (apiError) {
          Toast({
            context: this,
            selector: '#t-toast',
            message: apiError.message || '删除排班失败'
          });
        } finally {
          this.setData({ loading: false });
        }
      }
    });
  },

  goBack() {
    wx.switchTab({ url: '/pages/appointment-main/index' });
  }
});
