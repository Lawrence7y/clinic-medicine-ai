const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser } = require('../../../services/auth/index');
const { USER_ROLES } = require('../../../services/config/index');
const { getAppointmentList, cancelAppointment: cancelAppointmentApi } = require('../../../services/appointment/index');

const STATUS_MAP = {
  pending: { text: '\u5f85\u786e\u8ba4', theme: 'warning' },
  confirmed: { text: '\u5df2\u786e\u8ba4', theme: 'primary' },
  completed: { text: '\u5df2\u5b8c\u6210', theme: 'success' },
  cancelled: { text: '\u5df2\u53d6\u6d88', theme: 'default' },
  expired: { text: '\u5df2\u8fc7\u671f', theme: 'default' }
};

Page({
  data: {
    uiState: 'loading',
    errorMessage: '',
    searchKeyword: '',
    selectedStatus: '',
    appointmentList: [],
    rawList: [],
    loading: false,
    userInfo: null,
    calledAlert: null,
    isPatientView: false,
    isManagementView: false,
    texts: {
      myAppointments: '\u6211\u7684\u9884\u7ea6',
      appointmentManage: '\u9884\u7ea6\u7ba1\u7406',
      searchPlaceholder: '\u641c\u7d22\u9884\u7ea6\u8bb0\u5f55',
      all: '\u5168\u90e8',
      pending: '\u5f85\u786e\u8ba4',
      confirmed: '\u5df2\u786e\u8ba4',
      completed: '\u5df2\u5b8c\u6210',
      cancelled: '\u5df2\u53d6\u6d88',
      loading: '\u52a0\u8f7d\u4e2d...',
      loadFailed: '\u52a0\u8f7d\u5931\u8d25\uff0c\u8bf7\u7a0d\u540e\u91cd\u8bd5',
      retry: '\u91cd\u8bd5',
      doctorLabel: '\u533b\u751f\uff1a',
      dateLabel: '\u9884\u7ea6\u65e5\u671f\uff1a',
      timeLabel: '\u9884\u7ea6\u65f6\u95f4\uff1a',
      seqLabel: '\u5c31\u8bca\u5e8f\u53f7\uff1a',
      detail: '\u8be6\u60c5',
      cancel: '\u53d6\u6d88',
      calledTag: '\u5df2\u53eb\u53f7',
      calledTitle: '\u8bf7\u51c6\u5907\u5c31\u8bca',
      calledDescPrefix: '',
      calledDescSuffix: '\u533b\u751f\u6b63\u5728\u53eb\u53f7',
      calledSeqPrefix: '\uff08',
      calledSeqSuffix: '\u53f7\uff09',
      calledHint: '\u533b\u751f\u6b63\u5728\u53eb\u53f7\uff0c\u8bf7\u5c3d\u5feb\u5230\u8bca\u3002',
      calledModalTitle: '\u5c31\u8bca\u63d0\u9192',
      calledModalConfirm: '\u6211\u77e5\u9053\u4e86',
      noDoctor: '\u672a\u5206\u914d\u533b\u751f',
      noPatient: '\u672a\u767b\u8bb0\u60a3\u8005',
      empty: '\u6682\u65e0\u9884\u7ea6\u8bb0\u5f55',
      cancelTitle: '\u53d6\u6d88\u9884\u7ea6',
      cancelConfirm: '\u786e\u5b9a\u8981\u53d6\u6d88\u8be5\u9884\u7ea6\u5417\uff1f',
      cancelSuccess: '\u9884\u7ea6\u5df2\u53d6\u6d88',
      cancelFailed: '\u53d6\u6d88\u9884\u7ea6\u5931\u8d25',
      loadListFailed: '\u52a0\u8f7d\u9884\u7ea6\u8bb0\u5f55\u5931\u8d25'
    }
  },

  onShow() {
    this.initPage();
  },

  onPullDownRefresh() {
    this.refreshData().finally(() => wx.stopPullDownRefresh());
  },

  initPage() {
    const userInfo = getCurrentUser();
    if (!userInfo) {
      wx.redirectTo({ url: '/pages/login/index' });
      return;
    }

    const isPatientView = userInfo.role === USER_ROLES.PATIENT;
    const isManagementView = userInfo.role === USER_ROLES.DOCTOR
      || userInfo.role === USER_ROLES.SUPER_ADMIN
      || userInfo.role === USER_ROLES.CLINIC_ADMIN;

    wx.setNavigationBarTitle({
      title: isPatientView ? this.data.texts.myAppointments : this.data.texts.appointmentManage
    });

    this.setData({ userInfo, isPatientView, isManagementView });
    this.refreshData();
  },

  formatStatus(status) {
    return STATUS_MAP[status] || { text: status || '-', theme: 'default' };
  },

  mapDisplayList(list = []) {
    const { isPatientView, isManagementView, texts } = this.data;
    return list.map((item) => {
      const statusDisplay = this.formatStatus(item.status);
      return {
        ...item,
        statusText: statusDisplay.text,
        statusTheme: statusDisplay.theme,
        cardTitle: isPatientView ? (item.doctorName || texts.noDoctor) : (item.patientName || texts.noPatient),
        cardSubtitle: isManagementView && item.doctorName ? `${texts.doctorLabel}${item.doctorName}` : '',
        isCalledHighlighted: isPatientView && item.called === 1,
        showCalledHint: isPatientView && item.called === 1 && item.status === 'confirmed'
      };
    });
  },

  async refreshData() {
    this.setData({
      uiState: 'loading',
      errorMessage: '',
      appointmentList: [],
      rawList: [],
      calledAlert: null
    });
    await this.loadAppointments();
  },

  async loadAppointments() {
    if (this.data.loading) return;
    this.setData({ loading: true });
    const { texts } = this.data;
    try {
      const requestParams = { page: 1, pageSize: 10000 };
      if (this.data.userInfo.role === USER_ROLES.PATIENT) {
        requestParams.patientId = this.data.userInfo.id;
      }
      if (this.data.selectedStatus) {
        requestParams.status = this.data.selectedStatus;
      }

      const response = await getAppointmentList(requestParams);
      const fetchedList = response.data.list || [];

      let calledAlert = null;
      if (this.data.isPatientView) {
        fetchedList.forEach((item) => {
          if (!calledAlert && item.called === 1 && item.status === 'confirmed') {
            calledAlert = item;
          }
        });
      }

      this.setData({
        rawList: fetchedList,
        appointmentList: this.mapDisplayList(fetchedList),
        calledAlert,
        uiState: 'ready'
      });

      if (calledAlert && this.data.isPatientView) {
        const doctorName = calledAlert.doctorName || '';
        const seq = calledAlert.sequenceNumber || '-';
        wx.showModal({
          title: texts.calledModalTitle,
          content: `${doctorName}${texts.calledDescSuffix}（${seq}\u53f7\uff09`,
          showCancel: false,
          confirmText: texts.calledModalConfirm
        });
      }
    } catch (error) {
      const message = error.message || texts.loadListFailed;
      this.setData({
        uiState: 'error',
        errorMessage: message
      });
      Toast({ context: this, selector: '#t-toast', message });
    } finally {
      this.setData({ loading: false });
    }
  },

  onRetry() {
    this.refreshData();
  },

  onSearchChange(e) {
    this.setData({ searchKeyword: e.detail.value || '' });
  },

  onSearch() {
    const keyword = (this.data.searchKeyword || '').toLowerCase().trim();
    if (!keyword) {
      this.setData({ appointmentList: this.mapDisplayList(this.data.rawList) });
      return;
    }
    const filteredList = this.data.rawList.filter((item) => {
      const doctorName = (item.doctorName || '').toLowerCase();
      const patientName = (item.patientName || '').toLowerCase();
      return doctorName.includes(keyword) || patientName.includes(keyword);
    });
    this.setData({ appointmentList: this.mapDisplayList(filteredList) });
  },

  selectStatus(e) {
    this.setData({ selectedStatus: e.currentTarget.dataset.status || '' });
    this.refreshData();
  },

  goToAppointmentDetail(e) {
    const id = e.currentTarget.dataset.id;
    if (!id) return;
    wx.navigateTo({ url: `/pages/appointment/appointment-detail/index?id=${id}` });
  },

  cancelAppointment(e) {
    const appointmentId = e.currentTarget.dataset.id;
    if (!appointmentId) return;
    const { texts } = this.data;
    wx.showModal({
      title: texts.cancelTitle,
      content: texts.cancelConfirm,
      success: async (res) => {
        if (!res.confirm) return;
        this.setData({ loading: true });
        try {
          await cancelAppointmentApi(appointmentId);
          Toast({ context: this, selector: '#t-toast', message: texts.cancelSuccess, theme: 'success' });
          this.refreshData();
        } catch (error) {
          Toast({ context: this, selector: '#t-toast', message: error.message || texts.cancelFailed });
        } finally {
          this.setData({ loading: false });
        }
      }
    });
  }
});
