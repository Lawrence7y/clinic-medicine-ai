package com.ruoyi.project.clinic.config.service;

import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.project.system.config.domain.Config;
import com.ruoyi.project.system.config.service.IConfigService;
import java.sql.Connection;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;
import javax.sql.DataSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class ClinicConfigSupportService
{
    private static final Map<String, String> DEFAULTS = new HashMap<String, String>();
    private static final Set<String> ALLOWED_FIELDS = new LinkedHashSet<String>();
    private static final Set<String> URL_FIELDS = new LinkedHashSet<String>();
    private static final Pattern URL_LIKE_PATTERN = Pattern.compile("^[\\w.-]+(?::\\d+)?(?:/.*)?$");

    static
    {
        DEFAULTS.put("clinic.clinicName", "诊所");
        DEFAULTS.put("clinic.contactPhone", "400-888-8888");
        DEFAULTS.put("clinic.businessHours", "08:00 - 20:00");
        DEFAULTS.put("clinic.appointmentDays", "7");
        DEFAULTS.put("clinic.appointmentDuration", "30");
        DEFAULTS.put("clinic.pendingConfirmTimeoutMinutes", "30");
        DEFAULTS.put("clinic.patientCancelAdvanceMinutes", "120");
        DEFAULTS.put("clinic.maxSessionCount", "2");
        DEFAULTS.put("clinic.kickoutAfterNewLogin", "false");
        DEFAULTS.put("clinic.loginMaxFailCount", "5");
        DEFAULTS.put("clinic.loginLockMinutes", "5");
        DEFAULTS.put("sys.account.registerUser", "false");
        DEFAULTS.put("clinic.loginMode", "phone_and_admin");
        DEFAULTS.put("clinic.apiBaseUrl", "");
        DEFAULTS.put("clinic.adminBaseUrl", "");
        DEFAULTS.put("clinic.miniProgramBaseUrl", "");
        DEFAULTS.put("clinic.experienceDomain", "");
        DEFAULTS.put("clinic.tunnelBaseUrl", "");
        DEFAULTS.put("clinic.databaseName", "");
        DEFAULTS.put("clinic.configUpdatedAt", "0");
        DEFAULTS.put("clinic.aiAssistantEnabled", "true");
        DEFAULTS.put("clinic.aiAssistantName", "AI 助手");
        DEFAULTS.put("clinic.aiPromptTemplateGeneral", "你是诊所 AI 助手，请给出清晰、简洁且可执行的回答。");
        DEFAULTS.put("clinic.aiPromptTemplateBusiness", "你是诊所经营助手，请提供结构化的运营建议，优先给出可落地步骤。");
        DEFAULTS.put("clinic.aiModelDescriptionDoc", "请在此维护模型说明：适用场景、能力边界、风险与推荐配置。");

        ALLOWED_FIELDS.add("clinicName");
        ALLOWED_FIELDS.add("contactPhone");
        ALLOWED_FIELDS.add("businessHours");
        ALLOWED_FIELDS.add("appointmentDays");
        ALLOWED_FIELDS.add("appointmentDuration");
        ALLOWED_FIELDS.add("pendingConfirmTimeoutMinutes");
        ALLOWED_FIELDS.add("patientCancelAdvanceMinutes");
        ALLOWED_FIELDS.add("maxSessionCount");
        ALLOWED_FIELDS.add("kickoutAfterNewLogin");
        ALLOWED_FIELDS.add("loginMaxFailCount");
        ALLOWED_FIELDS.add("loginLockMinutes");
        ALLOWED_FIELDS.add("allowUserRegister");
        ALLOWED_FIELDS.add("loginMode");
        ALLOWED_FIELDS.add("apiBaseUrl");
        ALLOWED_FIELDS.add("adminBaseUrl");
        ALLOWED_FIELDS.add("miniProgramBaseUrl");
        ALLOWED_FIELDS.add("experienceDomain");
        ALLOWED_FIELDS.add("tunnelBaseUrl");
        ALLOWED_FIELDS.add("databaseName");
        ALLOWED_FIELDS.add("aiAssistantEnabled");
        ALLOWED_FIELDS.add("aiAssistantName");
        ALLOWED_FIELDS.add("aiPromptTemplateGeneral");
        ALLOWED_FIELDS.add("aiPromptTemplateBusiness");
        ALLOWED_FIELDS.add("aiModelDescriptionDoc");

        URL_FIELDS.add("apiBaseUrl");
        URL_FIELDS.add("adminBaseUrl");
        URL_FIELDS.add("miniProgramBaseUrl");
        URL_FIELDS.add("experienceDomain");
        URL_FIELDS.add("tunnelBaseUrl");
    }

    @Autowired
    private IConfigService configService;

    @Autowired(required = false)
    private DataSource dataSource;

    public Map<String, Object> getConfigMap()
    {
        Map<String, Object> config = new HashMap<String, Object>();
        config.put("clinicName", getVal("clinic.clinicName"));
        config.put("contactPhone", getVal("clinic.contactPhone"));
        config.put("businessHours", getVal("clinic.businessHours"));
        config.put("appointmentDays", parseBoundedInt(getVal("clinic.appointmentDays"), 7, 1, 30));
        config.put("appointmentDuration", parseBoundedInt(getVal("clinic.appointmentDuration"), 30, 5, 240));
        config.put("pendingConfirmTimeoutMinutes", getPendingConfirmTimeoutMinutes());
        config.put("patientCancelAdvanceMinutes", getPatientCancelAdvanceMinutes());
        config.put("maxSessionCount", getMaxSessionCount());
        config.put("kickoutAfterNewLogin", "true".equalsIgnoreCase(getVal("clinic.kickoutAfterNewLogin")));
        config.put("loginMaxFailCount", getLoginMaxFailCount());
        config.put("loginLockMinutes", getLoginLockMinutes());
        config.put("allowUserRegister", "true".equalsIgnoreCase(getVal("sys.account.registerUser")));
        config.put("loginMode", getVal("clinic.loginMode"));
        config.put("apiBaseUrl", getVal("clinic.apiBaseUrl"));
        config.put("adminBaseUrl", getVal("clinic.adminBaseUrl"));
        config.put("miniProgramBaseUrl", getVal("clinic.miniProgramBaseUrl"));
        config.put("experienceDomain", getVal("clinic.experienceDomain"));
        config.put("tunnelBaseUrl", getVal("clinic.tunnelBaseUrl"));
        config.put("effectiveApiBaseUrl", getEffectiveApiBaseUrl());
        config.put("databaseName", resolveDatabaseName());
        config.put("configUpdatedAt", parseLongOrDefault(getVal("clinic.configUpdatedAt"), 0L));
        config.put("aiAssistantEnabled", "true".equalsIgnoreCase(getVal("clinic.aiAssistantEnabled")));
        config.put("aiAssistantName", getVal("clinic.aiAssistantName"));
        config.put("aiPromptTemplateGeneral", getVal("clinic.aiPromptTemplateGeneral"));
        config.put("aiPromptTemplateBusiness", getVal("clinic.aiPromptTemplateBusiness"));
        config.put("aiModelDescriptionDoc", getVal("clinic.aiModelDescriptionDoc"));
        return config;
    }

    public Map<String, Object> updateConfig(Map<String, Object> updates)
    {
        if (updates == null)
        {
            throw new IllegalArgumentException("配置更新内容不能为空");
        }

        Map<String, String> normalizedValues = new HashMap<String, String>();
        for (Map.Entry<String, Object> entry : updates.entrySet())
        {
            String field = entry.getKey();
            if (!ALLOWED_FIELDS.contains(field))
            {
                continue;
            }
            String normalizedValue = normalizeValue(field, entry.getValue());
            if (normalizedValue == null)
            {
                throw new IllegalArgumentException("配置项取值无效: " + field);
            }
            normalizedValues.put(field, normalizedValue);
        }

        validateApiBaseOrTunnel(normalizedValues);

        for (Map.Entry<String, String> entry : normalizedValues.entrySet())
        {
            upsertConfig(toSysConfigKey(entry.getKey()), entry.getValue());
        }
        upsertConfig("clinic.configUpdatedAt", String.valueOf(System.currentTimeMillis()));

        configService.resetConfigCache();
        return getConfigMap();
    }

    private String getVal(String key)
    {
        String val = configService.selectConfigByKey(key);
        if (StringUtils.isEmpty(val))
        {
            val = configService.selectConfigByKey(legacyKey(key));
        }
        if (StringUtils.isEmpty(val) && DEFAULTS.containsKey(key))
        {
            return DEFAULTS.get(key);
        }
        return val != null ? val : "";
    }

    private String toSysConfigKey(String field)
    {
        if ("allowUserRegister".equals(field))
        {
            return "sys.account.registerUser";
        }
        return "clinic." + field;
    }

    private int upsertConfig(String key, String value)
    {
        int updatedLegacy = updateIfExists(legacyKey(key), value);
        if (!legacyKey(key).equals(key) && updatedLegacy > 0)
        {
            return updatedLegacy;
        }
        return upsertSingle(key, value);
    }

    private int updateIfExists(String key, String value)
    {
        Config query = new Config();
        query.setConfigKey(key);
        java.util.List<Config> list = configService.selectConfigList(query);
        if (list != null && !list.isEmpty())
        {
            Config cfg = list.get(0);
            cfg.setConfigValue(value);
            return configService.updateConfig(cfg);
        }
        return 0;
    }

    private int upsertSingle(String key, String value)
    {
        Config query = new Config();
        query.setConfigKey(key);
        java.util.List<Config> list = configService.selectConfigList(query);
        if (list != null && !list.isEmpty())
        {
            Config cfg = list.get(0);
            cfg.setConfigValue(value);
            return configService.updateConfig(cfg);
        }
        Config cfg = new Config();
        cfg.setConfigName("Clinic Unified Config");
        cfg.setConfigKey(key);
        cfg.setConfigValue(value);
        cfg.setConfigType("N");
        return configService.insertConfig(cfg);
    }

    private int parseIntOrDefault(String val, int defaultValue)
    {
        if (StringUtils.isEmpty(val))
        {
            return defaultValue;
        }
        try
        {
            return Integer.parseInt(val);
        }
        catch (Exception ignored)
        {
            return defaultValue;
        }
    }

    private long parseLongOrDefault(String val, long defaultValue)
    {
        if (StringUtils.isEmpty(val))
        {
            return defaultValue;
        }
        try
        {
            return Long.parseLong(val);
        }
        catch (Exception ignored)
        {
            return defaultValue;
        }
    }

    public int getPendingConfirmTimeoutMinutes()
    {
        return parseBoundedInt(getVal("clinic.pendingConfirmTimeoutMinutes"), 30, 1, 1440);
    }

    public int getPatientCancelAdvanceMinutes()
    {
        return parseBoundedInt(getVal("clinic.patientCancelAdvanceMinutes"), 120, 30, 1440);
    }

    public int getMaxSessionCount()
    {
        return parseBoundedInt(getVal("clinic.maxSessionCount"), 2, 1, 10);
    }

    public int getLoginMaxFailCount()
    {
        return parseBoundedInt(getVal("clinic.loginMaxFailCount"), 5, 3, 10);
    }

    public int getLoginLockMinutes()
    {
        return parseBoundedInt(getVal("clinic.loginLockMinutes"), 5, 1, 120);
    }

    public boolean isAiAssistantEnabled()
    {
        return "true".equalsIgnoreCase(getVal("clinic.aiAssistantEnabled"));
    }

    public String getAiAssistantName()
    {
        return getVal("clinic.aiAssistantName");
    }

    public String getAiPromptTemplateGeneral()
    {
        return getVal("clinic.aiPromptTemplateGeneral");
    }

    public String getAiPromptTemplateBusiness()
    {
        return getVal("clinic.aiPromptTemplateBusiness");
    }

    public String getEffectiveApiBaseUrl()
    {
        String apiBaseUrl = StringUtils.trimToEmpty(getVal("clinic.apiBaseUrl"));
        if (StringUtils.isNotEmpty(apiBaseUrl))
        {
            return apiBaseUrl;
        }
        return StringUtils.trimToEmpty(getVal("clinic.tunnelBaseUrl"));
    }

    public long getConfigUpdatedAt()
    {
        return parseLongOrDefault(getVal("clinic.configUpdatedAt"), 0L);
    }

    private int parseBoundedInt(String val, int defaultValue, int min, int max)
    {
        int parsed = parseIntOrDefault(val, defaultValue);
        if (parsed < min)
        {
            return min;
        }
        if (parsed > max)
        {
            return max;
        }
        return parsed;
    }

    private String normalizeValue(String field, Object valObj)
    {
        if (valObj == null)
        {
            return "";
        }
        String value = String.valueOf(valObj).trim();
        if ("allowUserRegister".equals(field)
                || "aiAssistantEnabled".equals(field)
                || "kickoutAfterNewLogin".equals(field))
        {
            return "true".equalsIgnoreCase(value) ? "true" : "false";
        }
        if (URL_FIELDS.contains(field))
        {
            return normalizeUrl(value);
        }
        if ("appointmentDays".equals(field) || "appointmentDuration".equals(field)
                || "pendingConfirmTimeoutMinutes".equals(field)
                || "patientCancelAdvanceMinutes".equals(field)
                || "maxSessionCount".equals(field)
                || "loginMaxFailCount".equals(field)
                || "loginLockMinutes".equals(field))
        {
            try
            {
                int intValue = Integer.parseInt(value);
                if ("appointmentDays".equals(field))
                {
                    return intValue < 1 || intValue > 30 ? null : String.valueOf(intValue);
                }
                if ("appointmentDuration".equals(field))
                {
                    return intValue < 5 || intValue > 240 ? null : String.valueOf(intValue);
                }
                if ("loginMaxFailCount".equals(field))
                {
                    return intValue < 3 || intValue > 10 ? null : String.valueOf(intValue);
                }
                if ("loginLockMinutes".equals(field))
                {
                    return intValue < 1 || intValue > 120 ? null : String.valueOf(intValue);
                }
                if ("patientCancelAdvanceMinutes".equals(field))
                {
                    return intValue < 30 || intValue > 1440 ? null : String.valueOf(intValue);
                }
                if ("maxSessionCount".equals(field))
                {
                    return intValue < 1 || intValue > 10 ? null : String.valueOf(intValue);
                }
                return intValue < 1 || intValue > 1440 ? null : String.valueOf(intValue);
            }
            catch (Exception ignored)
            {
                return null;
            }
        }
        if ("loginMode".equals(field))
        {
            return "phone_and_admin";
        }
        return value;
    }

    private String normalizeUrl(String value)
    {
        if (StringUtils.isEmpty(value))
        {
            return "";
        }

        String normalized = value.trim().replaceAll("/+$", "");
        String lower = normalized.toLowerCase();
        if (lower.contains("localhost") || lower.contains("127.0.0.1") || lower.contains("0.0.0.0"))
        {
            return null;
        }

        if (!lower.startsWith("http://") && !lower.startsWith("https://"))
        {
            if (!URL_LIKE_PATTERN.matcher(normalized).matches())
            {
                return null;
            }
            normalized = "https://" + normalized;
            lower = normalized.toLowerCase();
        }

        if (!lower.startsWith("https://"))
        {
            return null;
        }
        return normalized;
    }

    private String resolveDatabaseName()
    {
        String configured = getVal("clinic.databaseName");
        if (StringUtils.isNotEmpty(configured))
        {
            return configured;
        }
        if (dataSource == null)
        {
            return "";
        }
        try (Connection connection = dataSource.getConnection())
        {
            String catalog = connection.getCatalog();
            return StringUtils.defaultString(catalog);
        }
        catch (Exception ignored)
        {
            return "";
        }
    }

    private void validateApiBaseOrTunnel(Map<String, String> normalizedValues)
    {
        String apiBaseUrl = resolveUpdatedValue(normalizedValues, "apiBaseUrl", "clinic.apiBaseUrl");
        String tunnelBaseUrl = resolveUpdatedValue(normalizedValues, "tunnelBaseUrl", "clinic.tunnelBaseUrl");
        if (StringUtils.isEmpty(apiBaseUrl) && StringUtils.isEmpty(tunnelBaseUrl))
        {
            throw new IllegalArgumentException("小程序 API 地址与内网穿透地址至少配置一项");
        }
    }

    private String resolveUpdatedValue(Map<String, String> normalizedValues, String field, String configKey)
    {
        if (normalizedValues != null && normalizedValues.containsKey(field))
        {
            return StringUtils.trimToEmpty(normalizedValues.get(field));
        }
        return StringUtils.trimToEmpty(getVal(configKey));
    }

    private String legacyKey(String key)
    {
        if ("clinic.appointmentDays".equals(key))
        {
            return "appointment_advance_days";
        }
        return key;
    }
}
