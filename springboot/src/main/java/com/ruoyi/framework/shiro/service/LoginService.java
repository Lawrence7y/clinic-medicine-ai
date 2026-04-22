package com.ruoyi.framework.shiro.service;

import com.ruoyi.common.constant.Constants;
import com.ruoyi.common.constant.ShiroConstants;
import com.ruoyi.common.constant.UserConstants;
import com.ruoyi.common.exception.user.BlackListException;
import com.ruoyi.common.exception.user.CaptchaException;
import com.ruoyi.common.exception.user.RoleNotAllowedException;
import com.ruoyi.common.exception.user.UserBlockedException;
import com.ruoyi.common.exception.user.UserDeleteException;
import com.ruoyi.common.exception.user.UserNotExistsException;
import com.ruoyi.common.exception.user.UserPasswordNotMatchException;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.IpUtils;
import com.ruoyi.common.utils.MessageUtils;
import com.ruoyi.common.utils.ServletUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.security.ShiroUtils;
import com.ruoyi.framework.manager.AsyncManager;
import com.ruoyi.framework.manager.factory.AsyncFactory;
import com.ruoyi.project.system.config.service.IConfigService;
import com.ruoyi.project.system.menu.service.IMenuService;
import com.ruoyi.project.system.role.domain.Role;
import com.ruoyi.project.system.user.domain.User;
import com.ruoyi.project.system.user.domain.UserStatus;
import com.ruoyi.project.system.user.service.IUserService;
import java.util.List;
import java.util.Set;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/**
 * 登录校验方法
 */
@Component
public class LoginService
{
    @Autowired
    private PasswordService passwordService;

    @Autowired
    private IUserService userService;

    @Autowired
    private IMenuService menuService;

    @Autowired
    private IConfigService configService;

    /**
     * 登录
     */
    public User login(String username, String password)
    {
        if (ShiroConstants.CAPTCHA_ERROR.equals(ServletUtils.getRequest().getAttribute(ShiroConstants.CURRENT_CAPTCHA)))
        {
            AsyncManager.me().execute(AsyncFactory.recordLogininfor(username, Constants.LOGIN_FAIL,
                MessageUtils.message("user.jcaptcha.error")));
            throw new CaptchaException();
        }

        if (StringUtils.isEmpty(username) || StringUtils.isEmpty(password))
        {
            AsyncManager.me().execute(AsyncFactory.recordLogininfor(username, Constants.LOGIN_FAIL,
                MessageUtils.message("not.null")));
            throw new UserNotExistsException();
        }

        if (password.length() < UserConstants.PASSWORD_MIN_LENGTH
            || password.length() > UserConstants.PASSWORD_MAX_LENGTH)
        {
            AsyncManager.me().execute(AsyncFactory.recordLogininfor(username, Constants.LOGIN_FAIL,
                MessageUtils.message("user.password.not.match")));
            throw new UserPasswordNotMatchException();
        }

        if (username.length() < UserConstants.USERNAME_MIN_LENGTH
            || username.length() > UserConstants.USERNAME_MAX_LENGTH)
        {
            AsyncManager.me().execute(AsyncFactory.recordLogininfor(username, Constants.LOGIN_FAIL,
                MessageUtils.message("user.password.not.match")));
            throw new UserPasswordNotMatchException();
        }

        if (!isAdminLogin(username) && !maybeMobilePhoneNumber(username))
        {
            AsyncManager.me().execute(AsyncFactory.recordLogininfor(username, Constants.LOGIN_FAIL,
                "仅支持手机号登录，管理员请使用 admin 账号"));
            throw new IllegalArgumentException("仅支持手机号登录，管理员请使用 admin 账号");
        }

        String blackStr = configService.selectConfigByKey("sys.login.blackIPList");
        if (IpUtils.isMatchedIp(blackStr, ShiroUtils.getIp()))
        {
            AsyncManager.me().execute(AsyncFactory.recordLogininfor(username, Constants.LOGIN_FAIL,
                MessageUtils.message("login.blocked")));
            throw new BlackListException();
        }

        User user = isAdminLogin(username)
            ? userService.selectUserByLoginName(username)
            : userService.selectUserByPhoneNumber(username);

        if (user == null)
        {
            AsyncManager.me().execute(AsyncFactory.recordLogininfor(username, Constants.LOGIN_FAIL,
                MessageUtils.message("user.not.exists")));
            throw new UserNotExistsException();
        }

        if (UserStatus.DELETED.getCode().equals(user.getDelFlag()))
        {
            AsyncManager.me().execute(AsyncFactory.recordLogininfor(username, Constants.LOGIN_FAIL,
                MessageUtils.message("user.password.delete")));
            throw new UserDeleteException();
        }

        if (UserStatus.DISABLE.getCode().equals(user.getStatus()))
        {
            AsyncManager.me().execute(AsyncFactory.recordLogininfor(username, Constants.LOGIN_FAIL,
                MessageUtils.message("user.blocked")));
            throw new UserBlockedException();
        }

        if (!isValidUserRole(user))
        {
            AsyncManager.me().execute(AsyncFactory.recordLogininfor(username, Constants.LOGIN_FAIL,
                MessageUtils.message("role.not.allowed")));
            throw new RoleNotAllowedException();
        }

        passwordService.validate(user, password);

        AsyncManager.me().execute(AsyncFactory.recordLogininfor(username, Constants.LOGIN_SUCCESS,
            MessageUtils.message("user.login.success")));
        setRolePermission(user);
        recordLoginInfo(user.getUserId());
        return user;
    }

    private boolean maybeMobilePhoneNumber(String username)
    {
        return StringUtils.isNotEmpty(username) && username.matches(UserConstants.MOBILE_PHONE_NUMBER_PATTERN);
    }

    private boolean isAdminLogin(String username)
    {
        return "admin".equalsIgnoreCase(StringUtils.trim(username));
    }

    /**
     * 设置角色权限
     */
    public void setRolePermission(User user)
    {
        List<Role> roles = user.getRoles();
        if (!roles.isEmpty())
        {
            for (Role role : roles)
            {
                if (StringUtils.equals(role.getStatus(), UserConstants.ROLE_NORMAL) && !role.isAdmin())
                {
                    Set<String> rolePerms = menuService.selectPermsByRoleId(role.getRoleId());
                    role.setPermissions(rolePerms);
                }
            }
        }
    }

    /**
     * 记录登录信息
     */
    public void recordLoginInfo(Long userId)
    {
        userService.updateLoginInfo(userId, ShiroUtils.getIp(), DateUtils.getNowDate());
    }

    /**
     * 判断用户角色是否有效
     */
    private boolean isValidUserRole(User user)
    {
        if (user.isAdmin())
        {
            return true;
        }

        List<Role> roles = user.getRoles();
        if (roles != null && !roles.isEmpty())
        {
            for (Role role : roles)
            {
                String roleKey = role.getRoleKey();
                if ("admin".equals(roleKey)
                    || "common".equals(roleKey)
                    || "clinic_admin".equals(roleKey)
                    || "doctor".equals(roleKey)
                    || "patient".equals(roleKey))
                {
                    return true;
                }
            }
        }

        return false;
    }
}
