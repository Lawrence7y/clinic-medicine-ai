package com.ruoyi.framework.config;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import javax.sql.DataSource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
public class DatabaseUpdateConfig implements CommandLineRunner
{
    private static final Logger log = LoggerFactory.getLogger(DatabaseUpdateConfig.class);

    private static final String TABLE_MEDICINE = "clinic_medicine";
    private static final String TABLE_STOCK_BATCH = "clinic_stock_batch";
    private static final String TABLE_AI_PROVIDER = "clinic_ai_provider";
    private static final String TABLE_AI_MODEL = "clinic_ai_model";
    private static final String TABLE_AI_SCENE = "clinic_ai_scene_binding";
    private static final String TABLE_MENU = "sys_menu";
    private static final String TABLE_ROLE_MENU = "sys_role_menu";

    private final DataSource dataSource;

    public DatabaseUpdateConfig(DataSource dataSource)
    {
        this.dataSource = dataSource;
    }

    @Override
    public void run(String... args)
    {
        try (Connection connection = dataSource.getConnection())
        {
            if (!tableExists(connection, TABLE_MEDICINE))
            {
                log.warn("未找到表 {}，跳过药品结构迁移。", TABLE_MEDICINE);
                return;
            }

            ensureMedicineColumns(connection);
            ensureMedicineIndexes(connection);
            ensureStockBatchTable(connection);
            ensureAiProviderTable(connection);
            ensureAiModelTable(connection);
            ensureAiSceneTable(connection);
            seedDefaultMedicinesIfEmpty(connection);
            seedDefaultAiConfig(connection);
            ensureClinicAiMenus(connection);
            ensureClinicConfigMenus(connection);
        }
        catch (Exception e)
        {
            log.error("数据库自动更新失败。", e);
        }
    }

    private void ensureMedicineColumns(Connection connection) throws SQLException
    {
        ensureColumn(connection, TABLE_MEDICINE, "specification", "VARCHAR(255) NULL");
        ensureColumn(connection, TABLE_MEDICINE, "dosage_form", "VARCHAR(100) NULL");
        ensureColumn(connection, TABLE_MEDICINE, "form", "VARCHAR(100) NULL");
        ensureColumn(connection, TABLE_MEDICINE, "manufacturer", "VARCHAR(255) NULL");
        ensureColumn(connection, TABLE_MEDICINE, "barcode", "VARCHAR(64) NULL");
        ensureColumn(connection, TABLE_MEDICINE, "expiry_date", "DATE NULL");
        ensureColumn(connection, TABLE_MEDICINE, "price", "DECIMAL(10,2) NULL DEFAULT 0.00");
        ensureColumn(connection, TABLE_MEDICINE, "stock", "INT NULL DEFAULT 0");
        ensureColumn(connection, TABLE_MEDICINE, "warning_stock", "INT NULL DEFAULT 0");
        ensureColumn(connection, TABLE_MEDICINE, "warning_threshold", "INT NULL DEFAULT 0");
        ensureColumn(connection, TABLE_MEDICINE, "min_stock", "INT NULL DEFAULT 0");
        ensureColumn(connection, TABLE_MEDICINE, "unit", "VARCHAR(50) NULL");
        ensureColumn(connection, TABLE_MEDICINE, "pharmacology", "VARCHAR(500) NULL");
        ensureColumn(connection, TABLE_MEDICINE, "indications", "VARCHAR(1000) NULL");
        ensureColumn(connection, TABLE_MEDICINE, "dosage", "VARCHAR(1000) NULL");
        ensureColumn(connection, TABLE_MEDICINE, "side_effects", "VARCHAR(1000) NULL");
        ensureColumn(connection, TABLE_MEDICINE, "storage", "VARCHAR(500) NULL");
        ensureColumn(connection, TABLE_MEDICINE, "status", "CHAR(1) NULL DEFAULT '0'");
        ensureColumn(connection, TABLE_MEDICINE, "is_prescription", "CHAR(1) NULL DEFAULT '0'");
        ensureColumn(connection, TABLE_MEDICINE, "category", "VARCHAR(100) NULL");
        ensureColumn(connection, TABLE_MEDICINE, "location", "VARCHAR(255) NULL");
        ensureColumn(connection, TABLE_MEDICINE, "remark", "VARCHAR(500) NULL");
        ensureColumn(connection, TABLE_MEDICINE, "create_by", "VARCHAR(64) NULL");
        ensureColumn(connection, TABLE_MEDICINE, "create_time", "DATETIME NULL");
        ensureColumn(connection, TABLE_MEDICINE, "update_by", "VARCHAR(64) NULL");
        ensureColumn(connection, TABLE_MEDICINE, "update_time", "DATETIME NULL");
    }

    private void ensureMedicineIndexes(Connection connection) throws SQLException
    {
        ensureIndex(connection, TABLE_MEDICINE, "idx_barcode",
            "CREATE INDEX idx_barcode ON clinic_medicine(barcode)");
    }

    private void ensureStockBatchTable(Connection connection) throws SQLException
    {
        if (tableExists(connection, TABLE_STOCK_BATCH))
        {
            ensureColumn(connection, TABLE_STOCK_BATCH, "remaining_quantity", "INT NOT NULL DEFAULT 0");
            ensureColumn(connection, TABLE_STOCK_BATCH, "update_time", "DATETIME NULL");
            return;
        }

        String sql = "CREATE TABLE clinic_stock_batch ("
            + "batch_id BIGINT(20) NOT NULL AUTO_INCREMENT,"
            + "medicine_id BIGINT(20) NOT NULL,"
            + "batch_number VARCHAR(50) NOT NULL,"
            + "expiry_date DATE NOT NULL,"
            + "remaining_quantity INT NOT NULL DEFAULT 0,"
            + "create_time DATETIME NULL,"
            + "update_time DATETIME NULL,"
            + "PRIMARY KEY (batch_id),"
            + "UNIQUE KEY uk_medicine_batch_expiry (medicine_id, batch_number, expiry_date),"
            + "KEY idx_medicine_expiry (medicine_id, expiry_date)"
            + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
        try (Statement statement = connection.createStatement())
        {
            statement.execute(sql);
            log.info("已创建表 {}。", TABLE_STOCK_BATCH);
        }
    }

