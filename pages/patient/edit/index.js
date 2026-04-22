const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser } = require('../../../services/auth/index');
const { USER_ROLES } = require('../../../services/config/index');
const { getPatientDetail, updatePatient, createPatient } = require('../../../services/patient/index');

Page({
  data: {
    patientId: '',
    isEdit: false,
    uiState: 'loading',
    errorText: '',
    loading: false,
    submitting: false,
    genderOptions: [
      { label: '\u7537', value: 'male' },
      { label: '\u5973', value: 'female' }
    ],
    bloodTypeOptions: [
      { label: 'A\u578b', value: 'A' },
      { label: 'B\u578b', value: 'B' },
      { label: 'AB\u578b', value: 'AB' },
      { label: 'O\u578b', value: 'O' },
      { label: '\u672a\u586b\u5199', value: '' }
    ],
    texts: {
      editTitle: '\u7f16\u8f91\u60a3\u8005\u4fe1\u606f',
      createTitle: '\u65b0\u5efa\u60a3\u8005',
      basicInfo: '\u57fa\u672c\u4fe1\u606f',
      healthInfo: '\u5065\u5eb7\u4fe1\u606f',
      name: '\u59d3\u540d',
      namePlaceholder: '\u8bf7\u8f93\u5165\u59d3\u540d',
      gender: '\u6027\u522b',
      male: '\u7537',
      female: '\u5973',
      age: '\u5e74\u9f84',
      agePlaceholder: '\u8bf7\u8f93\u5165\u5e74\u9f84',
      phone: '\u8054\u7cfb\u7535\u8bdd',
      phonePlaceholder: '\u8bf7\u8f93\u5165\u8054\u7cfb\u7535\u8bdd',
      birthday: '\u751f\u65e5',
      birthdayPlaceholder: '\u8bf7\u9009\u62e9\u751f\u65e5',
      wechat: '\u5fae\u4fe1\u53f7',
      wechatPlaceholder: '\u8bf7\u8f93\u5165\u5fae\u4fe1\u53f7',
      address: '\u5730\u5740',
      addressPlaceholder: '\u8bf7\u8f93\u5165\u5730\u5740',
      bloodType: '\u8840\u578b',
      bloodTypeSuffix: '\u578b',
      bloodTypePlaceholder: '\u8bf7\u9009\u62e9\u8840\u578b',
      allergyHistory: '\u8fc7\u654f\u53f2',
      allergyPlaceholder: '\u8bf7\u8f93\u5165\u8fc7\u654f\u53f2',
      pastHistory: '\u65e2\u5f80\u53f2',
      pastHistoryPlaceholder: '\u8bf7\u8f93\u5165\u65e2\u5f80\u53f2',
      save: '\u4fdd\u5b58\u4fee\u6539',
      create: '\u521b\u5efa\u60a3\u8005',
      cancel: '\u53d6\u6d88',
      noEditPermission: '\u65e0\u6743\u9650\u7f16\u8f91\u60a3\u8005\u4fe1\u606f',
      loading: '\u6b63\u5728\u52a0\u8f7d\u60a3\u8005\u4fe1\u606f...',
      loadFailed: '\u52a0\u8f7d\u5931\u8d25',
      retry: '\u91cd\u8bd5',
      goBack: '\u8fd4\u56de',
      inputName: '\u8bf7\u8f93\u5165\u59d3\u540d',
      inputPhone: '\u8bf7\u8f93\u5165\u8054\u7cfb\u7535\u8bdd',
      updateSuccess: '\u60a3\u8005\u4fe1\u606f\u66f4\u65b0\u6210\u529f',
      createSuccess: '\u60a3\u8005\u521b\u5efa\u6210\u529f',
      operationFailed: '\u64cd\u4f5c\u5931\u8d25'
    },
    formData: {
      name: '',
      gender: 'male',
      age: '',
      phone: '',
      address: '',
      allergyHistory: '',
      pastHistory: '',
      bloodType: '',
      wechat: '',
      birthday: ''
    }
  },

  onLoad(options = {}) {
    this.setData({ patientId: options.id || '' });
    this.initPage();
  },

  async initPage() {
    const userInfo = getCurrentUser();
    const { texts } = this.data;
    if (!userInfo) {
      wx.redirectTo({ url: '/pages/login/index' });
      return;
    }

    const isAdmin = userInfo.role === USER_ROLES.SUPER_ADMIN || userInfo.role === USER_ROLES.CLINIC_ADMIN;
    const isDoctor = userInfo.role === USER_ROLES.DOCTOR;

    if (!isAdmin && !isDoctor) {
      wx.showToast({
        title: texts.noEditPermission,
        icon: 'none'
      });
      setTimeout(() => {
        wx.navigateBack();
      }, 1500);
      return;
    }

    if (this.data.patientId) {
      this.setData({ isEdit: true });
      await this.loadPatientData();
      return;
    }

    this.setData({
      uiState: 'ready',
      errorText: ''
    });
  },

  async loadPatientData() {
    const { texts } = this.data;
    this.setData({
      loading: true,
      uiState: 'loading',
      errorText: ''
    });

    try {
      const res = await getPatientDetail(this.data.patientId);
      const patient = res.data;

      this.setData({
        formData: {
          name: patient.name || '',
          gender: patient.gender || 'male',
          age: patient.age ? patient.age.toString() : '',
          phone: patient.phone || '',
          address: patient.address || '',
          allergyHistory: patient.allergyHistory || '',
          pastHistory: patient.pastHistory || '',
          bloodType: patient.bloodType || '',
          wechat: patient.wechat || '',
          birthday: patient.birthday || '',
          avatar: patient.avatar || ''
        },
        uiState: 'ready',
        errorText: ''
      });
    } catch (error) {
      const message = error.message || texts.loadFailed;
      Toast({
        context: this,
        selector: '#t-toast',
        message
      });
      this.setData({
        uiState: 'error',
        errorText: message
      });
    } finally {
      this.setData({ loading: false });
    }
  },

  retryLoad() {
    if (!this.data.patientId) {
      this.setData({
        uiState: 'ready',
        errorText: ''
      });
      return;
    }
    this.loadPatientData();
  },

  onFieldChange(e) {
    const { field } = e.currentTarget.dataset;
    const { value } = e.detail;
    this.setData({ [`formData.${field}`]: value });
  },

  onGenderChange(e) {
    const index = Number(e.detail.value);
    const selected = this.data.genderOptions[index];
    if (!selected) return;
    this.setData({
      'formData.gender': selected.value
    });
  },

  onBloodTypeChange(e) {
    const index = Number(e.detail.value);
    const selected = this.data.bloodTypeOptions[index];
    if (!selected) return;
    this.setData({
      'formData.bloodType': selected.value
    });
  },

  onBirthdayChange(e) {
    this.setData({
      'formData.birthday': e.detail.value
    });
  },

  async submitForm() {
    if (this.data.submitting) return;

    const { formData, texts } = this.data;

    if (!formData.name) {
      Toast({
        context: this,
        selector: '#t-toast',
        message: texts.inputName
      });
      return;
    }

    if (!formData.phone) {
      Toast({
        context: this,
        selector: '#t-toast',
        message: texts.inputPhone
      });
      return;
    }

    this.setData({ loading: true, submitting: true });

    try {
      if (this.data.isEdit) {
        await updatePatient(this.data.patientId, formData);
        Toast({
          context: this,
          selector: '#t-toast',
          message: texts.updateSuccess,
          theme: 'success'
        });
      } else {
        await createPatient(formData);
        Toast({
          context: this,
          selector: '#t-toast',
          message: texts.createSuccess,
          theme: 'success'
        });
      }

      setTimeout(() => {
        wx.navigateBack();
      }, 1500);
    } catch (error) {
      Toast({
        context: this,
        selector: '#t-toast',
        message: error.message || texts.operationFailed
      });
    } finally {
      this.setData({ loading: false, submitting: false });
    }
  },

  goBack() {
    wx.navigateBack();
  }
});
