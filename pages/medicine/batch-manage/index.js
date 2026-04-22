const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser } = require('../../../services/auth/index');
const { USER_ROLES } = require('../../../services/config/index');
const { getMedicineBatches, offShelfBatch } = require('../../../services/medicine/index');

Page({
  data: {
    medicineId: '',
    medicineName: '',
    uiState: 'loading',
    errorText: '',
    loading: false,
    batchList: [],
    canOffShelf: false,
    submittingBatchId: '',
    texts: {
      loading: '加载中...',
      loadFailed: '加载批次失败',
      empty: '暂无批次记录',
      retry: '重试'
    }
  },

  onLoad(options = {}) {
    const userInfo = getCurrentUser();
    if (!userInfo) {
      wx.redirectTo({ url: '/pages/login/index' });
      return;
    }

    const isAdmin = userInfo.role === USER_ROLES.SUPER_ADMIN || userInfo.role === USER_ROLES.CLINIC_ADMIN;
    const isDoctor = userInfo.role === USER_ROLES.DOCTOR;
    if (!isAdmin && !isDoctor) {
      wx.showToast({ title: '无权限查看批次管理', icon: 'none' });
      setTimeout(() => wx.navigateBack(), 1200);
      return;
    }

    const medicineId = options.id || '';
    const medicineName = decodeURIComponent(options.name || '');
    if (!medicineId) {
      wx.showToast({ title: '缺少药品编号', icon: 'none' });
      setTimeout(() => wx.navigateBack(), 1200);
      return;
    }

    this.setData({
      medicineId,
      medicineName,
      canOffShelf: isAdmin
    });
    this.loadBatches();
  },

  onPullDownRefresh() {
    this.loadBatches({ silent: this.data.uiState === 'ready' || this.data.uiState === 'empty' }).finally(() =>
      wx.stopPullDownRefresh()
    );
  },

  async loadBatches(options = {}) {
    if (this.data.loading) return;
    const { silent = false } = options;

    this.setData({
      loading: true,
      ...(silent ? {} : { uiState: 'loading', errorText: '' })
    });
    try {
      const response = await getMedicineBatches(this.data.medicineId);
      const batchList = response.data || [];
      this.setData({
        batchList,
        uiState: batchList.length > 0 ? 'ready' : 'empty',
        errorText: ''
      });
    } catch (error) {
      const message = error.message || this.data.texts.loadFailed;
      this.setData({
        uiState: this.data.batchList.length > 0 ? 'ready' : 'error',
        errorText: message
      });
      Toast({ context: this, selector: '#t-toast', message });
    } finally {
      this.setData({ loading: false });
    }
  },

  onRetry() {
    this.loadBatches();
  },

  getBatchTheme(item) {
    if (item.expired) return 'danger';
    if (item.nearExpiry) return 'warning';
    return 'success';
  },

  getBatchStatus(item) {
    if (item.expired) return '已过期';
    if (item.nearExpiry) return `临期(${item.daysToExpiry}天)`;
    return '正常';
  },

  handleOffShelfBatch(e) {
    const batch = e.currentTarget.dataset.batch || {};
    if (!batch.batchId || Number(batch.remainingQuantity || 0) <= 0 || this.data.submittingBatchId) {
      return;
    }

    wx.showModal({
      title: '批次出库',
      content: `确定对批次“${batch.batchNumber || '-'}”单独出库吗？`,
      success: async (res) => {
        if (!res.confirm) {
          return;
        }

        this.setData({ submittingBatchId: batch.batchId });
        try {
          await offShelfBatch(batch.batchId, `小程序批次出库：${batch.batchNumber || '-'}`);
          Toast({
            context: this,
            selector: '#t-toast',
            message: '批次出库成功',
            theme: 'success'
          });
          await this.loadBatches({ silent: true });
        } catch (error) {
          Toast({
            context: this,
            selector: '#t-toast',
            message: error.message || '批次出库失败'
          });
        } finally {
          this.setData({ submittingBatchId: '' });
        }
      }
    });
  }
});
