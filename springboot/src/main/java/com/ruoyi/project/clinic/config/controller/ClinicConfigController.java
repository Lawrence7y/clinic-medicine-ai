package com.ruoyi.project.clinic.config.controller;

import java.util.Map;
import org.apache.shiro.authz.annotation.RequiresPermissions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import com.ruoyi.framework.aspectj.lang.annotation.Log;
import com.ruoyi.framework.aspectj.lang.enums.BusinessType;
import com.ruoyi.framework.web.controller.BaseController;
import com.ruoyi.framework.web.domain.AjaxResult;
import com.ruoyi.project.clinic.config.service.ClinicConfigSupportService;

@Controller
@RequestMapping("/clinic/config")
public class ClinicConfigController extends BaseController
{
    private final String prefix = "clinic/config";

    @Autowired
    private ClinicConfigSupportService clinicConfigSupportService;

    @RequiresPermissions("clinic:config:view")
    @GetMapping()
    public String config(ModelMap mmap)
    {
        mmap.put("config", clinicConfigSupportService.getConfigMap());
        return prefix + "/config";
    }

    @RequiresPermissions("clinic:config:edit")
    @Log(title = "诊所系统配置", businessType = BusinessType.UPDATE)
    @PostMapping("/save")
    @ResponseBody
    public AjaxResult save(@RequestBody(required = false) Map<String, Object> updates)
    {
        if (updates == null)
        {
            return AjaxResult.error("配置内容不能为空");
        }
        try
        {
            return AjaxResult.success("更新成功", clinicConfigSupportService.updateConfig(updates));
        }
        catch (IllegalArgumentException ex)
        {
            return AjaxResult.error(ex.getMessage());
        }
    }
}
