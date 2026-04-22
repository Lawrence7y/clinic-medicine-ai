-- =========================================
-- 诊所管理系统完整数据库初始化脚本
-- 创建日期：2026-03-08
-- =========================================

-- 禁用外键检查，避免创建表时的约束问题
SET FOREIGN_KEY_CHECKS = 0;

USE WechatProject;

-- =========================================
-- 第1部分：ry_20250416.sql
-- =========================================

-- ----------------------------
-- 1、部门表
-- ----------------------------
drop table if exists sys_dept;
create table sys_dept (
  dept_id           bigint(20)      not null auto_increment    comment '部门id',
  parent_id         bigint(20)      default 0                  comment '父部门id',
  ancestors         varchar(50)     default ''                 comment '祖级列表',
  dept_name         varchar(30)     default ''                 comment '部门名称',
  order_num         int(4)          default 0                  comment '显示顺序',
  leader            varchar(20)     default null               comment '负责人',
  phone             varchar(11)     default null               comment '联系电话',
  email             varchar(50)     default null               comment '邮箱',
  status            char(1)         default '0'                comment '部门状态（0正常 1停用）',
  del_flag          char(1)         default '0'                comment '删除标志（0代表存在 2代表删除）',
  create_by         varchar(64)     default ''                 comment '创建者',
  create_time 	    datetime                                   comment '创建时间',
  update_by         varchar(64)     default ''                 comment '更新者',
  update_time       datetime                                   comment '更新时间',
  primary key (dept_id)
) engine=innodb auto_increment=200 comment = '部门表';

