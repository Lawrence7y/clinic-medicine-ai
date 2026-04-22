package com.ruoyi.project.clinic.patient.controller;

import com.github.pagehelper.PageHelper;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.security.ShiroUtils;
import com.ruoyi.framework.web.controller.BaseController;
import com.ruoyi.framework.web.domain.AjaxResult;
import com.ruoyi.framework.web.page.TableDataInfo;
import com.ruoyi.project.clinic.common.ClinicSecuritySupport;
import com.ruoyi.project.clinic.patient.domain.ClinicPatient;
import com.ruoyi.project.clinic.patient.service.IClinicPatientService;
import com.ruoyi.project.system.role.service.IRoleService;
import com.ruoyi.project.system.user.domain.User;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Map;
import java.util.Set;
import org.apache.shiro.authz.annotation.Logical;
import org.apache.shiro.authz.annotation.RequiresPermissions;
import org.apache.shiro.authz.annotation.RequiresRoles;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
@RequestMapping("/api/clinic/patient")
public class ClinicPatientApiController extends BaseController
{
    private static final String MSG_NEED_LOGIN = "请先登录";
    private static final String MSG_NO_PERMISSION = "无权限访问";
    private static final String MSG_PARAM_INVALID = "参数错误";
    private static final String MSG_PATIENT_NOT_FOUND = "患者不存在";
    private static final String MSG_CREATE_PATIENT_FAILED = "创建患者失败";
    private static final String MSG_DELETE_PATIENT_ID_REQUIRED = "请提供要删除的患者ID";
    private static final String MSG_DELETE_PATIENT_ID_INVALID = "患者ID格式错误";

    @Autowired
    private IClinicPatientService clinicPatientService;

    @Autowired
    private IRoleService roleService;

    @PostMapping("/list")
    @ResponseBody
    @RequiresRoles(value = { "admin", "common", "clinic_admin", "doctor" }, logical = Logical.OR)
    public TableDataInfo list(@RequestBody(required = false) ClinicPatientQuery query)
    {
        User currentUser = ShiroUtils.getSysUser();
        if (currentUser == null)
        {
            return deniedTable(401, MSG_NEED_LOGIN);
        }

        Set<String> roleKeys = ClinicSecuritySupport.normalizeRoleKeys(roleService.selectRoleKeys(currentUser.getUserId()));
        if (!ClinicSecuritySupport.isAdmin(roleKeys) && !ClinicSecuritySupport.isDoctor(roleKeys))
        {
            return deniedTable(403, MSG_NO_PERMISSION);
        }

        if (query == null)
        {
            query = new ClinicPatientQuery();
        }

        int pageNum = query.getPageNum() != null ? query.getPageNum() : 1;
        int pageSize = query.getPageSize() != null ? query.getPageSize() : 10;
        if (pageSize <= 0)
        {
            pageSize = 10;
        }
        if (pageSize > 200)
        {
            pageSize = 200;
        }
        PageHelper.startPage(pageNum, pageSize);
        PageHelper.orderBy("create_time DESC, patient_id DESC");

        ClinicPatient criteria = new ClinicPatient();
        criteria.setName(query.getPatientName());
        criteria.setPhone(query.getPatientPhone());

        return getDataTable(clinicPatientService.selectClinicPatientList(criteria));
    }

    @GetMapping("/getInfo")
    @ResponseBody
    public AjaxResult getInfo(@RequestParam Long patientId)
    {
        if (patientId == null)
        {
            return AjaxResult.error(MSG_PARAM_INVALID);
        }
        User currentUser = ShiroUtils.getSysUser();
        if (currentUser == null)
        {
            return AjaxResult.error(MSG_NEED_LOGIN);
        }

        Set<String> roleKeys = ClinicSecuritySupport.normalizeRoleKeys(roleService.selectRoleKeys(currentUser.getUserId()));
        if (!ClinicSecuritySupport.isAdmin(roleKeys) && !ClinicSecuritySupport.isDoctor(roleKeys))
        {
            return AjaxResult.error(MSG_NO_PERMISSION);
        }

        return AjaxResult.success(clinicPatientService.selectClinicPatientById(patientId));
    }

    @GetMapping("/getInfoByUserId")
    @ResponseBody
    public AjaxResult getInfoByUserId(@RequestParam Long userId)
    {
        if (userId == null)
        {
            return AjaxResult.error(MSG_PARAM_INVALID);
        }
        User currentUser = ShiroUtils.getSysUser();
        if (currentUser == null)
        {
            return AjaxResult.error(MSG_NEED_LOGIN);
        }

        Set<String> roleKeys = ClinicSecuritySupport.normalizeRoleKeys(roleService.selectRoleKeys(currentUser.getUserId()));
        boolean isAdminOrDoctor = ClinicSecuritySupport.isAdmin(roleKeys) || ClinicSecuritySupport.isDoctor(roleKeys);
        boolean isSelf = ClinicSecuritySupport.isPatient(roleKeys) && currentUser.getUserId().equals(userId);
        if (!isAdminOrDoctor && !isSelf)
        {
            return AjaxResult.error(MSG_NO_PERMISSION);
        }

        return AjaxResult.success(clinicPatientService.selectClinicPatientByUserId(userId));
    }

