package com.ruoyi.project.clinic.patient.service.impl;

import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.sql.SqlUtil;
import com.ruoyi.common.utils.security.ShiroUtils;
import com.ruoyi.framework.shiro.service.PasswordService;
import com.ruoyi.project.clinic.patient.domain.ClinicPatient;
import com.ruoyi.project.clinic.patient.mapper.ClinicPatientMapper;
import com.ruoyi.project.clinic.patient.service.IClinicPatientService;
import com.ruoyi.project.system.user.domain.User;
import com.ruoyi.project.system.user.service.IUserService;

@Service
public class ClinicPatientServiceImpl implements IClinicPatientService
{
    @Autowired
    private ClinicPatientMapper clinicPatientMapper;

    @Autowired
    private IUserService userService;

    @Autowired
    private PasswordService passwordService;

    @Override
    public ClinicPatient selectClinicPatientById(Long patientId)
    {
        return clinicPatientMapper.selectClinicPatientById(patientId);
    }

    @Override
    public ClinicPatient selectClinicPatientByUserId(Long userId)
    {
        return clinicPatientMapper.selectClinicPatientByUserId(userId);
    }

    @Override
    public List<ClinicPatient> selectClinicPatientList(ClinicPatient clinicPatient)
    {
        // 转义SQL LIKE特殊字符，防止模糊匹配攻击
        if (clinicPatient != null) {
            if (clinicPatient.getName() != null && !clinicPatient.getName().isEmpty()) {
                clinicPatient.setName(SqlUtil.escapeLike(clinicPatient.getName()));
            }
            if (clinicPatient.getPhone() != null && !clinicPatient.getPhone().isEmpty()) {
                clinicPatient.setPhone(SqlUtil.escapeLike(clinicPatient.getPhone()));
            }
        }
        return clinicPatientMapper.selectClinicPatientList(clinicPatient);
    }

    @Override
    @Transactional
    public int insertClinicPatient(ClinicPatient clinicPatient)
    {
        if (clinicPatient.getCreateBy() == null || clinicPatient.getCreateBy().trim().isEmpty())
        {
            clinicPatient.setCreateBy(ShiroUtils.getLoginName());
        }
        if (clinicPatient.getCreateTime() == null)
        {
            clinicPatient.setCreateTime(DateUtils.getNowDate());
        }

        Long userId = clinicPatient.getUserId();
        if (userId == null)
        {
            User user = new User();
            user.setLoginName(clinicPatient.getPhone());
            user.setUserName(clinicPatient.getName());
            user.setPhonenumber(clinicPatient.getPhone());
            user.setAvatar(clinicPatient.getAvatar());
            user.setPassword("123456");
            user.setUserType("01");
            user.setStatus("0");
            user.setDelFlag("0");
            user.setCreateBy(ShiroUtils.getLoginName());
            user.setCreateTime(DateUtils.getNowDate());
            user.setPwdUpdateDate(DateUtils.getNowDate());
            user.setSex(convertGenderToSex(clinicPatient.getGender()));

            user.randomSalt();
            user.setPassword(passwordService.encryptPassword(user.getLoginName(), user.getPassword(), user.getSalt()));
            user.setRoleIds(new Long[] { 4L });
            userService.insertUser(user);

            userId = user.getUserId();
            clinicPatient.setUserId(userId);
        }

        return clinicPatientMapper.insertClinicPatient(clinicPatient);
    }

    @Override
    @Transactional
    public int updateClinicPatient(ClinicPatient clinicPatient)
    {
        if (clinicPatient.getUpdateBy() == null || clinicPatient.getUpdateBy().trim().isEmpty())
        {
            clinicPatient.setUpdateBy(ShiroUtils.getLoginName());
        }
        if (clinicPatient.getUpdateTime() == null)
        {
            clinicPatient.setUpdateTime(DateUtils.getNowDate());
        }

        Long userId = clinicPatient.getUserId();
        if (userId != null)
        {
            User user = userService.selectUserById(userId);
            if (user != null)
            {
                user.setUserName(clinicPatient.getName());
                user.setPhonenumber(clinicPatient.getPhone());
                user.setAvatar(clinicPatient.getAvatar());
                user.setUpdateBy(ShiroUtils.getLoginName());
                user.setUpdateTime(DateUtils.getNowDate());
                user.setSex(convertGenderToSex(clinicPatient.getGender()));
                userService.updateUserInfo(user);
            }
        }

        return clinicPatientMapper.updateClinicPatient(clinicPatient);
    }

    @Override
    @Transactional
    public int deleteClinicPatientByIds(Long[] patientIds)
    {
        if (patientIds == null || patientIds.length == 0)
        {
            return 0;
        }

        List<ClinicPatient> patients = clinicPatientMapper.selectClinicPatientByIds(patientIds);
        Set<Long> userIds = new LinkedHashSet<>();
        for (ClinicPatient patient : patients)
        {
            if (patient != null && patient.getUserId() != null)
            {
                userIds.add(patient.getUserId());
            }
        }
        for (Long userId : userIds)
        {
            userService.deleteUserById(userId);
        }
        return clinicPatientMapper.deleteClinicPatientByIds(patientIds);
    }

    @Override
    @Transactional
    public int deleteClinicPatientById(Long patientId)
    {
        ClinicPatient patient = selectClinicPatientById(patientId);
        if (patient != null && patient.getUserId() != null)
        {
            userService.deleteUserById(patient.getUserId());
        }
        return clinicPatientMapper.deleteClinicPatientById(patientId);
    }

    @Override
    public int countPatient()
    {
        return clinicPatientMapper.countPatient();
    }

    private String convertGenderToSex(String gender)
    {
        if (gender == null)
        {
            return "2";
        }

        String normalized = gender.trim();
        if ("0".equals(normalized) || "male".equalsIgnoreCase(normalized) || "m".equalsIgnoreCase(normalized)
                || "\u7537".equals(normalized))
        {
            return "0";
        }
        if ("1".equals(normalized) || "female".equalsIgnoreCase(normalized) || "f".equalsIgnoreCase(normalized)
                || "\u5973".equals(normalized))
        {
            return "1";
        }
        return "2";
    }
}
