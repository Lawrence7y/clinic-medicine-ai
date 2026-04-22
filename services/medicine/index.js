const { post, get } = require('../_utils/request');
const { getCurrentUser } = require('../auth/index');
const { USER_ROLES } = require('../config/index');

const DAY_MS = 24 * 60 * 60 * 1000;

const pickDefined = (...values) => values.find((value) => value !== undefined && value !== null);
const toStringOrEmpty = (value) => (value === undefined || value === null ? '' : String(value));
const normalizeText = (value) => (value === undefined || value === null ? '' : String(value).trim());
const formatMedicineDisplayName = (medicine = {}) => {
  const baseName = normalizeText(pickDefined(medicine.name, medicine.medicineName, medicine.medicine_name));
  const manufacturer = normalizeText(
    pickDefined(
      medicine.manufacturer,
      medicine.factory,
      medicine.producer,
      medicine.vendor,
      medicine.company,
      medicine.manufacturerName,
      medicine.manufacturer_name,
      medicine.factoryName,
      medicine.factory_name
    )
  );

  if (!baseName) return '';
  if (!manufacturer) return baseName;
  if (baseName.includes(manufacturer)) return baseName;
  return `${baseName} (${manufacturer})`;
};

const parseDateOnly = (value) => {
  if (!value) return null;
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return null;
  return new Date(date.getFullYear(), date.getMonth(), date.getDate());
};

const getMedicineManufacturer = (medicine = {}) =>
  normalizeText(
    pickDefined(
      medicine.manufacturer,
      medicine.factory,
      medicine.producer,
      medicine.vendor,
      medicine.company,
      medicine.manufacturerName,
      medicine.manufacturer_name,
      medicine.factoryName,
      medicine.factory_name
    )
  );

const getMedicineBarcode = (medicine = {}) =>
  normalizeText(pickDefined(medicine.barcode, medicine.code, medicine.barCode, medicine.bar_code));

const buildPaginationData = (params, list, total) => ({
  list,
  total: total || list.length,
  page: params.page || 1,
  pageSize: params.pageSize || 10
});

const mapMedicine = (medicine = {}) => ({
  id: toStringOrEmpty(pickDefined(medicine.medicineId, medicine.medicine_id, medicine.id)),
  name: normalizeText(pickDefined(medicine.name, medicine.medicineName, medicine.medicine_name)),
  displayName: formatMedicineDisplayName(medicine),
  specification: medicine.specification,
  dosageForm: pickDefined(medicine.dosageForm, medicine.dosage_form, medicine.form),
  form: pickDefined(medicine.form, medicine.dosageForm, medicine.dosage_form),
  manufacturer: getMedicineManufacturer(medicine),
  barcode: getMedicineBarcode(medicine),
  expiryDate: pickDefined(medicine.expiryDate, medicine.expiry_date),
  nearestBatchExpiryDate: pickDefined(medicine.nearestBatchExpiryDate, medicine.nearest_batch_expiry_date),
  nearestBatchRemainingQuantity: pickDefined(medicine.nearestBatchRemainingQuantity, medicine.nearest_batch_remaining_quantity),
  nearestBatchNumber: pickDefined(medicine.nearestBatchNumber, medicine.nearest_batch_number),
  nearestBatchDaysToExpiry: pickDefined(medicine.nearestBatchDaysToExpiry, medicine.nearest_batch_days_to_expiry),
  price: medicine.price,
  stock: medicine.stock,
  warningStock: pickDefined(medicine.warningStock, medicine.warning_stock),
  warningThreshold: pickDefined(medicine.warningThreshold, medicine.warning_threshold),
  minStock: pickDefined(medicine.minStock, medicine.min_stock),
  unit: medicine.unit,
  pharmacology: medicine.pharmacology,
  indications: medicine.indications,
  dosage: medicine.dosage,
  sideEffects: medicine.sideEffects,
  storage: medicine.storage,
  status: medicine.status,
  isPrescription: pickDefined(medicine.isPrescription, medicine.is_prescription),
  category: medicine.category,
  location: medicine.location,
  createdAt: pickDefined(medicine.createTime, medicine.create_time),
  updatedAt: pickDefined(medicine.updateTime, medicine.update_time)
});

