USE WechatProject;

INSERT INTO sys_menu (
  menu_id, menu_name, parent_id, order_num, url, target, menu_type, visible, is_refresh, perms, icon,
  create_by, create_time, update_by, update_time, remark
)
SELECT 2060, 'AI 配置', 2000, 7, '#', '', 'M', '0', '1', '', 'fa fa-sliders',
       'admin', NOW(), '', NULL, 'AI 配置入口'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_id = 2060);

UPDATE sys_menu
SET menu_name = 'AI 配置',
    parent_id = 2000,
    order_num = 7,
    url = '#',
    menu_type = 'M',
    perms = '',
    icon = 'fa fa-sliders',
    remark = 'AI 配置入口'
WHERE menu_id = 2060;

UPDATE sys_menu SET parent_id = 2060, order_num = 1, menu_name = '服务商配置', url = 'clinic/ai/provider' WHERE menu_id = 2061;
UPDATE sys_menu SET parent_id = 2060, order_num = 2, menu_name = '模型配置', url = 'clinic/ai/model' WHERE menu_id = 2062;
UPDATE sys_menu SET parent_id = 2060, order_num = 3, menu_name = '场景绑定', url = 'clinic/ai/scene' WHERE menu_id = 2063;

INSERT INTO sys_menu (
  menu_id, menu_name, parent_id, order_num, url, target, menu_type, visible, is_refresh, perms, icon,
  create_by, create_time, update_by, update_time, remark
)
SELECT 2079, 'AI 助手', 2000, 6, 'clinic/ai/assistant', '', 'C', '0', '1', 'clinic:ai:assistant:view', 'fa fa-robot',
       'admin', NOW(), '', NULL, 'AI 助手独立入口'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM sys_menu WHERE menu_id = 2079);

UPDATE sys_menu
SET menu_name = 'AI 助手',
    parent_id = 2000,
    order_num = 6,
    url = 'clinic/ai/assistant',
    menu_type = 'C',
    perms = 'clinic:ai:assistant:view',
    icon = 'fa fa-robot',
    remark = 'AI 助手独立入口'
WHERE menu_id = 2079;

INSERT IGNORE INTO sys_role_menu (role_id, menu_id) VALUES (1, 2060), (2, 2060), (1, 2079), (2, 2079);
