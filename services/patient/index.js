const { post, get } = require('../_utils/request');

const getPatientList = (params = {}) => {
  return new Promise((resolve, reject) => {
    post('/api/clinic/patient/list', {
      pageNum: params.page || 1,
      pageSize: params.pageSize || 10,
      patientName: params.name || params.patientName,
      patientPhone: params.phone || params.patientPhone
    }).then((res) => {
      const list = (res.data.rows || res.data.list || []).map(p => ({
        id: (p.patientId || p.patient_id || p.id).toString(),
        userId: p.userId || p.user_id,
        name: p.name,
        gender: p.gender,
        age: p.age,
        phone: p.phone,
        birthday: p.birthday,
        address: p.address,
        allergyHistory: p.allergyHistory || p.allergy_history,
        pastHistory: p.pastHistory || p.past_history,
        bloodType: p.bloodType || p.blood_type,
        wechat: p.wechat,
        avatar: p.avatar,
        createdAt: p.createTime || p.create_time,
        updatedAt: p.updateTime || p.update_time
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

const getPatientDetail = (patientId) => {
  return new Promise((resolve, reject) => {
    get('/api/clinic/patient/getInfo', {
      patientId: patientId ? Number(patientId) : null
    }).then((res) => {
      const p = res.data.data || res.data;
      resolve({
        success: true,
        data: {
          id: (p.patientId || p.patient_id || p.id).toString(),
          userId: p.userId || p.user_id,
          name: p.name,
          gender: p.gender,
          age: p.age,
          phone: p.phone,
          birthday: p.birthday,
          address: p.address,
          allergyHistory: p.allergyHistory || p.allergy_history,
          pastHistory: p.pastHistory || p.past_history,
          bloodType: p.bloodType || p.blood_type,
          wechat: p.wechat,
          avatar: p.avatar,
          createdAt: p.createTime || p.create_time,
          updatedAt: p.updateTime || p.update_time
        }
      });
    }).catch((err) => {
      reject(err);
    });
  });
};

const createPatient = (data) => {
  return new Promise((resolve, reject) => {
    post('/api/clinic/patient/add', {
      name: data.name,
      gender: data.gender,
      age: data.age ? Number(data.age) : null,
      phone: data.phone,
      birthday: data.birthday,
      address: data.address,
      allergyHistory: data.allergyHistory,
      pastHistory: data.pastHistory,
      bloodType: data.bloodType,
      wechat: data.wechat,
      avatar: data.avatar,
      userId: data.userId ? Number(data.userId) : null
    }).then((res) => {
      const payload = res.data || {};
      const newPatient = {
        id: payload.patientId != null ? String(payload.patientId) : '',
        ...data,
        createdAt: new Date().toISOString().split('T')[0],
        updatedAt: new Date().toISOString().split('T')[0]
      };
      resolve({
        success: true,
        data: newPatient
      });
    }).catch((err) => {
      reject(err);
    });
  });
};

const updatePatient = (patientId, data) => {
  return new Promise((resolve, reject) => {
    post('/api/clinic/patient/edit', {
      patientId: patientId ? Number(patientId) : null,
      name: data.name,
      gender: data.gender,
      age: data.age ? Number(data.age) : null,
      phone: data.phone,
      birthday: data.birthday,
      address: data.address,
      allergyHistory: data.allergyHistory,
      pastHistory: data.pastHistory,
      bloodType: data.bloodType,
      wechat: data.wechat,
      avatar: data.avatar
    }).then((res) => {
      resolve({
        success: true,
        data: {
          id: patientId,
          ...data,
          updatedAt: new Date().toISOString().split('T')[0]
        }
      });
    }).catch((err) => {
      reject(err);
    });
  });
};

const deletePatient = (patientId) => {
  return new Promise((resolve, reject) => {
    post('/api/clinic/patient/remove', {
      ids: String(patientId)
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

const findPatientByPhone = (phone) => {
  return new Promise((resolve) => {
    getPatientList({ phone, page: 1, pageSize: 1 }).then((res) => {
      const patient = res.data.list[0] || null;
      resolve({
        success: true,
        data: patient
      });
    }).catch(() => {
      resolve({
        success: true,
        data: null
      });
    });
  });
};

const findPatientByUserId = (userId) => {
  return new Promise((resolve, reject) => {
    get('/api/clinic/patient/getInfoByUserId', { userId })
      .then((res) => {
        const p = res.data.data || res.data;
        if (!p) {
          resolve({ success: true, data: null });
          return;
        }
        resolve({
          success: true,
          data: {
            id: (p.patientId || p.patient_id || p.id).toString(),
            userId: p.userId || p.user_id,
            name: p.name,
            gender: p.gender,
            age: p.age,
            phone: p.phone,
            birthday: p.birthday,
            address: p.address,
            allergyHistory: p.allergyHistory || p.allergy_history,
            pastHistory: p.pastHistory || p.past_history,
            bloodType: p.bloodType || p.blood_type,
            wechat: p.wechat,
            avatar: p.avatar
          }
        });
      })
      .catch(reject);
  });
};

const getMyPatientInfo = () => {
  return new Promise((resolve, reject) => {
    get('/api/clinic/patient/myInfo')
      .then((res) => {
        const p = res.data.data || res.data;
        if (!p) {
          resolve({ success: true, data: null });
          return;
        }
        resolve({
          success: true,
          data: {
            id: (p.patientId || p.patient_id || p.id).toString(),
            userId: p.userId || p.user_id,
            name: p.name,
            gender: p.gender,
            age: p.age,
            phone: p.phone,
            birthday: p.birthday,
            address: p.address,
            allergyHistory: p.allergyHistory || p.allergy_history,
            pastHistory: p.pastHistory || p.past_history,
            bloodType: p.bloodType || p.blood_type,
            wechat: p.wechat,
            avatar: p.avatar
          }
        });
      })
      .catch(reject);
  });
};

module.exports = {
  getPatientList,
  getPatientDetail,
  createPatient,
  updatePatient,
  deletePatient,
  findPatientByPhone,
  findPatientByUserId,
  getMyPatientInfo
};
