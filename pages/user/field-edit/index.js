const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser, updateUserInfo } = require('../../../services/auth/index');
const { findPatientByUserId, updatePatient } = require('../../../services/patient/index');
const { syncDoctorName, syncPatientInfo } = require('../../../services/appointment/index');
const {
  syncDoctorName: syncDoctorNameToRecords,
  syncPatientInfo: syncPatientInfoToRecords
} = require('../../../services/medical-record/index');
const {
  syncOperatorName,
  syncPatientInfoToMedicine,
  syncDoctorNameToMedicine
} = require('../../../services/medicine/index');

const FIELD_CONFIG_MAP = {
  name: { title: '编辑姓名', placeholder: '请输入姓名', isDatePicker: false, isLongText: false },
  phone: { title: '编辑手机号', placeholder: '请输入手机号', isDatePicker: false, isLongText: false },
  wechat: { title: '编辑微信号', placeholder: '请输入微信号', isDatePicker: false, isLongText: false },
  birthday: { title: '编辑出生日期', placeholder: '', isDatePicker: true, isLongText: false },
  allergyHistory: { title: '编辑过敏史', placeholder: '请输入过敏史', isDatePicker: false, isLongText: true },
  pastHistory: { title: '编辑既往史', placeholder: '请输入既往史', isDatePicker: false, isLongText: true }
};

const calculateAge = (birthday) => {
  if (!birthday) return '';
  const birthDate = new Date(birthday);
  const today = new Date();
  let age = today.getFullYear() - birthDate.getFullYear();
  const monthDiff = today.getMonth() - birthDate.getMonth();
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
    age -= 1;
  }
  return age >= 0 ? age : '';
};

const buildPatientUpdatePayload = (patient = {}, field, value) => {
  const payload = {
    ...patient,
    [field]: value
  };
  if (field === 'birthday') {
    payload.age = calculateAge(value);
  }
  return payload;
};

Page({
  data: {
    type: '',
    value: '',
    title: '',
    placeholder: '',
    loading: false,
    isDatePicker: false,
    isLongText: false,
    stateMode: 'loading',
    stateTitle: '页面加载中',
    stateDescription: '',
    stateButtonText: '重试',
    retryAction: 'retry'
  },

  onLoad(options = {}) {
    this.lastOptions = options;
    this.initPage(options);
  },

  setAsyncState(mode, title, description = '', buttonText = '重试') {
    this.setData({
      stateMode: mode,
      stateTitle: title,
      stateDescription: description,
      stateButtonText: buttonText
    });
  },

  initPage(options = {}) {
    this.setData({ retryAction: 'retry' });
    this.setAsyncState('loading', '页面加载中', '请稍候...');

    try {
      const userInfo = getCurrentUser();
      if (!userInfo || !userInfo.id) {
        this.setData({ retryAction: 'login' });
        this.setAsyncState('error', '登录状态已失效', '请先重新登录后再编辑资料。', '去登录');
        return;
      }

      const config = FIELD_CONFIG_MAP[options.type];
      if (!config) {
        this.setData({ retryAction: 'back' });
        this.setAsyncState('error', '参数错误', '未识别要编辑的字段，请返回上一页重试。', '返回上一页');
        return;
      }

      const value = typeof options.name === 'string' ? options.name : '';
      this.setData({
        type: options.type,
        value,
        ...config,
        retryAction: 'retry'
      });
      wx.setNavigationBarTitle({ title: config.title });
      this.setAsyncState('success', '', '');
    } catch (error) {
      this.setData({ retryAction: 'retry' });
      this.setAsyncState(
        'error',
        '页面初始化失败',
        (error && error.message) || '请稍后重试。',
        '重试'
      );
    }
  },

  onStateRetry() {
    const { retryAction } = this.data;
    if (retryAction === 'login') {
      wx.redirectTo({ url: '/pages/login/index' });
      return;
    }
    if (retryAction === 'back') {
      this.goBack();
      return;
    }
    this.initPage(this.lastOptions || {});
  },

  goBack() {
    wx.navigateBack({ fail: () => wx.switchTab({ url: '/pages/user/user' }) });
  },

  onInputChange(e) {
    this.setData({ value: (e.detail && e.detail.value) || '' });
  },

  onDateChange(e) {
    this.setData({ value: (e.detail && e.detail.value) || '' });
  },

  async onSave() {
    if (this.data.stateMode !== 'success' || this.data.loading) return;

    const requiredFields = ['name', 'phone'];
    if (!this.data.value && requiredFields.includes(this.data.type)) {
      Toast({
        context: this,
        selector: '#t-toast',
        message: '请输入内容'
      });
      return;
    }

    this.setData({ loading: true });
    try {
      const userInfo = getCurrentUser();
      if (!userInfo || !userInfo.id) {
        throw new Error('用户未登录');
      }

      const oldName = userInfo.name;
      const newUserInfo = { ...userInfo, [this.data.type]: this.data.value };
      await updateUserInfo(userInfo.id, newUserInfo);

      if (userInfo.role === 'patient') {
        let patientId = null;
        try {
          const patientRes = await findPatientByUserId(userInfo.id);
          if (patientRes.data) {
            patientId = patientRes.data.id;
            await updatePatient(
              patientRes.data.id,
              buildPatientUpdatePayload(patientRes.data, this.data.type, this.data.value)
            );
          }
        } catch (err) {
          console.error('同步患者资料失败:', err);
        }

        if (patientId && (this.data.type === 'name' || this.data.type === 'phone')) {
          try {
            const updatedName = this.data.type === 'name' ? this.data.value : newUserInfo.name;
            const updatedPhone = this.data.type === 'phone' ? this.data.value : newUserInfo.phone;
            await syncPatientInfo(patientId, updatedName, updatedPhone);
            await syncPatientInfoToRecords(patientId, updatedName, updatedPhone);
            await syncPatientInfoToMedicine(patientId, updatedName, oldName);
          } catch (err) {
            console.error('同步患者关联数据失败:', err);
          }
        }
      }

      if (userInfo.role === 'doctor' && this.data.type === 'name') {
        try {
          await syncDoctorName(userInfo.id, this.data.value);
          await syncDoctorNameToRecords(userInfo.id, this.data.value);
          await syncDoctorNameToMedicine(userInfo.id, this.data.value, oldName);
        } catch (err) {
          console.error('同步医生姓名失败:', err);
        }
      }

      if (this.data.type === 'name') {
        try {
          await syncOperatorName(userInfo.id, this.data.value);
        } catch (err) {
          console.error('同步操作人姓名失败:', err);
        }
      }

      Toast({
        context: this,
        selector: '#t-toast',
        message: '保存成功',
        theme: 'success'
      });
      setTimeout(() => {
        wx.navigateBack();
      }, 1000);
    } catch (error) {
      Toast({
        context: this,
        selector: '#t-toast',
        message: (error && error.message) || '保存失败'
      });
    } finally {
      this.setData({ loading: false });
    }
  }
});
