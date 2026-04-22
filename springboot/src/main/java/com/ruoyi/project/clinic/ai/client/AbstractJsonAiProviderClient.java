package com.ruoyi.project.clinic.ai.client;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Base64;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;
import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONArray;
import com.alibaba.fastjson2.JSONObject;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.project.clinic.ai.domain.ClinicAiModel;
import com.ruoyi.project.clinic.ai.domain.ClinicAiProvider;
import com.ruoyi.project.clinic.ai.domain.ClinicAiSceneBinding;
import com.ruoyi.project.clinic.medicine.dto.MedicineRecognitionCandidate;

abstract class AbstractJsonAiProviderClient implements AiProviderClient
{
    private static final int DEFAULT_TIMEOUT_MS = 60000;
    private static final int BARCODE_LOOKUP_TIMEOUT_MS = 8000;
    private static final int TEST_RESPONSE_PREVIEW_LENGTH = 80;
    private static final String BARCODE_LOOKUP_URL_PREFIX = "https://68api.com/barcode/";
    private static final Map<String, String> COMMON_MEDICAL_TEXT_TRANSLATIONS = buildCommonMedicalTextTranslations();
    private static final String[] VERIFICATION_TEXT_MARKERS = new String[] {"访问验证", "完成验证后继续浏览", "请完成验证后继续浏览",
        "滑块验证", "验证码", "人机验证", "安全验证", "验证后继续", "访问频率过高"};

    @Override
    public List<MedicineRecognitionCandidate> recognizeByCode(ClinicAiProvider provider, ClinicAiModel model,
        ClinicAiSceneBinding sceneBinding, String scene, String code)
    {
        BarcodeEvidence barcodeEvidence = loadBarcodeEvidence(code);
        JSONObject requestBody = buildTextRequest(model, buildCodePrompt(sceneBinding, scene, code, barcodeEvidence));
        try
        {
            List<MedicineRecognitionCandidate> candidates = parseCandidates(doPostJson(provider, sceneBinding, requestBody),
                "model_search");
            return mergeCodeRecognitionCandidates(candidates, barcodeEvidence, code);
        }
        catch (Exception ex)
        {
            if (barcodeEvidence != null)
            {
                return buildFallbackCandidatesFromEvidence(barcodeEvidence, code);
            }
            throw ex;
        }
    }

    @Override
    public List<MedicineRecognitionCandidate> recognizeByImage(ClinicAiProvider provider, ClinicAiModel model,
        ClinicAiSceneBinding sceneBinding, String scene, String fileName, byte[] fileBytes, String contentType)
    {
        String mimeType = StringUtils.isNotEmpty(contentType) ? contentType : "image/jpeg";
        String imageDataUrl = "data:" + mimeType + ";base64," + Base64.getEncoder().encodeToString(fileBytes);
        JSONObject requestBody = buildVisionRequest(model, buildImagePrompt(sceneBinding, scene, fileName), imageDataUrl);
        return parseCandidates(doPostJson(provider, sceneBinding, requestBody), "model_vision");
    }

    @Override
    public String testConnection(ClinicAiProvider provider)
    {
        HttpURLConnection connection = null;
        try
        {
            connection = openConnection(provider, "GET", DEFAULT_TIMEOUT_MS);
            int status = connection.getResponseCode();
            if (status >= 200 && status < 300)
            {
                return "连接可达，HTTP " + status;
            }
            if (status == 401 || status == 403)
            {
                return "连接可达，但 API Key 校验失败，HTTP " + status;
            }
            if (status == 404 || status == 405)
            {
                return "端点可达。当前测试使用 GET，请求 chat-completions 接口时返回 HTTP "
                    + status + " 属于常见情况，建议再用真实模型请求确认。";
            }
            if (status < 500)
            {
                return "连接可用，HTTP " + status;
            }
            throw new IllegalStateException("连接失败，HTTP " + status);
        }
        catch (Exception ex)
        {
            throw new IllegalStateException(ex.getMessage(), ex);
        }
        finally
        {
            if (connection != null)
            {
                connection.disconnect();
            }
        }
    }

    @Override
    public String testConnection(ClinicAiProvider provider, ClinicAiModel model)
    {
        if (model != null && StringUtils.isNotEmpty(model.getModelCode()))
        {
            String content = doPostJson(provider, null, buildTextRequest(model, "请仅回复“OK”。"));
            return "连接成功。模型 " + model.getModelCode().trim() + " 返回："
                + previewContent(content);
        }
        return testConnection(provider);
    }

    @Override
    public String chat(ClinicAiProvider provider, ClinicAiModel model, String systemPrompt, String userPrompt)
    {
        JSONObject requestBody = buildChatRequest(model, systemPrompt, userPrompt);
        // doPostJson already extracts the model content from provider JSON response.
        return doPostJson(provider, null, requestBody);
    }

    protected JSONObject buildTextRequest(ClinicAiModel model, String prompt)
    {
        JSONObject requestBody = new JSONObject();
        requestBody.put("model", resolveModelCode(model));
        requestBody.put("temperature", 0.2);
        requestBody.put("messages", buildTextMessages(prompt));
        return requestBody;
    }

    protected JSONObject buildChatRequest(ClinicAiModel model, String systemPrompt, String userPrompt)
    {
        JSONObject requestBody = new JSONObject();
        requestBody.put("model", resolveModelCode(model));
        requestBody.put("temperature", 0.2);

        JSONArray messages = new JSONArray();
        JSONObject systemMessage = new JSONObject();
        systemMessage.put("role", "system");
        systemMessage.put("content", StringUtils.defaultIfEmpty(systemPrompt, systemPrompt()));
        messages.add(systemMessage);

        JSONObject userMessage = new JSONObject();
        userMessage.put("role", "user");
        userMessage.put("content", userPrompt);
        messages.add(userMessage);

        requestBody.put("messages", messages);
        return requestBody;
    }

    protected JSONObject buildVisionRequest(ClinicAiModel model, String prompt, String imageDataUrl)
    {
        JSONObject requestBody = new JSONObject();
        requestBody.put("model", resolveModelCode(model));
        requestBody.put("temperature", 0.2);

        JSONArray messages = new JSONArray();
        JSONObject systemMessage = new JSONObject();
        systemMessage.put("role", "system");
        systemMessage.put("content", systemPrompt());
        messages.add(systemMessage);

        JSONObject userMessage = new JSONObject();
        userMessage.put("role", "user");
        JSONArray content = new JSONArray();

        JSONObject textItem = new JSONObject();
        textItem.put("type", "text");
        textItem.put("text", prompt);
        content.add(textItem);

        JSONObject imageItem = new JSONObject();
        imageItem.put("type", "image_url");
        JSONObject imageUrl = new JSONObject();
        imageUrl.put("url", imageDataUrl);
        imageItem.put("image_url", imageUrl);
        content.add(imageItem);

        userMessage.put("content", content);
        messages.add(userMessage);
        requestBody.put("messages", messages);
        return requestBody;
    }

