package com.ruoyi.framework.shiro.web.session;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.List;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import org.apache.commons.lang3.time.DateUtils;
import org.apache.shiro.session.ExpiredSessionException;
import org.apache.shiro.session.InvalidSessionException;
import org.apache.shiro.session.Session;
import org.apache.shiro.session.mgt.DefaultSessionKey;
import org.apache.shiro.session.mgt.SessionKey;
import org.apache.shiro.web.session.mgt.DefaultWebSessionManager;
import org.apache.shiro.web.servlet.ShiroHttpServletRequest;
import org.apache.shiro.web.util.WebUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import com.ruoyi.common.constant.ShiroConstants;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.bean.BeanUtils;
import com.ruoyi.common.utils.spring.SpringUtils;
import com.ruoyi.project.monitor.online.domain.OnlineSession;
import com.ruoyi.project.monitor.online.domain.UserOnline;
import com.ruoyi.project.monitor.online.service.UserOnlineServiceImpl;

/**
 * 主要是在此如果会话的属性修改了 就标识下其修改了 然后方便 OnlineSessionDao同步
 * 支持从 Authorization 请求头读取 sessionId，兼容微信小程序等不携带 Cookie 的客户端
 * 
 * @author ruoyi
 */
public class OnlineWebSessionManager extends DefaultWebSessionManager
{
    private static final Logger log = LoggerFactory.getLogger(OnlineWebSessionManager.class);

    /** 微信小程序等客户端通过 Authorization 头传递 sessionId */
    private static final String AUTHORIZATION_HEADER = "Authorization";
    private static final String API_CLIENT_KEY = "api_client_key";
    private static final String API_REQUEST_NONCE_CACHE = "api_request_nonce_cache";

    @Override
    protected Serializable getSessionId(ServletRequest request, ServletResponse response)
    {
        String authorization = WebUtils.toHttp(request).getHeader(AUTHORIZATION_HEADER);
        String sessionId = parseSessionIdFromAuthorization(authorization);
        if (StringUtils.isNotEmpty(sessionId))
        {
            request.setAttribute(ShiroHttpServletRequest.REFERENCED_SESSION_ID_SOURCE, AUTHORIZATION_HEADER);
            request.setAttribute(ShiroHttpServletRequest.REFERENCED_SESSION_ID, sessionId);
            request.setAttribute(ShiroHttpServletRequest.REFERENCED_SESSION_ID_IS_VALID, Boolean.TRUE);
            return sessionId.trim();
        }
        return super.getSessionId(request, response);
    }

    private String parseSessionIdFromAuthorization(String authorization)
    {
        if (StringUtils.isEmpty(authorization))
        {
            return null;
        }
        String token = authorization.trim();
        String bearerPrefix = "Bearer ";
        if (token.regionMatches(true, 0, bearerPrefix, 0, bearerPrefix.length()))
        {
            token = token.substring(bearerPrefix.length()).trim();
        }
        return token;
    }

    @Override
    public void setAttribute(SessionKey sessionKey, Object attributeKey, Object value) throws InvalidSessionException
    {
        super.setAttribute(sessionKey, attributeKey, value);
        if (value != null && needMarkAttributeChanged(attributeKey))
        {
            OnlineSession session = getOnlineSession(sessionKey);
            session.markAttributeChanged();
        }
    }

    private boolean needMarkAttributeChanged(Object attributeKey)
    {
        if (attributeKey == null)
        {
            return false;
        }
        String attributeKeyStr = attributeKey.toString();
        // 优化 flash属性没必要持久化
        if (attributeKeyStr.startsWith("org.springframework"))
        {
            return false;
        }
        if (attributeKeyStr.startsWith("javax.servlet"))
        {
            return false;
        }
        if (attributeKeyStr.equals(ShiroConstants.CURRENT_USERNAME))
        {
            return false;
        }
        if (attributeKeyStr.equals(API_CLIENT_KEY) || attributeKeyStr.equals(API_REQUEST_NONCE_CACHE))
        {
            return false;
        }
        return true;
    }

    @Override
    public Object removeAttribute(SessionKey sessionKey, Object attributeKey) throws InvalidSessionException
    {
        Object removed = super.removeAttribute(sessionKey, attributeKey);
        if (removed != null)
        {
            OnlineSession s = getOnlineSession(sessionKey);
            s.markAttributeChanged();
        }

        return removed;
    }

    public OnlineSession getOnlineSession(SessionKey sessionKey)
    {
        OnlineSession session = null;
        Object obj = doGetSession(sessionKey);
        if (StringUtils.isNotNull(obj))
        {
            session = new OnlineSession();
            BeanUtils.copyBeanProp(session, obj);
        }
        return session;
    }

    /**
     * 验证session是否有效 用于删除过期session
     */
    @Override
    public void validateSessions()
    {
        if (log.isInfoEnabled())
        {
            log.info("invalidation sessions...");
        }

        int invalidCount = 0;

        int timeout = (int) this.getGlobalSessionTimeout();
        if (timeout < 0)
        {
            // 永不过期不进行处理
            return;
        }
        Date expiredDate = DateUtils.addMilliseconds(new Date(), 0 - timeout);
        UserOnlineServiceImpl userOnlineService = SpringUtils.getBean(UserOnlineServiceImpl.class);
        List<UserOnline> userOnlineList = userOnlineService.selectOnlineByExpired(expiredDate);
        // 批量过期删除
        List<String> needOfflineIdList = new ArrayList<String>();
        for (UserOnline userOnline : userOnlineList)
        {
            try
            {
                SessionKey key = new DefaultSessionKey(userOnline.getSessionId());
                Session session = retrieveSession(key);
                if (session != null)
                {
                    throw new InvalidSessionException();
                }
            }
            catch (InvalidSessionException e)
            {
                if (log.isDebugEnabled())
                {
                    boolean expired = (e instanceof ExpiredSessionException);
                    String msg = "Invalidated session with id [" + userOnline.getSessionId() + "]"
                            + (expired ? " (expired)" : " (stopped)");
                    log.debug(msg);
                }
                invalidCount++;
                needOfflineIdList.add(userOnline.getSessionId());
                userOnlineService.removeUserCache(userOnline.getLoginName(), userOnline.getSessionId());
            }

        }
        if (needOfflineIdList.size() > 0)
        {
            try
            {
                userOnlineService.batchDeleteOnline(needOfflineIdList);
            }
            catch (Exception e)
            {
                log.error("batch delete db session error.", e);
            }
        }

        if (log.isInfoEnabled())
        {
            String msg = "Finished invalidation session.";
            if (invalidCount > 0)
            {
                msg += " [" + invalidCount + "] sessions were stopped.";
            }
            else
            {
                msg += " No sessions were stopped.";
            }
            log.info(msg);
        }

    }

    @Override
    protected Collection<Session> getActiveSessions()
    {
        throw new UnsupportedOperationException("getActiveSessions method not supported");
    }
}
