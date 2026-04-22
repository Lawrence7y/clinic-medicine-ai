package com.ruoyi.project.clinic.support;

import com.ruoyi.project.system.user.domain.User;
import org.apache.shiro.SecurityUtils;
import org.apache.shiro.mgt.DefaultSecurityManager;
import org.apache.shiro.subject.SimplePrincipalCollection;
import org.apache.shiro.subject.Subject;
import org.apache.shiro.util.ThreadContext;

public final class ShiroTestSupport
{
    private ShiroTestSupport()
    {
    }

    public static void bindUser(User user)
    {
        DefaultSecurityManager securityManager = new DefaultSecurityManager();
        SecurityUtils.setSecurityManager(securityManager);
        Subject subject = new Subject.Builder(securityManager)
            .principals(new SimplePrincipalCollection(user, "testRealm"))
            .buildSubject();
        ThreadContext.bind(subject);
    }

    public static void clear()
    {
        ThreadContext.unbindSubject();
        ThreadContext.unbindSecurityManager();
    }
}
