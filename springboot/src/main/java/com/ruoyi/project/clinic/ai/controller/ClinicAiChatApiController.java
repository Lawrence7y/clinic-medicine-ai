package com.ruoyi.project.clinic.ai.controller;

import com.alibaba.fastjson2.JSONObject;
import com.ruoyi.common.utils.security.ShiroUtils;
import com.ruoyi.framework.web.controller.BaseController;
import com.ruoyi.framework.web.domain.AjaxResult;
import com.ruoyi.project.clinic.ai.service.support.AiInvocationLogService;
import com.ruoyi.project.clinic.ai.service.support.ClinicAiChatService;
import com.ruoyi.project.clinic.common.ClinicApiMessages;
import com.ruoyi.project.clinic.common.ClinicSecuritySupport;
import com.ruoyi.project.system.role.service.IRoleService;
import com.ruoyi.project.system.user.domain.User;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/clinic/ai/chat")
public class ClinicAiChatApiController extends BaseController
{
    private static final String MSG_NO_PERMISSION = "暂无权限";

    @Autowired
    private ClinicAiChatService clinicAiChatService;

    @Autowired
    private AiInvocationLogService aiInvocationLogService;

    @Autowired
    private IRoleService roleService;

    @PostMapping("/send")
    public AjaxResult send(@RequestBody(required = false) Map<String, String> params)
    {
        try
        {
            String message = params != null ? params.get("message") : null;
            String conversationId = params != null ? params.get("conversationId") : null;
            return success(clinicAiChatService.chat(message, conversationId));
        }
        catch (IllegalArgumentException | IllegalStateException ex)
        {
            return AjaxResult.error(ex.getMessage());
        }
    }

    @GetMapping("/history")
    public AjaxResult history(@RequestParam(value = "conversationId", required = false) String conversationId)
    {
        return success(clinicAiChatService.history(conversationId));
    }

    @GetMapping("/conversations")
    public AjaxResult conversations(@RequestParam(value = "limit", required = false, defaultValue = "20") Integer limit)
    {
        return success(clinicAiChatService.conversations(limit));
    }

    @PostMapping("/clear")
    public AjaxResult clear(@RequestBody(required = false) Map<String, String> params)
    {
        String conversationId = params != null ? params.get("conversationId") : null;
        clinicAiChatService.clearConversation(conversationId);
        return success();
    }

    @GetMapping("/templates")
    public AjaxResult templates()
    {
        try
        {
            return success(clinicAiChatService.templates());
        }
        catch (IllegalArgumentException | IllegalStateException ex)
        {
            return AjaxResult.error(ex.getMessage());
        }
    }

    @GetMapping("/capability")
    public AjaxResult capability()
    {
        try
        {
            return success(clinicAiChatService.capability());
        }
        catch (IllegalArgumentException | IllegalStateException ex)
        {
            return AjaxResult.error(ex.getMessage());
        }
    }

    @GetMapping("/logs")
    public AjaxResult logs(
        @RequestParam(value = "limit", required = false, defaultValue = "20") Integer limit,
        @RequestParam(value = "scene", required = false) String scene,
        @RequestParam(value = "model", required = false) String model,
        @RequestParam(value = "success", required = false) Boolean success,
        @RequestParam(value = "startTime", required = false) String startTime,
        @RequestParam(value = "endTime", required = false) String endTime
    )
    {
        User user = ShiroUtils.getSysUser();
        if (user == null)
        {
            return AjaxResult.error(ClinicApiMessages.MSG_NEED_LOGIN);
        }
        Set<String> roleKeys = ClinicSecuritySupport.getRoleKeys(user, roleService);
        if (!ClinicSecuritySupport.isDoctor(roleKeys) && !ClinicSecuritySupport.isAdmin(roleKeys))
        {
            AjaxResult result = AjaxResult.error(MSG_NO_PERMISSION);
            result.put(AjaxResult.CODE_TAG, 403);
            return result;
        }

        int effectiveLimit = limit != null ? limit : 20;
        if (effectiveLimit < 1)
        {
            effectiveLimit = 1;
        }
        if (effectiveLimit > 200)
        {
            effectiveLimit = 200;
        }

        List<JSONObject> items = aiInvocationLogService.latest(
            effectiveLimit,
            scene,
            model,
            success,
            startTime,
            endTime
        );
        return success(items);
    }
}
