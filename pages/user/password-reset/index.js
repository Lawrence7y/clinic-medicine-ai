import Toast from 'tdesign-miniprogram/toast/index';
import { resetPassword, resetUserPassword } from '../../../services/auth/index';

Page({
  data: {
    userId: null,
    oldPassword: '',
    newPassword: '',
    confirmPassword: '',
    loading: false,
    isAdminReset: false
  },

  onLoad(options = {}) {
    this.setData({
      userId: options.id || null,
      isAdminReset: !!options.id
    });
  },

  onOldPasswordChange(e) {
    this.setData({ oldPassword: e.detail.value || '' });
  },

  onPasswordChange(e) {
    this.setData({ newPassword: e.detail.value || '' });
  },

  onConfirmPasswordChange(e) {
    this.setData({ confirmPassword: e.detail.value || '' });
  },

  async handleReset() {
    const { userId, oldPassword, newPassword, confirmPassword, isAdminReset } = this.data;

    if (!isAdminReset && !oldPassword) {
      Toast({
        context: this,
        selector: '#t-toast',
        message: '请输入旧密码'
      });
      return;
    }

    if (!newPassword || String(newPassword).length < 6) {
      Toast({
        context: this,
        selector: '#t-toast',
        message: '密码至少 6 位'
      });
      return;
    }

    if (newPassword !== confirmPassword) {
      Toast({
        context: this,
        selector: '#t-toast',
        message: '两次密码输入不一致'
      });
      return;
    }

    this.setData({ loading: true });
    try {
      if (isAdminReset && userId) {
        await resetUserPassword(userId, newPassword);
      } else {
        await resetPassword(oldPassword, newPassword);
      }

      Toast({
        context: this,
        selector: '#t-toast',
        message: '密码重置成功',
        theme: 'success'
      });

      setTimeout(() => {
        wx.navigateBack();
      }, 1500);
    } catch (error) {
      Toast({
        context: this,
        selector: '#t-toast',
        message: (error && error.message) || '重置失败'
      });
    } finally {
      this.setData({ loading: false });
    }
  }
});
