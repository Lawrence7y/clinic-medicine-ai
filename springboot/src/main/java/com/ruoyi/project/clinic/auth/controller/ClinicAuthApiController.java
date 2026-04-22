package com.ruoyi.project.clinic.auth.controller;

import com.google.code.kaptcha.Producer;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.framework.config.RateLimitConfig;
import com.ruoyi.framework.shiro.service.PasswordService;
import com.ruoyi.framework.shiro.service.RegisterService;
import com.ruoyi.framework.shiro.session.OnlineSessionDAO;
import com.ruoyi.framework.web.controller.BaseController;
import com.ruoyi.framework.web.domain.AjaxResult;
import com.ruoyi.project.monitor.online.domain.UserOnline;
import com.ruoyi.project.monitor.online.service.IUserOnlineService;
import com.ruoyi.project.system.config.service.IConfigService;
import com.ruoyi.project.system.user.domain.User;
import com.ruoyi.project.system.user.service.IUserService;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Base64;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.regex.Pattern;
import javax.annotation.Resource;
import javax.imageio.ImageIO;
import org.apache.shiro.SecurityUtils;
import org.apache.shiro.authc.AuthenticationException;
import org.apache.shiro.authc.UsernamePasswordToken;
import org.apache.shiro.session.Session;
import org.apache.shiro.subject.Subject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
public class ClinicAuthApiController extends BaseController
{
    private static final String API_CLIENT_KEY = "api_client_key";
    private static final String LOGIN_ADMIN_ACCOUNT = "admin";
    private static final long CAPTCHA_EXPIRE_MILLIS = 5 * 60 * 1000L;
    private static final Pattern PHONE_PATTERN = Pattern.compile("^1\\d{10}$");
    private static final ConcurrentHashMap<String, CaptchaRecord> CAPTCHA_STORE = new ConcurrentHashMap<String, CaptchaRecord>();
    private static final String MSG_LOGIN_PARAM_INVALID = "登录参数错误";
    private static final String MSG_ACCOUNT_PASSWORD_REQUIRED = "请输入手机号或 admin 账号及密码";
    private static final String MSG_PHONE_OR_ADMIN_ONLY = "仅支持手机号登录，admin 账号除外";
    private static final String MSG_LOGIN_LOCKED_TEMPLATE = "登录失败次数过多，请在 %d 分钟后重试";
    private static final String MSG_LOGIN_FAILED_WITH_REMAINING_TEMPLATE = "账号、密码或验证码错误，剩余尝试次数：%d";
    private static final String MSG_CAPTCHA_REQUIRED = "请输入验证码";
    private static final String MSG_CAPTCHA_EXPIRED = "验证码已过期，请刷新后重试";
    private static final String MSG_CAPTCHA_INVALID = "验证码错误";
    private static final String MSG_CAPTCHA_GENERATE_FAILED = "验证码生成失败，请重试";
    private static final String MSG_SESSION_INIT_FAILED = "会话初始化失败，请重新登录";
    private static final String MSG_SESSION_INVALID = "会话无效，请重新登录";
    private static final String MSG_SESSION_EXPIRED = "会话已过期，请重新登录";
    private static final String MSG_NEED_LOGIN = "请先登录";
    private static final String MSG_SESSION_ID_REQUIRED = "缺少会话 ID";
    private static final String MSG_CANNOT_KICKOUT_CURRENT = "当前会话不能通过该接口强制下线，请使用退出登录";
    private static final String MSG_TARGET_SESSION_OFFLINE = "目标会话已离线";
    private static final String MSG_FORBIDDEN = "暂无权限";
    private static final String MSG_KICKOUT_OTHERS_SUCCESS = "其他会话已强制下线";
    private static final String MSG_SESSION_LIMIT_EXCEEDED = "当前账号在线会话数已达上限，请先下线其他设备后重试";
    private static final String MSG_REGISTER_DISABLED = "未开启自助注册";
    private static final String MSG_USER_INFO_LOAD_FAILED = "用户信息加载失败";
    private static final String MSG_LOGOUT_FAILED = "退出登录失败";
    private static final String MSG_SESSION_KICKOUT_SUCCESS = "会话已强制下线";
    private static final String MSG_PHONE_ALREADY_EXISTS = "手机号已存在";
    private static final String MSG_PHONE_INVALID = "请输入正确的手机号";
    private static final String MSG_EMAIL_ALREADY_EXISTS = "邮箱已存在";
    private static final String MSG_PROFILE_UPDATE_FAILED = "更新个人信息失败";
    private static final String MSG_NEW_PASSWORD_REQUIRED = "请输入新密码";
    private static final String MSG_CURRENT_PASSWORD_REQUIRED = "请输入当前密码";
    private static final String MSG_CURRENT_PASSWORD_INVALID = "当前密码不正确";
    private static final String MSG_NEW_PASSWORD_SAME_AS_OLD = "新密码不能与当前密码相同";
    private static final String MSG_PASSWORD_UPDATE_FAILED = "修改密码失败";
    private static final String MSG_REGISTER_PARAM_INVALID = "注册参数错误";
    private static final String MSG_REGISTER_ADMIN_FORBIDDEN = "admin 账号仅允许后台维护，不能注册";
    private static final String MSG_REGISTER_PHONE_MISMATCH = "注册账号与手机号不一致，请使用同一手机号";
    private static final String MSG_REGISTER_PHONE_ONLY = "注册仅支持手机号";

