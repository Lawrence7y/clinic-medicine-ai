const Toast = require('tdesign-miniprogram/toast/index').default;
const { getPatientList } = require('../../../services/patient/index');

Page({
  data: {
    searchKeyword: '',
    patientList: [],
    loading: false,
    uiState: 'loading',
    errorMessage: '',
    texts: {
      searchPlaceholder: '\u641c\u7d22\u60a3\u8005\u59d3\u540d\u3001\u624b\u673a\u53f7',
      loadFailed: '\u52a0\u8f7d\u5931\u8d25',
      retry: '\u91cd\u8bd5',
      empty: '\u6682\u65e0\u60a3\u8005\u8bb0\u5f55',
      male: '\u7537',
      female: '\u5973',
      ageSuffix: '\u5c81',
      noneAllergy: '\u65e0',
      allergyPrefix: '\u8fc7\u654f\u53f2\uff1a'
    }
  },

  onLoad() {
    this.refreshData();
  },

  onPullDownRefresh() {
    this.refreshData().finally(() => wx.stopPullDownRefresh());
  },

  async refreshData() {
    this.setData({
      patientList: [],
      uiState: 'loading',
      errorMessage: ''
    });
    await this.loadPatients();
  },

  async loadPatients() {
    if (this.data.loading) return;

    this.setData({ loading: true });

    try {
      const params = {
        page: 1,
        pageSize: 10000
      };

      if (this.data.searchKeyword) {
        params.name = this.data.searchKeyword;
      }

      const res = await getPatientList(params);
      const list = Array.isArray(res?.data?.list) ? res.data.list : [];
      this.setData({
        patientList: list,
        uiState: 'ready',
        errorMessage: ''
      });
    } catch (error) {
      const message = error.message || this.data.texts.loadFailed;
      Toast({
        context: this,
        selector: '#t-toast',
        message
      });
      this.setData({
        uiState: 'error',
        errorMessage: message
      });
    } finally {
      this.setData({ loading: false });
    }
  },

  onSearchChange(e) {
    this.setData({
      searchKeyword: e.detail.value
    });
  },

  onSearch() {
    this.refreshData();
  },

  onRetry() {
    this.refreshData();
  },

  goToPatientDetail(e) {
    const id = e.currentTarget.dataset.id;
    wx.navigateTo({
      url: `/pages/patient/detail/index?id=${id}`
    });
  }
});
