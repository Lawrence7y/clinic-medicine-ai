package com.ruoyi.project.clinic.ai.controller;

import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONArray;
import com.alibaba.fastjson2.JSONObject;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.security.ShiroUtils;
import com.ruoyi.framework.web.controller.BaseController;
import com.ruoyi.framework.web.domain.AjaxResult;
import com.ruoyi.project.clinic.ai.service.support.ClinicAiChatService;
import com.ruoyi.project.clinic.appointment.domain.ClinicAppointment;
import com.ruoyi.project.clinic.appointment.service.IClinicAppointmentService;
import com.ruoyi.project.clinic.common.ClinicSecuritySupport;
import com.ruoyi.project.clinic.medical.domain.ClinicMedicalRecord;
import com.ruoyi.project.clinic.medical.service.IClinicMedicalRecordService;
import com.ruoyi.project.clinic.medicine.domain.ClinicMedicine;
import com.ruoyi.project.clinic.medicine.service.IClinicMedicineService;
import com.ruoyi.project.clinic.medicine.service.IClinicStockRecordService;
import com.ruoyi.project.system.role.service.IRoleService;
import com.ruoyi.project.system.user.domain.User;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/clinic/ai/assistant")
public class ClinicAiAssistantApiController extends BaseController
{
    private static final String MSG_NEED_LOGIN = "请先登录";
    private static final String MSG_NO_PERMISSION = "无权限访问";
    private static final String MSG_INVALID_PARAM = "参数错误";

    @Autowired
    private IRoleService roleService;

    @Autowired
    private ClinicAiChatService clinicAiChatService;

    @Autowired
    private IClinicMedicalRecordService medicalRecordService;

    @Autowired
    private IClinicMedicineService medicineService;

    @Autowired
    private IClinicStockRecordService stockRecordService;

    @Autowired
    private IClinicAppointmentService appointmentService;

    @PostMapping("/medical-record")
    public AjaxResult medicalRecordAssistant(@RequestBody(required = false) Map<String, Object> params)
    {
        User user = currentUser();
        if (user == null)
        {
            return AjaxResult.error(MSG_NEED_LOGIN);
        }
        Set<String> roleKeys = getRoleKeys(user);
        if (!ClinicSecuritySupport.isAdmin(roleKeys) && !ClinicSecuritySupport.isDoctor(roleKeys))
        {
            return forbiddenAjax(MSG_NO_PERMISSION);
        }

        Long recordId = parseLong(params != null ? params.get("recordId") : null);
        String recordText = trimToEmpty(params != null ? params.get("recordText") : null);
        if (recordId == null && StringUtils.isEmpty(recordText))
        {
            return AjaxResult.error(MSG_INVALID_PARAM);
        }

        ClinicMedicalRecord record = null;
        if (recordId != null)
        {
            record = medicalRecordService.selectClinicMedicalRecordById(recordId);
            if (record == null)
            {
                return AjaxResult.error("病历不存在");
            }
        }

        String prompt = buildMedicalAssistantPrompt(record, recordText);
        String systemPrompt = "你是诊所病历助手。请严格输出 JSON，不要输出 Markdown。"
            + "输出结构：{\"summary\":\"\",\"followUpAdvice\":\"\",\"patientEducation\":\"\"}。";

        JSONObject aiResult = clinicAiChatService.runAssistant("clinic_ai_medical_assistant", systemPrompt, prompt);
        String reply = aiResult.getString("reply");
        JSONObject parsed = parseJsonObject(reply);

        Map<String, Object> data = new HashMap<String, Object>();
        data.put("summary", pickString(parsed, "summary", "暂无病历摘要"));
        data.put("followUpAdvice", pickString(parsed, "followUpAdvice", "暂无复诊建议"));
        data.put("patientEducation", pickString(parsed, "patientEducation", "暂无患者宣教建议"));
        data.put("model", aiResult.getString("model"));
        data.put("rawReply", reply);
        if (record != null)
        {
            data.put("recordId", record.getRecordId());
            data.put("patientName", record.getPatientName());
            data.put("doctorName", record.getDoctorName());
        }
        return success(data);
    }

