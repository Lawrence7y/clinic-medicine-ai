const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser } = require('../../../services/auth/index');
const { USER_ROLES } = require('../../../services/config/index');
const { getMyPatientInfo } = require('../../../services/patient/index');
const { getMedicalRecordDetail, deleteMedicalRecord } = require('../../../services/medical-record/index');

Page({
  data: {
    recordId: '',
    record: {},
    uiState: 'loading',
    errorText: '',
    loading: true,
    canEdit: false,
    canUseAiAssistant: false,
    texts: {
      loading: '病历加载中...',
      loadFailed: '病历加载失败',
      retry: '重试',
      empty: '未找到病历信息',
      aiNoPermission: '仅医生或管理员可使用 AI 病历助手'
    }
  },

  onLoad(options = {}) {
    if (!options.id) {
      Toast({ context: this, selector: '#t-toast', message: '病历编号无效' });
      setTimeout(() => wx.navigateBack(), 800);
      return;
    }
    this.setData({ recordId: String(options.id) });
    this.loadRecordDetail();
  },

  async loadRecordDetail() {
    this.setData({ loading: true, uiState: 'loading', errorText: '' });
    try {
      const user = getCurrentUser();
      if (!user) {
        wx.redirectTo({ url: '/pages/login/index' });
        return;
      }

      const res = await getMedicalRecordDetail(this.data.recordId);
      const record = res?.data || {};
      if (!record || !record.id) {
        this.setData({
          record: {},
          canEdit: false,
          uiState: 'empty'
        });
        return;
      }

      let myPatientId = '';
      if (user.role === USER_ROLES.PATIENT) {
        try {
          const mine = await getMyPatientInfo();
          myPatientId = String(mine?.data?.id || '');
        } catch (e) {
          myPatientId = '';
        }
      }

      const isAdmin = user.role === USER_ROLES.SUPER_ADMIN || user.role === USER_ROLES.CLINIC_ADMIN;
      const isDoctorOwner = user.role === USER_ROLES.DOCTOR && String(user.id) === String(record.doctorId || '');
      const isPatientOwner = user.role === USER_ROLES.PATIENT && myPatientId === String(record.patientId || '');
      const canUseAiAssistant = isAdmin || user.role === USER_ROLES.DOCTOR;
      if (!isAdmin && !isDoctorOwner && !isPatientOwner) {
        wx.showToast({ title: '无权限访问', icon: 'none' });
        setTimeout(() => wx.navigateBack(), 1000);
        return;
      }

      this.setData({
        record,
        canEdit: isAdmin || isDoctorOwner,
        canUseAiAssistant,
        uiState: 'ready',
        errorText: ''
      });
    } catch (error) {
      const message = error.message || this.data.texts.loadFailed;
      this.setData({
        uiState: 'error',
        errorText: message
      });
      Toast({ context: this, selector: '#t-toast', message });
    } finally {
      this.setData({ loading: false });
    }
  },

  onRetry() {
    this.loadRecordDetail();
  },

  editRecord() {
    if (!this.data.canEdit) return;
    wx.navigateTo({ url: `/pages/medical/record-edit/index?id=${this.data.recordId}` });
  },

  deleteRecord() {
    if (!this.data.canEdit) return;
    wx.showModal({
      title: '删除病历',
      content: '确认删除这条病历吗？',
      success: async (res) => {
        if (!res.confirm) return;
        try {
          await deleteMedicalRecord(this.data.recordId);
          Toast({ context: this, selector: '#t-toast', message: '删除成功', theme: 'success' });
          setTimeout(() => wx.navigateBack(), 800);
        } catch (error) {
          Toast({ context: this, selector: '#t-toast', message: error.message || '删除失败' });
        }
      }
    });
  },

  getGenderText(gender) {
    if (gender === 'male') return '男';
    if (gender === 'female') return '女';
    return '-';
  },

  goToPatientDetail() {
    const patientId = this.data.record?.patientId;
    if (!patientId) return;
    wx.navigateTo({ url: `/pages/patient/detail/index?id=${patientId}` });
  },

  goToPrescriptionPage() {
    const prescription = this.data.record?.prescription || [];
    if (!Array.isArray(prescription) || prescription.length === 0) {
      Toast({ context: this, selector: '#t-toast', message: '暂无处方信息' });
      return;
    }
    const payload = encodeURIComponent(JSON.stringify(prescription));
    wx.navigateTo({ url: `/pages/medical/prescription/index?recordId=${this.data.recordId}&items=${payload}` });
  },

  goToMedicineDetail(e) {
    const medicineId = e.currentTarget.dataset.medicineId;
    if (!medicineId) return;
    wx.navigateTo({ url: `/pages/medicine/detail/index?id=${medicineId}` });
  },

  goToAiMedicalAssistant() {
    if (!this.data.canUseAiAssistant) {
      Toast({ context: this, selector: '#t-toast', message: this.data.texts.aiNoPermission });
      return;
    }
    wx.navigateTo({ url: `/pages/ai/medical-assistant/index?recordId=${this.data.recordId}` });
  }
});
