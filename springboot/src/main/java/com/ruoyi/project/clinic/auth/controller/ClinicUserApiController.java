package com.ruoyi.project.clinic.auth.controller;

import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.framework.web.controller.BaseController;
import com.ruoyi.framework.web.domain.AjaxResult;
import com.ruoyi.framework.web.page.TableDataInfo;
import com.ruoyi.project.clinic.common.ClinicSecuritySupport;
import com.ruoyi.project.system.role.domain.Role;
import com.ruoyi.project.system.role.service.IRoleService;
import com.ruoyi.project.system.user.domain.User;
import com.ruoyi.project.system.user.mapper.UserMapper;
import com.ruoyi.project.system.user.service.IUserService;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
@RequestMapping("/api/clinic/user")
public class ClinicUserApiController extends BaseController
{
    private static final Set<String> SUPPORTED_ROLE_KEYS = ClinicSecuritySupport.SUPPORTED_ROLE_KEYS;
    private static final Pattern PHONE_PATTERN = Pattern.compile("^1\\d{10}$");
    private static final String LOGIN_ADMIN_ACCOUNT = "admin";
    private static final String MSG_NO_PERMISSION = "无权限访问";
    private static final String MSG_PARAM_INVALID = "参数错误";
    private static final String MSG_ACCOUNT_REQUIRED = "请输入手机号或 admin 账号";
    private static final String MSG_ACCOUNT_ONLY_PHONE_OR_ADMIN = "仅支持手机号登录，admin 账号除外";
    private static final String MSG_PHONE_INVALID = "请输入正确的手机号";
    private static final String MSG_ROLE_INVALID = "角色无效";
    private static final String MSG_ROLE_REQUIRED = "请至少分配一个角色";
    private static final String MSG_ROLE_UNSUPPORTED = "不支持的角色";

    @Autowired
    private IUserService userService;

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private IRoleService roleService;

    @GetMapping("/doctors")
    @ResponseBody
    public AjaxResult getDoctors()
    {
        List<User> allUsers = selectUsersWithoutDataScope(new User());

        List<Map<String, Object>> doctorList = new ArrayList<>();
        for (User user : allUsers)
        {
            Set<String> roleKeys = getRoleKeys(user);
            if (!ClinicSecuritySupport.isDoctor(roleKeys))
            {
                continue;
            }

            Map<String, Object> doctorInfo = new HashMap<>();
            doctorInfo.put("userId", user.getUserId());
            doctorInfo.put("userName", user.getUserName());
            doctorInfo.put("nickName", user.getUserName());
            doctorInfo.put("name", user.getUserName());
            doctorInfo.put("phone", user.getPhonenumber());
            doctorInfo.put("phonenumber", user.getPhonenumber());
            doctorInfo.put("avatar", user.getAvatar());
            doctorInfo.put("email", user.getEmail());
            doctorList.add(doctorInfo);
        }

        return AjaxResult.success(doctorList);
    }

    @GetMapping("/roles")
    @ResponseBody
    public AjaxResult getRoles()
    {
        Map<String, Map<String, Object>> roleMap = new LinkedHashMap<>();
        for (Role role : roleService.selectRoleAll())
        {
            String normalizedRoleKey = ClinicSecuritySupport.normalizeRoleKey(role.getRoleKey());
            if (!SUPPORTED_ROLE_KEYS.contains(normalizedRoleKey) || roleMap.containsKey(normalizedRoleKey))
            {
                continue;
            }
            roleMap.put(normalizedRoleKey, convertRoleInfo(role));
        }
        return AjaxResult.success(new ArrayList<>(roleMap.values()));
    }

    @PostMapping("/list")
    @ResponseBody
    public TableDataInfo list(@RequestBody(required = false) UserListQuery query)
    {
        if (query == null)
        {
            query = new UserListQuery();
        }

        Set<String> callerRoleKeys = getCallerAdminRoleKeys();
        if (callerRoleKeys.isEmpty())
        {
            return deniedTable(403, MSG_NO_PERMISSION);
        }

        int pageNum = query.getPageNum() != null ? query.getPageNum() : 1;
        int pageSize = query.getPageSize() != null ? query.getPageSize() : 10;
        if (pageSize > 200)
        {
            pageSize = 200;
        }

        User user = new User();
        user.setUserName(query.getUserName());
        user.setPhonenumber(query.getPhonenumber());

        List<User> list = selectUsersVisibleToCaller(user, callerRoleKeys);
        List<User> filteredList = new ArrayList<>();
        for (User item : list)
        {
            if (matchesRoleFilter(item, query.getRoleKey()))
            {
                filteredList.add(item);
            }
        }

        int total = filteredList.size();
        int fromIndex = Math.max((pageNum - 1) * pageSize, 0);
        int toIndex = Math.min(fromIndex + pageSize, total);
        List<User> pageList = fromIndex >= total ? new ArrayList<>() : filteredList.subList(fromIndex, toIndex);
        List<Map<String, Object>> resultList = new ArrayList<>();
        for (User item : pageList)
        {
            resultList.add(convertUserInfo(item));
        }

        TableDataInfo tableDataInfo = new TableDataInfo();
        tableDataInfo.setCode(0);
        tableDataInfo.setRows(resultList);
        tableDataInfo.setTotal(total);
        return tableDataInfo;
    }