    protected JSONArray buildTextMessages(String prompt)
    {
        JSONArray messages = new JSONArray();
        JSONObject systemMessage = new JSONObject();
        systemMessage.put("role", "system");
        systemMessage.put("content", systemPrompt());
        messages.add(systemMessage);

        JSONObject userMessage = new JSONObject();
        userMessage.put("role", "user");
        userMessage.put("content", prompt);
        messages.add(userMessage);
        return messages;
    }

    protected String systemPrompt()
    {
        return "你是中国诊所系统的药品识别助手。仅允许输出 JSON，不要输出 Markdown。"
            + "除 candidateId、barcode、evidenceUrls 外，其余文本字段必须使用简体中文。"
            + "优先使用药品官方中文通用名、中文厂家名称和标准中文医学术语。"
            + "dosageForm、form、category、storage、pharmacology、indications、dosage、sideEffects 必须使用自然中文表达。"
            + "如果来源资料是英文，请先翻译成中文再输出最终 JSON。"
            + "barcode、evidenceUrls、数字规格要保持准确；不确定字段返回 null。"
            + "输出结构：{\"candidates\":[{\"candidateId\":string,\"barcode\":string|null,\"name\":string|null,"
            + "\"specification\":string|null,\"manufacturer\":string|null,\"dosageForm\":string|null,"
            + "\"form\":string|null,\"category\":string|null,\"storage\":string|null,\"pharmacology\":string|null,"
            + "\"indications\":string|null,\"dosage\":string|null,\"sideEffects\":string|null,"
            + "\"confidence\":number|null,\"evidenceUrls\":string[]}]}";
    }

    protected String buildCodePrompt(ClinicAiSceneBinding sceneBinding, String scene, String code,
        BarcodeEvidence barcodeEvidence)
    {
        return "请根据以下条形码识别药品信息。条形码：" + code + "。场景：" + scene + "。"
            + "如可联网，请优先参考药品说明书、国家药监公开信息或可靠药品资料。"
            + "最多返回" + resolveCandidateLimit(sceneBinding) + "个候选。"
            + "所有返回文本字段必须使用简体中文，药品名称优先使用官方中文通用名或包装上的中文名。"
            + "重点返回自动填表需要的字段：barcode、name、specification、manufacturer、dosageForm、form、category、storage、pharmacology、indications、dosage、sideEffects。"
            + "不要猜测价格、批号或有效期。不确定字段返回 null，并尽量提供 evidenceUrls。"
            + "如果下方已经给出“条码检索证据”，请把这些证据视为已完成联网检索后的可靠线索，不要回答“无法联网”或“无法确认”。"
            + "请优先根据证据确定基础字段，再结合药品知识补充药理作用、适应症、用法用量和不良反应。"
            + buildBarcodeEvidencePrompt(barcodeEvidence);
    }

    protected String buildImagePrompt(ClinicAiSceneBinding sceneBinding, String scene, String fileName)
    {
        return "请识别上传药品包装图片中的药品信息"
            + (StringUtils.isNotEmpty(fileName) ? " (" + fileName + ")" : "")
            + "。场景：" + scene + "。最多返回" + resolveCandidateLimit(sceneBinding) + "个候选。"
            + "所有返回文本字段必须使用简体中文，药品名称优先使用官方中文通用名或包装上的中文名。"
            + "重点返回自动填表需要的字段：barcode、name、specification、manufacturer、dosageForm、form、category、storage、pharmacology、indications、dosage、sideEffects。"
            + "不要输出价格、批号或有效期。不确定字段返回 null，并尽量提供 evidenceUrls。";
    }

    protected int resolveCandidateLimit(ClinicAiSceneBinding sceneBinding)
    {
        return sceneBinding != null && sceneBinding.getCandidateLimit() != null && sceneBinding.getCandidateLimit() > 0
            ? sceneBinding.getCandidateLimit()
            : 3;
    }

    protected String doPostJson(ClinicAiProvider provider, ClinicAiSceneBinding sceneBinding, JSONObject requestBody)
    {
        HttpURLConnection connection = null;
        try
        {
            int timeoutMs = sceneBinding != null && sceneBinding.getTimeoutMs() != null && sceneBinding.getTimeoutMs() > 0
                ? sceneBinding.getTimeoutMs()
                : DEFAULT_TIMEOUT_MS;
            connection = openConnection(provider, "POST", timeoutMs);
            connection.setDoOutput(true);
            byte[] payload = requestBody.toJSONString().getBytes(StandardCharsets.UTF_8);
            try (OutputStream outputStream = connection.getOutputStream())
            {
                outputStream.write(payload);
            }

            int status = connection.getResponseCode();
            if (status < 200 || status >= 300)
            {
                throw new IllegalStateException("服务商响应异常 " + status + ": " + readStream(connection.getErrorStream()));
            }
            String content = extractContent(readStream(connection.getInputStream()));
            if (StringUtils.isEmpty(content))
            {
                throw new IllegalStateException("服务商返回内容为空");
            }
            return content;
        }
        catch (Exception ex)
        {
            throw new IllegalStateException("AI 服务商请求失败: " + ex.getMessage(), ex);
        }
        finally
        {
            if (connection != null)
            {
                connection.disconnect();
            }
        }
    }

    protected HttpURLConnection openConnection(ClinicAiProvider provider, String method, int timeoutMs) throws Exception
    {
        URL url = new URL(normalizeEndpoint(provider));
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod(method);
        connection.setConnectTimeout(timeoutMs);
        connection.setReadTimeout(timeoutMs);
        connection.setRequestProperty("Content-Type", "application/json");
        connection.setRequestProperty("Accept", "application/json");
        if (StringUtils.isNotEmpty(provider.getApiKey()))
        {
            connection.setRequestProperty("Authorization", "Bearer " + provider.getApiKey().trim());
        }
        return connection;
    }

