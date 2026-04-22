package com.ruoyi.project.clinic.medicine.controller;

import java.util.List;
import java.util.Arrays;
import java.util.Map;
import java.util.Set;
import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONObject;

import org.apache.shiro.authz.annotation.RequiresPermissions;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.security.ShiroUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import com.github.pagehelper.PageHelper;
import com.ruoyi.project.clinic.medicine.domain.ClinicMedicine;
import com.ruoyi.project.clinic.medicine.dto.MedicineRecognitionRequest;
import com.ruoyi.project.clinic.medicine.dto.MedicineRecognitionResult;
import com.ruoyi.project.clinic.medicine.service.IClinicMedicineService;
import com.ruoyi.project.clinic.common.ClinicApiMessages;
import com.ruoyi.project.clinic.medicine.service.support.MedicineRecognitionService;
import com.ruoyi.project.clinic.medicine.service.support.MedicineRecognitionHistoryService;
import com.ruoyi.framework.web.controller.BaseController;
import com.ruoyi.framework.web.domain.AjaxResult;
import com.ruoyi.framework.web.page.TableDataInfo;
import com.ruoyi.project.clinic.audit.service.AuditTrailService;
import com.ruoyi.project.system.role.service.IRoleService;
import com.ruoyi.project.system.user.domain.User;

@Controller
@RequestMapping("/api/clinic/medicine")
public class ClinicMedicineApiController extends BaseController
{
    private static final String MSG_CREATE_MEDICINE_FAILED = "创建药品失败";
    private static final String MSG_DELETE_MEDICINE_ID_REQUIRED = "请提供要删除的药品ID";
    private static final String MSG_DELETE_MEDICINE_ID_INVALID = "药品ID格式错误";
    private static final String MSG_MEDICINE_NOT_FOUND = "药品不存在";
    private static final String MSG_RECOGNITION_IMAGE_NOT_FOUND = "未找到识别原图";
    private static final String MSG_CONFIRM_SESSION_ID_REQUIRED = "缺少识别会话ID";
    private static final String MSG_CONFIRM_PAYLOAD_REQUIRED = "缺少识别确认内容";
    private static final String MSG_RECOGNITION_PERMISSION_CREATE = "无权限执行药品建档识别";
    private static final String MSG_RECOGNITION_PERMISSION_STOCK = "无权限执行药品出入库识别";

    @Autowired
    private IClinicMedicineService clinicMedicineService;

    @Autowired
    private IRoleService roleService;

    @Autowired
    private MedicineRecognitionService medicineRecognitionService;

    @Autowired
    private MedicineRecognitionHistoryService recognitionHistoryService;

    @Autowired
    private AuditTrailService auditTrailService;

    /**
     * 小程序药品列表（支持 JSON 请求体）
     */
    @PostMapping("/list")
    @ResponseBody
    public TableDataInfo list(@RequestBody(required = false) ClinicMedicineQuery query)
    {
        if (query == null)
        {
            query = new ClinicMedicineQuery();
        }

        int pageNum = query.getPageNum() != null ? query.getPageNum() : 1;
        int pageSize = query.getPageSize() != null ? query.getPageSize() : 10;
        if (pageSize <= 0)
        {
            pageSize = 10;
        }
        if (pageSize > 500) { pageSize = 500; }
        PageHelper.startPage(pageNum, pageSize);
        PageHelper.orderBy("create_time DESC, medicine_id DESC");

        ClinicMedicine criteria = new ClinicMedicine();
        criteria.setName(query.getName());
        criteria.setBarcode(query.getBarcode());
        criteria.setDosageForm(query.getDosageForm());
        criteria.setCategory(query.getCategory());
        criteria.setStatus(query.getStatus());
        criteria.setWarningOnly(query.getWarningOnly());

        List<ClinicMedicine> list = clinicMedicineService.selectClinicMedicineList(criteria);

        User currentUser = ShiroUtils.getSysUser();
        boolean isPatient = false;
        if (currentUser != null && currentUser.getUserId() != null)
        {
            Set<String> roleKeys = roleService.selectRoleKeys(currentUser.getUserId());
            isPatient = roleKeys != null && roleKeys.contains("patient");
        }
        if (isPatient)
        {
            for (ClinicMedicine medicine : list)
            {
                medicine.setLocation(null);
            }
        }

        return getDataTable(list);
    }