    @GetMapping("/getInfo")
    @ResponseBody
    public AjaxResult getInfo(@RequestParam("userId") Long userId)
    {
        if (userId == null)
        {
            return AjaxResult.error(MSG_PARAM_INVALID);
        }

        Set<String> callerRoleKeys = getCallerAdminRoleKeys();
        if (callerRoleKeys.isEmpty())
        {
            return AjaxResult.error(MSG_NO_PERMISSION);
        }

        User user = selectScopedUserById(userId);
        if (user == null)
        {
            return AjaxResult.error(MSG_NO_PERMISSION);
        }
        return AjaxResult.success(convertUserInfo(user));
    }

    @PostMapping("/add")
    @ResponseBody
    public AjaxResult addSave(@RequestBody Map<String, Object> params)
    {
        Set<String> callerRoleKeys = getCallerAdminRoleKeys();
        if (callerRoleKeys.isEmpty())
        {
            return AjaxResult.error(MSG_NO_PERMISSION);
        }

        try
        {
            User user = buildUserFromParams(params, false, callerRoleKeys, null, null);
            return toAjax(userService.insertUser(user));
        }
        catch (IllegalArgumentException ex)
        {
            return AjaxResult.error(ex.getMessage());
        }
    }

    @PostMapping("/edit")
    @ResponseBody
    public AjaxResult editSave(@RequestBody Map<String, Object> params)
    {
        Set<String> callerRoleKeys = getCallerAdminRoleKeys();
        if (callerRoleKeys.isEmpty())
        {
            return AjaxResult.error(MSG_NO_PERMISSION);
        }

        Long userId = parseLong(params.get("userId"));
        if (userId == null)
        {
            return AjaxResult.error(MSG_PARAM_INVALID);
        }

        User targetUser = selectScopedUserById(userId);
        if (targetUser == null)
        {
            return AjaxResult.error(MSG_NO_PERMISSION);
        }
        if (ClinicSecuritySupport.isClinicAdmin(callerRoleKeys) && userHasPrivilegedManagementRole(targetUser))
        {
            return AjaxResult.error("诊所管理员不能修改管理员账号");
        }

        try
        {
            User user = buildUserFromParams(params, true, callerRoleKeys, extractRoleIds(targetUser), targetUser);
            if (ClinicSecuritySupport.isClinicAdmin(callerRoleKeys) && containsPrivilegedManagementRole(user.getRoleIds()))
            {
                return AjaxResult.error("诊所管理员只能分配医生或患者角色");
            }
            return toAjax(userService.updateUser(user));
        }
        catch (IllegalArgumentException ex)
        {
            return AjaxResult.error(ex.getMessage());
        }
    }

    @PostMapping("/remove")
    @ResponseBody
    public AjaxResult remove(@RequestBody(required = false) Map<String, String> params)
    {
        Set<String> callerRoleKeys = getCallerAdminRoleKeys();
        if (callerRoleKeys.isEmpty())
        {
            return AjaxResult.error(MSG_NO_PERMISSION);
        }

        String ids = params != null ? params.get("ids") : null;
        if (StringUtils.isEmpty(ids))
        {
            return error("请提供要删除的用户ID");
        }

        for (String idText : ids.split(","))
        {
            Long userId = parseLong(idText);
            if (userId == null)
            {
                continue;
            }

            User targetUser = selectScopedUserById(userId);
            if (targetUser == null)
            {
                return AjaxResult.error(MSG_NO_PERMISSION);
            }
            if (ClinicSecuritySupport.isClinicAdmin(callerRoleKeys) && userHasPrivilegedManagementRole(targetUser))
            {
                return AjaxResult.error("诊所管理员不能删除管理员账号");
            }
        }

        return toAjax(userService.deleteUserByIds(ids));
    }

