package com.ruoyi.project.clinic.medicine.controller;

import com.github.pagehelper.PageHelper;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.security.ShiroUtils;
import com.ruoyi.framework.web.controller.BaseController;
import com.ruoyi.framework.web.domain.AjaxResult;
import com.ruoyi.framework.web.page.TableDataInfo;
import com.ruoyi.project.clinic.common.ClinicSecuritySupport;
import com.ruoyi.project.clinic.medicine.domain.ClinicStockBatch;
import com.ruoyi.project.clinic.medicine.domain.ClinicStockRecord;
import com.ruoyi.project.clinic.medicine.mapper.ClinicStockBatchMapper;
import com.ruoyi.project.clinic.medicine.service.IClinicStockRecordService;
import com.ruoyi.project.clinic.patient.service.IClinicPatientService;
import com.ruoyi.project.system.role.service.IRoleService;
import com.ruoyi.project.system.user.domain.User;
import java.sql.Date;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
@RequestMapping("/api/clinic/stock")
public class ClinicStockRecordApiController extends BaseController
{
    private static final String MSG_STOCK_IN_ADMIN_ONLY = "仅管理员可执行药品入库";

    @Autowired
    private IClinicStockRecordService clinicStockRecordService;

    @Autowired
    private IRoleService roleService;

    @Autowired
    private ClinicStockBatchMapper clinicStockBatchMapper;

    @Autowired
    private IClinicPatientService clinicPatientService;