    private void ensureAiProviderTable(Connection connection) throws SQLException
    {
        if (!tableExists(connection, TABLE_AI_PROVIDER))
        {
            String sql = "CREATE TABLE clinic_ai_provider ("
                + "provider_id BIGINT(20) NOT NULL AUTO_INCREMENT,"
                + "provider_code VARCHAR(64) NOT NULL,"
                + "provider_name VARCHAR(128) NOT NULL,"
                + "api_base_url VARCHAR(255) NULL,"
                + "api_key VARCHAR(512) NULL,"
                + "enabled TINYINT(1) NOT NULL DEFAULT 1,"
                + "remark VARCHAR(500) NULL,"
                + "create_by VARCHAR(64) NULL,"
                + "create_time DATETIME NULL,"
                + "update_by VARCHAR(64) NULL,"
                + "update_time DATETIME NULL,"
                + "PRIMARY KEY (provider_id),"
                + "UNIQUE KEY uk_provider_code (provider_code)"
                + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
            try (Statement statement = connection.createStatement())
            {
                statement.execute(sql);
                log.info("已创建表 {}。", TABLE_AI_PROVIDER);
            }
        }
        else
        {
            ensureColumn(connection, TABLE_AI_PROVIDER, "provider_code", "VARCHAR(64) NOT NULL");
            ensureColumn(connection, TABLE_AI_PROVIDER, "provider_name", "VARCHAR(128) NOT NULL");
            ensureColumn(connection, TABLE_AI_PROVIDER, "api_base_url", "VARCHAR(255) NULL");
            ensureColumn(connection, TABLE_AI_PROVIDER, "api_key", "VARCHAR(512) NULL");
            ensureColumn(connection, TABLE_AI_PROVIDER, "enabled", "TINYINT(1) NOT NULL DEFAULT 1");
            ensureColumn(connection, TABLE_AI_PROVIDER, "remark", "VARCHAR(500) NULL");
            ensureColumn(connection, TABLE_AI_PROVIDER, "create_by", "VARCHAR(64) NULL");
            ensureColumn(connection, TABLE_AI_PROVIDER, "create_time", "DATETIME NULL");
            ensureColumn(connection, TABLE_AI_PROVIDER, "update_by", "VARCHAR(64) NULL");
            ensureColumn(connection, TABLE_AI_PROVIDER, "update_time", "DATETIME NULL");
        }
    }

    private void ensureAiModelTable(Connection connection) throws SQLException
    {
        if (!tableExists(connection, TABLE_AI_MODEL))
        {
            String sql = "CREATE TABLE clinic_ai_model ("
                + "model_id BIGINT(20) NOT NULL AUTO_INCREMENT,"
                + "provider_id BIGINT(20) NOT NULL,"
                + "model_code VARCHAR(128) NOT NULL,"
                + "model_name VARCHAR(128) NOT NULL,"
                + "supports_vision TINYINT(1) NOT NULL DEFAULT 0,"
                + "supports_web_search TINYINT(1) NOT NULL DEFAULT 0,"
                + "supports_json_schema TINYINT(1) NOT NULL DEFAULT 0,"
                + "enabled TINYINT(1) NOT NULL DEFAULT 1,"
                + "remark VARCHAR(500) NULL,"
                + "create_by VARCHAR(64) NULL,"
                + "create_time DATETIME NULL,"
                + "update_by VARCHAR(64) NULL,"
                + "update_time DATETIME NULL,"
                + "PRIMARY KEY (model_id),"
                + "KEY idx_provider_id (provider_id)"
                + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
            try (Statement statement = connection.createStatement())
            {
                statement.execute(sql);
                log.info("已创建表 {}。", TABLE_AI_MODEL);
            }
        }
        else
        {
            ensureColumn(connection, TABLE_AI_MODEL, "provider_id", "BIGINT(20) NOT NULL");
            ensureColumn(connection, TABLE_AI_MODEL, "model_code", "VARCHAR(128) NOT NULL");
            ensureColumn(connection, TABLE_AI_MODEL, "model_name", "VARCHAR(128) NOT NULL");
            ensureColumn(connection, TABLE_AI_MODEL, "supports_vision", "TINYINT(1) NOT NULL DEFAULT 0");
            ensureColumn(connection, TABLE_AI_MODEL, "supports_web_search", "TINYINT(1) NOT NULL DEFAULT 0");
            ensureColumn(connection, TABLE_AI_MODEL, "supports_json_schema", "TINYINT(1) NOT NULL DEFAULT 0");
            ensureColumn(connection, TABLE_AI_MODEL, "enabled", "TINYINT(1) NOT NULL DEFAULT 1");
            ensureColumn(connection, TABLE_AI_MODEL, "remark", "VARCHAR(500) NULL");
            ensureColumn(connection, TABLE_AI_MODEL, "create_by", "VARCHAR(64) NULL");
            ensureColumn(connection, TABLE_AI_MODEL, "create_time", "DATETIME NULL");
            ensureColumn(connection, TABLE_AI_MODEL, "update_by", "VARCHAR(64) NULL");
            ensureColumn(connection, TABLE_AI_MODEL, "update_time", "DATETIME NULL");
        }
    }