    @PostMapping("/medicine")
    public AjaxResult medicineAssistant(@RequestBody(required = false) Map<String, Object> params)
    {
        User user = currentUser();
        if (user == null)
        {
            return AjaxResult.error(MSG_NEED_LOGIN);
        }
        Set<String> roleKeys = getRoleKeys(user);
        if (!ClinicSecuritySupport.isAdmin(roleKeys) && !ClinicSecuritySupport.isDoctor(roleKeys))
        {
            return forbiddenAjax(MSG_NO_PERMISSION);
        }

        Long medicineId = parseLong(params != null ? params.get("medicineId") : null);
        String medicineName = trimToEmpty(params != null ? params.get("medicineName") : null);
        if (medicineId == null && StringUtils.isEmpty(medicineName))
        {
            return AjaxResult.error(MSG_INVALID_PARAM);
        }

        ClinicMedicine medicine = medicineId != null ? medicineService.selectClinicMedicineById(medicineId) : null;
        if (medicine == null && StringUtils.isNotEmpty(medicineName))
        {
            ClinicMedicine query = new ClinicMedicine();
            query.setName(medicineName);
            List<ClinicMedicine> search = medicineService.selectClinicMedicineList(query);
            if (search != null && !search.isEmpty())
            {
                medicine = search.get(0);
            }
        }
        if (medicine == null)
        {
            return AjaxResult.error("药品不存在");
        }

        List<String> candidateNames = buildSimilarMedicineCandidates(medicine);
        String prompt = buildMedicineAssistantPrompt(medicine, candidateNames);
        String systemPrompt = "你是诊所药品助手。请严格输出 JSON，不要输出 Markdown。"
            + "输出结构：{\"similarMedicines\":[\"\"],\"precautions\":[\"\"],\"riskTips\":[\"\"]}。";

        JSONObject aiResult = clinicAiChatService.runAssistant("clinic_ai_medicine_assistant", systemPrompt, prompt);
        String reply = aiResult.getString("reply");
        JSONObject parsed = parseJsonObject(reply);

        Map<String, Object> data = new HashMap<String, Object>();
        data.put("medicineId", medicine.getMedicineId());
        data.put("medicineName", medicine.getName());
        data.put("similarMedicines", pickStringList(parsed, "similarMedicines", candidateNames));
        data.put("precautions", pickStringList(parsed, "precautions", defaultList("按医嘱用药", "关注禁忌人群", "出现不适及时复诊")));
        data.put("riskTips", pickStringList(parsed, "riskTips", defaultList("注意过敏史", "避免重复用药", "关注近效期批次")));
        data.put("model", aiResult.getString("model"));
        data.put("rawReply", reply);
        return success(data);
    }

    @PostMapping("/operations")
    public AjaxResult operationsAssistant(@RequestBody(required = false) Map<String, Object> params)
    {
        User user = currentUser();
        if (user == null)
        {
            return AjaxResult.error(MSG_NEED_LOGIN);
        }
        Set<String> roleKeys = getRoleKeys(user);
        if (!ClinicSecuritySupport.isAdmin(roleKeys) && !ClinicSecuritySupport.isDoctor(roleKeys))
        {
            return forbiddenAjax(MSG_NO_PERMISSION);
        }

        String question = trimToEmpty(params != null ? params.get("question") : null);
        if (StringUtils.isEmpty(question))
        {
            question = "请总结今天预约情况、近效期风险和库存异常，并给出处理建议。";
        }

        Map<String, Object> snapshot = buildOperationsSnapshot(user, roleKeys);
        String prompt = buildOperationsAssistantPrompt(question, snapshot);
        String systemPrompt = "你是诊所运营助手。请严格输出 JSON，不要输出 Markdown。"
            + "输出结构：{\"answer\":\"\",\"keyPoints\":[\"\"],\"todo\":[\"\"]}。";

        JSONObject aiResult = clinicAiChatService.runAssistant("clinic_ai_operations_assistant", systemPrompt, prompt);
        String reply = aiResult.getString("reply");
        JSONObject parsed = parseJsonObject(reply);

        Map<String, Object> data = new HashMap<String, Object>();
        data.put("question", question);
        data.put("answer", pickString(parsed, "answer", "已生成运营分析建议，请结合实际业务复核。"));
        data.put("keyPoints", pickStringList(parsed, "keyPoints", defaultList("优先处理临近就诊提醒", "重点跟进近效期批次", "复核库存异常记录")));
        data.put("todo", pickStringList(parsed, "todo", defaultList("确认今日待确认预约", "处理近效期药品", "检查库存异常原因")));
        data.put("snapshot", snapshot);
        data.put("model", aiResult.getString("model"));
        data.put("rawReply", reply);
        return success(data);
    }

