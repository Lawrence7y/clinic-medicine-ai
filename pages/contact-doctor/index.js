import Toast from 'tdesign-miniprogram/toast/index';
import { getDoctorList } from '../../services/appointment/index';

Page({
  data: {
    doctorList: [],
    loading: false,
    uiState: 'loading',
    errorText: '',
    texts: {
      loading: '加载中...',
      loadFailed: '加载失败',
      retry: '重试'
    }
  },

  onLoad() {
    this.loadDoctors();
  },

  onPullDownRefresh() {
    Promise.resolve(this.loadDoctors()).finally(() => wx.stopPullDownRefresh());
  },

  async loadDoctors() {
    this.setData({ loading: true, uiState: 'loading', errorText: '' });
    try {
      const res = await getDoctorList();
      const doctorList = (res.data || []).map((item) => ({
        ...item,
        name: item.name || '',
        phone: item.phone || '',
        wechat: item.wechat || ''
      }));
      this.setData({ doctorList, uiState: 'ready', errorText: '' });
    } catch (error) {
      const message = error.message || this.data.texts.loadFailed;
      this.setData({
        uiState: 'error',
        errorText: message
      });
      Toast({ context: this, selector: '#t-toast', message });
    } finally {
      this.setData({ loading: false });
    }
  },

  onRetry() {
    this.loadDoctors();
  },

  makePhoneCall(e) {
    const { phone } = e.currentTarget.dataset;
    if (!phone) {
      Toast({ context: this, selector: '#t-toast', message: '该医生未填写电话' });
      return;
    }
    wx.makePhoneCall({
      phoneNumber: phone,
      fail: (err) => console.error('拨打电话失败:', err)
    });
  },

  copyWechat(e) {
    const { wechat } = e.currentTarget.dataset;
    if (!wechat) {
      Toast({ context: this, selector: '#t-toast', message: '该医生未填写微信' });
      return;
    }
    wx.setClipboardData({
      data: wechat,
      success: () => Toast({ context: this, selector: '#t-toast', message: '微信号已复制' }),
      fail: () => Toast({ context: this, selector: '#t-toast', message: '复制失败' })
    });
  }
});