    @GetMapping("/getInfo")
    @ResponseBody
    public AjaxResult getInfo(@RequestParam Long medicineId)
    {
        if (medicineId == null)
        {
            return AjaxResult.error(ClinicApiMessages.MSG_PARAM_INVALID);
        }
        User currentUser = ShiroUtils.getSysUser();
        if (currentUser == null)
        {
            return AjaxResult.error(ClinicApiMessages.MSG_NEED_LOGIN);
        }
        ClinicMedicine medicine = clinicMedicineService.selectClinicMedicineById(medicineId);
        if (medicine == null)
        {
            return AjaxResult.error(MSG_MEDICINE_NOT_FOUND);
        }

        // 患者不允许查看药品位置
        boolean isPatient = roleService.selectRoleKeys(currentUser.getUserId())
                .stream().anyMatch("patient"::equals);
        if (isPatient)
        {
            medicine.setLocation(null);
        }

        return AjaxResult.success(medicine);
    }

    /**
     * 批量查询药品详情（解决N+1查询问题）
     */
    @PostMapping("/batch")
    @ResponseBody
    public AjaxResult batchGetInfo(@RequestBody java.util.List<Long> medicineIds)
    {
        User currentUser = ShiroUtils.getSysUser();
        if (currentUser == null)
        {
            return AjaxResult.error(ClinicApiMessages.MSG_NEED_LOGIN);
        }
        if (medicineIds == null || medicineIds.isEmpty())
        {
            return AjaxResult.success(java.util.Collections.emptyList());
        }
        // 限制最多查询100个
        if (medicineIds.size() > 100)
        {
            medicineIds = medicineIds.subList(0, 100);
        }
        java.util.List<Long> normalizedIds = sanitizeMedicineIds(medicineIds);
        if (normalizedIds.isEmpty())
        {
            return AjaxResult.success(java.util.Collections.emptyList());
        }
        java.util.List<ClinicMedicine> medicines = clinicMedicineService.selectMedicineByIds(normalizedIds);

        // 患者不允许查看药品位置
        boolean isPatient = roleService.selectRoleKeys(currentUser.getUserId())
                .stream().anyMatch("patient"::equals);
        if (isPatient)
        {
            for (ClinicMedicine medicine : medicines)
            {
                medicine.setLocation(null);
            }
        }

        return AjaxResult.success(medicines);
    }

    @PostMapping("/add")
    @ResponseBody
    @RequiresPermissions("clinic:medicine:add")
    public AjaxResult addSave(@RequestBody ClinicMedicine clinicMedicine)
    {
        User currentUser = ShiroUtils.getSysUser();
        if (currentUser == null)
        {
            return AjaxResult.error(ClinicApiMessages.MSG_NEED_LOGIN);
        }
        Set<String> roleKeys = roleService.selectRoleKeys(currentUser.getUserId());
        if (roleKeys == null || (!roleKeys.contains("admin") && !roleKeys.contains("common")
                && !roleKeys.contains("clinic_admin")))
        {
            return AjaxResult.error(ClinicApiMessages.MSG_NO_PERMISSION);
        }
        int rows = clinicMedicineService.insertClinicMedicine(clinicMedicine);
        if (rows > 0)
        {
            auditTrailService.record(
                "medicine",
                "create",
                clinicMedicine.getMedicineId() != null ? String.valueOf(clinicMedicine.getMedicineId()) : "-",
                "新增药品：" + StringUtils.defaultString(clinicMedicine.getName(), "-")
            );
            java.util.Map<String, Object> data = new java.util.HashMap<>();
            data.put("medicineId", clinicMedicine.getMedicineId());
            return AjaxResult.success(data);
        }
            return AjaxResult.error(MSG_CREATE_MEDICINE_FAILED);
    }

