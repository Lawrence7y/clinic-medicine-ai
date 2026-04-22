package com.ruoyi.project.clinic.medical.controller;

import java.util.List;
import java.util.Arrays;
import org.apache.shiro.authz.annotation.RequiresPermissions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import com.ruoyi.framework.aspectj.lang.annotation.Log;
import com.ruoyi.framework.aspectj.lang.enums.BusinessType;
import com.ruoyi.project.clinic.medical.domain.ClinicMedicalRecord;
import com.ruoyi.project.clinic.medical.service.IClinicMedicalRecordService;
import com.ruoyi.framework.web.controller.BaseController;
import com.ruoyi.framework.web.domain.AjaxResult;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.framework.web.page.TableDataInfo;
import com.ruoyi.common.utils.security.ShiroUtils;
import com.ruoyi.project.system.role.service.IRoleService;
import com.ruoyi.project.system.user.domain.User;
import java.util.Set;

@Controller
@RequestMapping("/clinic/medical")
public class ClinicMedicalRecordController extends BaseController
{
    private String prefix = "clinic/medical";

    @Autowired
    private IClinicMedicalRecordService clinicMedicalRecordService;

    @Autowired
    private IRoleService roleService;

    private boolean isClinicAdmin()
    {
        User currentUser = ShiroUtils.getSysUser();
        if (currentUser == null)
        {
            return false;
        }
        Set<String> roleKeys = roleService.selectRoleKeys(currentUser.getUserId());
        return roleKeys != null && roleKeys.contains("common");
    }

    @RequiresPermissions("clinic:medical:view")
    @GetMapping()
    public String medical()
    {
        return prefix + "/medical";
    }

    @RequiresPermissions("clinic:medical:list")
    @PostMapping("/list")
    @ResponseBody
    public TableDataInfo list(ClinicMedicalRecord clinicMedicalRecord)
    {
        startPage();
        List<ClinicMedicalRecord> list = clinicMedicalRecordService.selectClinicMedicalRecordList(clinicMedicalRecord);
        return getDataTable(list);
    }

    @RequiresPermissions("clinic:medical:export")
    @Log(title = "病历管理", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    @ResponseBody
    public AjaxResult export(ClinicMedicalRecord clinicMedicalRecord)
    {
        List<ClinicMedicalRecord> list = clinicMedicalRecordService.selectClinicMedicalRecordList(clinicMedicalRecord);
        ExcelUtil<ClinicMedicalRecord> util = new ExcelUtil<ClinicMedicalRecord>(ClinicMedicalRecord.class);
        return util.exportExcel(list, "病历数据");
    }

    @GetMapping("/add")
    public String add()
    {
        if (isClinicAdmin())
        {
            return "redirect:/clinic/medical";
        }
        return prefix + "/add";
    }

    @RequiresPermissions("clinic:medical:add")
    @Log(title = "病历管理", businessType = BusinessType.INSERT)
    @PostMapping("/add")
    @ResponseBody
    public AjaxResult addSave(ClinicMedicalRecord clinicMedicalRecord)
    {
        if (isClinicAdmin())
        {
            return AjaxResult.error("诊所管理员仅可查看病例");
        }
        return toAjax(clinicMedicalRecordService.insertClinicMedicalRecord(clinicMedicalRecord));
    }

    @GetMapping("/edit/{recordId}")
    public String edit(@PathVariable("recordId") Long recordId, ModelMap mmap)
    {
        if (isClinicAdmin())
        {
            return "redirect:/clinic/medical";
        }
        ClinicMedicalRecord clinicMedicalRecord = clinicMedicalRecordService.selectClinicMedicalRecordById(recordId);
        mmap.put("clinicMedicalRecord", clinicMedicalRecord);
        return prefix + "/edit";
    }

    @RequiresPermissions("clinic:medical:edit")
    @Log(title = "病历管理", businessType = BusinessType.UPDATE)
    @PostMapping("/edit")
    @ResponseBody
    public AjaxResult editSave(ClinicMedicalRecord clinicMedicalRecord)
    {
        if (isClinicAdmin())
        {
            return AjaxResult.error("诊所管理员仅可查看病例");
        }
        return toAjax(clinicMedicalRecordService.updateClinicMedicalRecord(clinicMedicalRecord));
    }

    @RequiresPermissions("clinic:medical:remove")
    @Log(title = "病历管理", businessType = BusinessType.DELETE)
    @PostMapping("/remove")
    @ResponseBody
    public AjaxResult remove(String ids)
    {
        Long[] recordIds = Arrays.stream(ids.split(","))
                .map(Long::valueOf)
                .toArray(Long[]::new);
        return toAjax(clinicMedicalRecordService.deleteClinicMedicalRecordByIds(recordIds));
    }
}
