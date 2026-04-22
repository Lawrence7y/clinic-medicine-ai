const { post, get } = require('../_utils/request');
const { getCurrentUser } = require('../auth/index');
const { USER_ROLES } = require('../config/index');

const safeJsonParse = (value, fallback = []) => {
  if (value == null || value === '') return fallback;
  if (typeof value !== 'string') return value;
  try {
    return JSON.parse(value);
  } catch (error) {
    return fallback;
  }
};


const getMedicalRecordList = (params = {}) => {
  return new Promise((resolve, reject) => {
    const currentUser = getCurrentUser && getCurrentUser();
    const requestBody = {
      pageNum: params.page || 1,
      pageSize: params.pageSize || 10,
      patientId: params.patientId ? Number(params.patientId) : null,
      patientName: params.patientName,
      patientPhone: params.patientPhone,
      doctorId: params.doctorId,
      startDate: params.startDate,
      endDate: params.endDate
    };

    if (currentUser && currentUser.role === USER_ROLES.PATIENT) {
      requestBody.patientName = null;
      requestBody.patientPhone = null;
      requestBody.doctorId = null;
    }
    // 医生可查看全部病历（已移除doctorId限制）
    // else if (currentUser && currentUser.role === USER_ROLES.DOCTOR) {
    //   requestBody.doctorId = currentUser.id ? Number(currentUser.id) : null;
    // }

    post('/api/clinic/medical/list', {
      ...requestBody
    }).then((res) => {
      const rows = res.data.rows || res.data.list || [];
      const list = rows.map(r => ({
        id: (r.recordId || r.record_id || r.id).toString(),
        patientId: (r.patientId || r.patient_id)?.toString(),
        patientName: r.patientName || r.patient_name,
        patientGender: r.patientGender || r.patient_gender,
        patientAge: r.patientAge || r.patient_age,
        patientPhone: r.patientPhone || r.patient_phone,
        patientBirthday: r.patientBirthday || r.patient_birthday,
        patientBloodType: r.patientBloodType || r.patient_blood_type,
        doctorId: (r.doctorId || r.doctor_id)?.toString(),
        doctorName: r.doctorName || r.doctor_name,
        visitTime: r.visitTime || r.visit_time,
        chiefComplaint: r.chiefComplaint || r.chief_complaint,
        presentIllness: r.presentIllness || r.present_illness,
        pastHistory: r.pastHistory || r.past_history,
        allergyHistory: r.allergyHistory || r.allergy_history,
        physicalExam: r.physicalExam || r.physical_exam,
        diagnosis: r.diagnosis,
        treatment: r.treatment,
        prescription: safeJsonParse(r.prescription, []),
        attachments: safeJsonParse(r.attachments, []),
        followUp: r.followUp || r.follow_up,
        createdAt: r.createTime || r.create_time,
        updatedAt: r.updateTime || r.update_time
      }));
      
      resolve({
        success: true,
        data: {
          list,
          total: res.data.total || list.length,
          page: params.page || 1,
          pageSize: params.pageSize || 10
        }
      });
    }).catch((err) => {
      reject(err);
    });
  });
};

const getMedicalRecordDetail = (recordId) => {
  return new Promise((resolve, reject) => {
    get('/api/clinic/medical/getInfo', {
      recordId
    }).then((res) => {
      const r = res.data.data || res.data;
      resolve({
        success: true,
        data: {
          id: (r.recordId || r.record_id || r.id).toString(),
          patientId: (r.patientId || r.patient_id)?.toString(),
          patientName: r.patientName || r.patient_name,
          patientGender: r.patientGender || r.patient_gender,
          patientAge: r.patientAge || r.patient_age,
          patientPhone: r.patientPhone || r.patient_phone,
          patientBirthday: r.patientBirthday || r.patient_birthday,
          patientBloodType: r.patientBloodType || r.patient_blood_type,
          doctorId: (r.doctorId || r.doctor_id)?.toString(),
          doctorName: r.doctorName || r.doctor_name,
          visitTime: r.visitTime || r.visit_time,
          chiefComplaint: r.chiefComplaint || r.chief_complaint,
          presentIllness: r.presentIllness || r.present_illness,
          pastHistory: r.pastHistory || r.past_history,
          allergyHistory: r.allergyHistory || r.allergy_history,
          physicalExam: r.physicalExam || r.physical_exam,
          diagnosis: r.diagnosis,
          treatment: r.treatment,
          prescription: safeJsonParse(r.prescription, []),
          attachments: safeJsonParse(r.attachments, []),
          followUp: r.followUp || r.follow_up,
          createdAt: r.createTime || r.create_time,
          updatedAt: r.updateTime || r.update_time
        }
      });
    }).catch((err) => {
      reject(err);
    });
  });
};

const formatDateTime = (dateStr) => {
  if (!dateStr) return null;
  if (dateStr.length === 16) {
    return dateStr + ':00';
  }
  return dateStr;
};