const mapStockRecord = (record = {}) => ({
  id: (record.recordId || record.record_id || record.id).toString(),
  medicineId: (record.medicineId || record.medicine_id)?.toString(),
  medicineName: record.medicineName || record.medicine_name,
  operationType: record.operationType || record.operation_type,
  quantity: record.quantity,
  beforeStock: record.beforeStock || record.before_stock,
  afterStock: record.afterStock || record.after_stock,
  batchNumber: record.batchNumber || record.batch_number,
  stockInDate: record.stockInDate || record.stock_in_date || '',
  expiryDate: record.expiryDate || record.expiry_date,
  operatorId: (record.operatorId || record.operator_id)?.toString(),
  operatorName: record.operatorName || record.operator_name,
  patientId: (record.patientId || record.patient_id)?.toString(),
  patientName: record.patientName || record.patient_name,
  doctorId: (record.doctorId || record.doctor_id)?.toString(),
  doctorName: record.doctorName || record.doctor_name,
  relatedRecordId: record.relatedRecordId || record.related_record_id,
  relatedRecordType: record.relatedRecordType || record.related_record_type,
  remark: record.remark,
  createdAt: record.createTime || record.create_time
});

const requestStockOperation = (operationType, data) => {
  const requestBody = {
    medicineId: data.medicineId ? Number(data.medicineId) : null,
    operationType,
    quantity: data.quantity ? Number(data.quantity) : null,
    operatorId: data.operatorId ? Number(data.operatorId) : null,
    operatorName: data.operatorName
  };

  if (data.remark !== undefined && data.remark !== null && String(data.remark).trim() !== '') {
    requestBody.remark = data.remark;
  }

  if (operationType === 'in') {
    if (data.batchNumber !== undefined && data.batchNumber !== null && String(data.batchNumber).trim() !== '') {
      requestBody.batchNumber = data.batchNumber;
    }
    if (data.stockInDate !== undefined && data.stockInDate !== null && String(data.stockInDate).trim() !== '') {
      requestBody.stockInDate = data.stockInDate;
    }
    if (data.expiryDate !== undefined && data.expiryDate !== null && String(data.expiryDate).trim() !== '') {
      requestBody.expiryDate = data.expiryDate;
    } else {
      throw new Error('入库时必须填写有效期');
    }
  }

  if (operationType === 'out') {
    if (data.batchId !== undefined && data.batchId !== null && String(data.batchId).trim() !== '') {
      requestBody.batchId = Number(data.batchId);
    }
    if (data.batchNumber !== undefined && data.batchNumber !== null && String(data.batchNumber).trim() !== '') {
      requestBody.batchNumber = data.batchNumber;
    }
    if (data.expiryDate !== undefined && data.expiryDate !== null && String(data.expiryDate).trim() !== '') {
      requestBody.expiryDate = data.expiryDate;
    }
    if (data.patientName !== undefined && data.patientName !== null && String(data.patientName).trim() !== '') {
      requestBody.patientName = data.patientName;
    }
    if (data.patientId !== undefined && data.patientId !== null && String(data.patientId).trim() !== '') {
      requestBody.patientId = Number(data.patientId);
    }
    if (data.doctorName !== undefined && data.doctorName !== null && String(data.doctorName).trim() !== '') {
      requestBody.doctorName = data.doctorName;
    }
    if (data.doctorId !== undefined && data.doctorId !== null && String(data.doctorId).trim() !== '') {
      requestBody.doctorId = Number(data.doctorId);
    }
    if (data.medicalRecordId !== undefined && data.medicalRecordId !== null && String(data.medicalRecordId).trim() !== '') {
      requestBody.relatedRecordId = data.medicalRecordId;
      requestBody.relatedRecordType = 'medical_record';
    }
    if (data.isPackMedicine !== undefined && data.isPackMedicine !== null) {
      requestBody.isPackMedicine = data.isPackMedicine ? 1 : 0;
    }
    if (data.packItems !== undefined && data.packItems !== null && String(data.packItems).trim() !== '') {
      requestBody.packItems = data.packItems;
    }
  }

  return post('/api/clinic/stock/add', requestBody).then((res) => {
    const payload = res.data || {};
    return {
      success: true,
      data: {
        medicine: { id: data.medicineId },
        record: { id: payload.recordId != null ? String(payload.recordId) : '', ...data }
      }
    };
  });
};