    @Autowired
    private IUserService userService;

    @Autowired
    private RegisterService registerService;

    @Autowired
    private IConfigService configService;

    @Autowired
    private PasswordService passwordService;

    @Autowired
    private IUserOnlineService userOnlineService;

    @Autowired
    private OnlineSessionDAO onlineSessionDAO;

    @Resource(name = "captchaProducer")
    private Producer captchaProducer;

    @Resource(name = "captchaProducerMath")
    private Producer captchaProducerMath;

    @Value("${shiro.user.captchaEnabled:true}")
    private boolean captchaEnabled;

    @Value("${shiro.user.captchaType:char}")
    private String captchaType;

    @GetMapping("/captcha")
    public AjaxResult getCaptcha()
    {
        cleanupExpiredCaptchas();
        RateLimitConfig rateLimiter = RateLimitConfig.getInstance();
        refreshLoginSecurityPolicy(rateLimiter);

        Map<String, Object> data = new HashMap<String, Object>();
        data.put("captchaEnabled", captchaEnabled);
        data.put("captchaType", resolveCaptchaType());
        data.put("expireSeconds", CAPTCHA_EXPIRE_MILLIS / 1000);
        data.put("maxFailCount", rateLimiter.getMaxFailCount());
        data.put("lockMinutes", Math.max(1L, rateLimiter.getLockDuration() / (60 * 1000)));
        data.put("maxSessionCount", resolveMaxSessionCount());
        data.put("kickoutAfterNewLogin", resolveKickoutAfterNewLogin());

        if (!captchaEnabled)
        {
            return success(data);
        }

        try
        {
            String captchaId = UUID.randomUUID().toString().replace("-", "");
            String code;
            BufferedImage image;

            if ("math".equals(resolveCaptchaType()))
            {
                String capText = captchaProducerMath.createText();
                String expression = capText.substring(0, capText.lastIndexOf("@"));
                code = capText.substring(capText.lastIndexOf("@") + 1);
                image = captchaProducerMath.createImage(expression);
            }
            else
            {
                code = captchaProducer.createText();
                image = captchaProducer.createImage(code);
            }

            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            ImageIO.write(image, "jpg", outputStream);
            CAPTCHA_STORE.put(captchaId, new CaptchaRecord(code, System.currentTimeMillis() + CAPTCHA_EXPIRE_MILLIS));

            data.put("captchaId", captchaId);
            data.put("imageBase64", Base64.getEncoder().encodeToString(outputStream.toByteArray()));
            return success(data);
        }
        catch (Exception e)
        {
            return error(MSG_CAPTCHA_GENERATE_FAILED);
        }
    }