    private String buildMedicalAssistantPrompt(ClinicMedicalRecord record, String extraText)
    {
        StringBuilder builder = new StringBuilder();
        builder.append("请基于以下病历内容生成结构化结果：\n");
        if (record != null)
        {
            builder.append("患者姓名：").append(trimToEmpty(record.getPatientName())).append("\n");
            builder.append("就诊时间：").append(record.getVisitTime()).append("\n");
            builder.append("主诉：").append(limitText(record.getChiefComplaint(), 240)).append("\n");
            builder.append("现病史：").append(limitText(record.getPresentIllness(), 360)).append("\n");
            builder.append("既往史：").append(limitText(record.getPastHistory(), 240)).append("\n");
            builder.append("过敏史：").append(limitText(record.getAllergyHistory(), 200)).append("\n");
            builder.append("体格检查：").append(limitText(record.getPhysicalExam(), 240)).append("\n");
            builder.append("诊断：").append(limitText(record.getDiagnosis(), 220)).append("\n");
            builder.append("治疗方案：").append(limitText(record.getTreatment(), 260)).append("\n");
            builder.append("处方：").append(limitText(record.getPrescription(), 500)).append("\n");
            builder.append("复诊建议：").append(limitText(record.getFollowUp(), 220)).append("\n");
        }
        if (StringUtils.isNotEmpty(extraText))
        {
            builder.append("补充说明：").append(limitText(extraText, 600)).append("\n");
        }
        builder.append("请使用中文，内容简洁清晰，可直接给医生与患者使用。");
        return builder.toString();
    }

    private String buildMedicineAssistantPrompt(ClinicMedicine medicine, List<String> candidateNames)
    {
        StringBuilder builder = new StringBuilder();
        builder.append("请基于以下药品信息生成结果：\n");
        builder.append("药品名称：").append(trimToEmpty(medicine.getName())).append("\n");
        builder.append("规格：").append(trimToEmpty(medicine.getSpecification())).append("\n");
        builder.append("剂型：").append(trimToEmpty(medicine.getDosageForm())).append("\n");
        builder.append("药理作用：").append(limitText(medicine.getPharmacology(), 220)).append("\n");
        builder.append("适应症：").append(limitText(medicine.getIndications(), 220)).append("\n");
        builder.append("用法用量：").append(limitText(medicine.getDosage(), 220)).append("\n");
        builder.append("不良反应：").append(limitText(medicine.getSideEffects(), 220)).append("\n");
        if (candidateNames != null && !candidateNames.isEmpty())
        {
            builder.append("候选相似药品：").append(JSON.toJSONString(candidateNames)).append("\n");
        }
        builder.append("要求：similarMedicines 3-5条，优先从候选列表中选；precautions 与 riskTips 各 3-5 条。");
        return builder.toString();
    }

    private String buildOperationsAssistantPrompt(String question, Map<String, Object> snapshot)
    {
        StringBuilder builder = new StringBuilder();
        builder.append("请回答运营问题：").append(question).append("\n");
        builder.append("以下是系统实时快照：\n");
        builder.append(JSON.toJSONString(snapshot));
        builder.append("\n请先给结论，再给可执行待办。");
        return builder.toString();
    }

    private Map<String, Object> buildOperationsSnapshot(User user, Set<String> roleKeys)
    {
        Map<String, Object> snapshot = new HashMap<String, Object>();
        String today = LocalDate.now().format(DateTimeFormatter.ISO_DATE);
        String tomorrow = LocalDate.now().plusDays(1).format(DateTimeFormatter.ISO_DATE);
        Long doctorId = ClinicSecuritySupport.isDoctor(roleKeys) && !ClinicSecuritySupport.isAdmin(roleKeys)
            ? user.getUserId()
            : null;

        int todayAppointments = appointmentService.countTodayAppointments(today, doctorId);
        int todayRecords = medicalRecordService.countTodayRecords(today, doctorId);
        int lowStockCount = medicineService.countLowStockMedicine();
        List<Map<String, Object>> nearExpiryList = stockRecordService.selectNearExpiryBatchWarnings(30, 6, null);
        List<ClinicAppointment> pendingList = appointmentService.selectPendingAppointmentsList(8, doctorId);
        List<ClinicAppointment> upcomingList = appointmentService.selectUpcomingAppointments(null, doctorId, today, tomorrow);

        snapshot.put("today", today);
        snapshot.put("todayAppointments", todayAppointments);
        snapshot.put("todayRecords", todayRecords);
        snapshot.put("lowStockCount", lowStockCount);
        snapshot.put("nearExpiryCount", nearExpiryList != null ? nearExpiryList.size() : 0);
        snapshot.put("pendingAppointmentCount", pendingList != null ? pendingList.size() : 0);
        snapshot.put("upcomingAppointmentCount", upcomingList != null ? upcomingList.size() : 0);
        snapshot.put("nearExpiryTop", trimMapList(nearExpiryList, 6));
        snapshot.put("pendingTop", trimAppointmentList(pendingList, 6));
        snapshot.put("upcomingTop", trimAppointmentList(upcomingList, 6));
        return snapshot;
    }