    protected String extractContent(String body)
    {
        if (StringUtils.isEmpty(body))
        {
            return "";
        }
        String normalized = body.trim();
        JSONObject json = null;
        try
        {
            json = JSON.parseObject(normalized);
        }
        catch (Exception ignored)
        {
            // Some providers/proxies may return plain text directly.
            return normalized;
        }
        JSONArray choices = json.getJSONArray("choices");
        if (choices != null && !choices.isEmpty())
        {
            JSONObject message = choices.getJSONObject(0).getJSONObject("message");
            if (message != null)
            {
                return contentToString(message.get("content"));
            }
        }

        JSONArray output = json.getJSONArray("output");
        if (output != null && !output.isEmpty())
        {
            JSONArray content = output.getJSONObject(0).getJSONArray("content");
            if (content != null)
            {
                return contentToString(content);
            }
        }

        if (json.containsKey("reply"))
        {
            return json.getString("reply");
        }
        if (json.containsKey("text"))
        {
            return json.getString("text");
        }
        return normalized;
    }

    protected String contentToString(Object content)
    {
        if (content == null)
        {
            return "";
        }
        if (content instanceof String)
        {
            return (String) content;
        }
        if (content instanceof JSONArray)
        {
            JSONArray array = (JSONArray) content;
            StringBuilder builder = new StringBuilder();
            for (int i = 0; i < array.size(); i++)
            {
                Object item = array.get(i);
                if (item instanceof String)
                {
                    builder.append((String) item);
                }
                else if (item instanceof JSONObject)
                {
                    String text = ((JSONObject) item).getString("text");
                    if (StringUtils.isNotEmpty(text))
                    {
                        builder.append(text);
                    }
                }
            }
            return builder.toString();
        }
        return JSON.toJSONString(content);
    }

    protected List<MedicineRecognitionCandidate> parseCandidates(String content, String defaultSource)
    {
        String normalized = normalizeJsonText(content);
        if (StringUtils.isEmpty(normalized))
        {
            return new ArrayList<MedicineRecognitionCandidate>();
        }

        Object parsed = JSON.parse(normalized);
        JSONArray candidateArray = null;
        if (parsed instanceof JSONObject)
        {
            JSONObject jsonObject = (JSONObject) parsed;
            candidateArray = jsonObject.getJSONArray("candidates");
            if (candidateArray == null && (jsonObject.containsKey("name") || jsonObject.containsKey("barcode")))
            {
                candidateArray = new JSONArray();
                candidateArray.add(jsonObject);
            }
        }
        else if (parsed instanceof JSONArray)
        {
            candidateArray = (JSONArray) parsed;
        }

        List<MedicineRecognitionCandidate> results = new ArrayList<MedicineRecognitionCandidate>();
        if (candidateArray == null)
        {
            return results;
        }

        Set<String> dedupeKeys = new LinkedHashSet<String>();
        for (int i = 0; i < candidateArray.size(); i++)
        {
            JSONObject item = candidateArray.getJSONObject(i);
            if (item == null)
            {
                continue;
            }
            MedicineRecognitionCandidate candidate = new MedicineRecognitionCandidate();
            candidate.setCandidateId(StringUtils.defaultIfEmpty(trimToNull(item.getString("candidateId")), "cand_" + (i + 1)));
            candidate.setSource(StringUtils.defaultIfEmpty(item.getString("source"), defaultSource));
            candidate.setConfidence(item.getDouble("confidence"));
            candidate.setBarcode(normalizeCandidateField("barcode", item.getString("barcode")));
            candidate.setName(normalizeCandidateField("name", item.getString("name")));
            candidate.setSpecification(normalizeCandidateField("specification", item.getString("specification")));
            candidate.setManufacturer(normalizeCandidateField("manufacturer", item.getString("manufacturer")));
            candidate.setDosageForm(normalizeCandidateField("dosageForm", item.getString("dosageForm")));
            candidate.setForm(normalizeCandidateField("form", item.getString("form")));
            candidate.setCategory(normalizeCandidateField("category", item.getString("category")));
            candidate.setStorage(normalizeCandidateField("storage", item.getString("storage")));
            candidate.setPharmacology(normalizeCandidateField("pharmacology", item.getString("pharmacology")));
            candidate.setIndications(normalizeCandidateField("indications", item.getString("indications")));
            candidate.setDosage(normalizeCandidateField("dosage", item.getString("dosage")));
            candidate.setSideEffects(normalizeCandidateField("sideEffects", item.getString("sideEffects")));
            candidate.setEvidenceUrls(stringList(item.getJSONArray("evidenceUrls")));
            if (StringUtils.isEmpty(candidate.getName()) && StringUtils.isEmpty(candidate.getBarcode()))
            {
                continue;
            }
            String key = StringUtils.defaultString(candidate.getBarcode()) + "|"
                + StringUtils.defaultString(candidate.getName()) + "|"
                + StringUtils.defaultString(candidate.getManufacturer()) + "|"
                + StringUtils.defaultString(candidate.getSpecification());
            if (dedupeKeys.add(key))
            {
                results.add(candidate);
            }
        }
        return results;
    }

    protected List<String> stringList(JSONArray array)
    {
        List<String> values = new ArrayList<String>();
        if (array == null)
        {
            return values;
        }
        for (int i = 0; i < array.size(); i++)
        {
            String value = trimToNull(array.getString(i));
            if (value != null)
            {
                values.add(value);
            }
        }
        return values;
    }

    protected String normalizeJsonText(String content)
    {
        String normalized = StringUtils.trim(content);
        if (StringUtils.isEmpty(normalized))
        {
            return normalized;
        }
        normalized = normalized.replaceFirst("(?s)^<think>.*?</think>\\s*", "");
        if (normalized.startsWith("```"))
        {
            normalized = normalized.replaceFirst("^```json", "");
            normalized = normalized.replaceFirst("^```", "");
            normalized = normalized.replaceFirst("```$", "");
            normalized = normalized.trim();
        }
        return extractJsonPayload(normalized);
    }

    protected String extractJsonPayload(String content)
    {
        int objectIndex = content.indexOf('{');
        int arrayIndex = content.indexOf('[');
        int start = -1;
        char opening = '{';
        char closing = '}';
        if (objectIndex >= 0 && (arrayIndex < 0 || objectIndex < arrayIndex))
        {
            start = objectIndex;
        }
        else if (arrayIndex >= 0)
        {
            start = arrayIndex;
            opening = '[';
            closing = ']';
        }
        if (start < 0)
        {
            return content;
        }
        int end = findJsonEnd(content, start, opening, closing);
        if (end < 0)
        {
            return content.substring(start).trim();
        }
        return content.substring(start, end + 1).trim();
    }

