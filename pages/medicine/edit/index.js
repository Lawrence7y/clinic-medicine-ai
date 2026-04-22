const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser } = require('../../../services/auth/index');
const { USER_ROLES } = require('../../../services/config/index');
const { getMedicineDetail, createMedicine, updateMedicine, stockIn } = require('../../../services/medicine/index');
const {
  scanMedicineCode,
  pickRecognitionImage,
  recognizeMedicineByCode,
  recognizeMedicineByImage,
  confirmRecognitionResult
} = require('../../../services/medicine-recognition/index');

const DOSAGE_FORM_OPTIONS = ['颗粒剂', '胶囊剂', '片剂', '注射剂', '喷雾剂', '口服液', '外用制剂', '其他'];
const DOSAGE_FORM_ALIAS_MAP = {
  Granules: '颗粒剂',
  Capsule: '胶囊剂',
  Tablet: '片剂',
  Injection: '注射剂',
  Spray: '喷雾剂',
  'Oral Liquid': '口服液',
  Topical: '外用制剂',
  Other: '其他',
  granules: '颗粒剂',
  capsule: '胶囊剂',
  tablet: '片剂',
  injection: '注射剂',
  spray: '喷雾剂',
  oral_liquid: '口服液',
  oral: '口服液',
  topical: '外用制剂',
  other: '其他'
};
const RECOGNITION_FIELDS = [
  'barcode',
  'name',
  'specification',
  'manufacturer',
  'dosageForm',
  'form',
  'category',
  'storage',
  'pharmacology',
  'indications',
  'dosage',
  'sideEffects'
];

const getCurrentDateTime = () => {
  const now = new Date();
  const year = now.getFullYear();
  const month = `${now.getMonth() + 1}`.padStart(2, '0');
  const day = `${now.getDate()}`.padStart(2, '0');
  const hours = `${now.getHours()}`.padStart(2, '0');
  const minutes = `${now.getMinutes()}`.padStart(2, '0');
  const seconds = `${now.getSeconds()}`.padStart(2, '0');
  return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
};

const getCurrentDate = () => getCurrentDateTime().slice(0, 10);

const buildEmptyFormData = () => ({
  barcode: '',
  name: '',
  specification: '',
  manufacturer: '',
  dosageForm: '',
  form: '',
  price: '',
  warningStock: 10,
  warningThreshold: 10,
  minStock: 10,
  pharmacology: '',
  indications: '',
  dosage: '',
  sideEffects: '',
  isPrescription: false,
  category: '',
  unit: '',
  storage: '',
  location: '',
  initialStockQuantity: '',
  initialBatchNumber: '',
  initialExpiryDate: '',
  initialStockInDate: getCurrentDateTime()
});

const normalizeText = (value) => (value === undefined || value === null ? '' : String(value).trim());
const normalizeDosageForm = (value) => {
  const raw = normalizeText(value);
  if (!raw) return '';
  if (DOSAGE_FORM_OPTIONS.includes(raw)) return raw;
  if (DOSAGE_FORM_ALIAS_MAP[raw]) return DOSAGE_FORM_ALIAS_MAP[raw];
  const lower = raw.toLowerCase().replace(/\s+/g, '_');
  if (DOSAGE_FORM_ALIAS_MAP[lower]) return DOSAGE_FORM_ALIAS_MAP[lower];
  return raw;
};

const extractInputValue = (e) => {
  if (!e) return '';
  if (e.detail && e.detail.value !== undefined) return e.detail.value;
  if (e.detail !== undefined) return e.detail;
  return '';
};

const buildRecognitionSnapshot = (formData = {}) => {
  const snapshot = {};
  RECOGNITION_FIELDS.forEach((field) => {
    snapshot[field] = normalizeText(formData[field]);
  });
  snapshot.form = normalizeText(formData.form || formData.dosageForm);
  snapshot.dosageForm = normalizeText(formData.dosageForm || formData.form);
  return snapshot;
};