    @PostMapping("/edit")
    @ResponseBody
    @RequiresPermissions("clinic:medicine:edit")
    public AjaxResult editSave(@RequestBody ClinicMedicine clinicMedicine)
    {
        User currentUser = ShiroUtils.getSysUser();
        if (currentUser == null)
        {
            return AjaxResult.error(ClinicApiMessages.MSG_NEED_LOGIN);
        }
        Set<String> roleKeys = roleService.selectRoleKeys(currentUser.getUserId());
        if (roleKeys == null || (!roleKeys.contains("admin") && !roleKeys.contains("common")
                && !roleKeys.contains("clinic_admin")))
        {
            return AjaxResult.error(ClinicApiMessages.MSG_NO_PERMISSION);
        }
        int rows = clinicMedicineService.updateClinicMedicine(clinicMedicine);
        if (rows > 0)
        {
            auditTrailService.record(
                "medicine",
                "update",
                clinicMedicine.getMedicineId() != null ? String.valueOf(clinicMedicine.getMedicineId()) : "-",
                "更新药品：" + StringUtils.defaultString(clinicMedicine.getName(), "-")
            );
        }
        return toAjax(rows);
    }

    @PostMapping("/remove")
    @ResponseBody
    @RequiresPermissions("clinic:medicine:remove")
    public AjaxResult remove(@RequestBody(required = false) Map<String, String> params)
    {
        User currentUser = ShiroUtils.getSysUser();
        if (currentUser == null)
        {
            return AjaxResult.error(ClinicApiMessages.MSG_NEED_LOGIN);
        }
        Set<String> roleKeys = roleService.selectRoleKeys(currentUser.getUserId());
        if (roleKeys == null || (!roleKeys.contains("admin") && !roleKeys.contains("common")
                && !roleKeys.contains("clinic_admin")))
        {
            return AjaxResult.error(ClinicApiMessages.MSG_NO_PERMISSION);
        }
        String ids = params != null && params.get("ids") != null ? params.get("ids") : null;
        if (StringUtils.isEmpty(ids))
        {
            return AjaxResult.error(MSG_DELETE_MEDICINE_ID_REQUIRED);
        }
        Long[] medicineIds;
        try
        {
            medicineIds = parseMedicineIds(ids);
        }
        catch (IllegalArgumentException ex)
        {
            return AjaxResult.error(ex.getMessage());
        }
        int rows = clinicMedicineService.deleteClinicMedicineByIds(medicineIds);
        if (rows > 0)
        {
            auditTrailService.record(
                "medicine",
                "delete",
                ids,
                "删除药品ID：" + ids
            );
        }
        return toAjax(rows);
    }

    /**
     * 药品列表查询参数
     */
    @PostMapping("/recognize/code")
    @ResponseBody
    public AjaxResult recognizeByCode(@RequestBody(required = false) MedicineRecognitionRequest request)
    {
        ensureRecognitionPermission(request != null ? request.getScene() : null);
        MedicineRecognitionResult result = medicineRecognitionService.recognizeByCode(
            request != null ? request.getScene() : null,
            request != null ? request.getCode() : null);
        return AjaxResult.success(result);
    }

    @PostMapping("/recognize/image")
    @ResponseBody
    public AjaxResult recognizeByImage(@RequestParam("scene") String scene, @RequestParam("file") MultipartFile file)
    {
        ensureRecognitionPermission(scene);
        MedicineRecognitionResult result = medicineRecognitionService.recognizeByImage(scene, file);
        return AjaxResult.success(result);
    }

