const { get } = require('../_utils/request');

const getAuditLogs = (params = {}) => {
  const query = {
    limit: Number(params.limit || 100)
  };
  if (params.module) query.module = params.module;
  if (params.action) query.action = params.action;
  if (params.keyword) query.keyword = params.keyword;
  if (params.startTime) query.startTime = params.startTime;
  if (params.endTime) query.endTime = params.endTime;
  return get('/api/clinic/audit/logs', query);
};

module.exports = {
  getAuditLogs
};