    @PostMapping("/resetPwd")
    @ResponseBody
    public AjaxResult resetPwd(@RequestBody Map<String, Object> params)
    {
        Set<String> callerRoleKeys = getCallerAdminRoleKeys();
        if (callerRoleKeys.isEmpty())
        {
            return AjaxResult.error(MSG_NO_PERMISSION);
        }

        Long userId = parseLong(params.get("userId"));
        String newPassword = getString(params, "newPassword");
        if (userId == null || StringUtils.isEmpty(newPassword))
        {
            return error(MSG_PARAM_INVALID);
        }

        User targetUser = selectScopedUserById(userId);
        if (targetUser == null)
        {
            return error(MSG_NO_PERMISSION);
        }
        if (ClinicSecuritySupport.isClinicAdmin(callerRoleKeys) && userHasPrivilegedManagementRole(targetUser))
        {
            return AjaxResult.error("诊所管理员不能重置管理员密码");
        }

        targetUser.setPassword(newPassword);
        return toAjax(userService.resetUserPwd(targetUser));
    }

    private Set<String> getCallerAdminRoleKeys()
    {
        User currentUser = getSysUser();
        if (currentUser == null)
        {
            return new LinkedHashSet<>();
        }

        Set<String> callerRoleKeys = getRoleKeys(currentUser);
        if (!ClinicSecuritySupport.isAdmin(callerRoleKeys))
        {
            return new LinkedHashSet<>();
        }
        return callerRoleKeys;
    }

    private User buildUserFromParams(Map<String, Object> params, boolean includeUserId, Set<String> callerRoleKeys,
        Long[] fallbackRoleIds, User existingUser)
    {
        User user = new User();
        if (includeUserId)
        {
            Long userId = parseLong(params.get("userId"));
            if (userId != null)
            {
                user.setUserId(userId);
            }
        }

        String loginName = getString(params, "loginName");
        String phone = getString(params, "phonenumber");
        if (StringUtils.isEmpty(loginName) && StringUtils.isEmpty(phone) && existingUser != null)
        {
            loginName = existingUser.getLoginName();
            phone = existingUser.getPhonenumber();
        }
        String account = StringUtils.isNotEmpty(loginName) ? loginName : phone;
        String normalizedLoginName = normalizeLoginAccount(account);
        user.setLoginName(normalizedLoginName);
        user.setUserName(getString(params, "userName"));
        user.setPhonenumber(resolvePhoneForAccount(phone, normalizedLoginName, existingUser));
        user.setPassword(getString(params, "password"));
        user.setSex(getString(params, "sex"));
        user.setEmail(getString(params, "email"));
        user.setRoleIds(resolveRoleIds(params, callerRoleKeys, fallbackRoleIds));
        return user;
    }

    private String normalizeLoginAccount(String account)
    {
        String normalized = StringUtils.trim(account);
        if (StringUtils.isEmpty(normalized))
        {
            throw new IllegalArgumentException(MSG_ACCOUNT_REQUIRED);
        }
        if (LOGIN_ADMIN_ACCOUNT.equalsIgnoreCase(normalized))
        {
            return LOGIN_ADMIN_ACCOUNT;
        }
        if (!PHONE_PATTERN.matcher(normalized).matches())
        {
            throw new IllegalArgumentException(MSG_ACCOUNT_ONLY_PHONE_OR_ADMIN);
        }
        return normalized;
    }

    private String resolvePhoneForAccount(String phone, String normalizedLoginName, User existingUser)
    {
        String normalizedPhone = StringUtils.trim(phone);
        if (LOGIN_ADMIN_ACCOUNT.equalsIgnoreCase(normalizedLoginName))
        {
            if (StringUtils.isNotEmpty(normalizedPhone))
            {
                return normalizedPhone;
            }
            if (existingUser != null && StringUtils.isNotEmpty(existingUser.getPhonenumber()))
            {
                return existingUser.getPhonenumber();
            }
            return LOGIN_ADMIN_ACCOUNT;
        }

        if (StringUtils.isEmpty(normalizedPhone))
        {
            if (existingUser != null && StringUtils.isNotEmpty(existingUser.getPhonenumber())
                && PHONE_PATTERN.matcher(existingUser.getPhonenumber()).matches())
            {
                return existingUser.getPhonenumber();
            }
            return normalizedLoginName;
        }
        if (!PHONE_PATTERN.matcher(normalizedPhone).matches())
        {
            throw new IllegalArgumentException(MSG_PHONE_INVALID);
        }
        return normalizedPhone;
    }

