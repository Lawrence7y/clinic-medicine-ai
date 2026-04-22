package com.ruoyi.project.clinic.prescription.controller;

import com.github.pagehelper.PageHelper;
import com.ruoyi.common.utils.security.ShiroUtils;
import com.ruoyi.framework.web.controller.BaseController;
import com.ruoyi.framework.web.domain.AjaxResult;
import com.ruoyi.framework.web.page.TableDataInfo;
import com.ruoyi.project.clinic.common.ClinicSecuritySupport;
import com.ruoyi.project.clinic.patient.service.IClinicPatientService;
import com.ruoyi.project.clinic.prescription.domain.ClinicPrescription;
import com.ruoyi.project.clinic.prescription.service.IClinicPrescriptionService;
import com.ruoyi.project.system.role.service.IRoleService;
import com.ruoyi.project.system.user.domain.User;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.apache.shiro.authz.annotation.RequiresPermissions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
@RequestMapping("/api/clinic/prescription")
public class ClinicPrescriptionApiController extends BaseController
{
    @Autowired
    private IClinicPrescriptionService clinicPrescriptionService;

    @Autowired
    private IRoleService roleService;

    @Autowired
    private IClinicPatientService clinicPatientService;

    @PostMapping("/list")
    @ResponseBody
    @RequiresPermissions("clinic:prescription:list")
    public TableDataInfo list(@RequestBody(required = false) ClinicPrescriptionQuery query)
    {
        if (query == null)
        {
            query = new ClinicPrescriptionQuery();
        }

        User currentUser = ShiroUtils.getSysUser();
        if (currentUser != null)
        {
            Set<String> roleKeys = getRoleKeys(currentUser);
            if (ClinicSecuritySupport.isPatient(roleKeys))
            {
                Long patientId = resolveCurrentPatientId(currentUser, roleKeys);
                if (patientId == null)
                {
                    return getDataTable(new ArrayList<>());
                }
                query.setPatientId(patientId);
            }
            else if (ClinicSecuritySupport.isDoctor(roleKeys) && !ClinicSecuritySupport.isAdmin(roleKeys))
            {
                query.setDoctorId(currentUser.getUserId());
            }
        }

        int pageNum = query.getPageNum() != null ? query.getPageNum() : 1;
        int pageSize = query.getPageSize() != null ? query.getPageSize() : 10;
        if (pageSize > 200)
        {
            pageSize = 200;
        }
        PageHelper.startPage(pageNum, pageSize);
        PageHelper.orderBy("prescription_date DESC, prescription_id DESC");

        ClinicPrescription criteria = new ClinicPrescription();
        criteria.setPatientId(query.getPatientId());
        criteria.setDoctorId(query.getDoctorId());
        criteria.setStatus(query.getStatus());
        criteria.setCategory(query.getCategory());
        criteria.setPatientName(query.getPatientName());

        List<ClinicPrescription> list = clinicPrescriptionService.selectPrescriptionList(criteria);
        return getDataTable(list);
    }

    @GetMapping("/getInfo")
    @ResponseBody
    @RequiresPermissions("clinic:prescription:list")
    public AjaxResult getInfo(@RequestParam Long prescriptionId)
    {
        User currentUser = ShiroUtils.getSysUser();
        if (currentUser == null)
        {
            return AjaxResult.error("请先登录");
        }

        ClinicPrescription prescription = clinicPrescriptionService.selectPrescriptionById(prescriptionId);
        if (prescription == null)
        {
            return AjaxResult.error("处方不存在");
        }

        Set<String> roleKeys = getRoleKeys(currentUser);
        if (ClinicSecuritySupport.isPatient(roleKeys))
        {
            Long patientId = resolveCurrentPatientId(currentUser, roleKeys);
            if (patientId == null || !patientId.equals(prescription.getPatientId()))
            {
                return AjaxResult.error("无权限访问");
            }
        }
        else if (ClinicSecuritySupport.isDoctor(roleKeys) && !ClinicSecuritySupport.isAdmin(roleKeys))
        {
            if (prescription.getDoctorId() != null && !currentUser.getUserId().equals(prescription.getDoctorId()))
            {
                return AjaxResult.error("无权限访问");
            }
        }

        return AjaxResult.success(prescription);
    }

    @GetMapping("/patient/{patientId}")
    @ResponseBody
    @RequiresPermissions("clinic:prescription:list")
    public AjaxResult getByPatient(@PathVariable("patientId") Long patientId)
    {
        User currentUser = ShiroUtils.getSysUser();
        if (currentUser == null)
        {
            return AjaxResult.error("请先登录");
        }

        Set<String> roleKeys = getRoleKeys(currentUser);
        boolean isAdmin = ClinicSecuritySupport.isAdmin(roleKeys);
        boolean isDoctor = ClinicSecuritySupport.isDoctor(roleKeys);
        boolean isPatient = ClinicSecuritySupport.isPatient(roleKeys);
        if (!isAdmin && !isDoctor && !isPatient)
        {
            return AjaxResult.error("无权限访问");
        }
        if (isPatient)
        {
            Long currentPatientId = resolveCurrentPatientId(currentUser, roleKeys);
            if (currentPatientId == null || !currentPatientId.equals(patientId))
            {
                return AjaxResult.error("无权限访问");
            }
        }

        List<ClinicPrescription> list = clinicPrescriptionService.selectPrescriptionByPatientId(patientId);
        return AjaxResult.success(list);
    }