const requestStockRecordList = (params = {}) => {
  const requestBody = {
    pageNum: params.page || 1,
    pageSize: params.pageSize || 10,
    operationType: params.operationType
  };

  if (params.medicineId) requestBody.medicineId = Number(params.medicineId);
  if (params.keyword) requestBody.keyword = params.keyword;

  return post('/api/clinic/stock/list', requestBody).then((res) => {
    const payload = res.data || {};
    const rows = payload.rows || payload.list || [];
    return {
      list: rows.map(mapStockRecord),
      total: payload.total
    };
  });
};

const getStockRecordDetail = (recordId) => {
  return new Promise((resolve, reject) => {
    get('/api/clinic/stock/getInfo', { recordId: Number(recordId) })
      .then((res) => {
        const record = res.data.data || res.data;
        resolve({ success: true, data: mapStockRecord(record) });
      })
      .catch(reject);
  });
};

const updateStockRecord = (recordId, data) => {
  return new Promise((resolve, reject) => {
    const requestBody = { recordId: Number(recordId) };
    if (data.quantity !== undefined && data.quantity !== null) {
      requestBody.quantity = Number(data.quantity);
    }
    if (data.remark !== undefined) {
      requestBody.remark = data.remark;
    }
    if (data.batchNumber !== undefined) {
      requestBody.batchNumber = data.batchNumber;
    }
    if (data.expiryDate !== undefined) {
      requestBody.expiryDate = data.expiryDate;
    }
    post('/api/clinic/stock/edit', requestBody)
      .then((res) => {
        resolve({ success: true, data: res.data });
      })
      .catch(reject);
  });
};

const deleteStockRecord = (recordId) => {
  return new Promise((resolve, reject) => {
    post('/api/clinic/stock/remove', { ids: String(recordId) })
      .then(() => resolve({ success: true, message: '删除成功' }))
      .catch(reject);
  });
};

const getMedicineBatchSummary = (medicineIds = []) => {
  return new Promise((resolve, reject) => {
    if (!Array.isArray(medicineIds) || medicineIds.length === 0) {
      resolve({ success: true, data: {} });
      return;
    }

    const ids = medicineIds.map((id) => Number(id)).filter((id) => Number.isFinite(id));
    if (ids.length === 0) {
      resolve({ success: true, data: {} });
      return;
    }

    get('/api/clinic/stock/batchSummary', { medicineIds: ids.join(',') }).then((res) => {
      const payload = (res && res.data && (res.data.data || res.data)) || [];
      const list = Array.isArray(payload) ? payload : [];
      const map = {};
      list.forEach((item) => {
        const key = toStringOrEmpty(item.medicineId);
        if (!key) return;
        map[key] = {
          nearestBatchExpiryDate: item.nearestBatchExpiryDate || '',
          nearestBatchRemainingQuantity: Number(item.nearestBatchRemainingQuantity || 0),
          nearestBatchNumber: item.nearestBatchNumber || '',
          nearestBatchInDate: item.nearestBatchInDate || item.nearestBatchNumber || '',
          nearestBatchDaysToExpiry:
            item.nearestBatchDaysToExpiry !== undefined && item.nearestBatchDaysToExpiry !== null
              ? Number(item.nearestBatchDaysToExpiry)
              : null
        };
      });

      resolve({ success: true, data: map });
    }).catch(reject);
  });
};