    private void ensureAiSceneTable(Connection connection) throws SQLException
    {
        if (!tableExists(connection, TABLE_AI_SCENE))
        {
            String sql = "CREATE TABLE clinic_ai_scene_binding ("
                + "scene_id BIGINT(20) NOT NULL AUTO_INCREMENT,"
                + "scene_code VARCHAR(64) NOT NULL,"
                + "scene_name VARCHAR(128) NOT NULL,"
                + "execution_mode VARCHAR(32) NOT NULL,"
                + "primary_model_id BIGINT(20) NULL,"
                + "fallback_model_id BIGINT(20) NULL,"
                + "candidate_limit INT NOT NULL DEFAULT 3,"
                + "timeout_ms INT NOT NULL DEFAULT 15000,"
                + "enabled TINYINT(1) NOT NULL DEFAULT 1,"
                + "remark VARCHAR(500) NULL,"
                + "create_by VARCHAR(64) NULL,"
                + "create_time DATETIME NULL,"
                + "update_by VARCHAR(64) NULL,"
                + "update_time DATETIME NULL,"
                + "PRIMARY KEY (scene_id),"
                + "UNIQUE KEY uk_scene_code (scene_code)"
                + ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
            try (Statement statement = connection.createStatement())
            {
                statement.execute(sql);
                log.info("已创建表 {}。", TABLE_AI_SCENE);
            }
        }
        else
        {
            ensureColumn(connection, TABLE_AI_SCENE, "scene_code", "VARCHAR(64) NOT NULL");
            ensureColumn(connection, TABLE_AI_SCENE, "scene_name", "VARCHAR(128) NOT NULL");
            ensureColumn(connection, TABLE_AI_SCENE, "execution_mode", "VARCHAR(32) NOT NULL");
            ensureColumn(connection, TABLE_AI_SCENE, "primary_model_id", "BIGINT(20) NULL");
            ensureColumn(connection, TABLE_AI_SCENE, "fallback_model_id", "BIGINT(20) NULL");
            ensureColumn(connection, TABLE_AI_SCENE, "candidate_limit", "INT NOT NULL DEFAULT 3");
            ensureColumn(connection, TABLE_AI_SCENE, "timeout_ms", "INT NOT NULL DEFAULT 15000");
            ensureColumn(connection, TABLE_AI_SCENE, "enabled", "TINYINT(1) NOT NULL DEFAULT 1");
            ensureColumn(connection, TABLE_AI_SCENE, "remark", "VARCHAR(500) NULL");
            ensureColumn(connection, TABLE_AI_SCENE, "create_by", "VARCHAR(64) NULL");
            ensureColumn(connection, TABLE_AI_SCENE, "create_time", "DATETIME NULL");
            ensureColumn(connection, TABLE_AI_SCENE, "update_by", "VARCHAR(64) NULL");
            ensureColumn(connection, TABLE_AI_SCENE, "update_time", "DATETIME NULL");
        }
    }

    private void ensureClinicConfigMenus(Connection connection) throws SQLException
    {
        if (!tableExists(connection, TABLE_MENU) || !tableExists(connection, TABLE_ROLE_MENU))
        {
            return;
        }

        Long clinicRootMenuId = queryClinicRootMenuId(connection);
        if (clinicRootMenuId == null)
        {
            log.warn("未找到诊所管理根菜单，跳过系统配置菜单迁移。");
            return;
        }

        Long configMenuId = ensureMenu(connection, clinicRootMenuId, "系统配置", "clinic/config",
            "C", "clinic:config:view", "fa fa-cogs", 8, "诊所系统配置菜单");
        Long editButtonId = ensureMenu(connection, configMenuId, "系统配置修改", "",
            "F", "clinic:config:edit", "#", 1, "诊所系统配置修改按钮");

        grantMenuToRoleIfExists(connection, 1L, configMenuId);
        grantMenuToRoleIfExists(connection, 1L, editButtonId);
        grantMenuToRoleIfExists(connection, 2L, configMenuId);
        grantMenuToRoleIfExists(connection, 2L, editButtonId);
    }

