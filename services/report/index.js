const { get } = require('../_utils/request');

const sortCountMapToList = (countMap = {}) => {
  return Object.keys(countMap || {})
    .map((key) => ({
      name: key,
      count: Number(countMap[key] || 0)
    }))
    .sort((a, b) => b.count - a.count);
};

const normalizeDailyStats = (rows = [], defaultFields = []) => {
  const list = Array.isArray(rows) ? rows : [];
  return list.map((item) => {
    const next = {
      date: item && item.date ? String(item.date) : ''
    };
    defaultFields.forEach((field) => {
      next[field] = Number(item && item[field] ? item[field] : 0);
    });
    return next;
  });
};

const getReportOverview = (params = {}) => {
  const query = {};
  if (params.startDate) query.startDate = params.startDate;
  if (params.endDate) query.endDate = params.endDate;
  if (params.dimension) query.dimension = params.dimension;

  return get('/api/clinic/report/overview', query).then((res) => {
    const raw = res.data || {};
    const appointment = raw.appointment || {};
    const inventory = raw.inventory || {};
    const nearExpiry = raw.nearExpiry || {};
    const ai = raw.aiInvocation || {};

    return {
      success: true,
      data: {
        generatedAt: Number(raw.generatedAt || Date.now()),
        appointment: {
          total: Number(appointment.total || 0),
          today: Number(appointment.today || 0),
          pending: Number(appointment.pending || 0),
          confirmed: Number(appointment.confirmed || 0),
          completed: Number(appointment.completed || 0),
          cancelled: Number(appointment.cancelled || 0),
          expired: Number(appointment.expired || 0),
          dailyStats: normalizeDailyStats(appointment.dailyStats, ['count'])
        },
        inventory: {
          medicineCount: Number(inventory.medicineCount || 0),
          lowStockCount: Number(inventory.lowStockCount || 0),
          totalStockQuantity: Number(inventory.totalStockQuantity || 0),
          totalStockValue: Number(inventory.totalStockValue || 0)
        },
        nearExpiry: {
          thresholdDays: Number(nearExpiry.thresholdDays || 30),
          nearExpiryBatchCount: Number(nearExpiry.nearExpiryBatchCount || 0),
          nearExpiryQuantity: Number(nearExpiry.nearExpiryQuantity || 0),
          expiredBatchCount: Number(nearExpiry.expiredBatchCount || 0),
          expiredQuantity: Number(nearExpiry.expiredQuantity || 0)
        },
        aiInvocation: {
          sampleSize: Number(ai.sampleSize || 0),
          successCount: Number(ai.successCount || 0),
          failedCount: Number(ai.failedCount || 0),
          successRate: Number(ai.successRate || 0),
          avgDurationMs: Number(ai.avgDurationMs || 0),
          sceneStats: sortCountMapToList(ai.sceneCountMap || {}),
          modelStats: sortCountMapToList(ai.modelCountMap || {}),
          dailyStats: normalizeDailyStats(ai.dailyStats, ['success', 'failed', 'total'])
        },
        rangeStartDate: raw.rangeStartDate || '',
        rangeEndDate: raw.rangeEndDate || '',
        dimension: raw.dimension || 'day'
      }
    };
  });
};

module.exports = {
  getReportOverview
};
