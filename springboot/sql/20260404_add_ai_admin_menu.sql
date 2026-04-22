USE WechatProject;

INSERT IGNORE INTO sys_menu (
  menu_id, menu_name, parent_id, order_num, url, target, menu_type, visible, is_refresh, perms, icon,
  create_by, create_time, update_by, update_time, remark
) VALUES
(2060, 'AI 配置', 2000, 7, '#', '', 'M', '0', '1', '', 'fa fa-sliders', 'admin', NOW(), '', NULL, 'AI 配置入口'),
(2061, '服务商配置', 2060, 1, 'clinic/ai/provider', '', 'C', '0', '1', 'clinic:ai:provider:view', 'fa fa-plug', 'admin', NOW(), '', NULL, 'AI 服务商配置'),
(2062, '模型配置', 2060, 2, 'clinic/ai/model', '', 'C', '0', '1', 'clinic:ai:model:view', 'fa fa-cube', 'admin', NOW(), '', NULL, 'AI 模型配置'),
(2063, '场景绑定', 2060, 3, 'clinic/ai/scene', '', 'C', '0', '1', 'clinic:ai:scene:view', 'fa fa-random', 'admin', NOW(), '', NULL, 'AI 场景绑定'),
(2064, '服务商查询', 2061, 1, '', '', 'F', '0', '1', 'clinic:ai:provider:list', '#', 'admin', NOW(), '', NULL, ''),
(2065, '服务商新增', 2061, 2, '', '', 'F', '0', '1', 'clinic:ai:provider:add', '#', 'admin', NOW(), '', NULL, ''),
(2066, '服务商修改', 2061, 3, '', '', 'F', '0', '1', 'clinic:ai:provider:edit', '#', 'admin', NOW(), '', NULL, ''),
(2067, '服务商删除', 2061, 4, '', '', 'F', '0', '1', 'clinic:ai:provider:remove', '#', 'admin', NOW(), '', NULL, ''),
(2068, '服务商测试', 2061, 5, '', '', 'F', '0', '1', 'clinic:ai:provider:test', '#', 'admin', NOW(), '', NULL, ''),
(2069, '模型查询', 2062, 1, '', '', 'F', '0', '1', 'clinic:ai:model:list', '#', 'admin', NOW(), '', NULL, ''),
(2070, '模型新增', 2062, 2, '', '', 'F', '0', '1', 'clinic:ai:model:add', '#', 'admin', NOW(), '', NULL, ''),
(2071, '模型修改', 2062, 3, '', '', 'F', '0', '1', 'clinic:ai:model:edit', '#', 'admin', NOW(), '', NULL, ''),
(2072, '模型删除', 2062, 4, '', '', 'F', '0', '1', 'clinic:ai:model:remove', '#', 'admin', NOW(), '', NULL, ''),
(2073, '场景查询', 2063, 1, '', '', 'F', '0', '1', 'clinic:ai:scene:list', '#', 'admin', NOW(), '', NULL, ''),
(2074, '场景新增', 2063, 2, '', '', 'F', '0', '1', 'clinic:ai:scene:add', '#', 'admin', NOW(), '', NULL, ''),
(2075, '场景修改', 2063, 3, '', '', 'F', '0', '1', 'clinic:ai:scene:edit', '#', 'admin', NOW(), '', NULL, ''),
(2076, '场景删除', 2063, 4, '', '', 'F', '0', '1', 'clinic:ai:scene:remove', '#', 'admin', NOW(), '', NULL, ''),
(2079, 'AI 助手', 2000, 6, 'clinic/ai/assistant', '', 'C', '0', '1', 'clinic:ai:assistant:view', 'fa fa-robot', 'admin', NOW(), '', NULL, 'AI 助手独立入口');

INSERT IGNORE INTO sys_role_menu (role_id, menu_id) VALUES
(1, 2060), (1, 2061), (1, 2062), (1, 2063), (1, 2064), (1, 2065), (1, 2066), (1, 2067), (1, 2068),
(1, 2069), (1, 2070), (1, 2071), (1, 2072), (1, 2073), (1, 2074), (1, 2075), (1, 2076), (1, 2079),
(2, 2060), (2, 2061), (2, 2062), (2, 2063), (2, 2064), (2, 2065), (2, 2066), (2, 2067), (2, 2068),
(2, 2069), (2, 2070), (2, 2071), (2, 2072), (2, 2073), (2, 2074), (2, 2075), (2, 2076), (2, 2079);