    private List<Map<String, Object>> trimMapList(List<Map<String, Object>> source, int limit)
    {
        List<Map<String, Object>> result = new ArrayList<Map<String, Object>>();
        if (source == null || source.isEmpty())
        {
            return result;
        }
        int size = Math.min(limit, source.size());
        for (int i = 0; i < size; i++)
        {
            Map<String, Object> item = source.get(i);
            Map<String, Object> row = new HashMap<String, Object>();
            row.put("medicineId", item.get("medicineId"));
            row.put("medicineName", item.get("medicineName"));
            row.put("batchNumber", item.get("batchNumber"));
            row.put("daysToExpiry", item.get("daysToExpiry"));
            row.put("remainingQuantity", item.get("remainingQuantity"));
            result.add(row);
        }
        return result;
    }

    private List<Map<String, Object>> trimAppointmentList(List<ClinicAppointment> source, int limit)
    {
        List<Map<String, Object>> result = new ArrayList<Map<String, Object>>();
        if (source == null || source.isEmpty())
        {
            return result;
        }
        int size = Math.min(limit, source.size());
        for (int i = 0; i < size; i++)
        {
            ClinicAppointment item = source.get(i);
            Map<String, Object> row = new HashMap<String, Object>();
            row.put("appointmentId", item.getAppointmentId());
            row.put("patientName", item.getPatientName());
            row.put("doctorName", item.getDoctorName());
            row.put("appointmentDate", item.getAppointmentDate());
            row.put("appointmentTime", item.getAppointmentTime());
            row.put("status", item.getStatus());
            result.add(row);
        }
        return result;
    }

    private List<String> buildSimilarMedicineCandidates(ClinicMedicine medicine)
    {
        Set<String> merged = new HashSet<String>();
        List<String> candidates = new ArrayList<String>();

        ClinicMedicine dosageQuery = new ClinicMedicine();
        dosageQuery.setDosageForm(medicine.getDosageForm());
        dosageQuery.setStatus("active");
        collectCandidateNames(candidates, merged, medicine, medicineService.selectClinicMedicineList(dosageQuery), 8);

        if (candidates.size() < 5 && StringUtils.isNotEmpty(medicine.getCategory()))
        {
            ClinicMedicine categoryQuery = new ClinicMedicine();
            categoryQuery.setCategory(medicine.getCategory());
            categoryQuery.setStatus("active");
            collectCandidateNames(candidates, merged, medicine, medicineService.selectClinicMedicineList(categoryQuery), 10);
        }

        if (candidates.size() < 5)
        {
            ClinicMedicine query = new ClinicMedicine();
            query.setStatus("active");
            collectCandidateNames(candidates, merged, medicine, medicineService.selectClinicMedicineList(query), 10);
        }

        if (candidates.size() > 8)
        {
            return new ArrayList<String>(candidates.subList(0, 8));
        }
        return candidates;
    }

    private void collectCandidateNames(List<String> output, Set<String> merged, ClinicMedicine current,
        List<ClinicMedicine> source, int maxAppend)
    {
        if (source == null || source.isEmpty() || maxAppend <= 0)
        {
            return;
        }
        int appended = 0;
        for (ClinicMedicine item : source)
        {
            if (item == null || StringUtils.isEmpty(item.getName()))
            {
                continue;
            }
            if (current != null
                && current.getMedicineId() != null
                && item.getMedicineId() != null
                && current.getMedicineId().equals(item.getMedicineId()))
            {
                continue;
            }
            String name = item.getName().trim();
            if (name.isEmpty() || merged.contains(name))
            {
                continue;
            }
            merged.add(name);
            output.add(name);
            appended++;
            if (appended >= maxAppend)
            {
                break;
            }
        }
    }

