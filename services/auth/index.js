const { STORAGE_KEYS, USER_ROLES } = require('../config/index');
const { post, get } = require('../_utils/request');

const ROLE_MAPPING = {
  admin: USER_ROLES.SUPER_ADMIN,
  super_admin: USER_ROLES.SUPER_ADMIN,
  common: USER_ROLES.CLINIC_ADMIN,
  clinic_admin: USER_ROLES.CLINIC_ADMIN,
  doctor: USER_ROLES.DOCTOR,
  patient: USER_ROLES.PATIENT
};

const APP_ROLE_TO_BACKEND_ROLE_KEY = {
  [USER_ROLES.SUPER_ADMIN]: 'admin',
  [USER_ROLES.CLINIC_ADMIN]: 'common',
  [USER_ROLES.DOCTOR]: 'doctor',
  [USER_ROLES.PATIENT]: 'patient'
};

const STATUS_MAPPING = {
  '0': 'active',
  '1': 'inactive'
};

const PHONE_PATTERN = /^1\d{10}$/;
const DEFAULT_PASSWORD_MIN_LENGTH = 6;

const LOGIN_COPY = Object.freeze({
  accountPlaceholder: '请输入手机号或 admin',
  accountRequired: '请输入手机号或 admin 账号',
  accountAndPasswordRequired: '请输入手机号或 admin 账号及密码',
  phoneRequired: '请输入手机号',
  phoneInvalid: '请输入正确的手机号',
  phoneLoginOnly: '仅支持手机号登录，admin 账号除外',
  passwordRequired: '请输入密码',
  captchaRequired: '请输入验证码',
  captchaNotReady: '验证码尚未就绪，请刷新后重试',
  captchaLoadFailed: '验证码加载失败',
  captchaImageEmpty: '验证码图片为空',
  captchaInvalidOrExpired: '验证码错误或已过期，请刷新后重试',
  loginFailed: '登录失败',
  loginSuccess: '登录成功'
});

const getPasswordMinLengthText = (minLength = DEFAULT_PASSWORD_MIN_LENGTH) => (
  `密码长度不能少于 ${minLength} 位`
);

const assertNonEmptyString = (value, message) => {
  if (typeof value !== 'string' || value.trim() === '') {
    throw new Error(message);
  }
};

const assertValidPhone = (phone, message = LOGIN_COPY.phoneInvalid) => {
  assertNonEmptyString(String(phone || ''), LOGIN_COPY.phoneRequired);
  if (!PHONE_PATTERN.test(String(phone).trim())) {
    throw new Error(message);
  }
};

const assertValidPassword = (password, minLength = DEFAULT_PASSWORD_MIN_LENGTH) => {
  assertNonEmptyString(String(password || ''), LOGIN_COPY.passwordRequired);
  if (String(password).length < minLength) {
    throw new Error(getPasswordMinLengthText(minLength));
  }
};

const parseUserId = (userId) => {
  const value = Number(userId);
  return Number.isFinite(value) && value > 0 ? value : null;
};

const convertUserRole = (roleKey) => ROLE_MAPPING[roleKey] || USER_ROLES.PATIENT;

const toBackendRoleKey = (role) => APP_ROLE_TO_BACKEND_ROLE_KEY[role] || role || 'patient';

const normalizeRoleKeys = (userData = {}) => {
  if (Array.isArray(userData.roleKeys) && userData.roleKeys.length) {
    return userData.roleKeys.filter(Boolean);
  }
  if (Array.isArray(userData.roles) && userData.roles.length) {
    return userData.roles.map((role) => role && role.roleKey).filter(Boolean);
  }
  return userData.roleKey ? [userData.roleKey] : [];
};

const normalizeUserInfo = (userData = {}, fallbackName = '') => {
  const roleKeys = normalizeRoleKeys(userData);
  const primaryRoleKey = roleKeys[0] || userData.roleKey || 'patient';
  return {
    id: userData.userId != null ? String(userData.userId) : '',
    phone: userData.phonenumber || '',
    name: userData.userName || userData.nickName || fallbackName,
    nickName: userData.nickName || userData.userName || fallbackName,
    role: convertUserRole(primaryRoleKey),
    roleKey: primaryRoleKey,
    roleKeys,
    roles: Array.isArray(userData.roles) ? userData.roles : [],
    avatar: userData.avatar || '',
    email: userData.email || '',
    status: STATUS_MAPPING[userData.status] || 'inactive',
    createdAt: userData.createTime
  };
};

