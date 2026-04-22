const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser } = require('../../services/auth/index');
const { USER_ROLES } = require('../../services/config/index');
const { getMedicalRecordList } = require('../../services/medical-record/index');

Page({
  data: {
    uiState: 'loading',
    errorText: '',
    searchKeyword: '',
    startDate: '',
    endDate: '',
    departments: [],
    deptIndex: 0,
    selectedDept: '',
    recordList: [],
    loading: false,
    loadMoreStatus: 0,
    canViewStats: false,
    canCreateRecord: false,
    stats: {
      totalRecords: 0,
      todayRecords: 0,
      thisMonth: 0
    },
    texts: {
      loading: '加载中...',
      loadFailed: '病历数据加载失败',
      retry: '重试',
      empty: '暂无病历记录'
    }
  },

  onLoad() {
    this.safeInitTabBar();
    this.initPage();
  },

  onShow() {
    this.safeInitTabBar();
  },

  onPullDownRefresh() {
    this.refreshData({ silent: this.data.uiState === 'ready' || this.data.uiState === 'empty' })
      .finally(() => wx.stopPullDownRefresh());
  },

  safeInitTabBar() {
    if (typeof this.getTabBar !== 'function') return;
    const tabBar = this.getTabBar();
    if (tabBar && typeof tabBar.init === 'function') {
      tabBar.init();
    }
  },

  async initPage() {
    const userInfo = getCurrentUser();
    if (!userInfo) {
      wx.showToast({
        title: '请先登录',
        icon: 'none'
      });
      setTimeout(() => {
        wx.redirectTo({ url: '/pages/login/index' });
      }, 1000);
      return;
    }

    this.setData({
      uiState: 'loading',
      errorText: '',
      canViewStats: userInfo.role === USER_ROLES.SUPER_ADMIN || 
                    userInfo.role === USER_ROLES.CLINIC_ADMIN ||
                    userInfo.role === USER_ROLES.DOCTOR,
      canCreateRecord: userInfo.role === USER_ROLES.SUPER_ADMIN || 
                       userInfo.role === USER_ROLES.DOCTOR
    });

    try {
      await this.loadStatistics();
      await this.refreshData();
    } catch (error) {
      this.setData({
        uiState: 'error',
        errorText: error && error.message ? error.message : this.data.texts.loadFailed
      });
    }
  },

  async loadStatistics() {
    if (!this.data.canViewStats) return;
    
    try {
      const today = new Date().toISOString().split('T')[0];
      const thisMonth = today.substring(0, 7);
      
      const userInfo = getCurrentUser();
      const params = {
        page: 1,
        pageSize: 10000
      };
      
      if (userInfo.role === USER_ROLES.DOCTOR) {
        params.doctorId = userInfo.id;
      }
      
      const res = await getMedicalRecordList(params);
      const records = res.data.list;
      
      let totalRecords = 0;
      let todayRecords = 0;
      let thisMonthRecords = 0;
      
      records.forEach(record => {
        totalRecords++;
        if (record.visitTime) {
          const visitDate = record.visitTime.split(' ')[0].split('T')[0];
          if (visitDate === today) {
            todayRecords++;
          }
          if (visitDate.startsWith(thisMonth)) {
            thisMonthRecords++;
          }
        }
      });
      
      this.setData({
        'stats.totalRecords': totalRecords,
        'stats.thisMonth': thisMonthRecords,
        'stats.todayRecords': todayRecords
      });
    } catch (error) {
      console.error('加载统计数据失败:', error);
    }
  },

  async refreshData(options = {}) {
    this.setData({
      recordList: [],
      loadMoreStatus: 0
    });
    return this.loadRecords(options);
  },

  async loadRecords(options = {}) {
    if (this.data.loading) return;
    const { silent = false } = options;

    this.setData({
      loading: true,
      ...(silent ? {} : { uiState: 'loading', errorText: '' })
    });
    
    try {
      const userInfo = getCurrentUser();
      const params = {
        page: 1,
        pageSize: 10000
      };
      
      // 医生只能看到自己的病历
      if (userInfo.role === USER_ROLES.DOCTOR) {
        params.doctorId = userInfo.id;
      }
      
      // 患者只能看到自己的病历
      if (this.data.startDate) {
        params.startDate = this.data.startDate;
      }
      if (this.data.endDate) {
        params.endDate = this.data.endDate;
      }
      if (this.data.searchKeyword) {
        params.patientName = this.data.searchKeyword;
      }
      
      const res = await getMedicalRecordList(params);
      const recordList = res.data.list || [];

      this.setData({
        recordList,
        loadMoreStatus: 2,
        uiState: recordList.length > 0 ? 'ready' : 'empty',
        errorText: ''
      });
      return true;
    } catch (error) {
      const message = error.message || this.data.texts.loadFailed;
      const hasOldData = this.data.recordList.length > 0;
      Toast({
        context: this,
        selector: '#t-toast',
        message
      });
      this.setData({
        loadMoreStatus: 3,
        uiState: hasOldData ? 'ready' : 'error',
        errorText: message
      });
      return false;
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

  onStartDateChange(e) {
    this.setData({
      startDate: e.detail.value
    });
    this.refreshData();
  },

  onEndDateChange(e) {
    this.setData({
      endDate: e.detail.value
    });
    this.refreshData();
  },

  onDeptChange(e) {
    const deptIndex = Number(e.detail.value || 0);
    const departments = this.data.departments || [];
    const selectedDept = departments[deptIndex] || '';
    this.setData({
      deptIndex,
      selectedDept
    });
    this.refreshData();
  },

  goToCreateRecord() {
    wx.navigateTo({
      url: '/pages/medical/record-edit/index'
    });
  },

  goToPatientList() {
    wx.navigateTo({
      url: '/pages/patient/list/index'
    });
  },

  goToStatistics() {
    wx.navigateTo({
      url: '/pages/medical/record-statistics/index'
    });
  },

  goToRecordDetail(e) {
    const id = e.currentTarget.dataset.id;
    wx.navigateTo({
      url: `/pages/medical/record-detail/index?id=${id}`
    });
  },

  retryLoad() {
    this.refreshData();
  }
});