    private void ensureClinicAiMenus(Connection connection) throws SQLException
    {
        if (!tableExists(connection, TABLE_MENU) || !tableExists(connection, TABLE_ROLE_MENU))
        {
            return;
        }

        Long clinicRootMenuId = queryClinicRootMenuId(connection);
        if (clinicRootMenuId == null)
        {
            log.warn("未找到诊所管理根菜单，跳过 AI 菜单迁移。");
            return;
        }

        Long assistantMenuId = ensureMenu(connection, clinicRootMenuId, "AI 助手", "clinic/ai/assistant",
            "C", "clinic:ai:assistant:view", "fa fa-robot", 6, "AI 助手独立入口");
        Long aiConfigRootId = ensureAiRootMenu(connection, clinicRootMenuId);
        Long providerMenuId = ensureMenu(connection, aiConfigRootId, "服务商配置", "clinic/ai/provider",
            "C", "clinic:ai:provider:view", "fa fa-plug", 1, "AI 服务商配置");
        Long modelMenuId = ensureMenu(connection, aiConfigRootId, "模型配置", "clinic/ai/model",
            "C", "clinic:ai:model:view", "fa fa-cube", 2, "AI 模型配置");
        Long sceneMenuId = ensureMenu(connection, aiConfigRootId, "场景绑定", "clinic/ai/scene",
            "C", "clinic:ai:scene:view", "fa fa-random", 3, "AI 场景绑定配置");

        Long providerListButtonId = ensureMenu(connection, providerMenuId, "服务商查询", "",
            "F", "clinic:ai:provider:list", "#", 1, "AI 服务商查询按钮");
        Long providerAddButtonId = ensureMenu(connection, providerMenuId, "服务商新增", "",
            "F", "clinic:ai:provider:add", "#", 2, "AI 服务商新增按钮");
        Long providerEditButtonId = ensureMenu(connection, providerMenuId, "服务商修改", "",
            "F", "clinic:ai:provider:edit", "#", 3, "AI 服务商修改按钮");
        Long providerRemoveButtonId = ensureMenu(connection, providerMenuId, "服务商删除", "",
            "F", "clinic:ai:provider:remove", "#", 4, "AI 服务商删除按钮");
        Long providerTestButtonId = ensureMenu(connection, providerMenuId, "服务商测试", "",
            "F", "clinic:ai:provider:test", "#", 5, "AI 服务商测试按钮");

        Long modelListButtonId = ensureMenu(connection, modelMenuId, "模型查询", "",
            "F", "clinic:ai:model:list", "#", 1, "AI 模型查询按钮");
        Long modelAddButtonId = ensureMenu(connection, modelMenuId, "模型新增", "",
            "F", "clinic:ai:model:add", "#", 2, "AI 模型新增按钮");
        Long modelEditButtonId = ensureMenu(connection, modelMenuId, "模型修改", "",
            "F", "clinic:ai:model:edit", "#", 3, "AI 模型修改按钮");
        Long modelRemoveButtonId = ensureMenu(connection, modelMenuId, "模型删除", "",
            "F", "clinic:ai:model:remove", "#", 4, "AI 模型删除按钮");

        Long sceneListButtonId = ensureMenu(connection, sceneMenuId, "场景查询", "",
            "F", "clinic:ai:scene:list", "#", 1, "AI 场景查询按钮");
        Long sceneAddButtonId = ensureMenu(connection, sceneMenuId, "场景新增", "",
            "F", "clinic:ai:scene:add", "#", 2, "AI 场景新增按钮");
        Long sceneEditButtonId = ensureMenu(connection, sceneMenuId, "场景修改", "",
            "F", "clinic:ai:scene:edit", "#", 3, "AI 场景修改按钮");
        Long sceneRemoveButtonId = ensureMenu(connection, sceneMenuId, "场景删除", "",
            "F", "clinic:ai:scene:remove", "#", 4, "AI 场景删除按钮");

        Long[] adminMenus = new Long[] {
            assistantMenuId, aiConfigRootId, providerMenuId, modelMenuId, sceneMenuId,
            providerListButtonId, providerAddButtonId, providerEditButtonId, providerRemoveButtonId, providerTestButtonId,
            modelListButtonId, modelAddButtonId, modelEditButtonId, modelRemoveButtonId,
            sceneListButtonId, sceneAddButtonId, sceneEditButtonId, sceneRemoveButtonId
        };
        for (Long menuId : adminMenus)
        {
            grantMenuToRoleIfExists(connection, 1L, menuId);
            grantMenuToRoleIfExists(connection, 2L, menuId);
        }
    }

    private Long ensureAiRootMenu(Connection connection, Long clinicRootMenuId) throws SQLException
    {
        Long menuId = querySingleLong(connection,
            "SELECT parent_id FROM sys_menu WHERE perms = ? LIMIT 1", "clinic:ai:provider:view");
        if (menuId == null)
        {
            menuId = querySingleLong(connection,
                "SELECT menu_id FROM sys_menu WHERE parent_id = ? AND menu_name IN (?, ?, ?) LIMIT 1",
                clinicRootMenuId, "AI模型配置", "AI 配置", "AI 管理");
        }
        if (menuId == null)
        {
            menuId = nextMenuId(connection);
            insertMenu(connection, menuId, clinicRootMenuId, "AI 配置", "#",
                "M", "", "fa fa-sliders", 7, "AI 配置入口");
            return menuId;
        }
        updateMenu(connection, menuId, clinicRootMenuId, "AI 配置", "#",
            "M", "", "fa fa-sliders", 7, "AI 配置入口");
        return menuId;
    }

    private Long queryClinicRootMenuId(Connection connection) throws SQLException
    {
        Long rootByChild = querySingleLong(connection,
            "SELECT parent_id FROM sys_menu WHERE url = ? LIMIT 1", "clinic/medicine");
        if (rootByChild != null && rootByChild > 0)
        {
            return rootByChild;
        }
        return querySingleLong(connection,
            "SELECT menu_id FROM sys_menu WHERE menu_name = ? AND menu_type = 'M' LIMIT 1", "诊所管理");
    }

    private Long ensureMenu(Connection connection, Long parentId, String menuName, String url, String menuType,
        String perms, String icon, int orderNum, String remark) throws SQLException
    {
        Long menuId = querySingleLong(connection, "SELECT menu_id FROM sys_menu WHERE perms = ? LIMIT 1", perms);
        if (menuId == null && url != null && !url.isEmpty())
        {
            menuId = querySingleLong(connection,
                "SELECT menu_id FROM sys_menu WHERE parent_id = ? AND url = ? LIMIT 1", parentId, url);
        }
        if (menuId == null)
        {
            menuId = nextMenuId(connection);
            insertMenu(connection, menuId, parentId, menuName, url, menuType, perms, icon, orderNum, remark);
        }
        else
        {
            updateMenu(connection, menuId, parentId, menuName, url, menuType, perms, icon, orderNum, remark);
        }
        return menuId;
    }

