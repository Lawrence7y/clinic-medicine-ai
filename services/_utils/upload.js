const { STORAGE_KEYS } = require('../config/index');
const { getRequestUrl } = require('./request');

const normalizeResponse = (requestUrl, res) => {
  let payload = null;
  try {
    payload = JSON.parse(res.data || '{}');
  } catch (error) {
    throw new Error(`上传响应解析失败：${requestUrl}`);
  }

  if (res.statusCode !== 200) {
    throw new Error((payload && (payload.msg || payload.message)) || `上传失败：${res.statusCode}`);
  }

  const code = payload.code;
  if (code === 0 || code === 200 || payload.success) {
    return {
      success: true,
      data: payload.data != null ? payload.data : payload
    };
  }

  throw new Error(payload.msg || payload.message || '上传失败');
};

const handleUploadFail = (requestUrl, error) => {
  const errMsg = error && error.errMsg ? String(error.errMsg) : '';
  if (/timeout/i.test(errMsg)) {
    throw new Error(`上传超时：${requestUrl}`);
  }
  throw new Error(`上传失败：${requestUrl} | ${errMsg || '网络异常'}`);
};

const uploadFile = ({ url, filePath, name = 'file', formData = {}, timeout = 90000, header = {} }) =>
  new Promise((resolve, reject) => {
    const requestUrl = getRequestUrl(url);
    if (!requestUrl) {
      reject(new Error('未配置 API 地址'));
      return;
    }

    const token = wx.getStorageSync(STORAGE_KEYS.TOKEN);
    wx.uploadFile({
      url: requestUrl,
      filePath,
      name,
      formData,
      timeout,
      header: {
        ...(token ? { Authorization: token } : {}),
        ...header
      },
      success: (res) => {
        try {
          resolve(normalizeResponse(requestUrl, res));
        } catch (error) {
          reject(error);
        }
      },
      fail: (error) => {
        try {
          handleUploadFail(requestUrl, error);
        } catch (uploadError) {
          reject(uploadError);
        }
      }
    });
  });

const stringToUint8Array = (text = '') => {
  const bytes = [];
  for (let i = 0; i < text.length; i += 1) {
    const code = text.charCodeAt(i);
    if (code <= 0x7f) {
      bytes.push(code);
    } else if (code <= 0x7ff) {
      bytes.push(0xc0 | (code >> 6), 0x80 | (code & 0x3f));
    } else {
      bytes.push(0xe0 | (code >> 12), 0x80 | ((code >> 6) & 0x3f), 0x80 | (code & 0x3f));
    }
  }
  return new Uint8Array(bytes);
};

const concatUint8Arrays = (parts = []) => {
  const totalLength = parts.reduce((sum, part) => sum + part.length, 0);
  const result = new Uint8Array(totalLength);
  let offset = 0;
  parts.forEach((part) => {
    result.set(part, offset);
    offset += part.length;
  });
  return result.buffer;
};

const readFileAsArrayBuffer = (filePath) =>
  new Promise((resolve, reject) => {
    wx.getFileSystemManager().readFile({
      filePath,
      success: (res) => resolve(res.data),
      fail: reject
    });
  });

const resolveContentType = (filePath = '') => {
  const lower = String(filePath || '').toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.mp3')) return 'audio/mpeg';
  if (lower.endsWith('.wav')) return 'audio/wav';
  if (lower.endsWith('.aac')) return 'audio/aac';
  if (lower.endsWith('.m4a')) return 'audio/mp4';
  return 'image/jpeg';
};

const resolveSafeFilename = (index, filePath = '') => {
  const extMatch = String(filePath || '').match(/(\.[a-z0-9]+)$/i);
  const ext = extMatch ? extMatch[1].toLowerCase() : '.jpg';
  return `upload_${index + 1}${ext}`;
};

const uploadFiles = async ({ url, filePaths = [], name = 'files', formData = {}, timeout = 90000, header = {} }) => {
  const requestUrl = getRequestUrl(url);
  if (!requestUrl) {
    throw new Error('未配置 API 地址');
  }
  const paths = Array.isArray(filePaths) ? filePaths.filter(Boolean) : [];
  if (!paths.length) {
    throw new Error('缺少上传文件');
  }

  const token = wx.getStorageSync(STORAGE_KEYS.TOKEN);
  const boundary = `----codex${Date.now()}`;
  const parts = [];

  Object.keys(formData || {}).forEach((key) => {
    parts.push(stringToUint8Array(`--${boundary}\r\n`));
    parts.push(stringToUint8Array(`Content-Disposition: form-data; name="${key}"\r\n\r\n`));
    parts.push(stringToUint8Array(`${formData[key] == null ? '' : String(formData[key])}\r\n`));
  });

  for (let index = 0; index < paths.length; index += 1) {
    const filePath = paths[index];
    const fileBuffer = new Uint8Array(await readFileAsArrayBuffer(filePath));
    parts.push(stringToUint8Array(`--${boundary}\r\n`));
    parts.push(stringToUint8Array(
      `Content-Disposition: form-data; name="${name}"; filename="${resolveSafeFilename(index, filePath)}"\r\n`
    ));
    parts.push(stringToUint8Array(`Content-Type: ${resolveContentType(filePath)}\r\n\r\n`));
    parts.push(fileBuffer);
    parts.push(stringToUint8Array('\r\n'));
  }
  parts.push(stringToUint8Array(`--${boundary}--\r\n`));

  const data = concatUint8Arrays(parts);
  return new Promise((resolve, reject) => {
    wx.request({
      url: requestUrl,
      method: 'POST',
      data,
      timeout,
      header: {
        'Content-Type': `multipart/form-data; boundary=${boundary}`,
        ...(token ? { Authorization: token } : {}),
        ...header
      },
      responseType: 'text',
      success: (res) => {
        try {
          resolve(normalizeResponse(requestUrl, res));
        } catch (error) {
          reject(error);
        }
      },
      fail: (error) => {
        try {
          handleUploadFail(requestUrl, error);
        } catch (uploadError) {
          reject(uploadError);
        }
      }
    });
  });
};

module.exports = {
  uploadFile,
  uploadFiles
};