    @PostMapping("/recognize/ocr")
    @ResponseBody
    public AjaxResult recognizeByOcr(@RequestParam("scene") String scene, @RequestParam("file") MultipartFile file)
    {
        ensureRecognitionPermission(scene);
        MedicineRecognitionResult result = medicineRecognitionService.recognizeByOcr(scene, file);
        return AjaxResult.success(result);
    }

    @PostMapping("/recognize/package")
    @ResponseBody
    public AjaxResult recognizeByPackage(@RequestParam("scene") String scene, @RequestParam("file") MultipartFile file)
    {
        ensureRecognitionPermission(scene);
        MedicineRecognitionResult result = medicineRecognitionService.recognizeByPackageImage(scene, file);
        return AjaxResult.success(result);
    }

    @PostMapping("/recognize/multi-image")
    @ResponseBody
    public AjaxResult recognizeByMultiImage(@RequestParam("scene") String scene, @RequestParam("files") MultipartFile[] files)
    {
        ensureRecognitionPermission(scene);
        MedicineRecognitionResult result = medicineRecognitionService.recognizeByMultiImage(scene, files);
        return AjaxResult.success(result);
    }

    @PostMapping("/recognize/voice-text")
    @ResponseBody
    public AjaxResult recognizeByVoiceText(@RequestBody(required = false) Map<String, String> params)
    {
        String scene = params != null ? params.get("scene") : null;
        ensureRecognitionPermission(scene);
        MedicineRecognitionResult result = medicineRecognitionService.recognizeByVoiceText(
            scene,
            params != null ? params.get("text") : null
        );
        return AjaxResult.success(result);
    }

    @GetMapping("/recognize/history")
    @ResponseBody
    public AjaxResult recognizeHistory(@RequestParam(value = "limit", required = false, defaultValue = "20") Integer limit)
    {
        ensureRecognitionPermission("stock_out");
        int effectiveLimit = limit != null ? limit : 20;
        if (effectiveLimit < 1)
        {
            effectiveLimit = 1;
        }
        if (effectiveLimit > 200)
        {
            effectiveLimit = 200;
        }
        return AjaxResult.success(recognitionHistoryService.latest(effectiveLimit));
    }

    @GetMapping("/recognize/image-data")
    @ResponseBody
    public AjaxResult recognizeImageData(@RequestParam("sessionId") String sessionId)
    {
        ensureRecognitionPermission("stock_out");
        if (StringUtils.isEmpty(sessionId))
        {
            return AjaxResult.error(ClinicApiMessages.MSG_PARAM_INVALID);
        }
        JSONObject data = recognitionHistoryService.loadImageData(sessionId);
        if (data == null)
        {
            return AjaxResult.error(MSG_RECOGNITION_IMAGE_NOT_FOUND);
        }
        return AjaxResult.success(data);
    }

    @PostMapping("/recognize/confirm")
    @ResponseBody
    public AjaxResult confirmRecognition(@RequestBody(required = false) Map<String, Object> params)
    {
        ensureRecognitionPermission("stock_out");
        String sessionId = params != null ? StringUtils.trim(String.valueOf(params.get("sessionId"))) : null;
        if (StringUtils.isEmpty(sessionId) || "null".equalsIgnoreCase(sessionId))
        {
            return AjaxResult.error(MSG_CONFIRM_SESSION_ID_REQUIRED);
        }
        Object finalPayload = params != null ? params.get("finalPayload") : null;
        if (finalPayload == null)
        {
            return AjaxResult.error(MSG_CONFIRM_PAYLOAD_REQUIRED);
        }
        JSONObject payload = finalPayload instanceof JSONObject
            ? (JSONObject) finalPayload
            : JSON.parseObject(JSON.toJSONString(finalPayload));
        if (payload == null)
        {
            return AjaxResult.error(MSG_CONFIRM_PAYLOAD_REQUIRED);
        }
        recognitionHistoryService.recordConfirmation(sessionId, payload);
        auditTrailService.record(
            "medicine_recognition",
            "confirm",
            sessionId,
            "识别结果已确认并写入最终内容"
        );
        return AjaxResult.success();
    }