    private Long[] resolveRoleIds(Map<String, Object> params, Set<String> callerRoleKeys, Long[] fallbackRoleIds)
    {
        List<Role> allRoles = roleService.selectRoleAll();
        Set<String> assignableRoleKeys = ClinicSecuritySupport.getAssignableRoleKeys(callerRoleKeys);
        Map<Long, Role> rolesById = allRoles.stream()
            .filter(role -> role != null && role.getRoleId() != null)
            .collect(Collectors.toMap(Role::getRoleId, role -> role, (left, right) -> left, LinkedHashMap::new));
        Map<String, Role> rolesByKey = new LinkedHashMap<>();
        for (Role role : allRoles)
        {
            if (role == null)
            {
                continue;
            }
            String normalizedRoleKey = ClinicSecuritySupport.normalizeRoleKey(role.getRoleKey());
            if (StringUtils.isNotEmpty(normalizedRoleKey) && !rolesByKey.containsKey(normalizedRoleKey))
            {
                rolesByKey.put(normalizedRoleKey, role);
            }
        }

        List<Long> explicitRoleIds = extractExplicitRoleIds(params, rolesById, rolesByKey, assignableRoleKeys);
        if (!explicitRoleIds.isEmpty())
        {
            return explicitRoleIds.toArray(new Long[0]);
        }

        return fallbackRoleIds != null ? fallbackRoleIds : new Long[0];
    }

    private List<Long> extractExplicitRoleIds(Map<String, Object> params, Map<Long, Role> rolesById,
        Map<String, Role> rolesByKey, Set<String> assignableRoleKeys)
    {
        List<Long> resolvedRoleIds = new ArrayList<>();
        Set<String> resolvedRoleKeys = new LinkedHashSet<>();
        boolean hasExplicitRoleInput = false;

        Object roleIdsValue = params.get("roleIds");
        if (roleIdsValue instanceof List)
        {
            hasExplicitRoleInput = true;
            List<?> roleIds = (List<?>) roleIdsValue;
            for (Object item : roleIds)
            {
                Long roleId = parseLong(item);
                if (roleId == null)
                {
                    continue;
                }

                Role role = rolesById.get(roleId);
                if (role == null)
                {
                    throw new IllegalArgumentException(MSG_ROLE_INVALID);
                }
                String normalizedRoleKey = ClinicSecuritySupport.normalizeRoleKey(role.getRoleKey());
                validateAssignableRole(normalizedRoleKey, assignableRoleKeys);
                if (resolvedRoleKeys.add(normalizedRoleKey))
                {
                    resolvedRoleIds.add(role.getRoleId());
                }
            }
        }

        Set<String> requestedRoleKeys = new LinkedHashSet<>();
        Object roleKeysValue = params.get("roleKeys");
        if (roleKeysValue instanceof List)
        {
            hasExplicitRoleInput = true;
            List<?> roleKeys = (List<?>) roleKeysValue;
            for (Object item : roleKeys)
            {
                String normalizedRoleKey = ClinicSecuritySupport.normalizeRoleKey(item != null ? item.toString() : null);
                if (StringUtils.isNotEmpty(normalizedRoleKey))
                {
                    requestedRoleKeys.add(normalizedRoleKey);
                }
            }
        }

        String roleKey = ClinicSecuritySupport.normalizeRoleKey(getString(params, "roleKey"));
        if (StringUtils.isNotEmpty(roleKey))
        {
            hasExplicitRoleInput = true;
            requestedRoleKeys.add(roleKey);
        }

        for (String requestedRoleKey : requestedRoleKeys)
        {
            validateAssignableRole(requestedRoleKey, assignableRoleKeys);
            Role role = rolesByKey.get(requestedRoleKey);
            if (role == null)
            {
                throw new IllegalArgumentException(MSG_ROLE_INVALID);
            }
            if (resolvedRoleKeys.add(requestedRoleKey))
            {
                resolvedRoleIds.add(role.getRoleId());
            }
        }

        if (!hasExplicitRoleInput)
        {
            return resolvedRoleIds;
        }
        if (resolvedRoleIds.isEmpty())
        {
            throw new IllegalArgumentException(MSG_ROLE_REQUIRED);
        }
        return resolvedRoleIds;
    }

