import Toast from 'tdesign-miniprogram/toast/index';
import { getCurrentUser } from '../../../services/auth/index';
import { USER_ROLES } from '../../../services/config/index';
import { getMedicalRecordStatistics, exportMedicalRecords } from '../../../services/medical-record/index';

Page({
  data: {
    uiState: 'loading',
    errorText: '',
    loading: false,
    selectedTimeRange: '7d',
    timeRangeOptions: [
      { label: '7天', value: '7d' },
      { label: '30天', value: '30d' },
      { label: '90天', value: '90d' },
      { label: '1年', value: '1y' }
    ],
    statistics: {
      totalRecords: 0,
      todayRecords: 0,
      totalPatients: 0,
      averageAge: 0
    },
    diagnosisData: [],
    trendData: [],
    maxTrendValue: 1,
    texts: {
      loading: '统计加载中...',
      loadFailed: '统计加载失败',
      retry: '重试',
      noDiagnosisData: '暂无诊断分布数据',
      noTrendData: '暂无趋势数据'
    }
  },

  onLoad() {
    this.initPage();
  },

  async initPage() {
    const userInfo = getCurrentUser();
    if (!userInfo) {
      wx.redirectTo({ url: '/pages/login/index' });
      return;
    }

    const isAdmin = userInfo.role === USER_ROLES.SUPER_ADMIN || userInfo.role === USER_ROLES.CLINIC_ADMIN;
    const isDoctor = userInfo.role === USER_ROLES.DOCTOR;
    if (!isAdmin && !isDoctor) {
      wx.showToast({
        title: '无权限查看统计数据',
        icon: 'none'
      });
      setTimeout(() => {
        wx.navigateBack();
      }, 1500);
      return;
    }

    await this.loadStatistics();
  },

  async loadStatistics() {
    if (this.data.loading) return;
    this.setData({ loading: true, uiState: 'loading', errorText: '' });
    try {
      const res = await getMedicalRecordStatistics({ timeRange: this.data.selectedTimeRange });
      const stats = res.data || {};
      const totalRecords = Number(stats.totalRecords || 0);
      const diagnosisData = Array.isArray(stats.diagnosisStats)
        ? stats.diagnosisStats.map((item) => {
          const value = Number(item.value || 0);
          const percent = totalRecords > 0 ? (value / totalRecords) * 100 : 0;
          return { ...item, value, percent: Math.max(0, Math.min(100, percent)) };
        })
        : [];
      const trendRaw = Array.isArray(stats.trendData) ? stats.trendData : [];
      const maxTrendValue = Math.max(...trendRaw.map((item) => Number(item.value || 0)), 1);
      const trendData = trendRaw.map((item) => {
        const value = Number(item.value || 0);
        const percent = maxTrendValue > 0 ? (value / maxTrendValue) * 100 : 0;
        return { ...item, value, percent: Math.max(0, Math.min(100, percent)) };
      });

      this.setData({
        statistics: {
          totalRecords,
          todayRecords: Number(stats.todayRecords || 0),
          totalPatients: Number(stats.totalPatients || 0),
          averageAge: Number(stats.averageAge || 0)
        },
        diagnosisData,
        trendData,
        maxTrendValue,
        uiState: 'ready',
        errorText: ''
      });
    } catch (error) {
      const message = error.message || this.data.texts.loadFailed;
      this.setData({
        uiState: 'error',
        errorText: message
      });
      Toast({
        context: this,
        selector: '#t-toast',
        message
      });
    } finally {
      this.setData({ loading: false });
    }
  },

  onRetry() {
    this.loadStatistics();
  },

  selectTimeRange(e) {
    const value = e.currentTarget.dataset.value;
    this.setData({ selectedTimeRange: value });
    this.loadStatistics();
  },

  exportData() {
    exportMedicalRecords({ timeRange: this.data.selectedTimeRange }).then((res) => {
      const token = wx.getStorageSync('token');
      const url = res.data.url;
      wx.downloadFile({
        url,
        header: token ? { Authorization: token } : {},
        success: (dl) => {
          if (dl.statusCode === 200) {
            wx.openDocument({
              filePath: dl.tempFilePath,
              fileType: 'xls',
              showMenu: true,
              fail: () => {
                Toast({
                  context: this,
                  selector: '#t-toast',
                  message: '打开文件失败'
                });
              }
            });
          } else {
            Toast({
              context: this,
              selector: '#t-toast',
              message: '下载失败'
            });
          }
        },
        fail: () => {
          Toast({
            context: this,
            selector: '#t-toast',
            message: '下载失败'
          });
        }
      });
    }).catch((error) => {
      Toast({
        context: this,
        selector: '#t-toast',
        message: error.message || '导出失败'
      });
    });
  }
});