    @PostMapping("/login")
    public AjaxResult login(@RequestBody Map<String, String> params)
    {
        if (params == null)
        {
            return error(MSG_LOGIN_PARAM_INVALID)
                .put("errorType", "INVALID_PARAMS");
        }
        String username = StringUtils.trim(params.get("username"));
        String password = params.get("password");
        if (StringUtils.isEmpty(username) || StringUtils.isEmpty(password))
        {
            return error(MSG_ACCOUNT_PASSWORD_REQUIRED)
                .put("errorType", "INVALID_PARAMS");
        }
        if (!LOGIN_ADMIN_ACCOUNT.equalsIgnoreCase(username) && !PHONE_PATTERN.matcher(username).matches())
        {
            return error(MSG_PHONE_OR_ADMIN_ONLY)
                .put("errorType", "LOGIN_NOT_ALLOWED");
        }

        if (captchaEnabled)
        {
            String captchaError = validateCaptcha(params.get("captchaId"), params.get("captchaCode"));
            if (captchaError != null)
            {
                return error(captchaError)
                    .put("errorType", "CAPTCHA_INVALID");
            }
        }

        RateLimitConfig rateLimiter = RateLimitConfig.getInstance();
        refreshLoginSecurityPolicy(rateLimiter);
        Long lockedUntil = rateLimiter.tryAcquire(username);
        if (lockedUntil != null && lockedUntil > 0)
        {
            long retryAfterSeconds = Math.max(1L, (lockedUntil - System.currentTimeMillis()) / 1000L);
            long minutes = Math.max(1L, (retryAfterSeconds / 60L) + 1L);
            return error(String.format(MSG_LOGIN_LOCKED_TEMPLATE, minutes))
                .put("errorType", "ACCOUNT_LOCKED")
                .put("remainingAttempts", 0)
                .put("maxFailCount", rateLimiter.getMaxFailCount())
                .put("retryAfterSeconds", retryAfterSeconds)
                .put("lockedUntil", lockedUntil);
        }
        int maxSessionCount = resolveMaxSessionCount();
        boolean kickoutAfterNewLogin = resolveKickoutAfterNewLogin();
        int onlineSessionCount = countValidSessions(queryUserSessions(username));
        if (!kickoutAfterNewLogin && onlineSessionCount >= maxSessionCount)
        {
            return error(MSG_SESSION_LIMIT_EXCEEDED)
                .put("errorType", "SESSION_LIMIT_EXCEEDED")
                .put("maxSessionCount", maxSessionCount)
                .put("onlineSessionCount", onlineSessionCount);
        }

        UsernamePasswordToken token = new UsernamePasswordToken(username, password, false);
        Subject subject = SecurityUtils.getSubject();
        try
        {
            subject.login(token);
            User user = getSysUser();
            Session session = subject.getSession();
            if (session == null)
            {
                return error(MSG_SESSION_INIT_FAILED);
            }

            rateLimiter.clearFailure(username);

            Map<String, Object> data = new HashMap<String, Object>();
            String clientKey = UUID.randomUUID().toString().replace("-", "");
            session.setAttribute(API_CLIENT_KEY, clientKey);
            int kickedSessionCount = kickoutAfterNewLogin
                ? enforceSessionLimitByKickout(user, String.valueOf(session.getId()), maxSessionCount)
                : 0;
            data.put("token", session.getId().toString());
            data.put("clientKey", clientKey);
            appendTokenLifecycle(data, session);
            data.put("userInfo", convertUserInfo(user));
            data.put("maxSessionCount", maxSessionCount);
            data.put("kickoutAfterNewLogin", kickoutAfterNewLogin);
            data.put("kickedSessionCount", kickedSessionCount);
            return success(data);
        }
        catch (AuthenticationException e)
        {
            rateLimiter.recordFailure(username);
            Long lockedUntilAfterFailure = rateLimiter.tryAcquire(username);
            if (lockedUntilAfterFailure != null && lockedUntilAfterFailure > 0)
            {
                long retryAfterSeconds = Math.max(1L, (lockedUntilAfterFailure - System.currentTimeMillis()) / 1000L);
                long minutes = Math.max(1L, (retryAfterSeconds / 60L) + 1L);
                return error(String.format(MSG_LOGIN_LOCKED_TEMPLATE, minutes))
                    .put("errorType", "ACCOUNT_LOCKED")
                    .put("remainingAttempts", 0)
                    .put("maxFailCount", rateLimiter.getMaxFailCount())
                    .put("retryAfterSeconds", retryAfterSeconds)
                    .put("lockedUntil", lockedUntilAfterFailure);
            }

            int remainingAttempts = Math.max(0, rateLimiter.getRemainingAttempts(username));
            return error(String.format(MSG_LOGIN_FAILED_WITH_REMAINING_TEMPLATE, remainingAttempts))
                .put("errorType", "LOGIN_FAILED")
                .put("maxFailCount", rateLimiter.getMaxFailCount())
                .put("remainingAttempts", remainingAttempts);
        }
    }

