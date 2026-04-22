package com.ruoyi.project.clinic.schedule.controller;

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
import com.ruoyi.project.clinic.schedule.domain.ClinicSchedule;
import com.ruoyi.project.clinic.schedule.service.IClinicScheduleService;
import com.ruoyi.framework.web.controller.BaseController;
import com.ruoyi.framework.web.domain.AjaxResult;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.framework.web.page.TableDataInfo;

@Controller
@RequestMapping("/clinic/schedule")
public class ClinicScheduleController extends BaseController
{
    private String prefix = "clinic/schedule";

    @Autowired
    private IClinicScheduleService clinicScheduleService;

    @RequiresPermissions("clinic:schedule:view")
    @GetMapping()
    public String schedule()
    {
        return prefix + "/schedule";
    }

    @RequiresPermissions("clinic:schedule:list")
    @PostMapping("/list")
    @ResponseBody
    public TableDataInfo list(ClinicSchedule clinicSchedule)
    {
        startPage();
        List<ClinicSchedule> list = clinicScheduleService.selectClinicScheduleList(clinicSchedule);
        return getDataTable(list);
    }

    @RequiresPermissions("clinic:schedule:export")
    @Log(title = "排班管理", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    @ResponseBody
    public AjaxResult export(ClinicSchedule clinicSchedule)
    {
        List<ClinicSchedule> list = clinicScheduleService.selectClinicScheduleList(clinicSchedule);
        ExcelUtil<ClinicSchedule> util = new ExcelUtil<ClinicSchedule>(ClinicSchedule.class);
        return util.exportExcel(list, "排班数据");
    }

    @GetMapping("/add")
    public String add()
    {
        return prefix + "/add";
    }

    @RequiresPermissions("clinic:schedule:add")
    @Log(title = "排班管理", businessType = BusinessType.INSERT)
    @PostMapping("/add")
    @ResponseBody
    public AjaxResult addSave(ClinicSchedule clinicSchedule)
    {
        try
        {
            return toAjax(clinicScheduleService.insertClinicSchedule(clinicSchedule));
        }
        catch (RuntimeException ex)
        {
            return AjaxResult.error(ex.getMessage());
        }
    }

    @GetMapping("/edit/{scheduleId}")
    public String edit(@PathVariable("scheduleId") Long scheduleId, ModelMap mmap)
    {
        ClinicSchedule clinicSchedule = clinicScheduleService.selectClinicScheduleById(scheduleId);
        mmap.put("clinicSchedule", clinicSchedule);
        return prefix + "/edit";
    }

    @RequiresPermissions("clinic:schedule:edit")
    @Log(title = "排班管理", businessType = BusinessType.UPDATE)
    @PostMapping("/edit")
    @ResponseBody
    public AjaxResult editSave(ClinicSchedule clinicSchedule)
    {
        try
        {
            return toAjax(clinicScheduleService.updateClinicSchedule(clinicSchedule));
        }
        catch (RuntimeException ex)
        {
            return AjaxResult.error(ex.getMessage());
        }
    }

    @RequiresPermissions("clinic:schedule:remove")
    @Log(title = "排班管理", businessType = BusinessType.DELETE)
    @PostMapping("/remove")
    @ResponseBody
    public AjaxResult remove(String ids)
    {
        Long[] scheduleIds = Arrays.stream(ids.split(","))
                .map(Long::valueOf)
                .toArray(Long[]::new);
        return toAjax(clinicScheduleService.deleteClinicScheduleByIds(scheduleIds));
    }
}
