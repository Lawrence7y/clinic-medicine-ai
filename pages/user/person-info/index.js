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

const buildPatientUpdatePayload = (patient = {}, field, value, calculateAge) => {
  const payload = {
    ...patient,
    [field]: value
  };
  if (field === 'birthday') {
    payload.age = calculateAge(value);
  }
  return payload;
};

const getRoleText = (role) => {
  const roleMap = {
    super_admin: '超级管理员',
    clinic_admin: '诊所管理员',
    doctor: '医生',
    patient: '患者'
  };
  return roleMap[role] || role || '用户';
};

const getGenderText = (gender) => {
  if (gender === 'male') return '男';
  if (gender === 'female') return '女';
  return '-';
};

Page({
  data: {
    uiState: 'loading',
    errorText: '',
    userInfo: {},
    roleText: '用户',
    genderText: '-',
    editAllergyHistory: '',
    originalAllergyHistory: '',
    editPastHistory: '',
    originalPastHistory: '',
    editWechat: '',
    originalWechat: '',
    editName: '',
    originalName: '',
    age: '',
    saving: false
  },

  onLoad() {
    this.fetchData();
  },

  onShow() {
    this.fetchData();
  },

  calculateAge(birthday) {
    if (!birthday) return '';
    const birthDate = new Date(birthday);
    const today = new Date();
    let age = today.getFullYear() - birthDate.getFullYear();
    const monthDiff = today.getMonth() - birthDate.getMonth();
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) age -= 1;
    return age >= 0 ? age : '';
  },

  async fetchData() {
    this.setData({ uiState: 'loading', errorText: '' });
    try {
      const userInfo = getCurrentUser() || {};
      if (!userInfo || !userInfo.id) {
        wx.redirectTo({ url: '/pages/login/index' });
        return;
      }

      let mergedUserInfo = { ...userInfo };
      if (userInfo.role === 'patient' && userInfo.id) {
        try {
          const patientRes = await findPatientByUserId(userInfo.id);
          const patient = patientRes && patientRes.data ? patientRes.data : null;
          if (patient) {
            mergedUserInfo = {
              ...mergedUserInfo,
              name: patient.name || mergedUserInfo.name || '',
              phone: patient.phone || mergedUserInfo.phone || '',
              gender: patient.gender || mergedUserInfo.gender || '',
              birthday: patient.birthday || mergedUserInfo.birthday || '',
              allergyHistory: patient.allergyHistory || mergedUserInfo.allergyHistory || '',
              pastHistory: patient.pastHistory || mergedUserInfo.pastHistory || '',
              bloodType: patient.bloodType || mergedUserInfo.bloodType || '',
              wechat: patient.wechat || mergedUserInfo.wechat || ''
            };
          }
        } catch (error) {
          // keep profile from user cache
        }
      }

      const age = this.calculateAge(mergedUserInfo.birthday);
      this.setData({
        uiState: 'ready',
        userInfo: mergedUserInfo,
        roleText: getRoleText(mergedUserInfo.role),
        genderText: getGenderText(mergedUserInfo.gender),
        editAllergyHistory: mergedUserInfo.allergyHistory || '',
        originalAllergyHistory: mergedUserInfo.allergyHistory || '',
        editPastHistory: mergedUserInfo.pastHistory || '',
        originalPastHistory: mergedUserInfo.pastHistory || '',
        editWechat: mergedUserInfo.wechat || '',
        originalWechat: mergedUserInfo.wechat || '',
        editName: mergedUserInfo.name || '',
        originalName: mergedUserInfo.name || '',
        age
      });
    } catch (error) {
      this.setData({
        uiState: 'error',
        errorText: (error && error.message) || '加载个人信息失败'
      });
    }
  },

  retryLoad() {
    this.fetchData();
  },

  onClickCell({ currentTarget }) {
    const { type } = currentTarget.dataset;
    const { userInfo } = this.data;
    if (type === 'phone') {
      wx.navigateTo({
        url: `/pages/user/field-edit/index?name=${encodeURIComponent(userInfo.phone || '')}&type=phone`
      });
    } else if (type === 'gender') {
      this.showGenderPicker();
    } else if (type === 'bloodType') {
      this.showBloodTypePicker();
    }
  },

  onNameChange(e) {
    this.setData({ editName: (e.detail && e.detail.value) || '' });
  },

  async saveName() {
    await this.updateUserField('name', this.data.editName);
    this.setData({ originalName: this.data.editName });
  },

  onWechatChange(e) {
    this.setData({ editWechat: (e.detail && e.detail.value) || '' });
  },

  async saveWechat() {
    await this.updateUserField('wechat', this.data.editWechat);
    this.setData({ originalWechat: this.data.editWechat });
  },

  onAllergyHistoryChange(e) {
    this.setData({ editAllergyHistory: (e.detail && e.detail.value) || '' });
  },

  onPastHistoryChange(e) {
    this.setData({ editPastHistory: (e.detail && e.detail.value) || '' });
  },

  async saveAllergyHistory() {
    await this.updateUserField('allergyHistory', this.data.editAllergyHistory);
    this.setData({ originalAllergyHistory: this.data.editAllergyHistory });
  },

  async savePastHistory() {
    await this.updateUserField('pastHistory', this.data.editPastHistory);
    this.setData({ originalPastHistory: this.data.editPastHistory });
  },

  onBirthdayChange(e) {
    const birthday = e.detail.value;
    this.setData({ age: this.calculateAge(birthday) });
    this.updateUserField('birthday', birthday);
  },

  showGenderPicker() {
    wx.showActionSheet({
      itemList: ['男', '女', '清空'],
      success: (res) => {
        if (res.tapIndex === 0) this.updateUserField('gender', 'male');
        if (res.tapIndex === 1) this.updateUserField('gender', 'female');
        if (res.tapIndex === 2) this.updateUserField('gender', '');
      }
    });
  },

  showBloodTypePicker() {
    wx.showActionSheet({
      itemList: ['A', 'B', 'AB', 'O', '清空'],
      success: (res) => {
        if (res.tapIndex < 4) {
          const bloodTypes = ['A', 'B', 'AB', 'O'];
          this.updateUserField('bloodType', bloodTypes[res.tapIndex]);
        } else if (res.tapIndex === 4) {
          this.updateUserField('bloodType', '');
        }
      }
    });
  },

  async updateUserField(field, value) {
    if (this.data.saving) return;
    this.setData({ saving: true });
    try {
      const userInfo = getCurrentUser();
      if (!userInfo || !userInfo.id) throw new Error('用户未登录');
      const oldName = userInfo.name;
      const newUserInfo = { ...userInfo, [field]: value };
      await updateUserInfo(userInfo.id, newUserInfo);

      if (userInfo.role === 'patient') {
        let patientId = null;
        try {
          const patientRes = await findPatientByUserId(userInfo.id);
          if (patientRes.data) {
            patientId = patientRes.data.id;
            await updatePatient(
              patientId,
              buildPatientUpdatePayload(patientRes.data, field, value, this.calculateAge.bind(this))
            );
          }
        } catch (err) {
          // keep main flow successful
        }
        if (patientId && (field === 'name' || field === 'phone')) {
          try {
            const updatedName = field === 'name' ? value : newUserInfo.name;
            const updatedPhone = field === 'phone' ? value : newUserInfo.phone;
            await syncPatientInfo(patientId, updatedName, updatedPhone);
            await syncPatientInfoToRecords(patientId, updatedName, updatedPhone);
            await syncPatientInfoToMedicine(patientId, updatedName, oldName);
          } catch (err) {
            // ignore sync failures
          }
        }
      }

      if (userInfo.role === 'doctor' && field === 'name') {
        try {
          await syncDoctorName(userInfo.id, value);
          await syncDoctorNameToRecords(userInfo.id, value);
          await syncDoctorNameToMedicine(userInfo.id, value, oldName);
        } catch (err) {
          // ignore sync failures
        }
      }

      if (field === 'name') {
        try {
          await syncOperatorName(userInfo.id, value);
        } catch (err) {
          // ignore sync failures
        }
      }

      Toast({ context: this, selector: '#t-toast', message: '更新成功', theme: 'success' });
      this.fetchData();
    } catch (error) {
      Toast({ context: this, selector: '#t-toast', message: error.message || '更新失败' });
    } finally {
      this.setData({ saving: false });
    }
  }
});