    private void validateAssignableRole(String roleKey, Set<String> assignableRoleKeys)
    {
        if (!SUPPORTED_ROLE_KEYS.contains(roleKey))
        {
            throw new IllegalArgumentException(MSG_ROLE_UNSUPPORTED);
        }
        if (!assignableRoleKeys.contains(roleKey))
        {
            throw new IllegalArgumentException("当前用户无法分配该角色: " + roleKey);
        }
    }

    private User selectScopedUserById(Long userId)
    {
        return selectScopedUserById(userId, getCallerAdminRoleKeys());
    }

    private User selectScopedUserById(Long userId, Set<String> callerRoleKeys)
    {
        if (userId == null || callerRoleKeys == null || callerRoleKeys.isEmpty())
        {
            return null;
        }

        User query = new User();
        query.setUserId(userId);
        List<User> users = selectUsersVisibleToCaller(query, callerRoleKeys);
        return users.isEmpty() ? null : users.get(0);
    }

    private List<User> selectUsersVisibleToCaller(User query, Set<String> callerRoleKeys)
    {
        List<User> users = selectUsersWithoutDataScope(query);
        List<User> visibleUsers = new ArrayList<>();
        for (User user : users)
        {
            if (isVisibleToCaller(user, callerRoleKeys))
            {
                visibleUsers.add(user);
            }
        }
        return visibleUsers;
    }

    private List<User> selectUsersWithoutDataScope(User query)
    {
        User userQuery = query != null ? query : new User();
        userQuery.getParams().put("dataScope", "");
        return userMapper.selectUserList(userQuery);
    }

    private boolean isVisibleToCaller(User user, Set<String> callerRoleKeys)
    {
        if (user == null || callerRoleKeys == null || callerRoleKeys.isEmpty())
        {
            return false;
        }
        if (ClinicSecuritySupport.isSuperAdmin(callerRoleKeys))
        {
            return true;
        }
        if (ClinicSecuritySupport.isClinicAdmin(callerRoleKeys))
        {
            Set<String> targetRoleKeys = getRoleKeys(user);
            return ClinicSecuritySupport.isDoctor(targetRoleKeys) || ClinicSecuritySupport.isPatient(targetRoleKeys);
        }
        return false;
    }

    private boolean userHasPrivilegedManagementRole(User user)
    {
        return ClinicSecuritySupport.containsPrivilegedManagementRole(getRoleKeys(user));
    }

    private boolean containsPrivilegedManagementRole(Long[] roleIds)
    {
        if (roleIds == null || roleIds.length == 0)
        {
            return false;
        }

        Map<Long, Role> rolesById = roleService.selectRoleAll().stream()
            .filter(role -> role != null && role.getRoleId() != null)
            .collect(Collectors.toMap(Role::getRoleId, role -> role, (left, right) -> left));
        for (Long roleId : roleIds)
        {
            Role role = rolesById.get(roleId);
            if (role != null && ClinicSecuritySupport.isPrivilegedManagementRole(role.getRoleKey()))
            {
                return true;
            }
        }
        return false;
    }

    private Long[] extractRoleIds(User user)
    {
        List<Role> roles = getSupportedRoles(user);
        Long[] roleIds = new Long[roles.size()];
        for (int i = 0; i < roles.size(); i++)
        {
            roleIds[i] = roles.get(i).getRoleId();
        }
        return roleIds;
    }

    private Set<String> getRoleKeys(User user)
    {
        return ClinicSecuritySupport.getRoleKeys(user, roleService);
    }

    private List<Role> getSupportedRoles(User user)
    {
        List<Role> sourceRoles = user != null ? user.getRoles() : null;
        if ((sourceRoles == null || sourceRoles.isEmpty()) && user != null && user.getUserId() != null)
        {
            sourceRoles = roleService.selectRolesByUserId(user.getUserId());
        }

        Map<String, Role> roleMap = new LinkedHashMap<>();
        if (sourceRoles != null)
        {
            for (Role role : sourceRoles)
            {
                if (role == null)
                {
                    continue;
                }

                String normalizedRoleKey = ClinicSecuritySupport.normalizeRoleKey(role.getRoleKey());
                if (SUPPORTED_ROLE_KEYS.contains(normalizedRoleKey) && !roleMap.containsKey(normalizedRoleKey))
                {
                    roleMap.put(normalizedRoleKey, role);
                }
            }
        }
        return new ArrayList<>(roleMap.values());
    }

