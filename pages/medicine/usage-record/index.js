const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser } = require('../../../services/auth/index');
const { USER_ROLES } = require('../../../services/config/index');
const { getUsageRecords, getMedicineList } = require('../../../services/medicine/index');

Page({
  data: {
    uiState: 'loading',
    errorText: '',
    searchKeyword: '',
    selectedMedicine: '',
    medicineList: [],
    usageList: [],
    loading: false,
    loadMoreStatus: 0,
    page: 1,
    pageSize: 10,
    total: 0,
    dateRange: [],
    texts: {
      loading: '加载中...',
      loadFailed: '加载失败',
      retry: '重试',
      empty: '暂无使用记录'
    }
  },

  onLoad(options) {
    if (options.medicineId) {
      this.setData({ selectedMedicine: options.medicineId });
    }
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

    this.loadMedicines();
  },

  async loadMedicines() {
    this.setData({ uiState: 'loading', errorText: '' });
    try {
      const res = await getMedicineList({
        page: 1,
        pageSize: 100
      });
      
      const allMedicines = [{ id: '', name: '全部药品' }, ...res.data.list];
      this.setData({
        medicineList: allMedicines
      });
      this.refreshData({ silent: true });
    } catch (error) {
      const message = error.message || '加载药品列表失败';
      this.setData({
        uiState: 'error',
        errorText: message
      });
      Toast({
        context: this,
        selector: '#t-toast',
        message
      });
    }
  },

  async refreshData(options = {}) {
    this.setData({
      page: 1,
      usageList: [],
      loadMoreStatus: 1
    });
    await this.loadUsageRecords(options);
  },

  async loadUsageRecords(options = {}) {
    if (this.data.loading) return;
    const { silent = false, append = false } = options;
    
    this.setData({
      loading: true,
      ...(silent ? {} : { uiState: 'loading', errorText: '' })
    });
    
    try {
      const params = {
        page: this.data.page,
        pageSize: this.data.pageSize
      };
      
      if (this.data.selectedMedicine) {
        params.medicineId = this.data.selectedMedicine;
      }
      
      if (this.data.searchKeyword) {
        params.keyword = this.data.searchKeyword;
      }
      
      const res = await getUsageRecords(params);
      
      const newList = this.data.page === 1 ? res.data.list : [...this.data.usageList, ...res.data.list];
      const isEmpty = newList.length === 0;
      
      this.setData({
        usageList: newList,
        total: res.data.total,
        loadMoreStatus: newList.length >= res.data.total ? 2 : 1,
        uiState: isEmpty ? 'empty' : 'ready',
        errorText: ''
      });
    } catch (error) {
      const message = error.message || this.data.texts.loadFailed;
      const hasExistingList = this.data.usageList.length > 0;
      Toast({
        context: this,
        selector: '#t-toast',
        message
      });
      this.setData({
        loadMoreStatus: 3,
        uiState: hasExistingList || append ? 'ready' : 'error',
        errorText: message
      });
    } finally {
      this.setData({ loading: false });
    }
  },

  onRetry() {
    this.refreshData();
  },

  loadMore() {
    if (this.data.loadMoreStatus === 2) return;
    
    this.setData({
      page: this.data.page + 1
    });
    this.loadUsageRecords({ silent: true, append: true });
  },

  onSearchChange(e) {
    this.setData({
      searchKeyword: e.detail.value
    });
  },

  onSearch() {
    this.refreshData();
  },

  onMedicineChange(e) {
    const { value } = e.detail;
    this.setData({
      selectedMedicine: this.data.medicineList[value].id
    });
    this.refreshData();
  },

  goToDetail(e) {
    const { record } = e.currentTarget.dataset;
    wx.navigateTo({
      url: `/pages/medicine/detail/index?id=${record.medicineId}`
    });
  },

  goBack() {
    wx.navigateBack();
  }
});
