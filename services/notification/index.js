const { getCurrentUser } = require('../auth/index');
const { USER_ROLES, getConfig, getStoredConfig } = require('../config/index');
const { getAiLogs } = require('../ai/index');
const { getAuditLogs } = require('../audit/index');
const { getAppointmentReminders, getDoctorTodo } = require('../appointment/index');
const { getStockWarnings } = require('../medicine/index');

const READ_MAP_KEY = 'notification_read_map_v1';
const MAX_READ_CACHE_SIZE = 500;

const safeText = (value, fallback = '') => {
  const text = value === undefined || value === null ? '' : String(value).trim();
  return text || fallback;
};

const toDateTimestamp = (date, time) => {
  const dateText = safeText(date);
  const timeText = safeText(time);
  const fullText = `${dateText}${timeText ? ` ${timeText}` : ''}`;
  const timestamp = Date.parse(fullText.replace(/\./g, '-'));
  return Number.isFinite(timestamp) ? timestamp : 0;
};

const normalizeReadMap = (raw) => {
  const source = raw && typeof raw === 'object' ? raw : {};
  const entries = Object.keys(source)
    .map((key) => ({ key, value: Number(source[key] || 0) }))
    .filter((item) => item.key && Number.isFinite(item.value))
    .sort((a, b) => b.value - a.value)
    .slice(0, MAX_READ_CACHE_SIZE);
  const map = {};
  entries.forEach((item) => {
    map[item.key] = item.value;
  });
  return map;
};

const getReadMap = () => {
  try {
    return normalizeReadMap(wx.getStorageSync(READ_MAP_KEY));
  } catch (error) {
    return {};
  }
};

const saveReadMap = (nextMap) => {
  const normalized = normalizeReadMap(nextMap);
  try {
    wx.setStorageSync(READ_MAP_KEY, normalized);
  } catch (error) {
    // ignore storage failures
  }
  return normalized;
};

const markAsRead = (ids = []) => {
  const list = Array.isArray(ids) ? ids : [ids];
  const now = Date.now();
  const map = getReadMap();
  list.forEach((id) => {
    const key = safeText(id);
    if (key) map[key] = now;
  });
  return saveReadMap(map);
};

const markAllAsRead = (list = []) => {
  const ids = (Array.isArray(list) ? list : [])
    .map((item) => item && item.notificationId)
    .filter(Boolean);
  return markAsRead(ids);
};

const buildAppointmentNotification = (item = {}) => {
  const appointmentId = safeText(item.appointmentId || item.id);
  const sceneText = safeText(item.sceneText, '预约提醒');
  const patientName = safeText(item.patientName, '-');
  const doctorName = safeText(item.doctorName, '-');
  const appointmentDate = safeText(item.appointmentDate, '-');
  const appointmentTime = safeText(item.appointmentTime, '-');
  const dateText = `${appointmentDate} ${appointmentTime}`.trim();
  const updateTime = safeText(item.updateTime || item.createTime);
  const timestamp = toDateTimestamp(appointmentDate, appointmentTime) || Date.parse(updateTime) || 0;
  const level = sceneText.includes('取消') ? 'warning' : sceneText.includes('就诊前') ? 'primary' : 'default';

  return {
    notificationId: `appointment:${appointmentId}:${sceneText}:${dateText}`,
    category: 'appointment',
    categoryText: '预约消息',
    level,
    title: sceneText,
    content: `患者：${patientName} | 医生：${doctorName} | 时间：${dateText}`,
    timeText: updateTime || dateText || '-',
    timestamp,
    actionType: 'appointment',
    actionId: appointmentId
  };
};

const buildTodoNotification = (item = {}) => {
  const appointmentId = safeText(item.appointmentId || item.id);
  const patientName = safeText(item.patientName, '-');
  const appointmentDate = safeText(item.appointmentDate, '-');
  const appointmentTime = safeText(item.appointmentTime, '-');
  const todoType = safeText(item.todoType, 'todo');
  const todoTypeText = todoType === 'confirm' ? '待确认预约' : '临近就诊准备';
  const sceneText = safeText(item.sceneText, '医生待办');
  const dateText = `${appointmentDate} ${appointmentTime}`.trim();
  const timestamp = toDateTimestamp(appointmentDate, appointmentTime);

  return {
    notificationId: `todo:${appointmentId}:${todoType}:${dateText}`,
    category: 'todo',
    categoryText: '待办消息',
    level: 'primary',
    title: `${todoTypeText} - ${sceneText}`,
    content: `患者：${patientName} | 时间：${dateText}`,
    timeText: dateText || '-',
    timestamp,
    actionType: 'appointment',
    actionId: appointmentId
  };
};