const getMedicineList = (params = {}) => {
  return new Promise((resolve, reject) => {
    const currentUser = getCurrentUser && getCurrentUser();
    if (currentUser && currentUser.role === USER_ROLES.PATIENT) {
      resolve({
        success: true,
        data: buildPaginationData(params, [], 0)
      });
      return;
    }

    post('/api/clinic/medicine/list', {
      pageNum: params.page || 1,
      pageSize: params.pageSize || 10,
      name: params.name || params.keyword,
      barcode: params.barcode,
      dosageForm: params.dosageForm,
      category: params.category,
      status: params.status,
      warningOnly: params.warningOnly
    }).then(async (res) => {
      const payload = res && res.data ? res.data : {};
      const rows = payload.rows || payload.list || payload.records || [];
      const baseList = rows.map(mapMedicine).filter((item) => item.id);

      const summaryRes = await getMedicineBatchSummary(baseList.map((item) => item.id));
      const summaryMap = summaryRes.data || {};
      const list = baseList.map((item) => ({
        ...item,
        ...(summaryMap[item.id] || {})
      }));

      resolve({
        success: true,
        data: buildPaginationData(params, list, payload.total || payload.count)
      });
    }).catch((err) => {
      if (err && err.type === 'forbidden') {
        resolve({
          success: true,
          data: buildPaginationData(params, [], 0)
        });
        return;
      }
      reject(err);
    });
  });
};

const getMedicineDetail = (medicineId) => {
  return new Promise((resolve, reject) => {
    get('/api/clinic/medicine/getInfo', { medicineId }).then((res) => {
      const medicine = res.data.data || res.data;
      resolve({ success: true, data: mapMedicine(medicine) });
    }).catch(reject);
  });
};

const createMedicine = (data) => new Promise((resolve, reject) => {
  post('/api/clinic/medicine/add', {
    name: data.name,
    specification: data.specification,
    dosageForm: data.dosageForm || data.form,
    form: data.form || data.dosageForm,
    manufacturer: data.manufacturer,
    barcode: data.barcode,
    expiryDate: data.expiryDate,
    price: data.price ? Number(data.price) : null,
    stock: data.stock ? Number(data.stock) : 0,
    warningStock: data.warningStock ? Number(data.warningStock) : 10,
    warningThreshold: data.warningThreshold ? Number(data.warningThreshold) : 10,
    minStock: data.minStock ? Number(data.minStock) : 10,
    unit: data.unit,
    pharmacology: data.pharmacology,
    indications: data.indications,
    dosage: data.dosage,
    sideEffects: data.sideEffects,
    storage: data.storage,
    status: data.status || 'active',
    isPrescription: data.isPrescription ? 1 : 0,
    category: data.category,
    location: data.location
  }).then((res) => {
    const payload = res.data || {};
    resolve({
      success: true,
      data: {
        id: payload.medicineId != null ? String(payload.medicineId) : '',
        ...data,
        status: data.status || 'active',
        isPrescription: data.isPrescription || false,
        createdAt: new Date().toISOString().split('T')[0],
        updatedAt: new Date().toISOString().split('T')[0]
      }
    });
  }).catch(reject);
});

const updateMedicine = (medicineId, data) => new Promise((resolve, reject) => {
  post('/api/clinic/medicine/edit', {
    medicineId: medicineId ? Number(medicineId) : null,
    name: data.name,
    specification: data.specification,
    dosageForm: data.dosageForm || data.form,
    form: data.form || data.dosageForm,
    manufacturer: data.manufacturer,
    barcode: data.barcode,
    expiryDate: data.expiryDate,
    price: data.price ? Number(data.price) : null,
    stock: data.stock ? Number(data.stock) : null,
    warningStock: data.warningStock ? Number(data.warningStock) : null,
    warningThreshold: data.warningThreshold ? Number(data.warningThreshold) : null,
    minStock: data.minStock ? Number(data.minStock) : null,
    unit: data.unit,
    pharmacology: data.pharmacology,
    indications: data.indications,
    dosage: data.dosage,
    sideEffects: data.sideEffects,
    storage: data.storage,
    status: data.status,
    isPrescription: data.isPrescription ? 1 : 0,
    category: data.category,
    location: data.location
  }).then(() => {
    resolve({
      success: true,
      data: {
        id: medicineId,
        ...data,
        updatedAt: new Date().toISOString().split('T')[0]
      }
    });
  }).catch(reject);
});