    private Map<String, Object> convertUserInfo(User user)
    {
        Map<String, Object> userInfo = new HashMap<>();
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

        List<Role> roles = getSupportedRoles(user);
        if (!roles.isEmpty())
        {
            List<Map<String, Object>> roleInfos = roles.stream().map(this::convertRoleInfo).collect(Collectors.toList());
            userInfo.put("roles", roleInfos);
            userInfo.put("roleKeys", roleInfos.stream().map(role -> String.valueOf(role.get("roleKey"))).collect(Collectors.toList()));
            userInfo.put("roleIds", roleInfos.stream().map(role -> Long.valueOf(String.valueOf(role.get("roleId")))).collect(Collectors.toList()));
            userInfo.put("roleKey", roleInfos.get(0).get("roleKey"));
            userInfo.put("roleName", roleInfos.get(0).get("roleName"));
        }

        return userInfo;
    }

    private Map<String, Object> convertRoleInfo(Role role)
    {
        String normalizedRoleKey = ClinicSecuritySupport.normalizeRoleKey(role.getRoleKey());
        Map<String, Object> roleInfo = new HashMap<>();
        roleInfo.put("roleId", role.getRoleId());
        roleInfo.put("roleKey", normalizedRoleKey);
        roleInfo.put("roleName", getCanonicalRoleNameCn(normalizedRoleKey, role.getRoleName()));
        return roleInfo;
    }

    private String getCanonicalRoleNameCn(String roleKey, String fallback)
    {
        if (ClinicSecuritySupport.ROLE_SUPER_ADMIN.equals(roleKey))
        {
            return "超级管理员";
        }
        if (ClinicSecuritySupport.ROLE_CLINIC_ADMIN.equals(roleKey))
        {
            return "诊所管理员";
        }
        if (ClinicSecuritySupport.ROLE_DOCTOR.equals(roleKey))
        {
            return "医生";
        }
        if (ClinicSecuritySupport.ROLE_PATIENT.equals(roleKey))
        {
            return "患者";
        }
        return fallback;
    }

    private String getCanonicalRoleName(String roleKey, String fallback)
    {
        if (ClinicSecuritySupport.ROLE_SUPER_ADMIN.equals(roleKey))
        {
            return "超级管理员";
        }
        if (ClinicSecuritySupport.ROLE_CLINIC_ADMIN.equals(roleKey))
        {
            return "诊所管理员";
        }
        if (ClinicSecuritySupport.ROLE_DOCTOR.equals(roleKey))
        {
            return "医生";
        }
        if (ClinicSecuritySupport.ROLE_PATIENT.equals(roleKey))
        {
            return "患者";
        }
        return fallback;
    }

    private String getString(Map<String, Object> params, String key)
    {
        Object value = params.get(key);
        return value != null ? value.toString() : null;
    }

    private Long parseLong(Object value)
    {
        if (value == null)
        {
            return null;
        }
        try
        {
            return Long.valueOf(String.valueOf(value).trim());
        }
        catch (Exception ignored)
        {
            return null;
        }
    }

    private TableDataInfo deniedTable(int code, String message)
    {
        TableDataInfo denied = new TableDataInfo();
        denied.setCode(code);
        denied.setMsg(message);
        denied.setRows(new ArrayList<>());
        denied.setTotal(0);
        return denied;
    }

    private boolean matchesRoleFilter(User user, String expectedRoleKey)
    {
        String normalizedRoleKey = ClinicSecuritySupport.normalizeRoleKey(expectedRoleKey);
        if (StringUtils.isEmpty(normalizedRoleKey))
        {
            return true;
        }
        return ClinicSecuritySupport.hasRole(getRoleKeys(user), normalizedRoleKey);
    }

    public static class UserListQuery
    {
        private Integer pageNum;
        private Integer pageSize;
        private String userName;
        private String phonenumber;
        private String roleKey;

        public Integer getPageNum()
        {
            return pageNum;
        }

        public void setPageNum(Integer pageNum)
        {
            this.pageNum = pageNum;
        }

        public Integer getPageSize()
        {
            return pageSize;
        }

        public void setPageSize(Integer pageSize)
        {
            this.pageSize = pageSize;
        }

        public String getUserName()
        {
            return userName;
        }

        public void setUserName(String userName)
        {
            this.userName = userName;
        }

        public String getPhonenumber()
        {
            return phonenumber;
        }

        public void setPhonenumber(String phonenumber)
        {
            this.phonenumber = phonenumber;
        }

        public String getRoleKey()
        {
            return roleKey;
        }

        public void setRoleKey(String roleKey)
        {
            this.roleKey = roleKey;
        }
    }
}
