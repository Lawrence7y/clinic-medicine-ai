const { post, get } = require('../_utils/request');
const { uploadFile, uploadFiles } = require('../_utils/upload');

const CODE_RECOGNITION_TIMEOUT = 30000;
const IMAGE_RECOGNITION_TIMEOUT = 90000;

const scanMedicineCode = () =>
  new Promise((resolve, reject) => {
    wx.scanCode({
      onlyFromCamera: false,
      scanType: ['barCode', 'qrCode'],
      success: (res) => {
        const code = res && (res.result || res.code) ? String(res.result || res.code).trim() : '';
        if (!code) {
          reject(new Error('未识别到条码内容。'));
          return;
        }
        resolve(code);
      },
      fail: (error) => {
        if (error && /cancel/i.test(error.errMsg || '')) {
          reject(new Error('已取消扫码。'));
          return;
        }
        reject(new Error((error && error.errMsg) || '扫码失败，请重试。'));
      }
    });
  });

const pickRecognitionImage = () =>
  new Promise((resolve, reject) => {
    wx.chooseImage({
      count: 1,
      sizeType: ['compressed'],
      sourceType: ['camera', 'album'],
      success: (res) => {
        const filePath = res && res.tempFilePaths && res.tempFilePaths[0] ? res.tempFilePaths[0] : '';
        if (!filePath) {
          reject(new Error('未选择图片。'));
          return;
        }
        resolve(filePath);
      },
      fail: (error) => {
        if (error && /cancel/i.test(error.errMsg || '')) {
          reject(new Error('已取消选择图片。'));
          return;
        }
        reject(new Error((error && error.errMsg) || '选择图片失败，请重试。'));
      }
    });
  });

const pickRecognitionImages = (count = 3) =>
  new Promise((resolve, reject) => {
    wx.chooseImage({
      count: Math.max(1, Math.min(4, Number(count || 3))),
      sizeType: ['compressed'],
      sourceType: ['camera', 'album'],
      success: (res) => {
        const filePaths = Array.isArray(res && res.tempFilePaths) ? res.tempFilePaths.filter(Boolean) : [];
        if (!filePaths.length) {
          reject(new Error('未选择图片。'));
          return;
        }
        resolve(filePaths);
      },
      fail: (error) => {
        if (error && /cancel/i.test(error.errMsg || '')) {
          reject(new Error('已取消选择图片。'));
          return;
        }
        reject(new Error((error && error.errMsg) || '选择图片失败，请重试。'));
      }
    });
  });

const normalizeRecognitionResult = (result = {}) => ({
  scene: result.scene || '',
  source: result.source || '',
  sessionId: result.sessionId || '',
  localMatched: Boolean(result.localMatched),
  recognizedText: result.recognizedText || '',
  imageCount: Number(result.imageCount || 0),
  candidates: Array.isArray(result.candidates) ? result.candidates : [],
  warnings: Array.isArray(result.warnings) ? result.warnings : []
});

const uploadRecognitionFile = (url, filePath, scene = 'create') =>
  uploadFile({
    url,
    filePath,
    name: 'file',
    formData: { scene },
    timeout: IMAGE_RECOGNITION_TIMEOUT
  }).then((res) => ({
    success: true,
    data: normalizeRecognitionResult(res.data || {})
  }));

const recognizeMedicineByCode = (code, scene = 'create') =>
  post('/api/clinic/medicine/recognize/code', { scene, code }, { timeout: CODE_RECOGNITION_TIMEOUT }).then((res) => ({
    success: true,
    data: normalizeRecognitionResult(res.data || {})
  }));

const recognizeMedicineByImage = (filePath, scene = 'create') =>
  uploadRecognitionFile('/api/clinic/medicine/recognize/image', filePath, scene);

const recognizeMedicineByOcr = (filePath, scene = 'create') =>
  uploadRecognitionFile('/api/clinic/medicine/recognize/ocr', filePath, scene);

const recognizeMedicineByPackageImage = (filePath, scene = 'create') =>
  uploadRecognitionFile('/api/clinic/medicine/recognize/package', filePath, scene);

const recognizeMedicineByMultiImage = (filePaths = [], scene = 'create') =>
  uploadFiles({
    url: '/api/clinic/medicine/recognize/multi-image',
    filePaths,
    name: 'files',
    formData: { scene },
    timeout: IMAGE_RECOGNITION_TIMEOUT
  }).then((res) => ({
    success: true,
    data: normalizeRecognitionResult(res.data || {})
  }));

const recognizeMedicineByVoiceText = (text, scene = 'create') =>
  post('/api/clinic/medicine/recognize/voice-text', { scene, text }, { timeout: CODE_RECOGNITION_TIMEOUT }).then((res) => ({
    success: true,
    data: normalizeRecognitionResult(res.data || {})
  }));

const confirmRecognitionResult = (sessionId, finalPayload) =>
  post('/api/clinic/medicine/recognize/confirm', { sessionId, finalPayload });

const getRecognitionHistory = (limit = 20) =>
  get('/api/clinic/medicine/recognize/history', { limit });

const getRecognitionImageData = (sessionId) =>
  get('/api/clinic/medicine/recognize/image-data', { sessionId });

module.exports = {
  scanMedicineCode,
  pickRecognitionImage,
  pickRecognitionImages,
  recognizeMedicineByCode,
  recognizeMedicineByImage,
  recognizeMedicineByOcr,
  recognizeMedicineByPackageImage,
  recognizeMedicineByMultiImage,
  recognizeMedicineByVoiceText,
  confirmRecognitionResult,
  getRecognitionHistory,
  getRecognitionImageData
};
