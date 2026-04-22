const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser } = require('../../../services/auth/index');
const { USER_ROLES } = require('../../../services/config/index');
const { getMyPatientInfo } = require('../../../services/patient/index');
const {
  getAppointmentDetail,
  confirmAppointment,
  completeAppointment,
  cancelAppointment: cancelAppointmentApi,
  callAppointment,
  getAppointmentPosition
} = require('../../../services/appointment/index');

const STATUS_TEXT = {
  pending: '\u5f85\u786e\u8ba4',
  confirmed: '\u5df2\u786e\u8ba4',
  completed: '\u5df2\u5b8c\u6210',
  cancelled: '\u5df2\u53d6\u6d88'
};

Page({
  data: {
    uiState: 'loading',
    errorText: '',
    appointmentId: '',
    appointment: null,
    loading: true,
    canManageAppointment: false,
    canCancelAppointment: false,
    userInfo: null,
    queueInfo: null,
    texts: {
      missingId: '\u7f3a\u5c11\u9884\u7ea6 ID',
      loading: '\u52a0\u8f7d\u4e2d...',
      loadFailed: '\u52a0\u8f7d\u9884\u7ea6\u8be6\u60c5\u5931\u8d25',
      retry: '\u91cd\u8bd5',
      back: '\u8fd4\u56de',
      doctorInfo: '\u533b\u751f\u4fe1\u606f',
      appointmentInfo: '\u9884\u7ea6\u4fe1\u606f',
      patientInfo: '\u60a3\u8005\u4fe1\u606f',
      queueInfo: '\u6392\u961f\u4fe1\u606f',
      name: '\u59d3\u540d\uff1a',
      date: '\u65e5\u671f\uff1a',
      time: '\u65f6\u95f4\uff1a',
      seq: '\u53f7\u5e8f\uff1a',
      createTime: '\u521b\u5efa\u65f6\u95f4\uff1a',
      phone: '\u624b\u673a\u53f7\uff1a',
      remark: '\u5907\u6ce8\uff1a',
      currentCalled: '\u5f53\u524d\u53eb\u53f7\uff1a',
      yourSeq: '\u60a8\u7684\u53f7\u5e8f\uff1a',
      aheadCount: '\u524d\u65b9\u4eba\u6570\uff1a',
      noPermission: '\u65e0\u6743\u9650\u64cd\u4f5c',
      noPermissionView: '\u65e0\u6743\u9650\u67e5\u770b\u8be5\u9884\u7ea6',
      notFound: '\u9884\u7ea6\u8bb0\u5f55\u4e0d\u5b58\u5728',
      actionConfirmTitle: '\u786e\u8ba4\u9884\u7ea6',
      actionConfirmContent: '\u786e\u8ba4\u8be5\u9884\u7ea6\u5417\uff1f',
      actionConfirmSuccess: '\u9884\u7ea6\u5df2\u786e\u8ba4',
      actionConfirmFail: '\u786e\u8ba4\u9884\u7ea6\u5931\u8d25',
      actionCompleteTitle: '\u5b8c\u6210\u5c31\u8bca',
      actionCompleteContent: '\u5c06\u8be5\u9884\u7ea6\u6807\u8bb0\u4e3a\u5df2\u5b8c\u6210\uff1f',
      actionCompleteSuccess: '\u5c31\u8bca\u5df2\u5b8c\u6210',
      actionCompleteFail: '\u5b8c\u6210\u5c31\u8bca\u5931\u8d25',
      actionCancelTitle: '\u53d6\u6d88\u9884\u7ea6',
      actionCancelContent: '\u786e\u8ba4\u53d6\u6d88\u8be5\u9884\u7ea6\u5417\uff1f',
      actionCancelSuccess: '\u9884\u7ea6\u5df2\u53d6\u6d88',
      actionCancelFail: '\u53d6\u6d88\u9884\u7ea6\u5931\u8d25',
      actionCallTitle: '\u53eb\u53f7',
      actionCallContent: '\u786e\u8ba4\u547c\u53eb\u8be5\u60a3\u8005\u8fdb\u5165\u8bca\u5ba4\u5417\uff1f',
      actionCallSuccess: '\u5df2\u5b8c\u6210\u53eb\u53f7',
      actionCallFail: '\u53eb\u53f7\u5931\u8d25',
      btnConfirm: '\u786e\u8ba4\u9884\u7ea6',
      btnCall: '\u53eb\u53f7',
      btnComplete: '\u5b8c\u6210\u5c31\u8bca',
      btnCancel: '\u53d6\u6d88\u9884\u7ea6'
    }
  },

  onLoad(options = {}) {
    if (options.id) {
      this.setData({ appointmentId: options.id });
      this.loadAppointmentDetail();
    } else {
      this.setData({ uiState: 'error', errorText: this.data.texts.missingId });
    }
  },

  async loadAppointmentDetail() {
    this.setData({ loading: true, uiState: 'loading', errorText: '' });
    const { texts } = this.data;

    try {
      const userInfo = getCurrentUser();
      if (!userInfo) {
        wx.redirectTo({ url: '/pages/login/index' });
        return;
      }
      this.setData({ userInfo });

      const res = await getAppointmentDetail(this.data.appointmentId);
      const appointment = res.data;
      if (!appointment) {
        this.setData({ uiState: 'error', errorText: texts.notFound });
        return;
      }

      let myPatientId = '';
      if (userInfo.role === USER_ROLES.PATIENT) {
        try {
          const myPatientRes = await getMyPatientInfo();
          myPatientId = myPatientRes && myPatientRes.data ? String(myPatientRes.data.id || '') : '';
        } catch (error) {
          myPatientId = '';
        }
      }

      const isAdmin = userInfo.role === USER_ROLES.SUPER_ADMIN || userInfo.role === USER_ROLES.CLINIC_ADMIN;
      const isDoctor = userInfo.role === USER_ROLES.DOCTOR && userInfo.id === appointment.doctorId;
      const isPatient = userInfo.role === USER_ROLES.PATIENT && myPatientId === String(appointment.patientId || '');

      if (!isAdmin && !isDoctor && !isPatient) {
        this.setData({ uiState: 'error', errorText: texts.noPermissionView });
        return;
      }

      this.setData({
        appointment,
        canManageAppointment: isAdmin || isDoctor,
        canCancelAppointment: isAdmin || isDoctor || isPatient,
        uiState: 'ready'
      });

      if (isPatient && appointment.status === 'confirmed') {
        this.loadQueueInfo(appointment);
      }
    } catch (error) {
      const message = error.message || texts.loadFailed;
      this.setData({ uiState: 'error', errorText: message });
      Toast({ context: this, selector: '#t-toast', message });
    } finally {
      this.setData({ loading: false });
    }
  },

  async confirmAppointment() {
    if (!this.data.canManageAppointment) {
      Toast({ context: this, selector: '#t-toast', message: this.data.texts.noPermission });
      return;
    }
    const { texts } = this.data;
    wx.showModal({
      title: texts.actionConfirmTitle,
      content: texts.actionConfirmContent,
      success: async (res) => {
        if (!res.confirm) return;
        this.setData({ loading: true });
        try {
          await confirmAppointment(this.data.appointmentId);
          Toast({ context: this, selector: '#t-toast', message: texts.actionConfirmSuccess, theme: 'success' });
          this.loadAppointmentDetail();
        } catch (error) {
          Toast({ context: this, selector: '#t-toast', message: error.message || texts.actionConfirmFail });
        } finally {
          this.setData({ loading: false });
        }
      }
    });
  },

  async completeAppointment() {
    if (!this.data.canManageAppointment) {
      Toast({ context: this, selector: '#t-toast', message: this.data.texts.noPermission });
      return;
    }
    const { texts } = this.data;
    wx.showModal({
      title: texts.actionCompleteTitle,
      content: texts.actionCompleteContent,
      success: async (res) => {
        if (!res.confirm) return;
        this.setData({ loading: true });
        try {
          await completeAppointment(this.data.appointmentId);
          Toast({ context: this, selector: '#t-toast', message: texts.actionCompleteSuccess, theme: 'success' });
          this.loadAppointmentDetail();
        } catch (error) {
          Toast({ context: this, selector: '#t-toast', message: error.message || texts.actionCompleteFail });
        } finally {
          this.setData({ loading: false });
        }
      }
    });
  },

  async cancelAppointment() {
    if (!this.data.canCancelAppointment) {
      Toast({ context: this, selector: '#t-toast', message: this.data.texts.noPermission });
      return;
    }
    const { texts } = this.data;
    wx.showModal({
      title: texts.actionCancelTitle,
      content: texts.actionCancelContent,
      success: async (res) => {
        if (!res.confirm) return;
        this.setData({ loading: true });
        try {
          await cancelAppointmentApi(this.data.appointmentId);
          Toast({ context: this, selector: '#t-toast', message: texts.actionCancelSuccess, theme: 'success' });
          this.loadAppointmentDetail();
        } catch (error) {
          Toast({ context: this, selector: '#t-toast', message: error.message || texts.actionCancelFail });
        } finally {
          this.setData({ loading: false });
        }
      }
    });
  },

  async callPatient() {
    if (!this.data.canManageAppointment) {
      Toast({ context: this, selector: '#t-toast', message: this.data.texts.noPermission });
      return;
    }
    const { texts } = this.data;
    wx.showModal({
      title: texts.actionCallTitle,
      content: texts.actionCallContent,
      success: async (res) => {
        if (!res.confirm) return;
        this.setData({ loading: true });
        try {
          await callAppointment(this.data.appointmentId);
          Toast({ context: this, selector: '#t-toast', message: texts.actionCallSuccess, theme: 'success' });
          this.loadAppointmentDetail();
        } catch (error) {
          Toast({ context: this, selector: '#t-toast', message: error.message || texts.actionCallFail });
        } finally {
          this.setData({ loading: false });
        }
      }
    });
  },

  getStatusText(status) {
    return STATUS_TEXT[status] || status;
  },

  getStatusIcon(status) {
    const iconMap = {
      pending: 'clock',
      confirmed: 'check-circle',
      completed: 'success',
      cancelled: 'close-circle'
    };
    return iconMap[status] || 'info';
  },

  getStatusColor(status) {
    const colorMap = {
      pending: '#ff9800',
      confirmed: '#2196f3',
      completed: '#4caf50',
      cancelled: '#9e9e9e'
    };
    return colorMap[status] || '#222222';
  },

  formatTime(timeStr) {
    if (!timeStr) return '';
    const normalized = typeof timeStr === 'string' ? timeStr.replace(/-/g, '/') : timeStr;
    const date = new Date(normalized);
    if (Number.isNaN(date.getTime())) return '';
    return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date
      .getDate()
      .toString()
      .padStart(2, '0')} ${date.getHours().toString().padStart(2, '0')}:${date
      .getMinutes()
      .toString()
      .padStart(2, '0')}`;
  },

  async loadQueueInfo(appointment) {
    try {
      const res = await getAppointmentPosition({
        appointmentId: appointment.id || appointment.appointmentId
      });
      if (res.success && res.data) {
        const queueInfo = {
          ...res.data,
          aheadCount: res.data.position >= 0 ? res.data.position : 0
        };
        this.setData({ queueInfo });
      }
    } catch (error) {
      // ignore queue info errors
    }
  },

  retryLoad() {
    if (!this.data.appointmentId) {
      wx.navigateBack({ fail: () => wx.switchTab({ url: '/pages/appointment-main/index' }) });
      return;
    }
    this.loadAppointmentDetail();
  },

  goBack() {
    wx.navigateBack({ fail: () => wx.switchTab({ url: '/pages/appointment-main/index' }) });
  }
});
