package com.ruoyi.project.clinic.ai.controller;

import org.apache.shiro.authz.annotation.RequiresPermissions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import com.ruoyi.framework.web.controller.BaseController;
import com.ruoyi.project.clinic.config.service.ClinicConfigSupportService;

@Controller
@RequestMapping("/clinic/ai/assistant")
public class ClinicAiAssistantController extends BaseController
{
    private final String prefix = "clinic/ai/assistant";

    @Autowired(required = false)
    private ClinicConfigSupportService clinicConfigSupportService;

    @RequiresPermissions("clinic:ai:assistant:view")
    @GetMapping()
    public String assistant(ModelMap mmap)
    {
        String assistantName = clinicConfigSupportService != null
            ? clinicConfigSupportService.getAiAssistantName()
            : "AI 助手";
        mmap.put("assistantName", assistantName);
        mmap.put("assistantEnabled", clinicConfigSupportService == null || clinicConfigSupportService.isAiAssistantEnabled());
        return prefix + "/assistant";
    }
}