const deleteMedicine = (medicineId) => new Promise((resolve, reject) => {
  post('/api/clinic/medicine/remove', { ids: medicineId }).then(() => {
    resolve({ success: true, message: '删除成功' });
  }).catch(reject);
});

const stockIn = (data) => new Promise((resolve, reject) => requestStockOperation('in', data).then(resolve).catch(reject));
const stockOut = (data) => new Promise((resolve, reject) => requestStockOperation('out', data).then(resolve).catch(reject));

const stockCheck = (data) => new Promise((resolve, reject) => {
  post('/api/clinic/stock/add', {
    medicineId: data.medicineId ? Number(data.medicineId) : null,
    operationType: 'check',
    quantity: data.quantity ? Number(data.quantity) : null,
    operatorId: data.operatorId ? Number(data.operatorId) : null,
    operatorName: data.operatorName,
    remark: data.remark
  }).then((res) => {
    const payload = res.data || {};
    resolve({
      success: true,
      data: {
        medicine: { id: data.medicineId },
        record: { id: payload.recordId != null ? String(payload.recordId) : '', ...data },
        difference: 0
      }
    });
  }).catch(reject);
});

const getStockRecords = (params = {}) => new Promise((resolve, reject) => {
  requestStockRecordList(params).then(({ list, total }) => {
    resolve({ success: true, data: buildPaginationData(params, list, total) });
  }).catch(reject);
});

const getUsageRecords = (params = {}) => new Promise((resolve, reject) => {
  const mergedParams = { ...params, operationType: params.operationType || 'out' };
  requestStockRecordList(mergedParams).then(({ list, total }) => {
    const usageList = list.map((item) => ({ ...item, usageTime: item.createdAt }));
    resolve({ success: true, data: buildPaginationData(params, usageList, total) });
  }).catch(reject);
});

const buildWarningMeta = (medicine, todayDate) => {
  const lowStock = medicine.stock <= (medicine.warningThreshold || 10);
  const expiryDate = parseDateOnly(medicine.expiryDate);
  const daysToExpiry = expiryDate ? Math.floor((expiryDate.getTime() - todayDate.getTime()) / DAY_MS) : null;
  const expired = daysToExpiry !== null && daysToExpiry < 0;
  const nearExpiry = daysToExpiry !== null && daysToExpiry >= 0 && daysToExpiry <= 30;

  let warningType = 'stock';
  if (expired) warningType = 'expired';
  else if (nearExpiry) warningType = 'near_expiry';
  else if (lowStock) warningType = 'stock';

  return { lowStock, expired, nearExpiry, warningType, daysToExpiry };
};

const getStockWarnings = () => new Promise((resolve) => {
  getMedicineList({ page: 1, pageSize: 100 }).then((res) => {
    const today = new Date();
    const todayDate = new Date(today.getFullYear(), today.getMonth(), today.getDate());
    const warnings = (res.data.list || [])
      .map((medicine) => ({ ...medicine, ...buildWarningMeta(medicine, todayDate) }))
      .filter((item) => item.lowStock || item.expired || item.nearExpiry);
    resolve({ success: true, data: warnings });
  }).catch(() => resolve({ success: true, data: [] }));
});