-- ----------------------------
-- 初始化-部门表数据
-- ----------------------------
insert into sys_dept values(100,  0,   '0',          '若依科技',   0, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', sysdate(), '', null);
insert into sys_dept values(101,  100, '0,100',      '深圳总公司', 1, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', sysdate(), '', null);
insert into sys_dept values(102,  100, '0,100',      '长沙分公司', 2, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', sysdate(), '', null);
insert into sys_dept values(103,  101, '0,100,101',  '研发部门',   1, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', sysdate(), '', null);
insert into sys_dept values(104,  101, '0,100,101',  '市场部门',   2, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', sysdate(), '', null);
insert into sys_dept values(105,  101, '0,100,101',  '测试部门',   3, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', sysdate(), '', null);
insert into sys_dept values(106,  101, '0,100,101',  '财务部门',   4, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', sysdate(), '', null);
insert into sys_dept values(107,  101, '0,100,101',  '运维部门',   5, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', sysdate(), '', null);
insert into sys_dept values(108,  102, '0,100,102',  '市场部门',   1, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', sysdate(), '', null);
insert into sys_dept values(109,  102, '0,100,102',  '财务部门',   2, '若依', '15888888888', 'ry@qq.com', '0', '0', 'admin', sysdate(), '', null);


-- ----------------------------
-- 2、用户信息表
-- ----------------------------
drop table if exists sys_user;
create table sys_user (
  user_id           bigint(20)      not null auto_increment    comment '用户ID',
  dept_id           bigint(20)      default null               comment '部门ID',
  login_name        varchar(30)     not null                   comment '登录账号',
  user_name         varchar(30)     default ''                 comment '用户昵称',
  user_type         varchar(2)      default '00'               comment '用户类型（00系统用户 01注册用户）',
  email             varchar(50)     default ''                 comment '用户邮箱',
  phonenumber       varchar(11)     default ''                 comment '手机号码',
  sex               char(1)         default '0'                comment '用户性别（0男 1女 2未知）',
  avatar            varchar(100)    default ''                 comment '头像路径',
  password          varchar(50)     default ''                 comment '密码',
  salt              varchar(20)     default ''                 comment '盐加密',
  status            char(1)         default '0'                comment '账号状态（0正常 1停用）',
  del_flag          char(1)         default '0'                comment '删除标志（0代表存在 2代表删除）',
  login_ip          varchar(128)    default ''                 comment '最后登录IP',
  login_date        datetime                                   comment '最后登录时间',
  pwd_update_date   datetime                                   comment '密码最后更新时间',
  create_by         varchar(64)     default ''                 comment '创建者',
  create_time       datetime                                   comment '创建时间',
  update_by         varchar(64)     default ''                 comment '更新者',
  update_time       datetime                                   comment '更新时间',
  remark            varchar(500)    default null               comment '备注',
  primary key (user_id)
) engine=innodb auto_increment=100 comment = '用户信息表';

-- ----------------------------
-- 初始化-用户信息表数据
-- 统一密码: 123456 (MD5(login_name + 123456 + salt))
-- ----------------------------
-- admin 密码: MD5("admin" + "123456" + "111111") = 3d3e2e119996cedb7401025cced5c1b0
-- ry 密码: MD5("ry" + "123456" + "222222") = 9b50fd829c98a54dfea6ca29bfc4f30e
insert into sys_user values(1,  103, 'admin', '若依', '00', 'ry@163.com', '15888888888', '1', '', '3d3e2e119996cedb7401025cced5c1b0', '111111', '0', '0', '127.0.0.1', null, null, 'admin', sysdate(), '', null, '管理员');
insert into sys_user values(2,  105, 'ry',    '若依', '00', 'ry@qq.com',  '15666666666', '1', '', '9b50fd829c98a54dfea6ca29bfc4f30e', '222222', '0', '0', '127.0.0.1', null, null, 'admin', sysdate(), '', null, '测试员');


-- ----------------------------
-- 3、岗位信息表
-- ----------------------------
drop table if exists sys_post;
create table sys_post
(
  post_id       bigint(20)      not null auto_increment    comment '岗位ID',
  post_code     varchar(64)     not null                   comment '岗位编码',
  post_name     varchar(50)     not null                   comment '岗位名称',
  post_sort     int(4)          not null                   comment '显示顺序',
  status        char(1)         not null                   comment '状态（0正常 1停用）',
  create_by     varchar(64)     default ''                 comment '创建者',
  create_time   datetime                                   comment '创建时间',
  update_by     varchar(64)     default ''			       comment '更新者',
  update_time   datetime                                   comment '更新时间',
  remark        varchar(500)    default null               comment '备注',
  primary key (post_id)
) engine=innodb comment = '岗位信息表';

-- ----------------------------
-- 初始化-岗位信息表数据
-- ----------------------------
insert into sys_post values(1, 'ceo',  '董事长',    1, '0', 'admin', sysdate(), '', null, '');
insert into sys_post values(2, 'se',   '项目经理',  2, '0', 'admin', sysdate(), '', null, '');
insert into sys_post values(3, 'hr',   '人力资源',  3, '0', 'admin', sysdate(), '', null, '');
insert into sys_post values(4, 'user', '普通员工',  4, '0', 'admin', sysdate(), '', null, '');


-- ----------------------------
-- 4、角色信息表
-- ----------------------------
drop table if exists sys_role;
create table sys_role (
  role_id           bigint(20)      not null auto_increment    comment '角色ID',
  role_name         varchar(30)     not null                   comment '角色名称',
  role_key          varchar(100)    not null                   comment '角色权限字符串',
  role_sort         int(4)          not null                   comment '显示顺序',
  data_scope        char(1)         default '1'                comment '数据范围（1：全部数据权限 2：自定数据权限 3：本部门数据权限 4：本部门及以下数据权限）',
  status            char(1)         not null                   comment '角色状态（0正常 1停用）',
  del_flag          char(1)         default '0'                comment '删除标志（0代表存在 2代表删除）',
  create_by         varchar(64)     default ''                 comment '创建者',
  create_time       datetime                                   comment '创建时间',
  update_by         varchar(64)     default ''                 comment '更新者',
  update_time       datetime                                   comment '更新时间',
  remark            varchar(500)    default null               comment '备注',
  primary key (role_id)
) engine=innodb auto_increment=100 comment = '角色信息表';

-- ----------------------------
-- 初始化-角色信息表数据
-- ----------------------------
insert into sys_role values('1', '超级管理员', 'admin',  1, 1, '0', '0', 'admin', sysdate(), '', null, '超级管理员');
insert into sys_role values('2', '普通角色',   'common', 2, 2, '0', '0', 'admin', sysdate(), '', null, '普通角色');


-- ----------------------------
-- 5、菜单权限表
-- ----------------------------
drop table if exists sys_menu;
create table sys_menu (
  menu_id           bigint(20)      not null auto_increment    comment '菜单ID',
  menu_name         varchar(50)     not null                   comment '菜单名称',
  parent_id         bigint(20)      default 0                  comment '父菜单ID',
  order_num         int(4)          default 0                  comment '显示顺序',
  url               varchar(200)    default '#'                comment '请求地址',
  target            varchar(20)     default ''                 comment '打开方式（menuItem页签 menuBlank新窗口）',
  menu_type         char(1)         default ''                 comment '菜单类型（M目录 C菜单 F按钮）',
  visible           char(1)         default 0                  comment '菜单状态（0显示 1隐藏）',
  is_refresh        char(1)         default 1                  comment '是否刷新（0刷新 1不刷新）',
  perms             varchar(100)    default null               comment '权限标识',
  icon              varchar(100)    default '#'                comment '菜单图标',
  create_by         varchar(64)     default ''                 comment '创建者',
  create_time       datetime                                   comment '创建时间',
  update_by         varchar(64)     default ''                 comment '更新者',
  update_time       datetime                                   comment '更新时间',
  remark            varchar(500)    default ''                 comment '备注',
  primary key (menu_id)
) engine=innodb auto_increment=2000 comment = '菜单权限表';

-- ----------------------------
-- 初始化-菜单信息表数据
-- ----------------------------
-- 一级菜单
insert into sys_menu values('1', '系统管理', '0', '1', '#',                '',          'M', '0', '1', '', 'fa fa-gear',           'admin', sysdate(), '', null, '系统管理目录');
insert into sys_menu values('2', '系统监控', '0', '2', '#',                '',          'M', '0', '1', '', 'fa fa-video-camera',   'admin', sysdate(), '', null, '系统监控目录');
insert into sys_menu values('3', '系统工具', '0', '3', '#',                '',          'M', '0', '1', '', 'fa fa-bars',           'admin', sysdate(), '', null, '系统工具目录');
insert into sys_menu values('4', '若依官网', '0', '4', 'http://ruoyi.vip', 'menuBlank', 'C', '0', '1', '', 'fa fa-location-arrow', 'admin', sysdate(), '', null, '若依官网地址');
-- 二级菜单
insert into sys_menu values('100',  '用户管理', '1', '1', '/system/user',          '', 'C', '0', '1', 'system:user:view',         'fa fa-user-o',          'admin', sysdate(), '', null, '用户管理菜单');
insert into sys_menu values('101',  '角色管理', '1', '2', '/system/role',          '', 'C', '0', '1', 'system:role:view',         'fa fa-user-secret',     'admin', sysdate(), '', null, '角色管理菜单');
insert into sys_menu values('102',  '菜单管理', '1', '3', '/system/menu',          '', 'C', '0', '1', 'system:menu:view',         'fa fa-th-list',         'admin', sysdate(), '', null, '菜单管理菜单');
insert into sys_menu values('103',  '部门管理', '1', '4', '/system/dept',          '', 'C', '0', '1', 'system:dept:view',         'fa fa-outdent',         'admin', sysdate(), '', null, '部门管理菜单');
insert into sys_menu values('104',  '岗位管理', '1', '5', '/system/post',          '', 'C', '0', '1', 'system:post:view',         'fa fa-address-card-o',  'admin', sysdate(), '', null, '岗位管理菜单');
insert into sys_menu values('105',  '字典管理', '1', '6', '/system/dict',          '', 'C', '0', '1', 'system:dict:view',         'fa fa-bookmark-o',      'admin', sysdate(), '', null, '字典管理菜单');
insert into sys_menu values('106',  '参数设置', '1', '7', '/system/config',        '', 'C', '0', '1', 'system:config:view',       'fa fa-sun-o',           'admin', sysdate(), '', null, '参数设置菜单');
insert into sys_menu values('107',  '通知公告', '1', '8', '/system/notice',        '', 'C', '0', '1', 'system:notice:view',       'fa fa-bullhorn',        'admin', sysdate(), '', null, '通知公告菜单');
insert into sys_menu values('108',  '日志管理', '1', '9', '#',                     '', 'M', '0', '1', '',                         'fa fa-pencil-square-o', 'admin', sysdate(), '', null, '日志管理菜单');
insert into sys_menu values('109',  '在线用户', '2', '1', '/monitor/online',       '', 'C', '0', '1', 'monitor:online:view',      'fa fa-user-circle',     'admin', sysdate(), '', null, '在线用户菜单');
insert into sys_menu values('110',  '定时任务', '2', '2', '/monitor/job',          '', 'C', '0', '1', 'monitor:job:view',         'fa fa-tasks',           'admin', sysdate(), '', null, '定时任务菜单');
insert into sys_menu values('111',  '数据监控', '2', '3', '/monitor/data',         '', 'C', '0', '1', 'monitor:data:view',        'fa fa-bug',             'admin', sysdate(), '', null, '数据监控菜单');
insert into sys_menu values('112',  '服务监控', '2', '4', '/monitor/server',       '', 'C', '0', '1', 'monitor:server:view',      'fa fa-server',          'admin', sysdate(), '', null, '服务监控菜单');
insert into sys_menu values('113',  '缓存监控', '2', '5', '/monitor/cache',        '', 'C', '0', '1', 'monitor:cache:view',       'fa fa-cube',            'admin', sysdate(), '', null, '缓存监控菜单');
insert into sys_menu values('114',  '表单构建', '3', '1', '/tool/build',           '', 'C', '0', '1', 'tool:build:view',          'fa fa-wpforms',         'admin', sysdate(), '', null, '表单构建菜单');
insert into sys_menu values('115',  '代码生成', '3', '2', '/tool/gen',             '', 'C', '0', '1', 'tool:gen:view',            'fa fa-code',            'admin', sysdate(), '', null, '代码生成菜单');
insert into sys_menu values('116',  '系统接口', '3', '3', '/tool/swagger',         '', 'C', '0', '1', 'tool:swagger:view',        'fa fa-gg',              'admin', sysdate(), '', null, '系统接口菜单');
-- 三级菜单
insert into sys_menu values('500',  '操作日志', '108', '1', '/monitor/operlog',    '', 'C', '0', '1', 'monitor:operlog:view',     'fa fa-address-book',    'admin', sysdate(), '', null, '操作日志菜单');
insert into sys_menu values('501',  '登录日志', '108', '2', '/monitor/logininfor', '', 'C', '0', '1', 'monitor:logininfor:view',  'fa fa-file-image-o',    'admin', sysdate(), '', null, '登录日志菜单');
-- 用户管理按钮
insert into sys_menu values('1000', '用户查询', '100', '1',  '#', '',  'F', '0', '1', 'system:user:list',        '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1001', '用户新增', '100', '2',  '#', '',  'F', '0', '1', 'system:user:add',         '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1002', '用户修改', '100', '3',  '#', '',  'F', '0', '1', 'system:user:edit',        '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1003', '用户删除', '100', '4',  '#', '',  'F', '0', '1', 'system:user:remove',      '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1004', '用户导出', '100', '5',  '#', '',  'F', '0', '1', 'system:user:export',      '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1005', '用户导入', '100', '6',  '#', '',  'F', '0', '1', 'system:user:import',      '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1006', '重置密码', '100', '7',  '#', '',  'F', '0', '1', 'system:user:resetPwd',    '#', 'admin', sysdate(), '', null, '');
-- 角色管理按钮
insert into sys_menu values('1007', '角色查询', '101', '1',  '#', '',  'F', '0', '1', 'system:role:list',        '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1008', '角色新增', '101', '2',  '#', '',  'F', '0', '1', 'system:role:add',         '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1009', '角色修改', '101', '3',  '#', '',  'F', '0', '1', 'system:role:edit',        '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1010', '角色删除', '101', '4',  '#', '',  'F', '0', '1', 'system:role:remove',      '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1011', '角色导出', '101', '5',  '#', '',  'F', '0', '1', 'system:role:export',      '#', 'admin', sysdate(), '', null, '');
-- 菜单管理按钮
insert into sys_menu values('1012', '菜单查询', '102', '1',  '#', '',  'F', '0', '1', 'system:menu:list',        '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1013', '菜单新增', '102', '2',  '#', '',  'F', '0', '1', 'system:menu:add',         '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1014', '菜单修改', '102', '3',  '#', '',  'F', '0', '1', 'system:menu:edit',        '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1015', '菜单删除', '102', '4',  '#', '',  'F', '0', '1', 'system:menu:remove',      '#', 'admin', sysdate(), '', null, '');
-- 部门管理按钮
insert into sys_menu values('1016', '部门查询', '103', '1',  '#', '',  'F', '0', '1', 'system:dept:list',        '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1017', '部门新增', '103', '2',  '#', '',  'F', '0', '1', 'system:dept:add',         '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1018', '部门修改', '103', '3',  '#', '',  'F', '0', '1', 'system:dept:edit',        '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1019', '部门删除', '103', '4',  '#', '',  'F', '0', '1', 'system:dept:remove',      '#', 'admin', sysdate(), '', null, '');
-- 岗位管理按钮
insert into sys_menu values('1020', '岗位查询', '104', '1',  '#', '',  'F', '0', '1', 'system:post:list',        '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1021', '岗位新增', '104', '2',  '#', '',  'F', '0', '1', 'system:post:add',         '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1022', '岗位修改', '104', '3',  '#', '',  'F', '0', '1', 'system:post:edit',        '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1023', '岗位删除', '104', '4',  '#', '',  'F', '0', '1', 'system:post:remove',      '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1024', '岗位导出', '104', '5',  '#', '',  'F', '0', '1', 'system:post:export',      '#', 'admin', sysdate(), '', null, '');
-- 字典管理按钮
insert into sys_menu values('1025', '字典查询', '105', '1',  '#', '',  'F', '0', '1', 'system:dict:list',        '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1026', '字典新增', '105', '2',  '#', '',  'F', '0', '1', 'system:dict:add',         '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1027', '字典修改', '105', '3',  '#', '',  'F', '0', '1', 'system:dict:edit',        '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1028', '字典删除', '105', '4',  '#', '',  'F', '0', '1', 'system:dict:remove',      '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1029', '字典导出', '105', '5',  '#', '',  'F', '0', '1', 'system:dict:export',      '#', 'admin', sysdate(), '', null, '');
-- 参数设置按钮
insert into sys_menu values('1030', '参数查询', '106', '1',  '#', '',  'F', '0', '1', 'system:config:list',      '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1031', '参数新增', '106', '2',  '#', '',  'F', '0', '1', 'system:config:add',       '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1032', '参数修改', '106', '3',  '#', '',  'F', '0', '1', 'system:config:edit',      '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1033', '参数删除', '106', '4',  '#', '',  'F', '0', '1', 'system:config:remove',    '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1034', '参数导出', '106', '5',  '#', '',  'F', '0', '1', 'system:config:export',    '#', 'admin', sysdate(), '', null, '');
-- 通知公告按钮
insert into sys_menu values('1035', '公告查询', '107', '1',  '#', '',  'F', '0', '1', 'system:notice:list',      '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1036', '公告新增', '107', '2',  '#', '',  'F', '0', '1', 'system:notice:add',       '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1037', '公告修改', '107', '3',  '#', '',  'F', '0', '1', 'system:notice:edit',      '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1038', '公告删除', '107', '4',  '#', '',  'F', '0', '1', 'system:notice:remove',    '#', 'admin', sysdate(), '', null, '');
-- 操作日志按钮
insert into sys_menu values('1039', '操作查询', '500', '1',  '#', '',  'F', '0', '1', 'monitor:operlog:list',    '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1040', '操作删除', '500', '2',  '#', '',  'F', '0', '1', 'monitor:operlog:remove',  '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1041', '详细信息', '500', '3',  '#', '',  'F', '0', '1', 'monitor:operlog:detail',  '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1042', '日志导出', '500', '4',  '#', '',  'F', '0', '1', 'monitor:operlog:export',  '#', 'admin', sysdate(), '', null, '');
-- 登录日志按钮
insert into sys_menu values('1043', '登录查询', '501', '1',  '#', '',  'F', '0', '1', 'monitor:logininfor:list',         '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1044', '登录删除', '501', '2',  '#', '',  'F', '0', '1', 'monitor:logininfor:remove',       '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1045', '日志导出', '501', '3',  '#', '',  'F', '0', '1', 'monitor:logininfor:export',       '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1046', '账户解锁', '501', '4',  '#', '',  'F', '0', '1', 'monitor:logininfor:unlock',       '#', 'admin', sysdate(), '', null, '');
-- 在线用户按钮
insert into sys_menu values('1047', '在线查询', '109', '1',  '#', '',  'F', '0', '1', 'monitor:online:list',             '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1048', '批量强退', '109', '2',  '#', '',  'F', '0', '1', 'monitor:online:batchForceLogout', '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1049', '单条强退', '109', '3',  '#', '',  'F', '0', '1', 'monitor:online:forceLogout',      '#', 'admin', sysdate(), '', null, '');
-- 定时任务按钮
insert into sys_menu values('1050', '任务查询', '110', '1',  '#', '',  'F', '0', '1', 'monitor:job:list',                '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1051', '任务新增', '110', '2',  '#', '',  'F', '0', '1', 'monitor:job:add',                 '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1052', '任务修改', '110', '3',  '#', '',  'F', '0', '1', 'monitor:job:edit',                '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1053', '任务删除', '110', '4',  '#', '',  'F', '0', '1', 'monitor:job:remove',              '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1054', '状态修改', '110', '5',  '#', '',  'F', '0', '1', 'monitor:job:changeStatus',        '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1055', '任务详细', '110', '6',  '#', '',  'F', '0', '1', 'monitor:job:detail',              '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1056', '任务导出', '110', '7',  '#', '',  'F', '0', '1', 'monitor:job:export',              '#', 'admin', sysdate(), '', null, '');
-- 代码生成按钮
insert into sys_menu values('1057', '生成查询', '115', '1',  '#', '',  'F', '0', '1', 'tool:gen:list',     '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1058', '生成修改', '115', '2',  '#', '',  'F', '0', '1', 'tool:gen:edit',     '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1059', '生成删除', '115', '3',  '#', '',  'F', '0', '1', 'tool:gen:remove',   '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1060', '预览代码', '115', '4',  '#', '',  'F', '0', '1', 'tool:gen:preview',  '#', 'admin', sysdate(), '', null, '');
insert into sys_menu values('1061', '生成代码', '115', '5',  '#', '',  'F', '0', '1', 'tool:gen:code',     '#', 'admin', sysdate(), '', null, '');


-- ----------------------------
-- 6、用户和角色关联表  用户N-1角色
-- ----------------------------
drop table if exists sys_user_role;
create table sys_user_role (
  user_id   bigint(20) not null comment '用户ID',
  role_id   bigint(20) not null comment '角色ID',
  primary key(user_id, role_id)
) engine=innodb comment = '用户和角色关联表';

-- ----------------------------
-- 初始化-用户和角色关联表数据
-- ----------------------------
insert into sys_user_role values ('1', '1');
insert into sys_user_role values ('2', '2');


-- ----------------------------
-- 7、角色和菜单关联表  角色1-N菜单
-- ----------------------------
drop table if exists sys_role_menu;
create table sys_role_menu (
  role_id   bigint(20) not null comment '角色ID',
  menu_id   bigint(20) not null comment '菜单ID',
  primary key(role_id, menu_id)
) engine=innodb comment = '角色和菜单关联表';

-- ----------------------------
-- 初始化-角色和菜单关联表数据
-- ----------------------------
insert into sys_role_menu values ('2', '1');
insert into sys_role_menu values ('2', '2');
insert into sys_role_menu values ('2', '3');
insert into sys_role_menu values ('2', '4');
insert into sys_role_menu values ('2', '100');
insert into sys_role_menu values ('2', '101');
insert into sys_role_menu values ('2', '102');
insert into sys_role_menu values ('2', '103');
insert into sys_role_menu values ('2', '104');
insert into sys_role_menu values ('2', '105');
insert into sys_role_menu values ('2', '106');
insert into sys_role_menu values ('2', '107');
insert into sys_role_menu values ('2', '108');
insert into sys_role_menu values ('2', '109');
insert into sys_role_menu values ('2', '110');
insert into sys_role_menu values ('2', '111');
insert into sys_role_menu values ('2', '112');
insert into sys_role_menu values ('2', '113');
insert into sys_role_menu values ('2', '114');
insert into sys_role_menu values ('2', '115');
insert into sys_role_menu values ('2', '116');
insert into sys_role_menu values ('2', '500');
insert into sys_role_menu values ('2', '501');
insert into sys_role_menu values ('2', '1000');
insert into sys_role_menu values ('2', '1001');
insert into sys_role_menu values ('2', '1002');
insert into sys_role_menu values ('2', '1003');
insert into sys_role_menu values ('2', '1004');
insert into sys_role_menu values ('2', '1005');
insert into sys_role_menu values ('2', '1006');
insert into sys_role_menu values ('2', '1007');
insert into sys_role_menu values ('2', '1008');
insert into sys_role_menu values ('2', '1009');
insert into sys_role_menu values ('2', '1010');
insert into sys_role_menu values ('2', '1011');
insert into sys_role_menu values ('2', '1012');
insert into sys_role_menu values ('2', '1013');
insert into sys_role_menu values ('2', '1014');
insert into sys_role_menu values ('2', '1015');
insert into sys_role_menu values ('2', '1016');
insert into sys_role_menu values ('2', '1017');
insert into sys_role_menu values ('2', '1018');
insert into sys_role_menu values ('2', '1019');
insert into sys_role_menu values ('2', '1020');
insert into sys_role_menu values ('2', '1021');
insert into sys_role_menu values ('2', '1022');
insert into sys_role_menu values ('2', '1023');
insert into sys_role_menu values ('2', '1024');
insert into sys_role_menu values ('2', '1025');
insert into sys_role_menu values ('2', '1026');
insert into sys_role_menu values ('2', '1027');
insert into sys_role_menu values ('2', '1028');
insert into sys_role_menu values ('2', '1029');
insert into sys_role_menu values ('2', '1030');
insert into sys_role_menu values ('2', '1031');
insert into sys_role_menu values ('2', '1032');
insert into sys_role_menu values ('2', '1033');
insert into sys_role_menu values ('2', '1034');
insert into sys_role_menu values ('2', '1035');
insert into sys_role_menu values ('2', '1036');
insert into sys_role_menu values ('2', '1037');
insert into sys_role_menu values ('2', '1038');
insert into sys_role_menu values ('2', '1039');
insert into sys_role_menu values ('2', '1040');
insert into sys_role_menu values ('2', '1041');
insert into sys_role_menu values ('2', '1042');
insert into sys_role_menu values ('2', '1043');
insert into sys_role_menu values ('2', '1044');
insert into sys_role_menu values ('2', '1045');
insert into sys_role_menu values ('2', '1046');
insert into sys_role_menu values ('2', '1047');
insert into sys_role_menu values ('2', '1048');
insert into sys_role_menu values ('2', '1049');
insert into sys_role_menu values ('2', '1050');
insert into sys_role_menu values ('2', '1051');
insert into sys_role_menu values ('2', '1052');
insert into sys_role_menu values ('2', '1053');
insert into sys_role_menu values ('2', '1054');
insert into sys_role_menu values ('2', '1055');
insert into sys_role_menu values ('2', '1056');
insert into sys_role_menu values ('2', '1057');
insert into sys_role_menu values ('2', '1058');
insert into sys_role_menu values ('2', '1059');
insert into sys_role_menu values ('2', '1060');
insert into sys_role_menu values ('2', '1061');

-- ----------------------------
-- 8、角色和部门关联表  角色1-N部门
-- ----------------------------
drop table if exists sys_role_dept;
create table sys_role_dept (
  role_id   bigint(20) not null comment '角色ID',
  dept_id   bigint(20) not null comment '部门ID',
  primary key(role_id, dept_id)
) engine=innodb comment = '角色和部门关联表';

-- ----------------------------
-- 初始化-角色和部门关联表数据
-- ----------------------------
insert into sys_role_dept values ('2', '100');
insert into sys_role_dept values ('2', '101');
insert into sys_role_dept values ('2', '105');

-- ----------------------------
-- 9、用户与岗位关联表  用户1-N岗位
-- ----------------------------
drop table if exists sys_user_post;
create table sys_user_post
(
  user_id   bigint(20) not null comment '用户ID',
  post_id   bigint(20) not null comment '岗位ID',
  primary key (user_id, post_id)
) engine=innodb comment = '用户与岗位关联表';

-- ----------------------------
-- 初始化-用户与岗位关联表数据
-- ----------------------------
insert into sys_user_post values ('1', '1');
insert into sys_user_post values ('2', '2');


-- ----------------------------
-- 10、操作日志记录
-- ----------------------------
drop table if exists sys_oper_log;
create table sys_oper_log (
  oper_id           bigint(20)      not null auto_increment    comment '日志主键',
  title             varchar(50)     default ''                 comment '模块标题',
  business_type     int(2)          default 0                  comment '业务类型（0其它 1新增 2修改 3删除）',
  method            varchar(200)    default ''                 comment '方法名称',
  request_method    varchar(10)     default ''                 comment '请求方式',
  operator_type     int(1)          default 0                  comment '操作类别（0其它 1后台用户 2手机端用户）',
  oper_name         varchar(50)     default ''                 comment '操作人员',
  dept_name         varchar(50)     default ''                 comment '部门名称',
  oper_url          varchar(255)    default ''                 comment '请求URL',
  oper_ip           varchar(128)    default ''                 comment '主机地址',
  oper_location     varchar(255)    default ''                 comment '操作地点',
  oper_param        varchar(2000)   default ''                 comment '请求参数',
  json_result       varchar(2000)   default ''                 comment '返回参数',
  status            int(1)          default 0                  comment '操作状态（0正常 1异常）',
  error_msg         varchar(2000)   default ''                 comment '错误消息',
  oper_time         datetime                                   comment '操作时间',
  cost_time         bigint(20)      default 0                  comment '消耗时间',
  primary key (oper_id),
  key idx_sys_oper_log_bt (business_type),
  key idx_sys_oper_log_s  (status),
  key idx_sys_oper_log_ot (oper_time)
) engine=innodb auto_increment=100 comment = '操作日志记录';


-- ----------------------------
-- 11、字典类型表
-- ----------------------------
drop table if exists sys_dict_type;
create table sys_dict_type
(
  dict_id          bigint(20)      not null auto_increment    comment '字典主键',
  dict_name        varchar(100)    default ''                 comment '字典名称',
  dict_type        varchar(100)    default ''                 comment '字典类型',
  status           char(1)         default '0'                comment '状态（0正常 1停用）',
  create_by        varchar(64)     default ''                 comment '创建者',
  create_time      datetime                                   comment '创建时间',
  update_by        varchar(64)     default ''                 comment '更新者',
  update_time      datetime                                   comment '更新时间',
  remark           varchar(500)    default null               comment '备注',
  primary key (dict_id),
  unique (dict_type)
) engine=innodb auto_increment=100 comment = '字典类型表';

insert into sys_dict_type values(1,  '用户性别', 'sys_user_sex',        '0', 'admin', sysdate(), '', null, '用户性别列表');
insert into sys_dict_type values(2,  '菜单状态', 'sys_show_hide',       '0', 'admin', sysdate(), '', null, '菜单状态列表');
insert into sys_dict_type values(3,  '系统开关', 'sys_normal_disable',  '0', 'admin', sysdate(), '', null, '系统开关列表');
insert into sys_dict_type values(4,  '任务状态', 'sys_job_status',      '0', 'admin', sysdate(), '', null, '任务状态列表');
insert into sys_dict_type values(5,  '任务分组', 'sys_job_group',       '0', 'admin', sysdate(), '', null, '任务分组列表');
insert into sys_dict_type values(6,  '系统是否', 'sys_yes_no',          '0', 'admin', sysdate(), '', null, '系统是否列表');
insert into sys_dict_type values(7,  '通知类型', 'sys_notice_type',     '0', 'admin', sysdate(), '', null, '通知类型列表');
insert into sys_dict_type values(8,  '通知状态', 'sys_notice_status',   '0', 'admin', sysdate(), '', null, '通知状态列表');
insert into sys_dict_type values(9,  '操作类型', 'sys_oper_type',       '0', 'admin', sysdate(), '', null, '操作类型列表');
insert into sys_dict_type values(10, '系统状态', 'sys_common_status',   '0', 'admin', sysdate(), '', null, '登录状态列表');


-- ----------------------------
-- 12、字典数据表
-- ----------------------------
drop table if exists sys_dict_data;
create table sys_dict_data
(
  dict_code        bigint(20)      not null auto_increment    comment '字典编码',
  dict_sort        int(4)          default 0                  comment '字典排序',
  dict_label       varchar(100)    default ''                 comment '字典标签',
  dict_value       varchar(100)    default ''                 comment '字典键值',
  dict_type        varchar(100)    default ''                 comment '字典类型',
  css_class        varchar(100)    default null               comment '样式属性（其他样式扩展）',
  list_class       varchar(100)    default null               comment '表格回显样式',
  is_default       char(1)         default 'N'                comment '是否默认（Y是 N否）',
  status           char(1)         default '0'                comment '状态（0正常 1停用）',
  create_by        varchar(64)     default ''                 comment '创建者',
  create_time      datetime                                   comment '创建时间',
  update_by        varchar(64)     default ''                 comment '更新者',
  update_time      datetime                                   comment '更新时间',
  remark           varchar(500)    default null               comment '备注',
  primary key (dict_code)
) engine=innodb auto_increment=100 comment = '字典数据表';

insert into sys_dict_data values(1,  1,  '男',       '0',       'sys_user_sex',        '',   '',        'Y', '0', 'admin', sysdate(), '', null, '性别男');
insert into sys_dict_data values(2,  2,  '女',       '1',       'sys_user_sex',        '',   '',        'N', '0', 'admin', sysdate(), '', null, '性别女');
insert into sys_dict_data values(3,  3,  '未知',     '2',       'sys_user_sex',        '',   '',        'N', '0', 'admin', sysdate(), '', null, '性别未知');
insert into sys_dict_data values(4,  1,  '显示',     '0',       'sys_show_hide',       '',   'primary', 'Y', '0', 'admin', sysdate(), '', null, '显示菜单');
insert into sys_dict_data values(5,  2,  '隐藏',     '1',       'sys_show_hide',       '',   'danger',  'N', '0', 'admin', sysdate(), '', null, '隐藏菜单');
insert into sys_dict_data values(6,  1,  '正常',     '0',       'sys_normal_disable',  '',   'primary', 'Y', '0', 'admin', sysdate(), '', null, '正常状态');
insert into sys_dict_data values(7,  2,  '停用',     '1',       'sys_normal_disable',  '',   'danger',  'N', '0', 'admin', sysdate(), '', null, '停用状态');
insert into sys_dict_data values(8,  1,  '正常',     '0',       'sys_job_status',      '',   'primary', 'Y', '0', 'admin', sysdate(), '', null, '正常状态');
insert into sys_dict_data values(9,  2,  '暂停',     '1',       'sys_job_status',      '',   'danger',  'N', '0', 'admin', sysdate(), '', null, '停用状态');
insert into sys_dict_data values(10, 1,  '默认',     'DEFAULT', 'sys_job_group',       '',   '',        'Y', '0', 'admin', sysdate(), '', null, '默认分组');
insert into sys_dict_data values(11, 2,  '系统',     'SYSTEM',  'sys_job_group',       '',   '',        'N', '0', 'admin', sysdate(), '', null, '系统分组');
insert into sys_dict_data values(12, 1,  '是',       'Y',       'sys_yes_no',          '',   'primary', 'Y', '0', 'admin', sysdate(), '', null, '系统默认是');
insert into sys_dict_data values(13, 2,  '否',       'N',       'sys_yes_no',          '',   'danger',  'N', '0', 'admin', sysdate(), '', null, '系统默认否');
insert into sys_dict_data values(14, 1,  '通知',     '1',       'sys_notice_type',     '',   'warning', 'Y', '0', 'admin', sysdate(), '', null, '通知');
insert into sys_dict_data values(15, 2,  '公告',     '2',       'sys_notice_type',     '',   'success', 'N', '0', 'admin', sysdate(), '', null, '公告');
insert into sys_dict_data values(16, 1,  '正常',     '0',       'sys_notice_status',   '',   'primary', 'Y', '0', 'admin', sysdate(), '', null, '正常状态');
insert into sys_dict_data values(17, 2,  '关闭',     '1',       'sys_notice_status',   '',   'danger',  'N', '0', 'admin', sysdate(), '', null, '关闭状态');
insert into sys_dict_data values(18, 99, '其他',     '0',       'sys_oper_type',       '',   'info',    'N', '0', 'admin', sysdate(), '', null, '其他操作');
insert into sys_dict_data values(19, 1,  '新增',     '1',       'sys_oper_type',       '',   'info',    'N', '0', 'admin', sysdate(), '', null, '新增操作');
insert into sys_dict_data values(20, 2,  '修改',     '2',       'sys_oper_type',       '',   'info',    'N', '0', 'admin', sysdate(), '', null, '修改操作');
insert into sys_dict_data values(21, 3,  '删除',     '3',       'sys_oper_type',       '',   'danger',  'N', '0', 'admin', sysdate(), '', null, '删除操作');
insert into sys_dict_data values(22, 4,  '授权',     '4',       'sys_oper_type',       '',   'primary', 'N', '0', 'admin', sysdate(), '', null, '授权操作');
insert into sys_dict_data values(23, 5,  '导出',     '5',       'sys_oper_type',       '',   'warning', 'N', '0', 'admin', sysdate(), '', null, '导出操作');
insert into sys_dict_data values(24, 6,  '导入',     '6',       'sys_oper_type',       '',   'warning', 'N', '0', 'admin', sysdate(), '', null, '导入操作');
insert into sys_dict_data values(25, 7,  '强退',     '7',       'sys_oper_type',       '',   'danger',  'N', '0', 'admin', sysdate(), '', null, '强退操作');
insert into sys_dict_data values(26, 8,  '生成代码', '8',       'sys_oper_type',       '',   'warning', 'N', '0', 'admin', sysdate(), '', null, '生成操作');
insert into sys_dict_data values(27, 9,  '清空数据', '9',       'sys_oper_type',       '',   'danger',  'N', '0', 'admin', sysdate(), '', null, '清空操作');
insert into sys_dict_data values(28, 1,  '成功',     '0',       'sys_common_status',   '',   'primary', 'N', '0', 'admin', sysdate(), '', null, '正常状态');
insert into sys_dict_data values(29, 2,  '失败',     '1',       'sys_common_status',   '',   'danger',  'N', '0', 'admin', sysdate(), '', null, '停用状态');


-- ----------------------------
-- 13、参数配置表
-- ----------------------------
drop table if exists sys_config;
create table sys_config (
  config_id         int(5)          not null auto_increment    comment '参数主键',
  config_name       varchar(100)    default ''                 comment '参数名称',
  config_key        varchar(100)    default ''                 comment '参数键名',
  config_value      varchar(500)    default ''                 comment '参数键值',
  config_type       char(1)         default 'N'                comment '系统内置（Y是 N否）',
  create_by         varchar(64)     default ''                 comment '创建者',
  create_time       datetime                                   comment '创建时间',
  update_by         varchar(64)     default ''                 comment '更新者',
  update_time       datetime                                   comment '更新时间',
  remark            varchar(500)    default null               comment '备注',
  primary key (config_id)
) engine=innodb auto_increment=100 comment = '参数配置表';

insert into sys_config values(1,  '主框架页-默认皮肤样式名称',     'sys.index.skinName',               'skin-blue',     'Y', 'admin', sysdate(), '', null, '蓝色 skin-blue、绿色 skin-green、紫色 skin-purple、红色 skin-red、黄色 skin-yellow');
insert into sys_config values(2,  '用户管理-账号初始密码',         'sys.user.initPassword',            '123456',        'Y', 'admin', sysdate(), '', null, '初始化密码 123456');
insert into sys_config values(3,  '主框架页-侧边栏主题',           'sys.index.sideTheme',              'theme-dark',    'Y', 'admin', sysdate(), '', null, '深黑主题theme-dark，浅色主题theme-light，深蓝主题theme-blue');
insert into sys_config values(4,  '账号自助-是否开启用户注册功能', 'sys.account.registerUser',         'false',         'Y', 'admin', sysdate(), '', null, '是否开启注册用户功能（true开启，false关闭）');
insert into sys_config values(5,  '用户管理-密码字符范围',         'sys.account.chrtype',              '0',             'Y', 'admin', sysdate(), '', null, '默认任意字符范围，0任意（密码可以输入任意字符），1数字（密码只能为0-9数字），2英文字母（密码只能为a-z和A-Z字母），3字母和数字（密码必须包含字母，数字）,4字母数字和特殊字符（目前支持的特殊字符包括：~!@#$%^&*()-=_+）');
insert into sys_config values(6,  '用户管理-初始密码修改策略',     'sys.account.initPasswordModify',   '1',             'Y', 'admin', sysdate(), '', null, '0：初始密码修改策略关闭，没有任何提示，1：提醒用户，如果未修改初始密码，则在登录时就会提醒修改密码对话框');
insert into sys_config values(7,  '用户管理-账号密码更新周期',     'sys.account.passwordValidateDays', '0',             'Y', 'admin', sysdate(), '', null, '密码更新周期（填写数字，数据初始化值为0不限制，若修改必须为大于0小于365的正整数），如果超过这个周期登录系统时，则在登录时就会提醒修改密码对话框');
insert into sys_config values(8,  '主框架页-菜单导航显示风格',     'sys.index.menuStyle',              'default',       'Y', 'admin', sysdate(), '', null, '菜单导航显示风格（default为左侧导航菜单，topnav为顶部导航菜单）');
insert into sys_config values(9,  '主框架页-是否开启页脚',         'sys.index.footer',                 'true',          'Y', 'admin', sysdate(), '', null, '是否开启底部页脚显示（true显示，false隐藏）');
insert into sys_config values(10, '主框架页-是否开启页签',         'sys.index.tagsView',               'true',          'Y', 'admin', sysdate(), '', null, '是否开启菜单多页签显示（true显示，false隐藏）');
insert into sys_config values(11, '用户登录-黑名单列表',           'sys.login.blackIPList',            '',              'Y', 'admin', sysdate(), '', null, '设置登录IP黑名单限制，多个匹配项以;分隔，支持匹配（*通配、网段）');


-- ----------------------------
-- 14、系统访问记录
-- ----------------------------
drop table if exists sys_logininfor;
create table sys_logininfor (
  info_id        bigint(20)     not null auto_increment   comment '访问ID',
  login_name     varchar(50)    default ''                comment '登录账号',
  ipaddr         varchar(128)   default ''                comment '登录IP地址',
  login_location varchar(255)   default ''                comment '登录地点',
  browser        varchar(50)    default ''                comment '浏览器类型',
  os             varchar(50)    default ''                comment '操作系统',
  status         char(1)        default '0'               comment '登录状态（0成功 1失败）',
  msg            varchar(255)   default ''                comment '提示消息',
  login_time     datetime                                 comment '访问时间',
  primary key (info_id),
  key idx_sys_logininfor_s  (status),
  key idx_sys_logininfor_lt (login_time)
) engine=innodb auto_increment=100 comment = '系统访问记录';


-- ----------------------------
-- 15、在线用户记录
-- ----------------------------
drop table if exists sys_user_online;
create table sys_user_online (
  sessionId         varchar(50)   default ''                comment '用户会话id',
  login_name        varchar(50)   default ''                comment '登录账号',
  dept_name         varchar(50)   default ''                comment '部门名称',
  ipaddr            varchar(128)  default ''                comment '登录IP地址',
  login_location    varchar(255)  default ''                comment '登录地点',
  browser           varchar(50)   default ''                comment '浏览器类型',
  os                varchar(50)   default ''                comment '操作系统',
  status            varchar(10)   default ''                comment '在线状态on_line在线off_line离线',
  start_timestamp   datetime                                comment 'session创建时间',
  last_access_time  datetime                                comment 'session最后访问时间',
  expire_time       int(5)        default 0                 comment '超时时间，单位为分钟',
  primary key (sessionId)
) engine=innodb comment = '在线用户记录';


-- ----------------------------
-- 16、定时任务调度表
-- ----------------------------
drop table if exists sys_job;
create table sys_job (
  job_id              bigint(20)    not null auto_increment    comment '任务ID',
  job_name            varchar(64)   default ''                 comment '任务名称',
  job_group           varchar(64)   default 'DEFAULT'          comment '任务组名',
  invoke_target       varchar(500)  not null                   comment '调用目标字符串',
  cron_expression     varchar(255)  default ''                 comment 'cron执行表达式',
  misfire_policy      varchar(20)   default '3'                comment '计划执行错误策略（1立即执行 2执行一次 3放弃执行）',
  concurrent          char(1)       default '1'                comment '是否并发执行（0允许 1禁止）',
  status              char(1)       default '0'                comment '状态（0正常 1暂停）',
  create_by           varchar(64)   default ''                 comment '创建者',
  create_time         datetime                                 comment '创建时间',
  update_by           varchar(64)   default ''                 comment '更新者',
  update_time         datetime                                 comment '更新时间',
  remark              varchar(500)  default ''                 comment '备注信息',
  primary key (job_id, job_name, job_group)
) engine=innodb auto_increment=100 comment = '定时任务调度表';

insert into sys_job values(1, '系统默认（无参）', 'DEFAULT', 'ryTask.ryNoParams',        '0/10 * * * * ?', '3', '1', '1', 'admin', sysdate(), '', null, '');
insert into sys_job values(2, '系统默认（有参）', 'DEFAULT', 'ryTask.ryParams(\'ry\')',  '0/15 * * * * ?', '3', '1', '1', 'admin', sysdate(), '', null, '');
insert into sys_job values(3, '系统默认（多参）', 'DEFAULT', 'ryTask.ryMultipleParams(\'ry\', true, 2000L, 316.50D, 100)',  '0/20 * * * * ?', '3', '1', '1', 'admin', sysdate(), '', null, '');


-- ----------------------------
-- 17、定时任务调度日志表
-- ----------------------------
drop table if exists sys_job_log;
create table sys_job_log (
  job_log_id          bigint(20)     not null auto_increment    comment '任务日志ID',
  job_name            varchar(64)    not null                   comment '任务名称',
  job_group           varchar(64)    not null                   comment '任务组名',
  invoke_target       varchar(500)   not null                   comment '调用目标字符串',
  job_message         varchar(500)                              comment '日志信息',
  status              char(1)        default '0'                comment '执行状态（0正常 1失败）',
  exception_info      varchar(2000)  default ''                 comment '异常信息',
  create_time         datetime                                  comment '创建时间',
  primary key (job_log_id)
) engine=innodb comment = '定时任务调度日志表';


-- ----------------------------
-- 18、通知公告表
-- ----------------------------
drop table if exists sys_notice;
create table sys_notice (
  notice_id         int(4)          not null auto_increment    comment '公告ID',
  notice_title      varchar(50)     not null                   comment '公告标题',
  notice_type       char(1)         not null                   comment '公告类型（1通知 2公告）',
  notice_content    longblob        default null               comment '公告内容',
  status            char(1)         default '0'                comment '公告状态（0正常 1关闭）',
  create_by         varchar(64)     default ''                 comment '创建者',
  create_time       datetime                                   comment '创建时间',
  update_by         varchar(64)     default ''                 comment '更新者',
  update_time       datetime                                   comment '更新时间',
  remark            varchar(255)    default null               comment '备注',
  primary key (notice_id)
) engine=innodb auto_increment=10 comment = '通知公告表';

-- ----------------------------
-- 初始化-公告信息表数据
-- ----------------------------
insert into sys_notice values('1', '温馨提醒：2018-07-01 若依新版本发布啦', '2', '新版本内容', '0', 'admin', sysdate(), '', null, '管理员');
insert into sys_notice values('2', '维护通知：2018-07-01 若依系统凌晨维护', '1', '维护内容',   '0', 'admin', sysdate(), '', null, '管理员');
insert into sys_notice values('3', '若依开源框架介绍', '1', '<p><span style=\"color: rgb(230, 0, 0);\">项目介绍</span></p><p><font color=\"#333333\">RuoYi开源项目是为企业用户定制的后台脚手架框架，为企业打造的一站式解决方案，降低企业开发成本，提升开发效率。主要包括用户管理、角色管理、部门管理、菜单管理、参数管理、字典管理、</font><span style=\"color: rgb(51, 51, 51);\">岗位管理</span><span style=\"color: rgb(51, 51, 51);\">、定时任务</span><span style=\"color: rgb(51, 51, 51);\">、</span><span style=\"color: rgb(51, 51, 51);\">服务监控、登录日志、操作日志、代码生成等功能。其中，还支持多数据源、数据权限、国际化、Redis缓存、Docker部署、滑动验证码、第三方认证登录、分布式事务、</span><font color=\"#333333\">分布式文件存储</font><span style=\"color: rgb(51, 51, 51);\">、分库分表处理等技术特点。</span></p><p><img src=\"https://foruda.gitee.com/images/1705030583977401651/5ed5db6a_1151004.png\" style=\"width: 64px;\"><br></p><p><span style=\"color: rgb(230, 0, 0);\">官网及演示</span></p><p><span style=\"color: rgb(51, 51, 51);\">若依官网地址：&nbsp;</span><a href=\"http://ruoyi.vip\" target=\"_blank\">http://ruoyi.vip</a><a href=\"http://ruoyi.vip\" target=\"_blank\"></a></p><p><span style=\"color: rgb(51, 51, 51);\">若依文档地址：&nbsp;</span><a href=\"http://doc.ruoyi.vip\" target=\"_blank\">http://doc.ruoyi.vip</a><br></p><p><span style=\"color: rgb(51, 51, 51);\">演示地址【不分离版】：&nbsp;</span><a href=\"http://demo.ruoyi.vip\" target=\"_blank\">http://demo.ruoyi.vip</a></p><p><span style=\"color: rgb(51, 51, 51);\">演示地址【分离版本】：&nbsp;</span><a href=\"http://vue.ruoyi.vip\" target=\"_blank\">http://vue.ruoyi.vip</a></p><p><span style=\"color: rgb(51, 51, 51);\">演示地址【微服务版】：&nbsp;</span><a href=\"http://cloud.ruoyi.vip\" target=\"_blank\">http://cloud.ruoyi.vip</a></p><p><span style=\"color: rgb(51, 51, 51);\">演示地址【移动端版】：&nbsp;</span><a href=\"http://h5.ruoyi.vip\" target=\"_blank\">http://h5.ruoyi.vip</a></p><p><br style=\"color: rgb(48, 49, 51); font-family: &quot;Helvetica Neue&quot;, Helvetica, Arial, sans-serif; font-size: 12px;\"></p>', '0', 'admin', sysdate(), '', null, '管理员');


-- ----------------------------
-- 19、代码生成业务表
-- ----------------------------
drop table if exists gen_table;
create table gen_table (
  table_id             bigint(20)      not null auto_increment    comment '编号',
  table_name           varchar(200)    default ''                 comment '表名称',
  table_comment        varchar(500)    default ''                 comment '表描述',
  sub_table_name       varchar(64)     default null               comment '关联子表的表名',
  sub_table_fk_name    varchar(64)     default null               comment '子表关联的外键名',
  class_name           varchar(100)    default ''                 comment '实体类名称',
  tpl_category         varchar(200)    default 'crud'             comment '使用的模板（crud单表操作 tree树表操作 sub主子表操作）',
  package_name         varchar(100)                               comment '生成包路径',
  module_name          varchar(30)                                comment '生成模块名',
  business_name        varchar(30)                                comment '生成业务名',
  function_name        varchar(50)                                comment '生成功能名',
  function_author      varchar(50)                                comment '生成功能作者',
  form_col_num         int(1)          default 1                  comment '表单布局（单列 双列 三列）',
  gen_type             char(1)         default '0'                comment '生成代码方式（0zip压缩包 1自定义路径）',
  gen_path             varchar(200)    default '/'                comment '生成路径（不填默认项目路径）',
  options              varchar(1000)                              comment '其它生成选项',
  create_by            varchar(64)     default ''                 comment '创建者',
  create_time 	       datetime                                   comment '创建时间',
  update_by            varchar(64)     default ''                 comment '更新者',
  update_time          datetime                                   comment '更新时间',
  remark               varchar(500)    default null               comment '备注',
  primary key (table_id)
) engine=innodb auto_increment=1 comment = '代码生成业务表';


-- ----------------------------
-- 20、代码生成业务表字段
-- ----------------------------
drop table if exists gen_table_column;
create table gen_table_column (
  column_id         bigint(20)      not null auto_increment    comment '编号',
  table_id          bigint(20)                                 comment '归属表编号',
  column_name       varchar(200)                               comment '列名称',
  column_comment    varchar(500)                               comment '列描述',
  column_type       varchar(100)                               comment '列类型',
  java_type         varchar(500)                               comment 'JAVA类型',
  java_field        varchar(200)                               comment 'JAVA字段名',
  is_pk             char(1)                                    comment '是否主键（1是）',
  is_increment      char(1)                                    comment '是否自增（1是）',
  is_required       char(1)                                    comment '是否必填（1是）',
  is_insert         char(1)                                    comment '是否为插入字段（1是）',
  is_edit           char(1)                                    comment '是否编辑字段（1是）',
  is_list           char(1)                                    comment '是否列表字段（1是）',
  is_query          char(1)                                    comment '是否查询字段（1是）',
  query_type        varchar(200)    default 'EQ'               comment '查询方式（等于、不等于、大于、小于、范围）',
  html_type         varchar(200)                               comment '显示类型（文本框、文本域、下拉框、复选框、单选框、日期控件）',
  dict_type         varchar(200)    default ''                 comment '字典类型',
  sort              int                                        comment '排序',
  create_by         varchar(64)     default ''                 comment '创建者',
  create_time 	    datetime                                   comment '创建时间',
  update_by         varchar(64)     default ''                 comment '更新者',
  update_time       datetime                                   comment '更新时间',
  primary key (column_id)
) engine=innodb auto_increment=1 comment = '代码生成业务表字段';

-- =========================================
-- 第2部分：quartz.sql
-- =========================================

DROP TABLE IF EXISTS QRTZ_FIRED_TRIGGERS;
DROP TABLE IF EXISTS QRTZ_PAUSED_TRIGGER_GRPS;
DROP TABLE IF EXISTS QRTZ_SCHEDULER_STATE;
DROP TABLE IF EXISTS QRTZ_LOCKS;
DROP TABLE IF EXISTS QRTZ_SIMPLE_TRIGGERS;
DROP TABLE IF EXISTS QRTZ_SIMPROP_TRIGGERS;
DROP TABLE IF EXISTS QRTZ_CRON_TRIGGERS;
DROP TABLE IF EXISTS QRTZ_BLOB_TRIGGERS;
DROP TABLE IF EXISTS QRTZ_TRIGGERS;
DROP TABLE IF EXISTS QRTZ_JOB_DETAILS;
DROP TABLE IF EXISTS QRTZ_CALENDARS;

-- ----------------------------
-- 1、存储每一个已配置的 jobDetail 的详细信息
-- ----------------------------
create table QRTZ_JOB_DETAILS (
    sched_name           varchar(120)    not null            comment '调度名称',
    job_name             varchar(200)    not null            comment '任务名称',
    job_group            varchar(200)    not null            comment '任务组名',
    description          varchar(250)    null                comment '相关介绍',
    job_class_name       varchar(250)    not null            comment '执行任务类名称',
    is_durable           varchar(1)      not null            comment '是否持久化',
    is_nonconcurrent     varchar(1)      not null            comment '是否并发',
    is_update_data       varchar(1)      not null            comment '是否更新数据',
    requests_recovery    varchar(1)      not null            comment '是否接受恢复执行',
    job_data             blob            null                comment '存放持久化job对象',
    primary key (sched_name, job_name, job_group)
) engine=innodb comment = '任务详细信息表';

-- ----------------------------
-- 2、 存储已配置的 Trigger 的信息
-- ----------------------------
create table QRTZ_TRIGGERS (
    sched_name           varchar(120)    not null            comment '调度名称',
    trigger_name         varchar(200)    not null            comment '触发器的名字',
    trigger_group        varchar(200)    not null            comment '触发器所属组的名字',
    job_name             varchar(200)    not null            comment 'qrtz_job_details表job_name的外键',
    job_group            varchar(200)    not null            comment 'qrtz_job_details表job_group的外键',
    description          varchar(250)    null                comment '相关介绍',
    next_fire_time       bigint(13)      null                comment '上一次触发时间（毫秒）',
    prev_fire_time       bigint(13)      null                comment '下一次触发时间（默认为-1表示不触发）',
    priority             integer         null                comment '优先级',
    trigger_state        varchar(16)     not null            comment '触发器状态',
    trigger_type         varchar(8)      not null            comment '触发器的类型',
    start_time           bigint(13)      not null            comment '开始时间',
    end_time             bigint(13)      null                comment '结束时间',
    calendar_name        varchar(200)    null                comment '日程表名称',
    misfire_instr        smallint(2)     null                comment '补偿执行的策略',
    job_data             blob            null                comment '存放持久化job对象',
    primary key (sched_name, trigger_name, trigger_group),
    foreign key (sched_name, job_name, job_group) references QRTZ_JOB_DETAILS(sched_name, job_name, job_group)
) engine=innodb comment = '触发器详细信息表';

-- ----------------------------
-- 3、 存储简单的 Trigger，包括重复次数，间隔，以及已触发的次数
-- ----------------------------
create table QRTZ_SIMPLE_TRIGGERS (
    sched_name           varchar(120)    not null            comment '调度名称',
    trigger_name         varchar(200)    not null            comment 'qrtz_triggers表trigger_name的外键',
    trigger_group        varchar(200)    not null            comment 'qrtz_triggers表trigger_group的外键',
    repeat_count         bigint(7)       not null            comment '重复的次数统计',
    repeat_interval      bigint(12)      not null            comment '重复的间隔时间',
    times_triggered      bigint(10)      not null            comment '已经触发的次数',
    primary key (sched_name, trigger_name, trigger_group),
    foreign key (sched_name, trigger_name, trigger_group) references QRTZ_TRIGGERS(sched_name, trigger_name, trigger_group)
) engine=innodb comment = '简单触发器的信息表';

-- ----------------------------
-- 4、 存储 Cron Trigger，包括 Cron 表达式和时区信息
-- ---------------------------- 
create table QRTZ_CRON_TRIGGERS (
    sched_name           varchar(120)    not null            comment '调度名称',
    trigger_name         varchar(200)    not null            comment 'qrtz_triggers表trigger_name的外键',
    trigger_group        varchar(200)    not null            comment 'qrtz_triggers表trigger_group的外键',
    cron_expression      varchar(200)    not null            comment 'cron表达式',
    time_zone_id         varchar(80)                         comment '时区',
    primary key (sched_name, trigger_name, trigger_group),
    foreign key (sched_name, trigger_name, trigger_group) references QRTZ_TRIGGERS(sched_name, trigger_name, trigger_group)
) engine=innodb comment = 'Cron类型的触发器表';

-- ----------------------------
-- 5、 Trigger 作为 Blob 类型存储(用于 Quartz 用户用 JDBC 创建他们自己定制的 Trigger 类型，JobStore 并不知道如何存储实例的时候)
-- ---------------------------- 
create table QRTZ_BLOB_TRIGGERS (
    sched_name           varchar(120)    not null            comment '调度名称',
    trigger_name         varchar(200)    not null            comment 'qrtz_triggers表trigger_name的外键',
    trigger_group        varchar(200)    not null            comment 'qrtz_triggers表trigger_group的外键',
    blob_data            blob            null                comment '存放持久化Trigger对象',
    primary key (sched_name, trigger_name, trigger_group),
    foreign key (sched_name, trigger_name, trigger_group) references QRTZ_TRIGGERS(sched_name, trigger_name, trigger_group)
) engine=innodb comment = 'Blob类型的触发器表';

-- ----------------------------
-- 6、 以 Blob 类型存储存放日历信息， quartz可配置一个日历来指定一个时间范围
-- ---------------------------- 
create table QRTZ_CALENDARS (
    sched_name           varchar(120)    not null            comment '调度名称',
    calendar_name        varchar(200)    not null            comment '日历名称',
    calendar             blob            not null            comment '存放持久化calendar对象',
    primary key (sched_name, calendar_name)
) engine=innodb comment = '日历信息表';

-- ----------------------------
-- 7、 存储已暂停的 Trigger 组的信息
-- ---------------------------- 
create table QRTZ_PAUSED_TRIGGER_GRPS (
    sched_name           varchar(120)    not null            comment '调度名称',
    trigger_group        varchar(200)    not null            comment 'qrtz_triggers表trigger_group的外键',
    primary key (sched_name, trigger_group)
) engine=innodb comment = '暂停的触发器表';

-- ----------------------------
-- 8、 存储与已触发的 Trigger 相关的状态信息，以及相联 Job 的执行信息
-- ---------------------------- 
create table QRTZ_FIRED_TRIGGERS (
    sched_name           varchar(120)    not null            comment '调度名称',
    entry_id             varchar(95)     not null            comment '调度器实例id',
    trigger_name         varchar(200)    not null            comment 'qrtz_triggers表trigger_name的外键',
    trigger_group        varchar(200)    not null            comment 'qrtz_triggers表trigger_group的外键',
    instance_name        varchar(200)    not null            comment '调度器实例名',
    fired_time           bigint(13)      not null            comment '触发的时间',
    sched_time           bigint(13)      not null            comment '定时器制定的时间',
    priority             integer         not null            comment '优先级',
    state                varchar(16)     not null            comment '状态',
    job_name             varchar(200)    null                comment '任务名称',
    job_group            varchar(200)    null                comment '任务组名',
    is_nonconcurrent     varchar(1)      null                comment '是否并发',
    requests_recovery    varchar(1)      null                comment '是否接受恢复执行',
    primary key (sched_name, entry_id)
) engine=innodb comment = '已触发的触发器表';

-- ----------------------------
-- 9、 存储少量的有关 Scheduler 的状态信息，假如是用于集群中，可以看到其他的 Scheduler 实例
-- ---------------------------- 
create table QRTZ_SCHEDULER_STATE (
    sched_name           varchar(120)    not null            comment '调度名称',
    instance_name        varchar(200)    not null            comment '实例名称',
    last_checkin_time    bigint(13)      not null            comment '上次检查时间',
    checkin_interval     bigint(13)      not null            comment '检查间隔时间',
    primary key (sched_name, instance_name)
) engine=innodb comment = '调度器状态表';

-- ----------------------------
-- 10、 存储程序的悲观锁的信息(假如使用了悲观锁)
-- ---------------------------- 
create table QRTZ_LOCKS (
    sched_name           varchar(120)    not null            comment '调度名称',
    lock_name            varchar(40)     not null            comment '悲观锁名称',
    primary key (sched_name, lock_name)
) engine=innodb comment = '存储的悲观锁信息表';

-- ----------------------------
-- 11、 Quartz集群实现同步机制的行锁表
-- ---------------------------- 
create table QRTZ_SIMPROP_TRIGGERS (
    sched_name           varchar(120)    not null            comment '调度名称',
    trigger_name         varchar(200)    not null            comment 'qrtz_triggers表trigger_name的外键',
    trigger_group        varchar(200)    not null            comment 'qrtz_triggers表trigger_group的外键',
    str_prop_1           varchar(512)    null                comment 'String类型的trigger的第一个参数',
    str_prop_2           varchar(512)    null                comment 'String类型的trigger的第二个参数',
    str_prop_3           varchar(512)    null                comment 'String类型的trigger的第三个参数',
    int_prop_1           int             null                comment 'int类型的trigger的第一个参数',
    int_prop_2           int             null                comment 'int类型的trigger的第二个参数',
    long_prop_1          bigint          null                comment 'long类型的trigger的第一个参数',
    long_prop_2          bigint          null                comment 'long类型的trigger的第二个参数',
    dec_prop_1           numeric(13,4)   null                comment 'decimal类型的trigger的第一个参数',
    dec_prop_2           numeric(13,4)   null                comment 'decimal类型的trigger的第二个参数',
    bool_prop_1          varchar(1)      null                comment 'Boolean类型的trigger的第一个参数',
    bool_prop_2          varchar(1)      null                comment 'Boolean类型的trigger的第二个参数',
    primary key (sched_name, trigger_name, trigger_group),
    foreign key (sched_name, trigger_name, trigger_group) references QRTZ_TRIGGERS(sched_name, trigger_name, trigger_group)
) engine=innodb comment = '同步机制的行锁表';

-- =========================================
-- 第3部分：clinic_management_system.sql
-- =========================================

-- 诊所管理系统数据库表结构
-- 创建日期：2026-03-07
-- 注意：请先执行 ry_20250416.sql 初始化若依框架基础表，再执行此文件

-- 患者表
DROP TABLE IF EXISTS `clinic_patient`;
CREATE TABLE `clinic_patient` (
  `patient_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '患者ID',
  `user_id` bigint(20) DEFAULT NULL COMMENT '关联用户ID',
  `name` varchar(50) NOT NULL COMMENT '患者姓名',
  `gender` varchar(10) DEFAULT NULL COMMENT '性别',
  `age` int(11) DEFAULT NULL COMMENT '年龄',
  `phone` varchar(20) DEFAULT NULL COMMENT '联系电话',
  `birthday` date DEFAULT NULL COMMENT '出生日期',
  `address` varchar(255) DEFAULT NULL COMMENT '地址',
  `allergy_history` text COMMENT '过敏史',
  `past_history` text COMMENT '既往史',
  `blood_type` varchar(10) DEFAULT NULL COMMENT '血型',
  `wechat` varchar(50) DEFAULT NULL COMMENT '微信号',
  `avatar` varchar(255) DEFAULT NULL COMMENT '头像',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`patient_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_phone` (`phone`)
) ENGINE=InnoDB AUTO_INCREMENT=100 COMMENT='患者信息表';

-- 设置患者表自增起始值
ALTER TABLE `clinic_patient` AUTO_INCREMENT = 100;

-- 药品表
DROP TABLE IF EXISTS `clinic_medicine`;
CREATE TABLE `clinic_medicine` (
  `medicine_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '药品ID',
  `name` varchar(100) NOT NULL COMMENT '药品名称',
  `specification` varchar(100) DEFAULT NULL COMMENT '规格',
  `dosage_form` varchar(50) DEFAULT NULL COMMENT '剂型',
  `form` varchar(50) DEFAULT NULL COMMENT '形式',
  `manufacturer` varchar(100) DEFAULT NULL COMMENT '生产厂家',
  `expiry_date` date DEFAULT NULL COMMENT '有效期',
  `price` decimal(10,2) DEFAULT NULL COMMENT '价格',
  `stock` int(11) DEFAULT 0 COMMENT '库存数量',
  `warning_stock` int(11) DEFAULT 10 COMMENT '预警库存',
  `warning_threshold` int(11) DEFAULT 10 COMMENT '预警阈值',
  `min_stock` int(11) DEFAULT 10 COMMENT '最小库存',
  `unit` varchar(20) DEFAULT NULL COMMENT '单位',
  `pharmacology` text COMMENT '药理作用',
  `indications` text COMMENT '适应症',
  `dosage` text COMMENT '用法用量',
  `side_effects` text COMMENT '不良反应',
  `storage` varchar(255) DEFAULT NULL COMMENT '储存条件',
  `status` varchar(20) DEFAULT 'active' COMMENT '状态：active, inactive',
  `is_prescription` tinyint(1) DEFAULT 0 COMMENT '是否处方药',
  `category` varchar(50) DEFAULT NULL COMMENT '药品分类',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`medicine_id`),
  KEY `idx_name` (`name`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=100 COMMENT='药品信息表';

-- 设置药品表自增起始值
ALTER TABLE `clinic_medicine` AUTO_INCREMENT = 100;

-- 库存记录表
DROP TABLE IF EXISTS `clinic_stock_record`;
CREATE TABLE `clinic_stock_record` (
  `record_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `medicine_id` bigint(20) NOT NULL COMMENT '药品ID',
  `medicine_name` varchar(100) DEFAULT NULL COMMENT '药品名称',
  `operation_type` varchar(20) NOT NULL COMMENT '操作类型：in, out, check',
  `quantity` int(11) NOT NULL COMMENT '数量',
  `before_stock` int(11) DEFAULT NULL COMMENT '操作前库存',
  `after_stock` int(11) DEFAULT NULL COMMENT '操作后库存',
  `supplier` varchar(100) DEFAULT NULL COMMENT '供应商（入库用）',
  `purchase_price` decimal(10,2) DEFAULT NULL COMMENT '进货价格',
  `batch_number` varchar(50) DEFAULT NULL COMMENT '批号',
  `expiry_date` date DEFAULT NULL COMMENT '有效期',
  `operator_id` bigint(20) DEFAULT NULL COMMENT '操作人ID',
  `operator_name` varchar(50) DEFAULT NULL COMMENT '操作人姓名',
  `patient_name` varchar(50) DEFAULT NULL COMMENT '患者姓名（出库用）',
  `patient_id` bigint(20) DEFAULT NULL COMMENT '患者档案ID',
  `doctor_name` varchar(50) DEFAULT NULL COMMENT '医生姓名（出库用）',
  `doctor_id` bigint(20) DEFAULT NULL COMMENT '医生用户ID',
  `related_record_id` varchar(50) DEFAULT NULL COMMENT '关联记录ID',
  `related_record_type` varchar(50) DEFAULT NULL COMMENT '关联记录类型',
  `is_pack_medicine` tinyint(1) DEFAULT 0 COMMENT '是否包药（1=包药，0=普通出库）',
  `pack_items` text COMMENT '包药明细JSON（is_pack_medicine=1时使用）',
  `remark` text COMMENT '备注',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`record_id`),
  KEY `idx_medicine_id` (`medicine_id`),
  KEY `idx_operation_type` (`operation_type`),
  KEY `idx_create_time` (`create_time`),
  KEY `idx_clinic_stock_record_patient_id` (`patient_id`),
  KEY `idx_clinic_stock_record_doctor_id` (`doctor_id`)
) ENGINE=InnoDB AUTO_INCREMENT=100 COMMENT='库存记录表';

-- 设置库存记录表自增起始值
ALTER TABLE `clinic_stock_record` AUTO_INCREMENT = 100;

-- 包药损耗记录表
DROP TABLE IF EXISTS `clinic_pack_loss_record`;
CREATE TABLE `clinic_pack_loss_record` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `medicine_id` bigint(20) DEFAULT NULL COMMENT '药品ID',
  `medicine_name` varchar(100) DEFAULT NULL COMMENT '药品名称',
  `loss_quantity` int(11) DEFAULT NULL COMMENT '损耗数量',
  `related_record_id` varchar(50) DEFAULT NULL COMMENT '关联记录ID',
  `batch_number` varchar(50) DEFAULT NULL COMMENT '批次号',
  `is_processed` int(1) DEFAULT '0' COMMENT '是否处理（0=未处理，1=已处理）',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `operator_name` varchar(50) DEFAULT NULL COMMENT '操作员名称',
  PRIMARY KEY (`id`),
  KEY `idx_medicine_id` (`medicine_id`),
  KEY `idx_is_processed` (`is_processed`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='包药损耗记录表';

-- 批次库存表（用于按批次管理有效期）
DROP TABLE IF EXISTS `clinic_stock_batch`;
CREATE TABLE `clinic_stock_batch` (
  `batch_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '批次ID',
  `medicine_id` bigint(20) NOT NULL COMMENT '药品ID',
  `batch_number` varchar(50) NOT NULL COMMENT '批号',
  `expiry_date` date NOT NULL COMMENT '批次有效期',
  `remaining_quantity` int(11) NOT NULL DEFAULT 0 COMMENT '批次剩余库存',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`batch_id`),
  UNIQUE KEY `uk_medicine_batch_expiry` (`medicine_id`,`batch_number`,`expiry_date`),
  KEY `idx_medicine_expiry` (`medicine_id`,`expiry_date`)
) ENGINE=InnoDB AUTO_INCREMENT=100 COMMENT='批次库存表';

-- 设置批次库存表自增起始值
ALTER TABLE `clinic_stock_batch` AUTO_INCREMENT = 100;

-- 药品使用记录表
DROP TABLE IF EXISTS `clinic_usage_record`;
CREATE TABLE `clinic_usage_record` (
  `usage_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '使用记录ID',
  `medicine_id` bigint(20) NOT NULL COMMENT '药品ID',
  `medicine_name` varchar(100) DEFAULT NULL COMMENT '药品名称',
  `specification` varchar(100) DEFAULT NULL COMMENT '规格',
  `quantity` int(11) NOT NULL COMMENT '数量',
  `patient_id` bigint(20) DEFAULT NULL COMMENT '患者ID',
  `patient_name` varchar(50) DEFAULT NULL COMMENT '患者姓名',
  `medical_record_id` varchar(50) DEFAULT NULL COMMENT '病历ID',
  `doctor_id` bigint(20) DEFAULT NULL COMMENT '医生ID',
  `doctor_name` varchar(50) DEFAULT NULL COMMENT '医生姓名',
  `issue_time` datetime DEFAULT NULL COMMENT '发药时间',
  `issuer_id` bigint(20) DEFAULT NULL COMMENT '发药人ID',
  `issuer_name` varchar(50) DEFAULT NULL COMMENT '发药人姓名',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`usage_id`),
  KEY `idx_medicine_id` (`medicine_id`),
  KEY `idx_patient_id` (`patient_id`),
  KEY `idx_issue_time` (`issue_time`)
) ENGINE=InnoDB AUTO_INCREMENT=100 COMMENT='药品使用记录表';

-- 设置药品使用记录表自增起始值
ALTER TABLE `clinic_usage_record` AUTO_INCREMENT = 100;

-- 病历表
DROP TABLE IF EXISTS `clinic_medical_record`;
CREATE TABLE `clinic_medical_record` (
  `record_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '病历ID',
  `patient_id` bigint(20) NOT NULL COMMENT '患者ID',
  `patient_name` varchar(50) DEFAULT NULL COMMENT '患者姓名',
  `patient_gender` varchar(10) DEFAULT NULL COMMENT '患者性别',
  `patient_age` int(11) DEFAULT NULL COMMENT '患者年龄',
  `patient_phone` varchar(20) DEFAULT NULL COMMENT '患者电话',
  `patient_birthday` date DEFAULT NULL COMMENT '患者生日',
  `patient_blood_type` varchar(10) DEFAULT NULL COMMENT '患者血型',
  `doctor_id` bigint(20) DEFAULT NULL COMMENT '医生ID',
  `doctor_name` varchar(50) DEFAULT NULL COMMENT '医生姓名',
  `visit_time` datetime DEFAULT NULL COMMENT '就诊时间',
  `chief_complaint` text COMMENT '主诉',
  `present_illness` text COMMENT '现病史',
  `past_history` text COMMENT '既往史',
  `allergy_history` text COMMENT '过敏史',
  `physical_exam` text COMMENT '体格检查',
  `diagnosis` text COMMENT '诊断',
  `treatment` text COMMENT '治疗方案',
  `prescription` text COMMENT '处方（JSON格式）',
  `attachments` text COMMENT '附件（JSON格式）',
  `follow_up` text COMMENT '随访计划',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`record_id`),
  KEY `idx_patient_id` (`patient_id`),
  KEY `idx_doctor_id` (`doctor_id`),
  KEY `idx_visit_time` (`visit_time`)
) ENGINE=InnoDB AUTO_INCREMENT=100 COMMENT='病历记录表';

-- 设置病历表自增起始值
ALTER TABLE `clinic_medical_record` AUTO_INCREMENT = 100;

-- 预约表
DROP TABLE IF EXISTS `clinic_appointment`;
CREATE TABLE `clinic_appointment` (
  `appointment_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '预约ID',
  `patient_id` bigint(20) NOT NULL COMMENT '患者ID',
  `patient_name` varchar(50) DEFAULT NULL COMMENT '患者姓名',
  `patient_phone` varchar(20) DEFAULT NULL COMMENT '患者电话',
  `doctor_id` bigint(20) NOT NULL COMMENT '医生ID',
  `doctor_name` varchar(50) DEFAULT NULL COMMENT '医生姓名',
  `schedule_id` bigint(20) DEFAULT NULL COMMENT '排班ID',
  `appointment_date` date DEFAULT NULL COMMENT '预约日期',
  `appointment_time` varchar(20) DEFAULT NULL COMMENT '预约时间段',
  `sequence_number` int(11) DEFAULT NULL COMMENT '序号',
  `status` varchar(20) DEFAULT 'pending' COMMENT '状态：pending, confirmed, completed, cancelled',
  `is_offline` tinyint(1) DEFAULT 0 COMMENT '是否线下',
  `called` tinyint(1) DEFAULT 0 COMMENT '是否被叫号',
  `called_time` datetime DEFAULT NULL COMMENT '叫号时间',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`appointment_id`),
  KEY `idx_patient_id` (`patient_id`),
  KEY `idx_doctor_id` (`doctor_id`),
  KEY `idx_appointment_date` (`appointment_date`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=100 COMMENT='预约记录表';

-- 设置预约表自增起始值
ALTER TABLE `clinic_appointment` AUTO_INCREMENT = 100;

-- 排班表
DROP TABLE IF EXISTS `clinic_schedule`;
CREATE TABLE `clinic_schedule` (
  `schedule_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '排班ID',
  `doctor_id` bigint(20) NOT NULL COMMENT '医生ID',
  `doctor_name` varchar(50) DEFAULT NULL COMMENT '医生姓名',
  `title` varchar(50) DEFAULT NULL COMMENT '职称',
  `schedule_date` date DEFAULT NULL COMMENT '排班日期',
  `start_time` varchar(10) DEFAULT NULL COMMENT '开始时间',
  `end_time` varchar(10) DEFAULT NULL COMMENT '结束时间',
  `total_slots` int(11) DEFAULT 20 COMMENT '总号源数',
  `booked_slots` int(11) DEFAULT 0 COMMENT '已预约数',
  `status` varchar(20) DEFAULT 'active' COMMENT '状态：active, inactive',
  `create_by` varchar(64) DEFAULT '' COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` varchar(64) DEFAULT '' COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`schedule_id`),
  KEY `idx_doctor_id` (`doctor_id`),
  KEY `idx_schedule_date` (`schedule_date`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=100 COMMENT='排班表';

-- 设置排班表自增起始值
ALTER TABLE `clinic_schedule` AUTO_INCREMENT = 100;

-- 系统配置表
DROP TABLE IF EXISTS `clinic_config`;
CREATE TABLE `clinic_config` (
  `config_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '配置ID',
  `config_key` varchar(100) NOT NULL COMMENT '配置键',
  `config_value` text COMMENT '配置值',
  `description` varchar(255) DEFAULT NULL COMMENT '描述',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`config_id`),
  UNIQUE KEY `uk_config_key` (`config_key`)
) ENGINE=InnoDB AUTO_INCREMENT=100 COMMENT='系统配置表';

-- 设置系统配置表自增起始值
ALTER TABLE `clinic_config` AUTO_INCREMENT = 100;

-- 初始化系统配置数据
INSERT IGNORE INTO `clinic_config` (`config_key`, `config_value`, `description`, `create_time`) VALUES
('clinic.stockWarningThreshold', '10', '库存预警阈值', NOW()),
('clinic.appointmentDays', '7', '可预约天数', NOW());

-- =========================================
-- 第3.5部分：医生、患者角色（须在诊所菜单之前存在）
-- =========================================
INSERT IGNORE INTO sys_role (role_id, role_name, role_key, role_sort, data_scope, status, del_flag, create_by, create_time, remark) VALUES
(3, '医生', 'doctor', 3, 1, '0', '0', 'admin', NOW(), '医生角色'),
(4, '患者', 'patient', 4, 1, '0', '0', 'admin', NOW(), '患者角色');

-- =========================================
-- 第4部分：fix_clinic_menu_and_permissions.sql
-- =========================================


USE WechatProject;

-- ============================================
-- 删除旧的菜单配置（如果存在）
-- ============================================
DELETE FROM sys_role_menu WHERE menu_id >= 2000 AND menu_id <= 2099;
DELETE FROM sys_menu WHERE menu_id >= 2000 AND menu_id <= 2099;

-- ============================================
-- 1. 创建诊所管理系统菜单（修正版）
-- ============================================

-- 插入诊所管理一级菜单（使用INSERT IGNORE避免重复）
INSERT IGNORE INTO sys_menu (menu_id, menu_name, parent_id, order_num, url, target, menu_type, visible, is_refresh, perms, icon, create_by, create_time, update_by, update_time, remark) VALUES
(2000, '诊所管理', 0, 10, '', '', 'M', '0', '1', '', 'fa fa-hospital-o', 'admin', NOW(), '', NULL, '诊所管理菜单');

-- 插入患者管理菜单（使用INSERT IGNORE避免重复）
INSERT IGNORE INTO sys_menu (menu_id, menu_name, parent_id, order_num, url, target, menu_type, visible, is_refresh, perms, icon, create_by, create_time, update_by, update_time, remark) VALUES
(2001, '患者管理', 2000, 1, 'clinic/patient', '', 'C', '0', '1', 'clinic:patient:view', 'fa fa-user-md', 'admin', NOW(), '', NULL, '患者管理菜单'),
(2002, '患者查询', 2001, 1, '', '', 'F', '0', '1', 'clinic:patient:list', '#', 'admin', NOW(), '', NULL, ''),
(2003, '患者新增', 2001, 2, '', '', 'F', '0', '1', 'clinic:patient:add', '#', 'admin', NOW(), '', NULL, ''),
(2004, '患者修改', 2001, 3, '', '', 'F', '0', '1', 'clinic:patient:edit', '#', 'admin', NOW(), '', NULL, ''),
(2005, '患者删除', 2001, 4, '', '', 'F', '0', '1', 'clinic:patient:remove', '#', 'admin', NOW(), '', NULL, ''),
(2006, '患者导出', 2001, 5, '', '', 'F', '0', '1', 'clinic:patient:export', '#', 'admin', NOW(), '', NULL, '');

-- 插入药品管理菜单（使用INSERT IGNORE避免重复）
INSERT IGNORE INTO sys_menu (menu_id, menu_name, parent_id, order_num, url, target, menu_type, visible, is_refresh, perms, icon, create_by, create_time, update_by, update_time, remark) VALUES
(2010, '药品管理', 2000, 2, 'clinic/medicine', '', 'C', '0', '1', 'clinic:medicine:view', 'fa fa-medkit', 'admin', NOW(), '', NULL, '药品管理菜单'),
(2011, '药品查询', 2010, 1, '', '', 'F', '0', '1', 'clinic:medicine:list', '#', 'admin', NOW(), '', NULL, ''),
(2012, '药品新增', 2010, 2, '', '', 'F', '0', '1', 'clinic:medicine:add', '#', 'admin', NOW(), '', NULL, ''),
(2013, '药品修改', 2010, 3, '', '', 'F', '0', '1', 'clinic:medicine:edit', '#', 'admin', NOW(), '', NULL, ''),
(2014, '药品删除', 2010, 4, '', '', 'F', '0', '1', 'clinic:medicine:remove', '#', 'admin', NOW(), '', NULL, ''),
(2015, '药品导出', 2010, 5, '', '', 'F', '0', '1', 'clinic:medicine:export', '#', 'admin', NOW(), '', NULL, '');

-- 插入病历管理菜单（使用INSERT IGNORE避免重复）
INSERT IGNORE INTO sys_menu (menu_id, menu_name, parent_id, order_num, url, target, menu_type, visible, is_refresh, perms, icon, create_by, create_time, update_by, update_time, remark) VALUES
(2030, '病历管理', 2000, 3, 'clinic/medical', '', 'C', '0', '1', 'clinic:medical:view', 'fa fa-file-text', 'admin', NOW(), '', NULL, '病历管理菜单'),
(2031, '病历查询', 2030, 1, '', '', 'F', '0', '1', 'clinic:medical:list', '#', 'admin', NOW(), '', NULL, ''),
(2032, '病历新增', 2030, 2, '', '', 'F', '0', '1', 'clinic:medical:add', '#', 'admin', NOW(), '', NULL, ''),
(2033, '病历修改', 2030, 3, '', '', 'F', '0', '1', 'clinic:medical:edit', '#', 'admin', NOW(), '', NULL, ''),
(2034, '病历删除', 2030, 4, '', '', 'F', '0', '1', 'clinic:medical:remove', '#', 'admin', NOW(), '', NULL, '');

-- 插入预约管理菜单（使用INSERT IGNORE避免重复）
INSERT IGNORE INTO sys_menu (menu_id, menu_name, parent_id, order_num, url, target, menu_type, visible, is_refresh, perms, icon, create_by, create_time, update_by, update_time, remark) VALUES
(2040, '预约管理', 2000, 4, 'clinic/appointment', '', 'C', '0', '1', 'clinic:appointment:view', 'fa fa-calendar', 'admin', NOW(), '', NULL, '预约管理菜单'),
(2041, '预约查询', 2040, 1, '', '', 'F', '0', '1', 'clinic:appointment:list', '#', 'admin', NOW(), '', NULL, ''),
(2042, '预约新增', 2040, 2, '', '', 'F', '0', '1', 'clinic:appointment:add', '#', 'admin', NOW(), '', NULL, ''),
(2043, '预约修改', 2040, 3, '', '', 'F', '0', '1', 'clinic:appointment:edit', '#', 'admin', NOW(), '', NULL, ''),
(2044, '预约删除', 2040, 4, '', '', 'F', '0', '1', 'clinic:appointment:remove', '#', 'admin', NOW(), '', NULL, '');

-- 插入排班管理菜单（使用INSERT IGNORE避免重复）
INSERT IGNORE INTO sys_menu (menu_id, menu_name, parent_id, order_num, url, target, menu_type, visible, is_refresh, perms, icon, create_by, create_time, update_by, update_time, remark) VALUES
(2050, '排班管理', 2000, 5, 'clinic/schedule', '', 'C', '0', '1', 'clinic:schedule:view', 'fa fa-clock-o', 'admin', NOW(), '', NULL, '排班管理菜单'),
(2051, '排班查询', 2050, 1, '', '', 'F', '0', '1', 'clinic:schedule:list', '#', 'admin', NOW(), '', NULL, ''),
(2052, '排班新增', 2050, 2, '', '', 'F', '0', '1', 'clinic:schedule:add', '#', 'admin', NOW(), '', NULL, ''),
(2053, '排班修改', 2050, 3, '', '', 'F', '0', '1', 'clinic:schedule:edit', '#', 'admin', NOW(), '', NULL, ''),
(2054, '排班删除', 2050, 4, '', '', 'F', '0', '1', 'clinic:schedule:remove', '#', 'admin', NOW(), '', NULL, '');

-- ============================================
-- 2. 为角色分配菜单权限
-- ============================================

-- 为超级管理员角色(role_id=1)分配所有诊所管理菜单权限（使用INSERT IGNORE避免重复）
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) VALUES
(1, 2000), (1, 2001), (1, 2002), (1, 2003), (1, 2004), (1, 2005), (1, 2006),
(1, 2010), (1, 2011), (1, 2012), (1, 2013), (1, 2014), (1, 2015),
(1, 2030), (1, 2031), (1, 2032), (1, 2033), (1, 2034),
(1, 2040), (1, 2041), (1, 2042), (1, 2043), (1, 2044),
(1, 2050), (1, 2051), (1, 2052), (1, 2053), (1, 2054);

-- 为普通角色(role_id=2)分配诊所管理菜单权限（诊所管理员）（使用INSERT IGNORE避免重复）
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) VALUES
(2, 2000), (2, 2001), (2, 2002), (2, 2003), (2, 2004), (2, 2005), (2, 2006),
(2, 2010), (2, 2011), (2, 2012), (2, 2013), (2, 2014), (2, 2015),
(2, 2030), (2, 2031), (2, 2032), (2, 2033), (2, 2034),
(2, 2040), (2, 2041), (2, 2042), (2, 2043), (2, 2044),
(2, 2050), (2, 2051), (2, 2052), (2, 2053), (2, 2054);

-- 为医生角色(role_id=3)分配菜单权限（使用INSERT IGNORE避免重复）
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) VALUES
(3, 2000), 
(3, 2001), (3, 2002), (3, 2003), 
(3, 2010), (3, 2011),
(3, 2030), (3, 2031), (3, 2032), (3, 2033),
(3, 2040), (3, 2041), (3, 2042), (3, 2043),
(3, 2050), (3, 2051), (3, 2052), (3, 2053);

-- 为患者角色(role_id=4)分配菜单权限（使用INSERT IGNORE避免重复）
INSERT IGNORE INTO sys_role_menu (role_id, menu_id) VALUES
(4, 2000),
(4, 2030), (4, 2031),
(4, 2040), (4, 2041), (4, 2042), (4, 2043),
(4, 2050), (4, 2051);


-- =========================================
-- 第5部分：reset_and_reinit_clinic_data.sql
-- =========================================


USE WechatProject;

-- ============================================
-- 1. 删除诊所管理系统的所有业务数据
-- ============================================

-- 先禁用外键检查
SET FOREIGN_KEY_CHECKS = 0;

-- 删除业务表数据（使用DELETE FROM，因为MySQL不支持TRUNCATE TABLE IF EXISTS）
DELETE FROM clinic_stock_record;
DELETE FROM clinic_usage_record;
DELETE FROM clinic_medical_record;
DELETE FROM clinic_appointment;
DELETE FROM clinic_schedule;
DELETE FROM clinic_patient;
DELETE FROM clinic_medicine;
DELETE FROM clinic_config;

-- 重置自增ID（只在表存在时执行）
ALTER TABLE clinic_stock_record AUTO_INCREMENT = 100;
ALTER TABLE clinic_usage_record AUTO_INCREMENT = 100;
ALTER TABLE clinic_medical_record AUTO_INCREMENT = 100;
ALTER TABLE clinic_appointment AUTO_INCREMENT = 100;
ALTER TABLE clinic_schedule AUTO_INCREMENT = 100;
ALTER TABLE clinic_patient AUTO_INCREMENT = 100;
ALTER TABLE clinic_medicine AUTO_INCREMENT = 100;
ALTER TABLE clinic_config AUTO_INCREMENT = 100;

-- 恢复外键检查
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================
-- 2. 删除测试用户（保留admin超级管理员）
-- ============================================

-- 删除用户角色关联
DELETE FROM sys_user_role WHERE user_id IN (100, 101, 102, 103, 200, 201, 202);

-- 删除测试用户
DELETE FROM sys_user WHERE user_id IN (100, 101, 102, 103, 200, 201, 202);

-- ============================================
-- 3. 确保医生和患者角色存在
-- ============================================

INSERT IGNORE INTO sys_role (role_id, role_name, role_key, role_sort, data_scope, status, del_flag, create_by, create_time, remark) VALUES
(3, '医生', 'doctor', 3, 1, '0', '0', 'admin', NOW(), '医生角色'),
(4, '患者', 'patient', 4, 1, '0', '0', 'admin', NOW(), '患者角色');

-- ============================================
-- 4. 重新创建完整的用户账号（密码都为 123456）
-- ============================================

-- 诊所管理员账号
INSERT IGNORE INTO sys_user (user_id, dept_id, login_name, user_name, user_type, email, phonenumber, sex, avatar, password, salt, status, del_flag, create_by, create_time, remark) VALUES
(100, 100, '13800138001', '诊所管理员', '00', 'admin@clinic.com', '13800138001', '0', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '诊所管理员账号');

-- 医生账号1 - 内科医生
INSERT IGNORE INTO sys_user (user_id, dept_id, login_name, user_name, user_type, email, phonenumber, sex, avatar, password, salt, status, del_flag, create_by, create_time, remark) VALUES
(101, 103, '13800138002', '李医生', '00', 'doctor1@clinic.com', '13800138002', '0', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '内科医生');

-- 医生账号2 - 外科医生
INSERT IGNORE INTO sys_user (user_id, dept_id, login_name, user_name, user_type, email, phonenumber, sex, avatar, password, salt, status, del_flag, create_by, create_time, remark) VALUES
(102, 103, '13800138003', '王医生', '00', 'doctor2@clinic.com', '13800138003', '1', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '外科医生');

-- 医生账号3 - 儿科医生
INSERT IGNORE INTO sys_user (user_id, dept_id, login_name, user_name, user_type, email, phonenumber, sex, avatar, password, salt, status, del_flag, create_by, create_time, remark) VALUES
(103, 103, '13800138004', '张医生', '00', 'doctor3@clinic.com', '13800138004', '0', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '儿科医生');

-- 患者账号1
INSERT IGNORE INTO sys_user (user_id, dept_id, login_name, user_name, user_type, email, phonenumber, sex, avatar, password, salt, status, del_flag, create_by, create_time, remark) VALUES
(200, 103, '13800138005', '赵明', '01', 'patient1@clinic.com', '13800138005', '0', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '患者账号1');

-- 患者账号2
INSERT IGNORE INTO sys_user (user_id, dept_id, login_name, user_name, user_type, email, phonenumber, sex, avatar, password, salt, status, del_flag, create_by, create_time, remark) VALUES
(201, 103, '13800138006', '钱红', '01', 'patient2@clinic.com', '13800138006', '1', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '患者账号2');

-- 患者账号3
INSERT IGNORE INTO sys_user (user_id, dept_id, login_name, user_name, user_type, email, phonenumber, sex, avatar, password, salt, status, del_flag, create_by, create_time, remark) VALUES
(202, 103, '13800138007', '孙伟', '01', 'patient3@clinic.com', '13800138007', '0', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '患者账号3');

-- ============================================
-- 5. 分配用户角色
-- ============================================

INSERT IGNORE INTO sys_user_role (user_id, role_id) VALUES
(100, 2),         -- 诊所管理员 - 普通角色
(101, 3),         -- 李医生 - 医生
(102, 3),         -- 王医生 - 医生
(103, 3),         -- 张医生 - 医生
(200, 4),         -- 赵明 - 患者
(201, 4),         -- 钱红 - 患者
(202, 4);         -- 孙伟 - 患者

-- ============================================
-- 6. 初始化系统配置
-- ============================================

INSERT IGNORE INTO clinic_config (config_key, config_value, description, create_time, update_time) VALUES
('clinic.stockWarningThreshold', '10', '库存预警阈值', NOW(), NOW()),
('clinic.appointmentDays', '7', '可预约天数', NOW(), NOW()),
('clinic_name', '阳光社区诊所', '诊所名称', NOW(), NOW()),
('clinic_address', '北京市朝阳区建国路88号', '诊所地址', NOW(), NOW()),
('clinic_phone', '010-88888888', '诊所电话', NOW(), NOW());

-- ============================================
-- 7. 初始化药品数据
-- ============================================

INSERT IGNORE INTO clinic_medicine (name, specification, dosage_form, form, manufacturer, expiry_date, price, stock, warning_stock, warning_threshold, min_stock, unit, pharmacology, storage, status, is_prescription, category, create_time, update_time) VALUES
('感冒灵颗粒', '10g*9袋', '颗粒剂', '颗粒剂', '三九医药', '2026-12-31', 15.50, 100, 20, 20, 20, '盒', '解热镇痛，用于感冒引起的头痛、发热、鼻塞、流涕、咽痛等', '密封，置阴凉干燥处', 'active', 0, '感冒药', NOW(), NOW()),
('布洛芬缓释胶囊', '0.3g*20粒', '胶囊剂', '胶囊剂', '中美史克', '2026-06-30', 28.00, 50, 10, 10, 10, '盒', '非甾体抗炎药，具有镇痛、解热和抗炎作用', '密封保存', 'active', 0, '止痛药', NOW(), NOW()),
('云南白药喷雾剂', '50ml', '喷雾剂', '喷雾剂', '云南白药', '2025-12-31', 35.00, 30, 5, 5, 5, '瓶', '活血散瘀，消肿止痛，用于跌打损伤、瘀血肿痛', '密封，置阴凉干燥处', 'active', 0, '外用药', NOW(), NOW()),
('阿莫西林胶囊', '0.25g*24粒', '胶囊剂', '胶囊剂', '华北制药', '2025-08-31', 12.00, 28, 10, 10, 10, '盒', '青霉素类抗生素，用于敏感菌所致的各种感染', '遮光，密封保存', 'active', 1, '抗生素', NOW(), NOW()),
('小儿氨酚黄那敏颗粒', '3g*10袋', '颗粒剂', '颗粒剂', '哈药六厂', '2026-03-31', 18.00, 60, 15, 15, 15, '盒', '适用于儿童普通感冒及流行性感冒引起的发热、头痛等', '密封保存', 'active', 0, '儿童药', NOW(), NOW()),
('头孢克肟分散片', '0.1g*6片', '片剂', '片剂', '广州白云山', '2025-10-31', 32.00, 25, 8, 8, 8, '盒', '头孢菌素类抗生素，用于敏感菌引起的呼吸道、泌尿道感染等', '遮光，密封，在阴凉处保存', 'active', 1, '抗生素', NOW(), NOW()),
('维生素C片', '100mg*100片', '片剂', '片剂', '东北制药', '2027-01-31', 8.50, 120, 30, 30, 30, '瓶', '用于预防和治疗坏血病，以及各种急慢性传染性疾病', '遮光，密封保存', 'active', 0, '维生素', NOW(), NOW()),
('蒙脱石散', '3g*10袋', '散剂', '散剂', '博福-益普生', '2026-09-30', 25.00, 45, 12, 12, 12, '盒', '用于成人及儿童急慢性腹泻', '密封，在干燥处保存', 'active', 0, '消化药', NOW(), NOW()),
('奥美拉唑肠溶胶囊', '20mg*14粒', '胶囊剂', '胶囊剂', '阿斯利康', '2025-11-30', 58.00, 18, 6, 6, 6, '盒', '质子泵抑制剂，用于胃溃疡、十二指肠溃疡、反流性食管炎', '遮光，密封，在干燥处保存', 'active', 1, '胃药', NOW(), NOW()),
('碘伏消毒液', '100ml', '外用液体剂', '外用液体剂', '利康药业', '2026-05-31', 12.00, 80, 20, 20, 20, '瓶', '外用消毒剂，用于皮肤、黏膜的消毒', '遮光，密封保存', 'active', 0, '消毒药', NOW(), NOW()),
('复方甘草片', '100片', '片剂', '片剂', '同仁堂', '2026-08-15', 22.00, 40, 10, 10, 10, '瓶', '镇咳祛痰，用于上呼吸道感染引起的咳嗽', '密封保存', 'active', 0, '止咳药', NOW(), NOW()),
('氯雷他定片', '10mg*6片', '片剂', '片剂', '扬子江药业', '2026-04-20', 35.00, 35, 8, 8, 8, '盒', '抗组胺药，用于过敏性鼻炎、荨麻疹等过敏症状', '密封保存', 'active', 1, '抗过敏药', NOW(), NOW());

-- ============================================
-- 8. 初始化患者数据
-- ============================================

INSERT IGNORE INTO clinic_patient (user_id, name, gender, age, phone, birthday, address, allergy_history, past_history, blood_type, wechat, create_time, update_time) VALUES
(200, '赵明', '男', 40, '13800138005', '1985-03-15', '北京市朝阳区建国路88号', '青霉素过敏', '高血压病史5年，规律服药', 'A', 'zhaoming_1985', NOW(), NOW()),
(201, '钱红', '女', 34, '13800138006', '1990-07-22', '北京市海淀区中关村大街1号', '海鲜过敏', '无特殊病史', 'B', 'qianhong_90', NOW(), NOW()),
(202, '孙伟', '男', 46, '13800138007', '1978-11-08', '北京市东城区王府井大街255号', '花粉过敏', '哮喘病史3年，季节性发作', 'O', 'sunwei_78', NOW(), NOW());

-- ============================================
-- 9. 初始化医生排班数据
-- ============================================

-- 李医生的排班
INSERT IGNORE INTO clinic_schedule (doctor_id, doctor_name, title, schedule_date, start_time, end_time, total_slots, booked_slots, status, create_time, update_time) VALUES
(101, '李医生', '内科主治医师', CURDATE(), '08:00', '12:00', 20, 3, 'active', NOW(), NOW()),
(101, '李医生', '内科主治医师', CURDATE(), '14:00', '17:00', 15, 2, 'active', NOW(), NOW()),
(101, '李医生', '内科主治医师', DATE_ADD(CURDATE(), INTERVAL 1 DAY), '08:30', '12:00', 18, 1, 'active', NOW(), NOW()),
(101, '李医生', '内科主治医师', DATE_ADD(CURDATE(), INTERVAL 1 DAY), '14:00', '17:30', 12, 0, 'active', NOW(), NOW());

-- 王医生的排班
INSERT IGNORE INTO clinic_schedule (doctor_id, doctor_name, title, schedule_date, start_time, end_time, total_slots, booked_slots, status, create_time, update_time) VALUES
(102, '王医生', '外科主治医师', CURDATE(), '08:00', '12:00', 20, 4, 'active', NOW(), NOW()),
(102, '王医生', '外科主治医师', DATE_ADD(CURDATE(), INTERVAL 1 DAY), '09:00', '12:00', 15, 1, 'active', NOW(), NOW()),
(102, '王医生', '外科主治医师', DATE_ADD(CURDATE(), INTERVAL 2 DAY), '08:00', '11:30', 16, 2, 'active', NOW(), NOW());

-- 张医生的排班
INSERT IGNORE INTO clinic_schedule (doctor_id, doctor_name, title, schedule_date, start_time, end_time, total_slots, booked_slots, status, create_time, update_time) VALUES
(103, '张医生', '儿科主治医师', CURDATE(), '08:30', '11:30', 25, 5, 'active', NOW(), NOW()),
(103, '张医生', '儿科主治医师', DATE_ADD(CURDATE(), INTERVAL 1 DAY), '14:00', '17:30', 20, 2, 'active', NOW(), NOW()),
(103, '张医生', '儿科主治医师', DATE_ADD(CURDATE(), INTERVAL 2 DAY), '09:00', '12:00', 22, 3, 'active', NOW(), NOW());

-- ============================================
-- 10. 初始化预约数据（不插入有外键关系的数据）
-- ============================================
-- 注意：为避免外键约束问题，暂不插入预约、病历、库存记录等有依赖数据
-- ============================================

-- ============================================
-- 初始化完成
-- ============================================

-- 重新启用外键检查
SET FOREIGN_KEY_CHECKS = 1;

SELECT '诊所管理系统数据重置完成！' AS message;

-- =========================================
-- FINAL RESET DATASET (ry123)
-- 删除现有业务数据与账号并重建全功能演示数据
-- =========================================
USE WechatProject;
SET FOREIGN_KEY_CHECKS = 0;

DELETE FROM clinic_usage_record;
DELETE FROM clinic_stock_record;
DELETE FROM clinic_stock_batch;
DELETE FROM clinic_medical_record;
DELETE FROM clinic_appointment;
DELETE FROM clinic_schedule;
DELETE FROM clinic_patient;
DELETE FROM clinic_medicine;
DELETE FROM clinic_config;

ALTER TABLE clinic_usage_record AUTO_INCREMENT = 100;
ALTER TABLE clinic_stock_record AUTO_INCREMENT = 100;
ALTER TABLE clinic_stock_batch AUTO_INCREMENT = 100;
ALTER TABLE clinic_medical_record AUTO_INCREMENT = 100;
ALTER TABLE clinic_appointment AUTO_INCREMENT = 100;
ALTER TABLE clinic_schedule AUTO_INCREMENT = 100;
ALTER TABLE clinic_patient AUTO_INCREMENT = 100;
ALTER TABLE clinic_medicine AUTO_INCREMENT = 100;
ALTER TABLE clinic_config AUTO_INCREMENT = 100;

DELETE FROM sys_user_role WHERE user_id <> 1;
DELETE FROM sys_user WHERE user_id <> 1;

INSERT IGNORE INTO sys_role (role_id, role_name, role_key, role_sort, data_scope, status, del_flag, create_by, create_time, remark) VALUES
(3, '医生', 'doctor', 3, 1, '0', '0', 'admin', NOW(), '医生角色'),
(4, '患者', 'patient', 4, 1, '0', '0', 'admin', NOW(), '患者角色');

INSERT INTO sys_user (user_id, dept_id, login_name, user_name, user_type, email, phonenumber, sex, avatar, password, salt, status, del_flag, create_by, create_time, remark) VALUES
(100, 100, '13800138001', '诊所管理员', '00', 'admin@clinic.com', '13800138001', '0', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '诊所管理员'),
(101, 103, '13800138002', '李医生', '00', 'doctor1@clinic.com', '13800138002', '0', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '内科医生'),
(102, 103, '13800138003', '王医生', '00', 'doctor2@clinic.com', '13800138003', '1', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '外科医生'),
(103, 103, '13800138004', '张医生', '00', 'doctor3@clinic.com', '13800138004', '0', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '儿科医生'),
(200, 103, '13800138100', '赵明', '01', 'patient1@clinic.com', '13800138100', '0', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '患者账号'),
(201, 103, '13800138101', '钱红', '01', 'patient2@clinic.com', '13800138101', '1', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '患者账号'),
(202, 103, '13800138102', '孙伟', '01', 'patient3@clinic.com', '13800138102', '0', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '患者账号'),
(203, 103, '13800138103', '李静', '01', 'patient4@clinic.com', '13800138103', '1', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '患者账号'),
(204, 103, '13800138104', '周强', '01', 'patient5@clinic.com', '13800138104', '0', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '患者账号'),
(205, 103, '13800138105', '吴婷', '01', 'patient6@clinic.com', '13800138105', '1', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '患者账号'),
(206, 103, '13800138106', '郑峰', '01', 'patient7@clinic.com', '13800138106', '0', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '患者账号'),
(207, 103, '13800138107', '王芳', '01', 'patient8@clinic.com', '13800138107', '1', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '患者账号'),
(208, 103, '13800138108', '何磊', '01', 'patient9@clinic.com', '13800138108', '0', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '患者账号'),
(209, 103, '13800138109', '郭敏', '01', 'patient10@clinic.com', '13800138109', '1', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '患者账号'),
(210, 103, '13800138110', '陈旭', '01', 'patient11@clinic.com', '13800138110', '0', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '患者账号'),
(211, 103, '13800138111', '宋雨', '01', 'patient12@clinic.com', '13800138111', '1', '', '29c67a30398638269fe600f73a054934', '111111', '0', '0', 'admin', NOW(), '患者账号');

INSERT INTO sys_user_role (user_id, role_id) VALUES
(100, 2), (101, 3), (102, 3), (103, 3),
(200, 4), (201, 4), (202, 4), (203, 4), (204, 4), (205, 4), (206, 4), (207, 4), (208, 4), (209, 4), (210, 4), (211, 4);

INSERT INTO clinic_config (config_key, config_value, description, create_time, update_time) VALUES
('clinic.stockWarningThreshold', '10', '库存预警阈值', NOW(), NOW()),
('clinic.appointmentDays', '14', '可预约天数', NOW(), NOW()),
('clinic_name', '阳光社区诊所', '诊所名称', NOW(), NOW()),
('clinic_address', '北京市朝阳区建国路88号', '诊所地址', NOW(), NOW()),
('clinic_phone', '010-88888888', '诊所电话', NOW(), NOW());

INSERT INTO clinic_medicine (medicine_id, name, specification, dosage_form, form, manufacturer, expiry_date, price, stock, warning_stock, warning_threshold, min_stock, unit, pharmacology, indications, dosage, side_effects, storage, status, is_prescription, category, create_by, create_time, update_by, update_time, remark) VALUES
(100, '感冒灵颗粒', '10g*9袋', '颗粒剂', '颗粒剂', '三九医药', '2026-12-31', 15.50, 100, 20, 20, 20, '盒', '解热镇痛', '普通感冒', '一次1袋，一日3次', '偶见皮疹', '阴凉干燥处', 'active', 0, '感冒药', 'admin', NOW(), 'admin', NOW(), '常用'),
(101, '布洛芬缓释胶囊', '0.3g*20粒', '胶囊剂', '胶囊剂', '中美史克', '2026-06-30', 28.00, 50, 10, 10, 10, '盒', '抗炎镇痛', '发热、疼痛', '一次1粒，必要时间隔8小时', '胃部不适', '密封保存', 'active', 0, '止痛药', 'admin', NOW(), 'admin', NOW(), '常用'),
(102, '阿莫西林胶囊', '0.25g*24粒', '胶囊剂', '胶囊剂', '华北制药', '2025-08-31', 12.00, 28, 10, 10, 10, '盒', '抗生素', '上呼吸道感染', '一次2粒，一日3次', '过敏反应', '避光密封', 'active', 1, '抗生素', 'admin', NOW(), 'admin', NOW(), '处方药'),
(103, '头孢克肟分散片', '0.1g*6片', '片剂', '片剂', '白云山', '2025-10-31', 32.00, 25, 8, 8, 8, '盒', '头孢类抗生素', '呼吸道感染', '一次1片，一日2次', '胃肠道反应', '避光保存', 'active', 1, '抗生素', 'admin', NOW(), 'admin', NOW(), '处方药'),
(104, '维生素C片', '100mg*100片', '片剂', '片剂', '东北制药', '2027-01-31', 8.50, 120, 30, 30, 30, '瓶', '补充维生素', '维生素缺乏', '一次1片，一日2次', '偶见恶心', '密封保存', 'active', 0, '维生素', 'admin', NOW(), 'admin', NOW(), '保健'),
(105, '蒙脱石散', '3g*10袋', '散剂', '散剂', '博福-益普生', '2026-09-30', 25.00, 45, 12, 12, 12, '盒', '肠道保护', '腹泻', '一次1袋，一日3次', '便秘', '干燥处保存', 'active', 0, '消化药', 'admin', NOW(), 'admin', NOW(), '常用'),
(106, '奥美拉唑肠溶胶囊', '20mg*14粒', '胶囊剂', '胶囊剂', '阿斯利康', '2025-11-30', 58.00, 18, 6, 6, 6, '盒', '抑酸', '胃炎、反流', '一次1粒，一日1次', '头晕', '避光保存', 'active', 1, '胃药', 'admin', NOW(), 'admin', NOW(), '处方药'),
(107, '氯雷他定片', '10mg*6片', '片剂', '片剂', '扬子江药业', '2026-04-20', 35.00, 35, 8, 8, 8, '盒', '抗过敏', '过敏性鼻炎', '一次1片，一日1次', '困倦', '密封保存', 'active', 1, '抗过敏', 'admin', NOW(), 'admin', NOW(), '处方药'),
(108, '云南白药喷雾剂', '50ml', '喷雾剂', '喷雾剂', '云南白药', '2025-12-31', 35.00, 30, 5, 5, 5, '瓶', '活血止痛', '跌打损伤', '外用适量喷涂', '局部刺激', '阴凉处', 'active', 0, '外用药', 'admin', NOW(), 'admin', NOW(), '常用'),
(109, '碘伏消毒液', '100ml', '外用液体剂', '外用液体剂', '利康药业', '2026-05-31', 12.00, 80, 20, 20, 20, '瓶', '消毒杀菌', '皮肤消毒', '外用涂擦', '偶见过敏', '避光密封', 'active', 0, '消毒药', 'admin', NOW(), 'admin', NOW(), '常用'),
(110, '复方甘草片', '100片', '片剂', '片剂', '同仁堂', '2026-08-15', 22.00, 40, 10, 10, 10, '瓶', '镇咳祛痰', '咳嗽', '一次2片，一日3次', '嗜睡', '密封保存', 'active', 0, '止咳药', 'admin', NOW(), 'admin', NOW(), '常用'),
(111, '小儿氨酚黄那敏颗粒', '3g*10袋', '颗粒剂', '颗粒剂', '哈药六厂', '2026-03-31', 18.00, 60, 15, 15, 15, '盒', '儿童退热', '儿童感冒', '一次1袋，一日3次', '嗜睡', '密封保存', 'active', 0, '儿科药', 'admin', NOW(), 'admin', NOW(), '常用');

INSERT INTO clinic_stock_batch (batch_id, medicine_id, batch_number, expiry_date, remaining_quantity, create_time, update_time) VALUES
(100,100,'CM202601','2026-08-31',40,NOW(),NOW()),(101,100,'CM202602','2026-12-31',60,NOW(),NOW()),
(102,101,'BLF202601','2026-06-30',50,NOW(),NOW()),
(103,102,'AMX202507','2025-08-31',28,NOW(),NOW()),
(104,103,'TBK202510','2025-10-31',25,NOW(),NOW()),
(105,104,'VC202701','2027-01-31',120,NOW(),NOW()),
(106,105,'MTS202609','2026-09-30',45,NOW(),NOW()),
(107,106,'AML202511','2025-11-30',18,NOW(),NOW()),
(108,107,'LLTD202604','2026-04-20',35,NOW(),NOW()),
(109,108,'YNBY202512','2025-12-31',30,NOW(),NOW()),
(110,109,'DF202605','2026-05-31',80,NOW(),NOW()),
(111,110,'FFGC202608','2026-08-15',40,NOW(),NOW()),
(112,111,'XEA202603','2026-03-31',60,NOW(),NOW());

INSERT INTO clinic_patient (patient_id, user_id, name, gender, age, phone, birthday, address, allergy_history, past_history, blood_type, wechat, avatar, create_by, create_time, update_by, update_time, remark) VALUES
(100,200,'赵明','男',40,'13800138100','1986-03-15','北京市朝阳区1号','青霉素过敏','高血压病史','A','zhaoming86','', 'admin',NOW(),'admin',NOW(),'慢病管理'),
(101,201,'钱红','女',34,'13800138101','1992-07-22','北京市海淀区2号','海鲜过敏','无','B','qianhong92','', 'admin',NOW(),'admin',NOW(),'普通患者'),
(102,202,'孙伟','男',46,'13800138102','1980-11-08','北京市东城区3号','花粉过敏','哮喘病史','O','sunwei80','', 'admin',NOW(),'admin',NOW(),'呼吸科'),
(103,203,'李静','女',29,'13800138103','1997-04-02','北京市丰台区4号','无','胃炎病史','AB','lijing97','', 'admin',NOW(),'admin',NOW(),'消化科'),
(104,204,'周强','男',52,'13800138104','1974-10-10','北京市昌平区5号','无','糖尿病病史','A','zhouqiang74','', 'admin',NOW(),'admin',NOW(),'慢病管理'),
(105,205,'吴婷','女',31,'13800138105','1995-12-01','北京市通州区6号','头孢过敏','甲状腺结节','B','wuting95','', 'admin',NOW(),'admin',NOW(),'复诊'),
(106,206,'郑峰','男',38,'13800138106','1988-01-23','北京市顺义区7号','无','无','O','zhengfeng88','', 'admin',NOW(),'admin',NOW(),'普通患者'),
(107,207,'王芳','女',44,'13800138107','1982-06-16','北京市大兴区8号','无','偏头痛病史','AB','wangfang82','', 'admin',NOW(),'admin',NOW(),'神经内科'),
(108,208,'何磊','男',27,'13800138108','1999-09-12','北京市石景山区9号','尘螨过敏','鼻炎病史','A','helei99','', 'admin',NOW(),'admin',NOW(),'过敏门诊'),
(109,209,'郭敏','女',36,'13800138109','1990-02-19','北京市门头沟区10号','无','无','B','guomin90','', 'admin',NOW(),'admin',NOW(),'普通患者'),
(110,210,'陈旭','男',33,'13800138110','1993-08-25','北京市房山区11号','无','腰肌劳损','O','chenxu93','', 'admin',NOW(),'admin',NOW(),'康复门诊'),
(111,211,'宋雨','女',25,'13800138111','2001-05-03','北京市延庆区12号','青霉素过敏','无','AB','songyu01','', 'admin',NOW(),'admin',NOW(),'儿科家属');

INSERT INTO clinic_schedule (schedule_id, doctor_id, doctor_name, title, schedule_date, start_time, end_time, total_slots, booked_slots, status, create_by, create_time, update_by, update_time, remark) VALUES
(100,101,'李医生','内科主治医师',CURDATE(),'08:00','12:00',20,6,'active','admin',NOW(),'admin',NOW(),'上午门诊'),
(101,101,'李医生','内科主治医师',CURDATE(),'14:00','17:30',15,4,'active','admin',NOW(),'admin',NOW(),'下午门诊'),
(102,102,'王医生','外科主治医师',CURDATE(),'08:30','12:00',18,5,'active','admin',NOW(),'admin',NOW(),'外科门诊'),
(103,102,'王医生','外科主治医师',DATE_ADD(CURDATE(),INTERVAL 1 DAY),'14:00','17:30',16,3,'active','admin',NOW(),'admin',NOW(),'复诊门诊'),
(104,103,'张医生','儿科主治医师',CURDATE(),'09:00','12:00',22,7,'active','admin',NOW(),'admin',NOW(),'儿科门诊'),
(105,103,'张医生','儿科主治医师',DATE_ADD(CURDATE(),INTERVAL 1 DAY),'14:00','17:30',20,2,'active','admin',NOW(),'admin',NOW(),'儿科复诊');

INSERT INTO clinic_appointment (appointment_id, patient_id, patient_name, patient_phone, doctor_id, doctor_name, schedule_id, appointment_date, appointment_time, sequence_number, status, is_offline, create_by, create_time, update_by, update_time, remark) VALUES
(100,100,'赵明','13800138100',101,'李医生',100,CURDATE(),'08:30-08:45',1,'confirmed',0,'admin',NOW(),'admin',NOW(),'线上预约'),
(101,101,'钱红','13800138101',101,'李医生',100,CURDATE(),'08:45-09:00',2,'completed',1,'admin',NOW(),'admin',NOW(),'线下已就诊'),
(102,102,'孙伟','13800138102',102,'王医生',102,CURDATE(),'09:00-09:15',1,'pending',0,'admin',NOW(),'admin',NOW(),'待确认'),
(103,103,'李静','13800138103',102,'王医生',102,CURDATE(),'09:15-09:30',2,'cancelled',0,'admin',NOW(),'admin',NOW(),'用户取消'),
(104,104,'周强','13800138104',103,'张医生',104,CURDATE(),'09:30-09:45',1,'completed',1,'admin',NOW(),'admin',NOW(),'儿科家属陪诊'),
(105,105,'吴婷','13800138105',101,'李医生',101,CURDATE(),'14:00-14:15',1,'confirmed',0,'admin',NOW(),'admin',NOW(),'复诊预约');

INSERT INTO clinic_medical_record (record_id, patient_id, patient_name, patient_gender, patient_age, patient_phone, patient_birthday, patient_blood_type, doctor_id, doctor_name, visit_time, chief_complaint, present_illness, past_history, allergy_history, physical_exam, diagnosis, treatment, prescription, attachments, follow_up, create_by, create_time, update_by, update_time, remark) VALUES
(100,100,'赵明','男',40,'13800138100','1986-03-15','A',101,'李医生',DATE_SUB(NOW(),INTERVAL 3 DAY),'发热咳嗽2天','咽痛、低热','高血压','青霉素过敏','体温37.8℃，咽部充血','上呼吸道感染','对症治疗，多饮水','[{"medicineId":100,"name":"感冒灵颗粒","dosage":"1袋","frequency":"每日3次","days":3},{"medicineId":101,"name":"布洛芬缓释胶囊","dosage":"1粒","frequency":"必要时","days":2}]','[]','3天后复诊','admin',NOW(),'admin',NOW(),'首诊'),
(101,101,'钱红','女',34,'13800138101','1992-07-22','B',101,'李医生',DATE_SUB(NOW(),INTERVAL 2 DAY),'胃部不适1周','反酸、嗳气','无','海鲜过敏','上腹轻压痛','慢性胃炎','抑酸+饮食调整','[{"medicineId":106,"name":"奥美拉唑肠溶胶囊","dosage":"1粒","frequency":"每日1次","days":14}]','[]','2周后复诊','admin',NOW(),'admin',NOW(),'慢病随访'),
(102,102,'孙伟','男',46,'13800138102','1980-11-08','O',102,'王医生',DATE_SUB(NOW(),INTERVAL 1 DAY),'咽痛伴发热','起病急','哮喘病史','花粉过敏','咽部红肿','急性咽炎','抗感染治疗','[{"medicineId":103,"name":"头孢克肟分散片","dosage":"1片","frequency":"每日2次","days":5}]','[]','必要时复诊','admin',NOW(),'admin',NOW(),'普通门诊'),
(103,104,'周强','男',52,'13800138104','1974-10-10','A',103,'张医生',NOW(),'咳嗽3天','夜间加重','糖尿病病史','无','双肺呼吸音粗','急性支气管炎','止咳化痰','[{"medicineId":110,"name":"复方甘草片","dosage":"2片","frequency":"每日3次","days":4}]','[]','1周后复诊','admin',NOW(),'admin',NOW(),'已开药');

INSERT INTO clinic_usage_record (usage_id, medicine_id, medicine_name, specification, quantity, patient_id, patient_name, medical_record_id, doctor_id, doctor_name, issue_time, issuer_id, issuer_name, create_time) VALUES
(100,100,'感冒灵颗粒','10g*9袋',3,100,'赵明','100',101,'李医生',DATE_SUB(NOW(),INTERVAL 3 DAY),100,'诊所管理员',NOW()),
(101,101,'布洛芬缓释胶囊','0.3g*20粒',2,100,'赵明','100',101,'李医生',DATE_SUB(NOW(),INTERVAL 3 DAY),100,'诊所管理员',NOW()),
(102,106,'奥美拉唑肠溶胶囊','20mg*14粒',14,101,'钱红','101',101,'李医生',DATE_SUB(NOW(),INTERVAL 2 DAY),100,'诊所管理员',NOW()),
(103,103,'头孢克肟分散片','0.1g*6片',5,102,'孙伟','102',102,'王医生',DATE_SUB(NOW(),INTERVAL 1 DAY),100,'诊所管理员',NOW()),
(104,110,'复方甘草片','100片',6,104,'周强','103',103,'张医生',NOW(),100,'诊所管理员',NOW());

INSERT INTO clinic_stock_record (record_id, medicine_id, medicine_name, operation_type, quantity, before_stock, after_stock, supplier, purchase_price, batch_number, expiry_date, operator_id, operator_name, patient_name, doctor_name, related_record_id, related_record_type, remark, create_time) VALUES
(100,100,'感冒灵颗粒','in',60,40,100,'国药供应链',12.00,'CM202602','2026-12-31',100,'诊所管理员',NULL,NULL,NULL,NULL,'补货入库',DATE_SUB(NOW(),INTERVAL 10 DAY)),
(101,101,'布洛芬缓释胶囊','in',50,0,50,'国药供应链',21.00,'BLF202601','2026-06-30',100,'诊所管理员',NULL,NULL,NULL,NULL,'新批次入库',DATE_SUB(NOW(),INTERVAL 9 DAY)),
(102,100,'感冒灵颗粒','out',3,100,97,NULL,NULL,'CM202602','2026-12-31',101,'李医生','赵明','李医生','100','medical','处方发药',DATE_SUB(NOW(),INTERVAL 3 DAY)),
(103,101,'布洛芬缓释胶囊','out',2,50,48,NULL,NULL,'BLF202601','2026-06-30',101,'李医生','赵明','李医生','100','medical','处方发药',DATE_SUB(NOW(),INTERVAL 3 DAY)),
(104,106,'奥美拉唑肠溶胶囊','out',14,18,4,NULL,NULL,'AML202511','2025-11-30',101,'李医生','钱红','李医生','101','medical','处方发药',DATE_SUB(NOW(),INTERVAL 2 DAY)),
(105,103,'头孢克肟分散片','out',5,25,20,NULL,NULL,'TBK202510','2025-10-31',102,'王医生','孙伟','王医生','102','medical','处方发药',DATE_SUB(NOW(),INTERVAL 1 DAY)),
(106,110,'复方甘草片','out',6,40,34,NULL,NULL,'FFGC202608','2026-08-15',103,'张医生','周强','张医生','103','medical','处方发药',NOW()),
(107,109,'碘伏消毒液','check',0,80,80,NULL,NULL,'DF202605','2026-05-31',100,'诊所管理员',NULL,NULL,NULL,NULL,'库存盘点正常',NOW());

SET FOREIGN_KEY_CHECKS = 1;
SELECT 'ry123 全量数据重建完成（含12个患者账号）' AS message;

-- 统一重算账号密码（密码=123456，算法：MD5(login_name + password + salt)）
UPDATE sys_user
SET password = MD5(CONCAT(login_name, '123456', salt))
WHERE user_id IN (1,100,101,102,103,200,201,202,203,204,205,206,207,208,209,210,211);

-- =========================================
-- 2026-04-04 medicine recognition additions
-- =========================================

SET @db_name = DATABASE();
SET @barcode_column_exists = (
  SELECT COUNT(1) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @db_name AND TABLE_NAME = 'clinic_medicine' AND COLUMN_NAME = 'barcode'
);
SET @barcode_column_sql = IF(
  @barcode_column_exists = 0,
  'ALTER TABLE clinic_medicine ADD COLUMN barcode VARCHAR(64) NULL COMMENT ''药品条码'' AFTER manufacturer',
  'SELECT ''clinic_medicine.barcode already exists'''
);
PREPARE stmt_ry_barcode_column FROM @barcode_column_sql;
EXECUTE stmt_ry_barcode_column;
DEALLOCATE PREPARE stmt_ry_barcode_column;

SET @barcode_index_exists = (
  SELECT COUNT(1) FROM information_schema.STATISTICS
  WHERE TABLE_SCHEMA = @db_name AND TABLE_NAME = 'clinic_medicine' AND INDEX_NAME = 'idx_barcode'
);
SET @barcode_index_sql = IF(
  @barcode_index_exists = 0,
  'CREATE INDEX idx_barcode ON clinic_medicine(barcode)',
  'SELECT ''idx_barcode already exists'''
);
PREPARE stmt_ry_barcode_index FROM @barcode_index_sql;
EXECUTE stmt_ry_barcode_index;
DEALLOCATE PREPARE stmt_ry_barcode_index;

SET @location_column_exists = (
  SELECT COUNT(1) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @db_name AND TABLE_NAME = 'clinic_medicine' AND COLUMN_NAME = 'location'
);
SET @location_column_sql = IF(
  @location_column_exists = 0,
  'ALTER TABLE clinic_medicine ADD COLUMN location VARCHAR(100) NULL COMMENT ''存放位置'' AFTER category',
  'SELECT ''clinic_medicine.location already exists'''
);
PREPARE stmt_ry_location_column FROM @location_column_sql;
EXECUTE stmt_ry_location_column;
DEALLOCATE PREPARE stmt_ry_location_column;

CREATE TABLE IF NOT EXISTS clinic_ai_provider (
  provider_id BIGINT(20) NOT NULL AUTO_INCREMENT,
  provider_code VARCHAR(64) NOT NULL,
  provider_name VARCHAR(128) NOT NULL,
  api_base_url VARCHAR(255) DEFAULT NULL,
  api_key VARCHAR(512) DEFAULT NULL,
  enabled TINYINT(1) NOT NULL DEFAULT 1,
  remark VARCHAR(500) DEFAULT NULL,
  create_by VARCHAR(64) DEFAULT NULL,
  create_time DATETIME DEFAULT NULL,
  update_by VARCHAR(64) DEFAULT NULL,
  update_time DATETIME DEFAULT NULL,
  PRIMARY KEY (provider_id),
  UNIQUE KEY uk_provider_code (provider_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI Provider 配置';

CREATE TABLE IF NOT EXISTS clinic_ai_model (
  model_id BIGINT(20) NOT NULL AUTO_INCREMENT,
  provider_id BIGINT(20) NOT NULL,
  model_code VARCHAR(128) NOT NULL,
  model_name VARCHAR(128) NOT NULL,
  supports_vision TINYINT(1) NOT NULL DEFAULT 0,
  supports_web_search TINYINT(1) NOT NULL DEFAULT 0,
  supports_json_schema TINYINT(1) NOT NULL DEFAULT 0,
  enabled TINYINT(1) NOT NULL DEFAULT 1,
  remark VARCHAR(500) DEFAULT NULL,
  create_by VARCHAR(64) DEFAULT NULL,
  create_time DATETIME DEFAULT NULL,
  update_by VARCHAR(64) DEFAULT NULL,
  update_time DATETIME DEFAULT NULL,
  PRIMARY KEY (model_id),
  KEY idx_provider_id (provider_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI Model 配置';

CREATE TABLE IF NOT EXISTS clinic_ai_scene_binding (
  scene_id BIGINT(20) NOT NULL AUTO_INCREMENT,
  scene_code VARCHAR(64) NOT NULL,
  scene_name VARCHAR(128) NOT NULL,
  execution_mode VARCHAR(32) NOT NULL,
  primary_model_id BIGINT(20) DEFAULT NULL,
  fallback_model_id BIGINT(20) DEFAULT NULL,
  candidate_limit INT NOT NULL DEFAULT 3,
  timeout_ms INT NOT NULL DEFAULT 15000,
  enabled TINYINT(1) NOT NULL DEFAULT 1,
  remark VARCHAR(500) DEFAULT NULL,
  create_by VARCHAR(64) DEFAULT NULL,
  create_time DATETIME DEFAULT NULL,
  update_by VARCHAR(64) DEFAULT NULL,
  update_time DATETIME DEFAULT NULL,
  PRIMARY KEY (scene_id),
  UNIQUE KEY uk_scene_code (scene_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI 场景绑定';

INSERT IGNORE INTO sys_menu (menu_id, menu_name, parent_id, order_num, url, target, menu_type, visible, is_refresh, perms, icon, create_by, create_time, update_by, update_time, remark) VALUES
(2060, 'AI模型配置', 2000, 6, '#', '', 'M', '0', '1', '', 'fa fa-robot', 'admin', NOW(), '', NULL, 'AI 模型配置目录'),
(2061, 'Provider配置', 2060, 1, 'clinic/ai/provider', '', 'C', '0', '1', 'clinic:ai:provider:view', 'fa fa-plug', 'admin', NOW(), '', NULL, 'AI Provider 配置'),
(2062, 'Model配置', 2060, 2, 'clinic/ai/model', '', 'C', '0', '1', 'clinic:ai:model:view', 'fa fa-cube', 'admin', NOW(), '', NULL, 'AI Model 配置'),
(2063, '场景绑定', 2060, 3, 'clinic/ai/scene', '', 'C', '0', '1', 'clinic:ai:scene:view', 'fa fa-random', 'admin', NOW(), '', NULL, 'AI 场景绑定'),
(2064, 'Provider查询', 2061, 1, '', '', 'F', '0', '1', 'clinic:ai:provider:list', '#', 'admin', NOW(), '', NULL, ''),
(2065, 'Provider新增', 2061, 2, '', '', 'F', '0', '1', 'clinic:ai:provider:add', '#', 'admin', NOW(), '', NULL, ''),
(2066, 'Provider修改', 2061, 3, '', '', 'F', '0', '1', 'clinic:ai:provider:edit', '#', 'admin', NOW(), '', NULL, ''),
(2067, 'Provider删除', 2061, 4, '', '', 'F', '0', '1', 'clinic:ai:provider:remove', '#', 'admin', NOW(), '', NULL, ''),
(2068, 'Provider测试', 2061, 5, '', '', 'F', '0', '1', 'clinic:ai:provider:test', '#', 'admin', NOW(), '', NULL, ''),
(2069, 'Model查询', 2062, 1, '', '', 'F', '0', '1', 'clinic:ai:model:list', '#', 'admin', NOW(), '', NULL, ''),
(2070, 'Model新增', 2062, 2, '', '', 'F', '0', '1', 'clinic:ai:model:add', '#', 'admin', NOW(), '', NULL, ''),
(2071, 'Model修改', 2062, 3, '', '', 'F', '0', '1', 'clinic:ai:model:edit', '#', 'admin', NOW(), '', NULL, ''),
(2072, 'Model删除', 2062, 4, '', '', 'F', '0', '1', 'clinic:ai:model:remove', '#', 'admin', NOW(), '', NULL, ''),
(2073, '场景查询', 2063, 1, '', '', 'F', '0', '1', 'clinic:ai:scene:list', '#', 'admin', NOW(), '', NULL, ''),
(2074, '场景新增', 2063, 2, '', '', 'F', '0', '1', 'clinic:ai:scene:add', '#', 'admin', NOW(), '', NULL, ''),
(2075, '场景修改', 2063, 3, '', '', 'F', '0', '1', 'clinic:ai:scene:edit', '#', 'admin', NOW(), '', NULL, ''),
(2076, '场景删除', 2063, 4, '', '', 'F', '0', '1', 'clinic:ai:scene:remove', '#', 'admin', NOW(), '', NULL, '');

INSERT IGNORE INTO sys_role_menu (role_id, menu_id) VALUES
(1, 2060), (1, 2061), (1, 2062), (1, 2063), (1, 2064), (1, 2065), (1, 2066), (1, 2067), (1, 2068),
(1, 2069), (1, 2070), (1, 2071), (1, 2072), (1, 2073), (1, 2074), (1, 2075), (1, 2076),
(2, 2060), (2, 2061), (2, 2062), (2, 2063), (2, 2064), (2, 2065), (2, 2066), (2, 2067), (2, 2068),
(2, 2069), (2, 2070), (2, 2071), (2, 2072), (2, 2073), (2, 2074), (2, 2075), (2, 2076);

-- 2026-04-04 medicine recognition ai seed
INSERT INTO clinic_ai_provider (provider_code, provider_name, api_base_url, api_key, enabled, remark, create_by, create_time, update_by, update_time)
SELECT 'openai', 'OpenAI 兼容服务', '', '', 0, '请先配置 apiBaseUrl 与 apiKey，再启用服务商。', 'system', NOW(), 'system', NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM clinic_ai_provider WHERE provider_code = 'openai');

INSERT INTO clinic_ai_provider (provider_code, provider_name, api_base_url, api_key, enabled, remark, create_by, create_time, update_by, update_time)
SELECT 'minimax', 'MiniMax', '', '', 0, '请先配置 apiBaseUrl 与 apiKey，再启用服务商。', 'system', NOW(), 'system', NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM clinic_ai_provider WHERE provider_code = 'minimax');

INSERT INTO clinic_ai_model (provider_id, model_code, model_name, supports_vision, supports_web_search, supports_json_schema, enabled, remark, create_by, create_time, update_by, update_time)
SELECT p.provider_id, 'gpt-5.4', 'gpt-5.4', 1, 1, 1, 0, '默认初始化模型。', 'system', NOW(), 'system', NOW()
FROM clinic_ai_provider p
WHERE p.provider_code = 'openai'
  AND NOT EXISTS (SELECT 1 FROM clinic_ai_model m WHERE m.provider_id = p.provider_id AND m.model_code = 'gpt-5.4');

INSERT INTO clinic_ai_model (provider_id, model_code, model_name, supports_vision, supports_web_search, supports_json_schema, enabled, remark, create_by, create_time, update_by, update_time)
SELECT p.provider_id, 'minimax-M2.7', 'minimax-M2.7', 1, 1, 1, 0, '默认初始化模型。', 'system', NOW(), 'system', NOW()
FROM clinic_ai_provider p
WHERE p.provider_code = 'minimax'
  AND NOT EXISTS (SELECT 1 FROM clinic_ai_model m WHERE m.provider_id = p.provider_id AND m.model_code = 'minimax-M2.7');

INSERT INTO clinic_ai_scene_binding (scene_code, scene_name, execution_mode, primary_model_id, fallback_model_id, candidate_limit, timeout_ms, enabled, remark, create_by, create_time, update_by, update_time)
SELECT 'medicine_create_code', '药品建档-扫码识别', 'local_then_model', pm.model_id, fm.model_id, 3, 15000, 1, '默认建档扫码识别场景。', 'system', NOW(), 'system', NOW()
FROM (SELECT 1) seed
LEFT JOIN clinic_ai_model pm ON pm.model_code = 'gpt-5.4'
LEFT JOIN clinic_ai_model fm ON fm.model_code = 'minimax-M2.7'
WHERE NOT EXISTS (SELECT 1 FROM clinic_ai_scene_binding WHERE scene_code = 'medicine_create_code');

INSERT INTO clinic_ai_scene_binding (scene_code, scene_name, execution_mode, primary_model_id, fallback_model_id, candidate_limit, timeout_ms, enabled, remark, create_by, create_time, update_by, update_time)
SELECT 'medicine_create_image', '药品建档-图片识别', 'model_only', pm.model_id, fm.model_id, 3, 15000, 1, '默认建档图片识别场景。', 'system', NOW(), 'system', NOW()
FROM (SELECT 1) seed
LEFT JOIN clinic_ai_model pm ON pm.model_code = 'gpt-5.4'
LEFT JOIN clinic_ai_model fm ON fm.model_code = 'minimax-M2.7'
WHERE NOT EXISTS (SELECT 1 FROM clinic_ai_scene_binding WHERE scene_code = 'medicine_create_image');

INSERT INTO clinic_ai_scene_binding (scene_code, scene_name, execution_mode, primary_model_id, fallback_model_id, candidate_limit, timeout_ms, enabled, remark, create_by, create_time, update_by, update_time)
SELECT 'medicine_stock_in_code', '药品入库-扫码识别', 'local_only', NULL, NULL, 3, 15000, 1, '默认入库扫码识别场景。', 'system', NOW(), 'system', NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM clinic_ai_scene_binding WHERE scene_code = 'medicine_stock_in_code');

INSERT INTO clinic_ai_scene_binding (scene_code, scene_name, execution_mode, primary_model_id, fallback_model_id, candidate_limit, timeout_ms, enabled, remark, create_by, create_time, update_by, update_time)
SELECT 'medicine_stock_out_code', '药品出库-扫码识别', 'local_only', NULL, NULL, 3, 15000, 1, '默认出库扫码识别场景。', 'system', NOW(), 'system', NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM clinic_ai_scene_binding WHERE scene_code = 'medicine_stock_out_code');