const createMedicalRecord = (data) => {
  return new Promise((resolve, reject) => {
    post('/api/clinic/medical/add', {
      patientId: data.patientId ? Number(data.patientId) : null,
      patientName: data.patientName,
      patientGender: data.patientGender,
      patientAge: data.patientAge ? Number(data.patientAge) : null,
      patientPhone: data.patientPhone,
      patientBirthday: data.patientBirthday,
      patientBloodType: data.patientBloodType,
      doctorId: data.doctorId ? Number(data.doctorId) : null,
      doctorName: data.doctorName,
      visitTime: formatDateTime(data.visitTime),
      chiefComplaint: data.chiefComplaint,
      presentIllness: data.presentIllness,
      pastHistory: data.pastHistory,
      allergyHistory: data.allergyHistory,
      physicalExam: data.physicalExam,
      diagnosis: data.diagnosis,
      treatment: data.treatment,
      prescription: data.prescription ? JSON.stringify(data.prescription) : '[]',
      attachments: data.attachments ? JSON.stringify(data.attachments) : '[]',
      followUp: data.followUp
    }).then((res) => {
      const payload = res.data || {};
      const newRecord = {
        id: payload.recordId != null ? String(payload.recordId) : '',
        ...data,
        createdAt: new Date().toISOString().split('T')[0],
        updatedAt: new Date().toISOString().split('T')[0]
      };
      resolve({
        success: true,
        data: newRecord
      });
    }).catch((err) => {
      reject(err);
    });
  });
};

const updateMedicalRecord = (recordId, data) => {
  return new Promise((resolve, reject) => {
    post('/api/clinic/medical/edit', {
      recordId: recordId ? Number(recordId) : null,
      patientId: data.patientId ? Number(data.patientId) : null,
      patientName: data.patientName,
      patientGender: data.patientGender,
      patientAge: data.patientAge ? Number(data.patientAge) : null,
      patientPhone: data.patientPhone,
      patientBirthday: data.patientBirthday,
      patientBloodType: data.patientBloodType,
      doctorId: data.doctorId ? Number(data.doctorId) : null,
      doctorName: data.doctorName,
      visitTime: formatDateTime(data.visitTime),
      chiefComplaint: data.chiefComplaint,
      presentIllness: data.presentIllness,
      pastHistory: data.pastHistory,
      allergyHistory: data.allergyHistory,
      physicalExam: data.physicalExam,
      diagnosis: data.diagnosis,
      treatment: data.treatment,
      prescription: data.prescription ? JSON.stringify(data.prescription) : '[]',
      attachments: data.attachments ? JSON.stringify(data.attachments) : '[]',
      followUp: data.followUp
    }).then((res) => {
      resolve({
        success: true,
        data: {
          id: recordId,
          ...data,
          updatedAt: new Date().toISOString().split('T')[0]
        }
      });
    }).catch((err) => {
      reject(err);
    });
  });
};

const deleteMedicalRecord = (recordId) => {
  return new Promise((resolve, reject) => {
    post('/api/clinic/medical/remove', {
      ids: recordId
    }).then((res) => {
      resolve({
        success: true,
        message: '删除成功'
      });
    }).catch((err) => {
      reject(err);
    });
  });
};

const getPatientMedicalHistory = (patientId) => {
  return new Promise((resolve) => {
    getMedicalRecordList({ patientId, page: 1, pageSize: 100 }).then((res) => {
      resolve({
        success: true,
        data: res.data.list
      });
    }).catch(() => {
      resolve({
        success: true,
        data: []
      });
    });
  });
};

const getMedicalRecordStatistics = (params = {}) => {
  return new Promise((resolve, reject) => {
    const timeRange = params.timeRange || '7d';
    get('/api/clinic/medical/statistics', { timeRange })
      .then((res) => {
        const data = res.data && res.data.data ? res.data.data : (res.data || {});
        resolve({
          success: true,
          data: {
            totalRecords: data.totalRecords || 0,
            todayRecords: data.todayRecords || 0,
            totalPatients: data.totalPatients || 0,
            averageAge: data.averageAge || 0,
            diagnosisStats: (data.diagnosisStats || []).map(item => ({
              name: item.name || item.diagnosis || '',
              value: item.value !== undefined && item.value !== null ? item.value : (item.count || 0)
            })),
            trendData: (data.trendData || []).map((item) => ({
              date: item.date,
              value: item.value !== undefined && item.value !== null ? item.value : (item.count || 0)
            }))
          }
        });
      })
      .catch(reject);
  });
};

const exportMedicalRecords = (params = {}) => {
  return new Promise((resolve, reject) => {
    // Return a full export URL for pages that call wx.downloadFile directly.
    const { getRequestUrl } = require('../_utils/request');
    const timeRange = params.timeRange || '7d';
    resolve({
      success: true,
      data: {
        url: getRequestUrl(`/api/clinic/medical/statistics/export?timeRange=${encodeURIComponent(timeRange)}`)
      }
    });
  });
};

function syncDoctorName(doctorId, doctorName) {
  return new Promise((resolve, reject) => {
    post('/api/clinic/medical/syncDoctorName', { doctorId, doctorName })
      .then((res) => resolve({ success: true, data: res.data }))
      .catch(reject);
  });
}

function syncPatientInfo(patientId, patientName, patientPhone) {
  return new Promise((resolve, reject) => {
    post('/api/clinic/medical/syncPatientInfo', { patientId, patientName, patientPhone })
      .then((res) => resolve({ success: true, data: res.data }))
      .catch(reject);
  });
}

module.exports = {
  getMedicalRecordList,
  getMedicalRecordDetail,
  createMedicalRecord,
  updateMedicalRecord,
  deleteMedicalRecord,
  getPatientMedicalHistory,
  getMedicalRecordStatistics,
  exportMedicalRecords,
  syncDoctorName,
  syncPatientInfo
};


