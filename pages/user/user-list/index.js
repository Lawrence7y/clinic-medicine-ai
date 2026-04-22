const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser, getUserList, addUser, updateUser, deleteUser } = require('../../../services/auth/index');
const { USER_ROLES, ROLE_NAMES } = require('../../../services/config/index');

const PHONE_PATTERN = /^1\d{10}$/;

const validateUserForm = (formData = {}, { isEdit = false } = {}) => {
  const name = String(formData.name || '').trim();
  const phone = String(formData.phone || '').trim();
  const password = String(formData.password || '');

  if (!name) {
    return '请输入姓名';
  }
  if (!phone) {
    return '请输入手机号';
  }
  if (!PHONE_PATTERN.test(phone)) {
    return '请输入正确的 11 位手机号';
  }
  if (!isEdit && !password) {
    return '请输入密码';
  }
  if (password && password.length < 6) {
    return '密码长度不能少于 6 位';
  }
  return '';
};

Page({
  data: {
    uiState: 'loading',
    errorText: '',
    searchKeyword: '',
    selectedRole: '',
    userList: [],
    loading: false,
    loadMoreStatus: 0,
    total: 0,
    showAddModal: false,
    showEditModal: false,
    editingUser: null,
    pickerRoleOptions: ['超级管理员', '诊所管理员', '医生', '患者'],
    pickerRoleValues: [USER_ROLES.SUPER_ADMIN, USER_ROLES.CLINIC_ADMIN, USER_ROLES.DOCTOR, USER_ROLES.PATIENT],
    pickerSelectedIndex: 3,
    formData: {
      name: '',
      phone: '',
      role: USER_ROLES.PATIENT,
      password: ''
    },
    texts: {
      loading: '加载中...',
      loadFailed: '加载失败',
      retry: '重试',
      empty: '暂无用户数据'
    }
  },

  onLoad() {
    this.initPage();
  },

  onShow() {
    this.refreshData();
  },

  onPullDownRefresh() {
    this.refreshData({ silent: this.data.uiState === 'ready' || this.data.uiState === 'empty' })
      .finally(() => wx.stopPullDownRefresh());
  },

  initPage() {
    const userInfo = getCurrentUser();
    if (!userInfo) {
      wx.redirectTo({ url: '/pages/login/index' });
      return;
    }

    const isAdmin = userInfo.role === USER_ROLES.SUPER_ADMIN || userInfo.role === USER_ROLES.CLINIC_ADMIN;
    if (!isAdmin) {
      wx.showToast({ title: '暂无权限访问', icon: 'none' });
      setTimeout(() => wx.navigateBack(), 1200);
      return;
    }
    this.refreshData();
  },

  async refreshData(options = {}) {
    this.setData({ userList: [], loadMoreStatus: 0 });
    await this.loadUsers(options);
  },

  async loadUsers(options = {}) {
    if (this.data.loading) return;
    const { silent = false } = options;
    this.setData({
      loading: true,
      ...(silent ? {} : { uiState: 'loading', errorText: '' })
    });
    try {
      const res = await getUserList({
        page: 1,
        pageSize: 10000,
        keyword: this.data.searchKeyword,
        role: this.data.selectedRole
      });
      this.setData({
        userList: res.data.list || [],
        total: res.data.total,
        loadMoreStatus: 2,
        uiState: (res.data.list || []).length > 0 ? 'ready' : 'empty',
        errorText: ''
      });
    } catch (error) {
      const message = error.message || this.data.texts.loadFailed;
      Toast({ context: this, selector: '#t-toast', message });
      this.setData({
        loadMoreStatus: 3,
        uiState: this.data.userList.length > 0 ? 'ready' : 'error',
        errorText: message
      });
    } finally {
      this.setData({ loading: false });
    }
  },

  onRetry() {
    this.refreshData();
  },

  onSearchChange(e) {
    this.setData({ searchKeyword: e.detail.value });
  },

  onSearch() {
    this.refreshData();
  },

  selectRole(e) {
    this.setData({ selectedRole: e.currentTarget.dataset.role || '' });
    this.refreshData();
  },

  openAddModal() {
    const patientIndex = this.data.pickerRoleValues.findIndex(item => item === USER_ROLES.PATIENT);
    this.setData({
      showAddModal: true,
      pickerSelectedIndex: patientIndex,
      formData: { name: '', phone: '', role: USER_ROLES.PATIENT, password: '' }
    });
  },

  closeAddModal() {
    this.setData({ showAddModal: false });
  },

  openEditModal(e) {
    const user = e.currentTarget.dataset.user;
    if (!this.canEditUser(user)) {
      Toast({ context: this, selector: '#t-toast', message: '无权限编辑该用户' });
      return;
    }
    const roleIndex = this.data.pickerRoleValues.findIndex(item => item === user.role);
    this.setData({
      showEditModal: true,
      editingUser: user,
      pickerSelectedIndex: roleIndex >= 0 ? roleIndex : 3,
      formData: { name: user.name, phone: user.phone, role: user.role, password: '' }
    });
  },

  closeEditModal() {
    this.setData({ showEditModal: false, editingUser: null });
  },

  onFormFieldChange(e) {
    const { field } = e.currentTarget.dataset;
    const { value } = e.detail;
    this.setData({ [`formData.${field}`]: value });
  },

  onRoleSelectChange(e) {
    const index = Number(e.detail.value || 0);
    const selectedRole = this.data.pickerRoleValues[index];
    this.setData({ 'formData.role': selectedRole, pickerSelectedIndex: index });
  },

  async handleAddUser() {
    const { formData } = this.data;
    const validationMessage = validateUserForm(formData);
    if (validationMessage) {
      Toast({ context: this, selector: '#t-toast', message: validationMessage });
      return;
    }
    this.setData({ loading: true });
    try {
      await addUser(formData);
      Toast({ context: this, selector: '#t-toast', message: '新增用户成功', theme: 'success' });
      this.closeAddModal();
      this.refreshData();
    } catch (error) {
      Toast({ context: this, selector: '#t-toast', message: error.message || '新增用户失败' });
    } finally {
      this.setData({ loading: false });
    }
  },

  async handleEditUser() {
    const { formData, editingUser } = this.data;
    const validationMessage = validateUserForm(formData, { isEdit: true });
    if (validationMessage) {
      Toast({ context: this, selector: '#t-toast', message: validationMessage });
      return;
    }
    this.setData({ loading: true });
    try {
      const updateData = { name: formData.name, role: formData.role };
      if (formData.password) updateData.password = formData.password;
      await updateUser(editingUser.id, updateData);
      Toast({ context: this, selector: '#t-toast', message: '更新用户成功', theme: 'success' });
      this.closeEditModal();
      this.refreshData();
    } catch (error) {
      Toast({ context: this, selector: '#t-toast', message: error.message || '更新用户失败' });
    } finally {
      this.setData({ loading: false });
    }
  },

  handleDeleteUser(e) {
    const user = e.currentTarget.dataset.user;
    if (!this.canEditUser(user)) {
      Toast({ context: this, selector: '#t-toast', message: '无权限删除该用户' });
      return;
    }
    const currentUser = getCurrentUser();
    if (String(user.id) === String(currentUser.id)) {
      Toast({ context: this, selector: '#t-toast', message: '不能删除当前登录用户' });
      return;
    }

    wx.showModal({
      title: '确认删除',
      content: `确认删除用户“${user.name}”吗？`,
      success: async (res) => {
        if (!res.confirm) return;
        this.setData({ loading: true });
        try {
          await deleteUser(user.id);
          Toast({ context: this, selector: '#t-toast', message: '删除用户成功', theme: 'success' });
          this.refreshData();
        } catch (error) {
          Toast({ context: this, selector: '#t-toast', message: error.message || '删除用户失败' });
        } finally {
          this.setData({ loading: false });
        }
      }
    });
  },

  getRoleName(role) {
    return ROLE_NAMES[role] || role;
  },

  // 是否有编辑/删除权限（诊所管理员只能编辑医生和患者）
  canEditUser(user = {}) {
    const currentUser = getCurrentUser() || {};
    if (currentUser.role === USER_ROLES.SUPER_ADMIN) {
      return true;
    }
    if (currentUser.role === USER_ROLES.CLINIC_ADMIN) {
      return user.role === USER_ROLES.DOCTOR || user.role === USER_ROLES.PATIENT;
    }
    return false;
  },

  // 是否有管理权限（诊所管理员和超级管理员，管理权限比编辑更宽泛）
  canManageUser(user = {}) {
    const currentUser = getCurrentUser() || {};
    if (currentUser.role === USER_ROLES.SUPER_ADMIN) {
      return true;
    }
    if (currentUser.role === USER_ROLES.CLINIC_ADMIN) {
      return user.role === USER_ROLES.DOCTOR || user.role === USER_ROLES.PATIENT;
    }
    return false;
  },

  goToUserDetail(e) {
    const user = e.currentTarget.dataset.user;
    if (!this.canManageUser(user)) {
      Toast({ context: this, selector: '#t-toast', message: '无权限管理该用户' });
      return;
    }
    wx.navigateTo({
      url: `/pages/user/user-detail/index?userId=${user.id}`
    });
  },

  goBack() {
    wx.navigateBack();
  }
});
