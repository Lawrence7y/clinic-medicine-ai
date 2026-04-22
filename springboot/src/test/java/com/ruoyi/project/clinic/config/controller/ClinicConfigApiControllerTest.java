package com.ruoyi.project.clinic.config.controller;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.when;
import com.ruoyi.framework.web.domain.AjaxResult;
import com.ruoyi.project.clinic.audit.service.AuditTrailService;
import com.ruoyi.project.clinic.config.service.ClinicConfigSupportService;
import com.ruoyi.project.system.role.service.IRoleService;
import java.util.HashMap;
import java.util.Map;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

@ExtendWith(MockitoExtension.class)
public class ClinicConfigApiControllerTest
{
    @Mock
    private ClinicConfigSupportService clinicConfigSupportService;

    @Mock
    private IRoleService roleService;

    @Mock
    private AuditTrailService auditTrailService;

    @InjectMocks
    private ClinicConfigApiController controller;

    @AfterEach
    public void tearDown()
    {
        RequestContextHolder.resetRequestAttributes();
    }

    @Test
    public void getConfig_shouldExposeCurrentRequestOriginWhenApiBaseUrlIsUnset()
    {
        Map<String, Object> config = new HashMap<String, Object>();
        config.put("apiBaseUrl", "");
        config.put("tunnelBaseUrl", "");
        config.put("effectiveApiBaseUrl", "");
        when(clinicConfigSupportService.getConfigMap()).thenReturn(config);

        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/api/clinic/config/get");
        request.setScheme("http");
        request.setServerName("192.168.124.7");
        request.setServerPort(8090);
        RequestContextHolder.setRequestAttributes(new ServletRequestAttributes(request));

        AjaxResult result = controller.getConfig();

        assertTrue(result.isSuccess());
        Map<?, ?> payload = (Map<?, ?>) result.get(AjaxResult.DATA_TAG);
        assertEquals("http://192.168.124.7:8090", payload.get("effectiveApiBaseUrl"));
    }

    @Test
    public void getConfig_shouldKeepConfiguredEffectiveApiBaseUrl()
    {
        Map<String, Object> config = new HashMap<String, Object>();
        config.put("apiBaseUrl", "");
        config.put("tunnelBaseUrl", "");
        config.put("effectiveApiBaseUrl", "https://clinic.example.com");
        when(clinicConfigSupportService.getConfigMap()).thenReturn(config);

        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/api/clinic/config/get");
        request.setScheme("http");
        request.setServerName("192.168.124.7");
        request.setServerPort(8090);
        RequestContextHolder.setRequestAttributes(new ServletRequestAttributes(request));

        AjaxResult result = controller.getConfig();

        assertTrue(result.isSuccess());
        Map<?, ?> payload = (Map<?, ?>) result.get(AjaxResult.DATA_TAG);
        assertEquals("https://clinic.example.com", payload.get("effectiveApiBaseUrl"));
    }

    @Test
    public void getConfig_shouldFallbackWhenApiUrlKeysAreMissing()
    {
        Map<String, Object> config = new HashMap<String, Object>();
        config.put("clinicName", "测试诊所");
        when(clinicConfigSupportService.getConfigMap()).thenReturn(config);

        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/api/clinic/config/get");
        request.setScheme("http");
        request.setServerName("192.168.124.7");
        request.setServerPort(8090);
        RequestContextHolder.setRequestAttributes(new ServletRequestAttributes(request));

        AjaxResult result = controller.getConfig();

        assertTrue(result.isSuccess());
        Map<?, ?> payload = (Map<?, ?>) result.get(AjaxResult.DATA_TAG);
        assertEquals("http://192.168.124.7:8090", payload.get("effectiveApiBaseUrl"));
    }
}
