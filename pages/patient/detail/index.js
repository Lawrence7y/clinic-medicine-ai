const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser } = require('../../../services/auth/index');
const { USER_ROLES } = require('../../../services/config/index');
const { getPatientDetail, getMyPatientInfo } = require('../../../services/patient/index');
const { getMedicalRecordList } = require('../../../services/medical-record/index');

Page({
  data: {
    patientId: '',
    patientInfo: {},
    recentRecords: [],
    canView: false,
    loading: false,
    uiState: 'loading',
    errorMessage: '',
    texts: {
      invalidPatientId: '\u60a3\u8005\u7f16\u53f7\u65e0\u6548',
      noPermission: '\u65e0\u6743\u9650\u67e5\u770b',
      loading: '\u52a0\u8f7d\u4e2d...',
      loadFailed: '\u52a0\u8f7d\u5931\u8d25',
      retry: '\u91cd\u8bd5',
      basicInfo: '\u57fa\u672c\u4fe1\u606f',
      name: '\u59d3\u540d',
      gender: '\u6027\u522b',
      age: '\u5e74\u9f84',
      phone: '\u624b\u673a\u53f7',
      address: '\u5730\u5740',
      healthInfo: '\u5065\u5eb7\u4fe1\u606f',
      allergy: '\u8fc7\u654f\u53f2',
      pastHistory: '\u65e2\u5f80\u53f2',
      bloodType: '\u8840\u578b',
      recentRecords: '\u8fd1\u671f\u75c5\u5386',
      viewAll: '\u67e5\u770b\u5168\u90e8',
      noRecords: '\u6682\u65e0\u75c5\u5386\u8bb0\u5f55',
      doctorPrefix: '\u533b\u751f\uff1a',
      male: '\u7537',
      female: '\u5973',
      unknown: '\u672a\u77e5'
    }
  },

  onLoad(options = {}) {
    if (!options.id) {
      Toast({ context: this, selector: '#t-toast', message: this.data.texts.invalidPatientId });
      setTimeout(() => wx.navigateBack(), 800);
      return;
    }
    this.setData({ patientId: String(options.id) });
    this.initPage();
  },

  async initPage() {
    const { texts } = this.data;
    const user = getCurrentUser();
    if (!user) {
      wx.redirectTo({ url: '/pages/login/index' });
      return;
    }
    this.setData({ loading: true, uiState: 'loading', errorMessage: '' });
    try {
      const detailRes = await getPatientDetail(this.data.patientId);
      const patientInfo = detailRes?.data || {};

      let myPatientId = '';
      if (user.role === USER_ROLES.PATIENT) {
        try {
          const mine = await getMyPatientInfo();
          myPatientId = String(mine?.data?.id || '');
        } catch (e) {
          myPatientId = '';
        }
      }

      const canView =
        user.role === USER_ROLES.SUPER_ADMIN ||
        user.role === USER_ROLES.CLINIC_ADMIN ||
        user.role === USER_ROLES.DOCTOR ||
        (user.role === USER_ROLES.PATIENT && myPatientId === String(patientInfo.id || this.data.patientId));

      if (!canView) {
        wx.showToast({ title: texts.noPermission, icon: 'none' });
        setTimeout(() => wx.navigateBack(), 1000);
        return;
      }

      const recordsRes = await getMedicalRecordList({
        patientId: this.data.patientId,
        page: 1,
        pageSize: 5
      });

      this.setData({
        canView: true,
        patientInfo,
        recentRecords: Array.isArray(recordsRes?.data?.list) ? recordsRes.data.list : [],
        uiState: 'ready'
      });
    } catch (error) {
      const message = error.message || texts.loadFailed;
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
    this.initPage();
  },

  getGenderText(gender) {
    if (gender === 'male') return this.data.texts.male;
    if (gender === 'female') return this.data.texts.female;
    return this.data.texts.unknown;
  },

  goToRecordDetail(e) {
    const id = e.currentTarget.dataset.id;
    if (!id) return;
    wx.navigateTo({ url: `/pages/medical/record-detail/index?id=${id}` });
  },

  goToMedicalHistory() {
    wx.navigateTo({ url: `/pages/patient/medical-history/index?patientId=${this.data.patientId}` });
  }
});
