const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser } = require('../../../services/auth/index');
const { USER_ROLES } = require('../../../services/config/index');
const { getMedicalRecordList } = require('../../../services/medical-record/index');

Page({
  data: {
    uiState: 'loading',
    errorText: '',
    searchKeyword: '',
    recordList: [],
    loading: false,
    loadMoreStatus: 0,
    page: 1,
    pageSize: 10,
    doctorId: '',
    texts: {
      loading: '病历加载中...',
      loadFailed: '病历加载失败',
      retry: '重试',
      empty: '暂无病历记录'
    }
  },

  onLoad(options) {
    this.setData({ doctorId: options.doctorId || '' });
    this.initPage();
  },

  onShow() {},

  onPullDownRefresh() {
    Promise.resolve(this.refreshData()).finally(() => wx.stopPullDownRefresh());
  },

  async initPage() {
    const userInfo = getCurrentUser();
    if (!userInfo) {
      wx.redirectTo({ url: '/pages/login/index' });
      return;
    }

    if (!this.data.doctorId && userInfo.role === USER_ROLES.DOCTOR) {
      this.setData({ doctorId: userInfo.id });
    }

    this.refreshData();
  },

  async refreshData() {
    this.setData({
      uiState: 'loading',
      errorText: '',
      page: 1,
      recordList: [],
      loadMoreStatus: 1
    });
    await this.loadRecords();
  },

  async loadRecords() {
    if (this.data.loading) return;

    this.setData({ loading: true });

    try {
      const userInfo = getCurrentUser();
      const params = {
        page: this.data.page,
        pageSize: this.data.pageSize
      };

      if (userInfo && userInfo.role === USER_ROLES.DOCTOR) {
        params.doctorId = userInfo.id;
      }

      if (this.data.searchKeyword) {
        params.patientName = this.data.searchKeyword;
      }

      if (this.data.doctorId) {
        params.doctorId = this.data.doctorId;
      }

      const res = await getMedicalRecordList(params);
      const list = (res.data && res.data.list) || [];
      const total = Number((res.data && res.data.total) || list.length);
      const newList = this.data.page === 1 ? list : [...this.data.recordList, ...list];

      this.setData({
        recordList: newList,
        loadMoreStatus: newList.length >= total ? 2 : 1,
        uiState: newList.length > 0 ? 'ready' : 'empty',
        errorText: ''
      });
    } catch (error) {
      const message = error.message || this.data.texts.loadFailed;
      if ((this.data.recordList || []).length > 0) {
        Toast({
          context: this,
          selector: '#t-toast',
          message
        });
        this.setData({ loadMoreStatus: 3 });
      } else {
        this.setData({
          uiState: 'error',
          errorText: message,
          loadMoreStatus: 3
        });
        Toast({
          context: this,
          selector: '#t-toast',
          message
        });
      }
    } finally {
      this.setData({ loading: false });
    }
  },

  onRetry() {
    this.refreshData();
  },

  loadMore() {
    if (this.data.loadMoreStatus === 2 || this.data.loadMoreStatus === 3 || this.data.loadMoreStatus === 0) return;

    this.setData(
      {
        page: this.data.page + 1
      },
      () => {
        this.loadRecords();
      }
    );
  },

  onSearchChange(e) {
    this.setData({
      searchKeyword: e.detail.value
    });
  },

  onSearch() {
    this.refreshData();
  },

  goToRecordDetail(e) {
    const id = e.currentTarget.dataset.id;
    wx.navigateTo({
      url: `/pages/medical/record-detail/index?id=${id}`
    });
  },

  getGenderText(gender) {
    return gender === 'male' ? '男' : gender === 'female' ? '女' : '其他';
  }
});