    @PostMapping("/add")
    @ResponseBody
    @RequiresPermissions("clinic:prescription:add")
    public AjaxResult addSave(@RequestBody ClinicPrescription prescription)
    {
        User currentUser = ShiroUtils.getSysUser();
        if (currentUser == null)
        {
            return AjaxResult.error("请先登录");
        }

        Set<String> roleKeys = getRoleKeys(currentUser);
        boolean isAdmin = ClinicSecuritySupport.isAdmin(roleKeys);
        boolean isDoctor = ClinicSecuritySupport.isDoctor(roleKeys);
        if (!isAdmin && !isDoctor)
        {
            return AjaxResult.error("无权限访问");
        }

        if (isDoctor && !isAdmin)
        {
            prescription.setDoctorId(currentUser.getUserId());
            prescription.setDoctorName(currentUser.getUserName());
        }

        int rows = clinicPrescriptionService.insertPrescription(prescription);
        if (rows <= 0)
        {
            return AjaxResult.error("创建处方失败");
        }

        Map<String, Object> data = new HashMap<>();
        data.put("prescriptionId", prescription.getPrescriptionId());
        return AjaxResult.success(data);
    }

    @PostMapping("/edit")
    @ResponseBody
    @RequiresPermissions("clinic:prescription:edit")
    public AjaxResult editSave(@RequestBody ClinicPrescription prescription)
    {
        User currentUser = ShiroUtils.getSysUser();
        if (currentUser == null)
        {
            return AjaxResult.error("请先登录");
        }

        Set<String> roleKeys = getRoleKeys(currentUser);
        boolean isAdmin = ClinicSecuritySupport.isAdmin(roleKeys);
        boolean isDoctor = ClinicSecuritySupport.isDoctor(roleKeys);
        if (!isAdmin && !isDoctor)
        {
            return AjaxResult.error("无权限访问");
        }
        if (prescription.getPrescriptionId() == null)
        {
            return AjaxResult.error("参数错误");
        }

        ClinicPrescription old = clinicPrescriptionService.selectPrescriptionById(prescription.getPrescriptionId());
        if (old == null)
        {
            return AjaxResult.error("处方不存在");
        }

        if (isDoctor && !isAdmin)
        {
            if (old.getDoctorId() != null && !old.getDoctorId().equals(currentUser.getUserId()))
            {
                return AjaxResult.error("无权限访问");
            }
            if ("dispensed".equals(old.getStatus()))
            {
                return AjaxResult.error("已发药处方不可编辑");
            }
        }

        prescription.setDoctorId(old.getDoctorId());
        prescription.setDoctorName(old.getDoctorName());
        return toAjax(clinicPrescriptionService.updatePrescription(prescription));
    }

    @PostMapping("/remove")
    @ResponseBody
    public AjaxResult remove(@RequestBody Map<String, Object> params)
    {
        User currentUser = ShiroUtils.getSysUser();
        if (currentUser == null)
        {
            return AjaxResult.error("请先登录");
        }

        Set<String> roleKeys = getRoleKeys(currentUser);
        boolean isAdmin = ClinicSecuritySupport.isAdmin(roleKeys);
        boolean isDoctor = ClinicSecuritySupport.isDoctor(roleKeys);
        if (!isAdmin && !isDoctor)
        {
            return AjaxResult.error("无权限访问");
        }

        Object idsObj = params.get("ids");
        if (!(idsObj instanceof List))
        {
            return AjaxResult.error("参数错误");
        }

        List<?> idsList = (List<?>) idsObj;
        Long[] prescriptionIds = new Long[idsList.size()];
        for (int i = 0; i < idsList.size(); i++)
        {
            prescriptionIds[i] = Long.valueOf(String.valueOf(idsList.get(i)));
        }

        if (isDoctor && !isAdmin)
        {
            for (Long id : prescriptionIds)
            {
                ClinicPrescription old = clinicPrescriptionService.selectPrescriptionById(id);
                if (old == null)
                {
                    return AjaxResult.error("处方不存在");
                }
                if (old.getDoctorId() != null && !old.getDoctorId().equals(currentUser.getUserId()))
                {
                    return AjaxResult.error("无权限访问");
                }
                if (!"active".equals(old.getStatus()))
                {
                    return AjaxResult.error("仅可删除状态为有效的处方");
                }
            }
        }

        return toAjax(clinicPrescriptionService.deletePrescriptionByIds(prescriptionIds));
    }

    private Set<String> getRoleKeys(User user)
    {
        return ClinicSecuritySupport.getRoleKeys(user, roleService);
    }

    private Long resolveCurrentPatientId(User currentUser, Set<String> roleKeys)
    {
        return ClinicSecuritySupport.resolvePatientProfileId(currentUser,
            ClinicSecuritySupport.normalizeRoleKeys(roleKeys), clinicPatientService);
    }

    public static class ClinicPrescriptionQuery
    {
        private Integer pageNum;
        private Integer pageSize;
        private Long patientId;
        private Long doctorId;
        private String status;
        private String category;
        private String patientName;

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

        public Long getPatientId()
        {
            return patientId;
        }

        public void setPatientId(Long patientId)
        {
            this.patientId = patientId;
        }

        public Long getDoctorId()
        {
            return doctorId;
        }

        public void setDoctorId(Long doctorId)
        {
            this.doctorId = doctorId;
        }

        public String getStatus()
        {
            return status;
        }

        public void setStatus(String status)
        {
            this.status = status;
        }

        public String getCategory()
        {
            return category;
        }

        public void setCategory(String category)
        {
            this.category = category;
        }

        public String getPatientName()
        {
            return patientName;
        }

        public void setPatientName(String patientName)
        {
            this.patientName = patientName;
        }
    }
}