const getMedicineStatistics = () => new Promise((resolve) => {
  getMedicineList({ page: 1, pageSize: 1 }).then((res) => {
    const totalMedicines = res.data.total || 0;
    const today = new Date();
    const todayDate = new Date(today.getFullYear(), today.getMonth(), today.getDate());

    getMedicineList({ page: 1, pageSize: 10000 }).then((fullRes) => {
      const medicines = fullRes.data.list || [];
      const warningCount = medicines.filter((medicine) => {
        const meta = buildWarningMeta(medicine, todayDate);
        return meta.lowStock || meta.expired || meta.nearExpiry;
      }).length;
      const totalStockValue = medicines.reduce((sum, medicine) => sum + (medicine.stock || 0) * (medicine.price || 0), 0);

      resolve({
        success: true,
        data: {
          totalMedicines,
          warningCount,
          totalStockValue,
          dosageFormStats: {},
          recentInValue: 0,
          recentOutQuantity: 0
        }
      });
    }).catch(() => {
      resolve({
        success: true,
        data: {
          totalMedicines,
          warningCount: 0,
          totalStockValue: 0,
          dosageFormStats: {},
          recentInValue: 0,
          recentOutQuantity: 0
        }
      });
    });
  }).catch(() => {
    resolve({
      success: true,
      data: {
        totalMedicines: 0,
        warningCount: 0,
        totalStockValue: 0,
        dosageFormStats: {},
        recentInValue: 0,
        recentOutQuantity: 0
      }
    });
  });
});

const getMedicineBatches = (medicineId) => new Promise((resolve, reject) => {
  get('/api/clinic/stock/batchList', { medicineId }).then((res) => {
    const payload = (res && res.data && (res.data.data || res.data)) || [];
    const list = Array.isArray(payload) ? payload : [];
    resolve({
      success: true,
      data: list.map((item) => ({
        batchId: item.batchId != null ? String(item.batchId) : '',
        medicineId: item.medicineId != null ? String(item.medicineId) : '',
        batchNumber: item.batchNumber || '',
        stockInDate: item.stockInDate || item.batchNumber || '',
        expiryDate: item.expiryDate || '',
        remainingQuantity: Number(item.remainingQuantity || 0),
        expired: Boolean(item.expired),
        nearExpiry: Boolean(item.nearExpiry),
        daysToExpiry: item.daysToExpiry !== undefined && item.daysToExpiry !== null ? Number(item.daysToExpiry) : null
      }))
    });
  }).catch(reject);
});

const getExpiryWarningBatches = (params = {}) => new Promise((resolve, reject) => {
  const requestParams = {
    days: Number(params.days) || 30
  };
  if (params.limit !== undefined && params.limit !== null && params.limit !== '') {
    const limit = Number(params.limit);
    if (Number.isFinite(limit)) {
      requestParams.limit = limit;
    }
  }
  if (params.medicineName) {
    requestParams.medicineName = params.medicineName;
  }

  get('/api/clinic/stock/expiryWarnings', requestParams).then((res) => {
    const payload = (res && res.data && (res.data.data || res.data)) || [];
    const list = Array.isArray(payload) ? payload : [];
    const normalized = list.map((item) => ({
      batchId: item.batchId != null ? String(item.batchId) : '',
      medicineId: item.medicineId != null ? String(item.medicineId) : '',
      medicineName: item.medicineName || '',
      batchNumber: item.batchNumber || '',
      stockInDate: item.stockInDate || '',
      expiryDate: item.expiryDate || '',
      remainingQuantity: Number(item.remainingQuantity || 0),
      daysToExpiry: Number(item.daysToExpiry || 0)
    }));

    resolve({
      success: true,
      data: normalized.sort((left, right) => left.daysToExpiry - right.daysToExpiry)
    });
  }).catch(reject);
});

const getPatientDispensedExpirySummary = (params = {}) => new Promise((resolve, reject) => {
  const requestParams = {};
  if (params.patientId) requestParams.patientId = Number(params.patientId);
  if (params.patientName) requestParams.patientName = params.patientName;
  if (Array.isArray(params.medicineIds) && params.medicineIds.length > 0) {
    requestParams.medicineIds = params.medicineIds.join(',');
  }

  get('/api/clinic/stock/patientDispensedExpirySummary', requestParams).then((res) => {
    const payload = (res && res.data && (res.data.data || res.data)) || [];
    const list = Array.isArray(payload) ? payload : [];
    const map = {};
    list.forEach((item) => {
      const medicineId = toStringOrEmpty(item.medicineId);
      if (!medicineId) return;
      map[medicineId] = item.dispensedExpiryDate || '';
    });
    resolve({ success: true, data: map });
  }).catch(reject);
});

