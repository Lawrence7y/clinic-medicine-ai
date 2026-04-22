const { getCurrentUser } = require('../../../services/auth/index');
const { USER_ROLES } = require('../../../services/config/index');
const { getMyPatientInfo } = require('../../../services/patient/index');
const { getMedicalRecordList } = require('../../../services/medical-record/index');
const { getMyDispensedMedicinesGrouped } = require('../../../services/medicine/index');
const { getAppointmentReminders, getComingAppointments } = require('../../../services/appointment/index');

const DAY_MS = 24 * 60 * 60 * 1000;

const calcDaysToExpiry = (expiryDate) => {
  if (!expiryDate) return null;
  const now = new Date();
  now.setHours(0, 0, 0, 0);
  const target = new Date(expiryDate);
  if (Number.isNaN(target.getTime())) return null;
  target.setHours(0, 0, 0, 0);
  return Math.floor((target.getTime() - now.getTime()) / DAY_MS);
};

Page({
  data: {
    uiState: 'loading',
    errorText: '',
    patientInfo: null,
    prescriptions: [],
    medicationReminders: [],
    revisitReminders: [],
    historySummary: {
      totalVisits: 0,
      lastVisitTime: '',
      commonDiagnoses: []
    },
    texts: {
      loading: '患者服务中心加载中...',
      loadFailed: '患者服务中心加载失败',
      retry: '重试',
      noPermission: '仅患者可访问',
      noData: '暂无数据',
      noArchiveTitle: '暂无患者档案',
      noArchiveHint: '请先联系诊所完成患者档案绑定。',
      permissionDenied: '暂无权限访问患者服务中心',
      sessionInvalid: '当前登录会话已失效，请重新登录'
    }
  },

  onLoad() {
    this.initPage();
  },

  onShow() {
    if (this.data.uiState === 'ready') {
      this.loadData();
    }
  },

  async initPage() {
    this.setData({ uiState: 'loading', errorText: '' });
    const user = getCurrentUser();
    if (!user) {
      wx.redirectTo({ url: '/pages/login/index' });
      return;
    }
    if (user.role !== USER_ROLES.PATIENT) {
      this.setData({
        uiState: 'error',
        errorText: this.data.texts.noPermission
      });
      return;
    }
    await this.loadData();
  },

  async loadData() {
    try {
      const [patientRes, recordRes, medicineRes, reminderRes, comingRes] = await Promise.all([
        getMyPatientInfo(),
        getMedicalRecordList({ page: 1, pageSize: 100 }),
        getMyDispensedMedicinesGrouped(),
        getAppointmentReminders(),
        getComingAppointments()
      ]);

      const patientInfo = (patientRes && patientRes.data) || null;
      const records = ((recordRes && recordRes.data && recordRes.data.list) || [])
        .slice()
        .sort((left, right) => String(right.visitTime || '').localeCompare(String(left.visitTime || '')));
      const dispensedList = (medicineRes && medicineRes.data) || [];
      const reminders = ((reminderRes && reminderRes.data && reminderRes.data.list) || [])
        .filter((item) => item.scene === 'before_visit' || item.scene === 'appointment_created' || item.scene === 'appointment_rescheduled');
      const comingAppointments = Array.isArray(comingRes?.data) ? comingRes.data : [];

      if (!patientInfo) {
        this.setData({
          uiState: 'empty',
          errorText: '',
          patientInfo: null,
          prescriptions: [],
          medicationReminders: [],
          revisitReminders: [],
          historySummary: {
            totalVisits: 0,
            lastVisitTime: '',
            commonDiagnoses: []
          }
        });
        return;
      }

      const prescriptions = this.buildPrescriptions(records);
      const medicationReminders = this.buildMedicationReminders(dispensedList);
      const revisitReminders = this.buildRevisitReminders(reminders, comingAppointments);
      const historySummary = this.buildHistorySummary(records);

      this.setData({
        uiState: 'ready',
        errorText: '',
        patientInfo,
        prescriptions,
        medicationReminders,
        revisitReminders,
        historySummary
      });
    } catch (error) {
      this.setData({
        uiState: 'error',
        errorText: this.normalizeErrorMessage(error)
      });
    }
  },

  normalizeErrorMessage(error) {
    if (!error) return this.data.texts.loadFailed;
    if (error.type === 'forbidden') return this.data.texts.permissionDenied;
    if (error.type === 'kickout' || error.type === 'unauth') return this.data.texts.sessionInvalid;
    return error.message || this.data.texts.loadFailed;
  },

  buildPrescriptions(records = []) {
    const list = [];
    records.forEach((record) => {
      const prescription = Array.isArray(record.prescription) ? record.prescription : [];
      prescription.forEach((item) => {
        list.push({
          recordId: record.id,
          visitTime: record.visitTime,
          diagnosis: record.diagnosis || '',
          medicineId: item.medicineId || '',
          medicineName: item.name || '',
          dosage: item.dosage || '',
          frequency: item.frequency || '',
          days: item.days || ''
        });
      });
    });
    return list.slice(0, 20);
  },

  buildMedicationReminders(dispensedList = []) {
    return dispensedList
      .map((item) => {
        const daysToExpiry = calcDaysToExpiry(item.expiryDate);
        let expiryHint = '有效期未设置';
        if (daysToExpiry !== null) {
          if (daysToExpiry < 0) expiryHint = '已过期';
          else if (daysToExpiry <= 7) expiryHint = `还有 ${daysToExpiry} 天过期`;
          else expiryHint = `有效期还有 ${daysToExpiry} 天`;
        }
        return {
          medicineId: item.medicineId || '',
          medicineName: item.medicineName || '',
          doctorName: item.doctorName || '-',
          totalQuantity: item.totalQuantity || 0,
          expiryHint,
          latestRecordTime: item.latestRecordTime || ''
        };
      })
      .sort((left, right) => String(right.latestRecordTime || '').localeCompare(String(left.latestRecordTime || '')))
      .slice(0, 20);
  },

  buildRevisitReminders(reminders = [], comingAppointments = []) {
    const merged = [];
    reminders.forEach((item) => {
      merged.push({
        appointmentId: item.appointmentId || item.id,
        doctorName: item.doctorName || '-',
        appointmentDate: item.appointmentDate || '-',
        appointmentTime: item.appointmentTime || '-',
        sceneText: item.sceneText || '复诊提醒'
      });
    });
    comingAppointments.forEach((item) => {
      merged.push({
        appointmentId: item.appointmentId || item.id,
        doctorName: item.doctorName || '-',
        appointmentDate: item.appointmentDate || '-',
        appointmentTime: item.appointmentTime || '-',
        sceneText: '即将就诊'
      });
    });

    const dedupMap = {};
    merged.forEach((item) => {
      const key = String(item.appointmentId || `${item.appointmentDate}_${item.appointmentTime}_${item.doctorName}`);
      if (!dedupMap[key]) dedupMap[key] = item;
    });
    return Object.keys(dedupMap).map((key) => dedupMap[key]).slice(0, 20);
  },

  buildHistorySummary(records = []) {
    const diagnosisCount = {};
    records.forEach((item) => {
      const diagnosis = String(item.diagnosis || '').trim();
      if (!diagnosis) return;
      diagnosisCount[diagnosis] = (diagnosisCount[diagnosis] || 0) + 1;
    });

    const commonDiagnoses = Object.keys(diagnosisCount)
      .sort((left, right) => diagnosisCount[right] - diagnosisCount[left])
      .slice(0, 3);

    return {
      totalVisits: records.length,
      lastVisitTime: records[0] ? (records[0].visitTime || '-') : '-',
      commonDiagnoses
    };
  },

  retryLoad() {
    this.initPage();
  },

  goToMedicineDetail(e) {
    const medicineId = e.currentTarget.dataset.medicineId;
    if (!medicineId) return;
    wx.navigateTo({ url: `/pages/medicine/detail/index?id=${medicineId}` });
  },

  goToRecordDetail(e) {
    const recordId = e.currentTarget.dataset.recordId;
    if (!recordId) return;
    wx.navigateTo({ url: `/pages/medical/record-detail/index?id=${recordId}` });
  }
});
