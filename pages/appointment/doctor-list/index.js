const Toast = require('tdesign-miniprogram/toast/index').default;
const { getDoctorList } = require('../../../services/appointment/index');

Page({
  data: {
    uiState: 'loading',
    errorMessage: '',
    loading: false,
    doctorList: [],
    originDoctorList: [],
    searchKeyword: ''
  },

  onLoad() {
    this.loadDoctors();
  },

  onPullDownRefresh() {
    this.loadDoctors().finally(() => wx.stopPullDownRefresh());
  },

  async loadDoctors() {
    this.setData({ loading: true, uiState: 'loading', errorMessage: '' });
    try {
      const res = await getDoctorList();
      const list = res.data || [];
      this.setData({
        doctorList: list,
        originDoctorList: list,
        uiState: 'ready'
      });
    } catch (error) {
      this.setData({
        uiState: 'error',
        errorMessage: error.message || '加载医生列表失败'
      });
    } finally {
      this.setData({ loading: false });
    }
  },

  onRetry() {
    this.loadDoctors();
  },

  onSearchChange(e) {
    this.setData({ searchKeyword: e.detail.value || '' });
  },

  onSearch() {
    const keyword = (this.data.searchKeyword || '').toLowerCase().trim();
    const list = this.data.originDoctorList || [];
    if (!keyword) {
      this.setData({ doctorList: list });
      return;
    }
    const filteredList = list.filter((doctor) => {
      const name = (doctor.name || '').toLowerCase();
      const intro = (doctor.introduction || '').toLowerCase();
      return name.includes(keyword) || intro.includes(keyword);
    });
    this.setData({ doctorList: filteredList });
  },

  goToDoctorDetail(e) {
    const { doctor } = e.currentTarget.dataset;
    if (!doctor || !doctor.id) {
      Toast({ context: this, selector: '#t-toast', message: '医生信息无效' });
      return;
    }
    const today = new Date();
    const y = today.getFullYear();
    const m = String(today.getMonth() + 1).padStart(2, '0');
    const d = String(today.getDate()).padStart(2, '0');
    const date = `${y}-${m}-${d}`;
    wx.navigateTo({
      url: `/pages/appointment/doctor-schedule/index?doctorId=${doctor.id}&date=${date}`
    });
  }
});