const persistAuthPayload = (payload = {}, fallbackName = '') => {
  const token = payload.token || '';
  const clientKey = payload.clientKey || '';
  const userInfo = normalizeUserInfo(payload.userInfo || payload, fallbackName);

  wx.setStorageSync(STORAGE_KEYS.USER_INFO, userInfo);
  wx.setStorageSync(STORAGE_KEYS.TOKEN, token);
  if (clientKey) {
    wx.setStorageSync(STORAGE_KEYS.CLIENT_KEY, clientKey);
  } else {
    wx.removeStorageSync(STORAGE_KEYS.CLIENT_KEY);
  }
  return userInfo;
};

const normalizeSessionPolicy = (payload = {}) => ({
  maxSessionCount: Number(payload.maxSessionCount || 2),
  kickoutAfterNewLogin: !!payload.kickoutAfterNewLogin,
  kickedSessionCount: Number(payload.kickedSessionCount || 0)
});

const buildUserPayload = (data, options = {}) => {
  const roleKey = toBackendRoleKey(data.roleKey || data.role);
  const payload = {};
  if (data.name !== undefined) {
    payload.userName = data.name;
    payload.nickName = data.name;
  }
  if (data.phone !== undefined) {
    payload.phonenumber = data.phone;
    payload.loginName = data.loginName || data.phone;
  } else if (data.loginName !== undefined) {
    payload.loginName = data.loginName;
  }
  if (data.gender !== undefined) {
    payload.sex = data.gender === 'male' ? '0' : data.gender === 'female' ? '1' : '2';
  }
  if (data.email !== undefined) {
    payload.email = data.email;
  }
  if (roleKey) {
    payload.roleKey = roleKey;
    payload.roleKeys = [roleKey];
  }
  if (options.includePassword) {
    payload.password = data.password || '123456';
  } else if (data.password) {
    payload.password = data.password;
  }
  if (options.includeUserId) {
    const parsedUserId = data.userId != null ? Number(data.userId) : Number(options.userId);
    if (!Number.isNaN(parsedUserId)) {
      payload.userId = parsedUserId;
    }
  }
  return payload;
};

const getLoginCaptcha = () => get('/api/auth/captcha');

const assertValidLoginAccount = (username) => {
  assertNonEmptyString(username, LOGIN_COPY.accountRequired);
  const normalized = String(username).trim();
  if (normalized.toLowerCase() === 'admin') {
    return normalized;
  }
  if (!PHONE_PATTERN.test(normalized)) {
    throw new Error(LOGIN_COPY.phoneLoginOnly);
  }
  return normalized;
};

const login = (username, password, captchaCode = '', captchaId = '') => {
  return new Promise((resolve, reject) => {
    try {
      username = assertValidLoginAccount(username);
      assertNonEmptyString(password, LOGIN_COPY.passwordRequired);
    } catch (error) {
      reject(error);
      return;
    }

    post('/api/auth/login', { username, password, captchaCode, captchaId })
      .then((res) => {
        if (!res.success || !res.data) {
          reject(new Error(res.msg || LOGIN_COPY.loginFailed));
          return;
        }
        const payload = res.data || {};
        const userInfo = persistAuthPayload(payload, username);
        resolve({
          success: true,
          data: {
            userInfo,
            sessionPolicy: normalizeSessionPolicy(payload)
          }
        });
      })
      .catch(reject);
  });
};

const register = (data) => {
  return new Promise((resolve, reject) => {
    try {
      assertValidPhone(data.phone);
      assertValidPassword(data.password);
      assertNonEmptyString(data.name, '请输入姓名。');
    } catch (error) {
      reject(error);
      return;
    }

    post('/api/auth/register', {
      username: data.phone,
      password: data.password,
      phonenumber: data.phone,
      userName: data.name,
      nickName: data.name
    }).then(() => login(data.phone, data.password).then(resolve).catch(reject))
      .catch(reject);
  });
};

const resetPassword = (oldPassword, newPassword) => {
  return new Promise((resolve, reject) => {
    try {
      assertValidPassword(newPassword);
    } catch (error) {
      reject(error);
      return;
    }

    post('/api/auth/profile/resetPwd', { oldPassword: oldPassword || '', newPassword })
      .then(() => resolve({ success: true, message: '密码修改成功。' }))
      .catch(reject);
  });
};

const resetUserPassword = (userId, newPassword) => {
  return new Promise((resolve, reject) => {
    const parsedUserId = parseUserId(userId);
    if (!parsedUserId) {
      reject(new Error('无效的用户 ID。'));
      return;
    }
    try {
      assertValidPassword(newPassword);
    } catch (error) {
      reject(error);
      return;
    }

    post('/api/clinic/user/resetPwd', { userId: parsedUserId, newPassword })
      .then(() => resolve({ success: true, message: '用户密码重置成功。' }))
      .catch(reject);
  });
};

