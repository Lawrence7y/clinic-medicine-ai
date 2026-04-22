const { post, get } = require('../_utils/request');

const mapSchedule = (s) => ({
  id: (s.scheduleId || s.schedule_id || s.id).toString(),
  doctorId: (s.doctorId || s.doctor_id)?.toString(),
  doctorName: s.doctorName || s.doctor_name,
  date: s.scheduleDate || s.schedule_date,
  scheduleDate: s.scheduleDate || s.schedule_date,
  startTime: s.startTime || s.start_time,
  endTime: s.endTime || s.end_time,
  totalSlots: s.totalSlots || s.total_slots,
  bookedSlots: s.bookedSlots || s.booked_slots || 0,
  status: s.status
});

const getScheduleList = (params = {}) => {
  return new Promise((resolve, reject) => {
    const body = {
      pageNum: params.page || 1,
      pageSize: params.pageSize || 50,
      doctorId: params.doctorId ? Number(params.doctorId) : null,
      scheduleDate: params.date || params.scheduleDate
    };

    post('/api/clinic/schedule/list', body)
      .then((res) => {
        const rows = res.data.rows || res.data.list || [];
        const list = rows.map(mapSchedule);
        resolve({
          success: true,
          data: {
            list,
            total: res.data.total || list.length
          }
        });
      })
      .catch(reject);
  });
};

const getScheduleDetail = (id) => {
  return new Promise((resolve, reject) => {
    get('/api/clinic/schedule/getInfo', { scheduleId: id })
      .then((res) => {
        const s = res.data.data || res.data;
        resolve({
          success: true,
          data: mapSchedule(s)
        });
      })
      .catch(reject);
  });
};

const createSchedule = (data) => {
  return new Promise((resolve, reject) => {
    post('/api/clinic/schedule/add', {
      doctorId: data.doctorId ? Number(data.doctorId) : null,
      doctorName: data.doctorName,
      scheduleDate: data.date || data.scheduleDate,
      startTime: data.startTime,
      endTime: data.endTime,
      totalSlots: Number(data.totalSlots) || 0
    })
      .then((res) => {
        resolve({
          success: true,
          data: res.data
        });
      })
      .catch(reject);
  });
};

const updateSchedule = (id, data) => {
  return new Promise((resolve, reject) => {
    post('/api/clinic/schedule/edit', {
      scheduleId: id ? Number(id) : null,
      doctorId: data.doctorId ? Number(data.doctorId) : null,
      doctorName: data.doctorName,
      scheduleDate: data.date || data.scheduleDate,
      startTime: data.startTime,
      endTime: data.endTime,
      totalSlots: Number(data.totalSlots) || 0
    })
      .then((res) => {
        resolve({
          success: true,
          data: res.data
        });
      })
      .catch(reject);
  });
};

const deleteSchedule = (id) => {
  return new Promise((resolve, reject) => {
    post('/api/clinic/schedule/remove', { ids: String(id) })
      .then((res) => {
        resolve({
          success: true,
          data: res.data
        });
      })
      .catch(reject);
  });
};

module.exports = {
  getScheduleList,
  getScheduleDetail,
  createSchedule,
  updateSchedule,
  deleteSchedule
};