const buildStockWarningText = (item = {}) => {
  if (item.warningType === 'expired') return '已过期，请立即处理';
  if (item.warningType === 'near_expiry') {
    const days = Number(item.daysToExpiry);
    if (Number.isFinite(days)) return `近效期，${days} 天后过期`;
    return '近效期，请尽快处理';
  }
  return `库存偏低：${Number(item.stock || 0)} / 阈值 ${Number(item.warningThreshold || item.warningStock || 10)}`;
};

const buildStockNotification = (item = {}) => {
  const medicineId = safeText(item.id);
  const name = safeText(item.name, '药品');
  const warningText = buildStockWarningText(item);
  const level = item.warningType === 'expired' ? 'danger' : 'warning';
  return {
    notificationId: `stock:${medicineId}:${warningText}`,
    category: 'stock',
    categoryText: '库存预警',
    level,
    title: `药品预警：${name}`,
    content: warningText,
    timeText: '当前',
    timestamp: Date.now() - 1000,
    actionType: 'medicine',
    actionId: medicineId
  };
};

const formatTimeText = (value) => {
  const timestamp = Number(value || 0);
  if (!Number.isFinite(timestamp) || timestamp <= 0) return '-';
  const date = new Date(timestamp);
  const y = date.getFullYear();
  const m = `${date.getMonth() + 1}`.padStart(2, '0');
  const d = `${date.getDate()}`.padStart(2, '0');
  const hh = `${date.getHours()}`.padStart(2, '0');
  const mm = `${date.getMinutes()}`.padStart(2, '0');
  return `${y}-${m}-${d} ${hh}:${mm}`;
};

const buildSystemNotifications = async ({ isAdmin, isDoctor, isPatient } = {}) => {
  const systemList = [];
  let config = getStoredConfig();
  try {
    const configRes = await getConfig();
    config = configRes?.data || config;
  } catch (error) {
    // use local config fallback
  }

  const configUpdatedAt = Number(config.configUpdatedAt || 0);
  if (configUpdatedAt > 0) {
    systemList.push({
      notificationId: `system:config:${configUpdatedAt}`,
      category: 'system',
      categoryText: '系统消息',
      level: 'primary',
      title: '系统配置已同步',
      content: `当前已同步到最新配置版本，AI 助手名称：${safeText(config.aiAssistantName, 'AI 助手')}`,
      timeText: formatTimeText(configUpdatedAt),
      timestamp: configUpdatedAt,
      actionType: isAdmin ? 'admin-config' : 'ai-chat',
      actionId: 'system-config'
    });
  }

  systemList.push({
    notificationId: `system:ai-status:${config.aiAssistantEnabled ? 'on' : 'off'}:${configUpdatedAt}`,
    category: 'system',
    categoryText: '系统消息',
    level: config.aiAssistantEnabled ? 'primary' : 'warning',
    title: config.aiAssistantEnabled ? 'AI 助手已启用' : 'AI 助手当前关闭',
    content: config.aiAssistantEnabled
      ? '首页快捷入口、我的页和药品页都可继续使用 AI 助手。'
      : '请在系统配置中重新开启 AI 助手入口。',
    timeText: formatTimeText(configUpdatedAt) || '当前',
    timestamp: configUpdatedAt || Date.now() - 500,
    actionType: config.aiAssistantEnabled ? 'ai-chat' : (isAdmin ? 'admin-config' : 'none'),
    actionId: config.aiAssistantEnabled ? 'ai-chat' : 'system-config'
  });

  systemList.push({
    notificationId: `system:security:${config.maxSessionCount || 0}:${config.loginMaxFailCount || 0}`,
    category: 'system',
    categoryText: '系统消息',
    level: 'default',
    title: '登录安全策略已生效',
    content: `连续失败 ${Number(config.loginMaxFailCount || 0)} 次锁定 ${Number(config.loginLockMinutes || 0)} 分钟，最多允许 ${Number(config.maxSessionCount || 0)} 个会话在线。`,
    timeText: formatTimeText(configUpdatedAt) || '当前',
    timestamp: configUpdatedAt || Date.now() - 1000,
    actionType: isAdmin ? 'admin-config' : 'none',
    actionId: 'system-config'
  });

  if (isAdmin || isDoctor) {
    try {
      const [aiLogRes, auditRes] = await Promise.all([
        getAiLogs({ limit: 20, success: false }),
        isAdmin ? getAuditLogs({ limit: 10, module: 'config' }) : Promise.resolve({ data: [] })
      ]);
      const failedLogs = Array.isArray(aiLogRes?.data) ? aiLogRes.data : [];
      if (failedLogs.length) {
        const latest = failedLogs[0] || {};
        systemList.push({
          notificationId: `system:ai-failure:${safeText(latest.time)}:${failedLogs.length}`,
          category: 'system',
          categoryText: '系统消息',
          level: 'warning',
          title: `发现 ${failedLogs.length} 条 AI 异常记录`,
          content: `最近异常场景：${safeText(latest.scene, '-')}${latest.failureReason ? `，原因：${latest.failureReason}` : ''}`,
          timeText: safeText(latest.time, '当前'),
          timestamp: Date.parse(safeText(latest.time).replace(/-/g, '/')) || Date.now() - 1500,
          actionType: 'admin-ai-logs',
          actionId: 'ai-logs'
        });
      }

      const auditLogs = Array.isArray(auditRes?.data) ? auditRes.data : [];
      const configAudit = auditLogs[0];
      if (configAudit && configAudit.time) {
        systemList.push({
          notificationId: `system:audit:${safeText(configAudit.time)}`,
          category: 'system',
          categoryText: '系统消息',
          level: 'primary',
          title: '后台配置最近有变更',
          content: safeText(configAudit.detail, '请进入审计中心查看详情。'),
          timeText: safeText(configAudit.time, '当前'),
          timestamp: Date.parse(safeText(configAudit.time).replace(/-/g, '/')) || Date.now() - 2000,
          actionType: isAdmin ? 'admin-audit' : 'admin-config',
          actionId: 'audit-center'
        });
      }
    } catch (error) {
      // ignore system message enrichment failures
    }
  }

  if (isPatient) {
    return systemList.slice(0, 3);
  }
  return systemList.slice(0, 5);
};

