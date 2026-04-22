const { post, get } = require('../_utils/request');
const { getCurrentUser } = require('../auth/index');
const { USER_ROLES } = require('../config/index');

const normalizeAppointmentMutationResponse = (raw = {}) => {
  const appointmentId = raw.appointmentId || raw.appointment_id || raw.id;
  const sequenceNumber = raw.sequenceNumber || raw.sequence_number;
  return {
    id: appointmentId != null ? String(appointmentId) : '',
    appointmentId: appointmentId != null ? String(appointmentId) : '',
    sequenceNumber: sequenceNumber != null ? Number(sequenceNumber) : null
  };
};

const mapSchedule = (s = {}) => {
  const totalSlotsRaw = s.totalSlots != null ? s.totalSlots : s.total_slots;
  const bookedSlotsRaw = s.bookedSlots != null ? s.bookedSlots : s.booked_slots;
  return {
    id: (s.scheduleId || s.schedule_id || s.id).toString(),
    doctorId: (s.doctorId || s.doctor_id)?.toString(),
    doctorName: s.doctorName || s.doctor_name,
    date: s.scheduleDate || s.schedule_date,
    scheduleDate: s.scheduleDate || s.schedule_date,
    startTime: s.startTime || s.start_time,
    endTime: s.endTime || s.end_time,
    totalSlots: Number(totalSlotsRaw != null ? totalSlotsRaw : 0),
    bookedSlots: Number(bookedSlotsRaw != null ? bookedSlotsRaw : 0),
    status: s.status
  };
};

const mapAppointment = (a = {}) => ({
  id: (a.appointmentId || a.appointment_id || a.id).toString(),
  patientId: (a.patientId || a.patient_id)?.toString(),
  patientName: a.patientName || a.patient_name,
  patientPhone: a.patientPhone || a.patient_phone,
  doctorId: (a.doctorId || a.doctor_id)?.toString(),
  doctorName: a.doctorName || a.doctor_name,
  scheduleId: (a.scheduleId || a.schedule_id)?.toString(),
  appointmentDate: a.appointmentDate || a.appointment_date,
  appointmentTime: a.appointmentTime || a.appointment_time,
  sequenceNumber: a.sequenceNumber || a.sequence_number,
  status: a.status,
  called: a.called,
  calledTime: a.calledTime || a.called_time,
  isOffline: a.isOffline || a.is_offline,
  remark: a.remark,
  createdAt: a.createTime || a.create_time,
  updatedAt: a.updateTime || a.update_time
});

const getDoctorScheduleList = (params = {}) => {
  return new Promise((resolve, reject) => {
    if (params.id) {
      get('/api/clinic/schedule/getInfo', { scheduleId: params.id })
        .then((res) => {
          const s = (res.data && res.data.data) || res.data;
          if (!s) {
            resolve({ success: true, data: [] });
            return;
          }
          resolve({ success: true, data: [mapSchedule(s)] });
        })
        .catch(reject);
      return;
    }

    const body = {
      pageNum: params.page || 1,
      pageSize: params.pageSize || 20,
      doctorId: params.doctorId ? Number(params.doctorId) : null,
      scheduleDate: params.date
    };

    post('/api/clinic/schedule/list', body)
      .then((res) => {
        const rows = res.data.rows || res.data.list || [];
        resolve({ success: true, data: rows.map(mapSchedule) });
      })
      .catch(reject);
  });
};

const getDoctorList = () => {
  return new Promise((resolve, reject) => {
    get('/api/clinic/user/doctors')
      .then((res) => {
        const raw = res.data || {};
        const source = Array.isArray(raw) ? raw : (raw.rows || raw.list || raw.data || []);
        const list = source.map((d) => ({
          id: (d.userId || d.user_id || d.id).toString(),
          name: d.userName || d.user_name || d.nickName || d.name || '',
          phone: d.phone || d.phonenumber || '',
          wechat: d.wechat || '',
          title: d.title || '',
          department: d.department || '',
          avatar: d.avatar || '',
          introduction: d.introduction || ''
        }));
        resolve({ success: true, data: list });
      })
      .catch(reject);
  });
};

const createAppointment = (data = {}) => {
  return new Promise((resolve, reject) => {
    post('/api/clinic/appointment/add', {
      scheduleId: data.scheduleId ? Number(data.scheduleId) : null,
      patientId: data.patientId ? Number(data.patientId) : null,
      patientName: data.patientName,
      patientPhone: data.patientPhone,
      doctorId: data.doctorId ? Number(data.doctorId) : null,
      doctorName: data.doctorName,
      appointmentDate: data.appointmentDate,
      appointmentTime: data.appointmentTime,
      status: data.status || 'pending',
      remark: data.remark
    }).then((res) => {
      resolve({ success: true, data: normalizeAppointmentMutationResponse(res.data || {}) });
    }).catch(reject);
  });
};

