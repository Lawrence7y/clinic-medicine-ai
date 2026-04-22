package com.ruoyi.project.clinic.ai.controller;

import com.ruoyi.common.utils.security.ShiroUtils;
import com.ruoyi.framework.web.controller.BaseController;
import com.ruoyi.framework.web.domain.AjaxResult;
import com.ruoyi.project.clinic.ai.domain.ClinicAiModel;
import com.ruoyi.project.clinic.ai.domain.ClinicAiSceneBinding;
import com.ruoyi.project.clinic.common.ClinicApiMessages;
import com.ruoyi.project.clinic.ai.service.IClinicAiModelService;
import com.ruoyi.project.clinic.ai.service.IClinicAiSceneBindingService;
import com.ruoyi.project.clinic.common.ClinicSecuritySupport;
import com.ruoyi.project.system.role.service.IRoleService;
import com.ruoyi.project.system.user.domain.User;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/clinic/ai/config")
public class ClinicAiConfigApiController extends BaseController
{
    private static final String MSG_NO_PERMISSION = "暂无权限";

    @Autowired
    private IRoleService roleService;

    @Autowired
    private IClinicAiModelService clinicAiModelService;

    @Autowired
    private IClinicAiSceneBindingService clinicAiSceneBindingService;

    @GetMapping("/models")
    public AjaxResult models()
    {
        AjaxResult denied = requireAdmin();
        if (denied != null)
        {
            return denied;
        }

        List<ClinicAiModel> rows = clinicAiModelService.selectClinicAiModelList(new ClinicAiModel());
        return success(rows != null ? rows : new ArrayList<ClinicAiModel>());
    }

    @GetMapping("/scenes")
    public AjaxResult scenes()
    {
        AjaxResult denied = requireAdmin();
        if (denied != null)
        {
            return denied;
        }

        List<ClinicAiSceneBinding> rows = clinicAiSceneBindingService
            .selectClinicAiSceneBindingList(new ClinicAiSceneBinding());
        return success(rows != null ? rows : new ArrayList<ClinicAiSceneBinding>());
    }

    private AjaxResult requireAdmin()
    {
        User user = ShiroUtils.getSysUser();
        if (user == null)
        {
            return AjaxResult.error(ClinicApiMessages.MSG_NEED_LOGIN);
        }
        Set<String> roleKeys = ClinicSecuritySupport.getRoleKeys(user, roleService);
        if (!ClinicSecuritySupport.isAdmin(roleKeys))
        {
            AjaxResult result = AjaxResult.error(MSG_NO_PERMISSION);
            result.put(AjaxResult.CODE_TAG, 403);
            return result;
        }
        return null;
    }
}