    private JSONObject parseJsonObject(String rawText)
    {
        if (StringUtils.isEmpty(rawText))
        {
            return new JSONObject();
        }
        String trimmed = rawText.trim();
        JSONObject parsed = tryParseJsonObject(trimmed, 0);
        if (parsed == null)
        {
            List<String> fenceContents = extractMarkdownFenceContents(trimmed);
            for (String candidate : fenceContents)
            {
                parsed = tryParseJsonObject(candidate, 0);
                if (parsed != null)
                {
                    break;
                }
            }
        }
        if (parsed == null)
        {
            List<String> objectCandidates = extractBalancedJsonObjects(trimmed, 8);
            for (String candidate : objectCandidates)
            {
                parsed = tryParseJsonObject(candidate, 0);
                if (parsed != null)
                {
                    break;
                }
            }
        }
        if (parsed == null)
        {
            parsed = new JSONObject();
        }

        // Fallback: infer structured fields from plain-text answers/markdown lists.
        JSONObject inferred = inferStructuredObject(trimmed);
        mergeMissingFields(parsed, inferred);
        return parsed;
    }

    private JSONObject tryParseJsonObject(String candidate, int depth)
    {
        if (StringUtils.isEmpty(candidate) || depth > 3)
        {
            return null;
        }
        String text = candidate.trim();
        if (StringUtils.isEmpty(text))
        {
            return null;
        }
        try
        {
            Object parsed = JSON.parse(text);
            if (parsed instanceof JSONObject)
            {
                return (JSONObject) parsed;
            }
            if (parsed instanceof String)
            {
                return tryParseJsonObject(((String) parsed).trim(), depth + 1);
            }
            if (parsed instanceof JSONArray)
            {
                JSONArray array = (JSONArray) parsed;
                if (!array.isEmpty() && array.get(0) instanceof JSONObject)
                {
                    return (JSONObject) array.get(0);
                }
            }
        }
        catch (Exception ignored)
        {
            // try next strategy
        }
        return null;
    }

    private List<String> extractMarkdownFenceContents(String text)
    {
        List<String> contents = new ArrayList<String>();
        if (StringUtils.isEmpty(text))
        {
            return contents;
        }
        int cursor = 0;
        while (cursor < text.length())
        {
            int start = text.indexOf("```", cursor);
            if (start < 0)
            {
                break;
            }
            int end = text.indexOf("```", start + 3);
            if (end < 0)
            {
                break;
            }
            String block = text.substring(start + 3, end).trim();
            if (StringUtils.isNotEmpty(block))
            {
                int lineBreak = block.indexOf('\n');
                if (lineBreak > 0)
                {
                    String firstLine = block.substring(0, lineBreak).trim().toLowerCase();
                    if ("json".equals(firstLine) || "javascript".equals(firstLine) || "js".equals(firstLine))
                    {
                        block = block.substring(lineBreak + 1).trim();
                    }
                }
                if (StringUtils.isNotEmpty(block))
                {
                    contents.add(block);
                }
            }
            cursor = end + 3;
        }
        return contents;
    }

    private List<String> extractBalancedJsonObjects(String text, int maxCount)
    {
        List<String> result = new ArrayList<String>();
        if (StringUtils.isEmpty(text) || maxCount <= 0)
        {
            return result;
        }
        boolean inString = false;
        boolean escape = false;
        int depth = 0;
        int start = -1;
        for (int i = 0; i < text.length(); i++)
        {
            char ch = text.charAt(i);
            if (inString)
            {
                if (escape)
                {
                    escape = false;
                }
                else if (ch == '\\')
                {
                    escape = true;
                }
                else if (ch == '"')
                {
                    inString = false;
                }
                continue;
            }

            if (ch == '"')
            {
                inString = true;
                continue;
            }
            if (ch == '{')
            {
                if (depth == 0)
                {
                    start = i;
                }
                depth++;
                continue;
            }
            if (ch == '}' && depth > 0)
            {
                depth--;
                if (depth == 0 && start >= 0)
                {
                    result.add(text.substring(start, i + 1));
                    if (result.size() >= maxCount)
                    {
                        break;
                    }
                    start = -1;
                }
            }
        }
        return result;
    }

