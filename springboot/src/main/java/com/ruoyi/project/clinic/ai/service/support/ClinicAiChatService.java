package com.ruoyi.project.clinic.ai.service.support;

import com.alibaba.fastjson2.JSONArray;
import com.alibaba.fastjson2.JSONObject;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.security.ShiroUtils;
import com.ruoyi.project.clinic.ai.client.AiProviderClient;
import com.ruoyi.project.clinic.ai.domain.ClinicAiModel;
import com.ruoyi.project.clinic.ai.domain.ClinicAiProvider;
import com.ruoyi.project.clinic.ai.domain.ClinicAiSceneBinding;
import com.ruoyi.project.clinic.ai.factory.AiProviderClientFactory;
import com.ruoyi.project.clinic.ai.service.IClinicAiModelService;
import com.ruoyi.project.clinic.ai.service.IClinicAiProviderService;
import com.ruoyi.project.clinic.ai.service.IClinicAiSceneBindingService;
import com.ruoyi.project.clinic.audit.service.AuditTrailService;
import com.ruoyi.project.clinic.common.ClinicSecuritySupport;
import com.ruoyi.project.clinic.config.service.ClinicConfigSupportService;
import com.ruoyi.project.system.role.service.IRoleService;
import com.ruoyi.project.system.user.domain.User;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Set;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class ClinicAiChatService
{
    private static final String CHAT_SCENE_CODE = "clinic_ai_chat";
    private static final String MEDICAL_ASSISTANT_SCENE_CODE = "clinic_ai_medical_assistant";
    private static final String MEDICINE_ASSISTANT_SCENE_CODE = "clinic_ai_medicine_assistant";
    private static final String OPERATIONS_ASSISTANT_SCENE_CODE = "clinic_ai_operations_assistant";
    private static final long CONNECTION_CHECK_CACHE_MS = 30000L;
    private static final List<String> PATIENT_BLOCKED_KEYWORDS = Arrays.asList(
        "库存", "入库", "出库", "过期", "药品预警", "报表", "统计", "营收",
        "ai调用日志", "模型配置", "排班管理", "医生待办", "诊所运营",
        "admin", "管理员", "inventory", "stock in", "stock out", "expiry", "report", "revenue",
        "model config", "doctor todo", "operation dashboard"
    );

    private volatile long lastConnectionCheckedAt = 0L;
    private volatile String lastConnectionCacheKey = "";
    private volatile JSONObject lastConnectionStatus = null;

    @Autowired
    private IClinicAiSceneBindingService sceneBindingService;

    @Autowired
    private IClinicAiModelService modelService;

    @Autowired
    private IClinicAiProviderService providerService;

    @Autowired
    private IRoleService roleService;

    @Autowired
    private AiProviderClientFactory clientFactory;

    @Autowired
    private AiInvocationLogService aiInvocationLogService;

    @Autowired
    private AiChatConversationMemoryService conversationMemoryService;

    @Autowired
    private ClinicAiSafetyService clinicAiSafetyService;

    @Autowired
    private AuditTrailService auditTrailService;

    @Autowired(required = false)
    private ClinicConfigSupportService clinicConfigSupportService;

    public JSONObject chat(String message, String conversationId)
    {
        String trimmedMessage = StringUtils.trim(message);
        if (StringUtils.isEmpty(trimmedMessage))
        {
            throw new IllegalArgumentException("消息内容不能为空");
        }

        User user = ShiroUtils.getSysUser();
        if (user == null)
        {
            throw new IllegalArgumentException("请先登录后再使用 AI 助手");
        }

        Set<String> roleKeys = ClinicSecuritySupport.getRoleKeys(user, roleService);
        boolean patientOnly = isPatientOnly(roleKeys);
        String cid = conversationMemoryService.ensureConversation(conversationId, user.getUserId());

        if (patientOnly && isBusinessQuestion(trimmedMessage))
        {
            String blockedReply = "当前角色仅支持咨询与流程问答，业务类问题请由医生或管理员账号使用。";
            return buildBlockedConversationResult(
                CHAT_SCENE_CODE,
                cid,
                user,
                roleKeys,
                "role-gate",
                "blocked_by_role",
                trimmedMessage,
                blockedReply,
                ""
            );
        }

        ClinicAiSafetyService.SafetyResult inputSafety = clinicAiSafetyService.inspectInput(CHAT_SCENE_CODE, trimmedMessage, roleKeys);
        if (inputSafety.isBlocked())
        {
            return buildBlockedConversationResult(
                CHAT_SCENE_CODE,
                cid,
                user,
                roleKeys,
                "safety-gate",
                inputSafety.getAction(),
                trimmedMessage,
                inputSafety.getUserMessage(),
                inputSafety.getMatchedKeyword()
            );
        }

        long start = System.currentTimeMillis();
        boolean success = false;
        String failureReason = "";
        String modelName = "配置检查";
        ChatModelSpec spec = null;
        ClinicAiSafetyService.SafetyResult outputSafety = null;

        try
        {
            AssistantStatus status = resolveAssistantStatus(CHAT_SCENE_CODE, false);
            if (!status.isAvailable())
            {
                throw new IllegalStateException(status.getMessage());
            }
            spec = status.getSpec();
            modelName = resolveModelName(spec);

            String safeUserMessage = inputSafety.getContent();
            String prompt = buildPromptWithHistory(cid, user.getUserId(), safeUserMessage);
            String rawReply = spec.client.chat(spec.provider, spec.model, buildSystemPrompt(patientOnly), prompt);
            outputSafety = clinicAiSafetyService.sanitizeOutput(CHAT_SCENE_CODE, rawReply);
            success = true;

            conversationMemoryService.append(cid, user.getUserId(), "user", safeUserMessage);
            conversationMemoryService.append(cid, user.getUserId(), "assistant", outputSafety.getContent());
            auditTrailService.record(
                "ai",
                "chat",
                cid,
                buildAiAuditDetail("chat", spec.model.getModelName(), roleKeys, inputSafety, outputSafety, "")
            );

            JSONObject result = new JSONObject();
            result.put("conversationId", cid);
            result.put("reply", outputSafety.getContent());
            result.put("model", spec.model.getModelName());
            result.put("security", buildSecurityPayload(inputSafety, outputSafety));
            return result;
        }
        catch (Exception ex)
        {
            failureReason = StringUtils.defaultIfEmpty(ex.getMessage(), ex.getClass().getSimpleName());
            auditTrailService.record("ai", "chat_failed", cid, "AI 对话失败：" + failureReason);
            if (ex instanceof IllegalStateException)
            {
                throw (IllegalStateException) ex;
            }
            throw new IllegalStateException("AI 对话失败：" + failureReason, ex);
        }
        finally
        {
            aiInvocationLogService.record(
                CHAT_SCENE_CODE,
                modelName,
                success,
                failureReason,
                System.currentTimeMillis() - start,
                buildInvocationMetadata(user, roleKeys, inputSafety, outputSafety, cid)
            );
        }
    }

    public List<JSONObject> history(String conversationId)
    {
        User user = ShiroUtils.getSysUser();
        if (user == null || StringUtils.isEmpty(conversationId))
        {
            return Collections.emptyList();
        }
        return conversationMemoryService.history(conversationId, user.getUserId());
    }

    public List<JSONObject> conversations(Integer limit)
    {
        User user = ShiroUtils.getSysUser();
        if (user == null)
        {
            return Collections.emptyList();
        }
        int size = limit != null ? limit : 20;
        if (size <= 0)
        {
            size = 20;
        }
        if (size > 100)
        {
            size = 100;
        }
        return conversationMemoryService.listConversations(user.getUserId(), size);
    }

    public void clearConversation(String conversationId)
    {
        User user = ShiroUtils.getSysUser();
        if (user == null || StringUtils.isEmpty(conversationId))
        {
            return;
        }
        conversationMemoryService.clear(conversationId, user.getUserId());
    }

    public List<String> templates()
    {
        User user = ShiroUtils.getSysUser();
        if (user == null)
        {
            return Collections.emptyList();
        }
        Set<String> roleKeys = ClinicSecuritySupport.getRoleKeys(user, roleService);
        boolean patientOnly = isPatientOnly(roleKeys);
        if (patientOnly)
        {
            return Arrays.asList(
                "明天怎么预约医生？",
                "药品领取流程是什么？",
                "复诊前需要准备什么？"
            );
        }
        return Arrays.asList(
            "总结今天的预约情况",
            "列出库存风险和处理建议",
            "按紧急程度排序今日待办事项"
        );
    }

    public JSONObject capability()
    {
        User user = ShiroUtils.getSysUser();
        if (user == null)
        {
            throw new IllegalArgumentException("请先登录后再使用 AI 助手");
        }

        Set<String> roleKeys = ClinicSecuritySupport.getRoleKeys(user, roleService);
        boolean patientOnly = isPatientOnly(roleKeys);
        AssistantStatus status = resolveAssistantStatus(CHAT_SCENE_CODE, true);
        String assistantName = resolveAssistantName();

        JSONObject capability = new JSONObject();
        capability.put("assistantName", assistantName);
        capability.put("assistantStatus", status.toJson());
        capability.put("patientOnly", patientOnly);
        capability.put("canBusinessQa", !patientOnly);
        capability.put("roleKeys", roleKeys);
        capability.put(
            "allowedScopes",
            patientOnly ? Arrays.asList("consultation", "process") : Arrays.asList("consultation", "process", "business")
        );
        capability.put(
            "roleHint",
            patientOnly
                ? "患者角色：仅支持咨询与流程问答。"
                : "医生/管理员：支持咨询、流程问答与业务问答。"
        );
        return capability;
    }

    public JSONObject runAssistant(String sceneCode, String systemPrompt, String userPrompt)
    {
        String scene = StringUtils.isNotEmpty(sceneCode) ? sceneCode : CHAT_SCENE_CODE;
        String prompt = StringUtils.trim(userPrompt);
        if (StringUtils.isEmpty(prompt))
        {
            throw new IllegalArgumentException("消息内容不能为空");
        }

        User user = ShiroUtils.getSysUser();
        if (user == null)
        {
            throw new IllegalArgumentException("请先登录后再使用 AI 助手");
        }

        Set<String> roleKeys = ClinicSecuritySupport.getRoleKeys(user, roleService);
        ClinicAiSafetyService.SafetyResult inputSafety = clinicAiSafetyService.inspectInput(scene, prompt, roleKeys);
        if (inputSafety.isBlocked())
        {
            aiInvocationLogService.record(
                scene,
                "safety-gate",
                false,
                inputSafety.getAction(),
                0L,
                buildInvocationMetadata(user, roleKeys, inputSafety, null, "")
            );
            auditTrailService.record(
                "ai_security",
                "blocked",
                scene,
                "AI 助手请求被拦截：" + inputSafety.getAction()
                    + (StringUtils.isNotEmpty(inputSafety.getMatchedKeyword()) ? " | 命中：" + inputSafety.getMatchedKeyword() : "")
            );
            throw new IllegalArgumentException(inputSafety.getUserMessage());
        }

        long start = System.currentTimeMillis();
        boolean success = false;
        String failureReason = "";
        String modelName = "配置检查";
        ChatModelSpec spec = null;
        ClinicAiSafetyService.SafetyResult outputSafety = null;

        try
        {
            AssistantStatus status = resolveAssistantStatus(scene, false);
            if (!status.isAvailable())
            {
                throw new IllegalStateException(status.getMessage());
            }
            spec = status.getSpec();
            modelName = resolveModelName(spec);

            String safeSystemPrompt = mergeSystemPrompt(scene, roleKeys, systemPrompt);
            String reply = spec.client.chat(spec.provider, spec.model, safeSystemPrompt, inputSafety.getContent());
            outputSafety = clinicAiSafetyService.sanitizeOutput(scene, reply);
            success = true;
            auditTrailService.record(
                "ai",
                "assistant_call",
                scene,
                buildAiAuditDetail("assistant", spec.model.getModelName(), roleKeys, inputSafety, outputSafety, scene)
            );

            JSONObject result = new JSONObject();
            result.put("reply", outputSafety.getContent());
            result.put("model", spec.model.getModelName());
            result.put("security", buildSecurityPayload(inputSafety, outputSafety));
            return result;
        }
        catch (Exception ex)
        {
            failureReason = StringUtils.defaultIfEmpty(ex.getMessage(), ex.getClass().getSimpleName());
            auditTrailService.record("ai", "assistant_failed", scene, "AI 助手调用失败：" + failureReason);
            if (ex instanceof IllegalStateException)
            {
                throw (IllegalStateException) ex;
            }
            throw new IllegalStateException("AI 助手调用失败：" + failureReason, ex);
        }
        finally
        {
            aiInvocationLogService.record(
                scene,
                modelName,
                success,
                failureReason,
                System.currentTimeMillis() - start,
                buildInvocationMetadata(user, roleKeys, inputSafety, outputSafety, "")
            );
        }
    }

    private JSONObject buildBlockedConversationResult(String sceneCode, String conversationId, User user, Set<String> roleKeys,
        String modelName, String failureReason, String originalMessage, String blockedReply, String matchedKeyword)
    {
        conversationMemoryService.append(conversationId, user.getUserId(), "user", originalMessage);
        conversationMemoryService.append(conversationId, user.getUserId(), "assistant", blockedReply);

        JSONObject inputMeta = new JSONObject();
        inputMeta.put("requestMasked", false);
        inputMeta.put("requestMaskCount", 0);
        inputMeta.put("securityAction", failureReason);
        if (StringUtils.isNotEmpty(matchedKeyword))
        {
            inputMeta.put("matchedKeyword", matchedKeyword);
        }
        aiInvocationLogService.record(
            sceneCode,
            modelName,
            false,
            failureReason,
            0L,
            mergeMetadata(buildBaseMetadata(user, roleKeys, conversationId), inputMeta)
        );
        auditTrailService.record(
            "ai_security",
            failureReason,
            conversationId,
            "AI 请求被拦截："
                + (StringUtils.isNotEmpty(matchedKeyword) ? "命中=" + matchedKeyword + " | " : "")
                + "角色=" + resolveRoleScope(roleKeys)
        );

        JSONObject result = new JSONObject();
        result.put("conversationId", conversationId);
        result.put("reply", blockedReply);
        result.put("model", modelName);
        JSONObject security = new JSONObject();
        security.put("blocked", true);
        security.put("reason", failureReason);
        security.put("matchedKeyword", matchedKeyword);
        result.put("security", security);
        return result;
    }

    private JSONObject buildInvocationMetadata(User user, Set<String> roleKeys,
        ClinicAiSafetyService.SafetyResult inputSafety,
        ClinicAiSafetyService.SafetyResult outputSafety,
        String conversationId)
    {
        JSONObject metadata = buildBaseMetadata(user, roleKeys, conversationId);
        if (inputSafety != null)
        {
            metadata.put("requestMasked", inputSafety.isMasked());
            metadata.put("requestMaskCount", inputSafety.getMaskCount());
            if (StringUtils.isNotEmpty(inputSafety.getSummary()))
            {
                metadata.put("requestMaskSummary", inputSafety.getSummary());
            }
            if (StringUtils.isNotEmpty(inputSafety.getAction()))
            {
                metadata.put("securityAction", inputSafety.getAction());
            }
        }
        if (outputSafety != null)
        {
            metadata.put("responseMasked", outputSafety.isMasked());
            metadata.put("responseMaskCount", outputSafety.getMaskCount());
            if (StringUtils.isNotEmpty(outputSafety.getSummary()))
            {
                metadata.put("responseMaskSummary", outputSafety.getSummary());
            }
            if (outputSafety.isMasked())
            {
                metadata.put("securityAction", "desensitized");
            }
        }
        return metadata;
    }

    private JSONObject buildBaseMetadata(User user, Set<String> roleKeys, String conversationId)
    {
        JSONObject metadata = new JSONObject();
        metadata.put("userId", user != null && user.getUserId() != null ? String.valueOf(user.getUserId()) : "-");
        metadata.put("roleScope", resolveRoleScope(roleKeys));
        if (StringUtils.isNotEmpty(conversationId))
        {
            metadata.put("conversationId", conversationId);
        }
        return metadata;
    }

    private JSONObject mergeMetadata(JSONObject left, JSONObject right)
    {
        JSONObject merged = new JSONObject();
        if (left != null)
        {
            for (String key : left.keySet())
            {
                merged.put(key, left.get(key));
            }
        }
        if (right != null)
        {
            for (String key : right.keySet())
            {
                merged.put(key, right.get(key));
            }
        }
        return merged;
    }

    private JSONObject buildSecurityPayload(ClinicAiSafetyService.SafetyResult inputSafety,
        ClinicAiSafetyService.SafetyResult outputSafety)
    {
        JSONObject payload = new JSONObject();
        payload.put("requestMasked", inputSafety != null && inputSafety.isMasked());
        payload.put("requestMaskCount", inputSafety != null ? inputSafety.getMaskCount() : 0);
        payload.put("responseMasked", outputSafety != null && outputSafety.isMasked());
        payload.put("responseMaskCount", outputSafety != null ? outputSafety.getMaskCount() : 0);
        if (inputSafety != null && StringUtils.isNotEmpty(inputSafety.getSummary()))
        {
            payload.put("requestMaskSummary", inputSafety.getSummary());
        }
        if (outputSafety != null && StringUtils.isNotEmpty(outputSafety.getSummary()))
        {
            payload.put("responseMaskSummary", outputSafety.getSummary());
        }
        return payload;
    }

    private String buildAiAuditDetail(String actionType, String modelName, Set<String> roleKeys,
        ClinicAiSafetyService.SafetyResult inputSafety,
        ClinicAiSafetyService.SafetyResult outputSafety,
        String targetId)
    {
        StringBuilder builder = new StringBuilder();
        builder.append("类型=").append(actionType);
        builder.append(" | 模型=").append(StringUtils.defaultIfEmpty(modelName, "-"));
        builder.append(" | 角色=").append(resolveRoleScope(roleKeys));
        if (StringUtils.isNotEmpty(targetId))
        {
            builder.append(" | 场景=").append(targetId);
        }
        if (inputSafety != null && inputSafety.isMasked())
        {
            builder.append(" | 输入脱敏=").append(inputSafety.getSummary());
        }
        if (outputSafety != null && outputSafety.isMasked())
        {
            builder.append(" | 输出脱敏=").append(outputSafety.getSummary());
        }
        return builder.toString();
    }

    private String resolveRoleScope(Set<String> roleKeys)
    {
        if (ClinicSecuritySupport.isAdmin(roleKeys))
        {
            return "admin";
        }
        if (ClinicSecuritySupport.isDoctor(roleKeys))
        {
            return "doctor";
        }
        if (ClinicSecuritySupport.isPatient(roleKeys))
        {
            return "patient";
        }
        return "unknown";
    }

    private boolean isPatientOnly(Set<String> roleKeys)
    {
        return ClinicSecuritySupport.isPatient(roleKeys)
            && !ClinicSecuritySupport.isDoctor(roleKeys)
            && !ClinicSecuritySupport.isAdmin(roleKeys);
    }

    private boolean isBusinessQuestion(String message)
    {
        String content = StringUtils.trimToEmpty(message).toLowerCase();
        for (String keyword : PATIENT_BLOCKED_KEYWORDS)
        {
            if (content.contains(keyword.toLowerCase()))
            {
                return true;
            }
        }
        return false;
    }

    private String buildSystemPrompt(boolean patientOnly)
    {
        String assistantName = resolveAssistantName();
        String generalPrompt = clinicConfigSupportService != null
            ? clinicConfigSupportService.getAiPromptTemplateGeneral()
            : "";
        String businessPrompt = clinicConfigSupportService != null
            ? clinicConfigSupportService.getAiPromptTemplateBusiness()
            : "";
        if (patientOnly)
        {
            return StringUtils.defaultIfEmpty(generalPrompt, "你是诊所 AI 助手，请给出清晰、简洁且可执行的回答。")
                + "\n"
                + "你的名称是“" + assistantName + "”。"
                + "你是诊所小程序助手。"
                + "仅回答咨询和流程问题，例如就诊流程、预约流程、取药流程。"
                + "不要提供经营管理建议、库存分析或管理决策。";
        }
        return StringUtils.defaultIfEmpty(businessPrompt, "你是诊所经营助手，请提供结构化的运营建议，优先给出可落地步骤。")
            + "\n"
            + "你的名称是“" + assistantName + "”。"
            + "你是诊所管理助手。"
            + "可以回答咨询、流程问答、预约概览、库存预警和业务支持问题。"
            + "不要编造数据；若上下文不足，明确说明缺失信息并给出下一步建议。";
    }

    private String mergeSystemPrompt(String sceneCode, Set<String> roleKeys, String systemPrompt)
    {
        boolean patientOnly = isPatientOnly(roleKeys);
        String basePrompt = buildSystemPrompt(patientOnly);
        if (StringUtils.isEmpty(systemPrompt))
        {
            return basePrompt;
        }
        return basePrompt + "\n\n场景补充要求：\n" + systemPrompt;
    }

    private String buildPromptWithHistory(String conversationId, Long userId, String message)
    {
        List<JSONObject> history = conversationMemoryService.history(conversationId, userId);
        if (history == null || history.isEmpty())
        {
            return message;
        }

        StringBuilder prompt = new StringBuilder();
        prompt.append("最近会话上下文：\n");
        int start = Math.max(0, history.size() - 10);
        for (int i = start; i < history.size(); i++)
        {
            JSONObject item = history.get(i);
            String role = item.getString("role");
            String content = item.getString("content");
            if (StringUtils.isEmpty(content))
            {
                continue;
            }
            prompt.append("[").append("assistant".equals(role) ? "assistant" : "user").append("] ")
                .append(content).append("\n");
        }
        prompt.append("[user] ").append(message).append("\n");
        prompt.append("只需要回答当前这一轮的问题。");
        return prompt.toString();
    }

    private AssistantStatus resolveAssistantStatus(String sceneCode, boolean checkConnection)
    {
        String scene = StringUtils.defaultIfEmpty(sceneCode, CHAT_SCENE_CODE);
        boolean requireSceneBinding = isAssistantScene(scene);
        JSONArray items = new JSONArray();
        String assistantName = resolveAssistantName();

        boolean assistantEnabled = clinicConfigSupportService == null || clinicConfigSupportService.isAiAssistantEnabled();
        items.add(buildStatusItem(
            "assistantEnabled",
            "助手开关",
            assistantEnabled,
            assistantEnabled
                ? assistantName + "已开启。"
                : assistantName + "已关闭，请联系管理员在系统配置中开启。"
        ));
        if (!assistantEnabled)
        {
            return AssistantStatus.unavailable(
                "assistant_disabled",
                assistantName + "已关闭，请联系管理员在系统配置中开启。",
                items,
                null
            );
        }

        ClinicAiSceneBinding binding = sceneBindingService.selectClinicAiSceneBindingByCode(scene);
        boolean sceneBound = binding != null;
        items.add(buildStatusItem(
            "sceneBound",
            "场景绑定",
            sceneBound,
            sceneBound
                ? "场景“" + scene + "”已绑定。"
                : "场景“" + scene + "”未绑定，请在后台 AI 场景绑定页配置。"
        ));
        if (requireSceneBinding && !sceneBound)
        {
            return AssistantStatus.unavailable(
                "scene_not_bound",
                "AI 场景未绑定，请在后台 AI 场景绑定页完成配置后重试。",
                items,
                null
            );
        }

        boolean sceneEnabled = binding == null || (binding.getEnabled() != null && binding.getEnabled() == 1);
        items.add(buildStatusItem(
            "sceneEnabled",
            "场景启用",
            sceneEnabled,
            sceneEnabled ? "场景已启用。" : "场景已禁用，请在后台启用后重试。"
        ));
        if (requireSceneBinding && !sceneEnabled)
        {
            return AssistantStatus.unavailable("scene_disabled", "AI 场景已禁用，请在后台启用后重试。", items, null);
        }

        boolean hasBindingModel = binding != null && (binding.getPrimaryModelId() != null || binding.getFallbackModelId() != null);
        items.add(buildStatusItem(
            "sceneModelBound",
            "场景模型",
            hasBindingModel || !requireSceneBinding,
            hasBindingModel
                ? "场景已绑定主模型或兜底模型。"
                : (requireSceneBinding ? "场景未绑定模型，请在后台 AI 场景绑定页选择模型。" : "当前场景未绑定模型，已尝试使用全局可用模型。")
        ));
        if (requireSceneBinding && !hasBindingModel)
        {
            return AssistantStatus.unavailable(
                "scene_model_unbound",
                "AI 场景未绑定主模型或兜底模型，请先完成模型绑定。",
                items,
                null
            );
        }

        ChatModelSpec spec = null;
        if (binding != null && sceneEnabled)
        {
            spec = resolveSceneBindingModel(binding);
        }
        if (spec == null && !requireSceneBinding)
        {
            List<ClinicAiModel> enabledModels = modelService.selectEnabledModels();
            spec = resolveEnabledModel(enabledModels, true);
            if (spec == null)
            {
                spec = resolveEnabledModel(enabledModels, false);
            }
        }

        boolean modelAvailable = spec != null;
        String modelMessage = modelAvailable
            ? "当前模型：" + resolveModelName(spec)
            : (hasBindingModel
                ? "场景已绑定模型，但模型不可用（可能被禁用或配置失效）。"
                : "未找到可用的 AI 文本模型。");
        items.add(buildStatusItem("modelAvailable", "模型可用", modelAvailable, modelMessage));
        if (!modelAvailable)
        {
            return AssistantStatus.unavailable(
                hasBindingModel ? "model_unavailable" : "no_model_available",
                modelMessage,
                items,
                null
            );
        }

        boolean providerEnabled = spec.provider != null && spec.provider.getEnabled() != null && spec.provider.getEnabled() == 1;
        items.add(buildStatusItem(
            "providerEnabled",
            "服务商状态",
            providerEnabled,
            providerEnabled
                ? "服务商“" + StringUtils.defaultIfEmpty(spec.provider.getProviderName(), spec.provider.getProviderCode()) + "”已启用。"
                : "服务商已禁用，请在后台 AI 服务商页面启用后重试。"
        ));
        if (!providerEnabled)
        {
            return AssistantStatus.unavailable("provider_disabled", "当前模型关联的服务商已禁用。", items, spec);
        }

        JSONObject connectionItem = resolveConnectionStatusItem(spec, checkConnection);
        items.add(connectionItem);
        if (Boolean.FALSE.equals(connectionItem.getBoolean("ok")))
        {
            return AssistantStatus.unavailable(
                "provider_unreachable",
                connectionItem.getString("message"),
                items,
                spec
            );
        }

        return AssistantStatus.available("ok", assistantName + "已就绪，可开始提问。", items, spec);
    }

    private JSONObject resolveConnectionStatusItem(ChatModelSpec spec, boolean checkConnection)
    {
        if (spec == null)
        {
            return buildStatusItem("apiReachable", "接口可访问", false, "缺少可用模型，无法检测接口可访问性。");
        }
        if (!checkConnection || spec.provider == null || spec.provider.getProviderId() == null)
        {
            return buildStatusItem("apiReachable", "接口可访问", true, "将在实际调用时校验接口可访问性。");
        }

        String cacheKey = String.valueOf(spec.provider.getProviderId()) + "|" + String.valueOf(spec.model.getModelId());
        long now = System.currentTimeMillis();
        JSONObject cached = lastConnectionStatus;
        if (cached != null
            && cacheKey.equals(lastConnectionCacheKey)
            && (now - lastConnectionCheckedAt) < CONNECTION_CHECK_CACHE_MS)
        {
            return new JSONObject(cached);
        }

        JSONObject item;
        try
        {
            String message = providerService.testConnection(spec.provider.getProviderId());
            item = buildStatusItem(
                "apiReachable",
                "接口可访问",
                true,
                StringUtils.defaultIfEmpty(message, "模型接口可访问。")
            );
        }
        catch (Exception ex)
        {
            String message = StringUtils.defaultIfEmpty(ex.getMessage(), "模型接口访问失败");
            item = buildStatusItem("apiReachable", "接口可访问", false, "模型接口访问失败：" + message);
        }
        lastConnectionCheckedAt = now;
        lastConnectionCacheKey = cacheKey;
        lastConnectionStatus = new JSONObject(item);
        return item;
    }

    private JSONObject buildStatusItem(String key, String label, boolean ok, String message)
    {
        JSONObject item = new JSONObject();
        item.put("key", key);
        item.put("label", label);
        item.put("ok", ok);
        item.put("message", message);
        return item;
    }

    private boolean isAssistantScene(String sceneCode)
    {
        String scene = StringUtils.defaultIfEmpty(sceneCode, CHAT_SCENE_CODE);
        return CHAT_SCENE_CODE.equals(scene)
            || MEDICAL_ASSISTANT_SCENE_CODE.equals(scene)
            || MEDICINE_ASSISTANT_SCENE_CODE.equals(scene)
            || OPERATIONS_ASSISTANT_SCENE_CODE.equals(scene);
    }

    private String resolveAssistantName()
    {
        String configuredName = clinicConfigSupportService != null ? clinicConfigSupportService.getAiAssistantName() : "";
        return StringUtils.defaultIfEmpty(StringUtils.trim(configuredName), "AI 助手");
    }

    private ChatModelSpec resolveSceneBindingModel(ClinicAiSceneBinding binding)
    {
        if (binding == null || binding.getEnabled() == null || binding.getEnabled() != 1)
        {
            return null;
        }

        ChatModelSpec primary = resolveModel(binding.getPrimaryModelId());
        if (primary != null)
        {
            return primary;
        }
        if (binding.getFallbackModelId() != null
            && (binding.getPrimaryModelId() == null || !binding.getFallbackModelId().equals(binding.getPrimaryModelId())))
        {
            return resolveModel(binding.getFallbackModelId());
        }
        return null;
    }

    private ChatModelSpec resolveEnabledModel(List<ClinicAiModel> enabledModels, boolean preferTextOnly)
    {
        if (enabledModels == null || enabledModels.isEmpty())
        {
            return null;
        }
        for (ClinicAiModel item : enabledModels)
        {
            if (item == null || item.getEnabled() == null || item.getEnabled() != 1)
            {
                continue;
            }
            boolean supportsVision = item.getSupportsVision() != null && item.getSupportsVision() == 1;
            if (preferTextOnly && supportsVision)
            {
                continue;
            }
            ChatModelSpec spec = resolveModel(item.getModelId());
            if (spec != null)
            {
                return spec;
            }
        }
        return null;
    }

    private ChatModelSpec resolveModel(Long modelId)
    {
        if (modelId == null)
        {
            return null;
        }
        ClinicAiModel model = modelService.selectClinicAiModelById(modelId);
        if (model == null || model.getEnabled() == null || model.getEnabled() != 1)
        {
            return null;
        }
        ClinicAiProvider provider = providerService.selectClinicAiProviderById(model.getProviderId());
        if (provider == null || provider.getEnabled() == null || provider.getEnabled() != 1)
        {
            return null;
        }
        AiProviderClient client = clientFactory.getClient(provider.getProviderCode());
        if (client == null)
        {
            return null;
        }
        return new ChatModelSpec(client, provider, model);
    }

    private String resolveModelName(ChatModelSpec spec)
    {
        if (spec == null || spec.model == null)
        {
            return "配置检查";
        }
        return StringUtils.defaultIfEmpty(spec.model.getModelName(), spec.model.getModelCode());
    }

    private static class ChatModelSpec
    {
        private final AiProviderClient client;
        private final ClinicAiProvider provider;
        private final ClinicAiModel model;

        private ChatModelSpec(AiProviderClient client, ClinicAiProvider provider, ClinicAiModel model)
        {
            this.client = client;
            this.provider = provider;
            this.model = model;
        }
    }

    private static class AssistantStatus
    {
        private final boolean available;
        private final String code;
        private final String message;
        private final JSONArray items;
        private final ChatModelSpec spec;

        private AssistantStatus(boolean available, String code, String message, JSONArray items, ChatModelSpec spec)
        {
            this.available = available;
            this.code = code;
            this.message = message;
            this.items = items != null ? items : new JSONArray();
            this.spec = spec;
        }

        private static AssistantStatus available(String code, String message, JSONArray items, ChatModelSpec spec)
        {
            return new AssistantStatus(true, code, message, items, spec);
        }

        private static AssistantStatus unavailable(String code, String message, JSONArray items, ChatModelSpec spec)
        {
            return new AssistantStatus(false, code, message, items, spec);
        }

        private boolean isAvailable()
        {
            return available;
        }

        private String getMessage()
        {
            return message;
        }

        private ChatModelSpec getSpec()
        {
            return spec;
        }

        private JSONObject toJson()
        {
            JSONObject payload = new JSONObject();
            payload.put("available", available);
            payload.put("code", code);
            payload.put("message", message);
            payload.put("items", items);
            payload.put("model", spec != null && spec.model != null ? StringUtils.defaultIfEmpty(spec.model.getModelName(), spec.model.getModelCode()) : "");
            payload.put("provider", spec != null && spec.provider != null ? StringUtils.defaultIfEmpty(spec.provider.getProviderName(), spec.provider.getProviderCode()) : "");
            return payload;
        }
    }
}
