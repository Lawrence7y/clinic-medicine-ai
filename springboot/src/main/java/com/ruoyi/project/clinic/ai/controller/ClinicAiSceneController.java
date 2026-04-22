package com.ruoyi.project.clinic.ai.controller;

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
import com.ruoyi.project.clinic.ai.domain.ClinicAiSceneBinding;
import com.ruoyi.project.clinic.ai.service.IClinicAiModelService;
import com.ruoyi.project.clinic.ai.service.IClinicAiSceneBindingService;

@Controller
@RequestMapping("/clinic/ai/scene")
public class ClinicAiSceneController extends BaseController
{
    private final String prefix = "clinic/ai/scene";

    @Autowired
    private IClinicAiSceneBindingService sceneBindingService;

    @Autowired
    private IClinicAiModelService modelService;

    @RequiresPermissions("clinic:ai:scene:view")
    @GetMapping()
    public String scene()
    {
        return prefix + "/scene";
    }

    @RequiresPermissions("clinic:ai:scene:list")
    @PostMapping("/list")
    @ResponseBody
    public TableDataInfo list(ClinicAiSceneBinding sceneBinding)
    {
        startPage();
        return getDataTable(sceneBindingService.selectClinicAiSceneBindingList(sceneBinding));
    }

    @RequiresPermissions("clinic:ai:scene:add")
    @GetMapping("/add")
    public String add(ModelMap mmap)
    {
        mmap.put("models", modelService.selectClinicAiModelList(new ClinicAiModel()));
        return prefix + "/add";
    }

    @RequiresPermissions("clinic:ai:scene:add")
    @PostMapping("/add")
    @ResponseBody
    public AjaxResult addSave(ClinicAiSceneBinding sceneBinding)
    {
        return toAjax(sceneBindingService.insertClinicAiSceneBinding(sceneBinding));
    }

    @RequiresPermissions("clinic:ai:scene:edit")
    @GetMapping("/edit/{sceneId}")
    public String edit(@PathVariable("sceneId") Long sceneId, ModelMap mmap)
    {
        mmap.put("scene", sceneBindingService.selectClinicAiSceneBindingById(sceneId));
        mmap.put("models", modelService.selectClinicAiModelList(new ClinicAiModel()));
        return prefix + "/edit";
    }

    @RequiresPermissions("clinic:ai:scene:edit")
    @PostMapping("/edit")
    @ResponseBody
    public AjaxResult editSave(ClinicAiSceneBinding sceneBinding)
    {
        return toAjax(sceneBindingService.updateClinicAiSceneBinding(sceneBinding));
    }

    @RequiresPermissions("clinic:ai:scene:remove")
    @PostMapping("/remove")
    @ResponseBody
    public AjaxResult remove(String ids)
    {
        return toAjax(sceneBindingService.deleteClinicAiSceneBindingByIds(toLongArray(ids)));
    }

    private Long[] toLongArray(String ids)
    {
        return java.util.Arrays.stream(StringUtils.defaultString(ids).split(","))
            .filter(StringUtils::isNotEmpty)
            .map(Long::valueOf)
            .toArray(Long[]::new);
    }
}