const getMyDispensedMedicinesGrouped = () => new Promise((resolve, reject) => {
  get('/api/clinic/stock/myDispensedMedicinesGrouped')
    .then((res) => {
      const payload = (res && res.data && (res.data.data || res.data)) || [];
      const list = Array.isArray(payload) ? payload : [];
      resolve({
        success: true,
        data: list.map((item) => ({
          medicineId: item.medicineId != null ? String(item.medicineId) : '',
          medicineName: item.medicineName || '',
          expiryDate: item.expiryDate || '',
          totalQuantity: Number(item.totalQuantity || 0),
          latestRecordTime: item.latestRecordTime || '',
          doctorName: item.doctorName || '',
          records: Array.isArray(item.records) ? item.records : []
        }))
      });
    })
    .catch(reject);
});

const offShelfNearExpiryBatches = (days = 30) => new Promise((resolve, reject) => {
  post('/api/clinic/stock/offShelfNearExpiry', { days }).then((res) => {
    resolve({
      success: true,
      data: (res && res.data && (res.data.data || res.data)) || {}
    });
  }).catch(reject);
});

const offShelfBatch = (batchId, remark = '') => new Promise((resolve, reject) => {
  post('/api/clinic/stock/offShelfBatch', {
    batchId: batchId ? Number(batchId) : null,
    remark
  }).then((res) => {
    resolve({
      success: true,
      data: (res && res.data && (res.data.data || res.data)) || {}
    });
  }).catch(reject);
});

function syncOperatorName(operatorId, operatorName) {
  return new Promise((resolve, reject) => {
    post('/api/clinic/stock/syncOperatorName', { operatorId, operatorName })
      .then((res) => resolve({ success: true, data: res.data }))
      .catch(reject);
  });
}

function syncPatientInfoToMedicine(patientIdOrOptions, newNameArg, oldNameArg) {
  return new Promise((resolve, reject) => {
    const options = typeof patientIdOrOptions === 'object' && patientIdOrOptions !== null
      ? patientIdOrOptions
      : { patientId: patientIdOrOptions, newName: newNameArg, oldName: oldNameArg };
    const { patientId, newName, oldName } = options;

    if (!patientId || !oldName || !newName || oldName === newName) {
      resolve({ success: true, data: { updated: 0 } });
      return;
    }

    post('/api/clinic/stock/syncPatientName', { patientId, newName })
      .then((res) => resolve({ success: true, data: res.data }))
      .catch(reject);
  });
}

function syncDoctorNameToMedicine(doctorIdOrOptions, newNameArg, oldNameArg) {
  return new Promise((resolve, reject) => {
    const options = typeof doctorIdOrOptions === 'object' && doctorIdOrOptions !== null
      ? doctorIdOrOptions
      : { doctorId: doctorIdOrOptions, newName: newNameArg, oldName: oldNameArg };
    const { doctorId, newName, oldName } = options;

    if (!doctorId || !oldName || !newName || oldName === newName) {
      resolve({ success: true, data: { updated: 0 } });
      return;
    }

    post('/api/clinic/stock/syncDoctorName', { doctorId, newName })
      .then((res) => resolve({ success: true, data: res.data }))
      .catch(reject);
  });
}

module.exports = {
  getMedicineList,
  getMedicineDetail,
  createMedicine,
  updateMedicine,
  deleteMedicine,
  stockIn,
  stockOut,
  stockCheck,
  getStockRecords,
  getStockRecordDetail,
  updateStockRecord,
  deleteStockRecord,
  getUsageRecords,
  getStockWarnings,
  getMedicineStatistics,
  getMedicineBatches,
  getExpiryWarningBatches,
  getPatientDispensedExpirySummary,
  getMyDispensedMedicinesGrouped,
  offShelfNearExpiryBatches,
  offShelfBatch,
  getMedicineBatchSummary,
  syncOperatorName,
  syncPatientInfoToMedicine,
  syncDoctorNameToMedicine
};