    @PostMapping(value = "/list", consumes = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public TableDataInfo list(@Validated @RequestBody(required = false) ClinicStockRecord clinicStockRecord)
    {
        return listInternal(clinicStockRecord);
    }

    @PostMapping(value = "/list", consumes = MediaType.APPLICATION_FORM_URLENCODED_VALUE)
    @ResponseBody
    public TableDataInfo listForm(@Validated ClinicStockRecord clinicStockRecord)
    {
        return listInternal(clinicStockRecord);
    }

    @PostMapping("/listForm")
    @ResponseBody
    public TableDataInfo listFormDirect(@Validated ClinicStockRecord clinicStockRecord)
    {
        return listInternal(clinicStockRecord);
    }

    private TableDataInfo listInternal(ClinicStockRecord clinicStockRecord)
    {
        User currentUser = currentUser();
        if (currentUser == null)
        {
            return deniedTable(401, "请先登录");
        }

        Set<String> roleKeys = getRoleKeys(currentUser);
        boolean isAdmin = ClinicSecuritySupport.isAdmin(roleKeys);
        boolean isDoctor = ClinicSecuritySupport.isDoctor(roleKeys);
        if (!isAdmin && !isDoctor)
        {
            return deniedTable(403, "无权限访问");
        }

        if (clinicStockRecord == null)
        {
            clinicStockRecord = new ClinicStockRecord();
        }
        if (isDoctor && !isAdmin)
        {
            clinicStockRecord.setOperatorId(currentUser.getUserId());
        }

        int pageNum = clinicStockRecord.getPageNum() != null ? clinicStockRecord.getPageNum() : 1;
        int pageSize = clinicStockRecord.getPageSize() != null ? clinicStockRecord.getPageSize() : 10;
        if (pageSize > 200)
        {
            pageSize = 200;
        }

        try
        {
            PageHelper.startPage(pageNum, pageSize);
            List<ClinicStockRecord> list = clinicStockRecordService.selectClinicStockRecordList(clinicStockRecord);
            return getDataTable(list);
        }
        catch (RuntimeException ex)
        {
            return errorTable(ex.getMessage());
        }
    }

    @GetMapping("/getInfo")
    @ResponseBody
    public AjaxResult getInfo(@RequestParam Long recordId)
    {
        User currentUser = currentUser();
        if (currentUser == null)
        {
            return AjaxResult.error("请先登录");
        }

        Set<String> roleKeys = getRoleKeys(currentUser);
        boolean isAdmin = ClinicSecuritySupport.isAdmin(roleKeys);
        boolean isDoctor = ClinicSecuritySupport.isDoctor(roleKeys);
        if (!isAdmin && !isDoctor)
        {
            return forbiddenAjax("无权限访问");
        }

        ClinicStockRecord record = clinicStockRecordService.selectClinicStockRecordById(recordId);
        if (record == null)
        {
            return AjaxResult.error("库存记录不存在");
        }
        if (isDoctor && !isAdmin && !ownsRecord(currentUser, record))
        {
            return forbiddenAjax("无权限访问");
        }
        return AjaxResult.success(record);
    }

    @PostMapping(value = "/add", consumes = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public AjaxResult addSave(@Validated @RequestBody ClinicStockRecord clinicStockRecord)
    {
        return addInternal(clinicStockRecord);
    }

    @PostMapping(value = "/add", consumes = MediaType.APPLICATION_FORM_URLENCODED_VALUE)
    @ResponseBody
    public AjaxResult addSaveForm(@Validated ClinicStockRecord clinicStockRecord)
    {
        return addInternal(clinicStockRecord);
    }

    @PostMapping("/addForm")
    @ResponseBody
    public AjaxResult addSaveFormDirect(@Validated ClinicStockRecord clinicStockRecord)
    {
        return addInternal(clinicStockRecord);
    }

    private AjaxResult addInternal(ClinicStockRecord clinicStockRecord)
    {
        User currentUser = currentUser();
        if (currentUser == null)
        {
            return AjaxResult.error("请先登录");
        }

        Set<String> roleKeys = getRoleKeys(currentUser);
        boolean isAdmin = ClinicSecuritySupport.isAdmin(roleKeys);
        boolean isDoctor = ClinicSecuritySupport.isDoctor(roleKeys);
        if (!isAdmin && !isDoctor)
        {
            return forbiddenAjax("无权限访问");
        }

        if (!isAdmin && isStockInOperation(clinicStockRecord))
        {
            return forbiddenAjax(MSG_STOCK_IN_ADMIN_ONLY);
        }

        clinicStockRecord.setOperatorId(currentUser.getUserId());
        clinicStockRecord.setOperatorName(currentUser.getUserName());
        try
        {
            int rows = clinicStockRecordService.insertClinicStockRecord(clinicStockRecord);
            if (rows <= 0)
            {
                return AjaxResult.error("创建库存记录失败");
            }

            Map<String, Object> data = new HashMap<>();
            data.put("recordId", clinicStockRecord.getRecordId());
            return AjaxResult.success(data);
        }
        catch (RuntimeException ex)
        {
            return AjaxResult.error(ex.getMessage());
        }
    }

    @PostMapping(value = "/edit", consumes = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public AjaxResult editSave(@Validated @RequestBody ClinicStockRecord clinicStockRecord)
    {
        return editInternal(clinicStockRecord);
    }

    @PostMapping(value = "/edit", consumes = MediaType.APPLICATION_FORM_URLENCODED_VALUE)
    @ResponseBody
    public AjaxResult editSaveForm(@Validated ClinicStockRecord clinicStockRecord)
    {
        return editInternal(clinicStockRecord);
    }

    private AjaxResult editInternal(ClinicStockRecord clinicStockRecord)
    {
        User currentUser = currentUser();
        if (currentUser == null)
        {
            return AjaxResult.error("请先登录");
        }

        Set<String> roleKeys = getRoleKeys(currentUser);
        boolean isAdmin = ClinicSecuritySupport.isAdmin(roleKeys);
        boolean isDoctor = ClinicSecuritySupport.isDoctor(roleKeys);
        if (!isAdmin && !isDoctor)
        {
            return forbiddenAjax("无权限访问");
        }
        if (clinicStockRecord.getRecordId() == null)
        {
            return AjaxResult.error("参数错误");
        }

        ClinicStockRecord old = clinicStockRecordService.selectClinicStockRecordById(clinicStockRecord.getRecordId());
        if (old == null)
        {
            return AjaxResult.error("库存记录不存在");
        }
        if (isDoctor && !isAdmin && !ownsRecord(currentUser, old))
        {
            return forbiddenAjax("无权限访问");
        }
        if (isDoctor && !isAdmin)
        {
            clinicStockRecord.setOperatorId(currentUser.getUserId());
            clinicStockRecord.setOperatorName(currentUser.getUserName());
        }
        try
        {
            return toAjax(clinicStockRecordService.updateClinicStockRecord(clinicStockRecord));
        }
        catch (RuntimeException ex)
        {
            return AjaxResult.error(ex.getMessage());
        }
    }

    @PostMapping(value = "/remove", consumes = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public AjaxResult remove(@RequestBody(required = false) Map<String, String> params)
    {
        return removeInternal(params != null ? params.get("ids") : null);
    }

    @PostMapping(value = "/remove", consumes = MediaType.APPLICATION_FORM_URLENCODED_VALUE)
    @ResponseBody
    public AjaxResult removeForm(String ids)
    {
        return removeInternal(ids);
    }

    private AjaxResult removeInternal(String ids)
    {
        User currentUser = currentUser();
        if (currentUser == null)
        {
            return AjaxResult.error("请先登录");
        }

        Set<String> roleKeys = getRoleKeys(currentUser);
        boolean isAdmin = ClinicSecuritySupport.isAdmin(roleKeys);
        boolean isDoctor = ClinicSecuritySupport.isDoctor(roleKeys);
        if (!isAdmin && !isDoctor)
        {
            return forbiddenAjax("无权限访问");
        }
        if (StringUtils.isEmpty(ids))
        {
            return AjaxResult.error("请提供要删除的库存记录ID");
        }

        Long[] recordIds = Arrays.stream(ids.split(","))
            .map(String::trim)
            .filter(StringUtils::isNotEmpty)
            .map(Long::valueOf)
            .toArray(Long[]::new);

        if (isDoctor && !isAdmin)
        {
            for (Long recordId : recordIds)
            {
                ClinicStockRecord record = clinicStockRecordService.selectClinicStockRecordById(recordId);
                if (record != null && !ownsRecord(currentUser, record))
                {
                    return forbiddenAjax("无权限访问");
                }
            }
        }
        return toAjax(clinicStockRecordService.deleteClinicStockRecordByIds(recordIds));
    }

    @PostMapping("/syncOperatorName")
    @ResponseBody
    public AjaxResult syncOperatorName(@RequestBody Map<String, Object> params)
    {
        Long operatorId = parseLong(params.get("operatorId"));
        String operatorName = stringValue(params.get("operatorName"));

        User currentUser = currentUser();
        if (currentUser == null)
        {
            return AjaxResult.error("请先登录");
        }

        Set<String> roleKeys = getRoleKeys(currentUser);
        boolean isAdmin = ClinicSecuritySupport.isAdmin(roleKeys);
        boolean isSelf = operatorId != null && operatorId.equals(currentUser.getUserId());
        if (!isAdmin && !isSelf)
        {
            return forbiddenAjax("无权限访问");
        }

        int updated = clinicStockRecordService.syncOperatorName(operatorId, operatorName);
        return AjaxResult.success("更新成功", updated);
    }

    @PostMapping("/syncPatientName")
    @ResponseBody
    public AjaxResult syncPatientName(@RequestBody Map<String, Object> params)
    {
        Long patientId = parseLong(params.get("patientId"));
        String newName = stringValue(params.get("newName"));

        User currentUser = currentUser();
        if (currentUser == null)
        {
            return AjaxResult.error("请先登录");
        }

        Set<String> roleKeys = getRoleKeys(currentUser);
        Long currentPatientId = resolveCurrentPatientId(currentUser, roleKeys);
        boolean isSelfPatient = ClinicSecuritySupport.isPatient(roleKeys)
            && currentPatientId != null
            && currentPatientId.equals(patientId);
        if (!ClinicSecuritySupport.isAdmin(roleKeys) && !isSelfPatient)
        {
            return forbiddenAjax("无权限访问");
        }

        int updated = clinicStockRecordService.syncPatientName(patientId, newName);
        return AjaxResult.success("更新成功", updated);
    }

    @PostMapping("/syncDoctorName")
    @ResponseBody
    public AjaxResult syncDoctorName(@RequestBody Map<String, Object> params)
    {
        Long doctorId = parseLong(params.get("doctorId"));
        String newName = stringValue(params.get("newName"));

        User currentUser = currentUser();
        if (currentUser == null)
        {
            return AjaxResult.error("请先登录");
        }

        Set<String> roleKeys = getRoleKeys(currentUser);
        boolean isSelfDoctor = ClinicSecuritySupport.isDoctor(roleKeys)
            && doctorId != null
            && doctorId.equals(currentUser.getUserId());
        if (!ClinicSecuritySupport.isAdmin(roleKeys) && !isSelfDoctor)
        {
            return forbiddenAjax("无权限访问");
        }

        int updated = clinicStockRecordService.syncDoctorName(doctorId, newName);
        return AjaxResult.success("更新成功", updated);
    }

    @GetMapping("/myDispensedMedicines")
    @ResponseBody
    public TableDataInfo myDispensedMedicines()
    {
        User currentUser = currentUser();
        if (currentUser == null)
        {
            return deniedTable(401, "请先登录");
        }

        Set<String> roleKeys = getRoleKeys(currentUser);
        if (!ClinicSecuritySupport.isAdmin(roleKeys)
            && !ClinicSecuritySupport.isDoctor(roleKeys)
            && !ClinicSecuritySupport.isPatient(roleKeys))
        {
            return deniedTable(403, "无权限访问");
        }

        Long patientId = resolveCurrentPatientId(currentUser, roleKeys);
        List<ClinicStockRecord> records = patientId != null
            ? clinicStockRecordService.selectStockOutRecordsByPatientId(patientId)
            : Collections.emptyList();

        List<Map<String, Object>> result = new ArrayList<>();
        for (ClinicStockRecord record : records)
        {
            Map<String, Object> row = new HashMap<>();
            row.put("recordId", record.getRecordId());
            row.put("medicineId", record.getMedicineId());
            row.put("medicineName", record.getMedicineName());
            row.put("batchNumber", record.getBatchNumber());
            row.put("expiryDate", record.getExpiryDate());
            row.put("quantity", record.getQuantity());
            row.put("beforeStock", record.getBeforeStock());
            row.put("afterStock", record.getAfterStock());
            row.put("patientId", record.getPatientId());
            row.put("doctorId", record.getDoctorId());
            row.put("doctorName", record.getDoctorName());
            row.put("operatorName", record.getOperatorName());
            row.put("remark", record.getRemark());
            row.put("createTime", record.getCreateTime());
            result.add(row);
        }

        TableDataInfo table = new TableDataInfo();
        table.setCode(0);
        table.setMsg("成功");
        table.setRows(result);
        table.setTotal(result.size());
        return table;
    }

    @GetMapping("/myDispensedMedicinesGrouped")
    @ResponseBody
    public AjaxResult myDispensedMedicinesGrouped()
    {
        User currentUser = currentUser();
        if (currentUser == null)
        {
            return AjaxResult.error("请先登录");
        }

        Set<String> roleKeys = getRoleKeys(currentUser);
        if (!ClinicSecuritySupport.isPatient(roleKeys))
        {
            return forbiddenAjax("无权限访问");
        }

        Long patientId = resolveCurrentPatientId(currentUser, roleKeys);
        if (patientId == null)
        {
            return AjaxResult.success(new ArrayList<>());
        }

        List<ClinicStockRecord> records = clinicStockRecordService.selectStockOutRecordsByPatientId(patientId);
        Map<Long, Map<String, Object>> medicineMap = new HashMap<>();
        for (ClinicStockRecord record : records)
        {
            Long medicineId = record.getMedicineId();
            if (medicineId == null)
            {
                continue;
            }

            Map<String, Object> group = medicineMap.get(medicineId);
            if (group == null)
            {
                group = new HashMap<>();
                group.put("medicineId", medicineId);
                group.put("medicineName", record.getMedicineName());
                group.put("expiryDate", record.getExpiryDate());
                group.put("totalQuantity", record.getQuantity() != null ? record.getQuantity() : 0);
                group.put("latestRecordTime", record.getCreateTime());
                group.put("doctorName", record.getDoctorName());
                group.put("records", new ArrayList<Map<String, Object>>());
                medicineMap.put(medicineId, group);
            }
            else
            {
                Integer totalQuantity = (Integer) group.get("totalQuantity");
                group.put("totalQuantity", (totalQuantity != null ? totalQuantity : 0)
                    + (record.getQuantity() != null ? record.getQuantity() : 0));

                java.util.Date latestRecordTime = (java.util.Date) group.get("latestRecordTime");
                if (latestRecordTime == null
                    || (record.getCreateTime() != null && record.getCreateTime().after(latestRecordTime)))
                {
                    group.put("latestRecordTime", record.getCreateTime());
                    group.put("expiryDate", record.getExpiryDate());
                    group.put("doctorName", record.getDoctorName());
                }
            }

            @SuppressWarnings("unchecked")
            List<Map<String, Object>> recordList = (List<Map<String, Object>>) group.get("records");
            Map<String, Object> recordMap = new HashMap<>();
            recordMap.put("recordId", record.getRecordId());
            recordMap.put("quantity", record.getQuantity());
            recordMap.put("createTime", record.getCreateTime());
            recordMap.put("remark", record.getRemark());
            recordList.add(recordMap);
        }

        return AjaxResult.success(new ArrayList<>(medicineMap.values()));
    }

    @GetMapping("/patientDispensedExpirySummary")
    @ResponseBody
    public AjaxResult patientDispensedExpirySummary(@RequestParam(required = false) Long patientId,
        @RequestParam(required = false) String patientName,
        @RequestParam(required = false) String medicineIds)
    {
        User currentUser = currentUser();
        if (currentUser == null)
        {
            return AjaxResult.error("请先登录");
        }

        Set<String> roleKeys = getRoleKeys(currentUser);
        if (!ClinicSecuritySupport.isAdmin(roleKeys)
            && !ClinicSecuritySupport.isDoctor(roleKeys)
            && !ClinicSecuritySupport.isPatient(roleKeys))
        {
            return forbiddenAjax("无权限访问");
        }

        Long targetPatientId = patientId;
        String targetPatientName = StringUtils.isNotEmpty(patientName) ? patientName.trim() : null;
        if (ClinicSecuritySupport.isPatient(roleKeys))
        {
            targetPatientId = resolveCurrentPatientId(currentUser, roleKeys);
            targetPatientName = null;
        }
        if (targetPatientId == null && StringUtils.isEmpty(targetPatientName))
        {
            return AjaxResult.success(new ArrayList<>());
        }

        Set<Long> medicineIdSet = parseIdSet(medicineIds);
        ClinicStockRecord query = new ClinicStockRecord();
        query.setOperationType("out");
        if (targetPatientId != null)
        {
            query.setPatientId(targetPatientId);
        }
        else
        {
            query.setPatientName(targetPatientName);
        }

        List<ClinicStockRecord> records = clinicStockRecordService.selectClinicStockRecordList(query);
        Map<Long, java.util.Date> latestExpiryByMedicine = new HashMap<>();
        Map<Long, java.util.Date> latestRecordTimeByMedicine = new HashMap<>();
        for (ClinicStockRecord record : records)
        {
            if (record == null || record.getMedicineId() == null || record.getExpiryDate() == null)
            {
                continue;
            }
            if (targetPatientId != null)
            {
                if (!targetPatientId.equals(record.getPatientId()))
                {
                    continue;
                }
            }
            else if (!targetPatientName.equals(record.getPatientName()))
            {
                continue;
            }
            if (!medicineIdSet.isEmpty() && !medicineIdSet.contains(record.getMedicineId()))
            {
                continue;
            }
            if (!"medical_record".equals(record.getRelatedRecordType()))
            {
                continue;
            }

            java.util.Date currentCreateTime = record.getCreateTime() != null ? record.getCreateTime() : new java.util.Date(0);
            java.util.Date latestCreateTime = latestRecordTimeByMedicine.get(record.getMedicineId());
            if (latestCreateTime == null || currentCreateTime.after(latestCreateTime))
            {
                latestRecordTimeByMedicine.put(record.getMedicineId(), currentCreateTime);
                latestExpiryByMedicine.put(record.getMedicineId(), record.getExpiryDate());
            }
        }

        List<Map<String, Object>> result = new ArrayList<>();
        for (Map.Entry<Long, java.util.Date> entry : latestExpiryByMedicine.entrySet())
        {
            Map<String, Object> row = new HashMap<>();
            row.put("medicineId", entry.getKey());
            row.put("dispensedExpiryDate", entry.getValue());
            result.add(row);
        }
        return AjaxResult.success(result);
    }

    @GetMapping("/batchList")
    @ResponseBody
    public AjaxResult batchList(@RequestParam Long medicineId)
    {
        User currentUser = currentUser();
        if (currentUser == null)
        {
            return AjaxResult.error("请先登录");
        }

        Set<String> roleKeys = getRoleKeys(currentUser);
        if (!ClinicSecuritySupport.isAdmin(roleKeys) && !ClinicSecuritySupport.isDoctor(roleKeys))
        {
            return forbiddenAjax("无权限访问");
        }
        if (medicineId == null)
        {
            return AjaxResult.error("缺少药品ID");
        }

        Date today = Date.valueOf(LocalDate.now());
        List<ClinicStockBatch> list = clinicStockBatchMapper.selectBatchListByMedicineId(medicineId);
        List<Map<String, Object>> rows = new ArrayList<>();
        for (ClinicStockBatch batch : list)
        {
            rows.add(toBatchView(batch, today));
        }
        return AjaxResult.success(rows);
    }

    @GetMapping("/batchSummary")
    @ResponseBody
    public AjaxResult batchSummary(@RequestParam String medicineIds)
    {
        User currentUser = currentUser();
        if (currentUser == null)
        {
            return AjaxResult.error("请先登录");
        }

        Set<String> roleKeys = getRoleKeys(currentUser);
        if (!ClinicSecuritySupport.isAdmin(roleKeys) && !ClinicSecuritySupport.isDoctor(roleKeys))
        {
            return forbiddenAjax("无权限访问");
        }
        if (StringUtils.isEmpty(medicineIds))
        {
            return AjaxResult.error("缺少药品ID列表");
        }

        Date today = Date.valueOf(LocalDate.now());
        List<Map<String, Object>> summaryList = new ArrayList<>();
        for (String idText : medicineIds.split(","))
        {
            Long medicineId = parseLong(idText);
            if (medicineId == null)
            {
                continue;
            }

            List<ClinicStockBatch> batchList = clinicStockBatchMapper.selectBatchListByMedicineId(medicineId);
            ClinicStockBatch nearest = null;
            for (ClinicStockBatch batch : batchList)
            {
                Integer remaining = batch.getRemainingQuantity();
                if (remaining == null || remaining <= 0)
                {
                    continue;
                }
                if (nearest == null
                    || (batch.getExpiryDate() != null && nearest.getExpiryDate() != null
                        && batch.getExpiryDate().before(nearest.getExpiryDate())))
                {
                    nearest = batch;
                }
            }

            Map<String, Object> row = new HashMap<>();
            row.put("medicineId", medicineId);
            if (nearest != null)
            {
                long daysToExpiry = nearest.getExpiryDate() != null
                    ? (nearest.getExpiryDate().getTime() - today.getTime()) / (24L * 60L * 60L * 1000L)
                    : 0L;
                row.put("nearestBatchExpiryDate", nearest.getExpiryDate());
                row.put("nearestBatchRemainingQuantity", nearest.getRemainingQuantity());
                row.put("nearestBatchNumber", nearest.getBatchNumber());
                row.put("nearestBatchInDate", nearest.getCreateTime());
                row.put("nearestBatchDaysToExpiry", daysToExpiry);
            }
            summaryList.add(row);
        }
        return AjaxResult.success(summaryList);
    }

    @GetMapping("/expiryWarnings")
    @ResponseBody
    public AjaxResult expiryWarnings(@RequestParam(required = false) Integer days,
        @RequestParam(required = false) Integer limit,
        @RequestParam(required = false) String medicineName)
    {
        User currentUser = currentUser();
        if (currentUser == null)
        {
            return AjaxResult.error("请先登录");
        }

        Set<String> roleKeys = getRoleKeys(currentUser);
        if (!ClinicSecuritySupport.isAdmin(roleKeys) && !ClinicSecuritySupport.isDoctor(roleKeys))
        {
            return forbiddenAjax("无权限访问");
        }
        return AjaxResult.success(clinicStockRecordService.selectNearExpiryBatchWarnings(days, limit, medicineName));
    }

    @PostMapping("/offShelfNearExpiry")
    @ResponseBody
    public AjaxResult offShelfNearExpiry(@RequestBody(required = false) Map<String, Object> params)
    {
        User currentUser = currentUser();
        if (currentUser == null)
        {
            return AjaxResult.error("请先登录");
        }

        Set<String> roleKeys = getRoleKeys(currentUser);
        if (!ClinicSecuritySupport.isAdmin(roleKeys))
        {
            return forbiddenAjax("无权限访问");
        }

        Integer days = null;
        if (params != null && params.get("days") != null)
        {
            try
            {
                days = Integer.valueOf(String.valueOf(params.get("days")));
            }
            catch (Exception ignored)
            {
            }
        }

        try
        {
            Map<String, Object> result = clinicStockRecordService.offShelfNearExpiryBatches(days, currentUser.getUserId(),
                currentUser.getUserName());
            return AjaxResult.success(result);
        }
        catch (RuntimeException ex)
        {
            return AjaxResult.error(ex.getMessage());
        }
    }

    @PostMapping("/offShelfBatch")
    @ResponseBody
    public AjaxResult offShelfBatch(@RequestBody Map<String, Object> params)
    {
        User currentUser = currentUser();
        if (currentUser == null)
        {
            return AjaxResult.error("请先登录");
        }

        Set<String> roleKeys = getRoleKeys(currentUser);
        if (!ClinicSecuritySupport.isAdmin(roleKeys))
        {
            return forbiddenAjax("无权限访问");
        }

        Long batchId = parseLong(params.get("batchId"));
        if (batchId == null)
        {
            return AjaxResult.error("批次ID无效");
        }

        String remark = stringValue(params.get("remark"));
        try
        {
            Map<String, Object> result = clinicStockRecordService.offShelfBatch(batchId, currentUser.getUserId(),
                currentUser.getUserName(), remark);
            return AjaxResult.success(result);
        }
        catch (RuntimeException ex)
        {
            return AjaxResult.error(ex.getMessage());
        }
    }

    @GetMapping("/packLossSummary")
    @ResponseBody
    public AjaxResult getPackLossSummary()
    {
        User currentUser = currentUser();
        if (currentUser == null)
        {
            return AjaxResult.error("请先登录");
        }

        Set<String> roleKeys = getRoleKeys(currentUser);
        if (!ClinicSecuritySupport.isAdmin(roleKeys) && !ClinicSecuritySupport.isDoctor(roleKeys))
        {
            return forbiddenAjax("无权限访问");
        }

        return AjaxResult.success(clinicStockRecordService.getPackLossSummary());
    }

    @PostMapping("/executePackLossOut")
    @ResponseBody
    public AjaxResult executePackLossOut(@RequestParam Long medicineId)
    {
        User currentUser = currentUser();
        if (currentUser == null)
        {
            return AjaxResult.error("请先登录");
        }

        Set<String> roleKeys = getRoleKeys(currentUser);
        if (!ClinicSecuritySupport.isAdmin(roleKeys) && !ClinicSecuritySupport.isDoctor(roleKeys))
        {
            return forbiddenAjax("无权限访问");
        }

        Map<String, Object> result = clinicStockRecordService.executePackLossOut(medicineId, currentUser.getUserId(),
            currentUser.getUserName());
        if (Boolean.TRUE.equals(result.get("success")))
        {
            return AjaxResult.success("出库成功", result);
        }
        return AjaxResult.error(String.valueOf(result.get("message")));
    }

    private User currentUser()
    {
        return ShiroUtils.getSysUser();
    }

    private Set<String> getRoleKeys(User user)
    {
        return ClinicSecuritySupport.getRoleKeys(user, roleService);
    }

    private Long resolveCurrentPatientId(User currentUser, Set<String> roleKeys)
    {
        return ClinicSecuritySupport.resolvePatientProfileId(currentUser,
            ClinicSecuritySupport.normalizeRoleKeys(roleKeys), clinicPatientService);
    }

    private boolean ownsRecord(User currentUser, ClinicStockRecord record)
    {
        return currentUser != null
            && record != null
            && record.getOperatorId() != null
            && record.getOperatorId().equals(currentUser.getUserId());
    }

    private boolean isStockInOperation(ClinicStockRecord clinicStockRecord)
    {
        if (clinicStockRecord == null || StringUtils.isEmpty(clinicStockRecord.getOperationType()))
        {
            return false;
        }
        return "in".equalsIgnoreCase(clinicStockRecord.getOperationType().trim());
    }

    private Set<Long> parseIdSet(String values)
    {
        Set<Long> ids = new HashSet<>();
        if (StringUtils.isEmpty(values))
        {
            return ids;
        }

        for (String value : values.split(","))
        {
            Long id = parseLong(value);
            if (id != null)
            {
                ids.add(id);
            }
        }
        return ids;
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
        catch (Exception ignored)
        {
            return null;
        }
    }

    private String stringValue(Object value)
    {
        return value != null ? String.valueOf(value) : null;
    }

    private Map<String, Object> toBatchView(ClinicStockBatch batch, Date today)
    {
        boolean expired = batch.getExpiryDate() != null && batch.getExpiryDate().before(today);
        Long daysToExpiry = null;
        boolean nearExpiry = false;
        if (batch.getExpiryDate() != null)
        {
            long delta = (batch.getExpiryDate().getTime() - today.getTime()) / (24L * 60L * 60L * 1000L);
            daysToExpiry = delta;
            nearExpiry = !expired && delta <= 30;
        }

        Map<String, Object> row = new HashMap<>();
        row.put("batchId", batch.getBatchId());
        row.put("medicineId", batch.getMedicineId());
        row.put("batchNumber", batch.getBatchNumber());
        row.put("stockInDate", batch.getCreateTime());
        row.put("createTime", batch.getCreateTime());
        row.put("expiryDate", batch.getExpiryDate());
        row.put("remainingQuantity", batch.getRemainingQuantity());
        row.put("expired", expired);
        row.put("nearExpiry", nearExpiry);
        row.put("daysToExpiry", daysToExpiry);
        return row;
    }

    private AjaxResult forbiddenAjax(String message)
    {
        AjaxResult result = AjaxResult.error(message);
        result.put(AjaxResult.CODE_TAG, 403);
        return result;
    }

    private TableDataInfo deniedTable(int code, String message)
    {
        TableDataInfo denied = new TableDataInfo();
        denied.setCode(code);
        denied.setMsg(message);
        denied.setRows(new ArrayList<>());
        denied.setTotal(0);
        return denied;
    }

    private TableDataInfo errorTable(String message)
    {
        TableDataInfo error = new TableDataInfo();
        error.setCode(500);
        error.setMsg(StringUtils.isNotEmpty(message) ? message : "加载库存记录失败");
        error.setRows(new ArrayList<>());
        error.setTotal(0);
        return error;
    }
}