    private JSONObject inferStructuredObject(String rawText)
    {
        JSONObject inferred = new JSONObject();
        if (StringUtils.isEmpty(rawText))
        {
            return inferred;
        }

        String normalized = rawText.replace("\r\n", "\n").replace('\r', '\n');
        String[] lines = normalized.split("\n");
        Map<String, List<String>> buckets = new HashMap<String, List<String>>();
        List<String> plainLines = new ArrayList<String>();
        List<String> bulletLines = new ArrayList<String>();
        String currentListKey = null;

        for (String rawLine : lines)
        {
            String line = cleanupTextLine(rawLine);
            if (StringUtils.isEmpty(line))
            {
                continue;
            }

            String key = detectStructuredKey(line);
            if (key != null)
            {
                String inlineValue = extractInlineValue(line);
                if (isListKey(key))
                {
                    currentListKey = key;
                    addListValue(buckets, key, inlineValue, 8);
                }
                else
                {
                    currentListKey = null;
                    if (StringUtils.isNotEmpty(inlineValue))
                    {
                        inferred.put(key, inlineValue);
                    }
                }
                continue;
            }

            if (currentListKey != null)
            {
                addListValue(buckets, currentListKey, line, 8);
            }
            else
            {
                plainLines.add(line);
            }
            if (isBulletLine(rawLine))
            {
                addUniqueValue(bulletLines, line, 8);
            }
        }

        putListIfPresent(inferred, "similarMedicines", buckets.get("similarMedicines"), 8);
        putListIfPresent(inferred, "precautions", buckets.get("precautions"), 8);
        putListIfPresent(inferred, "riskTips", buckets.get("riskTips"), 8);
        putListIfPresent(inferred, "keyPoints", buckets.get("keyPoints"), 8);
        putListIfPresent(inferred, "todo", buckets.get("todo"), 8);

        if (!hasTextValue(inferred, "summary") && !plainLines.isEmpty())
        {
            inferred.put("summary", plainLines.get(0));
        }
        if (!hasTextValue(inferred, "answer") && !plainLines.isEmpty())
        {
            inferred.put("answer", joinTopLines(plainLines, 2));
        }
        if (!hasTextValue(inferred, "followUpAdvice") && plainLines.size() > 1)
        {
            inferred.put("followUpAdvice", plainLines.get(1));
        }
        if (!hasTextValue(inferred, "patientEducation") && plainLines.size() > 2)
        {
            inferred.put("patientEducation", plainLines.get(2));
        }

        if (!hasListValue(inferred, "keyPoints") && !bulletLines.isEmpty())
        {
            putListIfPresent(inferred, "keyPoints", bulletLines, 6);
        }

        return inferred;
    }

    private void mergeMissingFields(JSONObject target, JSONObject source)
    {
        if (target == null || source == null || source.isEmpty())
        {
            return;
        }
        mergeTextField(target, source, "summary");
        mergeTextField(target, source, "followUpAdvice");
        mergeTextField(target, source, "patientEducation");
        mergeTextField(target, source, "answer");
        mergeListField(target, source, "similarMedicines");
        mergeListField(target, source, "precautions");
        mergeListField(target, source, "riskTips");
        mergeListField(target, source, "keyPoints");
        mergeListField(target, source, "todo");
    }

    private void mergeTextField(JSONObject target, JSONObject source, String key)
    {
        String existing = target.getString(key);
        if (StringUtils.isNotEmpty(existing))
        {
            return;
        }
        String inferred = source.getString(key);
        if (StringUtils.isNotEmpty(inferred))
        {
            target.put(key, inferred);
        }
    }

    private void mergeListField(JSONObject target, JSONObject source, String key)
    {
        if (hasListValue(target, key))
        {
            return;
        }
        Object value = source.get(key);
        if (value instanceof JSONArray && !((JSONArray) value).isEmpty())
        {
            target.put(key, value);
            return;
        }
        if (value instanceof String)
        {
            List<String> parsed = splitTextToList((String) value, 8);
            if (!parsed.isEmpty())
            {
                putListIfPresent(target, key, parsed, 8);
            }
        }
    }

    private String detectStructuredKey(String line)
    {
        String keyText = normalizeKeyText(line);
        if (StringUtils.isEmpty(keyText))
        {
            return null;
        }
        if (startsWithAny(keyText, "summary", "\u6458\u8981", "\u603b\u7ed3", "\u75c5\u5386\u6458\u8981", "\u75c5\u5386\u603b\u7ed3"))
        {
            return "summary";
        }
        if (startsWithAny(keyText, "followupadvice", "followup", "\u590d\u8bca\u5efa\u8bae", "\u968f\u8bbf\u5efa\u8bae", "\u590d\u67e5\u5efa\u8bae"))
        {
            return "followUpAdvice";
        }
        if (startsWithAny(keyText, "patienteducation", "\u60a3\u8005\u5ba3\u6559", "\u5065\u5eb7\u5ba3\u6559"))
        {
            return "patientEducation";
        }
        if (startsWithAny(keyText, "answer", "\u56de\u7b54", "\u7ed3\u8bba", "\u603b\u7ed3\u5efa\u8bae"))
        {
            return "answer";
        }
        if (startsWithAny(keyText, "similarmedicines", "similarmedicine", "\u76f8\u4f3c\u836f\u54c1", "\u66ff\u4ee3\u836f\u54c1", "\u540c\u7c7b\u836f\u54c1"))
        {
            return "similarMedicines";
        }
        if (startsWithAny(keyText, "precautions", "\u6ce8\u610f\u4e8b\u9879", "\u7528\u836f\u6ce8\u610f", "\u7981\u5fcc"))
        {
            return "precautions";
        }
        if (startsWithAny(keyText, "risktips", "risktips", "risk", "\u98ce\u9669\u63d0\u793a", "\u98ce\u9669\u8b66\u793a"))
        {
            return "riskTips";
        }
        if (startsWithAny(keyText, "keypoints", "keypoint", "\u8981\u70b9", "\u5173\u952e\u70b9", "\u91cd\u70b9"))
        {
            return "keyPoints";
        }
        if (startsWithAny(keyText, "todo", "\u5f85\u529e", "\u884c\u52a8\u5efa\u8bae", "\u6267\u884c\u6b65\u9aa4"))
        {
            return "todo";
        }
        return null;
    }