    private void ensureRecognitionPermission(String scene)
    {
        User currentUser = ShiroUtils.getSysUser();
        if (currentUser == null)
        {
            throw new IllegalArgumentException(ClinicApiMessages.MSG_NEED_LOGIN);
        }
        Set<String> roleKeys = roleService.selectRoleKeys(currentUser.getUserId());
        String normalizedScene = StringUtils.trim(scene);
        boolean createScene = StringUtils.isEmpty(normalizedScene) || "create".equals(normalizedScene);
        boolean stockInScene = "stock_in".equals(normalizedScene);
        boolean canCreate = roleKeys != null && (roleKeys.contains("admin") || roleKeys.contains("common")
            || roleKeys.contains("clinic_admin"));
        boolean canStock = roleKeys != null && (canCreate || roleKeys.contains("doctor"));
        if (createScene && !canCreate)
        {
            throw new IllegalArgumentException(MSG_RECOGNITION_PERMISSION_CREATE);
        }
        if (stockInScene && !canCreate)
        {
            throw new IllegalArgumentException(MSG_RECOGNITION_PERMISSION_STOCK);
        }
        if (!createScene && !stockInScene && !canStock)
        {
            throw new IllegalArgumentException(MSG_RECOGNITION_PERMISSION_STOCK);
        }
    }

    private java.util.List<Long> sanitizeMedicineIds(java.util.List<Long> medicineIds)
    {
        java.util.List<Long> result = new java.util.ArrayList<Long>();
        for (Long id : medicineIds)
        {
            if (id != null && id > 0)
            {
                result.add(id);
            }
        }
        return result;
    }

    private Long[] parseMedicineIds(String ids)
    {
        Long[] medicineIds = Arrays.stream(ids.split(","))
            .map(String::trim)
            .filter(StringUtils::isNotEmpty)
            .map(this::parseMedicineId)
            .toArray(Long[]::new);
        if (medicineIds.length == 0)
        {
            throw new IllegalArgumentException(MSG_DELETE_MEDICINE_ID_REQUIRED);
        }
        return medicineIds;
    }

    private Long parseMedicineId(String rawId)
    {
        try
        {
            return Long.valueOf(rawId);
        }
        catch (Exception ex)
        {
            throw new IllegalArgumentException(MSG_DELETE_MEDICINE_ID_INVALID);
        }
    }

    public static class ClinicMedicineQuery
    {
        private Integer pageNum;
        private Integer pageSize;
        private String name;
        private String barcode;
        private String dosageForm;
        private String category;
        private String status;
        private Boolean warningOnly;

        public Integer getPageNum()
        {
            return pageNum;
        }

        public void setPageNum(Integer pageNum)
        {
            this.pageNum = pageNum;
        }

        public Integer getPageSize()
        {
            return pageSize;
        }

        public void setPageSize(Integer pageSize)
        {
            this.pageSize = pageSize;
        }

        public String getName()
        {
            return name;
        }

        public void setName(String name)
        {
            this.name = name;
        }

        public String getDosageForm()
        {
            return dosageForm;
        }

        public String getBarcode()
        {
            return barcode;
        }

        public void setBarcode(String barcode)
        {
            this.barcode = barcode;
        }

        public void setDosageForm(String dosageForm)
        {
            this.dosageForm = dosageForm;
        }

        public String getCategory()
        {
            return category;
        }

        public void setCategory(String category)
        {
            this.category = category;
        }

        public String getStatus()
        {
            return status;
        }

        public void setStatus(String status)
        {
            this.status = status;
        }

        public Boolean getWarningOnly()
        {
            return warningOnly;
        }

        public void setWarningOnly(Boolean warningOnly)
        {
            this.warningOnly = warningOnly;
        }
    }
}
