const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser } = require('../../../services/auth/index');
const { USER_ROLES } = require('../../../services/config/index');
const { getDoctorScheduleList, createAppointment } = require('../../../services/appointment/index');

Page({
  data: {
    uiState: 'loading',
    errorText: '',
    scheduleId: '',
    schedule: null,
    loading: false,
    submitted: false,
    patientInfo: {
      name: '',
      phone: ''
    }
  },

  onLoad(options = {}) {
    const scheduleId = String(options.scheduleId || '').trim();
    this.setData({ scheduleId });
    this.initPage();
  },

  async initPage() {
    if (!this.data.scheduleId) {
      this.setData({ uiState: 'error', errorText: '缺少排班编号' });
      return;
    }
    this.setData({ uiState: 'loading', errorText: '' });
    await this.loadScheduleDetail();
  },

  async loadScheduleDetail() {
    this.setData({ loading: true });
    try {
      const userInfo = getCurrentUser();
      if (!userInfo) {
        wx.redirectTo({ url: '/pages/login/index' });
        return;
      }

      if (userInfo.role === USER_ROLES.PATIENT) {
        this.setData({
          patientInfo: {
            name: userInfo.name || '',
            phone: userInfo.phone || ''
          }
        });
      }

      const response = await getDoctorScheduleList({ id: this.data.scheduleId });
      const scheduleList = Array.isArray(response.data) ? response.data : [];
      if (!scheduleList.length) {
        throw new Error('未找到排班信息');
      }

      this.setData({
        schedule: scheduleList[0],
        uiState: 'ready'
      });
    } catch (error) {
      this.setData({
        uiState: 'error',
        errorText: error && error.message ? error.message : '加载排班详情失败'
      });
    } finally {
      this.setData({ loading: false });
    }
  },

  retryLoad() {
    this.initPage();
  },

  onInputChange(e) {
    const field = e.currentTarget.dataset.field;
    if (!field) return;
    this.setData({ [`patientInfo.${field}`]: e.detail.value || '' });
  },

  validateBeforeSubmit() {
    const { schedule, patientInfo } = this.data;
    if (!schedule) throw new Error('排班不可用');
    if (!patientInfo.name) throw new Error('请输入就诊人姓名');
    if (!patientInfo.phone) throw new Error('请输入手机号');
    if (!/^1\d{10}$/.test(String(patientInfo.phone).trim())) throw new Error('请输入正确的手机号');

    const remainingSlots = Number(schedule.totalSlots || 0) - Number(schedule.bookedSlots || 0);
    if (remainingSlots <= 0) throw new Error('当前排班号源已满');
  },

  async submitAppointment() {
    if (this.data.submitted) return;

    try {
      this.validateBeforeSubmit();
    } catch (error) {
      Toast({ context: this, selector: '#t-toast', message: error.message });
      return;
    }

    this.setData({ submitted: true, loading: true });
    try {
      const userInfo = getCurrentUser();
      if (!userInfo || !userInfo.id) {
        throw new Error('请先登录');
      }

      const { schedule, patientInfo } = this.data;
      const requestBody = {
        scheduleId: this.data.scheduleId,
        patientId: userInfo.id,
        patientName: patientInfo.name,
        patientPhone: patientInfo.phone,
        doctorId: schedule.doctorId,
        doctorName: schedule.doctorName,
        appointmentDate: schedule.date || schedule.scheduleDate,
        appointmentTime: `${schedule.startTime}-${schedule.endTime}`
      };

      const response = await createAppointment(requestBody);
      const appointmentId = response?.data?.appointmentId || response?.data?.id || '';

      Toast({ context: this, selector: '#t-toast', message: '预约创建成功', theme: 'success' });
      setTimeout(() => {
        if (appointmentId) {
          wx.redirectTo({ url: `/pages/appointment/appointment-detail/index?id=${appointmentId}` });
        } else {
          wx.redirectTo({ url: '/pages/appointment/my-appointments/index' });
        }
      }, 500);
    } catch (error) {
      Toast({
        context: this,
        selector: '#t-toast',
        message: error && error.message ? error.message : '创建预约失败'
      });
    } finally {
      this.setData({ submitted: false, loading: false });
    }
  },

  goBack() {
    wx.navigateBack();
  }
});
