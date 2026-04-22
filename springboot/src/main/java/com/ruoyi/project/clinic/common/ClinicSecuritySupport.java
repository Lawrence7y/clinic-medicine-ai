package com.ruoyi.project.clinic.common;

import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.project.clinic.patient.domain.ClinicPatient;
import com.ruoyi.project.clinic.patient.service.IClinicPatientService;
import com.ruoyi.project.system.role.domain.Role;
import com.ruoyi.project.system.role.service.IRoleService;
import com.ruoyi.project.system.user.domain.User;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.Set;

public final class ClinicSecuritySupport
{
    public static final String ROLE_SUPER_ADMIN = "admin";
    public static final String ROLE_CLINIC_ADMIN = "common";
    public static final String ROLE_DOCTOR = "doctor";
    public static final String ROLE_PATIENT = "patient";

    public static final Set<String> SUPPORTED_ROLE_KEYS = Collections.unmodifiableSet(
        new LinkedHashSet<>(Arrays.asList(ROLE_SUPER_ADMIN, ROLE_CLINIC_ADMIN, ROLE_DOCTOR, ROLE_PATIENT)));

    private ClinicSecuritySupport()
    {
    }

    public static String normalizeRoleKey(String roleKey)
    {
        if (StringUtils.isEmpty(roleKey))
        {
            return null;
        }

        String normalized = roleKey.trim();
        if ("super_admin".equals(normalized))
        {
            return ROLE_SUPER_ADMIN;
        }
        if ("clinic_admin".equals(normalized))
        {
            return ROLE_CLINIC_ADMIN;
        }
        return normalized;
    }

    public static Set<String> normalizeRoleKeys(Collection<String> roleKeys)
    {
        Set<String> normalized = new LinkedHashSet<>();
        if (roleKeys == null)
        {
            return normalized;
        }

        for (String roleKey : roleKeys)
        {
            String normalizedRoleKey = normalizeRoleKey(roleKey);
            if (StringUtils.isNotEmpty(normalizedRoleKey))
            {
                normalized.add(normalizedRoleKey);
            }
        }
        return normalized;
    }

    public static Set<String> getRoleKeys(User user, IRoleService roleService)
    {
        Set<String> roleKeys = new LinkedHashSet<>();
        if (user == null)
        {
            return roleKeys;
        }

        if (user.getRoles() != null)
        {
            for (Role role : user.getRoles())
            {
                if (role != null)
                {
                    String normalizedRoleKey = normalizeRoleKey(role.getRoleKey());
                    if (StringUtils.isNotEmpty(normalizedRoleKey))
                    {
                        roleKeys.add(normalizedRoleKey);
                    }
                }
            }
        }

        if (roleKeys.isEmpty() && user.getUserId() != null && roleService != null)
        {
            roleKeys.addAll(normalizeRoleKeys(roleService.selectRoleKeys(user.getUserId())));
        }
        return roleKeys;
    }

    public static boolean hasRole(Collection<String> roleKeys, String roleKey)
    {
        String normalizedRoleKey = normalizeRoleKey(roleKey);
        return normalizedRoleKey != null && normalizeRoleKeys(roleKeys).contains(normalizedRoleKey);
    }

    public static boolean hasAnyRole(Collection<String> roleKeys, String... expectedRoleKeys)
    {
        if (expectedRoleKeys == null || expectedRoleKeys.length == 0)
        {
            return false;
        }

        Set<String> normalized = normalizeRoleKeys(roleKeys);
        for (String expectedRoleKey : expectedRoleKeys)
        {
            String normalizedExpected = normalizeRoleKey(expectedRoleKey);
            if (normalizedExpected != null && normalized.contains(normalizedExpected))
            {
                return true;
            }
        }
        return false;
    }

    public static boolean isSuperAdmin(Collection<String> roleKeys)
    {
        return hasRole(roleKeys, ROLE_SUPER_ADMIN);
    }

    public static boolean isClinicAdmin(Collection<String> roleKeys)
    {
        return hasRole(roleKeys, ROLE_CLINIC_ADMIN);
    }

    public static boolean isAdmin(Collection<String> roleKeys)
    {
        return isSuperAdmin(roleKeys) || isClinicAdmin(roleKeys);
    }

    public static boolean isDoctor(Collection<String> roleKeys)
    {
        return hasRole(roleKeys, ROLE_DOCTOR);
    }

    public static boolean isPatient(Collection<String> roleKeys)
    {
        return hasRole(roleKeys, ROLE_PATIENT);
    }

    public static boolean isPrivilegedManagementRole(String roleKey)
    {
        String normalizedRoleKey = normalizeRoleKey(roleKey);
        return ROLE_SUPER_ADMIN.equals(normalizedRoleKey) || ROLE_CLINIC_ADMIN.equals(normalizedRoleKey);
    }

    public static boolean containsPrivilegedManagementRole(Collection<String> roleKeys)
    {
        for (String roleKey : normalizeRoleKeys(roleKeys))
        {
            if (isPrivilegedManagementRole(roleKey))
            {
                return true;
            }
        }
        return false;
    }

    public static Set<String> getAssignableRoleKeys(Collection<String> callerRoleKeys)
    {
        if (isSuperAdmin(callerRoleKeys))
        {
            return new LinkedHashSet<>(SUPPORTED_ROLE_KEYS);
        }
        if (isClinicAdmin(callerRoleKeys))
        {
            return new LinkedHashSet<>(Arrays.asList(ROLE_DOCTOR, ROLE_PATIENT));
        }
        return new LinkedHashSet<>();
    }

    public static Long resolvePatientProfileId(User currentUser, Set<String> roleKeys,
        IClinicPatientService clinicPatientService)
    {
        if (currentUser == null || currentUser.getUserId() == null || !isPatient(roleKeys)
            || clinicPatientService == null)
        {
            return null;
        }

        ClinicPatient patient = clinicPatientService.selectClinicPatientByUserId(currentUser.getUserId());
        return patient != null ? patient.getPatientId() : null;
    }
}