    private void insertMenu(Connection connection, Long menuId, Long parentId, String menuName, String url,
        String menuType, String perms, String icon, int orderNum, String remark) throws SQLException
    {
        String sql = "INSERT INTO sys_menu "
            + "(menu_id, menu_name, parent_id, order_num, url, target, menu_type, visible, is_refresh, perms, icon, create_by, create_time, remark) "
            + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement insert = connection.prepareStatement(sql))
        {
            insert.setLong(1, menuId);
            insert.setString(2, menuName);
            insert.setLong(3, parentId);
            insert.setInt(4, orderNum);
            insert.setString(5, url != null && !url.isEmpty() ? url : "#");
            insert.setString(6, "");
            insert.setString(7, menuType);
            insert.setString(8, "0");
            insert.setString(9, "1");
            insert.setString(10, perms);
            insert.setString(11, icon);
            insert.setString(12, "system");
            insert.setTimestamp(13, new Timestamp(System.currentTimeMillis()));
            insert.setString(14, remark);
            insert.executeUpdate();
            log.info("Inserted menu {}({}).", menuName, menuId);
        }
    }

    private void updateMenu(Connection connection, Long menuId, Long parentId, String menuName, String url,
        String menuType, String perms, String icon, int orderNum, String remark) throws SQLException
    {
        String sql = "UPDATE sys_menu SET menu_name = ?, parent_id = ?, order_num = ?, url = ?, target = ?, "
            + "menu_type = ?, visible = ?, is_refresh = ?, perms = ?, icon = ?, update_by = ?, update_time = ?, remark = ? "
            + "WHERE menu_id = ?";
        try (PreparedStatement update = connection.prepareStatement(sql))
        {
            update.setString(1, menuName);
            update.setLong(2, parentId);
            update.setInt(3, orderNum);
            update.setString(4, url != null && !url.isEmpty() ? url : "#");
            update.setString(5, "");
            update.setString(6, menuType);
            update.setString(7, "0");
            update.setString(8, "1");
            update.setString(9, perms);
            update.setString(10, icon);
            update.setString(11, "system");
            update.setTimestamp(12, new Timestamp(System.currentTimeMillis()));
            update.setString(13, remark);
            update.setLong(14, menuId);
            update.executeUpdate();
        }
    }

    private void grantMenuToRoleIfExists(Connection connection, Long roleId, Long menuId) throws SQLException
    {
        if (roleId == null || menuId == null || !roleExists(connection, roleId) || roleMenuExists(connection, roleId, menuId))
        {
            return;
        }
        String sql = "INSERT INTO sys_role_menu (role_id, menu_id) VALUES (?, ?)";
        try (PreparedStatement insert = connection.prepareStatement(sql))
        {
            insert.setLong(1, roleId);
            insert.setLong(2, menuId);
            insert.executeUpdate();
        }
    }

    private boolean roleExists(Connection connection, Long roleId) throws SQLException
    {
        return querySingleLong(connection, "SELECT role_id FROM sys_role WHERE role_id = ? LIMIT 1", roleId) != null;
    }

    private boolean roleMenuExists(Connection connection, Long roleId, Long menuId) throws SQLException
    {
        return querySingleLong(connection,
            "SELECT role_id FROM sys_role_menu WHERE role_id = ? AND menu_id = ? LIMIT 1", roleId, menuId) != null;
    }

    private Long nextMenuId(Connection connection) throws SQLException
    {
        Long maxId = querySingleLong(connection, "SELECT MAX(menu_id) FROM sys_menu");
        return maxId == null ? 1L : maxId + 1L;
    }

    private Long querySingleLong(Connection connection, String sql, Object... params) throws SQLException
    {
        try (PreparedStatement statement = connection.prepareStatement(sql))
        {
            if (params != null)
            {
                for (int i = 0; i < params.length; i++)
                {
                    statement.setObject(i + 1, params[i]);
                }
            }
            try (ResultSet rs = statement.executeQuery())
            {
                if (rs.next())
                {
                    long value = rs.getLong(1);
                    return rs.wasNull() ? null : value;
                }
            }
        }
        return null;
    }

    private void ensureColumn(Connection connection, String tableName, String columnName, String definition)
        throws SQLException
    {
        if (columnExists(connection, tableName, columnName))
        {
            return;
        }
        String sql = "ALTER TABLE " + tableName + " ADD COLUMN " + columnName + " " + definition;
        try (Statement statement = connection.createStatement())
        {
            statement.execute(sql);
            log.info("Added missing column {}.{}.", tableName, columnName);
        }
    }

    private void ensureIndex(Connection connection, String tableName, String indexName, String createSql)
        throws SQLException
    {
        if (indexExists(connection, tableName, indexName))
        {
            return;
        }
        try (Statement statement = connection.createStatement())
        {
            statement.execute(createSql);
            log.info("已为表 {} 补齐缺失索引 {}。", tableName, indexName);
        }
    }

    private boolean tableExists(Connection connection, String tableName) throws SQLException
    {
        DatabaseMetaData metaData = connection.getMetaData();
        String catalog = connection.getCatalog();
        String schema = connection.getSchema();
        try (ResultSet rs = metaData.getTables(catalog, schema, tableName, new String[] { "TABLE" }))
        {
            if (rs.next())
            {
                return true;
            }
        }
        try (ResultSet rs = metaData.getTables(catalog, schema, tableName.toUpperCase(), new String[] { "TABLE" }))
        {
            if (rs.next())
            {
                return true;
            }
        }
        try (ResultSet rs = metaData.getTables(catalog, schema, tableName.toLowerCase(), new String[] { "TABLE" }))
        {
            return rs.next();
        }
    }

    private boolean columnExists(Connection connection, String tableName, String columnName) throws SQLException
    {
        DatabaseMetaData metaData = connection.getMetaData();
        String catalog = connection.getCatalog();
        String schema = connection.getSchema();
        try (ResultSet rs = metaData.getColumns(catalog, schema, tableName, columnName))
        {
            if (rs.next())
            {
                return true;
            }
        }
        try (ResultSet rs = metaData.getColumns(catalog, schema, tableName.toUpperCase(), columnName.toUpperCase()))
        {
            if (rs.next())
            {
                return true;
            }
        }
        try (ResultSet rs = metaData.getColumns(catalog, schema, tableName.toLowerCase(), columnName.toLowerCase()))
        {
            return rs.next();
        }
    }

    private boolean indexExists(Connection connection, String tableName, String indexName) throws SQLException
    {
        DatabaseMetaData metaData = connection.getMetaData();
        String catalog = connection.getCatalog();
        String schema = connection.getSchema();
        try (ResultSet rs = metaData.getIndexInfo(catalog, schema, tableName, false, false))
        {
            while (rs.next())
            {
                String currentIndexName = rs.getString("INDEX_NAME");
                if (indexName.equalsIgnoreCase(currentIndexName))
                {
                    return true;
                }
            }
        }
        return false;
    }

    private void seedDefaultMedicinesIfEmpty(Connection connection) throws SQLException
    {
        String countSql = "SELECT COUNT(*) FROM " + TABLE_MEDICINE;
        try (PreparedStatement countStatement = connection.prepareStatement(countSql);
            ResultSet rs = countStatement.executeQuery())
        {
            if (!rs.next() || rs.getInt(1) > 0)
            {
                return;
            }
        }

        String insertSql = "INSERT INTO clinic_medicine "
            + "(name, specification, dosage_form, form, manufacturer, expiry_date, price, stock, warning_stock, "
            + "warning_threshold, min_stock, unit, pharmacology, indications, dosage, side_effects, storage, "
            + "status, is_prescription, category, create_by, create_time, remark) "
            + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement insert = connection.prepareStatement(insertSql))
        {
            insertMedicine(insert, "阿莫西林胶囊", "0.25g*24", "口服", "胶囊",
                "系统默认药厂", new java.sql.Date(System.currentTimeMillis() + 365L * 24 * 3600 * 1000),
                new BigDecimal("18.50"), 120, 20, 20, 10, "盒",
                "β-内酰胺类抗生素", "细菌感染", "每次0.5g，每日3次",
                "可能出现皮疹或轻度胃肠不适", "阴凉干燥处保存",
                "0", "1", "抗感染", "system", "系统初始化数据");

            insertMedicine(insert, "布洛芬缓释胶囊", "0.3g*20", "口服", "胶囊",
                "系统默认药厂", new java.sql.Date(System.currentTimeMillis() + 540L * 24 * 3600 * 1000),
                new BigDecimal("22.00"), 160, 30, 30, 15, "盒",
                "解热镇痛抗炎", "轻中度疼痛或发热", "必要时每12小时1粒",
                "可能出现胃部不适或头晕", "避光防潮保存", "0", "0", "镇痛", "system", "系统初始化数据");
            log.info("因表 {} 为空，已写入默认药品数据。", TABLE_MEDICINE);
        }
    }

    private void seedDefaultAiConfig(Connection connection) throws SQLException
    {
        insertAiProviderIfMissing(connection, "openai", "OpenAI 兼容服务");
        insertAiProviderIfMissing(connection, "minimax", "MiniMax");

        Long openAiProviderId = queryIdByCode(connection, TABLE_AI_PROVIDER, "provider_id", "provider_code", "openai");
        Long miniMaxProviderId = queryIdByCode(connection, TABLE_AI_PROVIDER, "provider_id", "provider_code", "minimax");

        Long openAiModelId = insertAiModelIfMissing(connection, openAiProviderId, "gpt-5.4", "gpt-5.4", 1, 1, 1);
        Long miniMaxModelId = insertAiModelIfMissing(connection, miniMaxProviderId, "minimax-M2.7", "minimax-M2.7", 1, 1, 1);
        Long preferredModelId = firstNonNull(queryFirstEnabledAiModelId(connection), openAiModelId, miniMaxModelId);
        Long fallbackModelId = firstDifferentNonNull(preferredModelId,
            queryFirstEnabledAiModelIdExcluding(connection, preferredModelId), openAiModelId, miniMaxModelId);

        renameAiSceneIfDefault(connection, "medicine_create_code", "Medicine Create Code", "药品新建-扫码识别", "默认药品新建扫码识别场景");
        renameAiSceneIfDefault(connection, "medicine_create_image", "Medicine Create Image", "药品新建-拍照识别", "默认药品新建拍照识别场景");
        renameAiSceneIfDefault(connection, "medicine_stock_in_code", "Medicine Stock In Code", "药品入库-扫码识别", "默认药品入库扫码识别场景");
        renameAiSceneIfDefault(connection, "medicine_stock_out_code", "Medicine Stock Out Code", "药品出库-扫码识别", "默认药品出库扫码识别场景");

        insertAiSceneIfMissing(connection, "medicine_create_code", "药品新建-扫码识别", "local_then_model",
            preferredModelId, fallbackModelId, 3, 15000, 1, "默认药品新建扫码识别场景");
        insertAiSceneIfMissing(connection, "medicine_create_image", "药品新建-拍照识别", "model_only",
            preferredModelId, fallbackModelId, 3, 90000, 1, "默认药品新建拍照识别场景");
        insertAiSceneIfMissing(connection, "medicine_create_ocr", "药品说明书 OCR 识别", "model_only",
            preferredModelId, fallbackModelId, 3, 90000, 1, "默认药品说明书 OCR 识别场景");
        insertAiSceneIfMissing(connection, "medicine_create_package", "药品包装图识别", "model_only",
            preferredModelId, fallbackModelId, 3, 90000, 1, "默认药品包装图识别场景");
        insertAiSceneIfMissing(connection, "medicine_create_multi_image", "药品多图识别", "model_only",
            preferredModelId, fallbackModelId, 3, 90000, 1, "默认药品多图识别场景");
        insertAiSceneIfMissing(connection, "medicine_create_voice_text", "药品语音转写识别", "model_only",
            preferredModelId, fallbackModelId, 3, 30000, 1, "默认药品语音转写识别场景");
        insertAiSceneIfMissing(connection, "medicine_stock_in_code", "药品入库-扫码识别", "local_only",
            null, null, 3, 15000, 1, "默认药品入库扫码识别场景");
        insertAiSceneIfMissing(connection, "medicine_stock_out_code", "药品出库-扫码识别", "local_only",
            null, null, 3, 15000, 1, "默认药品出库扫码识别场景");
        insertAiSceneIfMissing(connection, "clinic_ai_chat", "AI 助手对话", "model_only",
            preferredModelId, fallbackModelId, 3, 30000, 1, "默认 AI 助手对话场景");
        insertAiSceneIfMissing(connection, "clinic_ai_medical_assistant", "AI 病历助手", "model_only",
            preferredModelId, fallbackModelId, 3, 30000, 1, "默认 AI 病历助手场景");
        insertAiSceneIfMissing(connection, "clinic_ai_medicine_assistant", "AI 药品助手", "model_only",
            preferredModelId, fallbackModelId, 3, 30000, 1, "默认 AI 药品助手场景");
        insertAiSceneIfMissing(connection, "clinic_ai_operations_assistant", "AI 运营助手", "model_only",
            preferredModelId, fallbackModelId, 3, 30000, 1, "默认 AI 运营助手场景");

        ensureAiSceneModelIfNull(connection, "medicine_create_code", preferredModelId, fallbackModelId);
        ensureAiSceneModelIfNull(connection, "medicine_create_image", preferredModelId, fallbackModelId);
        ensureAiSceneModelIfNull(connection, "medicine_create_ocr", preferredModelId, fallbackModelId);
        ensureAiSceneModelIfNull(connection, "medicine_create_package", preferredModelId, fallbackModelId);
        ensureAiSceneModelIfNull(connection, "medicine_create_multi_image", preferredModelId, fallbackModelId);
        ensureAiSceneModelIfNull(connection, "medicine_create_voice_text", preferredModelId, fallbackModelId);
        ensureAiSceneModelIfNull(connection, "clinic_ai_chat", preferredModelId, fallbackModelId);
        ensureAiSceneModelIfNull(connection, "clinic_ai_medical_assistant", preferredModelId, fallbackModelId);
        ensureAiSceneModelIfNull(connection, "clinic_ai_medicine_assistant", preferredModelId, fallbackModelId);
        ensureAiSceneModelIfNull(connection, "clinic_ai_operations_assistant", preferredModelId, fallbackModelId);
    }

    private void insertAiProviderIfMissing(Connection connection, String providerCode, String providerName)
        throws SQLException
    {
        if (queryIdByCode(connection, TABLE_AI_PROVIDER, "provider_id", "provider_code", providerCode) != null)
        {
            return;
        }
        String sql = "INSERT INTO clinic_ai_provider "
            + "(provider_code, provider_name, api_base_url, api_key, enabled, remark, create_by, create_time, update_by, update_time) "
            + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement insert = connection.prepareStatement(sql))
        {
            insert.setString(1, providerCode);
            insert.setString(2, providerName);
            insert.setString(3, "");
            insert.setString(4, "");
            insert.setInt(5, 0);
            insert.setString(6, "请先配置 apiBaseUrl 与 apiKey，再启用服务商。");
            insert.setString(7, "system");
            insert.setTimestamp(8, new Timestamp(System.currentTimeMillis()));
            insert.setString(9, "system");
            insert.setTimestamp(10, new Timestamp(System.currentTimeMillis()));
            insert.executeUpdate();
        }
    }

    private Long insertAiModelIfMissing(Connection connection, Long providerId, String modelCode, String modelName,
        int supportsVision, int supportsWebSearch, int supportsJsonSchema) throws SQLException
    {
        if (providerId == null)
        {
            return null;
        }
        String checkSql = "SELECT model_id FROM clinic_ai_model WHERE provider_id = ? AND model_code = ? LIMIT 1";
        try (PreparedStatement check = connection.prepareStatement(checkSql))
        {
            check.setLong(1, providerId);
            check.setString(2, modelCode);
            try (ResultSet rs = check.executeQuery())
            {
                if (rs.next())
                {
                    return rs.getLong(1);
                }
            }
        }

        String sql = "INSERT INTO clinic_ai_model "
            + "(provider_id, model_code, model_name, supports_vision, supports_web_search, supports_json_schema, enabled, remark, create_by, create_time, update_by, update_time) "
            + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement insert = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS))
        {
            insert.setLong(1, providerId);
            insert.setString(2, modelCode);
            insert.setString(3, modelName);
            insert.setInt(4, supportsVision);
            insert.setInt(5, supportsWebSearch);
            insert.setInt(6, supportsJsonSchema);
            insert.setInt(7, 0);
            insert.setString(8, "系统初始化默认模型。");
            insert.setString(9, "system");
            insert.setTimestamp(10, new Timestamp(System.currentTimeMillis()));
            insert.setString(11, "system");
            insert.setTimestamp(12, new Timestamp(System.currentTimeMillis()));
            insert.executeUpdate();
            try (ResultSet keys = insert.getGeneratedKeys())
            {
                if (keys.next())
                {
                    return keys.getLong(1);
                }
            }
        }
        return queryAiModelId(connection, providerId, modelCode);
    }

    private void insertAiSceneIfMissing(Connection connection, String sceneCode, String sceneName, String executionMode,
        Long primaryModelId, Long fallbackModelId, int candidateLimit, int timeoutMs, int enabled, String remark)
        throws SQLException
    {
        if (queryIdByCode(connection, TABLE_AI_SCENE, "scene_id", "scene_code", sceneCode) != null)
        {
            return;
        }
        String sql = "INSERT INTO clinic_ai_scene_binding "
            + "(scene_code, scene_name, execution_mode, primary_model_id, fallback_model_id, candidate_limit, timeout_ms, enabled, remark, create_by, create_time, update_by, update_time) "
            + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement insert = connection.prepareStatement(sql))
        {
            insert.setString(1, sceneCode);
            insert.setString(2, sceneName);
            insert.setString(3, executionMode);
            if (primaryModelId != null)
            {
                insert.setLong(4, primaryModelId);
            }
            else
            {
                insert.setNull(4, java.sql.Types.BIGINT);
            }
            if (fallbackModelId != null)
            {
                insert.setLong(5, fallbackModelId);
            }
            else
            {
                insert.setNull(5, java.sql.Types.BIGINT);
            }
            insert.setInt(6, candidateLimit);
            insert.setInt(7, timeoutMs);
            insert.setInt(8, enabled);
            insert.setString(9, remark);
            insert.setString(10, "system");
            insert.setTimestamp(11, new Timestamp(System.currentTimeMillis()));
            insert.setString(12, "system");
            insert.setTimestamp(13, new Timestamp(System.currentTimeMillis()));
            insert.executeUpdate();
        }
    }

    private void renameAiSceneIfDefault(Connection connection, String sceneCode, String oldSceneName, String newSceneName,
        String newRemark) throws SQLException
    {
        String sql = "UPDATE clinic_ai_scene_binding "
            + "SET scene_name = ?, remark = CASE WHEN remark IS NULL OR remark = '' THEN ? ELSE remark END "
            + "WHERE scene_code = ? AND (scene_name = ? OR scene_name IS NULL OR scene_name = '')";
        try (PreparedStatement update = connection.prepareStatement(sql))
        {
            update.setString(1, newSceneName);
            update.setString(2, newRemark);
            update.setString(3, sceneCode);
            update.setString(4, oldSceneName);
            update.executeUpdate();
        }
    }

    private void ensureAiSceneModelIfNull(Connection connection, String sceneCode, Long primaryModelId, Long fallbackModelId)
        throws SQLException
    {
        String sql = "UPDATE clinic_ai_scene_binding "
            + "SET primary_model_id = COALESCE(primary_model_id, ?), "
            + "fallback_model_id = COALESCE(fallback_model_id, ?), "
            + "update_by = ?, update_time = ? "
            + "WHERE scene_code = ?";
        try (PreparedStatement update = connection.prepareStatement(sql))
        {
            if (primaryModelId != null)
            {
                update.setLong(1, primaryModelId);
            }
            else
            {
                update.setNull(1, java.sql.Types.BIGINT);
            }
            if (fallbackModelId != null)
            {
                update.setLong(2, fallbackModelId);
            }
            else
            {
                update.setNull(2, java.sql.Types.BIGINT);
            }
            update.setString(3, "system");
            update.setTimestamp(4, new Timestamp(System.currentTimeMillis()));
            update.setString(5, sceneCode);
            update.executeUpdate();
        }
    }

    private Long queryFirstEnabledAiModelId(Connection connection) throws SQLException
    {
        return querySingleLong(connection,
            "SELECT m.model_id FROM clinic_ai_model m "
                + "LEFT JOIN clinic_ai_provider p ON p.provider_id = m.provider_id "
                + "WHERE m.enabled = 1 AND p.enabled = 1 ORDER BY m.model_id ASC LIMIT 1");
    }

    private Long queryFirstEnabledAiModelIdExcluding(Connection connection, Long excludedModelId) throws SQLException
    {
        if (excludedModelId == null)
        {
            return queryFirstEnabledAiModelId(connection);
        }
        return querySingleLong(connection,
            "SELECT m.model_id FROM clinic_ai_model m "
                + "LEFT JOIN clinic_ai_provider p ON p.provider_id = m.provider_id "
                + "WHERE m.enabled = 1 AND p.enabled = 1 AND m.model_id <> ? ORDER BY m.model_id ASC LIMIT 1",
            excludedModelId);
    }

    private Long firstNonNull(Long... values)
    {
        if (values == null)
        {
            return null;
        }
        for (Long value : values)
        {
            if (value != null)
            {
                return value;
            }
        }
        return null;
    }

    private Long firstDifferentNonNull(Long excludedValue, Long... values)
    {
        if (values == null)
        {
            return null;
        }
        for (Long value : values)
        {
            if (value != null && (excludedValue == null || !excludedValue.equals(value)))
            {
                return value;
            }
        }
        return null;
    }

    private Long queryIdByCode(Connection connection, String tableName, String idColumn, String codeColumn, String code)
        throws SQLException
    {
        String sql = "SELECT " + idColumn + " FROM " + tableName + " WHERE " + codeColumn + " = ? LIMIT 1";
        try (PreparedStatement statement = connection.prepareStatement(sql))
        {
            statement.setString(1, code);
            try (ResultSet rs = statement.executeQuery())
            {
                if (rs.next())
                {
                    return rs.getLong(1);
                }
            }
        }
        return null;
    }

    private Long queryAiModelId(Connection connection, Long providerId, String modelCode) throws SQLException
    {
        String sql = "SELECT model_id FROM clinic_ai_model WHERE provider_id = ? AND model_code = ? LIMIT 1";
        try (PreparedStatement statement = connection.prepareStatement(sql))
        {
            statement.setLong(1, providerId);
            statement.setString(2, modelCode);
            try (ResultSet rs = statement.executeQuery())
            {
                if (rs.next())
                {
                    return rs.getLong(1);
                }
            }
        }
        return null;
    }

    private void insertMedicine(PreparedStatement insert, String name, String specification, String dosageForm,
        String form, String manufacturer, java.sql.Date expiryDate, BigDecimal price, int stock, int warningStock,
        int warningThreshold, int minStock, String unit, String pharmacology, String indications, String dosage,
        String sideEffects, String storage, String status, String isPrescription, String category, String createBy,
        String remark) throws SQLException
    {
        int index = 1;
        insert.setString(index++, name);
        insert.setString(index++, specification);
        insert.setString(index++, dosageForm);
        insert.setString(index++, form);
        insert.setString(index++, manufacturer);
        insert.setDate(index++, expiryDate);
        insert.setBigDecimal(index++, price);
        insert.setInt(index++, stock);
        insert.setInt(index++, warningStock);
        insert.setInt(index++, warningThreshold);
        insert.setInt(index++, minStock);
        insert.setString(index++, unit);
        insert.setString(index++, pharmacology);
        insert.setString(index++, indications);
        insert.setString(index++, dosage);
        insert.setString(index++, sideEffects);
        insert.setString(index++, storage);
        insert.setString(index++, status);
        insert.setString(index++, isPrescription);
        insert.setString(index++, category);
        insert.setString(index++, createBy);
        insert.setTimestamp(index++, new Timestamp(System.currentTimeMillis()));
        insert.setString(index, remark);
        insert.executeUpdate();
    }
}