    @GetMapping("/getInfo")
    public AjaxResult getInfo()
    {
        try
        {
            User user = getSysUser();
            return success(convertUserInfo(user));
        }
        catch (Exception e)
        {
            return error(MSG_USER_INFO_LOAD_FAILED);
        }
    }

    @PostMapping("/logout")
    public AjaxResult logout()
    {
        try
        {
            SecurityUtils.getSubject().logout();
            return success();
        }
        catch (Exception e)
        {
            return error(MSG_LOGOUT_FAILED);
        }
    }

    @PostMapping("/refreshToken")
    public AjaxResult refreshToken()
    {
        Subject subject = SecurityUtils.getSubject();
        User user = getSysUser();
        if (user == null)
        {
            return error(MSG_SESSION_INVALID);
        }

        Session session = subject.getSession(false);
        if (session == null)
        {
            return error(MSG_SESSION_EXPIRED);
        }
        session.touch();

        Map<String, Object> data = new HashMap<String, Object>();
        data.put("token", session.getId().toString());
        Object clientKey = session.getAttribute(API_CLIENT_KEY);
        if (clientKey != null)
        {
            data.put("clientKey", String.valueOf(clientKey));
        }
        appendTokenLifecycle(data, session);
        return success(data);
    }

    @GetMapping("/session/list")
    public AjaxResult sessionList()
    {
        User currentUser = getSysUser();
        if (currentUser == null)
        {
            return error(MSG_NEED_LOGIN);
        }

        Session currentSession = SecurityUtils.getSubject().getSession(false);
        String currentSessionId = currentSession != null ? String.valueOf(currentSession.getId()) : "";
        List<UserOnline> sessions = queryUserSessions(currentUser.getLoginName());
        List<Map<String, Object>> rows = new ArrayList<Map<String, Object>>();
        for (UserOnline item : sessions)
        {
            if (item == null || StringUtils.isEmpty(item.getSessionId()))
            {
                continue;
            }
            Map<String, Object> row = new HashMap<String, Object>();
            row.put("sessionId", item.getSessionId());
            row.put("current", item.getSessionId().equals(currentSessionId));
            row.put("ipaddr", item.getIpaddr());
            row.put("loginLocation", item.getLoginLocation());
            row.put("browser", item.getBrowser());
            row.put("os", item.getOs());
            row.put("status", item.getStatus() != null ? item.getStatus().name() : "on_line");
            row.put("startTimestamp", item.getStartTimestamp());
            row.put("lastAccessTime", item.getLastAccessTime());
            row.put("expireTime", item.getExpireTime());
            rows.add(row);
        }

        Collections.sort(rows, new Comparator<Map<String, Object>>()
        {
            @Override
            public int compare(Map<String, Object> a, Map<String, Object> b)
            {
                Object at = a.get("lastAccessTime");
                Object bt = b.get("lastAccessTime");
                if (at == null && bt == null)
                {
                    return 0;
                }
                if (at == null)
                {
                    return 1;
                }
                if (bt == null)
                {
                    return -1;
                }
                return String.valueOf(bt).compareTo(String.valueOf(at));
            }
        });

        Map<String, Object> data = new HashMap<String, Object>();
        data.put("currentSessionId", currentSessionId);
        data.put("sessions", rows);
        data.put("total", rows.size());
        data.put("maxSessionCount", resolveMaxSessionCount());
        data.put("kickoutAfterNewLogin", resolveKickoutAfterNewLogin());
        return success(data);
    }