    private String normalizeKeyText(String text)
    {
        if (StringUtils.isEmpty(text))
        {
            return "";
        }
        String normalized = text.trim().toLowerCase();
        normalized = normalized.replaceAll("[\\s#>*`\\-_:：\\(\\)\\[\\]【】]+", "");
        return normalized;
    }

    private boolean startsWithAny(String text, String... prefixes)
    {
        if (StringUtils.isEmpty(text) || prefixes == null)
        {
            return false;
        }
        for (String prefix : prefixes)
        {
            if (StringUtils.isNotEmpty(prefix) && text.startsWith(prefix))
            {
                return true;
            }
        }
        return false;
    }

    private boolean isListKey(String key)
    {
        return "similarMedicines".equals(key)
            || "precautions".equals(key)
            || "riskTips".equals(key)
            || "keyPoints".equals(key)
            || "todo".equals(key);
    }

    private String cleanupTextLine(String line)
    {
        if (StringUtils.isEmpty(line))
        {
            return "";
        }
        String cleaned = line.trim();
        if (cleaned.startsWith("```"))
        {
            return "";
        }
        cleaned = cleaned.replaceAll("^\\s*[>#`]+\\s*", "");
        cleaned = cleaned.replaceAll("^\\s*([-*\\u2022]|\\d+[\\.\\)\\u3001])\\s+", "");
        return cleaned.trim();
    }

    private boolean isBulletLine(String line)
    {
        if (StringUtils.isEmpty(line))
        {
            return false;
        }
        return line.trim().matches("^([-*\\u2022]|\\d+[\\.\\)\\u3001])\\s+.+");
    }

    private String extractInlineValue(String line)
    {
        if (StringUtils.isEmpty(line))
        {
            return "";
        }
        int index = line.indexOf('：');
        if (index < 0)
        {
            index = line.indexOf(':');
        }
        if (index < 0 || index >= line.length() - 1)
        {
            return "";
        }
        return cleanupTextLine(line.substring(index + 1));
    }

    private void addListValue(Map<String, List<String>> buckets, String key, String value, int maxItems)
    {
        if (StringUtils.isEmpty(key) || StringUtils.isEmpty(value))
        {
            return;
        }
        List<String> list = buckets.get(key);
        if (list == null)
        {
            list = new ArrayList<String>();
            buckets.put(key, list);
        }
        List<String> pieces = splitTextToList(value, maxItems);
        if (pieces.isEmpty())
        {
            pieces.add(cleanupTextLine(value));
        }
        for (String item : pieces)
        {
            addUniqueValue(list, item, maxItems);
        }
    }

    private void addUniqueValue(List<String> list, String value, int maxItems)
    {
        if (list == null || maxItems <= 0)
        {
            return;
        }
        String cleaned = cleanupTextLine(value);
        if (StringUtils.isEmpty(cleaned) || list.contains(cleaned))
        {
            return;
        }
        if (list.size() < maxItems)
        {
            list.add(cleaned);
        }
    }

    private void putListIfPresent(JSONObject obj, String key, List<String> source, int maxItems)
    {
        if (obj == null || StringUtils.isEmpty(key) || source == null || source.isEmpty() || maxItems <= 0)
        {
            return;
        }
        JSONArray array = new JSONArray();
        int size = Math.min(source.size(), maxItems);
        for (int i = 0; i < size; i++)
        {
            String item = cleanupTextLine(source.get(i));
            if (StringUtils.isNotEmpty(item))
            {
                array.add(item);
            }
        }
        if (!array.isEmpty())
        {
            obj.put(key, array);
        }
    }

