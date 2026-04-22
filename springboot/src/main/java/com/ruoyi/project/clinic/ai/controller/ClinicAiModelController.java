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
import com.ruoyi.project.clinic.ai.domain.ClinicAiModel;
import com.ruoyi.project.clinic.ai.domain.ClinicAiProvider;
import com.ruoyi.project.clinic.ai.service.IClinicAiModelService;
import com.ruoyi.project.clinic.ai.service.IClinicAiProviderService;

@Controller
@RequestMapping("/clinic/ai/model")
public class ClinicAiModelController extends BaseController
{
    private final String prefix = "clinic/ai/model";

    @Autowired
    private IClinicAiModelService modelService;

    @Autowired
    private IClinicAiProviderService providerService;

    @RequiresPermissions("clinic:ai:model:view")
    @GetMapping()
    public String model()
    {
        return prefix + "/model";
    }

    @RequiresPermissions("clinic:ai:model:list")
    @PostMapping("/list")
    @ResponseBody
    public TableDataInfo list(ClinicAiModel model)
    {
        startPage();
        return getDataTable(modelService.selectClinicAiModelList(model));
    }

    @RequiresPermissions("clinic:ai:model:add")
    @GetMapping("/add")
    public String add(ModelMap mmap)
    {
        mmap.put("providers", providerService.selectClinicAiProviderList(new ClinicAiProvider()));
        return prefix + "/add";
    }

    @RequiresPermissions("clinic:ai:model:add")
    @PostMapping("/add")
    @ResponseBody
    public AjaxResult addSave(ClinicAiModel model)
    {
        return toAjax(modelService.insertClinicAiModel(model));
    }

    @RequiresPermissions("clinic:ai:model:edit")
    @GetMapping("/edit/{modelId}")
    public String edit(@PathVariable("modelId") Long modelId, ModelMap mmap)
    {
        mmap.put("model", modelService.selectClinicAiModelById(modelId));
        mmap.put("providers", providerService.selectClinicAiProviderList(new ClinicAiProvider()));
        return prefix + "/edit";
    }

    @RequiresPermissions("clinic:ai:model:edit")
    @PostMapping("/edit")
    @ResponseBody
    public AjaxResult editSave(ClinicAiModel model)
    {
        return toAjax(modelService.updateClinicAiModel(model));
    }

    @RequiresPermissions("clinic:ai:model:remove")
    @PostMapping("/remove")
    @ResponseBody
    public AjaxResult remove(String ids)
    {
        return toAjax(modelService.deleteClinicAiModelByIds(toLongArray(ids)));
    }

    private Long[] toLongArray(String ids)
    {
        return java.util.Arrays.stream(StringUtils.defaultString(ids).split(","))
            .filter(StringUtils::isNotEmpty)
            .map(Long::valueOf)
            .toArray(Long[]::new);
    }
}
