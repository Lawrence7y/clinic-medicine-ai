const Toast = require('tdesign-miniprogram/toast/index').default;
const {
  getRecognitionHistory,
  getRecognitionImageData
} = require('../../../services/medicine-recognition/index');

const FIELD_LABELS = {
  barcode: '条码',
  name: '药品名称',
  specification: '规格',
  manufacturer: '生产厂家',
  dosageForm: '剂型',
  form: '剂型',
  category: '分类',
  storage: '储存条件',
  pharmacology: '药理作用',
  indications: '适应症',
  dosage: '用法用量',
  sideEffects: '不良反应'
};

const toSafeText = (value) => (value === undefined || value === null ? '' : String(value).trim());
const toArray = (value) => (Array.isArray(value) ? value : []);

const toObject = (value) => {
  if (value && typeof value === 'object' && !Array.isArray(value)) return value;
  return {};
};

const getSourceLabel = (source) => {
  if (source === 'code') return '条码识别';
  if (source === 'image') return '拍照识别';
  if (source === 'ocr') return '说明书 OCR';
  if (source === 'package_image') return '包装图识别';
  if (source === 'multi_image') return '多图识别';
  if (source === 'voice_text') return '语音转写识别';
  return source ? `识别来源：${source}` : '识别来源：未知';
};

const getSceneLabel = (scene) => {
  if (scene === 'create') return '建档场景';
  if (scene) return `场景：${scene}`;
  return '场景：默认';
};

const extractFinalMedicine = (item = {}) => {
  const payload = toObject(item.finalPayload);
  const finalMedicine = toObject(payload.finalMedicine);
  if (Object.keys(finalMedicine).length > 0) return finalMedicine;

  const hasMedicineFields = ['name', 'barcode', 'specification', 'manufacturer']
    .some((field) => toSafeText(payload[field]));
  return hasMedicineFields ? payload : {};
};

const extractCorrectionEntries = (item = {}) => {
  const payload = toObject(item.finalPayload);
  const diff = toObject(payload.correctionDiff);

  return Object.keys(diff).map((key) => {
    const entry = toObject(diff[key]);
    return {
      field: key,
      label: FIELD_LABELS[key] || key,
      from: toSafeText(entry.from) || '-',
      to: toSafeText(entry.to) || '-'
    };
  });
};

const normalizeHistoryItem = (item = {}) => {
  const candidates = toArray(item.candidates).map((candidate) => ({
    ...candidate,
    evidenceUrls: toArray(candidate && candidate.evidenceUrls)
  }));
  const warnings = toArray(item.warnings);
  const finalPayload = toObject(item.finalPayload);
  const finalMedicine = extractFinalMedicine(item);
  const correctionEntries = extractCorrectionEntries(item);
  const correctionNote = toSafeText(finalPayload.correctionNote);
  const finalMedicineId = toSafeText(finalMedicine.medicineId || finalPayload.medicineId);
  const selectedCandidateId = toSafeText(finalPayload.selectedCandidateId);
  const selectedCandidate = candidates.find((candidate) => toSafeText(candidate.candidateId) === selectedCandidateId) || null;
  const selectedCandidateName = selectedCandidate ? toSafeText(selectedCandidate.name) : '';

  return {
    ...item,
    candidates,
    warnings,
    finalPayload,
    finalMedicine,
    imageCount: Number(item.imageCount || (Array.isArray(item.imagePaths) ? item.imagePaths.length : (item.imagePath ? 1 : 0))),
    recognizedText: toSafeText(item.recognizedText),
    correctionEntries,
    correctionCount: correctionEntries.length,
    correctionNote,
    finalMedicineId,
    selectedCandidateId,
    selectedCandidateName,
    sourceLabel: getSourceLabel(toSafeText(item.source)),
    sceneLabel: getSceneLabel(toSafeText(item.scene)),
    hasConfirmedPayload: Object.keys(finalMedicine).length > 0 || correctionEntries.length > 0 || Boolean(correctionNote)
  };
};