    private boolean hasTextValue(JSONObject obj, String key)
    {
        if (obj == null || StringUtils.isEmpty(key))
        {
            return false;
        }
        return StringUtils.isNotEmpty(obj.getString(key));
    }

    private boolean hasListValue(JSONObject obj, String key)
    {
        if (obj == null || StringUtils.isEmpty(key))
        {
            return false;
        }
        Object value = obj.get(key);
        if (value instanceof JSONArray)
        {
            return !((JSONArray) value).isEmpty();
        }
        if (value instanceof String)
        {
            return !splitTextToList((String) value, 8).isEmpty();
        }
        return false;
    }

    private String joinTopLines(List<String> lines, int count)
    {
        if (lines == null || lines.isEmpty() || count <= 0)
        {
            return "";
        }
        StringBuilder builder = new StringBuilder();
        int size = Math.min(lines.size(), count);
        for (int i = 0; i < size; i++)
        {
            String line = trimToEmpty(lines.get(i));
            if (StringUtils.isEmpty(line))
            {
                continue;
            }
            if (builder.length() > 0)
            {
                builder.append(" ");
            }
            builder.append(line);
        }
        return builder.toString();
    }

    private List<String> splitTextToList(String text, int maxItems)
    {
        List<String> list = new ArrayList<String>();
        if (StringUtils.isEmpty(text) || maxItems <= 0)
        {
            return list;
        }
        String normalized = text.replace("\r\n", "\n").replace('\r', '\n');
        String[] lines = normalized.split("\n");
        for (String line : lines)
        {
            String cleaned = cleanupTextLine(line);
            if (StringUtils.isEmpty(cleaned))
            {
                continue;
            }
            String[] pieces = cleaned.split("[；;]");
            for (String piece : pieces)
            {
                addUniqueValue(list, piece, maxItems);
                if (list.size() >= maxItems)
                {
                    return list;
                }
            }
        }
        return list;
    }

    private String pickString(JSONObject obj, String key, String fallback)
    {
        if (obj == null)
        {
            return fallback;
        }
        String value = obj.getString(key);
        if (StringUtils.isEmpty(value))
        {
            return fallback;
        }
        return value;
    }

    private List<String> pickStringList(JSONObject obj, String key, List<String> fallback)
    {
        if (obj == null)
        {
            return fallback;
        }
        JSONArray array = obj.getJSONArray(key);
        List<String> list = new ArrayList<String>();
        if (array != null && !array.isEmpty())
        {
            for (int i = 0; i < array.size(); i++)
            {
                String item = trimToEmpty(array.get(i));
                if (StringUtils.isNotEmpty(item))
                {
                    list.add(item);
                }
            }
        }
        if (!list.isEmpty())
        {
            return list;
        }
        Object raw = obj.get(key);
        if (raw instanceof String)
        {
            list = splitTextToList((String) raw, 8);
        }
        else if (raw != null)
        {
            list = splitTextToList(trimToEmpty(raw), 8);
        }
        if (!list.isEmpty())
        {
            List<String> trimmed = new ArrayList<String>();
            for (String item : list)
            {
                String clean = trimToEmpty(item);
                if (StringUtils.isNotEmpty(clean))
                {
                    trimmed.add(clean);
                }
            }
            if (!trimmed.isEmpty())
            {
                return trimmed;
            }
        }
        return fallback;
    }

    private List<String> defaultList(String... items)
    {
        List<String> list = new ArrayList<String>();
        if (items == null)
        {
            return list;
        }
        for (String item : items)
        {
            if (StringUtils.isNotEmpty(item))
            {
                list.add(item);
            }
        }
        return list;
    }

    private String limitText(String value, int maxLength)
    {
        String safe = trimToEmpty(value);
        if (safe.length() <= maxLength)
        {
            return safe;
        }
        return safe.substring(0, maxLength) + "...";
    }

    private String trimToEmpty(Object value)
    {
        return value == null ? "" : String.valueOf(value).trim();
    }

    private Long parseLong(Object value)
    {
        if (value == null)
        {
            return null;
        }
        try
        {
            return Long.valueOf(String.valueOf(value).trim());
        }
        catch (Exception ex)
        {
            return null;
        }
    }

    private User currentUser()
    {
        return ShiroUtils.getSysUser();
    }

    private Set<String> getRoleKeys(User user)
    {
        return ClinicSecuritySupport.getRoleKeys(user, roleService);
    }

    private AjaxResult forbiddenAjax(String message)
    {
        AjaxResult result = AjaxResult.error(message);
        result.put(AjaxResult.CODE_TAG, 403);
        return result;
    }
}