const createOfflineAppointment = (data = {}) => {
  return new Promise((resolve, reject) => {
    post('/api/clinic/appointment/offlineAdd', {
      scheduleId: data.scheduleId ? Number(data.scheduleId) : null,
      patientPhone: data.patientPhone,
      patientName: data.patientName
    }).then((res) => {
      resolve({ success: true, data: normalizeAppointmentMutationResponse(res.data || {}) });
    }).catch(reject);
  });
};

const getAppointmentList = (params = {}) => {
  return new Promise((resolve, reject) => {
    const currentUser = getCurrentUser && getCurrentUser();
    const requestBody = {
      pageNum: params.page || 1,
      pageSize: params.pageSize || 10,
      patientId: params.patientId,
      doctorId: params.doctorId,
      status: params.status,
      appointmentDate: params.date || params.appointmentDate
    };

    if (currentUser && currentUser.role === USER_ROLES.PATIENT) {
      requestBody.patientId = params.patientId ? Number(params.patientId) : null;
      requestBody.doctorId = null;
    } else if (currentUser && currentUser.role === USER_ROLES.DOCTOR) {
      requestBody.doctorId = currentUser.id || params.doctorId;
      requestBody.patientId = null;
    }

    post('/api/clinic/appointment/list', requestBody)
      .then((res) => {
        const rows = res.data.rows || res.data.list || [];
        const list = rows.map(mapAppointment);
        resolve({
          success: true,
          data: {
            list,
            total: res.data.total || list.length,
            page: params.page || 1,
            pageSize: params.pageSize || 10
          }
        });
      })
      .catch(reject);
  });
};

const getAppointmentDetail = (appointmentId) => {
  return new Promise((resolve, reject) => {
    get('/api/clinic/appointment/getInfo', { appointmentId })
      .then((res) => {
        const a = (res.data && res.data.data) || res.data;
        resolve({ success: true, data: mapAppointment(a) });
      })
      .catch(reject);
  });
};

const updateAppointmentStatus = (appointmentId, status) => {
  return new Promise((resolve, reject) => {
    post('/api/clinic/appointment/edit', {
      appointmentId: appointmentId ? Number(appointmentId) : null,
      status
    }).then((res) => resolve({ success: true, data: res.data }))
      .catch(reject);
  });
};

const confirmAppointment = (appointmentId) => updateAppointmentStatus(appointmentId, 'confirmed');
const completeAppointment = (appointmentId) => updateAppointmentStatus(appointmentId, 'completed');
const cancelAppointment = (appointmentId) => updateAppointmentStatus(appointmentId, 'cancelled');

const updateAppointmentTime = (appointmentId, appointmentDate, appointmentTime) => {
  return new Promise((resolve, reject) => {
    post('/api/clinic/appointment/edit', {
      appointmentId: appointmentId ? Number(appointmentId) : null,
      appointmentDate,
      appointmentTime
    }).then((res) => resolve({ success: true, data: res.data }))
      .catch(reject);
  });
};

const updateSchedule = (scheduleId, data) => {
  const { updateSchedule: updateScheduleV2 } = require('../schedule/index');
  return updateScheduleV2(scheduleId, data);
};

const deleteSchedule = (scheduleId) => {
  const { deleteSchedule: deleteScheduleV2 } = require('../schedule/index');
  return deleteScheduleV2(scheduleId);
};

const addSchedule = (data) => {
  const { createSchedule } = require('../schedule/index');
  return createSchedule(data);
};

const offlineRegistration = (data) => createOfflineAppointment(data);

const syncDoctorName = (doctorId, doctorName) => {
  return new Promise((resolve, reject) => {
    post('/api/clinic/appointment/syncDoctorName', { doctorId, doctorName })
      .then((res) => resolve({ success: true, data: res.data }))
      .catch(reject);
  });
};

const syncPatientInfo = (patientId, patientName, patientPhone) => {
  return new Promise((resolve, reject) => {
    post('/api/clinic/appointment/syncPatientInfo', { patientId, patientName, patientPhone })
      .then((res) => resolve({ success: true, data: res.data }))
      .catch(reject);
  });
};

const callAppointment = (appointmentId) => {
  return new Promise((resolve, reject) => {
    post(`/api/clinic/appointment/${appointmentId}/call`)
      .then((res) => resolve({ success: true, data: res.data }))
      .catch(reject);
  });
};