    protected int findJsonEnd(String content, int start, char opening, char closing)
    {
        boolean inString = false;
        boolean escaped = false;
        int depth = 0;
        for (int i = start; i < content.length(); i++)
        {
            char current = content.charAt(i);
            if (escaped)
            {
                escaped = false;
                continue;
            }
            if (current == '\\')
            {
                escaped = true;
                continue;
            }
            if (current == '"')
            {
                inString = !inString;
                continue;
            }
            if (inString)
            {
                continue;
            }
            if (current == opening)
            {
                depth++;
            }
            else if (current == closing)
            {
                depth--;
                if (depth == 0)
                {
                    return i;
                }
            }
        }
        return -1;
    }

    protected String trimToNull(String value)
    {
        String normalized = StringUtils.trim(value);
        return StringUtils.isEmpty(normalized) ? null : normalized;
    }

    protected String buildBarcodeEvidencePrompt(BarcodeEvidence barcodeEvidence)
    {
        if (barcodeEvidence == null || !barcodeEvidence.hasUsefulData())
        {
            return "";
        }
        StringBuilder builder = new StringBuilder();
        builder.append(" 已检索到的条码证据如下：");
        builder.append("条码=").append(barcodeEvidence.getBarcode()).append("；");
        if (StringUtils.isNotEmpty(barcodeEvidence.getName()))
        {
            builder.append("药品名称=").append(barcodeEvidence.getName()).append("；");
        }
        if (StringUtils.isNotEmpty(barcodeEvidence.getGenericName()))
        {
            builder.append("通用名称=").append(barcodeEvidence.getGenericName()).append("；");
        }
        if (StringUtils.isNotEmpty(barcodeEvidence.getBrand()))
        {
            builder.append("品牌名称=").append(barcodeEvidence.getBrand()).append("；");
        }
        if (StringUtils.isNotEmpty(barcodeEvidence.getSpecification()))
        {
            builder.append("规格=").append(barcodeEvidence.getSpecification()).append("；");
        }
        if (StringUtils.isNotEmpty(barcodeEvidence.getManufacturer()))
        {
            builder.append("生产企业=").append(barcodeEvidence.getManufacturer()).append("；");
        }
        if (StringUtils.isNotEmpty(barcodeEvidence.getCategory()))
        {
            builder.append("商品分类=").append(barcodeEvidence.getCategory()).append("；");
        }
        if (StringUtils.isNotEmpty(barcodeEvidence.getRawSummary()))
        {
            builder.append("页面摘要=").append(barcodeEvidence.getRawSummary()).append("；");
        }
        if (StringUtils.isNotEmpty(barcodeEvidence.getLookupUrl()))
        {
            builder.append("证据链接=").append(barcodeEvidence.getLookupUrl()).append("。");
        }
        return builder.toString();
    }

    protected BarcodeEvidence loadBarcodeEvidence(String code)
    {
        String normalizedCode = trimToNull(code);
        if (normalizedCode == null)
        {
            return null;
        }
        HttpURLConnection connection = null;
        try
        {
            String lookupUrl = BARCODE_LOOKUP_URL_PREFIX + normalizedCode;
            connection = openSimpleGetConnection(lookupUrl, BARCODE_LOOKUP_TIMEOUT_MS, "text/html,application/xhtml+xml");
            int status = connection.getResponseCode();
            if (status < 200 || status >= 300)
            {
                return null;
            }
            BarcodeEvidence barcodeEvidence = parseBarcodeEvidence(normalizedCode, lookupUrl,
                readStream(connection.getInputStream()));
            return barcodeEvidence != null && barcodeEvidence.hasUsefulData() ? barcodeEvidence : null;
        }
        catch (Exception ex)
        {
            return null;
        }
        finally
        {
            if (connection != null)
            {
                connection.disconnect();
            }
        }
    }

