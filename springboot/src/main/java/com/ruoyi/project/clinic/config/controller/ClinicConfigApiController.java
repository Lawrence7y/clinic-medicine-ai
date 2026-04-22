package com.ruoyi.project.clinic.config.controller;

import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.security.ShiroUtils;
import com.ruoyi.framework.web.controller.BaseController;
import com.ruoyi.framework.web.domain.AjaxResult;
import com.ruoyi.project.clinic.audit.service.AuditTrailService;
import com.ruoyi.project.clinic.common.ClinicApiMessages;
import com.ruoyi.project.clinic.config.service.ClinicConfigSupportService;
import com.ruoyi.project.system.role.service.IRoleService;
import com.ruoyi.project.system.user.domain.User;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import javax.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

@RestController
@RequestMapping("/api/clinic/config")
public class ClinicConfigApiController extends BaseController
{
    private static final String MSG_CONFIG_CONTENT_REQUIRED = "配置内容不能为空";
    private static final String MSG_CONFIG_UPDATE_DENIED = "无权限修改系统配置";

    @Autowired
    private ClinicConfigSupportService clinicConfigSupportService;

    @Autowired
    private IRoleService roleService;

    @Autowired
    private AuditTrailService auditTrailService;

    @GetMapping("/get")
    public AjaxResult getConfig()
    {
        Map<String, Object> config = clinicConfigSupportService.getConfigMap();
        applyRuntimeEffectiveApiBaseUrl(config);
        return success(config);
    }

    @GetMapping("/version")
    public AjaxResult getConfigVersion()
    {
        Map<String, Object> data = new HashMap<String, Object>();
        data.put("configUpdatedAt", clinicConfigSupportService.getConfigUpdatedAt());
        return success(data);
    }

    @PostMapping("/update")
    @Transactional
    public AjaxResult updateConfig(@RequestBody(required = false) Map<String, Object> updates)
    {
        if (updates == null)
        {
            return AjaxResult.error(MSG_CONFIG_CONTENT_REQUIRED);
        }

        User user = ShiroUtils.getSysUser();
        if (user == null)
        {
            return AjaxResult.error(ClinicApiMessages.MSG_NEED_LOGIN);
        }
        Set<String> roleKeys = roleService.selectRoleKeys(user.getUserId());
        if (roleKeys == null || (!roleKeys.contains("admin") && !roleKeys.contains("clinic_admin")))
        {
            return AjaxResult.error(MSG_CONFIG_UPDATE_DENIED);
        }

        try
        {
            Map<String, Object> result = clinicConfigSupportService.updateConfig(updates);
            auditTrailService.record(
                "config",
                "update",
                "system",
                "更新字段：" + String.join(",", updates.keySet())
            );
            return AjaxResult.success(result);
        }
        catch (IllegalArgumentException ex)
        {
            return AjaxResult.error(ex.getMessage());
        }
    }

    private void applyRuntimeEffectiveApiBaseUrl(Map<String, Object> config)
    {
        if (config == null)
        {
            return;
        }

        String effectiveApiBaseUrl = readConfigValue(config, "effectiveApiBaseUrl");
        String apiBaseUrl = readConfigValue(config, "apiBaseUrl");
        String tunnelBaseUrl = readConfigValue(config, "tunnelBaseUrl");
        if (StringUtils.isNotEmpty(effectiveApiBaseUrl)
                || StringUtils.isNotEmpty(apiBaseUrl)
                || StringUtils.isNotEmpty(tunnelBaseUrl))
        {
            return;
        }

        String runtimeBaseUrl = resolveCurrentRequestBaseUrl();
        if (StringUtils.isNotEmpty(runtimeBaseUrl))
        {
            config.put("effectiveApiBaseUrl", runtimeBaseUrl);
        }
    }

    private String resolveCurrentRequestBaseUrl()
    {
        ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attributes == null)
        {
            return "";
        }

        HttpServletRequest request = attributes.getRequest();
        if (request == null)
        {
            return "";
        }

        String scheme = firstHeaderValue(request.getHeader("X-Forwarded-Proto"));
        if (StringUtils.isEmpty(scheme))
        {
            scheme = request.getScheme();
        }

        String host = firstHeaderValue(request.getHeader("X-Forwarded-Host"));
        if (StringUtils.isEmpty(host))
        {
            host = request.getServerName();
        }
        if (StringUtils.isEmpty(host))
        {
            return "";
        }

        String portHeader = firstHeaderValue(request.getHeader("X-Forwarded-Port"));
        int port = parsePort(portHeader, request.getServerPort());
        if (!host.contains(":") && shouldAppendPort(scheme, port))
        {
            host = host + ":" + port;
        }

        return StringUtils.trim(scheme).toLowerCase() + "://" + StringUtils.trim(host);
    }

    private String firstHeaderValue(String value)
    {
        if (StringUtils.isEmpty(value))
        {
            return "";
        }
        String[] segments = value.split(",");
        return segments.length > 0 ? StringUtils.trim(segments[0]) : "";
    }

    private int parsePort(String portValue, int fallbackPort)
    {
        if (StringUtils.isEmpty(portValue))
        {
            return fallbackPort;
        }
        try
        {
            return Integer.parseInt(portValue);
        }
        catch (NumberFormatException ex)
        {
            return fallbackPort;
        }
    }

    private boolean shouldAppendPort(String scheme, int port)
    {
        if (port <= 0)
        {
            return false;
        }
        String normalizedScheme = StringUtils.trim(scheme).toLowerCase();
        return !("http".equals(normalizedScheme) && port == 80)
                && !("https".equals(normalizedScheme) && port == 443);
    }

    private String readConfigValue(Map<String, Object> config, String key)
    {
        Object value = config.get(key);
        return value == null ? "" : StringUtils.trim(String.valueOf(value));
    }
}
