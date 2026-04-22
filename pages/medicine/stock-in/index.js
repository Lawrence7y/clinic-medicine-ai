const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser } = require('../../../services/auth/index');
const { USER_ROLES, STOCK_OPERATION_TYPE } = require('../../../services/config/index');
const { getMedicineList, stockIn, getStockRecords } = require('../../../services/medicine/index');
const { scanMedicineCode, recognizeMedicineByCode } = require('../../../services/medicine-recognition/index');

const normalizeText = (value) => (value === undefined || value === null ? '' : String(value).trim());
const safeDecode = (value) => {
  if (value === undefined || value === null || value === '') return '';
  try {
    return decodeURIComponent(String(value));
  } catch (error) {
    return String(value);
  }
};
const buildEmptyStockInForm = (getCurrentDateTime, overrides = {}) => ({
  medicineId: '',
  medicineName: '',
  quantity: 0,
  stockInDate: getCurrentDateTime(),
  expiryDate: '',
  batchNumber: '',
  remark: '',
  ...overrides
});

Page({
  data: {
    uiState: 'loading',
    errorText: '',
    medicineList: [],
    listLoading: false,
    loading: false,
    scanLoading: false,
    showAddModal: false,
    showMedicineDropdown: false,
    medicineSearchKeyword: '',
    filteredMedicineList: [],
    formData: {
      medicineId: '',
      medicineName: '',
      quantity: 0,
      stockInDate: '',
      expiryDate: '',
      batchNumber: '',
      remark: ''
    },
    selectedMedicineDisplayName: '',
    selectedMedicineExtra: '',
    stockInHistory: [],
    todayCount: 0
  },

  getCurrentDateTime() {
    const now = new Date();
    const y = now.getFullYear();
    const m = String(now.getMonth() + 1).padStart(2, '0');
    const d = String(now.getDate()).padStart(2, '0');
    const hh = String(now.getHours()).padStart(2, '0');
    const mm = String(now.getMinutes()).padStart(2, '0');
    const ss = String(now.getSeconds()).padStart(2, '0');
    return `${y}-${m}-${d} ${hh}:${mm}:${ss}`;
  },

  getCurrentDate() {
    return this.getCurrentDateTime().slice(0, 10);
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

  onLoad(options = {}) {
    const medicineId = normalizeText(options.medicineId);
    this._pendingPrefill = {
      medicineId,
      medicineName: safeDecode(options.medicineName),
      quantity: normalizeText(options.quantity),
      stockInDate: safeDecode(options.stockInDate),
      expiryDate: normalizeText(options.expiryDate),
      batchNumber: safeDecode(options.batchNumber),
      remark: safeDecode(options.remark),
      openAdd: options.openAdd === '1' || (Boolean(medicineId) && options.openAdd !== '0')
    };
    this._prefillApplied = false;
    this.initPage();
  },

  onShow() {
    this.refreshData();
  },

  onPullDownRefresh() {
    this.refreshData().finally(() => wx.stopPullDownRefresh());
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

    this.refreshData();
  },

  refreshData() {
    return Promise.all([
      this.loadMedicines(),
      this.loadStockInHistory({ silent: this.data.uiState === 'ready' || this.data.uiState === 'empty' })
    ]).then(() => {
      this.tryApplyPendingPrefill();
    });
  },

  async loadMedicines() {
    this.setData({ loading: true });
    try {
      const response = await getMedicineList({ page: 1, pageSize: 1000 });
      this.setData({ medicineList: response.data.list || [] });
    } catch (error) {
      Toast({ context: this, selector: '#t-toast', message: error.message || '加载药品列表失败' });
    } finally {
      this.setData({ loading: false });
    }
  },

  async loadStockInHistory(options = {}) {
    if (this.data.listLoading) return;
    const { silent = false } = options;
    this.setData({
      listLoading: true,
      ...(silent ? {} : { uiState: 'loading', errorText: '' })
    });
    try {
      const response = await getStockRecords({ operationType: STOCK_OPERATION_TYPE.IN, pageSize: 100 });
      const historyList = (response.data.list || []).map((record) => ({
        id: record.id,
        medicineName: record.medicineName,
        quantity: record.quantity,
        stockInDate: record.stockInDate || '未填写',
        expiryDate: record.expiryDate || '未填写',
        remark: record.remark || '',
        operator: record.operatorName,
        createTime: this.formatDateTime(record.createdAt),
        createdDateText: this.extractDateText(record.createdAt)
      }));
      const today = this.getCurrentDate();
      const todayCount = historyList.filter((item) => item.createdDateText === today).length;
      this.setData({
        stockInHistory: historyList,
        todayCount,
        uiState: historyList.length > 0 ? 'ready' : 'empty',
        errorText: ''
      });
    } catch (error) {
      const message = error.message || '加载入库记录失败';
      this.setData({
        uiState: this.data.stockInHistory.length > 0 ? 'ready' : 'error',
        errorText: message
      });
      Toast({ context: this, selector: '#t-toast', message, icon: 'none' });
    } finally {
      this.setData({ listLoading: false });
    }
  },

  onRetry() {
    this.loadStockInHistory();
  },

  openAddModal() {
    this.openAddModalWithPrefill();
  },

  openAddModalWithPrefill(prefill = {}) {
    const formData = buildEmptyStockInForm(this.getCurrentDateTime.bind(this), prefill);
    this.setData({
      showAddModal: true,
      showMedicineDropdown: false,
      medicineSearchKeyword: formData.medicineName || '',
      filteredMedicineList: [],
      selectedMedicineDisplayName: formData.medicineName || '',
      selectedMedicineExtra: '',
      formData
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

  onMedicineSelect(e) {
    const selectedMedicineId = e.currentTarget.dataset.id;
    const selectedMedicine = this.data.medicineList.find((medicine) => medicine.id === selectedMedicineId);
    if (!selectedMedicine) return;
    this.applySelectedMedicine(selectedMedicine);
  },

  applySelectedMedicine(medicine) {
    const displayName = medicine.displayName || medicine.name || '';
    const extra = [medicine.manufacturer, medicine.barcode].filter(Boolean).join(' / ');
    this.setData({
      'formData.medicineId': medicine.id,
      'formData.medicineName': displayName,
      medicineSearchKeyword: displayName,
      selectedMedicineDisplayName: displayName,
      selectedMedicineExtra: extra,
      showMedicineDropdown: false
    });
  },

  tryApplyPendingPrefill() {
    if (this._prefillApplied || !this._pendingPrefill) return;
    const pending = this._pendingPrefill;
    if (!pending.openAdd && !pending.medicineId) {
      this._prefillApplied = true;
      return;
    }

    const matchedMedicine = pending.medicineId
      ? this.data.medicineList.find((item) => String(item.id) === String(pending.medicineId))
      : null;
    const medicineName = matchedMedicine
      ? (matchedMedicine.displayName || matchedMedicine.name || '')
      : pending.medicineName;

    this.openAddModalWithPrefill({
      medicineId: pending.medicineId || '',
      medicineName,
      quantity: pending.quantity && Number.isFinite(Number(pending.quantity)) ? Number(pending.quantity) : 0,
      stockInDate: pending.stockInDate || this.getCurrentDateTime(),
      expiryDate: pending.expiryDate || '',
      batchNumber: pending.batchNumber || '',
      remark: pending.remark || ''
    });

    if (matchedMedicine) {
      this.applySelectedMedicine(matchedMedicine);
    } else if (medicineName) {
      this.setData({
        selectedMedicineDisplayName: medicineName,
        medicineSearchKeyword: medicineName
      });
    }

    this._prefillApplied = true;
  },

  async handleScanSelectMedicine() {
    if (this.data.scanLoading) return;
    this.setData({ scanLoading: true });
    try {
      const code = await scanMedicineCode();
      const response = await recognizeMedicineByCode(code, 'stock_in');
      const result = response.data || {};
      const candidate = Array.isArray(result.candidates) ? result.candidates[0] : null;
      if (!candidate) {
        const message = (result.warnings && result.warnings[0]) || '未匹配到本地药品，请先新建药品';
        wx.showModal({
          title: '未找到药品',
          content: message,
          confirmText: '去新建',
          success: (res) => {
            if (res.confirm) {
              wx.navigateTo({ url: '/pages/medicine/edit/index' });
            }
          }
        });
        return;
      }

      const matchedMedicine = this.findMedicineByRecognition(candidate);
      if (!matchedMedicine) {
        Toast({ context: this, selector: '#t-toast', message: '已识别到药品，但本地列表尚未同步，请稍后重试' });
        return;
      }

      this.applySelectedMedicine(matchedMedicine);
      Toast({ context: this, selector: '#t-toast', theme: 'success', message: '已根据条码选中药品' });
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
      const found = this.data.medicineList.find((item) => String(item.id) === medicineId);
      if (found) return found;
    }
    if (barcode) {
      const found = this.data.medicineList.find((item) => normalizeText(item.barcode) === barcode);
      if (found) return found;
    }
    return null;
  },

  clearMedicineSearch() {
    this.setData({ medicineSearchKeyword: '', showMedicineDropdown: false });
  },

  onExpiryDateChange(e) {
    this.setData({ 'formData.expiryDate': e.detail.value });
  },

  onStockInDateChange(e) {
    this.setData({ 'formData.stockInDate': e.detail.value });
  },

  onFormFieldChange(e) {
    const field = e.currentTarget.dataset.field;
    const value = e.detail.value !== undefined ? e.detail.value : e.detail;
    this.setData({ [`formData.${field}`]: value });
  },

  async handleSubmit() {
    const { formData } = this.data;
    if (!formData.medicineId || !formData.quantity || formData.quantity <= 0) {
      Toast({ context: this, selector: '#t-toast', message: '请选择药品并填写入库数量' });
      return;
    }
    if (!formData.batchNumber) {
      Toast({ context: this, selector: '#t-toast', message: '请填写批次号' });
      return;
    }
    if (!formData.expiryDate) {
      Toast({ context: this, selector: '#t-toast', message: '请填写有效期' });
      return;
    }

    if (formData.expiryDate < this.getCurrentDate()) {
      Toast({ context: this, selector: '#t-toast', message: '有效期不能早于今天' });
      return;
    }

    this.setData({ loading: true });
    try {
      const userInfo = getCurrentUser();
      await stockIn({
        medicineId: formData.medicineId,
        quantity: formData.quantity,
        stockInDate: formData.stockInDate || this.getCurrentDateTime(),
        expiryDate: formData.expiryDate,
        batchNumber: formData.batchNumber,
        operatorId: userInfo.id,
        operatorName: userInfo.name,
        remark: formData.remark
      });

      Toast({ context: this, selector: '#t-toast', message: '入库成功', theme: 'success' });
      this.closeAddModal();
      this.refreshData();
    } catch (error) {
      Toast({ context: this, selector: '#t-toast', message: error.message || '入库失败' });
    } finally {
      this.setData({ loading: false });
    }
  },

  goBack() {
    wx.navigateBack();
  }
});
