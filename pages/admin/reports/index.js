const Toast = require('tdesign-miniprogram/toast/index').default;
const { getReportOverview } = require('../../../services/report/index');

const DIMENSION_OPTIONS = [
  { value: 'day', label: '按日' },
  { value: 'week', label: '按周' },
  { value: 'month', label: '按月' }
];

const toDayText = (date = new Date()) => {
  const y = date.getFullYear();
  const m = `${date.getMonth() + 1}`.padStart(2, '0');
  const d = `${date.getDate()}`.padStart(2, '0');
  return `${y}-${m}-${d}`;
};

const getLastDaysDateText = (days) => {
  const date = new Date();
  date.setDate(date.getDate() - Math.max(0, Number(days || 0)));
  return toDayText(date);
};

Page({
  data: {
    uiState: 'loading',
    errorText: '',
    loading: false,
    generatedAtText: '',
    filterStartDate: '',
    filterEndDate: '',
    dimensionOptions: DIMENSION_OPTIONS,
    dimensionIndex: 0,
    activeDimension: 'day',
    exporting: false,
    texts: {
      loading: '报表加载中...',
      loadFailed: '报表加载失败',
      retry: '重试',
      emptyTitle: '当前筛选范围暂无统计数据',
      emptyDesc: '请调整时间范围后重试。',
      startDate: '开始日期',
      endDate: '结束日期',
      applyFilter: '应用筛选',
      resetFilter: '重置',
      exportCsv: '导出CSV',
      exportSuccess: '报表 CSV 已复制到剪贴板',
      invalidRange: '开始日期不能晚于结束日期',
      dimension: '时间维度'
    },
    overview: {
      appointment: {
        total: 0,
        today: 0,
        pending: 0,
        confirmed: 0,
        completed: 0,
        cancelled: 0,
        expired: 0,
        dailyStats: []
      },
      inventory: {
        medicineCount: 0,
        lowStockCount: 0,
        totalStockQuantity: 0,
        totalStockValue: 0
      },
      nearExpiry: {
        thresholdDays: 30,
        nearExpiryBatchCount: 0,
        nearExpiryQuantity: 0,
        expiredBatchCount: 0,
        expiredQuantity: 0
      },
      aiInvocation: {
        sampleSize: 0,
        successCount: 0,
        failedCount: 0,
        successRate: 0,
        avgDurationMs: 0,
        sceneStats: [],
        modelStats: [],
        dailyStats: []
      },
      rangeStartDate: '',
      rangeEndDate: '',
      dimension: 'day'
    }
  },

  onLoad() {
    this.initDefaultRange();
    this.loadOverview();
  },

  onPullDownRefresh() {
    this.loadOverview().finally(() => wx.stopPullDownRefresh());
  },

  initDefaultRange() {
    this.setData({
      filterStartDate: getLastDaysDateText(29),
      filterEndDate: toDayText()
    });
  },

  validateDateRange() {
    const { filterStartDate, filterEndDate } = this.data;
    if (!filterStartDate || !filterEndDate) return true;
    return filterStartDate <= filterEndDate;
  },

  buildQuery() {
    const query = {};
    if (this.data.filterStartDate) query.startDate = this.data.filterStartDate;
    if (this.data.filterEndDate) query.endDate = this.data.filterEndDate;
    query.dimension = this.data.activeDimension || 'day';
    return query;
  },

  hasOverviewData(overview = {}) {
    const appointment = overview.appointment || {};
    const inventory = overview.inventory || {};
    const nearExpiry = overview.nearExpiry || {};
    const ai = overview.aiInvocation || {};
    const baseCount = Number(appointment.total || 0)
      + Number(inventory.medicineCount || 0)
      + Number(nearExpiry.nearExpiryBatchCount || 0)
      + Number(ai.sampleSize || 0);
    return baseCount > 0;
  },

  async loadOverview() {
    if (!this.validateDateRange()) {
      Toast({ context: this, selector: '#t-toast', message: this.data.texts.invalidRange });
      return;
    }

    this.setData({ loading: true, uiState: 'loading', errorText: '' });
    try {
      const res = await getReportOverview(this.buildQuery());
      const data = res?.data || this.data.overview;
      this.setData({
        overview: data,
        generatedAtText: this.formatDateTime(data.generatedAt),
        uiState: this.hasOverviewData(data) ? 'ready' : 'empty',
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
    this.loadOverview();
  },

  onStartDateChange(e) {
    this.setData({ filterStartDate: e.detail.value || '' });
  },

  onEndDateChange(e) {
    this.setData({ filterEndDate: e.detail.value || '' });
  },

  onApplyFilter() {
    this.loadOverview();
  },

  onDimensionChange(e) {
    const index = Number(e.detail.value || 0);
    const option = DIMENSION_OPTIONS[index] || DIMENSION_OPTIONS[0];
    this.setData({
      dimensionIndex: Number.isFinite(index) ? index : 0,
      activeDimension: option.value
    });
  },

  onResetFilter() {
    this.initDefaultRange();
    this.setData({
      dimensionIndex: 0,
      activeDimension: 'day'
    });
    this.loadOverview();
  },

  async onExportCsv() {
    if (this.data.exporting || this.data.loading) return;
    this.setData({ exporting: true });
    try {
      const csv = this.buildCsv();
      await new Promise((resolve, reject) => {
        wx.setClipboardData({
          data: csv,
          success: resolve,
          fail: reject
        });
      });
      Toast({
        context: this,
        selector: '#t-toast',
        message: this.data.texts.exportSuccess,
        theme: 'success'
      });
    } catch (error) {
      Toast({
        context: this,
        selector: '#t-toast',
        message: (error && error.message) || '导出失败'
      });
    } finally {
      this.setData({ exporting: false });
    }
  },

  buildCsv() {
    const { overview, filterStartDate, filterEndDate } = this.data;
    const lines = [];
    lines.push('基础报表导出');
    lines.push(`筛选开始日期,${filterStartDate || '-'}`);
    lines.push(`筛选结束日期,${filterEndDate || '-'}`);
    lines.push(`时间维度,${this.data.dimensionOptions[this.data.dimensionIndex].label}`);
    lines.push(`生成时间,${this.data.generatedAtText || '-'}`);
    lines.push('');

    lines.push('预约统计');
    lines.push('指标,数值');
    lines.push(`总预约,${overview.appointment.total}`);
    lines.push(`今日预约,${overview.appointment.today}`);
    lines.push(`待确认,${overview.appointment.pending}`);
    lines.push(`已确认,${overview.appointment.confirmed}`);
    lines.push(`已完成,${overview.appointment.completed}`);
    lines.push(`已取消,${overview.appointment.cancelled}`);
    lines.push(`已过期,${overview.appointment.expired}`);
    lines.push('');

    lines.push('预约按日趋势');
    lines.push('日期,预约数量');
    (overview.appointment.dailyStats || []).forEach((item) => {
      lines.push(`${item.date || '-'},${Number(item.count || 0)}`);
    });
    lines.push('');

    lines.push('库存统计');
    lines.push('指标,数值');
    lines.push(`药品种类,${overview.inventory.medicineCount}`);
    lines.push(`低库存,${overview.inventory.lowStockCount}`);
    lines.push(`库存总量,${overview.inventory.totalStockQuantity}`);
    lines.push(`库存估值,${overview.inventory.totalStockValue}`);
    lines.push('');

    lines.push('近效期统计');
    lines.push('指标,数值');
    lines.push(`近效期批次,${overview.nearExpiry.nearExpiryBatchCount}`);
    lines.push(`近效期数量,${overview.nearExpiry.nearExpiryQuantity}`);
    lines.push(`已过期批次,${overview.nearExpiry.expiredBatchCount}`);
    lines.push(`已过期数量,${overview.nearExpiry.expiredQuantity}`);
    lines.push('');

    lines.push('AI调用统计');
    lines.push('指标,数值');
    lines.push(`样本总数,${overview.aiInvocation.sampleSize}`);
    lines.push(`成功次数,${overview.aiInvocation.successCount}`);
    lines.push(`失败次数,${overview.aiInvocation.failedCount}`);
    lines.push(`成功率,${overview.aiInvocation.successRate}%`);
    lines.push(`平均耗时(ms),${overview.aiInvocation.avgDurationMs}`);
    lines.push('');

    lines.push('AI按日趋势');
    lines.push('日期,成功,失败,总数');
    (overview.aiInvocation.dailyStats || []).forEach((item) => {
      lines.push(`${item.date || '-'},${Number(item.success || 0)},${Number(item.failed || 0)},${Number(item.total || 0)}`);
    });
    lines.push('');

    lines.push('AI按场景');
    lines.push('场景,次数');
    (overview.aiInvocation.sceneStats || []).forEach((item) => {
      lines.push(`${item.name || '-'},${Number(item.count || 0)}`);
    });
    lines.push('');

    lines.push('AI按模型');
    lines.push('模型,次数');
    (overview.aiInvocation.modelStats || []).forEach((item) => {
      lines.push(`${item.name || '-'},${Number(item.count || 0)}`);
    });

    return lines.join('\n');
  },

  formatDateTime(timestamp) {
    const date = new Date(Number(timestamp || Date.now()));
    const y = date.getFullYear();
    const m = `${date.getMonth() + 1}`.padStart(2, '0');
    const d = `${date.getDate()}`.padStart(2, '0');
    const hh = `${date.getHours()}`.padStart(2, '0');
    const mm = `${date.getMinutes()}`.padStart(2, '0');
    const ss = `${date.getSeconds()}`.padStart(2, '0');
    return `${y}-${m}-${d} ${hh}:${mm}:${ss}`;
  }
});
