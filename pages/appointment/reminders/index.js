const Toast = require('tdesign-miniprogram/toast/index').default;
const { getCurrentUser } = require('../../../services/auth/index');
const { USER_ROLES } = require('../../../services/config/index');
const {
  getAppointmentReminders,
  getDoctorTodo,
  getAppointmentSubscription,
  saveAppointmentSubscription
} = require('../../../services/appointment/index');

const REMIND_DAY_OPTIONS = [
  { value: 0, label: '当天提醒' },
  { value: 1, label: '提前 1 天' },
  { value: 2, label: '提前 2 天' },
  { value: 3, label: '提前 3 天' },
  { value: 7, label: '提前 7 天' }
];

Page({
  data: {
    uiState: 'loading',
    errorMessage: '',
    reminders: [],
    loading: false,
    emptyText: '暂无预约提醒',
    isPatient: false,
    isDoctorOrAdmin: false,
    savingSubscription: false,
    subscription: {
      appointmentReminder: 1,
      remindDaysBefore: 1,
      subscribeStatus: 'enabled'
    },
    remindDayOptions: REMIND_DAY_OPTIONS,
    remindDayIndex: 1,
    todoStats: {
      pendingCount: 0,
      confirmedCount: 0,
      todayCount: 0,
      nearVisitCount: 0
    },
    todoList: []
  },

  onShow() {
    this.initPage();
  },

  onPullDownRefresh() {
    Promise.resolve(this.loadData()).finally(() => wx.stopPullDownRefresh());
  },

  initPage() {
    const userInfo = getCurrentUser();
    if (!userInfo) {
      wx.redirectTo({ url: '/pages/login/index' });
      return;
    }

    const isAdmin = userInfo.role === USER_ROLES.SUPER_ADMIN || userInfo.role === USER_ROLES.CLINIC_ADMIN;
    const isDoctor = userInfo.role === USER_ROLES.DOCTOR;
    const isPatient = userInfo.role === USER_ROLES.PATIENT;

    if (!isAdmin && !isDoctor && !isPatient) {
      wx.showToast({ title: '暂无权限', icon: 'none' });
      setTimeout(() => wx.navigateBack(), 1000);
      return;
    }

    this.setData({
      isPatient,
      isDoctorOrAdmin: isAdmin || isDoctor
    });
    this.loadData();
  },

  async loadData() {
    if (this.data.loading) return;
    this.setData({ loading: true, uiState: 'loading', errorMessage: '' });
    try {
      const tasks = [getAppointmentReminders(), getAppointmentSubscription()];
      if (this.data.isDoctorOrAdmin) {
        tasks.push(getDoctorTodo());
      }

      const [reminderRes, subscriptionRes, todoRes] = await Promise.all(tasks);
      const reminders = ((reminderRes.data && reminderRes.data.list) || []).map((item) => ({
        ...item,
        sceneTheme: this.getSceneTheme(item.scene),
        sceneText: item.sceneText || this.getSceneText(item.scene)
      }));
      const subscription = this.normalizeSubscription(subscriptionRes && subscriptionRes.data);
      const remindDayIndex = this.resolveRemindDayIndex(subscription.remindDaysBefore);
      const nextState = {
        reminders,
        emptyText: reminders.length === 0 ? '未来 7 天暂无提醒' : '',
        subscription,
        remindDayIndex,
        uiState: 'ready'
      };

      if (todoRes && todoRes.data) {
        nextState.todoStats = {
          pendingCount: todoRes.data.pendingCount || 0,
          confirmedCount: todoRes.data.confirmedCount || 0,
          todayCount: todoRes.data.todayCount || 0,
          nearVisitCount: todoRes.data.nearVisitCount || 0
        };
        nextState.todoList = (todoRes.data.todoList || []).map((item) => ({
          ...item,
          sceneText: item.sceneText || this.getSceneText(item.scene),
          todoTypeText: this.getTodoTypeText(item.todoType)
        }));
      } else {
        nextState.todoList = [];
      }
      this.setData(nextState);
    } catch (error) {
      const message = error.message || '加载提醒失败';
      this.setData({
        uiState: 'error',
        errorMessage: message
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
    this.loadData();
  },

  normalizeSubscription(raw = {}) {
    const remindDaysBefore = Number(raw.remindDaysBefore != null ? raw.remindDaysBefore : 1);
    return {
      appointmentReminder: Number(raw.appointmentReminder != null ? raw.appointmentReminder : 1) === 1 ? 1 : 0,
      remindDaysBefore: Number.isFinite(remindDaysBefore) ? remindDaysBefore : 1,
      subscribeStatus: String(raw.subscribeStatus || 'enabled')
    };
  },

  resolveRemindDayIndex(remindDaysBefore) {
    const idx = REMIND_DAY_OPTIONS.findIndex((item) => item.value === Number(remindDaysBefore));
    return idx >= 0 ? idx : 1;
  },

  onReminderToggle(e) {
    this.setData({
      'subscription.appointmentReminder': e.detail.value ? 1 : 0
    });
  },

  onSubscribeStatusChange(e) {
    this.setData({
      'subscription.subscribeStatus': e.detail.value ? 'enabled' : 'disabled'
    });
  },

  onRemindDayChange(e) {
    const index = Number(e.detail.value || 0);
    const selected = REMIND_DAY_OPTIONS[index] || REMIND_DAY_OPTIONS[1];
    this.setData({
      remindDayIndex: index,
      'subscription.remindDaysBefore': selected.value
    });
  },

  async onSaveSubscription() {
    if (this.data.savingSubscription) return;
    this.setData({ savingSubscription: true });
    try {
      const payload = {
        appointmentReminder: this.data.subscription.appointmentReminder === 1,
        remindDaysBefore: this.data.subscription.remindDaysBefore,
        subscribeStatus: this.data.subscription.subscribeStatus
      };
      await saveAppointmentSubscription(payload);
      Toast({
        context: this,
        selector: '#t-toast',
        message: '提醒设置已保存',
        theme: 'success'
      });
    } catch (error) {
      Toast({
        context: this,
        selector: '#t-toast',
        message: error.message || '保存提醒设置失败'
      });
    } finally {
      this.setData({ savingSubscription: false });
    }
  },

  getSceneTheme(scene) {
    if (scene === 'appointment_cancelled') return 'danger';
    if (scene === 'appointment_rescheduled') return 'warning';
    if (scene === 'before_visit') return 'success';
    return 'primary';
  },

  getSceneText(scene) {
    if (scene === 'appointment_created') return '预约成功';
    if (scene === 'appointment_rescheduled') return '预约改约';
    if (scene === 'appointment_cancelled') return '预约取消';
    if (scene === 'before_visit') return '就诊前提醒';
    if (scene === 'doctor_todo') return '医生待办';
    return '预约提醒';
  },

  getTodoTypeText(todoType) {
    if (todoType === 'confirm') return '待确认';
    if (todoType === 'prepare') return '待准备';
    return '待处理';
  },

  goToAppointmentDetail(e) {
    const id = e.currentTarget.dataset.id;
    if (!id) return;
    wx.navigateTo({ url: `/pages/appointment/appointment-detail/index?id=${id}` });
  },

  goToDoctorWorkbench() {
    wx.navigateTo({ url: '/pages/appointment/doctor-workbench/index' });
  }
});