    @GetMapping("/myInfo")
    @ResponseBody
    public AjaxResult getMyInfo()
    {
        User currentUser = ShiroUtils.getSysUser();
        if (currentUser == null)
        {
            return AjaxResult.error(MSG_NEED_LOGIN);
        }

        Set<String> roleKeys = ClinicSecuritySupport.normalizeRoleKeys(roleService.selectRoleKeys(currentUser.getUserId()));
        if (!ClinicSecuritySupport.isPatient(roleKeys))
        {
            return AjaxResult.error(MSG_NO_PERMISSION);
        }

        return AjaxResult.success(clinicPatientService.selectClinicPatientByUserId(currentUser.getUserId()));
    }

    @PostMapping("/add")
    @ResponseBody
    public AjaxResult addSave(@Validated @RequestBody ClinicPatient clinicPatient)
    {
        User currentUser = ShiroUtils.getSysUser();
        if (currentUser == null)
        {
            return AjaxResult.error(MSG_NEED_LOGIN);
        }

        Set<String> roleKeys = ClinicSecuritySupport.normalizeRoleKeys(roleService.selectRoleKeys(currentUser.getUserId()));
        if (!ClinicSecuritySupport.isAdmin(roleKeys) && !ClinicSecuritySupport.isDoctor(roleKeys))
        {
            return AjaxResult.error(MSG_NO_PERMISSION);
        }

        int rows = clinicPatientService.insertClinicPatient(clinicPatient);
        if (rows <= 0)
        {
            return AjaxResult.error(MSG_CREATE_PATIENT_FAILED);
        }

        java.util.Map<String, Object> data = new java.util.HashMap<>();
        data.put("patientId", clinicPatient.getPatientId());
        return AjaxResult.success(data);
    }

    @PostMapping("/edit")
    @ResponseBody
    public AjaxResult editSave(@Validated @RequestBody ClinicPatient clinicPatient)
    {
        User currentUser = ShiroUtils.getSysUser();
        if (currentUser == null)
        {
            return AjaxResult.error(MSG_NEED_LOGIN);
        }
        if (clinicPatient.getPatientId() == null)
        {
            return AjaxResult.error(MSG_PARAM_INVALID);
        }

        ClinicPatient currentPatient = clinicPatientService.selectClinicPatientById(clinicPatient.getPatientId());
        if (currentPatient == null)
        {
            return AjaxResult.error(MSG_PATIENT_NOT_FOUND);
        }

        Set<String> roleKeys = ClinicSecuritySupport.normalizeRoleKeys(roleService.selectRoleKeys(currentUser.getUserId()));
        boolean isAdminOrDoctor = ClinicSecuritySupport.isAdmin(roleKeys) || ClinicSecuritySupport.isDoctor(roleKeys);
        boolean isSelfPatient = ClinicSecuritySupport.isPatient(roleKeys)
            && currentPatient.getUserId() != null
            && currentPatient.getUserId().equals(currentUser.getUserId());
        if (!isAdminOrDoctor && !isSelfPatient)
        {
            return AjaxResult.error(MSG_NO_PERMISSION);
        }

        clinicPatient.setUserId(currentPatient.getUserId());
        return toAjax(clinicPatientService.updateClinicPatient(clinicPatient));
    }

    @PostMapping("/remove")
    @ResponseBody
    @RequiresPermissions("clinic:patient:remove")
    public AjaxResult remove(@RequestBody(required = false) Map<String, String> params)
    {
        User currentUser = ShiroUtils.getSysUser();
        if (currentUser == null)
        {
            return AjaxResult.error(MSG_NEED_LOGIN);
        }

        Set<String> roleKeys = ClinicSecuritySupport.normalizeRoleKeys(roleService.selectRoleKeys(currentUser.getUserId()));
        if (!ClinicSecuritySupport.isAdmin(roleKeys))
        {
            return AjaxResult.error(MSG_NO_PERMISSION);
        }

        String ids = params != null ? params.get("ids") : null;
        if (StringUtils.isEmpty(ids))
        {
            return AjaxResult.error(MSG_DELETE_PATIENT_ID_REQUIRED);
        }
        Long[] patientIds;
        try
        {
            patientIds = parsePatientIds(ids);
        }
        catch (IllegalArgumentException ex)
        {
            return AjaxResult.error(ex.getMessage());
        }
        return toAjax(clinicPatientService.deleteClinicPatientByIds(patientIds));
    }

    private Long[] parsePatientIds(String ids)
    {
        Long[] patientIds = Arrays.stream(ids.split(","))
            .map(String::trim)
            .filter(StringUtils::isNotEmpty)
            .map(this::parsePatientId)
            .toArray(Long[]::new);
        if (patientIds.length == 0)
        {
            throw new IllegalArgumentException(MSG_DELETE_PATIENT_ID_REQUIRED);
        }
        return patientIds;
    }

    private Long parsePatientId(String rawId)
    {
        try
        {
            return Long.valueOf(rawId);
        }
        catch (Exception ex)
        {
            throw new IllegalArgumentException(MSG_DELETE_PATIENT_ID_INVALID);
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

    public static class ClinicPatientQuery
    {
        private Integer pageNum;
        private Integer pageSize;
        private String patientName;
        private String patientPhone;

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

        public String getPatientName()
        {
            return patientName;
        }

        public void setPatientName(String patientName)
        {
            this.patientName = patientName;
        }

        public String getPatientPhone()
        {
            return patientPhone;
        }

        public void setPatientPhone(String patientPhone)
        {
            this.patientPhone = patientPhone;
        }
    }
}
