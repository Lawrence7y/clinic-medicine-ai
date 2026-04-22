package com.ruoyi.project.clinic.medicine.service.support;

import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONArray;
import com.alibaba.fastjson2.JSONObject;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.project.clinic.ai.client.AiProviderClient;
import com.ruoyi.project.clinic.ai.domain.ClinicAiModel;
import com.ruoyi.project.clinic.ai.domain.ClinicAiProvider;
import com.ruoyi.project.clinic.ai.domain.ClinicAiSceneBinding;
import com.ruoyi.project.clinic.ai.factory.AiProviderClientFactory;
import com.ruoyi.project.clinic.ai.service.IClinicAiModelService;
import com.ruoyi.project.clinic.ai.service.IClinicAiProviderService;
import com.ruoyi.project.clinic.ai.service.IClinicAiSceneBindingService;
import com.ruoyi.project.clinic.ai.service.support.AiInvocationLogService;
import com.ruoyi.project.clinic.ai.service.support.ClinicAiChatService;
import com.ruoyi.project.clinic.medicine.domain.ClinicMedicine;
import com.ruoyi.project.clinic.medicine.dto.MedicineRecognitionCandidate;
import com.ruoyi.project.clinic.medicine.dto.MedicineRecognitionResult;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class MedicineRecognitionService
{
    @Autowired private MedicineLocalMatchService localMatchService;
    @Autowired private IClinicAiSceneBindingService sceneBindingService;
    @Autowired private IClinicAiModelService modelService;
    @Autowired private IClinicAiProviderService providerService;
    @Autowired private AiProviderClientFactory clientFactory;
    @Autowired private MedicineRecognitionHistoryService historyService;
    @Autowired private AiInvocationLogService aiInvocationLogService;
    @Autowired private ClinicAiChatService clinicAiChatService;

    public MedicineRecognitionResult recognizeByCode(String scene, String code)
    {
        SceneSpec spec = resolveSceneSpec(scene, "code");
        String barcode = StringUtils.trim(code);
        if (StringUtils.isEmpty(barcode)) throw new IllegalArgumentException("\u6761\u7801\u4e0d\u80fd\u4e3a\u7a7a");
        MedicineRecognitionResult result = buildBaseResult(spec);
        ClinicAiSceneBinding binding = loadSceneBinding(spec.sceneCode, spec.sceneName, spec.executionMode);
        Map<String, MedicineRecognitionCandidate> merged = new LinkedHashMap<String, MedicineRecognitionCandidate>();
        if (usesLocal(binding))
        {
            ClinicMedicine local = localMatchService.selectByBarcode(barcode);
            if (local != null)
            {
                result.setLocalMatched(true);
                addCandidate(merged, localMatchService.buildCandidate(local, "local_barcode", 0.99D));
            }
            else if (StringUtils.isNotEmpty(spec.localMissWarning) && isLocalOnly(binding))
            {
                result.getWarnings().add(spec.localMissWarning);
            }
        }
        if (usesModel(binding))
        {
            mergeSafely(result, merged, binding, spec, barcode, null);
        }
        finalizeResult(result, merged, binding.getCandidateLimit(), spec);
        historyService.recordRecognition(result, (List<String>) null);
        return result;
    }

    public MedicineRecognitionResult recognizeByImage(String scene, MultipartFile file) { return recognizeSingleImage(resolveSceneSpec(scene, "image"), file); }
    public MedicineRecognitionResult recognizeByOcr(String scene, MultipartFile file) { return recognizeSingleImage(resolveSceneSpec(scene, "ocr"), file); }
    public MedicineRecognitionResult recognizeByPackageImage(String scene, MultipartFile file) { return recognizeSingleImage(resolveSceneSpec(scene, "package_image"), file); }

    public MedicineRecognitionResult recognizeByMultiImage(String scene, MultipartFile[] files)
    {
        SceneSpec spec = resolveSceneSpec(scene, "multi_image");
        List<MultipartFile> validFiles = toValidFiles(files, 4);
        if (validFiles.isEmpty()) throw new IllegalArgumentException("\u81f3\u5c11\u4e0a\u4f20\u4e00\u5f20\u56fe\u7247");
        MedicineRecognitionResult result = buildBaseResult(spec);
        result.setImageCount(validFiles.size());
        ClinicAiSceneBinding binding = loadSceneBinding(spec.sceneCode, spec.sceneName, spec.executionMode);
        Map<String, MedicineRecognitionCandidate> merged = new LinkedHashMap<String, MedicineRecognitionCandidate>();
        for (MultipartFile file : validFiles) mergeSafely(result, merged, binding, spec, null, file);
        finalizeResult(result, merged, binding.getCandidateLimit(), spec);
        try { historyService.recordRecognition(result, historyService.saveImages(result.getSessionId(), toImagePayloads(validFiles))); }
        catch (Exception ignored) { historyService.recordRecognition(result, (List<String>) null); }
        return result;
    }

    public MedicineRecognitionResult recognizeByVoiceText(String scene, String voiceText)
    {
        SceneSpec spec = resolveSceneSpec(scene, "voice_text");
        String transcript = StringUtils.trim(voiceText);
        if (StringUtils.isEmpty(transcript)) throw new IllegalArgumentException("\u8bed\u97f3\u8f6c\u5199\u5185\u5bb9\u4e0d\u80fd\u4e3a\u7a7a");
        MedicineRecognitionResult result = buildBaseResult(spec);
        result.setRecognizedText(transcript);
        Map<String, MedicineRecognitionCandidate> merged = new LinkedHashMap<String, MedicineRecognitionCandidate>();
        try
        {
            String systemPrompt = "你是诊所药品识别助手，只能输出 JSON，不要输出 Markdown。"
                + "请按以下结构输出：{\"candidates\":[{\"candidateId\":\"\",\"name\":\"\",\"barcode\":\"\",\"specification\":\"\","
                + "\"manufacturer\":\"\",\"dosageForm\":\"\",\"form\":\"\",\"category\":\"\",\"storage\":\"\","
                + "\"pharmacology\":\"\",\"indications\":\"\",\"dosage\":\"\",\"sideEffects\":\"\",\"confidence\":0.8}]}";
            String prompt = "请从以下语音转写内容中提取药品候选信息，所有文本字段使用简体中文：\n" + transcript;
            JSONObject aiResult = clinicAiChatService.runAssistant(spec.sceneCode, systemPrompt, prompt);
            mergeCandidates(merged, parseAssistantCandidates(aiResult.getString("reply"), "voice_text"));
        }
        catch (Exception ex)
        {
            result.getWarnings().add(ex.getMessage());
        }
        finalizeResult(result, merged, 3, spec);
        historyService.recordRecognition(result, (List<String>) null);
        return result;
    }

    private MedicineRecognitionResult recognizeSingleImage(SceneSpec spec, MultipartFile file)
    {
        if (file == null || file.isEmpty()) throw new IllegalArgumentException("\u56fe\u7247\u6587\u4ef6\u4e0d\u80fd\u4e3a\u7a7a");
        MedicineRecognitionResult result = buildBaseResult(spec);
        result.setImageCount(1);
        ClinicAiSceneBinding binding = loadSceneBinding(spec.sceneCode, spec.sceneName, spec.executionMode);
        Map<String, MedicineRecognitionCandidate> merged = new LinkedHashMap<String, MedicineRecognitionCandidate>();
        mergeSafely(result, merged, binding, spec, null, file);
        finalizeResult(result, merged, binding.getCandidateLimit(), spec);
        try
        {
            List<String> imagePaths = new ArrayList<String>();
            imagePaths.add(historyService.saveImage(result.getSessionId(), file.getBytes(), file.getContentType()));
            historyService.recordRecognition(result, imagePaths);
        }
        catch (Exception ignored)
        {
            historyService.recordRecognition(result, (List<String>) null);
        }
        return result;
    }

    private void mergeSafely(MedicineRecognitionResult result, Map<String, MedicineRecognitionCandidate> merged,
        ClinicAiSceneBinding binding, SceneSpec spec, String code, MultipartFile file)
    {
        try { mergeCandidates(merged, recognizeWithConfiguredModel(binding, spec, code, file)); }
        catch (Exception ex) { result.getWarnings().add((file != null ? "\u56fe\u7247\u8bc6\u522b\u5931\u8d25\uff1a" : "") + ex.getMessage()); }
    }

    private List<MedicineRecognitionCandidate> recognizeWithConfiguredModel(ClinicAiSceneBinding binding, SceneSpec spec,
        String code, MultipartFile file) throws Exception
    {
        List<MedicineRecognitionCandidate> primary = recognizeWithModel(binding.getPrimaryModelId(), binding, spec, code, file);
        if (!primary.isEmpty() || binding.getFallbackModelId() == null || binding.getFallbackModelId().equals(binding.getPrimaryModelId())) return primary;
        return recognizeWithModel(binding.getFallbackModelId(), binding, spec, code, file);
    }

    private List<MedicineRecognitionCandidate> recognizeWithModel(Long modelId, ClinicAiSceneBinding binding, SceneSpec spec,
        String code, MultipartFile file) throws Exception
    {
        if (modelId == null) return new ArrayList<MedicineRecognitionCandidate>();
        ClinicAiModel model = modelService.selectClinicAiModelById(modelId);
        if (model == null || model.getEnabled() == null || model.getEnabled() != 1) return new ArrayList<MedicineRecognitionCandidate>();
        ClinicAiProvider provider = providerService.selectClinicAiProviderById(model.getProviderId());
        if (provider == null || provider.getEnabled() == null || provider.getEnabled() != 1) return new ArrayList<MedicineRecognitionCandidate>();
        AiProviderClient client = clientFactory.getClient(provider.getProviderCode());
        if (client == null) throw new IllegalStateException("\u4e0d\u652f\u6301\u7684 AI \u670d\u52a1\u5546\uff1a" + provider.getProviderCode());
        long startedAt = System.currentTimeMillis();
        boolean success = false;
        String failureReason = "";
        try
        {
            List<MedicineRecognitionCandidate> list = file != null
                ? recognizeVision(provider, model, binding, spec, client, file)
                : client.recognizeByCode(provider, model, binding, spec.businessScene, code);
            success = true;
            return list != null ? list : new ArrayList<MedicineRecognitionCandidate>();
        }
        catch (Exception ex)
        {
            failureReason = StringUtils.defaultIfEmpty(ex.getMessage(), ex.getClass().getSimpleName());
            throw ex;
        }
        finally
        {
            aiInvocationLogService.record(spec.sceneCode, StringUtils.defaultIfEmpty(model.getModelName(), model.getModelCode()), success, failureReason, Math.max(0L, System.currentTimeMillis() - startedAt));
        }
    }

    private List<MedicineRecognitionCandidate> recognizeVision(ClinicAiProvider provider, ClinicAiModel model,
        ClinicAiSceneBinding binding, SceneSpec spec, AiProviderClient client, MultipartFile file) throws Exception
    {
        if (model.getSupportsVision() == null || model.getSupportsVision() != 1)
        {
            throw new IllegalStateException("\u5f53\u524d\u6a21\u578b\u4e0d\u652f\u6301\u56fe\u7247\u8bc6\u522b");
        }
        return client.recognizeByImage(provider, model, binding, spec.businessScene, file.getOriginalFilename(),
            file.getBytes(), file.getContentType());
    }

    private List<MedicineRecognitionCandidate> parseAssistantCandidates(String rawReply, String defaultSource)
    {
        String normalized = normalizeJsonText(rawReply);
        if (StringUtils.isEmpty(normalized)) return new ArrayList<MedicineRecognitionCandidate>();
        Object parsed = JSON.parse(normalized);
        JSONArray array = parsed instanceof JSONArray ? (JSONArray) parsed : ((JSONObject) parsed).getJSONArray("candidates");
        List<MedicineRecognitionCandidate> list = new ArrayList<MedicineRecognitionCandidate>();
        if (array == null) return list;
        for (int i = 0; i < array.size(); i++)
        {
            JSONObject item = array.getJSONObject(i);
            if (item == null) continue;
            MedicineRecognitionCandidate c = new MedicineRecognitionCandidate();
            c.setCandidateId(StringUtils.defaultIfEmpty(item.getString("candidateId"), defaultSource + "_" + (i + 1)));
            c.setSource(defaultSource);
            c.setConfidence(item.getDouble("confidence"));
            c.setBarcode(cleanText(item.getString("barcode")));
            c.setName(cleanText(item.getString("name")));
            c.setSpecification(cleanText(item.getString("specification")));
            c.setManufacturer(cleanText(item.getString("manufacturer")));
            c.setDosageForm(cleanText(item.getString("dosageForm")));
            c.setForm(cleanText(item.getString("form")));
            c.setCategory(cleanText(item.getString("category")));
            c.setStorage(cleanText(item.getString("storage")));
            c.setPharmacology(cleanText(item.getString("pharmacology")));
            c.setIndications(cleanText(item.getString("indications")));
            c.setDosage(cleanText(item.getString("dosage")));
            c.setSideEffects(cleanText(item.getString("sideEffects")));
            if (StringUtils.isNotEmpty(c.getName()) || StringUtils.isNotEmpty(c.getBarcode())) list.add(c);
        }
        return list;
    }

    private void mergeCandidates(Map<String, MedicineRecognitionCandidate> merged, List<MedicineRecognitionCandidate> list)
    {
        if (list == null) return;
        for (MedicineRecognitionCandidate candidate : list)
        {
            ClinicMedicine existing = candidate == null ? null : localMatchService.findExistingMedicine(candidate);
            if (existing != null)
            {
                candidate.setMedicineId(existing.getMedicineId());
                if (StringUtils.isEmpty(candidate.getBarcode())) candidate.setBarcode(existing.getBarcode());
                if (StringUtils.isEmpty(candidate.getManufacturer())) candidate.setManufacturer(existing.getManufacturer());
                if (StringUtils.isEmpty(candidate.getSpecification())) candidate.setSpecification(existing.getSpecification());
            }
            addCandidate(merged, candidate);
        }
    }

    private void addCandidate(Map<String, MedicineRecognitionCandidate> merged, MedicineRecognitionCandidate candidate)
    {
        if (candidate == null || (StringUtils.isEmpty(candidate.getName()) && StringUtils.isEmpty(candidate.getBarcode()))) return;
        String key = StringUtils.defaultString(candidate.getBarcode()) + "|" + StringUtils.defaultString(candidate.getName()) + "|" + StringUtils.defaultString(candidate.getManufacturer()) + "|" + StringUtils.defaultString(candidate.getSpecification());
        if (!merged.containsKey(key)) merged.put(key, candidate);
    }

    private void finalizeResult(MedicineRecognitionResult result, Map<String, MedicineRecognitionCandidate> merged, Integer limit, SceneSpec spec)
    {
        result.setCandidates(limitCandidates(merged, limit));
        if ("create".equals(spec.businessScene)) result.getWarnings().add("\u4ef7\u683c\u9700\u624b\u52a8\u586b\u5199");
        if ("ocr".equals(spec.sourceType)) result.getWarnings().add("\u8bf4\u660e\u4e66 OCR \u7ed3\u679c\u9700\u4eba\u5de5\u786e\u8ba4\u540e\u518d\u5165\u5e93\u3002");
        if ("package_image".equals(spec.sourceType)) result.getWarnings().add("\u5305\u88c5\u56fe\u8bc6\u522b\u5efa\u8bae\u8865\u62cd\u6761\u7801\u9762\u548c\u5382\u5bb6\u533a\u57df\u3002");
        if ("multi_image".equals(spec.sourceType)) result.getWarnings().add("\u591a\u56fe\u8bc6\u522b\u5df2\u5408\u5e76\u5019\u9009\u7ed3\u679c\uff0c\u8bf7\u91cd\u70b9\u6838\u5bf9\u6761\u7801\u4e0e\u89c4\u683c\u3002");
        if ("voice_text".equals(spec.sourceType)) result.getWarnings().add("\u8bed\u97f3\u8f6c\u5199\u53ef\u80fd\u5b58\u5728\u540c\u97f3\u8bef\u5dee\uff0c\u8bf7\u4eba\u5de5\u6821\u5bf9\u5173\u952e\u5b57\u6bb5\u3002");
        if (result.getCandidates().isEmpty()) result.getWarnings().add(StringUtils.isNotEmpty(spec.localMissWarning) ? spec.localMissWarning : "\u672a\u8bc6\u522b\u5230\u53ef\u9760\u5019\u9009\u9879\uff0c\u8bf7\u624b\u52a8\u8865\u5145\u836f\u54c1\u4fe1\u606f\u3002");
    }

    private List<MedicineRecognitionCandidate> limitCandidates(Map<String, MedicineRecognitionCandidate> merged, Integer limit)
    {
        int size = limit != null && limit > 0 ? limit : 3;
        List<MedicineRecognitionCandidate> list = new ArrayList<MedicineRecognitionCandidate>(merged.values());
        return list.size() <= size ? list : new ArrayList<MedicineRecognitionCandidate>(list.subList(0, size));
    }

    private MedicineRecognitionResult buildBaseResult(SceneSpec spec)
    {
        MedicineRecognitionResult result = new MedicineRecognitionResult();
        result.setScene(spec.businessScene);
        result.setSource(spec.sourceType);
        result.setSessionId("rec_" + System.currentTimeMillis() + "_" + UUID.randomUUID().toString().substring(0, 8));
        result.setLocalMatched(false);
        result.setImageCount(0);
        return result;
    }

    private ClinicAiSceneBinding loadSceneBinding(String sceneCode, String sceneName, String executionMode)
    {
        ClinicAiSceneBinding binding = sceneBindingService.selectClinicAiSceneBindingByCode(sceneCode);
        if (binding != null) return binding;
        ClinicAiSceneBinding fallback = new ClinicAiSceneBinding();
        fallback.setSceneCode(sceneCode);
        fallback.setSceneName(sceneName);
        fallback.setExecutionMode(executionMode);
        fallback.setCandidateLimit(3);
        fallback.setTimeoutMs(sceneCode.contains("image") || sceneCode.contains("ocr") || sceneCode.contains("package") ? 90000 : 30000);
        fallback.setEnabled(1);
        return fallback;
    }

    private boolean usesLocal(ClinicAiSceneBinding binding) { return "local_only".equals(binding.getExecutionMode()) || "local_then_model".equals(binding.getExecutionMode()); }
    private boolean usesModel(ClinicAiSceneBinding binding) { return "model_only".equals(binding.getExecutionMode()) || "local_then_model".equals(binding.getExecutionMode()); }
    private boolean isLocalOnly(ClinicAiSceneBinding binding) { return "local_only".equals(binding.getExecutionMode()); }

    private List<MultipartFile> toValidFiles(MultipartFile[] files, int maxCount)
    {
        List<MultipartFile> list = new ArrayList<MultipartFile>();
        if (files == null) return list;
        for (MultipartFile file : files)
        {
            if (file != null && !file.isEmpty()) list.add(file);
            if (list.size() >= maxCount) break;
        }
        return list;
    }

    private List<MedicineRecognitionHistoryService.ImagePayload> toImagePayloads(List<MultipartFile> files) throws Exception
    {
        List<MedicineRecognitionHistoryService.ImagePayload> list = new ArrayList<MedicineRecognitionHistoryService.ImagePayload>();
        if (files == null) return list;
        for (MultipartFile file : files) if (file != null && !file.isEmpty()) list.add(new MedicineRecognitionHistoryService.ImagePayload(file.getBytes(), file.getContentType()));
        return list;
    }

    private String normalizeJsonText(String rawText)
    {
        if (StringUtils.isEmpty(rawText)) return "";
        String trimmed = rawText.trim();
        int left = trimmed.indexOf('{');
        int right = trimmed.lastIndexOf('}');
        return left >= 0 && right > left ? trimmed.substring(left, right + 1) : trimmed;
    }

    private String cleanText(String value)
    {
        String text = StringUtils.trim(value);
        if (StringUtils.isEmpty(text)) return null;
        String compact = text.replaceAll("[\\s:;,.\\uFF0C\\uFF1A\\uFF1B]+", "").toLowerCase();
        return "\u65e0".equals(compact) || "\u6682\u65e0".equals(compact) || "\u672a\u77e5".equals(compact) || "null".equals(compact) ? null : text;
    }

    private SceneSpec resolveSceneSpec(String scene, String sourceType)
    {
        String businessScene = StringUtils.defaultIfEmpty(StringUtils.trim(scene), "create");
        if (!"code".equals(sourceType) && !"create".equals(businessScene)) throw new IllegalArgumentException("\u5f53\u524d\u8bc6\u522b\u65b9\u5f0f\u4ec5\u652f\u6301\u65b0\u5efa\u836f\u54c1\u573a\u666f");
        if ("code".equals(sourceType))
        {
            if ("stock_in".equals(businessScene)) return new SceneSpec(businessScene, "code", "medicine_stock_in_code", "\u836f\u54c1\u5165\u5e93-\u626b\u7801\u8bc6\u522b", "local_only", "\u672a\u5339\u914d\u5230\u672c\u5730\u836f\u54c1\uff0c\u8bf7\u5148\u65b0\u5efa\u836f\u54c1\u6863\u6848\u3002");
            if ("stock_out".equals(businessScene)) return new SceneSpec(businessScene, "code", "medicine_stock_out_code", "\u836f\u54c1\u51fa\u5e93-\u626b\u7801\u8bc6\u522b", "local_only", "\u7cfb\u7edf\u672a\u627e\u5230\u672c\u5730\u836f\u54c1\u6863\u6848\uff0c\u4e0d\u80fd\u76f4\u63a5\u51fa\u5e93\u3002");
            return new SceneSpec("create", "code", "medicine_create_code", "\u836f\u54c1\u65b0\u5efa-\u626b\u7801\u8bc6\u522b", "local_then_model", null);
        }
        if ("image".equals(sourceType)) return new SceneSpec("create", "image", "medicine_create_image", "\u836f\u54c1\u65b0\u5efa-\u62cd\u7167\u8bc6\u522b", "model_only", null);
        if ("ocr".equals(sourceType)) return new SceneSpec("create", "ocr", "medicine_create_ocr", "\u836f\u54c1\u8bf4\u660e\u4e66OCR\u8bc6\u522b", "model_only", null);
        if ("package_image".equals(sourceType)) return new SceneSpec("create", "package_image", "medicine_create_package", "\u836f\u54c1\u5305\u88c5\u56fe\u8bc6\u522b", "model_only", null);
        if ("multi_image".equals(sourceType)) return new SceneSpec("create", "multi_image", "medicine_create_multi_image", "\u836f\u54c1\u591a\u56fe\u8bc6\u522b", "model_only", null);
        if ("voice_text".equals(sourceType)) return new SceneSpec("create", "voice_text", "medicine_create_voice_text", "\u836f\u54c1\u8bed\u97f3\u8f6c\u5199\u8bc6\u522b", "model_only", null);
        throw new IllegalArgumentException("\u4e0d\u652f\u6301\u7684\u8bc6\u522b\u65b9\u5f0f");
    }

    private static class SceneSpec
    {
        private final String businessScene;
        private final String sourceType;
        private final String sceneCode;
        private final String sceneName;
        private final String executionMode;
        private final String localMissWarning;

        private SceneSpec(String businessScene, String sourceType, String sceneCode, String sceneName, String executionMode, String localMissWarning)
        {
            this.businessScene = businessScene;
            this.sourceType = sourceType;
            this.sceneCode = sceneCode;
            this.sceneName = sceneName;
            this.executionMode = executionMode;
            this.localMissWarning = localMissWarning;
        }
    }
}
