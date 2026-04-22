package com.ruoyi.project.clinic.auth.controller;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import com.ruoyi.framework.web.domain.AjaxResult;
import com.ruoyi.framework.web.page.TableDataInfo;
import com.ruoyi.project.clinic.support.ShiroTestSupport;
import com.ruoyi.project.system.role.domain.Role;
import com.ruoyi.project.system.role.service.IRoleService;
import com.ruoyi.project.system.user.domain.User;
import com.ruoyi.project.system.user.mapper.UserMapper;
import com.ruoyi.project.system.user.service.IUserService;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
public class ClinicUserApiControllerTest
{
    @Mock
    private IUserService userService;

    @Mock
    private UserMapper userMapper;

    @Mock
    private IRoleService roleService;

    @InjectMocks
    private ClinicUserApiController controller;

    @AfterEach
    public void tearDown()
    {
        ShiroTestSupport.clear();
    }

    @Test
    public void addSave_shouldRejectClinicAdminAssigningAdminRole()
    {
        ShiroTestSupport.bindUser(userWithRoles(10L, role(2L, "common")));
        when(roleService.selectRoleAll()).thenReturn(Arrays.asList(
            role(1L, "admin"),
            role(2L, "common"),
            role(3L, "doctor"),
            role(4L, "patient")));

        Map<String, Object> params = new HashMap<>();
        params.put("userName", "New Admin");
        params.put("phonenumber", "13800138000");
        params.put("password", "secret");
        params.put("roleKey", "admin");

        AjaxResult result = controller.addSave(params);

        assertTrue(result.isError());
        assertTrue(String.valueOf(result.get(AjaxResult.MSG_TAG)).contains("无法分配该角色"));
        verify(userService, never()).insertUser(any(User.class));
    }

    @Test
    public void resetPwd_shouldRejectClinicAdminResettingPrivilegedAccount()
    {
        ShiroTestSupport.bindUser(userWithRoles(10L, role(2L, "common")));
        User targetUser = userWithRoles(99L, role(1L, "admin"));
        when(userMapper.selectUserList(any(User.class))).thenReturn(Collections.singletonList(targetUser));

        Map<String, Object> params = new HashMap<>();
        params.put("userId", 99L);
        params.put("newPassword", "newSecret");

        AjaxResult result = controller.resetPwd(params);

        assertTrue(result.isError());
        assertTrue(String.valueOf(result.get(AjaxResult.MSG_TAG)).contains("无权限"));
        verify(userService, never()).resetUserPwd(any(User.class));
    }

    @Test
    public void list_shouldFilterUsersByRoleKeyBeforePagination()
    {
        ShiroTestSupport.bindUser(userWithRoles(1L, role(1L, "admin")));
        User doctor = userWithRoles(20L, role(3L, "doctor"));
        doctor.setPhonenumber("13800000001");
        User patient = userWithRoles(21L, role(4L, "patient"));
        patient.setPhonenumber("13800000002");
        when(userMapper.selectUserList(any(User.class))).thenReturn(Arrays.asList(doctor, patient));

        ClinicUserApiController.UserListQuery query = new ClinicUserApiController.UserListQuery();
        query.setPageNum(1);
        query.setPageSize(10);
        query.setRoleKey("doctor");

        TableDataInfo result = controller.list(query);

        assertEquals(0, result.getCode());
        assertEquals(1, result.getTotal());
        assertEquals(1, result.getRows().size());
    }

    @Test
    public void list_shouldRestrictClinicAdminToDoctorAndPatientUsers()
    {
        ShiroTestSupport.bindUser(userWithRoles(10L, role(2L, "common")));
        User admin = userWithRoles(1L, role(1L, "admin"));
        User clinicAdmin = userWithRoles(11L, role(2L, "common"));
        User doctor = userWithRoles(20L, role(3L, "doctor"));
        User patient = userWithRoles(21L, role(4L, "patient"));
        when(userMapper.selectUserList(any(User.class))).thenReturn(Arrays.asList(admin, clinicAdmin, doctor, patient));

        TableDataInfo result = controller.list(new ClinicUserApiController.UserListQuery());

        assertEquals(0, result.getCode());
        assertEquals(2, result.getTotal());
        assertEquals(2, result.getRows().size());
    }

    @Test
    public void getDoctors_shouldIgnoreDataScopeFiltering()
    {
        User clinicAdmin = userWithRoles(10L, role(2L, "common"));
        User doctor = userWithRoles(20L, role(3L, "doctor"));
        User patient = userWithRoles(21L, role(4L, "patient"));
        when(userMapper.selectUserList(any(User.class))).thenReturn(Arrays.asList(clinicAdmin, doctor, patient));

        AjaxResult result = controller.getDoctors();

        assertTrue(result.isSuccess());
        assertEquals(1, ((java.util.List<?>) result.get(AjaxResult.DATA_TAG)).size());
    }

    private User userWithRoles(Long userId, Role... roles)
    {
        User user = new User();
        user.setUserId(userId);
        user.setUserName("tester");
        user.setRoles(Arrays.asList(roles));
        return user;
    }

    private Role role(Long roleId, String roleKey)
    {
        Role role = new Role();
        role.setRoleId(roleId);
        role.setRoleKey(roleKey);
        role.setRoleName(roleKey);
        return role;
    }
}
