const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser } = require('../../../services/auth/index');
const { USER_ROLES } = require('../../../services/config/index');
const { getMedicineList, deleteMedicine } = require('../../../services/medicine/index');

const ALL_DOSAGE_FORM = '全部剂型';
const DOSAGE_FORM_OPTIONS = [ALL_DOSAGE_FORM, '颗粒剂', '胶囊剂', '片剂', '喷雾剂', '注射剂', '口服液'];

Page({
  data: {
    uiState: 'loading',
    errorMessage: '',
    searchKeyword: '',
    selectedForm: '',
    dosageForms: DOSAGE_FORM_OPTIONS,
    medicineList: [],
    loading: false,
    total: 0,
    isAdmin: false
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

  initPage() {
    const currentUser = getCurrentUser();
    if (!currentUser) {
      wx.redirectTo({ url: '/pages/login/index' });
      return;
    }
    const isAdmin = currentUser.role === USER_ROLES.SUPER_ADMIN || currentUser.role === USER_ROLES.CLINIC_ADMIN;
    this.setData({ isAdmin });
  },

  async refreshData() {
    this.setData({ medicineList: [], uiState: 'loading', errorMessage: '' });
    await this.loadMedicines();
  },

  async loadMedicines() {
    if (this.data.loading) return;
    this.setData({ loading: true });
    try {
      const requestParams = {
        page: 1,
        pageSize: 10000
      };
      if (this.data.searchKeyword) {
        requestParams.name = this.data.searchKeyword;
      }
      if (this.data.selectedForm && this.data.selectedForm !== ALL_DOSAGE_FORM) {
        requestParams.dosageForm = this.data.selectedForm;
      }
      const response = await getMedicineList(requestParams);
      const list = response.data.rows || response.data.list || [];
      this.setData({
        medicineList: list,
        total: Number(response.data.total || list.length),
        uiState: 'ready'
      });
    } catch (error) {
      this.setData({
        uiState: 'error',
        errorMessage: error.message || '加载药品列表失败'
      });
      Toast({ context: this, selector: '#t-toast', message: error.message || '加载药品列表失败' });
    } finally {
      this.setData({ loading: false });
    }
  },

  onRetry() {
    this.refreshData();
  },

  onSearchChange(e) {
    this.setData({ searchKeyword: e.detail.value || '' });
  },

  onSearch() {
    this.refreshData();
  },

  onFormChange(e) {
    const index = Number(e.detail.value);
    this.setData({ selectedForm: this.data.dosageForms[index] || '' });
    this.refreshData();
  },

  goToDetail(e) {
    const { medicine } = e.currentTarget.dataset;
    if (!medicine || !medicine.id) return;
    wx.navigateTo({ url: `/pages/medicine/detail/index?id=${medicine.id}` });
  },

  goToEdit(e) {
    const { medicine } = e.currentTarget.dataset;
    const id = medicine && medicine.id ? `?id=${medicine.id}` : '';
    wx.navigateTo({ url: `/pages/medicine/edit/index${id}` });
  },

  goToAdd() {
    wx.navigateTo({ url: '/pages/medicine/edit/index' });
  },

  goToStockIn() {
    wx.navigateTo({ url: '/pages/medicine/stock-in/index' });
  },

  goToStockOut() {
    wx.navigateTo({ url: '/pages/medicine/stock-out/index' });
  },

  stopPropagation() {},

  async handleDelete(e) {
    const { medicine } = e.currentTarget.dataset;
    if (!medicine || !medicine.id) return;
    wx.showModal({
      title: '确认删除',
      content: `确定要删除药品“${medicine.name || '-'}”吗？`,
      success: async (res) => {
        if (!res.confirm) return;
        this.setData({ loading: true });
        try {
          await deleteMedicine(medicine.id);
          Toast({ context: this, selector: '#t-toast', message: '删除成功', theme: 'success' });
          this.refreshData();
        } catch (error) {
          Toast({ context: this, selector: '#t-toast', message: error.message || '删除失败' });
        } finally {
          this.setData({ loading: false });
        }
      }
    });
  }
});
