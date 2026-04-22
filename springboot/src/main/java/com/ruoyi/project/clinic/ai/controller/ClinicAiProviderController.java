package com.ruoyi.project.clinic.ai.controller;

import java.util.List;
import org.apache.shiro.authz.annotation.RequiresPermissions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.framework.web.controller.BaseController;
import com.ruoyi.framework.web.domain.AjaxResult;
import com.ruoyi.framework.web.page.TableDataInfo;
import com.ruoyi.project.clinic.ai.domain.ClinicAiProvider;
import com.ruoyi.project.clinic.ai.service.IClinicAiProviderService;

@Controller
@RequestMapping("/clinic/ai/provider")
public class ClinicAiProviderController extends BaseController
{
    private final String prefix = "clinic/ai/provider";

    @Autowired
    private IClinicAiProviderService providerService;

    @RequiresPermissions("clinic:ai:provider:view")
    @GetMapping()
    public String provider()
    {
        return prefix + "/provider";
    }

    @RequiresPermissions("clinic:ai:provider:list")
    @PostMapping("/list")
    @ResponseBody
    public TableDataInfo list(ClinicAiProvider provider)
    {
        startPage();
        List<ClinicAiProvider> list = providerService.selectClinicAiProviderList(provider);
        for (ClinicAiProvider item : list)
        {
            item.setApiKey(maskApiKey(item.getApiKey()));
        }
        return getDataTable(list);
    }

    @RequiresPermissions("clinic:ai:provider:add")
    @GetMapping("/add")
    public String add()
    {
        return prefix + "/add";
    }

    @RequiresPermissions("clinic:ai:provider:add")
    @PostMapping("/add")
    @ResponseBody
    public AjaxResult addSave(ClinicAiProvider provider)
    {
        return toAjax(providerService.insertClinicAiProvider(provider));
    }

    @RequiresPermissions("clinic:ai:provider:edit")
    @GetMapping("/edit/{providerId}")
    public String edit(@PathVariable("providerId") Long providerId, ModelMap mmap)
    {
        mmap.put("provider", providerService.selectClinicAiProviderById(providerId));
        return prefix + "/edit";
    }

    @RequiresPermissions("clinic:ai:provider:edit")
    @PostMapping("/edit")
    @ResponseBody
    public AjaxResult editSave(ClinicAiProvider provider)
    {
        return toAjax(providerService.updateClinicAiProvider(provider));
    }

    @RequiresPermissions("clinic:ai:provider:remove")
    @PostMapping("/remove")
    @ResponseBody
    public AjaxResult remove(String ids)
    {
        return toAjax(providerService.deleteClinicAiProviderByIds(toLongArray(ids)));
    }

    @RequiresPermissions("clinic:ai:provider:test")
    @PostMapping("/test")
    @ResponseBody
    public AjaxResult test(Long providerId)
    {
        return AjaxResult.success(providerService.testConnection(providerId));
    }

    private Long[] toLongArray(String ids)
    {
        return java.util.Arrays.stream(StringUtils.defaultString(ids).split(","))
            .filter(StringUtils::isNotEmpty)
            .map(Long::valueOf)
            .toArray(Long[]::new);
    }

    private String maskApiKey(String apiKey)
    {
        if (StringUtils.isEmpty(apiKey))
        {
            return "";
        }
        if (apiKey.length() <= 8)
        {
            return "********";
        }
        return apiKey.substring(0, 4) + "****" + apiKey.substring(apiKey.length() - 4);
    }
}
