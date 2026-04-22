package com.ruoyi.project.clinic.patient.controller;

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
import com.ruoyi.project.clinic.patient.domain.ClinicPatient;
import com.ruoyi.project.clinic.patient.service.IClinicPatientService;
import com.ruoyi.framework.web.controller.BaseController;
import com.ruoyi.framework.web.domain.AjaxResult;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.framework.web.page.TableDataInfo;

@Controller
@RequestMapping("/clinic/patient")
public class ClinicPatientController extends BaseController
{
    private String prefix = "clinic/patient";

    @Autowired
    private IClinicPatientService clinicPatientService;

    @RequiresPermissions("clinic:patient:view")
    @GetMapping()
    public String patient()
    {
        return prefix + "/patient";
    }

    @RequiresPermissions("clinic:patient:list")
    @PostMapping("/list")
    @ResponseBody
    public TableDataInfo list(ClinicPatient clinicPatient)
    {
        startPage();
        List<ClinicPatient> list = clinicPatientService.selectClinicPatientList(clinicPatient);
        return getDataTable(list);
    }

    @RequiresPermissions("clinic:patient:export")
    @Log(title = "患者管理", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    @ResponseBody
    public AjaxResult export(ClinicPatient clinicPatient)
    {
        List<ClinicPatient> list = clinicPatientService.selectClinicPatientList(clinicPatient);
        ExcelUtil<ClinicPatient> util = new ExcelUtil<ClinicPatient>(ClinicPatient.class);
        return util.exportExcel(list, "患者数据");
    }

    @GetMapping("/add")
    public String add()
    {
        return prefix + "/add";
    }

    @RequiresPermissions("clinic:patient:add")
    @Log(title = "患者管理", businessType = BusinessType.INSERT)
    @PostMapping("/add")
    @ResponseBody
    public AjaxResult addSave(ClinicPatient clinicPatient)
    {
        return toAjax(clinicPatientService.insertClinicPatient(clinicPatient));
    }

    @GetMapping("/edit/{patientId}")
    public String edit(@PathVariable("patientId") Long patientId, ModelMap mmap)
    {
        ClinicPatient clinicPatient = clinicPatientService.selectClinicPatientById(patientId);
        mmap.put("clinicPatient", clinicPatient);
        return prefix + "/edit";
    }

    @RequiresPermissions("clinic:patient:edit")
    @Log(title = "患者管理", businessType = BusinessType.UPDATE)
    @PostMapping("/edit")
    @ResponseBody
    public AjaxResult editSave(ClinicPatient clinicPatient)
    {
        return toAjax(clinicPatientService.updateClinicPatient(clinicPatient));
    }

    @RequiresPermissions("clinic:patient:remove")
    @Log(title = "患者管理", businessType = BusinessType.DELETE)
    @PostMapping("/remove")
    @ResponseBody
    public AjaxResult remove(String ids)
    {
        Long[] patientIds = Arrays.stream(ids.split(","))
                .map(Long::valueOf)
                .toArray(Long[]::new);
        return toAjax(clinicPatientService.deleteClinicPatientByIds(patientIds));
    }
}