const getCurrentUser = () => wx.getStorageSync(STORAGE_KEYS.USER_INFO);
const getClientKey = () => wx.getStorageSync(STORAGE_KEYS.CLIENT_KEY) || '';

const isLoggedIn = () => {
  const token = wx.getStorageSync(STORAGE_KEYS.TOKEN);
  const userInfo = getCurrentUser();
  return !!token && !!userInfo;
};

const clearLoginState = () => {
  wx.removeStorageSync(STORAGE_KEYS.USER_INFO);
  wx.removeStorageSync(STORAGE_KEYS.TOKEN);
  wx.removeStorageSync(STORAGE_KEYS.CLIENT_KEY);
};

const logout = () => new Promise((resolve) => {
  post('/api/auth/logout', {}).finally(() => {
    clearLoginState();
    resolve();
  });
});

const getSessionList = () => {
  return get('/api/auth/session/list').then((res) => {
    const data = res && res.data ? res.data : {};
    return {
      success: true,
      data: {
        currentSessionId: data.currentSessionId || '',
        total: Number(data.total || 0),
        sessions: Array.isArray(data.sessions) ? data.sessions : [],
        maxSessionCount: Number(data.maxSessionCount || 2),
        kickoutAfterNewLogin: !!data.kickoutAfterNewLogin
      }
    };
  });
};

const kickoutSession = (sessionId) => {
  const normalized = String(sessionId || '').trim();
  if (!normalized) {
    return Promise.reject(new Error('无效的会话 ID。'));
  }
  return post('/api/auth/session/kickout', { sessionId: normalized });
};

const kickoutOtherSessions = () => {
  return post('/api/auth/session/kickoutOthers', {});
};

const updateUserInfo = (userId, data) => {
  return new Promise((resolve, reject) => {
    const updateData = {
      userName: data.name,
      nickName: data.name,
      phonenumber: data.phone,
      email: data.email,
      sex: data.gender === 'male' ? '0' : data.gender === 'female' ? '1' : '2',
      avatar: data.avatar
    };
    post('/api/auth/profile/update', updateData).then(async (res) => {
      if (!res.success) {
        reject(new Error(res.msg || '更新用户资料失败。'));
        return;
      }
      try {
        const userInfoRes = await get('/api/auth/getInfo');
        const userInfo = normalizeUserInfo(userInfoRes.data, data.name);
        wx.setStorageSync(STORAGE_KEYS.USER_INFO, userInfo);
        resolve({ success: true, data: userInfo });
      } catch (error) {
        reject(new Error('刷新用户资料失败。'));
      }
    }).catch(reject);
  });
};

const getUserList = (params = {}) => {
  return new Promise((resolve, reject) => {
    const queryParams = {
      pageNum: params.page || 1,
      pageSize: params.pageSize || 10
    };
    if (params.keyword) {
      const keyword = params.keyword.trim();
      if (/^\d{6,}$/.test(keyword)) {
        queryParams.phonenumber = keyword;
      } else {
        queryParams.userName = keyword;
      }
    }
    if (params.role) {
      queryParams.roleKey = toBackendRoleKey(params.role);
    }

    post('/api/clinic/user/list', queryParams).then((res) => {
      if (!res.success || !res.data) {
        reject(new Error(res.msg || '加载用户列表失败。'));
        return;
      }
      const data = res.data;
      const rawList = Array.isArray(data.rows) ? data.rows
        : Array.isArray(data.list) ? data.list
          : Array.isArray(data.records) ? data.records
            : Array.isArray(data.data) ? data.data : [];

      const list = rawList.map((user) => {
        const normalized = normalizeUserInfo(user, user.userName || user.nickName || '');
        return {
          id: normalized.id,
          name: normalized.name,
          phone: normalized.phone,
          role: normalized.role,
          roleKey: normalized.roleKey,
          roleKeys: normalized.roleKeys,
          roles: normalized.roles,
          status: normalized.status,
          createdAt: normalized.createdAt,
          avatar: normalized.avatar,
          email: normalized.email
        };
      });

      const filteredList = params.role ? list.filter((user) => user.role === params.role) : list;
      const total = data.total ?? data.count ?? data.totalCount ?? filteredList.length;
      resolve({
        success: true,
        data: { list: filteredList, total, page: params.page || 1, pageSize: params.pageSize || 10 }
      });
    }).catch(reject);
  });
};

