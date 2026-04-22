package com.ruoyi.project.clinic.appointment.controller;

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
import com.ruoyi.project.clinic.appointment.domain.ClinicAppointment;
import com.ruoyi.project.clinic.appointment.service.IClinicAppointmentService;
import com.ruoyi.framework.web.controller.BaseController;
import com.ruoyi.framework.web.domain.AjaxResult;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.framework.web.page.TableDataInfo;

@Controller
@RequestMapping("/clinic/appointment")
public class ClinicAppointmentController extends BaseController
{
    private String prefix = "clinic/appointment";

    @Autowired
    private IClinicAppointmentService clinicAppointmentService;

    @RequiresPermissions("clinic:appointment:view")
    @GetMapping()
    public String appointment()
    {
        return prefix + "/appointment";
    }

    @RequiresPermissions("clinic:appointment:list")
    @PostMapping("/list")
    @ResponseBody
    public TableDataInfo list(ClinicAppointment clinicAppointment)
    {
        startPage();
        List<ClinicAppointment> list = clinicAppointmentService.selectClinicAppointmentList(clinicAppointment);
        return getDataTable(list);
    }

    @RequiresPermissions("clinic:appointment:export")
    @Log(title = "预约管理", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    @ResponseBody
    public AjaxResult export(ClinicAppointment clinicAppointment)
    {
        List<ClinicAppointment> list = clinicAppointmentService.selectClinicAppointmentList(clinicAppointment);
        ExcelUtil<ClinicAppointment> util = new ExcelUtil<ClinicAppointment>(ClinicAppointment.class);
        return util.exportExcel(list, "预约数据");
    }

    @GetMapping("/add")
    public String add()
    {
        return prefix + "/add";
    }

    @RequiresPermissions("clinic:appointment:add")
    @Log(title = "预约管理", businessType = BusinessType.INSERT)
    @PostMapping("/add")
    @ResponseBody
    public AjaxResult addSave(ClinicAppointment clinicAppointment)
    {
        return toAjax(clinicAppointmentService.insertClinicAppointment(clinicAppointment));
    }

    @GetMapping("/edit/{appointmentId}")
    public String edit(@PathVariable("appointmentId") Long appointmentId, ModelMap mmap)
    {
        ClinicAppointment clinicAppointment = clinicAppointmentService.selectClinicAppointmentById(appointmentId);
        mmap.put("clinicAppointment", clinicAppointment);
        return prefix + "/edit";
    }

    @RequiresPermissions("clinic:appointment:edit")
    @Log(title = "预约管理", businessType = BusinessType.UPDATE)
    @PostMapping("/edit")
    @ResponseBody
    public AjaxResult editSave(ClinicAppointment clinicAppointment)
    {
        return toAjax(clinicAppointmentService.updateClinicAppointment(clinicAppointment));
    }

    @RequiresPermissions("clinic:appointment:remove")
    @Log(title = "预约管理", businessType = BusinessType.DELETE)
    @PostMapping("/remove")
    @ResponseBody
    public AjaxResult remove(String ids)
    {
        Long[] appointmentIds = Arrays.stream(ids.split(","))
                .map(Long::valueOf)
                .toArray(Long[]::new);
        return toAjax(clinicAppointmentService.deleteClinicAppointmentByIds(appointmentIds));
    }

    @RequiresPermissions("clinic:appointment:edit")
    @Log(title = "预约管理-叫号", businessType = BusinessType.UPDATE)
    @PostMapping("/call/{appointmentId}")
    @ResponseBody
    public AjaxResult callAppointment(@PathVariable("appointmentId") Long appointmentId)
    {
        try
        {
            clinicAppointmentService.callAppointment(appointmentId);
            return AjaxResult.success("叫号成功");
        }
        catch (RuntimeException e)
        {
            return AjaxResult.error(e.getMessage());
        }
    }

    @RequiresPermissions("clinic:appointment:edit")
    @Log(title = "预约管理-完成就诊", businessType = BusinessType.UPDATE)
    @PostMapping("/complete/{appointmentId}")
    @ResponseBody
    public AjaxResult completeAppointment(@PathVariable("appointmentId") Long appointmentId)
    {
        try
        {
            clinicAppointmentService.completeAppointment(appointmentId);
            return AjaxResult.success("完成就诊成功");
        }
        catch (RuntimeException e)
        {
            return AjaxResult.error(e.getMessage());
        }
    }
}