const getAppointmentQueue = (params = {}) => {
  return new Promise((resolve, reject) => {
    get('/api/clinic/appointment/queue', params)
      .then((res) => resolve({ success: true, data: res.data }))
      .catch(reject);
  });
};

const getAppointmentPosition = (params = {}) => {
  return new Promise((resolve, reject) => {
    get('/api/clinic/appointment/position', params)
      .then((res) => resolve({ success: true, data: res.data }))
      .catch(reject);
  });
};

const getAppointmentReminders = () => {
  return new Promise((resolve, reject) => {
    get('/api/clinic/appointment/reminders')
      .then((res) => {
        const data = res.data || {};
        const rows = data.rows || data.list || data.data || [];
        resolve({
          success: true,
          data: {
            list: rows.map((a) => ({
              id: (a.id || a.appointmentId || a.appointment_id || '').toString(),
              appointmentId: (a.appointmentId || a.id || a.appointment_id || '').toString(),
              patientName: a.patientName || a.patient_name,
              patientPhone: a.patientPhone || a.patient_phone,
              doctorName: a.doctorName || a.doctor_name,
              appointmentDate: a.appointmentDate || a.appointment_date,
              appointmentTime: a.appointmentTime || a.appointment_time,
              sequenceNumber: a.sequenceNumber || a.sequence_number,
              status: a.status,
              statusText: a.statusText || a.status_text,
              scene: a.scene || '',
              sceneText: a.sceneText || a.scene_text || '',
              createTime: a.createTime || a.create_time,
              updateTime: a.updateTime || a.update_time
            })),
            total: data.total || rows.length
          }
        });
      })
      .catch(reject);
  });
};

const getDoctorTodo = () => {
  return new Promise((resolve, reject) => {
    get('/api/clinic/appointment/todo')
      .then((res) => {
        const payload = res.data || {};
        const data = payload.data || payload;
        resolve({
          success: true,
          data: {
            pendingCount: Number(data.pendingCount || 0),
            confirmedCount: Number(data.confirmedCount || 0),
            todayCount: Number(data.todayCount || 0),
            nearVisitCount: Number(data.nearVisitCount || 0),
            todoList: Array.isArray(data.todoList) ? data.todoList : []
          }
        });
      })
      .catch(reject);
  });
};

const getComingAppointments = () => {
  return new Promise((resolve, reject) => {
    get('/api/clinic/appointment/coming')
      .then((res) => {
        const list = Array.isArray(res?.data) ? res.data : [];
        resolve({
          success: true,
          data: list.map(mapAppointment)
        });
      })
      .catch(reject);
  });
};

const getAppointmentSubscription = () => {
  return new Promise((resolve, reject) => {
    get('/api/clinic/appointment/subscription')
      .then((res) => {
        const row = res.data || {};
        resolve({
          success: true,
          data: {
            subscriptionId: row.subscriptionId || row.subscription_id || '',
            appointmentReminder: Number(row.appointmentReminder != null ? row.appointmentReminder : 1),
            remindDaysBefore: Number(row.remindDaysBefore != null ? row.remindDaysBefore : 1),
            subscribeStatus: row.subscribeStatus || row.subscribe_status || 'enabled',
            templateId: row.templateId || row.template_id || '',
            openid: row.openid || ''
          }
        });
      })
      .catch(reject);
  });
};

const saveAppointmentSubscription = (params = {}) => {
  return new Promise((resolve, reject) => {
    const payload = {
      appointmentReminder: params.appointmentReminder === true || Number(params.appointmentReminder) === 1,
      remindDaysBefore: Number(params.remindDaysBefore != null ? params.remindDaysBefore : 1),
      subscribeStatus: params.subscribeStatus || 'enabled'
    };
    if (params.templateId) payload.templateId = params.templateId;
    if (params.openid) payload.openid = params.openid;
    post('/api/clinic/appointment/subscription/save', payload)
      .then((res) => resolve({ success: true, data: res.data }))
      .catch(reject);
  });
};

module.exports = {
  getDoctorScheduleList,
  getDoctorList,
  createAppointment,
  createOfflineAppointment,
  getAppointmentList,
  getAppointmentDetail,
  confirmAppointment,
  completeAppointment,
  cancelAppointment,
  updateAppointmentTime,
  addSchedule,
  updateSchedule,
  deleteSchedule,
  offlineRegistration,
  syncDoctorName,
  syncPatientInfo,
  callAppointment,
  getAppointmentQueue,
  getAppointmentPosition,
  getAppointmentReminders,
  getDoctorTodo,
  getComingAppointments,
  getAppointmentSubscription,
  saveAppointmentSubscription
};
