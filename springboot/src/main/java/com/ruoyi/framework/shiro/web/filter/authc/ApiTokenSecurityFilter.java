package com.ruoyi.framework.shiro.web.filter.authc;

import java.io.IOException;
import java.util.concurrent.ConcurrentHashMap;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.shiro.session.Session;
import org.apache.shiro.subject.Subject;
import org.apache.shiro.web.filter.authc.UserFilter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.framework.web.domain.AjaxResult;

/**
 * API Token 安全过滤器：客户端绑定、防重放、过期信息透传
 * 用于微信小程序等 REST API 场景
 *
 * @author ruoyi
 */
public class ApiTokenSecurityFilter extends UserFilter
{
    private static final Logger log = LoggerFactory.getLogger(ApiTokenSecurityFilter.class);
    private static final String API_CLIENT_KEY = "api_client_key";

    private static final ObjectMapper objectMapper = new ObjectMapper();

    /**
     * 防重放缓存，key为nonce，value为请求时间戳
     */
    private final ConcurrentHashMap<String, Long> nonceCache = new ConcurrentHashMap<>();

    /**
     * API Token 安全增强开关（防重放）
     */
    private boolean replayProtectEnabled = true;

    /**
     * API Token 是否强制客户端绑定标识
     */
    private boolean requireClientKey = true;

    /**
     * API Token 请求时间窗口（秒）
     */
    private int requestWindowSeconds = 300;

    /**
     * API Token 防重放缓存上限
     */
    private int maxNonceCacheSize = 512;

    public void setReplayProtectEnabled(boolean replayProtectEnabled)
    {
        this.replayProtectEnabled = replayProtectEnabled;
    }

    public void setRequireClientKey(boolean requireClientKey)
    {
        this.requireClientKey = requireClientKey;
    }

    public void setRequestWindowSeconds(int requestWindowSeconds)
    {
        this.requestWindowSeconds = requestWindowSeconds;
    }

    public void setMaxNonceCacheSize(int maxNonceCacheSize)
    {
        this.maxNonceCacheSize = maxNonceCacheSize;
    }

    @Override
    protected boolean isAccessAllowed(ServletRequest request, ServletResponse response, Object mappedValue)
    {
        // Always execute onAccessDenied for /api/** to enforce token hardening checks.
        return false;
    }

    @Override
    protected boolean onAccessDenied(ServletRequest request, ServletResponse response) throws IOException
    {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        String uri = httpRequest.getRequestURI();

        if (uri != null && uri.startsWith("/api/"))
        {
            // 检查是否携带API Token
            String apiToken = httpRequest.getHeader("X-Api-Token");
            if (StringUtils.isEmpty(apiToken))
            {
                // 如果未携带token，仅记录日志，不拦截（由ApiUserFilter处理登录校验）
                log.debug("API请求未携带X-Api-Token令牌");
                return true;
            }

            Subject subject = getSubject(request, response);
            Session session = subject != null ? subject.getSession(false) : null;

            // 客户端绑定校验
            if (requireClientKey)
            {
                String clientKey = httpRequest.getHeader("X-Client-Key");
                if (StringUtils.isEmpty(clientKey))
                {
                    log.warn("API请求缺少客户端标识X-Client-Key，token={}", apiToken);
                    returnJson(httpResponse, AjaxResult.error("Client key is missing. Session invalid, relogin required."));
                    return false;
                }

                if (session == null)
                {
                    log.warn("API请求会话不存在，token={}", apiToken);
                    returnJson(httpResponse, AjaxResult.error("Session invalid, relogin required."));
                    return false;
                }

                Object boundClientKey = session.getAttribute(API_CLIENT_KEY);
                if (boundClientKey == null || !StringUtils.equals(clientKey, String.valueOf(boundClientKey)))
                {
                    log.warn("API客户端标识不匹配，token={}, headerClientKey={}, sessionClientKey={}",
                        apiToken, clientKey, boundClientKey);
                    try
                    {
                        session.setAttribute("kickout", true);
                        if (subject != null)
                        {
                            subject.logout();
                        }
                    }
                    catch (Exception ignored)
                    {
                    }
                    returnJson(httpResponse,
                        AjaxResult.error("Account logged in elsewhere. Session invalid, relogin required."));
                    return false;
                }
            }

            // 防重放校验
            if (replayProtectEnabled)
            {
                String nonce = httpRequest.getHeader("X-Nonce");
                String timestampStr = httpRequest.getHeader("X-Timestamp");

                if (StringUtils.isEmpty(nonce) || StringUtils.isEmpty(timestampStr))
                {
                    log.warn("API请求缺少防重放参数nonce或timestamp，token={}", apiToken);
                }
                else
                {
                    try
                    {
                        long timestamp = Long.parseLong(timestampStr);
                        long currentTime = System.currentTimeMillis() / 1000;
                        long timeDiff = Math.abs(currentTime - timestamp);

                        // 检查时间窗口
                        if (timeDiff > requestWindowSeconds)
                        {
                            log.warn("API请求已过期，时间戳差={}秒，token={}", timeDiff, apiToken);
                            returnJson(httpResponse, AjaxResult.error("Request expired. Please login again."));
                            return false;
                        }

                        // 检查nonce是否已使用（防重放）
                        if (nonceCache.containsKey(nonce))
                        {
                            log.warn("API请求nonce已使用，可能为重放攻击，nonce={}, token={}", nonce, apiToken);
                            returnJson(httpResponse, AjaxResult.error("Duplicated request detected. Please retry."));
                            return false;
                        }

                        // 记录nonce
                        nonceCache.put(nonce, timestamp);
                        cleanExpiredNonce(timestamp);
                    }
                    catch (NumberFormatException e)
                    {
                        log.warn("API请求时间戳格式错误，timestamp={}", timestampStr);
                    }
                }
            }
        }

        return true;
    }

    /**
     * 清理过期nonce
     */
    private void cleanExpiredNonce(long currentTimestamp)
    {
        if (nonceCache.size() >= maxNonceCacheSize)
        {
            // 清理超过时间窗口的nonce
            nonceCache.entrySet().removeIf(entry -> {
                long diff = currentTimestamp - entry.getValue();
                return diff > requestWindowSeconds;
            });

            // 如果仍然超出限制，清除最老的50%
            if (nonceCache.size() >= maxNonceCacheSize)
            {
                int removeCount = nonceCache.size() / 2;
                nonceCache.entrySet().stream()
                    .sorted((e1, e2) -> Long.compare(e1.getValue(), e2.getValue()))
                    .limit(removeCount)
                    .forEach(entry -> nonceCache.remove(entry.getKey()));
            }
        }
    }

    /**
     * 返回JSON错误
     */
    private void returnJson(HttpServletResponse response, AjaxResult result) throws IOException
    {
        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
        response.setContentType("application/json;charset=UTF-8");
        objectMapper.writeValue(response.getOutputStream(), result);
    }
}