    @PostMapping("/session/kickout")
    public AjaxResult kickoutSession(@RequestBody(required = false) Map<String, String> params)
    {
        User currentUser = getSysUser();
        if (currentUser == null)
        {
            return error(MSG_NEED_LOGIN);
        }
        String sessionId = params != null ? StringUtils.trim(params.get("sessionId")) : null;
        if (StringUtils.isEmpty(sessionId))
        {
            return error(MSG_SESSION_ID_REQUIRED);
        }
        String currentSessionId = String.valueOf(SecurityUtils.getSubject().getSession().getId());
        if (sessionId.equals(currentSessionId))
        {
            return error(MSG_CANNOT_KICKOUT_CURRENT);
        }

        UserOnline online = userOnlineService.selectOnlineById(sessionId);
        if (online == null)
        {
            return error(MSG_TARGET_SESSION_OFFLINE);
        }

        boolean isOwner = StringUtils.equals(currentUser.getLoginName(), online.getLoginName());
        if (!isOwner && !currentUser.isAdmin())
        {
            return error(MSG_FORBIDDEN);
        }

        forceSessionOffline(online);
        return success(MSG_SESSION_KICKOUT_SUCCESS);
    }

    @PostMapping("/session/kickoutOthers")
    public AjaxResult kickoutOthers()
    {
        User currentUser = getSysUser();
        if (currentUser == null)
        {
            return error(MSG_NEED_LOGIN);
        }

        String currentSessionId = String.valueOf(SecurityUtils.getSubject().getSession().getId());
        List<UserOnline> sessions = queryUserSessions(currentUser.getLoginName());
        int kickedCount = 0;
        for (UserOnline online : sessions)
        {
            if (online == null || StringUtils.isEmpty(online.getSessionId()))
            {
                continue;
            }
            if (online.getSessionId().equals(currentSessionId))
            {
                continue;
            }
            forceSessionOffline(online);
            kickedCount++;
        }

        Map<String, Object> data = new HashMap<String, Object>();
        data.put("kickedCount", kickedCount);
        data.put("currentSessionId", currentSessionId);
        return AjaxResult.success(MSG_KICKOUT_OTHERS_SUCCESS, data);
    }

    @PostMapping("/register")
    public AjaxResult register(@RequestBody Map<String, String> params)
    {
        if (params == null)
        {
            return error(MSG_REGISTER_PARAM_INVALID);
        }
        if (!("true".equals(configService.selectConfigByKey("sys.account.registerUser"))))
        {
            return error(MSG_REGISTER_DISABLED);
        }
        String registerPhone;
        try
        {
            registerPhone = normalizeRegisterPhone(params.get("username"), params.get("phonenumber"));
        }
        catch (IllegalArgumentException ex)
        {
            return error(ex.getMessage());
        }
        User user = new User();
        user.setLoginName(registerPhone);
        user.setPassword(params.get("password"));
        String userName = params.get("userName");
        String nickName = params.get("nickName");
        if (StringUtils.isNotEmpty(userName))
        {
            user.setUserName(userName);
        }
        else if (StringUtils.isNotEmpty(nickName))
        {
            user.setUserName(nickName);
        }
        else
        {
            user.setUserName(user.getLoginName());
        }
        user.setPhonenumber(registerPhone);
        String msg = registerService.register(user);
        return StringUtils.isEmpty(msg) ? success() : error(msg);
    }

    @PostMapping("/profile/update")
    public AjaxResult updateProfile(@RequestBody Map<String, Object> params)
    {
        User currentUser = getSysUser();
        if (currentUser == null)
        {
            return error(MSG_NEED_LOGIN);
        }
        if (params == null)
        {
            return error(MSG_LOGIN_PARAM_INVALID);
        }
        try
        {
            String newUserName = null;
            if (params.containsKey("userName"))
            {
                newUserName = String.valueOf(params.get("userName"));
            }
            else if (params.containsKey("nickName"))
            {
                newUserName = String.valueOf(params.get("nickName"));
            }
            if (StringUtils.isNotEmpty(newUserName))
            {
                currentUser.setUserName(newUserName);
            }
            if (params.containsKey("phonenumber"))
            {
                String normalizedPhone = normalizeProfilePhone(String.valueOf(params.get("phonenumber")), currentUser);
                currentUser.setPhonenumber(normalizedPhone);
            }
            if (params.containsKey("email"))
            {
                currentUser.setEmail(String.valueOf(params.get("email")));
            }
            if (params.containsKey("sex"))
            {
                currentUser.setSex(String.valueOf(params.get("sex")));
            }
            if (params.containsKey("avatar") && params.get("avatar") != null)
            {
                currentUser.setAvatar(String.valueOf(params.get("avatar")));
            }
            if (StringUtils.isNotEmpty(currentUser.getPhonenumber()) && !userService.checkPhoneUnique(currentUser))
            {
                return error(MSG_PHONE_ALREADY_EXISTS);
            }
            if (StringUtils.isNotEmpty(currentUser.getEmail()) && !userService.checkEmailUnique(currentUser))
            {
                return error(MSG_EMAIL_ALREADY_EXISTS);
            }
            if (userService.updateUserInfo(currentUser) > 0)
            {
                setSysUser(userService.selectUserById(currentUser.getUserId()));
                return success(convertUserInfo(getSysUser()));
            }
            return error(MSG_PROFILE_UPDATE_FAILED);
        }
        catch (IllegalArgumentException ex)
        {
            return error(ex.getMessage());
        }
    }

