const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser } = require('../../../services/auth/index');
const { USER_ROLES, STOCK_OPERATION_TYPE } = require('../../../services/config/index');
const { getMedicineList, stockOut, getStockRecords, getMedicineBatches } = require('../../../services/medicine/index');
const { getMedicalRecordList, getMedicalRecordDetail } = require('../../../services/medical-record/index');
const { scanMedicineCode, recognizeMedicineByCode } = require('../../../services/medicine-recognition/index');

const normalizeText = (value) => (value === undefined || value === null ? '' : String(value).trim());

Page({
  data: {
    uiState: 'loading',
    errorText: '',
    medicineList: [],
    medicalRecordList: [],
    listLoading: false,
    loading: false,
    scanLoading: false,
    showAddModal: false,
    showMedicineDropdown: false,
    currentUserRole: '',
    medicineSearchKeyword: '',
    filteredMedicineList: [],
    medicineBatchList: [],
    batchOptionList: [],
    formData: {
      medicineId: '',
      medicineName: '',
      batchId: '',
      batchNumber: '',
      batchExpiryDate: '',
      quantity: 0,
      patientId: '',
      patientName: '',
      doctorId: '',
      doctorName: '',
      usage: '',
      medicalRecordId: '',
      medicalRecordInfo: '',
      prescriptionMedicineInfo: '',
      remark: ''
    },
    stockOutHistory: [],
    todayCount: 0,
    selectedMedicineIsPrescription: false,
    selectedMedicineExpiryDate: '',
    selectedMedicineDisplayName: '',
    selectedMedicineExtra: '',
    prescriptionMedicineList: []
  },

  onLoad() {
    this.initPage();
  },

  onShow() {
    this.refreshData();
  },

  onPullDownRefresh() {
    this.refreshData().finally(() => wx.stopPullDownRefresh());
  },

  normalizeDateValue(value) {
    if (!value) return '';
    if (value instanceof Date) return value;
    if (typeof value === 'string') return value.replace('T', ' ').replace(/-/g, '/');
    return value;
  },

  extractDateText(value) {
    if (!value) return '';
    if (typeof value === 'string') {
      const matched = value.match(/^(\d{4})[-/](\d{2})[-/](\d{2})/);
      if (matched) return `${matched[1]}-${matched[2]}-${matched[3]}`;
    }

    const date = new Date(this.normalizeDateValue(value));
    if (Number.isNaN(date.getTime())) return '';
    const y = date.getFullYear();
    const m = String(date.getMonth() + 1).padStart(2, '0');
    const d = String(date.getDate()).padStart(2, '0');
    return `${y}-${m}-${d}`;
  },

  formatDateTime(value) {
    if (!value) return '';
    const date = new Date(this.normalizeDateValue(value));
    if (Number.isNaN(date.getTime())) return typeof value === 'string' ? value.replace('T', ' ').slice(0, 19) : '';
    const y = date.getFullYear();
    const m = String(date.getMonth() + 1).padStart(2, '0');
    const d = String(date.getDate()).padStart(2, '0');
    const hh = String(date.getHours()).padStart(2, '0');
    const mm = String(date.getMinutes()).padStart(2, '0');
    const ss = String(date.getSeconds()).padStart(2, '0');
    return `${y}-${m}-${d} ${hh}:${mm}:${ss}`;
  },

  initPage() {
    const userInfo = getCurrentUser();
    if (!userInfo) {
      wx.redirectTo({ url: '/pages/login/index' });
      return;
    }

    const hasPermission = [USER_ROLES.SUPER_ADMIN, USER_ROLES.CLINIC_ADMIN, USER_ROLES.DOCTOR].includes(userInfo.role);
    if (!hasPermission) {
      wx.showToast({ title: '无权限访问', icon: 'none' });
      setTimeout(() => wx.navigateBack(), 1500);
      return;
    }

    this.setData({ currentUserRole: userInfo.role });
    this.refreshData();
  },

  async loadInitialData() {
    this.setData({ loading: true });
    try {
      const [medicineResponse, medicalRecordResponse] = await Promise.all([
        getMedicineList({ page: 1, pageSize: 1000 }),
        getMedicalRecordList({ page: 1, pageSize: 100 })
      ]);

      const medicalRecordList = (medicalRecordResponse.data.list || []).map((record) => ({
        ...record,
        displayText: `${record.patientName} - ${record.chiefComplaint || '无主诉'}`
      }));

      this.setData({
        medicineList: medicineResponse.data.list || [],
        medicalRecordList
      });
    } catch (error) {
      Toast({ context: this, selector: '#t-toast', message: error.message || '加载数据失败' });
    } finally {
      this.setData({ loading: false });
    }
  },

  refreshData() {
    this.loadInitialData();
    return this.loadStockOutHistory({ silent: this.data.uiState === 'ready' || this.data.uiState === 'empty' });
  },

  async loadStockOutHistory(options = {}) {
    if (this.data.listLoading) return;
    const { silent = false } = options;
    this.setData({
      listLoading: true,
      ...(silent ? {} : { uiState: 'loading', errorText: '' })
    });
    try {
      const response = await getStockRecords({ operationType: STOCK_OPERATION_TYPE.OUT, pageSize: 100 });
      const historyList = (response.data.list || []).map((record) => ({
        id: record.id,
        medicineName: record.medicineName,
        quantity: record.quantity,
        patientName: record.patientName || '未填写',
        doctorName: record.doctorName || '未填写',
        operator: record.operatorName,
        remark: record.remark || '',
        createTime: this.formatDateTime(record.createdAt),
        createdDateText: this.extractDateText(record.createdAt)
      }));
      const today = this.extractDateText(new Date());
      const todayCount = historyList.filter((item) => item.createdDateText === today).length;
      this.setData({
        stockOutHistory: historyList,
        todayCount,
        uiState: historyList.length > 0 ? 'ready' : 'empty',
        errorText: ''
      });
    } catch (error) {
      const message = error.message || '加载出库记录失败';
      this.setData({
        uiState: this.data.stockOutHistory.length > 0 ? 'ready' : 'error',
        errorText: message
      });
      Toast({ context: this, selector: '#t-toast', message, icon: 'none' });
    } finally {
      this.setData({ listLoading: false });
    }
  },

  onRetry() {
    this.loadStockOutHistory();
  },

  openAddModal() {
    this.setData({
      showAddModal: true,
      showMedicineDropdown: false,
      medicineSearchKeyword: '',
      filteredMedicineList: [],
      medicineBatchList: [],
      batchOptionList: [],
      selectedMedicineIsPrescription: false,
      selectedMedicineExpiryDate: '',
      selectedMedicineDisplayName: '',
      selectedMedicineExtra: '',
      prescriptionMedicineList: [],
      formData: {
        medicineId: '',
        medicineName: '',
        batchId: '',
        batchNumber: '',
        batchExpiryDate: '',
        quantity: 0,
        patientId: '',
        patientName: '',
        doctorId: '',
        doctorName: '',
        usage: '',
        medicalRecordId: '',
        medicalRecordInfo: '',
        prescriptionMedicineInfo: '',
        remark: ''
      }
    });
  },

  closeAddModal() {
    this.setData({ showAddModal: false, showMedicineDropdown: false });
  },

  onMedicineSearch(e) {
    const keyword = normalizeText(e.detail.value || '');
    const lowerKeyword = keyword.toLowerCase();
    const filteredMedicineList = this.data.medicineList.filter((medicine) => {
      const searchable = [
        medicine.displayName,
        medicine.name,
        medicine.specification,
        medicine.manufacturer,
        medicine.barcode
      ]
        .filter(Boolean)
        .join(' ')
        .toLowerCase();
      return searchable.includes(lowerKeyword);
    });

    this.setData({
      medicineSearchKeyword: keyword,
      filteredMedicineList,
      showMedicineDropdown: keyword.length > 0 && filteredMedicineList.length > 0
    });
  },

  async onMedicineSelect(e) {
    const selectedMedicineId = e.currentTarget.dataset.id;
    const selectedMedicine = this.data.medicineList.find((medicine) => medicine.id === selectedMedicineId);
    if (!selectedMedicine) return;
    await this.applySelectedMedicine(selectedMedicine);
  },

  async applySelectedMedicine(medicine) {
    const displayName = medicine.displayName || medicine.name || '';
    const extra = [medicine.manufacturer, medicine.barcode].filter(Boolean).join(' / ');
    this.setData({
      'formData.medicineId': medicine.id,
      'formData.medicineName': displayName,
      'formData.batchId': '',
      'formData.batchNumber': '',
      'formData.batchExpiryDate': '',
      selectedMedicineIsPrescription: Boolean(medicine.isPrescription),
      selectedMedicineExpiryDate: medicine.expiryDate || '',
      selectedMedicineDisplayName: displayName,
      selectedMedicineExtra: extra,
      medicineSearchKeyword: displayName,
      showMedicineDropdown: false
    });
    await this.loadMedicineBatches(medicine.id);
  },

  async handleScanSelectMedicine() {
    if (this.data.scanLoading) return;
    this.setData({ scanLoading: true });
    try {
      const code = await scanMedicineCode();
      const response = await recognizeMedicineByCode(code, 'stock_out');
      const result = response.data || {};
      const candidate = Array.isArray(result.candidates) ? result.candidates[0] : null;
      if (!candidate) {
        Toast({
          context: this,
          selector: '#t-toast',
          message: (result.warnings && result.warnings[0]) || '系统未找到本地药品档案，不能直接出库'
        });
        return;
      }
      const matchedMedicine = this.findMedicineByRecognition(candidate);
      if (!matchedMedicine) {
        Toast({ context: this, selector: '#t-toast', message: '已识别到药品，但本地列表尚未同步，请稍后重试' });
        return;
      }
      await this.applySelectedMedicine(matchedMedicine);
      Toast({ context: this, selector: '#t-toast', theme: 'success', message: '已根据条码选中药品并加载批次' });
    } catch (error) {
      if (error && error.message && error.message !== '已取消扫码') {
        Toast({ context: this, selector: '#t-toast', message: error.message || '扫码选药失败' });
      }
    } finally {
      this.setData({ scanLoading: false });
    }
  },

  findMedicineByRecognition(candidate = {}) {
    const medicineId = candidate.medicineId != null ? String(candidate.medicineId) : '';
    const barcode = normalizeText(candidate.barcode);
    if (medicineId) {
      const found = this.data.medicineList.find((item) => item.id === medicineId);
      if (found) return found;
    }
    if (barcode) {
      const found = this.data.medicineList.find((item) => normalizeText(item.barcode) === barcode);
      if (found) return found;
    }
    return null;
  },

  async loadMedicineBatches(medicineId) {
    try {
      const response = await getMedicineBatches(medicineId);
      const batchList = (response.data || []).filter((item) => Number(item.remainingQuantity || 0) > 0);
      const batchOptionList = batchList.map((item) => {
        const batchNo = item.batchNumber || item.stockInDate || '-';
        const expiry = item.expiryDate ? `（有效期：${item.expiryDate}）` : '';
        return `${batchNo}${expiry}`;
      });
      this.setData({ medicineBatchList: batchList, batchOptionList });

      if (batchList.length > 0) {
        const firstBatch = batchList[0];
        this.setData({
          'formData.batchId': firstBatch.batchId,
          'formData.batchNumber': firstBatch.batchNumber || firstBatch.stockInDate || '',
          'formData.batchExpiryDate': firstBatch.expiryDate || ''
        });
      }
    } catch (error) {
      this.setData({ medicineBatchList: [], batchOptionList: [] });
      Toast({ context: this, selector: '#t-toast', message: error.message || '加载批次失败' });
    }
  },

  onBatchChange(e) {
    const selectedIndex = Number(e.detail.value);
    const selectedBatch = this.data.medicineBatchList[selectedIndex];
    if (!selectedBatch) return;
    this.setData({
      'formData.batchId': selectedBatch.batchId,
      'formData.batchNumber': selectedBatch.batchNumber || selectedBatch.stockInDate || '',
      'formData.batchExpiryDate': selectedBatch.expiryDate || ''
    });
  },

  clearMedicineSearch() {
    this.setData({ medicineSearchKeyword: '', showMedicineDropdown: false });
  },

  onMedicalRecordSelect(e) {
    const selectedRecord = this.data.medicalRecordList[Number(e.detail.value)];
    if (!selectedRecord) return;
    this.setData({
      'formData.medicalRecordId': selectedRecord.id,
      'formData.patientId': selectedRecord.patientId || '',
      'formData.medicalRecordInfo': selectedRecord.displayText,
      'formData.patientName': selectedRecord.patientName,
      'formData.doctorId': selectedRecord.doctorId || '',
      'formData.doctorName': selectedRecord.doctorName,
      'formData.prescriptionMedicineInfo': '',
      prescriptionMedicineList: []
    });
    this.loadMedicalRecordDetails(selectedRecord.id);
  },

  async loadMedicalRecordDetails(recordId) {
    try {
      const response = await getMedicalRecordDetail(recordId);
      const record = response.data || {};
      const prescription = Array.isArray(record.prescription) ? record.prescription : [];
      const prescriptionMedicineList = [];

      const pushPrescriptionMedicine = (medicineId, name, extra = {}) => {
        const normalizedId = medicineId != null ? String(medicineId).trim() : '';
        if (!normalizedId) return;
        prescriptionMedicineList.push({
          medicineId: normalizedId,
          name: name || normalizedId,
          displayText: name || normalizedId,
          ...extra
        });
      };

      prescription.forEach((item) => {
        if (Array.isArray(item.packDetails) && item.packDetails.length > 0) {
          item.packDetails.forEach((packItem) => {
            pushPrescriptionMedicine(packItem.medicineId, packItem.name, {
              batchId: packItem.batchId || '',
              batchNumber: packItem.batchNumber || '',
              isPackMedicine: true
            });
          });
          return;
        }
        pushPrescriptionMedicine(item.medicineId, item.name || item.medicineName, {
          batchId: item.batchId || '',
          batchNumber: item.batchNumber || '',
          isPackMedicine: Boolean(item.isPackMedicine)
        });
      });

      this.setData({ prescriptionMedicineList });
      if (prescriptionMedicineList.length === 1) {
        this.selectPrescriptionMedicine(0);
      }
    } catch (error) {
      console.error('加载病历详情失败', error);
    }
  },

  onPrescriptionMedicineSelect(e) {
    this.selectPrescriptionMedicine(Number(e.detail.value));
  },

  async selectPrescriptionMedicine(index) {
    const selectedMedicine = this.data.prescriptionMedicineList[index];
    if (!selectedMedicine || !selectedMedicine.medicineId) {
      Toast({ context: this, selector: '#t-toast', message: '病历中的药品信息不完整' });
      return;
    }

    const medicine = this.data.medicineList.find((item) => item.id === String(selectedMedicine.medicineId));
    if (!medicine) {
      Toast({ context: this, selector: '#t-toast', message: '病历中的药品未在库存列表中找到' });
      return;
    }

    await this.applySelectedMedicine(medicine);
    this.setData({
      'formData.prescriptionMedicineInfo': selectedMedicine.displayText,
      'formData.quantity': 0
    });

    if (selectedMedicine.batchId) {
      this.setData({
        'formData.batchId': selectedMedicine.batchId,
        'formData.batchNumber': selectedMedicine.batchNumber || '',
        'formData.batchExpiryDate': ''
      });
    }
  },

  onFormFieldChange(e) {
    const field = e.currentTarget.dataset.field;
    const value = e.detail.value !== undefined ? e.detail.value : e.detail;
    this.setData({ [`formData.${field}`]: value });
  },

  async handleSubmit() {
    const { formData, selectedMedicineIsPrescription, selectedMedicineExpiryDate } = this.data;
    if (!formData.medicineId || !formData.quantity || formData.quantity <= 0) {
      Toast({ context: this, selector: '#t-toast', message: '请选择药品并填写出库数量' });
      return;
    }
    if (!formData.batchId) {
      Toast({ context: this, selector: '#t-toast', message: '请选择出库批次' });
      return;
    }
    if (selectedMedicineIsPrescription && !formData.medicalRecordId) {
      Toast({ context: this, selector: '#t-toast', message: '处方药必须关联病历后再出库' });
      return;
    }

    const expiryDate = formData.batchExpiryDate || selectedMedicineExpiryDate;
    if (expiryDate) {
      const today = this.extractDateText(new Date());
      if (expiryDate < today) {
        Toast({ context: this, selector: '#t-toast', message: '该药品已过期，禁止出库' });
        return;
      }
    }

    this.setData({ loading: true });
    try {
      const userInfo = getCurrentUser();
      await stockOut({
        medicineId: formData.medicineId,
        batchId: formData.batchId,
        batchNumber: formData.batchNumber,
        expiryDate: formData.batchExpiryDate,
        quantity: formData.quantity,
        patientId: formData.patientId,
        patientName: formData.patientName,
        doctorId: formData.doctorId,
        doctorName: formData.doctorName,
        usage: formData.usage,
        medicalRecordId: formData.medicalRecordId,
        operatorId: userInfo.id,
        operatorName: userInfo.name,
        remark: formData.remark
      });

      Toast({ context: this, selector: '#t-toast', message: '出库成功', theme: 'success' });
      this.closeAddModal();
      this.refreshData();
    } catch (error) {
      Toast({ context: this, selector: '#t-toast', message: error.message || '出库失败' });
    } finally {
      this.setData({ loading: false });
    }
  },

  goBack() {
    wx.navigateBack();
  }
});
