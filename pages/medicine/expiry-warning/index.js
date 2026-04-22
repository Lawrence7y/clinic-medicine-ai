const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser } = require('../../../services/auth/index');
const { USER_ROLES } = require('../../../services/config/index');
const { getExpiryWarningBatches, offShelfNearExpiryBatches } = require('../../../services/medicine/index');

Page({
  data: {
    uiState: 'loading',
    errorText: '',
    loading: false,
    offShelfLoading: false,
    days: 30,
    searchKeyword: '',
    warningList: [],
    texts: {
      loading: '加载中...',
      loadFailed: '加载失败，请稍后重试',
      empty: '暂无临期批次',
      retry: '重试'
    }
  },

  onLoad() {
    const userInfo = getCurrentUser();
    if (!userInfo) {
      wx.redirectTo({ url: '/pages/login/index' });
      return;
    }

    const canManageMedicine =
      userInfo.role === USER_ROLES.SUPER_ADMIN || userInfo.role === USER_ROLES.CLINIC_ADMIN;
    if (!canManageMedicine) {
      wx.showToast({ title: '无权限访问', icon: 'none' });
      setTimeout(() => wx.navigateBack(), 1200);
      return;
    }

    this.loadWarnings();
  },

  onPullDownRefresh() {
    this.loadWarnings({ silent: this.data.uiState === 'ready' || this.data.uiState === 'empty' }).finally(() =>
      wx.stopPullDownRefresh()
    );
  },

  onSearchChange(e) {
    this.setData({ searchKeyword: e.detail.value });
  },

  onSearch() {
    this.loadWarnings();
  },

  onDaysChange(e) {
    const days = Number(e.currentTarget.dataset.days || 30);
    this.setData({ days });
    this.loadWarnings();
  },

  async loadWarnings(options = {}) {
    if (this.data.loading) {
      return;
    }
    const { silent = false } = options;

    this.setData({
      loading: true,
      ...(silent ? {} : { uiState: 'loading', errorText: '' })
    });
    try {
      const response = await getExpiryWarningBatches({
        days: this.data.days,
        medicineName: this.data.searchKeyword
      });
      const warningList = (response.data || []).map((item) => {
        const daysToExpiry = Number(item.daysToExpiry || 0);
        if (daysToExpiry < 0) {
          return {
            ...item,
            daysTagTheme: 'danger',
            daysTagText: `已过期${Math.abs(daysToExpiry)}天`
          };
        }
        return {
          ...item,
          daysTagTheme: 'warning',
          daysTagText: `${daysToExpiry}天`
        };
      });
      this.setData({
        warningList,
        uiState: warningList.length > 0 ? 'ready' : 'empty',
        errorText: ''
      });
    } catch (error) {
      const message = error.message || this.data.texts.loadFailed;
      this.setData({
        uiState: this.data.warningList.length > 0 ? 'ready' : 'error',
        errorText: message
      });
      Toast({ context: this, selector: '#t-toast', message });
    } finally {
      this.setData({ loading: false });
    }
  },

  onRetry() {
    this.loadWarnings();
  },

  handleOneClickOffShelf() {
    wx.showModal({
      title: '确认下架',
      content: `将下架有效期不足 ${this.data.days} 天的全部批次，是否继续？`,
      success: async (res) => {
        if (!res.confirm) {
          return;
        }
        this.setData({ offShelfLoading: true });
        try {
          const response = await offShelfNearExpiryBatches(this.data.days);
          const data = response.data || {};
          Toast({
            context: this,
            selector: '#t-toast',
            theme: 'success',
            message: `下架完成：药品${data.affectedMedicineCount || 0}种，批次${data.affectedBatchCount || 0}个`
          });
          await this.loadWarnings({ silent: true });
        } catch (error) {
          Toast({ context: this, selector: '#t-toast', message: error.message || '下架失败' });
        } finally {
          this.setData({ offShelfLoading: false });
        }
      }
    });
  },

  goToMedicineDetail(e) {
    const medicineId = e.currentTarget.dataset.medicineId;
    if (!medicineId) {
      return;
    }
    wx.navigateTo({ url: `/pages/medicine/detail/index?id=${medicineId}` });
  }
});