    @PostMapping("/profile/resetPwd")
    public AjaxResult resetPwd(@RequestBody Map<String, String> params)
    {
        if (params == null)
        {
            return error(MSG_LOGIN_PARAM_INVALID);
        }
        String oldPassword = params.get("oldPassword");
        String newPassword = params.get("newPassword");
        if (StringUtils.isEmpty(newPassword))
        {
            return error(MSG_NEW_PASSWORD_REQUIRED);
        }
        User user = getSysUser();
        if (user == null)
        {
            return error(MSG_NEED_LOGIN);
        }
        if (StringUtils.isNotEmpty(oldPassword))
        {
            if (!passwordService.matches(user, oldPassword))
            {
                return error(MSG_CURRENT_PASSWORD_INVALID);
            }
            if (passwordService.matches(user, newPassword))
            {
                return error(MSG_NEW_PASSWORD_SAME_AS_OLD);
            }
        }
        else
        {
            return error(MSG_CURRENT_PASSWORD_REQUIRED);
        }
        user.setPassword(newPassword);
        if (userService.resetUserPwd(user) > 0)
        {
            setSysUser(userService.selectUserById(user.getUserId()));
            return success();
        }
        return error(MSG_PASSWORD_UPDATE_FAILED);
    }

    private String normalizeRegisterPhone(String username, String phonenumber)
    {
        String normalizedPhone = StringUtils.trim(phonenumber);
        String normalizedUsername = StringUtils.trim(username);
        if (StringUtils.isEmpty(normalizedPhone) && StringUtils.isEmpty(normalizedUsername))
        {
            throw new IllegalArgumentException(MSG_REGISTER_PHONE_ONLY);
        }
        if (StringUtils.isNotEmpty(normalizedPhone) && StringUtils.isNotEmpty(normalizedUsername)
            && !StringUtils.equals(normalizedPhone, normalizedUsername))
        {
            throw new IllegalArgumentException(MSG_REGISTER_PHONE_MISMATCH);
        }
        String account = StringUtils.isNotEmpty(normalizedPhone) ? normalizedPhone : normalizedUsername;
        if (LOGIN_ADMIN_ACCOUNT.equalsIgnoreCase(account))
        {
            throw new IllegalArgumentException(MSG_REGISTER_ADMIN_FORBIDDEN);
        }
        if (!PHONE_PATTERN.matcher(account).matches())
        {
            throw new IllegalArgumentException(MSG_REGISTER_PHONE_ONLY);
        }
        return account;
    }

    private String normalizeProfilePhone(String phonenumber, User currentUser)
    {
        String normalizedPhone = StringUtils.trim(phonenumber);
        if (StringUtils.isEmpty(normalizedPhone))
        {
            return normalizedPhone;
        }
        if (LOGIN_ADMIN_ACCOUNT.equalsIgnoreCase(currentUser != null ? currentUser.getLoginName() : null))
        {
            return normalizedPhone;
        }
        if (!PHONE_PATTERN.matcher(normalizedPhone).matches())
        {
            throw new IllegalArgumentException(MSG_PHONE_INVALID);
        }
        return normalizedPhone;
    }

