const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser } = require('../../../services/auth/index');
const { USER_ROLES } = require('../../../services/config/index');
const { getPatientDetail, getMyPatientInfo } = require('../../../services/patient/index');
const { getMedicalRecordList } = require('../../../services/medical-record/index');

Page({
  data: {
    uiState: 'loading',
    errorText: '',
    patientId: '',
    patientInfo: {},
    recordList: [],
    loading: false,
    page: 1,
    pageSize: 10,
    loadMoreStatus: 0,
    texts: {
      loading: '加载中...',
      loadFailed: '加载就诊记录失败',
      retry: '重试',
      noProfile: '患者档案不存在',
      patientIdMissing: '缺少患者编号',
      empty: '暂无就诊记录'
    }
  },

  onLoad(options = {}) {
    this.setData({ patientId: options.patientId || '' });
    this.initPage();
  },

  onPullDownRefresh() {
    this.refreshData().finally(() => wx.stopPullDownRefresh());
  },

  async initPage() {
    const user = getCurrentUser();
    if (!user) {
      wx.redirectTo({ url: '/pages/login/index' });
      return;
    }
    this.setData({ uiState: 'loading', errorText: '' });

    let patientId = this.data.patientId;
    try {
      if (user.role === USER_ROLES.PATIENT) {
        const mine = await getMyPatientInfo();
        patientId = String(mine?.data?.id || '');
        if (!patientId) {
          this.setData({
            uiState: 'error',
            errorText: this.data.texts.noProfile
          });
          return;
        }
      }

      if (!patientId) {
        this.setData({
          uiState: 'error',
          errorText: this.data.texts.patientIdMissing
        });
        return;
      }

      this.setData({ patientId });
      await this.loadPatientInfo();
      await this.loadRecords();
    } catch (error) {
      this.setData({
        uiState: 'error',
        errorText: error.message || this.data.texts.loadFailed
      });
    }
  },

  async loadPatientInfo() {
    const res = await getPatientDetail(this.data.patientId);
    this.setData({ patientInfo: res?.data || {} });
  },

  async loadRecords(options = {}) {
    if (this.data.loading) return;
    const { silent = false, append = false } = options;
    this.setData({
      loading: true,
      ...(silent ? {} : { uiState: 'loading', errorText: '' })
    });
    try {
      const res = await getMedicalRecordList({
        patientId: this.data.patientId,
        page: this.data.page,
        pageSize: this.data.pageSize
      });
      const list = res?.data?.list || [];
      const total = Number(res?.data?.total || list.length);
      const merged = this.data.page === 1 ? list : [...this.data.recordList, ...list];
      this.setData({
        recordList: merged,
        loadMoreStatus: merged.length >= total ? 2 : 1,
        uiState: merged.length > 0 ? 'ready' : 'empty',
        errorText: ''
      });
    } catch (error) {
      const message = error.message || this.data.texts.loadFailed;
      const hasList = this.data.recordList.length > 0;
      Toast({ context: this, selector: '#t-toast', message });
      this.setData({
        loadMoreStatus: 3,
        uiState: hasList || append ? 'ready' : 'error',
        errorText: message
      });
    } finally {
      this.setData({ loading: false });
    }
  },

  async refreshData() {
    this.setData({ page: 1, recordList: [], loadMoreStatus: 0 });
    await this.loadRecords({ silent: false });
  },

  loadMore() {
    if (this.data.loading || this.data.loadMoreStatus === 2) return;
    this.setData({ page: this.data.page + 1 });
    this.loadRecords({ silent: true, append: true });
  },

  onRetry() {
    this.initPage();
  },

  goToRecordDetail(e) {
    const id = e.currentTarget.dataset.id;
    if (!id) return;
    wx.navigateTo({ url: `/pages/medical/record-detail/index?id=${id}` });
  },

  getGenderText(gender) {
    if (gender === 'male') return '男';
    if (gender === 'female') return '女';
    return '未知';
  }
});