const getUserDetail = (userId) => {
  return new Promise((resolve, reject) => {
    const parsedUserId = parseUserId(userId);
    if (!parsedUserId) {
      reject(new Error('缺少有效的用户 ID。'));
      return;
    }
    get('/api/clinic/user/getInfo', { userId: parsedUserId }).then((res) => {
      if (!res.success) {
        reject(new Error(res.msg || '加载用户详情失败。'));
        return;
      }
      const normalized = normalizeUserInfo(res.data || {}, '');
      resolve({
        success: true,
        data: {
          id: normalized.id,
          name: normalized.name,
          phone: normalized.phone,
          role: normalized.role,
          roleKey: normalized.roleKey,
          roleKeys: normalized.roleKeys,
          roles: normalized.roles,
          roleName: res.data && res.data.roleName,
          email: normalized.email,
          status: normalized.status,
          createdAt: normalized.createdAt,
          raw: res.data
        }
      });
    }).catch(reject);
  });
};

const getRoleOptions = () => {
  return new Promise((resolve, reject) => {
    get('/api/clinic/user/roles').then((res) => {
      if (!res.success) {
        reject(new Error(res.msg || '加载角色选项失败。'));
        return;
      }
      resolve({
        success: true,
        data: (res.data || []).map((role) => ({
          id: role.roleId,
          key: role.roleKey,
          name: role.roleName,
          appRole: convertUserRole(role.roleKey)
        }))
      });
    }).catch(reject);
  });
};

const addUser = (data) => {
  return new Promise((resolve, reject) => {
    try {
      assertNonEmptyString(data.name, '请输入姓名。');
      if (data.phone !== 'admin') {
        assertValidPhone(data.phone);
      }
      assertValidPassword(data.password);
    } catch (error) {
      reject(error);
      return;
    }
    post('/api/clinic/user/add', buildUserPayload(data, { includePassword: true })).then((res) => {
      if (!res.success) {
        reject(new Error(res.msg || '创建用户失败。'));
        return;
      }
      resolve({ success: true, data: { ...data } });
    }).catch(reject);
  });
};

const batchImportUsers = (userList) => {
  return new Promise((resolve, reject) => {
    const results = { success: 0, failed: 0, errors: [] };
    Promise.all(userList.map((userData, index) => addUser(userData).then(() => {
      results.success += 1;
    }).catch((err) => {
      results.failed += 1;
      results.errors.push(`第 ${index + 1} 行：${err.message}`);
    }))).then(() => {
      resolve({ success: true, data: results });
    }).catch(reject);
  });
};

const updateUser = (userId, data) => {
  return new Promise((resolve, reject) => {
    const parsedUserId = parseUserId(userId);
    if (!parsedUserId) {
      reject(new Error('无效的用户 ID。'));
      return;
    }
    try {
      assertNonEmptyString(data.name, '请输入姓名。');
      if (data.phone !== undefined && data.phone !== 'admin') {
        assertValidPhone(data.phone);
      }
      if (data.password !== undefined && data.password !== '') {
        assertValidPassword(data.password);
      }
    } catch (error) {
      reject(error);
      return;
    }

    post('/api/clinic/user/edit', buildUserPayload({ ...data, userId }, { includeUserId: true, userId })).then((res) => {
      if (!res.success) {
        reject(new Error(res.msg || '更新用户失败。'));
        return;
      }
      resolve({ success: true, data: { id: parsedUserId, ...data } });
    }).catch(reject);
  });
};

const deleteUser = (userId) => {
  return new Promise((resolve, reject) => {
    const parsedUserId = parseUserId(userId);
    if (!parsedUserId) {
      reject(new Error('无效的用户 ID。'));
      return;
    }
    post('/api/clinic/user/remove', { ids: parsedUserId }).then((res) => {
      if (!res.success) {
        reject(new Error(res.msg || '删除用户失败。'));
        return;
      }
      resolve({ success: true, message: '用户删除成功。' });
    }).catch(reject);
  });
};

module.exports = {
  LOGIN_COPY,
  getPasswordMinLengthText,
  getLoginCaptcha,
  login,
  register,
  resetPassword,
  resetUserPassword,
  getCurrentUser,
  getClientKey,
  getRoleOptions,
  isLoggedIn,
  clearLoginState,
  logout,
  getSessionList,
  kickoutSession,
  kickoutOtherSessions,
  updateUserInfo,
  updateUser,
  getUserList,
  getUserDetail,
  addUser,
  batchImportUsers,
  deleteUser,
  USER_ROLES
};