    private Map<String, Object> convertUserInfo(User user)
    {
        Map<String, Object> userInfo = new HashMap<String, Object>();
        userInfo.put("userId", user.getUserId());
        userInfo.put("userName", user.getUserName());
        userInfo.put("nickName", user.getUserName());
        userInfo.put("loginName", user.getLoginName());
        userInfo.put("phonenumber", user.getPhonenumber());
        userInfo.put("email", user.getEmail());
        userInfo.put("avatar", user.getAvatar());
        userInfo.put("sex", user.getSex());
        userInfo.put("status", user.getStatus());
        userInfo.put("createTime", user.getCreateTime());

        if (user.getRoles() != null && !user.getRoles().isEmpty())
        {
            userInfo.put("roleKey", user.getRoles().get(0).getRoleKey());
            userInfo.put("roleName", user.getRoles().get(0).getRoleName());
        }
        else
        {
            userInfo.put("roleKey", "");
            userInfo.put("roleName", "");
        }
        return userInfo;
    }

    private void appendTokenLifecycle(Map<String, Object> data, Session session)
    {
        if (data == null || session == null)
        {
            return;
        }
        long timeout = session.getTimeout();
        if (timeout < 0 || session.getLastAccessTime() == null)
        {
            data.put("expireAt", -1L);
            data.put("expiresIn", -1L);
            return;
        }
        long expireAt = session.getLastAccessTime().getTime() + timeout;
        long expiresIn = Math.max(0L, (expireAt - System.currentTimeMillis()) / 1000L);
        data.put("expireAt", expireAt);
        data.put("expiresIn", expiresIn);
    }

    private String validateCaptcha(String captchaId, String captchaCode)
    {
        cleanupExpiredCaptchas();
        if (StringUtils.isEmpty(captchaId) || StringUtils.isEmpty(captchaCode))
        {
            return MSG_CAPTCHA_REQUIRED;
        }

        CaptchaRecord record = CAPTCHA_STORE.remove(captchaId);
        if (record == null || record.isExpired())
        {
            return MSG_CAPTCHA_EXPIRED;
        }
        if (!StringUtils.equalsIgnoreCase(record.getCode(), captchaCode.trim()))
        {
            return MSG_CAPTCHA_INVALID;
        }
        return null;
    }

    private void cleanupExpiredCaptchas()
    {
        long now = System.currentTimeMillis();
        Iterator<Map.Entry<String, CaptchaRecord>> iterator = CAPTCHA_STORE.entrySet().iterator();
        while (iterator.hasNext())
        {
            Map.Entry<String, CaptchaRecord> entry = iterator.next();
            if (entry.getValue() == null || entry.getValue().getExpireAt() <= now)
            {
                iterator.remove();
            }
        }
    }

    private String resolveCaptchaType()
    {
        return "math".equalsIgnoreCase(captchaType) ? "math" : "char";
    }

    private void refreshLoginSecurityPolicy(RateLimitConfig rateLimiter)
    {
        if (rateLimiter == null)
        {
            return;
        }
        int maxFailCount = parseIntOrDefault(configService.selectConfigByKey("clinic.loginMaxFailCount"), 5);
        int lockMinutes = parseIntOrDefault(configService.selectConfigByKey("clinic.loginLockMinutes"), 5);
        rateLimiter.setPolicy(maxFailCount, lockMinutes * 60L * 1000L);
    }

    private int parseIntOrDefault(String value, int defaultValue)
    {
        if (StringUtils.isEmpty(value))
        {
            return defaultValue;
        }
        try
        {
            return Integer.parseInt(value.trim());
        }
        catch (Exception ignored)
        {
            return defaultValue;
        }
    }

    private boolean parseBooleanOrDefault(String value, boolean defaultValue)
    {
        if (StringUtils.isEmpty(value))
        {
            return defaultValue;
        }
        String normalized = value.trim();
        if ("true".equalsIgnoreCase(normalized))
        {
            return true;
        }
        if ("false".equalsIgnoreCase(normalized))
        {
            return false;
        }
        return defaultValue;
    }

    private int resolveMaxSessionCount()
    {
        int configured = parseIntOrDefault(configService.selectConfigByKey("clinic.maxSessionCount"), 2);
        if (configured < 1)
        {
            return 1;
        }
        if (configured > 10)
        {
            return 10;
        }
        return configured;
    }

    private int countValidSessions(List<UserOnline> sessions)
    {
        if (sessions == null || sessions.isEmpty())
        {
            return 0;
        }
        int count = 0;
        for (UserOnline session : sessions)
        {
            if (session != null && StringUtils.isNotEmpty(session.getSessionId()))
            {
                count++;
            }
        }
        return count;
    }