const fetchNotifications = async () => {
  const user = getCurrentUser();
  if (!user || !user.id) {
    throw new Error('请先登录');
  }

  const isAdmin = user.role === USER_ROLES.SUPER_ADMIN || user.role === USER_ROLES.CLINIC_ADMIN;
  const isDoctor = user.role === USER_ROLES.DOCTOR;
  const isPatient = user.role === USER_ROLES.PATIENT;

  const tasks = [getAppointmentReminders()];
  if (isAdmin || isDoctor) {
    tasks.push(getDoctorTodo());
    tasks.push(getStockWarnings());
  } else {
    tasks.push(Promise.resolve({ success: true, data: { todoList: [] } }));
    tasks.push(Promise.resolve({ success: true, data: [] }));
  }
  tasks.push(buildSystemNotifications({ isAdmin, isDoctor, isPatient }));

  const [reminderRes, todoRes, stockRes, systemList] = await Promise.all(tasks);
  const appointmentList = Array.isArray(reminderRes?.data?.list) ? reminderRes.data.list : [];
  const todoList = Array.isArray(todoRes?.data?.todoList) ? todoRes.data.todoList : [];
  const stockList = Array.isArray(stockRes?.data) ? stockRes.data : [];
  const normalizedSystemList = Array.isArray(systemList) ? systemList : [];

  const merged = [
    ...appointmentList.map(buildAppointmentNotification),
    ...(isAdmin || isDoctor ? todoList.map(buildTodoNotification) : []),
    ...(isAdmin || isDoctor ? stockList.map(buildStockNotification) : []),
    ...normalizedSystemList
  ];

  merged.sort((a, b) => Number(b.timestamp || 0) - Number(a.timestamp || 0));

  const readMap = getReadMap();
  const list = merged.map((item) => ({
    ...item,
    read: !!readMap[item.notificationId]
  }));

  const unreadCount = list.filter((item) => !item.read).length;
  const categoryCount = {
    all: list.length,
    appointment: list.filter((item) => item.category === 'appointment').length,
    todo: list.filter((item) => item.category === 'todo').length,
    stock: list.filter((item) => item.category === 'stock').length,
    system: list.filter((item) => item.category === 'system').length
  };

  return {
    list,
    unreadCount,
    categoryCount,
    role: user.role,
    isPatient
  };
};

module.exports = {
  fetchNotifications,
  markAsRead,
  markAllAsRead,
  getReadMap
};