const normalizeCandidate = (candidate = {}, index = 0) => {
  const name = normalizeText(candidate.name);
  const manufacturer = normalizeText(candidate.manufacturer);
  const displayName = manufacturer && name && !name.includes(manufacturer)
    ? `${name} (${manufacturer})`
    : name;
  const confidence = candidate.confidence;

  return {
    ...candidate,
    candidateId: candidate.candidateId || `candidate_${index + 1}`,
    displayName: displayName || `候选结果 ${index + 1}`,
    confidenceText: Number.isFinite(Number(confidence)) ? `${Math.round(Number(confidence) * 100)}%` : '',
    dosageForm: normalizeDosageForm(candidate.dosageForm || candidate.form),
    form: normalizeDosageForm(candidate.form || candidate.dosageForm),
    evidenceUrls: Array.isArray(candidate.evidenceUrls) ? candidate.evidenceUrls : []
  };
};

Page({
  data: {
    medicineId: '',
    isEdit: false,
    uiState: 'loading',
    errorText: '',
    loading: false,
    submitting: false,
    recognizing: false,
    dosageFormOptions: DOSAGE_FORM_OPTIONS,
    dosageFormIndex: -1,
    recognitionCandidates: [],
    recognitionWarnings: [],
    recognitionSource: '',
    recognitionSessionId: '',
    selectedCandidateId: '',
    recognitionDecisionRequired: false,
    recognitionNeedConfirm: false,
    recognitionConfirmed: false,
    recognitionAppliedSnapshot: null,
    recognitionErrorText: '',
    lastRecognitionMode: '',
    correctionNote: '',
    texts: {
      loading: '页面加载中...',
      loadFailed: '页面加载失败',
      retry: '重试'
    },
    formData: buildEmptyFormData()
  },

  onLoad(options = {}) {
    this.setData({ medicineId: options.id || '' });
    this.initPage();
  },

  async initPage() {
    const currentUser = getCurrentUser();
    if (!currentUser) {
      wx.redirectTo({ url: '/pages/login/index' });
      return;
    }

    const isAdmin = currentUser.role === USER_ROLES.SUPER_ADMIN || currentUser.role === USER_ROLES.CLINIC_ADMIN;
    if (!isAdmin) {
      wx.showToast({ title: '暂无编辑药品权限', icon: 'none' });
      setTimeout(() => wx.navigateBack(), 1200);
      return;
    }

    if (!this.data.medicineId) {
      this.setData({ uiState: 'ready' });
      return;
    }
    this.setData({ isEdit: true });
    await this.loadMedicineData();
  },

  async loadMedicineData() {
    this.setData({ loading: true, uiState: 'loading', errorText: '' });
    try {
      const response = await getMedicineDetail(this.data.medicineId);
      const medicineData = response.data || {};
      const form = normalizeDosageForm(medicineData.form || medicineData.dosageForm || '');
      const dosageFormIndex = DOSAGE_FORM_OPTIONS.indexOf(form);
      this.setData({
        formData: {
          ...buildEmptyFormData(),
          ...medicineData,
          dosageForm: normalizeDosageForm(medicineData.dosageForm || form),
          form
        },
        dosageFormIndex,
        uiState: 'ready',
        errorText: ''
      });
    } catch (error) {
      const message = error.message || '加载药品详情失败。';
      this.setData({
        uiState: 'error',
        errorText: message
      });
      Toast({ context: this, selector: '#t-toast', message });
    } finally {
      this.setData({ loading: false });
    }
  },

  onRetryInit() {
    if (this.data.isEdit) {
      this.loadMedicineData();
      return;
    }
    this.setData({ uiState: 'ready', errorText: '' });
  },

  onFieldChange(e) {
    const field = e.currentTarget.dataset.field;
    if (!field) return;
    this.setData({ [`formData.${field}`]: extractInputValue(e) });
  },

  onDosageFormChange(e) {
    const dosageFormIndex = Number(e.detail.value);
    const value = DOSAGE_FORM_OPTIONS[dosageFormIndex] || '';
    this.setData({
      dosageFormIndex,
      'formData.form': value,
      'formData.dosageForm': value
    });
  },

  onPrescriptionSwitch(e) {
    const checked = !!(e && e.detail && e.detail.value);
    this.setData({ 'formData.isPrescription': checked });
  },

  onCorrectionNoteChange(e) {
    this.setData({ correctionNote: extractInputValue(e) });
  },

  onInitialExpiryDateChange(e) {
    this.setData({ 'formData.initialExpiryDate': extractInputValue(e) });
  },

  onInitialStockInDateChange(e) {
    this.setData({ 'formData.initialStockInDate': extractInputValue(e) });
  },

  async handleScanRecognition() {
    if (this.data.recognizing) return;
    this.setData({
      recognizing: true,
      recognitionErrorText: '',
      lastRecognitionMode: 'scan'
    });
    try {
      const code = await scanMedicineCode();
      this.setData({
        'formData.barcode': code,
        recognitionCandidates: [],
        recognitionWarnings: [],
        recognitionSource: '条码识别',
        selectedCandidateId: '',
        recognitionDecisionRequired: false,
        recognitionNeedConfirm: false,
        recognitionConfirmed: false,
        recognitionAppliedSnapshot: null
      });
      const response = await recognizeMedicineByCode(code, 'create');
      this.applyRecognitionResult(response.data || {}, '条码识别', {
        autoApplyFirstCandidate: true,
        detectedBarcode: code
      });
    } catch (error) {
      if (error && error.message !== '已取消扫码。') {
        const message = error.message || '条码识别失败，请重试。';
        this.setData({ recognitionErrorText: message });
        Toast({ context: this, selector: '#t-toast', message });
      }
    } finally {
      this.setData({ recognizing: false });
    }
  },

  async handleImageRecognition() {
    if (this.data.recognizing) return;
    this.setData({
      recognizing: true,
      recognitionErrorText: '',
      lastRecognitionMode: 'image'
    });
    try {
      const filePath = await pickRecognitionImage();
      const response = await recognizeMedicineByImage(filePath, 'create');
      this.applyRecognitionResult(response.data || {}, '拍照识别');
    } catch (error) {
      if (error && error.message !== '已取消选择图片。') {
        const message = error.message || '图片识别失败，请重试。';
        this.setData({ recognitionErrorText: message });
        Toast({ context: this, selector: '#t-toast', message });
      }
    } finally {
      this.setData({ recognizing: false });
    }
  },

  applyRecognitionResult(result, sourceLabel, options = {}) {
    const { autoApplyFirstCandidate = false, detectedBarcode = '' } = options;
    const candidates = Array.isArray(result.candidates)
      ? result.candidates.map((item, index) => normalizeCandidate(item, index))
      : [];
    const warnings = Array.isArray(result.warnings) ? result.warnings : [];

    this.setData({
      recognitionCandidates: candidates,
      recognitionWarnings: warnings,
      recognitionSource: sourceLabel,
      recognitionSessionId: result.sessionId || '',
      selectedCandidateId: '',
      recognitionDecisionRequired: false,
      recognitionNeedConfirm: false,
      recognitionConfirmed: false,
      recognitionAppliedSnapshot: null,
      recognitionErrorText: '',
      correctionNote: ''
    });

    if (detectedBarcode) {
      this.setData({ 'formData.barcode': detectedBarcode });
    }

    if (!candidates.length) {
      Toast({
        context: this,
        selector: '#t-toast',
        message: warnings[0] || '未识别到可靠候选项，请手动补全药品信息。'
      });
      return;
    }

    if (autoApplyFirstCandidate) {
      this.applyCandidateToForm(candidates[0], {
        fallbackBarcode: detectedBarcode,
        requireManualConfirm: true,
        successMessage: '已应用首个识别结果，请先确认结果后再入库。'
      });
      return;
    }

    this.setData({ recognitionDecisionRequired: true });
    Toast({
      context: this,
      selector: '#t-toast',
      theme: 'success',
      message: `识别到 ${candidates.length} 个候选结果，请确认其一。`
    });
  },

  applyCandidateToForm(candidate, options = {}) {
    if (!candidate) return;
    const {
      fallbackBarcode = '',
      requireManualConfirm = true,
      successMessage = '已应用识别结果，请保存前再次确认。'
    } = options;

    const nextForm = { ...this.data.formData };
    RECOGNITION_FIELDS.forEach((field) => {
      if (candidate[field] !== undefined && candidate[field] !== null && normalizeText(candidate[field])) {
        nextForm[field] = candidate[field];
      }
    });

    if (fallbackBarcode && !normalizeText(nextForm.barcode)) {
      nextForm.barcode = fallbackBarcode;
    }

    const formValue = normalizeDosageForm(candidate.form || candidate.dosageForm || nextForm.form || nextForm.dosageForm);
    nextForm.form = formValue;
    nextForm.dosageForm = normalizeDosageForm(candidate.dosageForm || candidate.form || formValue);

    const dosageFormIndex = DOSAGE_FORM_OPTIONS.indexOf(nextForm.form || nextForm.dosageForm || '');
    const updates = {
      dosageFormIndex,
      selectedCandidateId: candidate.candidateId || '',
      recognitionDecisionRequired: false,
      recognitionNeedConfirm: requireManualConfirm,
      recognitionConfirmed: !requireManualConfirm,
      recognitionAppliedSnapshot: buildRecognitionSnapshot(nextForm)
    };
    Object.keys(nextForm).forEach((field) => {
      updates[`formData.${field}`] = nextForm[field];
    });
    this.setData(updates);

    Toast({
      context: this,
      selector: '#t-toast',
      theme: 'success',
      message: successMessage
    });
  },

  onSelectCandidate(e) {
    const index = Number(e.currentTarget.dataset.index);
    const candidate = this.data.recognitionCandidates[index];
    if (!candidate) return;
    this.applyCandidateToForm(candidate, {
      requireManualConfirm: true,
      successMessage: '候选结果已选中，请确认结果后再保存。'
    });
  },

  confirmRecognitionSelection() {
    if (!this.data.selectedCandidateId) {
      Toast({
        context: this,
        selector: '#t-toast',
        message: '请先选择一个识别候选结果。'
      });
      return;
    }
    this.setData({
      recognitionNeedConfirm: false,
      recognitionConfirmed: true
    });
    Toast({
      context: this,
      selector: '#t-toast',
      theme: 'success',
      message: '识别结果已确认，可继续保存入库。'
    });
  },

  clearSelectedCandidate() {
    this.setData({
      selectedCandidateId: '',
      recognitionDecisionRequired: false,
      recognitionNeedConfirm: false,
      recognitionConfirmed: false,
      recognitionAppliedSnapshot: null,
      correctionNote: ''
    });
  },

  skipRecognitionCandidates() {
    this.setData({
      recognitionCandidates: [],
      recognitionWarnings: [],
      selectedCandidateId: '',
      recognitionDecisionRequired: false,
      recognitionNeedConfirm: false,
      recognitionConfirmed: false,
      recognitionAppliedSnapshot: null,
      recognitionErrorText: '',
      correctionNote: ''
    });
    Toast({
      context: this,
      selector: '#t-toast',
      theme: 'success',
      message: '已跳过识别候选，请手动确认后再保存。'
    });
  },

  retryLastRecognition() {
    if (this.data.recognizing) return;
    if (this.data.lastRecognitionMode === 'scan') {
      this.handleScanRecognition();
      return;
    }
    if (this.data.lastRecognitionMode === 'image') {
      this.handleImageRecognition();
      return;
    }
    Toast({
      context: this,
      selector: '#t-toast',
      message: '暂无可重试的识别操作。'
    });
  },

  validateInitialStock() {
    if (this.data.isEdit) return '';
    const { formData } = this.data;
    const quantityText = normalizeText(formData.initialStockQuantity);
    const batchNumber = normalizeText(formData.initialBatchNumber);
    const expiryDate = normalizeText(formData.initialExpiryDate);
    const hasAnyValue = Boolean(quantityText || batchNumber || expiryDate);
    if (!hasAnyValue) return '';

    const quantity = Number(quantityText);
    if (!Number.isInteger(quantity) || quantity <= 0) {
      return '如需首批入库，请填写大于 0 的入库数量。';
    }
    if (!batchNumber) {
      return '如需首批入库，请填写首批批次号。';
    }
    if (!expiryDate) {
      return '如需首批入库，请填写首批有效期。';
    }
    if (expiryDate < getCurrentDate()) {
      return '首批有效期不能早于今天。';
    }
    return '';
  },

  validateForm() {
    const { formData } = this.data;
    if (this.data.recognitionDecisionRequired) {
      return '请先确认识别候选结果，或点击“跳过识别，手动填写”。';
    }
    if (this.data.selectedCandidateId && this.data.recognitionNeedConfirm) {
      return '请先点击“确认识别结果”后再保存入库。';
    }
    if (!normalizeText(formData.name)) return '请输入药品名称。';
    if (!normalizeText(formData.specification)) return '请输入规格。';
    if (!normalizeText(formData.form || formData.dosageForm)) return '请选择剂型。';

    const price = Number(formData.price);
    if (!Number.isFinite(price) || price < 0) return '请输入正确的价格。';

    const warningThreshold = Number(formData.warningThreshold);
    if (!Number.isFinite(warningThreshold) || warningThreshold < 0) return '请输入正确的预警阈值。';

    const initialStockError = this.validateInitialStock();
    if (initialStockError) return initialStockError;

    return '';
  },

  buildSubmitPayload() {
    const { formData } = this.data;
    const form = normalizeDosageForm(formData.form || formData.dosageForm || '');
    return {
      ...formData,
      form,
      dosageForm: form,
      price: Number(formData.price),
      warningStock: Number(formData.warningStock || 10),
      warningThreshold: Number(formData.warningThreshold || 10),
      minStock: Number(formData.minStock || 10)
    };
  },

  shouldCreateInitialStock() {
    if (this.data.isEdit) return false;
    const quantity = Number(this.data.formData.initialStockQuantity || 0);
    return Number.isInteger(quantity) && quantity > 0;
  },

  buildInitialStockPayload(medicineId, medicineName) {
    const userInfo = getCurrentUser() || {};
    return {
      medicineId,
      medicineName,
      quantity: Number(this.data.formData.initialStockQuantity || 0),
      stockInDate: normalizeText(this.data.formData.initialStockInDate) || getCurrentDateTime(),
      expiryDate: normalizeText(this.data.formData.initialExpiryDate),
      batchNumber: normalizeText(this.data.formData.initialBatchNumber),
      operatorId: userInfo.id,
      operatorName: userInfo.name,
      remark: '新建药品后首批入库'
    };
  },

  navigateToStockInPage(medicineId, medicineName, options = {}) {
    const query = [
      `medicineId=${encodeURIComponent(String(medicineId || ''))}`,
      `medicineName=${encodeURIComponent(medicineName || '')}`,
      'openAdd=1'
    ];
    if (options.quantity) {
      query.push(`quantity=${encodeURIComponent(String(options.quantity))}`);
    }
    if (options.batchNumber) {
      query.push(`batchNumber=${encodeURIComponent(options.batchNumber)}`);
    }
    if (options.expiryDate) {
      query.push(`expiryDate=${encodeURIComponent(options.expiryDate)}`);
    }
    if (options.stockInDate) {
      query.push(`stockInDate=${encodeURIComponent(options.stockInDate)}`);
    }
    wx.navigateTo({
      url: `/pages/medicine/stock-in/index?${query.join('&')}`
    });
  },

  buildCorrectionDiff(payload) {
    const snapshot = this.data.recognitionAppliedSnapshot;
    if (!snapshot) return {};

    const diff = {};
    const compareFields = Array.from(new Set([...RECOGNITION_FIELDS, 'form', 'dosageForm']));
    compareFields.forEach((field) => {
      const before = normalizeText(snapshot[field]);
      const after = normalizeText(payload[field]);
      if (before !== after) {
        diff[field] = { from: before, to: after };
      }
    });
    return diff;
  },

  async syncRecognitionConfirmation(payload) {
    if (!this.data.recognitionSessionId) return;
    const finalPayload = {
      selectedCandidateId: this.data.selectedCandidateId || '',
      recognitionSource: this.data.recognitionSource || '',
      recognitionConfirmed: !!this.data.recognitionConfirmed,
      confirmedAt: this.data.recognitionConfirmed ? new Date().toISOString() : '',
      correctionNote: normalizeText(this.data.correctionNote),
      correctionDiff: this.buildCorrectionDiff(payload),
      finalMedicine: payload
    };
    await confirmRecognitionResult(this.data.recognitionSessionId, finalPayload);
  },

  async submitForm() {
    if (this.data.submitting) return;
    const validationMsg = this.validateForm();
    if (validationMsg) {
      Toast({ context: this, selector: '#t-toast', message: validationMsg });
      return;
    }

    const payload = this.buildSubmitPayload();
    this.setData({ loading: true, submitting: true });
    try {
      let successMessage = '';
      let finalRecognitionPayload = { ...payload };
      if (this.data.isEdit) {
        await updateMedicine(this.data.medicineId, payload);
        finalRecognitionPayload = {
          ...payload,
          medicineId: this.data.medicineId
        };
        successMessage = '药品更新成功。';
      } else {
        const created = await createMedicine(payload);
        const createdMedicineId = created?.data?.id || '';
        const createdMedicineName = payload.name;
        finalRecognitionPayload = {
          ...payload,
          medicineId: createdMedicineId
        };
        if (this.shouldCreateInitialStock()) {
          try {
            await stockIn(this.buildInitialStockPayload(createdMedicineId, createdMedicineName));
            successMessage = '药品建档并入库成功。';
          } catch (stockInError) {
            try {
              await this.syncRecognitionConfirmation(finalRecognitionPayload);
            } catch (syncError) {
              // keep stock-in补录路径优先，不阻塞后续提示
            }
            wx.showModal({
              title: '首批入库未完成',
              content: `药品档案已创建，但首批入库失败：${stockInError.message || '请稍后重试。'}`,
              confirmText: '去补录',
              cancelText: '稍后处理',
              success: (modalRes) => {
                if (modalRes.confirm) {
                  this.navigateToStockInPage(createdMedicineId, createdMedicineName, {
                    quantity: Number(this.data.formData.initialStockQuantity || 0),
                    batchNumber: normalizeText(this.data.formData.initialBatchNumber),
                    expiryDate: normalizeText(this.data.formData.initialExpiryDate),
                    stockInDate: normalizeText(this.data.formData.initialStockInDate) || getCurrentDateTime()
                  });
                }
              }
            });
            throw new Error('__STOCK_IN_PARTIAL__');
          }
        } else {
          successMessage = '药品档案创建成功，可稍后前往入库页补录首批库存。';
        }
      }
      try {
        await this.syncRecognitionConfirmation(finalRecognitionPayload);
        Toast({ context: this, selector: '#t-toast', message: successMessage, theme: 'success' });
      } catch (syncError) {
        Toast({
          context: this,
          selector: '#t-toast',
          message: `${successMessage} 识别确认同步失败，可稍后在识别历史补录。`
        });
      }
      setTimeout(() => wx.navigateBack(), 800);
    } catch (error) {
      if (error && error.message === '__STOCK_IN_PARTIAL__') {
        return;
      }
      Toast({ context: this, selector: '#t-toast', message: error.message || '保存失败，请稍后重试。' });
    } finally {
      this.setData({ loading: false, submitting: false });
    }
  }
});