    private int enforceSessionLimitByKickout(User currentUser, String currentSessionId, int maxSessionCount)
    {
        if (currentUser == null || maxSessionCount < 1)
        {
            return 0;
        }
        List<UserOnline> sessions = queryUserSessions(currentUser.getLoginName());
        if (sessions == null || sessions.isEmpty())
        {
            return 0;
        }

        List<UserOnline> sorted = new ArrayList<UserOnline>();
        for (UserOnline session : sessions)
        {
            if (session != null && StringUtils.isNotEmpty(session.getSessionId()))
            {
                sorted.add(session);
            }
        }
        if (sorted.size() <= maxSessionCount)
        {
            return 0;
        }

        Collections.sort(sorted, new Comparator<UserOnline>()
        {
            @Override
            public int compare(UserOnline a, UserOnline b)
            {
                int priorityCompare = Integer.compare(resolveSessionPriority(a, currentSessionId),
                    resolveSessionPriority(b, currentSessionId));
                if (priorityCompare != 0)
                {
                    return priorityCompare;
                }
                return Long.compare(resolveSessionSortTime(b), resolveSessionSortTime(a));
            }
        });

        int kickedCount = 0;
        for (int i = maxSessionCount; i < sorted.size(); i++)
        {
            UserOnline online = sorted.get(i);
            if (online == null || StringUtils.isEmpty(online.getSessionId()))
            {
                continue;
            }
            if (StringUtils.equals(online.getSessionId(), currentSessionId))
            {
                continue;
            }
            forceSessionOffline(online);
            kickedCount++;
        }
        return kickedCount;
    }

    private int resolveSessionPriority(UserOnline session, String currentSessionId)
    {
        if (session == null || StringUtils.isEmpty(session.getSessionId()))
        {
            return 3;
        }
        if (StringUtils.equals(session.getSessionId(), currentSessionId))
        {
            return 0;
        }
        if (session.getStatus() != null && "on_line".equalsIgnoreCase(session.getStatus().name()))
        {
            return 1;
        }
        return 2;
    }

    private long resolveSessionSortTime(UserOnline session)
    {
        if (session == null)
        {
            return 0L;
        }
        Date lastAccessTime = session.getLastAccessTime();
        if (lastAccessTime != null)
        {
            return lastAccessTime.getTime();
        }
        Date startTimestamp = session.getStartTimestamp();
        return startTimestamp != null ? startTimestamp.getTime() : 0L;
    }

    private boolean resolveKickoutAfterNewLogin()
    {
        return parseBooleanOrDefault(configService.selectConfigByKey("clinic.kickoutAfterNewLogin"), false);
    }

    private List<UserOnline> queryUserSessions(String loginName)
    {
        if (StringUtils.isEmpty(loginName))
        {
            return Collections.emptyList();
        }
        UserOnline query = new UserOnline();
        query.setLoginName(loginName);
        List<UserOnline> rows = userOnlineService.selectUserOnlineList(query);
        if (rows == null || rows.isEmpty())
        {
            return Collections.emptyList();
        }

        List<UserOnline> filtered = new ArrayList<UserOnline>();
        for (UserOnline row : rows)
        {
            if (row != null && StringUtils.equals(loginName, row.getLoginName()))
            {
                filtered.add(row);
            }
        }
        return filtered;
    }

    private void forceSessionOffline(UserOnline online)
    {
        if (online == null || StringUtils.isEmpty(online.getSessionId()))
        {
            return;
        }
        String sessionId = online.getSessionId();
        userOnlineService.forceLogout(sessionId);
        userOnlineService.removeUserCache(online.getLoginName(), sessionId);
        Serializable sid = sessionId;
        try
        {
            Session session = onlineSessionDAO.readSession(sid);
            if (session != null)
            {
                session.setAttribute("kickout", true);
            }
        }
        catch (Exception ignored)
        {
            // ignore if session already not available
        }
    }

    private static final class CaptchaRecord
    {
        private final String code;
        private final long expireAt;

        private CaptchaRecord(String code, long expireAt)
        {
            this.code = code;
            this.expireAt = expireAt;
        }

        public String getCode()
        {
            return code;
        }

        public long getExpireAt()
        {
            return expireAt;
        }

        public boolean isExpired()
        {
            return expireAt <= System.currentTimeMillis();
        }
    }
}