Page({
  data: {
    loading: true,
    list: [],
    stateMode: 'loading',
    stateTitle: '正在加载识别历史',
    stateDescription: '',
    previewLoadingSessionId: ''
  },

  onLoad() {
    this.imageFileCache = {};
    this.loadHistory();
  },

  onUnload() {
    this.cleanupImageCache();
  },

  onPullDownRefresh() {
    this.loadHistory().finally(() => wx.stopPullDownRefresh());
  },

  async loadHistory() {
    this.setData({
      loading: true,
      stateMode: 'loading',
      stateTitle: '正在加载识别历史',
      stateDescription: ''
    });

    try {
      const res = await getRecognitionHistory(50);
      const list = Array.isArray(res?.data) ? res.data.map(normalizeHistoryItem) : [];
      this.setData({
        list,
        stateMode: list.length > 0 ? 'success' : 'empty',
        stateTitle: list.length > 0 ? '' : '暂无识别历史',
        stateDescription: list.length > 0 ? '' : '请先在药品编辑页执行扫码识别或拍照识别。'
      });
    } catch (error) {
      const message = (error && error.message) || '识别历史加载失败';
      this.setData({
        stateMode: 'error',
        stateTitle: '识别历史加载失败',
        stateDescription: message
      });
      Toast({
        context: this,
        selector: '#t-toast',
        message
      });
    } finally {
      this.setData({ loading: false });
    }
  },

  onRetry() {
    this.loadHistory();
  },

  async onPreviewOriginal(e) {
    const sessionId = toSafeText(e.currentTarget.dataset.sessionId);
    if (!sessionId) return;

    this.setData({ previewLoadingSessionId: sessionId });
    try {
      const cachedPath = this.imageFileCache[sessionId];
      if (cachedPath) {
        this.previewImage(cachedPath);
        return;
      }

      const res = await getRecognitionImageData(sessionId);
      const payload = toObject(res?.data);
      const imageItems = Array.isArray(payload.images) ? payload.images : [payload];
      const validItems = imageItems.filter((item) => toSafeText(item && item.imageBase64));
      if (!validItems.length) {
        throw new Error('未找到识别原图');
      }
      const filePaths = [];
      for (let index = 0; index < validItems.length; index += 1) {
        const item = validItems[index];
        const filePath = await this.persistImageToTemp(
          `${sessionId}_${index + 1}`,
          toSafeText(item.imageBase64),
          toSafeText(item.contentType) || 'image/jpeg'
        );
        filePaths.push(filePath);
      }
      this.imageFileCache[sessionId] = filePaths;
      this.previewImage(filePaths);
    } catch (error) {
      Toast({
        context: this,
        selector: '#t-toast',
        message: (error && error.message) || '原图预览失败'
      });
    } finally {
      this.setData({ previewLoadingSessionId: '' });
    }
  },

  previewImage(filePath) {
    const urls = Array.isArray(filePath) ? filePath : [filePath];
    wx.previewImage({
      urls,
      current: urls[0],
      fail: () => {
        Toast({
          context: this,
          selector: '#t-toast',
          message: '原图预览失败'
        });
      }
    });
  },

  persistImageToTemp(sessionId, imageBase64, contentType) {
    return new Promise((resolve, reject) => {
      try {
        const ext = this.resolveImageExt(contentType);
        const filePath = `${wx.env.USER_DATA_PATH}/recognition-${sessionId}-${Date.now()}${ext}`;
        const fileSystem = wx.getFileSystemManager();
        const arrayBuffer = wx.base64ToArrayBuffer(imageBase64);
        fileSystem.writeFile({
          filePath,
          data: arrayBuffer,
          encoding: 'binary',
          success: () => resolve(filePath),
          fail: reject
        });
      } catch (error) {
        reject(error);
      }
    });
  },

  resolveImageExt(contentType) {
    const normalized = toSafeText(contentType).toLowerCase();
    if (normalized.includes('png')) return '.png';
    if (normalized.includes('webp')) return '.webp';
    return '.jpg';
  },

  cleanupImageCache() {
    const fileSystem = wx.getFileSystemManager();
    Object.values(this.imageFileCache || {}).forEach((item) => {
      const filePaths = Array.isArray(item) ? item : [item];
      filePaths.forEach((filePath) => {
        if (!filePath || !filePath.startsWith(wx.env.USER_DATA_PATH)) return;
        try {
          fileSystem.unlink({ filePath, fail: () => {} });
        } catch (error) {
          // ignore clean-up errors
        }
      });
    });
    this.imageFileCache = {};
  }
});
