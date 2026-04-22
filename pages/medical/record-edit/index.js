const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser } = require('../../../services/auth/index');
const { USER_ROLES } = require('../../../services/config/index');
const { getMedicalRecordDetail, createMedicalRecord, updateMedicalRecord } = require('../../../services/medical-record/index');
const { getPatientList, findPatientByPhone } = require('../../../services/patient/index');
const { getMedicineList } = require('../../../services/medicine/index');

const DEFAULT_FORM_DATA = {
  patientId: '',
  patientName: '',
  patientGender: '',
  patientAge: '',
  patientPhone: '',
  patientBirthday: '',
  patientAddress: '',
  patientBloodType: '',
  visitTime: '',
  doctorName: '',
  chiefComplaint: '',
  presentIllness: '',
  pastHistory: '',
  allergyHistory: '',
  physicalExam: '',
  diagnosis: '',
  treatment: '',
  followUp: '',
  prescription: []
};

Page({
  data: {
    uiState: 'loading',
    errorText: '',
    initLoading: false,
    recordId: '',
    isEdit: false,
    isReadonly: false,
    loading: false,
    showPatientSelector: false,
    patientList: [],
    filteredPatientList: [],
    patientSearchKeyword: '',
    medicineList: [],
    showMedicineDropdown: false,
    medicineSearchKeyword: '',
    filteredMedicineList: [],
    activeMedicineIndex: -1,
    // 就诊时间选择
    visitDate: '',
    visitTime: '',
    // 包药相关
    showPackMedicine: false,
    packMedicineKeyword: '',
    filteredPackMedicineList: [],
    packMedicineItems: [], // 已选的包药药品列表 [{medicineId, name, quantity, batchId, batchNumber}]
    packMedicineTargetIndex: -1,
    // 批次选择相关
    showBatchSelect: false,
    tempSelectMedicine: {},
    tempMedicineBatches: [],
    tempSelectedBatch: {},
    formData: { ...DEFAULT_FORM_DATA },
    texts: {
      loading: '页面初始化中...',
      loadFailed: '页面加载失败',
      retry: '重试'
    }
  },

  onLoad(options = {}) {
    this.setData({ recordId: options.id || '' });
    this.initPage();
  },

  showToast(message, theme) {
    Toast({ context: this, selector: '#t-toast', message, ...(theme ? { theme } : {}) });
  },

  isPermissionDenied(error) {
    if (!error) return false;
    const msg = String(error.message || '');
    const type = String(error.type || '');
    return type === 'forbidden' || /无权限|没有权限|forbidden|permission denied/i.test(msg);
  },

  normalizeGender(value) {
    if (value === 'male' || value === '男' || value === '0' || value === 0) return 'male';
    if (value === 'female' || value === '女' || value === '1' || value === 1) return 'female';
    return '';
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

  async initPage() {
    this.setData({ uiState: 'loading', errorText: '', initLoading: true });
    const userInfo = getCurrentUser();
    if (!userInfo) {
      this.setData({ initLoading: false });
      wx.redirectTo({ url: '/pages/login/index' });
      return;
    }

    const isSuperAdmin = userInfo.role === USER_ROLES.SUPER_ADMIN;
    const isClinicAdmin = userInfo.role === USER_ROLES.CLINIC_ADMIN;
    const isDoctor = userInfo.role === USER_ROLES.DOCTOR;

    if (!isSuperAdmin && !isClinicAdmin && !isDoctor) {
      this.setData({ initLoading: false });
      wx.showToast({ title: '无权限访问', icon: 'none' });
      setTimeout(() => wx.navigateBack(), 800);
      return;
    }

    const isEdit = !!this.data.recordId;
    const isReadonly = isClinicAdmin && isEdit;
    const nextData = { isEdit, isReadonly, 'formData.doctorName': userInfo.name || '' };
    if (!isEdit) {
      const now = new Date();
      const y = now.getFullYear();
      const m = String(now.getMonth() + 1).padStart(2, '0');
      const d = String(now.getDate()).padStart(2, '0');
      const hh = String(now.getHours()).padStart(2, '0');
      const mm = String(now.getMinutes()).padStart(2, '0');
      const visitDate = `${y}-${m}-${d}`;
      const visitTime = `${hh}:${mm}`;
      nextData['visitDate'] = visitDate;
      nextData['visitTime'] = visitTime;
      nextData['formData.visitTime'] = `${visitDate} ${visitTime}:00`;
    }
    this.setData(nextData);

    try {
      if (isEdit) {
        const loaded = await this.loadRecordData();
        if (!loaded) {
          this.setData({
            uiState: 'error',
            errorText: this.data.texts.loadFailed
          });
          return;
        }
      }
      await this.loadMedicineList();
      this.setData({
        uiState: 'ready',
        errorText: ''
      });
    } finally {
      this.setData({ initLoading: false });
    }
  },

  async loadRecordData() {
    this.setData({ loading: true });
    try {
      const res = await getMedicalRecordDetail(this.data.recordId);
      const payload = (res && res.data) || {};
      const prescription = Array.isArray(payload.prescription)
        ? payload.prescription.map((item) => ({
          medicineId: item.medicineId || '',
          name: item.name || '',
          dosage: item.dosage || '',
          frequency: item.frequency || '',
          days: item.days || ''
        }))
        : [];
      // 解析就诊时间
      let visitDate = '';
      let visitTime = '';
      if (payload.visitTime) {
        const parts = payload.visitTime.split(' ');
        if (parts.length >= 2) {
          visitDate = parts[0];
          visitTime = parts[1].substring(0, 5);
        }
      }
      this.setData({
        formData: { ...DEFAULT_FORM_DATA, ...payload, prescription },
        visitDate,
        visitTime
      });
      return true;
    } catch (error) {
      this.showToast(error.message || '加载病例失败');
      return false;
    } finally {
      this.setData({ loading: false });
    }
  },

  onFieldChange(e) {
    const field = e.currentTarget.dataset.field;
    const value = e.detail && e.detail.value !== undefined ? e.detail.value : e.detail;
    this.setData({ [`formData.${field}`]: value });
  },

  onDateTap() {
  },

  onDateChange(e) {
    const visitDate = e.detail.value;
    let visitTime = this.data.visitTime || '00:00';
    this.setData({
      visitDate,
      visitTime,
      'formData.visitTime': `${visitDate} ${visitTime}:00`
    });
  },

  onTimeChange(e) {
    const visitTime = e.detail.value;
    const visitDate = this.data.visitDate;
    if (!visitDate) {
      const now = new Date();
      const y = now.getFullYear();
      const m = String(now.getMonth() + 1).padStart(2, '0');
      const d = String(now.getDate()).padStart(2, '0');
      const defaultDate = `${y}-${m}-${d}`;
      this.setData({
        visitDate: defaultDate,
        visitTime,
        'formData.visitTime': `${defaultDate} ${visitTime}:00`
      });
    } else {
      this.setData({
        visitTime,
        'formData.visitTime': `${visitDate} ${visitTime}:00`
      });
    }
  },

  onRadioChange(e) {
    this.setData({ [`formData.${e.currentTarget.dataset.field}`]: e.detail.value });
  },

  async loadMedicineList() {
    try {
      const res = await getMedicineList({ page: 1, pageSize: 500 });
      this.setData({ medicineList: (res.data && res.data.list) || [] });
    } catch (error) {
      this.showToast(error.message || '加载药品列表失败');
    }
  },

  onRetryInit() {
    this.initPage();
  },

  onMedicineSearch(e) {
    const keyword = (e.detail && e.detail.value) || '';
    const rowIndex = Number(e.currentTarget.dataset.rowIndex ?? e.currentTarget.dataset.index);
    const needle = keyword.toLowerCase();
    const filtered = (this.data.medicineList || []).filter((item) =>
      String(item.name || '').toLowerCase().includes(needle)
      || String(item.code || '').toLowerCase().includes(needle)
    );
    this.setData({
      medicineSearchKeyword: keyword,
      filteredMedicineList: filtered,
      showMedicineDropdown: keyword.length > 0 && filtered.length > 0,
      activeMedicineIndex: Number.isNaN(rowIndex) ? -1 : rowIndex
    });
  },

  onMedicineSelect(e) {
    const medicineId = String(e.currentTarget.dataset.id || '');
    const rowIndex = Number(e.currentTarget.dataset.rowIndex ?? e.currentTarget.dataset.index);
    const medicine = (this.data.medicineList || []).find((x) => String(x.id) === medicineId);
    if (!medicine || Number.isNaN(rowIndex)) return;
    const prescription = [...(this.data.formData.prescription || [])];
    if (!prescription[rowIndex]) return;
    prescription[rowIndex].medicineId = medicine.id;
    prescription[rowIndex].name = medicine.name;
    this.setData({
      'formData.prescription': prescription,
      showMedicineDropdown: false,
      activeMedicineIndex: -1,
      filteredMedicineList: []
    });
  },

  addMedicine() {
    const prescription = [...(this.data.formData.prescription || [])];
    prescription.push({ medicineId: '', name: '', dosage: '', frequency: '', days: '' });
    this.setData({ 'formData.prescription': prescription });
  },

  removeMedicine(e) {
    const index = Number(e.currentTarget.dataset.index);
    const prescription = (this.data.formData.prescription || []).filter((_, i) => i !== index);
    this.setData({ 'formData.prescription': prescription, showMedicineDropdown: false, activeMedicineIndex: -1 });
  },

  onMedicineChange(e) {
    const index = Number(e.currentTarget.dataset.index);
    const field = e.currentTarget.dataset.field;
    const value = e.detail && e.detail.value !== undefined ? e.detail.value : e.detail;
    const prescription = [...(this.data.formData.prescription || [])];
    if (!prescription[index]) return;
    prescription[index][field] = value;
    this.setData({ 'formData.prescription': prescription });
  },

  // 包药相关方法
  async openPackMedicine() {
    // 诊所管理员不能使用包药功能
    if (this.data.isReadonly) {
      this.showToast('当前账号无包药权限');
      return;
    }
    // 确保药品列表已加载
    if (!this.data.medicineList || this.data.medicineList.length === 0) {
      await this.loadMedicineList();
    }
    // 筛选片剂药品
    const tabletMedicines = this.filterTabletMedicines(this.data.medicineList || []);
    this.setData({
      showPackMedicine: true,
      packMedicineKeyword: '',
      filteredPackMedicineList: tabletMedicines,
      packMedicineItems: [],
      packMedicineTargetIndex: -1 // -1 表示添加到新行
    });
  },

  async openPackMedicineForRow(e) {
    // 诊所管理员不能使用包药功能
    if (this.data.isReadonly) {
      this.showToast('当前账号无包药权限');
      return;
    }
    // 确保药品列表已加载
    if (!this.data.medicineList || this.data.medicineList.length === 0) {
      await this.loadMedicineList();
    }
    const rowIndex = Number(e.currentTarget.dataset.index);
    // 筛选片剂药品
    const tabletMedicines = this.filterTabletMedicines(this.data.medicineList || []);
    this.setData({
      showPackMedicine: true,
      packMedicineKeyword: '',
      filteredPackMedicineList: tabletMedicines,
      packMedicineItems: [],
      packMedicineTargetIndex: rowIndex // 记录目标行索引
    });
  },

  filterTabletMedicines(medicineList) {
    return medicineList.filter((item) => {
      const dosageForm = (item.dosageForm || item.form || '').toLowerCase();
      const name = (item.name || '').toLowerCase();
      return dosageForm.includes('片') || dosageForm.includes('tablet') || name.includes('片');
    });
  },

  closePackMedicine() {
    this.setData({ showPackMedicine: false });
  },

  onPackMedicineSearchChange(e) {
    const keyword = (e.detail && e.detail.value) || '';
    const needle = keyword.toLowerCase();
    // 先获取片剂药品列表，再进行搜索过滤
    const tabletMedicines = this.filterTabletMedicines(this.data.medicineList || []);
    const filtered = needle
      ? tabletMedicines.filter((item) => {
          const nameLower = String(item.name || '').toLowerCase();
          return nameLower.includes(needle);
        })
      : tabletMedicines;
    this.setData({
      packMedicineKeyword: keyword,
      filteredPackMedicineList: filtered
    });
  },

  // 点击包药药品，打开批次选择
  async onPackMedicineItemTap(e) {
    const medicine = e.currentTarget.dataset.medicine || {};
    if (!medicine.id) return;

    // 检查是否已存在
    const packMedicineItems = [...(this.data.packMedicineItems || [])];
    const existIndex = packMedicineItems.findIndex(item => String(item.medicineId) === String(medicine.id));
    if (existIndex >= 0) {
      this.showToast('该药品已在包药列表中');
      return;
    }

    // 加载该药品的批次信息
    try {
      const { getMedicineBatches } = require('../../../services/medicine/index');
      const response = await getMedicineBatches(medicine.id);
      const batchList = (response.data || []).filter(item => Number(item.remainingQuantity || 0) > 0);

      this.setData({
        showBatchSelect: true,
        tempSelectMedicine: medicine,
        tempMedicineBatches: batchList,
        tempSelectedBatch: {}
      });
    } catch (error) {
      this.showToast('加载批次失败');
    }
  },

  // 批次选择弹窗关闭
  closeBatchSelect() {
    this.setData({
      showBatchSelect: false,
      tempSelectMedicine: {},
      tempMedicineBatches: [],
      tempSelectedBatch: {}
    });
  },

  // 选择批次
  onBatchSelect(e) {
    const batch = e.currentTarget.dataset.batch || {};
    this.setData({ tempSelectedBatch: batch });
  },

  // 确认添加包药药品
  confirmAddPackMedicine() {
    const { tempSelectMedicine, tempSelectedBatch, packMedicineItems } = this.data;
    if (!tempSelectMedicine.id) return;

    const items = [...(packMedicineItems || [])];
    items.push({
      medicineId: tempSelectMedicine.id,
      name: tempSelectMedicine.name,
      quantity: 1,
      batchId: tempSelectedBatch.batchId || '',
      batchNumber: tempSelectedBatch.batchNumber || ''
    });

    this.setData({
      packMedicineItems: items,
      showBatchSelect: false,
      tempSelectMedicine: {},
      tempMedicineBatches: [],
      tempSelectedBatch: {}
    });
    this.showToast('已添加：' + tempSelectMedicine.name, 'success');
  },

  // 移除包药列表中的药品
  removePackItem(e) {
    const index = Number(e.currentTarget.dataset.index);
    const packMedicineItems = [...(this.data.packMedicineItems || [])];
    packMedicineItems.splice(index, 1);
    this.setData({ packMedicineItems });
  },

  // 修改包药列表中药品的数量
  onPackItemQuantityChange(e) {
    const index = Number(e.currentTarget.dataset.index);
    const value = (e.detail && e.detail.value !== undefined) ? e.detail.value : e.detail;
    const quantity = parseInt(value, 10);
    const packMedicineItems = [...(this.data.packMedicineItems || [])];
    if (packMedicineItems[index]) {
      packMedicineItems[index].quantity = isNaN(quantity) ? 1 : Math.max(1, quantity);
      this.setData({ packMedicineItems });
    }
  },

  // 增加包药数量
  increasePackItem(e) {
    const index = Number(e.currentTarget.dataset.index);
    const packMedicineItems = [...(this.data.packMedicineItems || [])];
    if (packMedicineItems[index]) {
      packMedicineItems[index].quantity = (packMedicineItems[index].quantity || 0) + 1;
      this.setData({ packMedicineItems });
    }
  },

  // 减少包药数量
  decreasePackItem(e) {
    const index = Number(e.currentTarget.dataset.index);
    const packMedicineItems = [...(this.data.packMedicineItems || [])];
    if (packMedicineItems[index] && packMedicineItems[index].quantity > 1) {
      packMedicineItems[index].quantity -= 1;
      this.setData({ packMedicineItems });
    }
  },

  confirmPackMedicine() {
    const { packMedicineItems, packMedicineTargetIndex } = this.data;
    if (!packMedicineItems || packMedicineItems.length === 0) {
      this.showToast('请添加至少一种药品');
      return;
    }

    // 生成包药名称，如 "[包药] A药×1片 + B药×2片"
    const name = '[包药] ' + packMedicineItems.map(item => `${item.name}×${item.quantity}片`).join(' + ');

    // 生成medicineId列表，用于库存记录
    const medicineIds = packMedicineItems.map(item => item.medicineId);

    // 添加到处方列表
    const prescription = [...(this.data.formData.prescription || [])];
    const packItem = {
      medicineId: medicineIds.join(','), // 逗号分隔多个ID
      name: name,
      dosage: '',
      frequency: '',
      days: '',
      isPackMedicine: 1, // 标记为包药
      packDetails: packMedicineItems // 保留详情用于后端处理
    };

    // 如果指定了目标行索引，则添加到该行；否则添加新行
    if (packMedicineTargetIndex >= 0 && prescription[packMedicineTargetIndex]) {
      prescription[packMedicineTargetIndex] = {
        ...prescription[packMedicineTargetIndex],
        ...packItem
      };
    } else {
      prescription.push(packItem);
    }

    // 自动填充患者为"包药"、医生为"admin"、手机号为默认
    this.setData({
      'formData.prescription': prescription,
      'formData.patientName': '包药',
      'formData.doctorName': 'admin',
      'formData.patientPhone': '13800138000',
      showPackMedicine: false
    });
    this.showToast('已添加包药', 'success');
  },

  async openPatientSelector() {
    if (this.data.isReadonly) return;
    this.setData({ showPatientSelector: true, patientSearchKeyword: '' });
    await this.loadPatientList();
  },

  closePatientSelector() {
    this.setData({ showPatientSelector: false });
  },

  async loadPatientList() {
    try {
      const res = await getPatientList({ page: 1, pageSize: 200 });
      const list = (res.data && res.data.list) || [];
      this.setData({ patientList: list, filteredPatientList: list });
    } catch (error) {
      if (this.isPermissionDenied(error)) {
        this.showToast('当前账号无权限读取患者列表，可手动填写患者信息');
      } else {
        this.showToast(error.message || '加载患者列表失败');
      }
      this.setData({ patientList: [], filteredPatientList: [] });
    }
  },

  updateFilteredList() {
    const keyword = (this.data.patientSearchKeyword || '').trim().toLowerCase();
    const source = this.data.patientList || [];
    if (!keyword) {
      this.setData({ filteredPatientList: source });
      return;
    }
    const filtered = source.filter((item) => String(item.name || '').toLowerCase().includes(keyword)
      || String(item.phone || '').toLowerCase().includes(keyword));
    this.setData({ filteredPatientList: filtered });
  },

  onPatientSearchChange(e) {
    this.setData({ patientSearchKeyword: (e.detail && e.detail.value) || '' });
    this.updateFilteredList();
  },

  onSearch() {
    this.updateFilteredList();
    const count = (this.data.filteredPatientList || []).length;
    if (count === 0) {
      this.showToast('未找到匹配患者');
      return;
    }
    this.showToast(`找到 ${count} 位患者`, 'success');
  },

  selectPatient(e) {
    const patient = e.currentTarget.dataset.patient || {};
    this.setData({
      'formData.patientId': patient.id || '',
      'formData.patientName': patient.name || '',
      'formData.patientGender': this.normalizeGender(patient.gender),
      'formData.patientAge': patient.age || '',
      'formData.patientPhone': patient.phone || '',
      'formData.patientBirthday': patient.birthday || '',
      'formData.patientAddress': patient.address || '',
      'formData.patientBloodType': patient.bloodType || '',
      'formData.pastHistory': patient.pastHistory || '',
      'formData.allergyHistory': patient.allergyHistory || ''
    });
    this.closePatientSelector();
    this.showToast('已选择患者', 'success');
  },

  async checkAndFillPatient() {
    const formData = this.data.formData || {};
    if (!formData.patientPhone || formData.patientId) return;
    try {
      const res = await findPatientByPhone(formData.patientPhone);
      const patient = res && res.data;
      if (!patient) return;
      this.setData({
        'formData.patientId': patient.id || '',
        'formData.patientName': formData.patientName || patient.name || '',
        'formData.patientGender': this.normalizeGender(formData.patientGender) || this.normalizeGender(patient.gender),
        'formData.patientAge': formData.patientAge || patient.age || '',
        'formData.patientBirthday': formData.patientBirthday || patient.birthday || '',
        'formData.patientAddress': formData.patientAddress || patient.address || '',
        'formData.patientBloodType': formData.patientBloodType || patient.bloodType || '',
        'formData.pastHistory': formData.pastHistory || patient.pastHistory || '',
        'formData.allergyHistory': formData.allergyHistory || patient.allergyHistory || ''
      });
    } catch (error) {
      // 自动补全失败不阻断提交
    }
  },

  validateForm() {
    const formData = this.data.formData || {};
    if (!formData.patientName) return this.showToast('请输入患者姓名') || false;
    if (!/^1\d{10}$/.test(String(formData.patientPhone || '').trim())) return this.showToast('请输入正确的手机号') || false;
    if (!formData.visitTime) return this.showToast('请输入就诊时间') || false;
    if (!formData.doctorName) return this.showToast('请输入医生姓名') || false;
    if (!formData.chiefComplaint) return this.showToast('请填写主诉') || false;
    if (!formData.physicalExam) return this.showToast('请填写体格检查') || false;
    if (!formData.diagnosis) return this.showToast('请填写诊断结果') || false;
    if (!formData.treatment) return this.showToast('请填写治疗方案') || false;
    return true;
  },

  async submitForm() {
    if (this.data.isReadonly) {
      this.showToast('当前账号仅可查看，不能编辑');
      return;
    }

    await this.checkAndFillPatient();
    if (!this.validateForm()) return;

    this.setData({ loading: true });
    try {
      const userInfo = getCurrentUser();
      const formData = this.data.formData || {};
      const submitData = {
        ...formData,
        patientId: formData.patientId ? Number(formData.patientId) : null,
        patientAge: formData.patientAge ? Number(formData.patientAge) : null,
        doctorId: userInfo && userInfo.id ? Number(userInfo.id) : null,
        prescription: Array.isArray(formData.prescription) ? formData.prescription.filter((item) => item && item.name) : []
      };
      if (this.data.isEdit) {
        await updateMedicalRecord(this.data.recordId, submitData);
        this.showToast('病例更新成功', 'success');
      } else {
        await createMedicalRecord(submitData);
        this.showToast('病例创建成功', 'success');
      }
      setTimeout(() => wx.navigateBack(), 900);
    } catch (error) {
      if (this.isPermissionDenied(error)) this.showToast('无权限执行此操作');
      else this.showToast(error.message || '保存失败');
    } finally {
      this.setData({ loading: false });
    }
  }
});
