package com.ruoyi.framework.shiro.web.filter.authc;

import java.io.IOException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.shiro.web.filter.authc.UserFilter;
import org.apache.shiro.web.util.WebUtils;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.ruoyi.framework.web.domain.AjaxResult;

/**
 * API 请求认证过滤器：未认证时返回 401 JSON 而非重定向
 * 用于微信小程序等 REST API 场景
 * 
 * @author ruoyi
 */
public class ApiUserFilter extends UserFilter
{
    private static final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    protected void redirectToLogin(ServletRequest request, ServletResponse response) throws IOException
    {
        HttpServletRequest httpRequest = WebUtils.toHttp(request);
        HttpServletResponse httpResponse = WebUtils.toHttp(response);
        String uri = httpRequest.getRequestURI();
        if (uri != null && uri.startsWith("/api/"))
        {
            httpResponse.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            httpResponse.setContentType("application/json;charset=UTF-8");
            AjaxResult result = AjaxResult.error("Session expired. Please login again.");
            objectMapper.writeValue(httpResponse.getOutputStream(), result);
        }
        else
        {
            super.redirectToLogin(request, response);
        }
    }
}
