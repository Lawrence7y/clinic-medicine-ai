const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser } = require('../../../services/auth/index');
const { USER_ROLES } = require('../../../services/config/index');
const { getMedicineList } = require('../../../services/medicine/index');

Page({
  data: {
    uiState: 'loading',
    errorMessage: '',
    searchKeyword: '',
    selectedStatus: '',
    inventoryList: [],
    loading: false,
    loadMoreStatus: 0,
    totalCount: 0,
    lowStockCount: 0,
    outOfStockCount: 0
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
    const userInfo = getCurrentUser();
    if (!userInfo) {
      wx.redirectTo({ url: '/pages/login/index' });
      return;
    }

    const isAdmin = userInfo.role === USER_ROLES.SUPER_ADMIN || userInfo.role === USER_ROLES.CLINIC_ADMIN;
    const isDoctor = userInfo.role === USER_ROLES.DOCTOR;
    if (!isAdmin && !isDoctor) {
      this.setData({
        uiState: 'error',
        errorMessage: '无权限查看库存'
      });
      return;
    }
    this.refreshData();
  },

  async loadInventory() {
    if (this.data.loading) return;
    this.setData({ loading: true, uiState: 'loading', errorMessage: '' });
    try {
      const params = { page: 1, pageSize: 10000 };
      const keyword = (this.data.searchKeyword || '').trim();
      if (keyword) params.keyword = keyword;

      const res = await getMedicineList(params);
      const allList = (res.data && res.data.list) || [];
      const totalCount = Number((res.data && res.data.total) || allList.length);
      const lowStockCount = allList.filter((item) => {
        const threshold = item.warningThreshold || item.warningStock || 10;
        return item.stock > 0 && item.stock <= threshold;
      }).length;
      const outOfStockCount = allList.filter((item) => Number(item.stock) <= 0).length;

      let filteredList = allList;
      if (this.data.selectedStatus) {
        filteredList = filteredList.filter((item) => {
          const threshold = item.warningThreshold || item.warningStock || 10;
          if (this.data.selectedStatus === 'out') return Number(item.stock) <= 0;
          if (this.data.selectedStatus === 'low') return Number(item.stock) > 0 && Number(item.stock) <= threshold;
          if (this.data.selectedStatus === 'normal') return Number(item.stock) > threshold;
          return true;
        });
      }

      this.setData({
        inventoryList: filteredList,
        loadMoreStatus: 2,
        totalCount,
        lowStockCount,
        outOfStockCount,
        uiState: 'ready'
      });
    } catch (error) {
      this.setData({
        uiState: 'error',
        errorMessage: error.message || '加载库存失败',
        loadMoreStatus: 3
      });
      Toast({ context: this, selector: '#t-toast', message: error.message || '加载库存失败' });
    } finally {
      this.setData({ loading: false });
    }
  },

  refreshData() {
    this.setData({ inventoryList: [], loadMoreStatus: 0 });
    return this.loadInventory();
  },

  onRetry() {
    this.refreshData();
  },

  loadMore() {
    this.refreshData();
  },

  onSearchChange(e) {
    this.setData({ searchKeyword: e.detail.value || '' });
  },

  onSearch() {
    this.refreshData();
  },

  selectStatus(e) {
    this.setData({ selectedStatus: e.currentTarget.dataset.status || '' });
    this.refreshData();
  },

  goToMedicineDetail(e) {
    const id = e.currentTarget.dataset.id;
    if (!id) return;
    wx.navigateTo({ url: `/pages/medicine/detail/index?id=${id}` });
  },

  getStockStatus(item) {
    const threshold = item.warningThreshold || item.warningStock || 10;
    if (Number(item.stock) <= 0) return '缺货';
    if (Number(item.stock) <= threshold) return '库存不足';
    return '库存充足';
  },

  getStockTheme(item) {
    const threshold = item.warningThreshold || item.warningStock || 10;
    if (Number(item.stock) <= 0) return 'danger';
    if (Number(item.stock) <= threshold) return 'warning';
    return 'success';
  }
});