    protected HttpURLConnection openSimpleGetConnection(String urlValue, int timeoutMs, String acceptValue) throws Exception
    {
        HttpURLConnection connection = (HttpURLConnection) new URL(urlValue).openConnection();
        connection.setRequestMethod("GET");
        connection.setConnectTimeout(timeoutMs);
        connection.setReadTimeout(timeoutMs);
        connection.setRequestProperty("Accept", acceptValue);
        connection.setRequestProperty("User-Agent",
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123 Safari/537.36");
        return connection;
    }

    protected BarcodeEvidence parseBarcodeEvidence(String barcode, String lookupUrl, String html)
    {
        String normalizedHtml = trimToNull(html);
        if (normalizedHtml == null)
        {
            return null;
        }
        if (isVerificationPage(normalizedHtml))
        {
            return null;
        }
        BarcodeEvidence barcodeEvidence = new BarcodeEvidence();
        barcodeEvidence.setBarcode(barcode);
        barcodeEvidence.setLookupUrl(lookupUrl);
        barcodeEvidence.setName(firstNonEmpty(
            extractLabeledDivValue(normalizedHtml, "通用名称"),
            cleanupBarcodeTitle(extractRegexGroup(normalizedHtml, "(?is)<div\\s+class=\"bar-1-right\">.*?<strong>(.*?)</strong>")),
            cleanupBarcodeTitle(extractRegexGroup(normalizedHtml, "(?is)<title>(.*?)</title>"))));
        barcodeEvidence.setGenericName(extractLabeledDivValue(normalizedHtml, "通用名称"));
        barcodeEvidence.setBrand(extractLabeledDivValue(normalizedHtml, "品牌名称"));
        barcodeEvidence.setCategory(extractLabeledDivValue(normalizedHtml, "商品分类"));
        barcodeEvidence.setSpecification(firstNonEmpty(extractLabeledDivValue(normalizedHtml, "规格"),
            extractRegexGroup(normalizedHtml, "(?is)<meta\\s+name=\"description\"\\s+content=\".*?规格([^，。\"]+)")));
        barcodeEvidence.setManufacturer(firstNonEmpty(
            extractRegexGroup(normalizedHtml, "(?is)<span\\s+class=\"sub-title\">厂家信息</span>.*?<strong>(.*?)</strong>"),
            extractRegexGroup(normalizedHtml, "(?is)<meta\\s+name=\"description\"\\s+content=\".*?由(.*?)生产"),
            extractLabeledDivValue(normalizedHtml, "生产企业")));
        barcodeEvidence.setRawSummary(extractRegexGroup(normalizedHtml,
            "(?is)<meta\\s+name=\"description\"\\s+content=\"(.*?)\""));
        barcodeEvidence.setDosageForm(inferDosageFormFromEvidence(barcodeEvidence));
        if (StringUtils.isEmpty(barcodeEvidence.getName()) && StringUtils.isNotEmpty(barcodeEvidence.getBrand()))
        {
            barcodeEvidence.setName(barcodeEvidence.getBrand());
        }
        return barcodeEvidence.hasUsefulData() ? barcodeEvidence : null;
    }

    protected String extractLabeledDivValue(String html, String label)
    {
        return htmlToPlainText(extractRegexGroup(html,
            "(?is)<div>\\s*<div>\\s*" + Pattern.quote(label) + "\\s*</div>\\s*<div>(.*?)</div>\\s*</div>"));
    }

    protected String extractRegexGroup(String content, String regex)
    {
        if (StringUtils.isEmpty(content) || StringUtils.isEmpty(regex))
        {
            return null;
        }
        java.util.regex.Matcher matcher = Pattern.compile(regex).matcher(content);
        if (!matcher.find() || matcher.groupCount() < 1)
        {
            return null;
        }
        return trimToNull(matcher.group(1));
    }

    protected String cleanupBarcodeTitle(String title)
    {
        String normalized = htmlToPlainText(title);
        if (normalized == null)
        {
            return null;
        }
        int splitIndex = normalized.indexOf('_');
        if (splitIndex > 0)
        {
            normalized = normalized.substring(0, splitIndex);
        }
        splitIndex = normalized.indexOf('-');
        if (splitIndex > 0)
        {
            normalized = normalized.substring(0, splitIndex);
        }
        return trimToNull(normalized);
    }

    protected String htmlToPlainText(String html)
    {
        String normalized = trimToNull(html);
        if (normalized == null)
        {
            return null;
        }
        normalized = normalized.replaceAll("(?is)<script.*?</script>", " ");
        normalized = normalized.replaceAll("(?is)<style.*?</style>", " ");
        normalized = normalized.replaceAll("(?is)<[^>]+>", " ");
        normalized = normalized.replace("&nbsp;", " ");
        normalized = normalized.replace("&amp;", "&");
        normalized = normalized.replace("&quot;", "\"");
        normalized = normalized.replace("&#39;", "'");
        normalized = normalized.replace("&lt;", "<");
        normalized = normalized.replace("&gt;", ">");
        normalized = normalized.replace("&#183;", "·");
        return normalizeGenericText(normalized);
    }

    protected String firstNonEmpty(String... values)
    {
        if (values == null)
        {
            return null;
        }
        for (String value : values)
        {
            String normalized = trimToNull(value);
            if (normalized != null)
            {
                return normalized;
            }
        }
        return null;
    }

    protected String inferDosageFormFromEvidence(BarcodeEvidence barcodeEvidence)
    {
        if (barcodeEvidence == null)
        {
            return null;
        }
        String combined = StringUtils.defaultString(barcodeEvidence.getName()) + " "
            + StringUtils.defaultString(barcodeEvidence.getSpecification()) + " "
            + StringUtils.defaultString(barcodeEvidence.getRawSummary());
        String normalized = normalizeGenericText(combined);
        if (normalized == null)
        {
            return null;
        }
        if (normalized.contains("胶囊"))
        {
            return "胶囊剂";
        }
        if (normalized.contains("颗粒"))
        {
            return "颗粒剂";
        }
        if (normalized.contains("口服液"))
        {
            return "口服液";
        }
        if (normalized.contains("糖浆"))
        {
            return "糖浆剂";
        }
        if (normalized.contains("喷雾"))
        {
            return "喷雾剂";
        }
        if (normalized.contains("注射"))
        {
            return "注射剂";
        }
        if (normalized.contains("乳膏"))
        {
            return "乳膏剂";
        }
        if (normalized.contains("软膏"))
        {
            return "软膏剂";
        }
        if (normalized.contains("滴眼液"))
        {
            return "滴眼液";
        }
        if (normalized.contains("片"))
        {
            return "片剂";
        }
        if (normalized.contains("丸"))
        {
            return "丸剂";
        }
        return null;
    }

    protected List<MedicineRecognitionCandidate> mergeCodeRecognitionCandidates(
        List<MedicineRecognitionCandidate> candidates, BarcodeEvidence barcodeEvidence, String barcode)
    {
        List<MedicineRecognitionCandidate> mergedCandidates = candidates != null
            ? candidates
            : new ArrayList<MedicineRecognitionCandidate>();
        if (barcodeEvidence == null)
        {
            return mergedCandidates;
        }
        if (mergedCandidates.isEmpty())
        {
            return buildFallbackCandidatesFromEvidence(barcodeEvidence, barcode);
        }
        for (MedicineRecognitionCandidate candidate : mergedCandidates)
        {
            if (candidate == null)
            {
                continue;
            }
            if (StringUtils.isEmpty(candidate.getBarcode()))
            {
                candidate.setBarcode(firstNonEmpty(barcodeEvidence.getBarcode(), barcode));
            }
            if (StringUtils.isEmpty(candidate.getName()))
            {
                candidate.setName(firstNonEmpty(barcodeEvidence.getGenericName(), barcodeEvidence.getName()));
            }
            if (StringUtils.isEmpty(candidate.getSpecification()))
            {
                candidate.setSpecification(barcodeEvidence.getSpecification());
            }
            if (StringUtils.isEmpty(candidate.getManufacturer()))
            {
                candidate.setManufacturer(barcodeEvidence.getManufacturer());
            }
            if (StringUtils.isEmpty(candidate.getCategory()))
            {
                candidate.setCategory(barcodeEvidence.getCategory());
            }
            if (StringUtils.isEmpty(candidate.getDosageForm()))
            {
                candidate.setDosageForm(barcodeEvidence.getDosageForm());
            }
            if (StringUtils.isEmpty(candidate.getForm()))
            {
                candidate.setForm(firstNonEmpty(candidate.getDosageForm(), barcodeEvidence.getDosageForm()));
            }
            if ((candidate.getEvidenceUrls() == null || candidate.getEvidenceUrls().isEmpty())
                && StringUtils.isNotEmpty(barcodeEvidence.getLookupUrl()))
            {
                List<String> evidenceUrls = new ArrayList<String>();
                evidenceUrls.add(barcodeEvidence.getLookupUrl());
                candidate.setEvidenceUrls(evidenceUrls);
            }
            if (candidate.getConfidence() == null && barcodeEvidence.hasUsefulData())
            {
                candidate.setConfidence(0.82D);
            }
        }
        return mergedCandidates;
    }

    protected List<MedicineRecognitionCandidate> buildFallbackCandidatesFromEvidence(BarcodeEvidence barcodeEvidence,
        String barcode)
    {
        List<MedicineRecognitionCandidate> candidates = new ArrayList<MedicineRecognitionCandidate>();
        if (barcodeEvidence == null)
        {
            return candidates;
        }
        MedicineRecognitionCandidate candidate = new MedicineRecognitionCandidate();
        candidate.setCandidateId("cand_1");
        candidate.setSource("barcode_lookup");
        candidate.setConfidence(0.76D);
        candidate.setBarcode(firstNonEmpty(barcodeEvidence.getBarcode(), barcode));
        candidate.setName(firstNonEmpty(barcodeEvidence.getGenericName(), barcodeEvidence.getName()));
        candidate.setSpecification(barcodeEvidence.getSpecification());
        candidate.setManufacturer(barcodeEvidence.getManufacturer());
        candidate.setCategory(barcodeEvidence.getCategory());
        candidate.setDosageForm(barcodeEvidence.getDosageForm());
        candidate.setForm(barcodeEvidence.getDosageForm());
        if (StringUtils.isNotEmpty(barcodeEvidence.getLookupUrl()))
        {
            List<String> evidenceUrls = new ArrayList<String>();
            evidenceUrls.add(barcodeEvidence.getLookupUrl());
            candidate.setEvidenceUrls(evidenceUrls);
        }
        if (StringUtils.isNotEmpty(candidate.getName()) || StringUtils.isNotEmpty(candidate.getBarcode()))
        {
            candidates.add(candidate);
        }
        return candidates;
    }

    protected String normalizeCandidateField(String fieldName, String value)
    {
        String normalized = trimToNull(value);
        if (normalized == null || isNullLikeText(normalized) || isVerificationText(normalized))
        {
            return null;
        }
        if ("barcode".equals(fieldName))
        {
            return normalized;
        }
        if ("dosageForm".equals(fieldName) || "form".equals(fieldName))
        {
            return normalizeDosageFormToChinese(normalized);
        }
        if ("category".equals(fieldName))
        {
            return normalizeCategoryToChinese(normalized);
        }
        if ("storage".equals(fieldName))
        {
            return normalizeStorageToChinese(normalized);
        }
        if ("specification".equals(fieldName))
        {
            return normalizeSpecificationText(normalized);
        }
        if ("pharmacology".equals(fieldName) || "indications".equals(fieldName)
            || "dosage".equals(fieldName) || "sideEffects".equals(fieldName))
        {
            return normalizeMedicalSentence(normalized);
        }
        return normalizeGenericText(normalized);
    }

    protected boolean isNullLikeText(String value)
    {
        String lower = value.toLowerCase(Locale.ROOT);
        return "null".equals(lower) || "n/a".equals(lower) || "na".equals(lower) || "none".equals(lower)
            || "unknown".equals(lower) || "not sure".equals(lower) || "unsure".equals(lower)
            || "not available".equals(lower) || "unavailable".equals(lower) || "not provided".equals(lower)
            || "not specified".equals(lower) || "unspecified".equals(lower);
    }

    protected String normalizeGenericText(String value)
    {
        String normalized = value.replace('\u3000', ' ');
        normalized = normalized.replaceAll("\\s+", " ").trim();
        if (isVerificationText(normalized))
        {
            return null;
        }
        return StringUtils.isEmpty(normalized) ? null : normalized;
    }

    protected boolean isVerificationPage(String html)
    {
        if (StringUtils.isEmpty(html))
        {
            return false;
        }
        String normalized = html.toLowerCase(Locale.ROOT);
        return (normalized.contains("<title>访问验证</title>") || normalized.contains("captcha")
            || normalized.contains("请完成验证后继续浏览")) && containsVerificationMarker(normalized);
    }

    protected boolean isVerificationText(String value)
    {
        if (StringUtils.isEmpty(value))
        {
            return false;
        }
        return containsVerificationMarker(value.toLowerCase(Locale.ROOT));
    }

    protected boolean containsVerificationMarker(String lowerCaseText)
    {
        for (String marker : VERIFICATION_TEXT_MARKERS)
        {
            if (lowerCaseText.contains(marker.toLowerCase(Locale.ROOT)))
            {
                return true;
            }
        }
        return false;
    }

    protected String normalizeSpecificationText(String value)
    {
        String normalized = normalizeGenericText(value);
        if (normalized == null)
        {
            return null;
        }
        normalized = replaceIgnoreCase(normalized, "tablets", "片");
        normalized = replaceIgnoreCase(normalized, "tablet", "片");
        normalized = replaceIgnoreCase(normalized, "tabs", "片");
        normalized = replaceIgnoreCase(normalized, "capsules", "粒");
        normalized = replaceIgnoreCase(normalized, "capsule", "粒");
        normalized = replaceIgnoreCase(normalized, "caps", "粒");
        normalized = replaceIgnoreCase(normalized, "softgels", "粒");
        normalized = replaceIgnoreCase(normalized, "softgel", "粒");
        normalized = replaceIgnoreCase(normalized, "sachets", "袋");
        normalized = replaceIgnoreCase(normalized, "sachet", "袋");
        normalized = replaceIgnoreCase(normalized, "bottles", "瓶");
        normalized = replaceIgnoreCase(normalized, "bottle", "瓶");
        normalized = replaceIgnoreCase(normalized, "boxes", "盒");
        normalized = replaceIgnoreCase(normalized, "box", "盒");
        normalized = replaceIgnoreCase(normalized, "bags", "袋");
        normalized = replaceIgnoreCase(normalized, "bag", "袋");
        normalized = replaceIgnoreCase(normalized, "packs", "包");
        normalized = replaceIgnoreCase(normalized, "pack", "包");
        normalized = replaceIgnoreCase(normalized, "vials", "支");
        normalized = replaceIgnoreCase(normalized, "vial", "支");
        normalized = replaceIgnoreCase(normalized, "ampoules", "支");
        normalized = replaceIgnoreCase(normalized, "ampoule", "支");
        return normalizeGenericText(normalized);
    }

    protected String normalizeDosageFormToChinese(String value)
    {
        String normalized = normalizeGenericText(value);
        if (normalized == null)
        {
            return null;
        }
        String lower = normalized.toLowerCase(Locale.ROOT);
        if (containsChinese(normalized))
        {
            return normalized;
        }
        if (containsAny(lower, "film-coated tablet", "film coated tablet"))
        {
            return "薄膜衣片";
        }
        if (containsAny(lower, "enteric-coated tablet", "enteric coated tablet"))
        {
            return "肠溶片";
        }
        if (containsAny(lower, "sustained-release tablet", "sustained release tablet", "extended-release tablet",
            "extended release tablet", "controlled-release tablet", "controlled release tablet"))
        {
            return "缓释片";
        }
        if (containsAny(lower, "dispersible tablet"))
        {
            return "分散片";
        }
        if (containsAny(lower, "chewable tablet"))
        {
            return "咀嚼片";
        }
        if (containsAny(lower, "tablet", "tabs", "tab"))
        {
            return "片剂";
        }
        if (containsAny(lower, "soft capsule", "soft capsules", "softgel", "softgels"))
        {
            return "软胶囊";
        }
        if (containsAny(lower, "hard capsule", "hard capsules"))
        {
            return "硬胶囊";
        }
        if (containsAny(lower, "capsule", "capsules", "caps"))
        {
            return "胶囊剂";
        }
        if (containsAny(lower, "granule", "granules", "sachet", "sachets"))
        {
            return "颗粒剂";
        }
        if (containsAny(lower, "powder", "powders"))
        {
            return "散剂";
        }
        if (containsAny(lower, "oral solution"))
        {
            return "口服溶液";
        }
        if (containsAny(lower, "oral liquid"))
        {
            return "口服液";
        }
        if (containsAny(lower, "syrup"))
        {
            return "糖浆剂";
        }
        if (containsAny(lower, "suspension"))
        {
            return "混悬剂";
        }
        if (containsAny(lower, "emulsion"))
        {
            return "乳剂";
        }
        if (containsAny(lower, "eye drop", "eye drops"))
        {
            return "滴眼液";
        }
        if (containsAny(lower, "ear drop", "ear drops"))
        {
            return "滴耳液";
        }
        if (containsAny(lower, "nasal spray"))
        {
            return "鼻喷雾剂";
        }
        if (containsAny(lower, "spray"))
        {
            return "喷雾剂";
        }
        if (containsAny(lower, "injection", "injectable"))
        {
            return "注射剂";
        }
        if (containsAny(lower, "cream"))
        {
            return "乳膏剂";
        }
        if (containsAny(lower, "ointment"))
        {
            return "软膏剂";
        }
        if (containsAny(lower, "gel"))
        {
            return "凝胶剂";
        }
        if (containsAny(lower, "liniment"))
        {
            return "搽剂";
        }
        if (containsAny(lower, "patch", "plaster"))
        {
            return "贴剂";
        }
        if (containsAny(lower, "suppository"))
        {
            return "栓剂";
        }
        if (containsAny(lower, "lozenge", "troche"))
        {
            return "含片";
        }
        if (containsAny(lower, "solution"))
        {
            return "溶液剂";
        }
        return normalized;
    }

    protected String normalizeCategoryToChinese(String value)
    {
        String normalized = normalizeGenericText(value);
        if (normalized == null)
        {
            return null;
        }
        String lower = normalized.toLowerCase(Locale.ROOT);
        if (containsChinese(normalized))
        {
            return normalized;
        }
        if (containsAny(lower, "prescription", "prescription only", "rx"))
        {
            return "处方药";
        }
        if (containsAny(lower, "otc", "over-the-counter", "over the counter", "nonprescription"))
        {
            return "非处方药";
        }
        if (containsAny(lower, "traditional chinese medicine"))
        {
            return "中成药";
        }
        if (containsAny(lower, "western medicine"))
        {
            return "西药";
        }
        if (containsAny(lower, "antibiotic"))
        {
            return "抗生素";
        }
        if (containsAny(lower, "biologic", "biological"))
        {
            return "生物制品";
        }
        return normalized;
    }

    protected String normalizeStorageToChinese(String value)
    {
        String normalized = normalizeGenericText(value);
        if (normalized == null)
        {
            return null;
        }
        if (containsChinese(normalized))
        {
            return normalized;
        }
        String lower = normalized.toLowerCase(Locale.ROOT);
        List<String> requirements = new ArrayList<String>();
        if (containsAny(lower, "refrigerate", "refrigerated", "2-8", "2 to 8", "2~8"))
        {
            addUnique(requirements, "冷藏保存（2-8℃）");
        }
        if (containsAny(lower, "do not freeze", "avoid freezing"))
        {
            addUnique(requirements, "避免冷冻");
        }
        if (containsAny(lower, "room temperature", "ambient temperature"))
        {
            addUnique(requirements, "常温保存");
        }
        if (containsAny(lower, "cool, dry place", "cool dry place", "cool and dry place", "dry place"))
        {
            addUnique(requirements, "阴凉干燥处保存");
        }
        else if (containsAny(lower, "cool place", "keep cool"))
        {
            addUnique(requirements, "阴凉处保存");
        }
        if (containsAny(lower, "protect from light", "away from light", "avoid light"))
        {
            addUnique(requirements, "避光保存");
        }
        if (containsAny(lower, "sealed", "airtight", "keep tightly closed", "tightly closed"))
        {
            addUnique(requirements, "密封保存");
        }
        if (containsAny(lower, "keep out of reach of children"))
        {
            addUnique(requirements, "置于儿童不能接触处");
        }
        if (!requirements.isEmpty())
        {
            return joinChineseClauses(requirements);
        }
        return normalizeMedicalSentence(normalized);
    }

    protected String normalizeMedicalSentence(String value)
    {
        String normalized = normalizeGenericText(value);
        if (normalized == null)
        {
            return null;
        }
        String translated = replaceCommonMedicalEnglish(normalized);
        translated = translated.replace(';', '；');
        if (containsChinese(translated))
        {
            translated = translated.replace(',', '，').replace(':', '：');
        }
        translated = translated.replaceAll("\\s+", " ").trim();
        return StringUtils.isEmpty(translated) ? null : translated;
    }

    protected String replaceCommonMedicalEnglish(String value)
    {
        String translated = value;
        for (Map.Entry<String, String> entry : COMMON_MEDICAL_TEXT_TRANSLATIONS.entrySet())
        {
            translated = replaceIgnoreCase(translated, entry.getKey(), entry.getValue());
        }
        return translated;
    }

    protected boolean containsChinese(String value)
    {
        for (int i = 0; i < value.length(); i++)
        {
            if (Character.UnicodeScript.of(value.charAt(i)) == Character.UnicodeScript.HAN)
            {
                return true;
            }
        }
        return false;
    }

    protected boolean containsAny(String value, String... keywords)
    {
        for (String keyword : keywords)
        {
            if (value.contains(keyword))
            {
                return true;
            }
        }
        return false;
    }

    protected void addUnique(List<String> items, String value)
    {
        if (!items.contains(value))
        {
            items.add(value);
        }
    }

    protected String joinChineseClauses(List<String> clauses)
    {
        StringBuilder builder = new StringBuilder();
        for (int i = 0; i < clauses.size(); i++)
        {
            if (i > 0)
            {
                builder.append('；');
            }
            builder.append(clauses.get(i));
        }
        return builder.toString();
    }

    protected String replaceIgnoreCase(String text, String search, String replacement)
    {
        return Pattern.compile(Pattern.quote(search), Pattern.CASE_INSENSITIVE).matcher(text).replaceAll(replacement);
    }

    private static Map<String, String> buildCommonMedicalTextTranslations()
    {
        Map<String, String> translations = new LinkedHashMap<String, String>();
        translations.put("nonsteroidal anti-inflammatory drug", "非甾体抗炎药");
        translations.put("non-steroidal anti-inflammatory drug", "非甾体抗炎药");
        translations.put("anti inflammatory", "抗炎");
        translations.put("anti-inflammatory", "抗炎");
        translations.put("antibacterial", "抗菌");
        translations.put("antibiotic", "抗生素");
        translations.put("antiviral", "抗病毒");
        translations.put("antifungal", "抗真菌");
        translations.put("antihistamine", "抗组胺");
        translations.put("analgesic", "镇痛");
        translations.put("antipyretic", "解热");
        translations.put("expectorant", "祛痰");
        translations.put("antitussive", "镇咳");
        translations.put("bronchodilator", "支气管扩张");
        translations.put("mucolytic", "化痰");
        translations.put("probiotic", "益生菌");
        translations.put("sedative", "镇静");
        translations.put("hypnotic", "催眠");
        translations.put("anxiolytic", "抗焦虑");
        translations.put("antidepressant", "抗抑郁");
        translations.put("antihypertensive", "降压");
        translations.put("antidiabetic", "降糖");
        translations.put("hypoglycemic", "降糖");
        translations.put("lipid-lowering", "调脂");
        translations.put("antiemetic", "止吐");
        translations.put("antidiarrheal", "止泻");
        translations.put("laxative", "缓泻");
        translations.put("antiulcer", "抗溃疡");
        translations.put("anti-allergic", "抗过敏");
        translations.put("anti allergic", "抗过敏");
        translations.put("topical", "外用");
        translations.put("apply externally", "外用");
        translations.put("oral administration", "口服");
        translations.put("take orally", "口服");
        translations.put("intravenous infusion", "静脉滴注");
        translations.put("intravenous injection", "静脉注射");
        translations.put("intramuscular injection", "肌内注射");
        translations.put("subcutaneous injection", "皮下注射");
        translations.put("once daily", "每日一次");
        translations.put("twice daily", "每日两次");
        translations.put("three times daily", "每日三次");
        translations.put("four times daily", "每日四次");
        translations.put("every 4 hours", "每4小时一次");
        translations.put("every 6 hours", "每6小时一次");
        translations.put("before meals", "饭前");
        translations.put("after meals", "饭后");
        translations.put("with food", "随餐");
        translations.put("as needed", "必要时");
        translations.put("side effects", "不良反应");
        translations.put("adverse reactions", "不良反应");
        translations.put("contraindications", "禁忌");
        translations.put("indications", "适应症");
        translations.put("dosage and administration", "用法用量");
        translations.put("dosage", "用法用量");
        return translations;
    }

    protected static class BarcodeEvidence
    {
        private String barcode;
        private String name;
        private String genericName;
        private String brand;
        private String specification;
        private String manufacturer;
        private String category;
        private String dosageForm;
        private String lookupUrl;
        private String rawSummary;

        public boolean hasUsefulData()
        {
            return StringUtils.isNotEmpty(name) || StringUtils.isNotEmpty(genericName)
                || StringUtils.isNotEmpty(specification) || StringUtils.isNotEmpty(manufacturer)
                || StringUtils.isNotEmpty(category);
        }

        public String getBarcode()
        {
            return barcode;
        }

        public void setBarcode(String barcode)
        {
            this.barcode = barcode;
        }

        public String getName()
        {
            return name;
        }

        public void setName(String name)
        {
            this.name = name;
        }

        public String getGenericName()
        {
            return genericName;
        }

        public void setGenericName(String genericName)
        {
            this.genericName = genericName;
        }

        public String getBrand()
        {
            return brand;
        }

        public void setBrand(String brand)
        {
            this.brand = brand;
        }

        public String getSpecification()
        {
            return specification;
        }

        public void setSpecification(String specification)
        {
            this.specification = specification;
        }

        public String getManufacturer()
        {
            return manufacturer;
        }

        public void setManufacturer(String manufacturer)
        {
            this.manufacturer = manufacturer;
        }

        public String getCategory()
        {
            return category;
        }

        public void setCategory(String category)
        {
            this.category = category;
        }

        public String getDosageForm()
        {
            return dosageForm;
        }

        public void setDosageForm(String dosageForm)
        {
            this.dosageForm = dosageForm;
        }

        public String getLookupUrl()
        {
            return lookupUrl;
        }

        public void setLookupUrl(String lookupUrl)
        {
            this.lookupUrl = lookupUrl;
        }

        public String getRawSummary()
        {
            return rawSummary;
        }

        public void setRawSummary(String rawSummary)
        {
            this.rawSummary = rawSummary;
        }
    }

    protected String resolveModelCode(ClinicAiModel model)
    {
        if (model == null || StringUtils.isEmpty(model.getModelCode()))
        {
            throw new IllegalStateException("AI 模型未配置");
        }
        return model.getModelCode().trim();
    }

    protected String normalizeEndpoint(ClinicAiProvider provider)
    {
        if (provider == null || StringUtils.isEmpty(provider.getApiBaseUrl()))
        {
            throw new IllegalStateException("AI 服务商 apiBaseUrl 未配置");
        }
        String endpoint = provider.getApiBaseUrl().trim();
        if (endpoint.endsWith("/"))
        {
            endpoint = endpoint.substring(0, endpoint.length() - 1);
        }
        return endpoint;
    }

    protected String previewContent(String content)
    {
        String normalized = StringUtils.trim(content);
        if (StringUtils.isEmpty(normalized))
        {
            return "(empty response)";
        }
        if (normalized.length() <= TEST_RESPONSE_PREVIEW_LENGTH)
        {
            return normalized;
        }
        return normalized.substring(0, TEST_RESPONSE_PREVIEW_LENGTH) + "...";
    }

    protected String readStream(InputStream inputStream) throws Exception
    {
        if (inputStream == null)
        {
            return "";
        }
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream, StandardCharsets.UTF_8));
            ByteArrayOutputStream output = new ByteArrayOutputStream())
        {
            String line;
            while ((line = reader.readLine()) != null)
            {
                output.write(line.getBytes(StandardCharsets.UTF_8));
            }
            return new String(output.toByteArray(), StandardCharsets.UTF_8);
        }
    }
}
