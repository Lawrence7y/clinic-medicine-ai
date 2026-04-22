package com.ruoyi.project.clinic.medical.controller;

import com.github.pagehelper.PageHelper;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.security.ShiroUtils;
import com.ruoyi.framework.web.controller.BaseController;
import com.ruoyi.framework.web.domain.AjaxResult;
import com.ruoyi.framework.web.page.TableDataInfo;
import com.ruoyi.project.clinic.common.ClinicSecuritySupport;
import com.ruoyi.project.clinic.medical.domain.ClinicMedicalRecord;
import com.ruoyi.project.clinic.medical.service.IClinicMedicalRecordService;
import com.ruoyi.project.clinic.patient.service.IClinicPatientService;
import com.ruoyi.project.system.role.service.IRoleService;
import com.ruoyi.project.system.user.domain.User;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;
import javax.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
@RequestMapping("/api/clinic/medical")
public class ClinicMedicalRecordApiController extends BaseController
{
    @Autowired
    private IClinicMedicalRecordService clinicMedicalRecordService;

    @Autowired
    private IRoleService roleService;

    @Autowired
    private IClinicPatientService clinicPatientService;

    @PostMapping("/list")
    @ResponseBody
    public TableDataInfo list(@RequestBody(required = false) ClinicMedicalRecordQuery query)
    {
        if (query == null)
        {
            query = new ClinicMedicalRecordQuery();
        }

        User currentUser = currentUser();
        if (currentUser == null)
        {
            return deniedTable(401, "璇峰厛鐧诲綍");
        }

        Set<String> roleKeys = getRoleKeys(currentUser);
        boolean isAdmin = ClinicSecuritySupport.isAdmin(roleKeys);
        boolean isDoctor = ClinicSecuritySupport.isDoctor(roleKeys);
        boolean isPatient = ClinicSecuritySupport.isPatient(roleKeys);
        if (!isAdmin && !isDoctor && !isPatient)
        {
            return deniedTable(403, "鏃犳潈闄愯闂?");
        }

        if (isPatient)
        {
            Long patientId = resolveCurrentPatientId(currentUser, roleKeys);
            if (patientId == null)
            {
                return emptyTable();
            }
            query.setPatientId(patientId);
            query.setPatientName(null);
            query.setPatientPhone(null);
        }
        else if (isDoctor && !isAdmin)
        {
            query.setDoctorId(currentUser.getUserId());
            query.setPatientName(null);
            query.setPatientPhone(null);
        }

        int pageNum = query.getPageNum() != null ? query.getPageNum() : 1;
        int pageSize = query.getPageSize() != null ? query.getPageSize() : 10;
        if (pageSize > 200)
        {
            pageSize = 200;
        }
        PageHelper.startPage(pageNum, pageSize);
        PageHelper.orderBy("create_time DESC, record_id DESC");

        ClinicMedicalRecord criteria = new ClinicMedicalRecord();
        criteria.setPatientId(query.getPatientId());
        criteria.setPatientName(query.getPatientName());
        criteria.setPatientPhone(query.getPatientPhone());
        criteria.setDoctorId(query.getDoctorId());
        criteria.setDiagnosis(query.getDiagnosis());
        if (StringUtils.isNotEmpty(query.getStartDate()))
        {
            criteria.getParams().put("startDate", query.getStartDate());
        }
        if (StringUtils.isNotEmpty(query.getEndDate()))
        {
            criteria.getParams().put("endDate", query.getEndDate());
        }

        List<ClinicMedicalRecord> list = clinicMedicalRecordService.selectClinicMedicalRecordList(criteria);
        return getDataTable(list);
    }

    @GetMapping("/getInfo")
    @ResponseBody
    public AjaxResult getInfo(@RequestParam Long recordId)
    {
        User loginUser = currentUser();
        if (loginUser == null)
        {
            return AjaxResult.error("请先登录");
        }

        Set<String> loginRoleKeys = getRoleKeys(loginUser);
        boolean loginIsAdmin = ClinicSecuritySupport.isAdmin(loginRoleKeys);
        boolean loginIsDoctor = ClinicSecuritySupport.isDoctor(loginRoleKeys);
        boolean loginIsPatient = ClinicSecuritySupport.isPatient(loginRoleKeys);
        if (!loginIsAdmin && !loginIsDoctor && !loginIsPatient)
        {
            return forbiddenAjax("无权限访问");
        }
        ClinicMedicalRecord record = clinicMedicalRecordService.selectClinicMedicalRecordById(recordId);
        if (record == null)
        {
            return AjaxResult.error("病历不存在");
        }

        User currentUser = currentUser();
        if (currentUser != null)
        {
            Set<String> roleKeys = getRoleKeys(currentUser);
            if (ClinicSecuritySupport.isPatient(roleKeys))
            {
                Long patientId = resolveCurrentPatientId(currentUser, roleKeys);
                if (patientId == null || !patientId.equals(record.getPatientId()))
                {
                    return forbiddenAjax("无权限访问");
                }
            }
        }

        if (loginIsDoctor && !loginIsAdmin
            && record.getDoctorId() != null
            && !record.getDoctorId().equals(loginUser.getUserId()))
        {
            return forbiddenAjax("无权限访问");
        }

        return AjaxResult.success(record);
    }

    @PostMapping("/add")
    @ResponseBody
    public AjaxResult addSave(@RequestBody ClinicMedicalRecord clinicMedicalRecord)
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

        if (isDoctor && !isAdmin)
        {
            clinicMedicalRecord.setDoctorId(currentUser.getUserId());
            clinicMedicalRecord.setDoctorName(currentUser.getUserName());
        }

        int rows = clinicMedicalRecordService.insertClinicMedicalRecord(clinicMedicalRecord);
        if (rows <= 0)
        {
            return AjaxResult.error("创建病历失败");
        }

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("recordId", clinicMedicalRecord.getRecordId());
        return AjaxResult.success(data);
    }

    @PostMapping("/edit")
    @ResponseBody
    public AjaxResult editSave(@RequestBody ClinicMedicalRecord clinicMedicalRecord)
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
        if (clinicMedicalRecord.getRecordId() == null)
        {
            return AjaxResult.error("参数错误");
        }

        ClinicMedicalRecord old = clinicMedicalRecordService.selectClinicMedicalRecordById(clinicMedicalRecord.getRecordId());
        if (old == null)
        {
            return AjaxResult.error("病历不存在");
        }
        if (isDoctor && !isAdmin && old.getDoctorId() != null && !old.getDoctorId().equals(currentUser.getUserId()))
        {
            return forbiddenAjax("无权限访问");
        }
        return toAjax(clinicMedicalRecordService.updateClinicMedicalRecord(clinicMedicalRecord));
    }

    @PostMapping("/remove")
    @ResponseBody
    public AjaxResult remove(@RequestBody(required = false) Map<String, String> params)
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

        String ids = params != null ? params.get("ids") : null;
        if (StringUtils.isEmpty(ids))
        {
            return AjaxResult.error("请提供要删除的病历ID");
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
                ClinicMedicalRecord record = clinicMedicalRecordService.selectClinicMedicalRecordById(recordId);
                if (record != null && record.getDoctorId() != null
                    && !record.getDoctorId().equals(currentUser.getUserId()))
                {
                    return forbiddenAjax("无权限访问");
                }
            }
        }
        return toAjax(clinicMedicalRecordService.deleteClinicMedicalRecordByIds(recordIds));
    }

    @PostMapping("/syncDoctorName")
    @ResponseBody
    public AjaxResult syncDoctorName(@RequestBody Map<String, Object> params)
    {
        Long doctorId = parseLong(params.get("doctorId"));
        String doctorName = stringValue(params.get("doctorName"));

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

        int updated = clinicMedicalRecordService.syncDoctorName(doctorId, doctorName);
        return AjaxResult.success("更新成功", updated);
    }

    @PostMapping("/syncPatientInfo")
    @ResponseBody
    public AjaxResult syncPatientInfo(@RequestBody Map<String, Object> params)
    {
        Long patientId = parseLong(params.get("patientId"));
        String patientName = stringValue(params.get("patientName"));
        String patientPhone = stringValue(params.get("patientPhone"));

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

        int updated = clinicMedicalRecordService.syncPatientInfo(patientId, patientName, patientPhone);
        return AjaxResult.success("更新成功", updated);
    }

    @GetMapping("/statistics")
    @ResponseBody
    public AjaxResult statistics(@RequestParam(defaultValue = "7d") String timeRange)
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

        Long doctorScopeId = isDoctor && !isAdmin ? currentUser.getUserId() : null;
        try
        {
            int days = resolveDays(timeRange);
            LocalDate end = LocalDate.now();
            LocalDate start = end.minusDays(days - 1);
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

            ClinicMedicalRecord criteria = new ClinicMedicalRecord();
            criteria.setDoctorId(doctorScopeId);
            List<ClinicMedicalRecord> all = clinicMedicalRecordService.selectClinicMedicalRecordList(criteria);
            if (all == null)
            {
                all = new ArrayList<>();
            }
            List<ClinicMedicalRecord> records = filterByDateRange(all, start, end, formatter);

            int totalRecords = records.size();
            int todayRecords = (int) records.stream()
                .filter(record -> end.equals(toLocalDate(record.getVisitTime())))
                .count();

            long totalPatients = records.stream()
                .filter(record -> record.getPatientId() != null)
                .map(ClinicMedicalRecord::getPatientId)
                .distinct()
                .count();

            java.math.BigDecimal averageAge = java.math.BigDecimal.ZERO;
            List<ClinicMedicalRecord> recordsWithAge = records.stream()
                .filter(record -> record.getPatientAge() != null)
                .collect(Collectors.toList());
            if (!recordsWithAge.isEmpty())
            {
                int sumAge = recordsWithAge.stream().mapToInt(ClinicMedicalRecord::getPatientAge).sum();
                averageAge = new java.math.BigDecimal(sumAge)
                    .divide(new java.math.BigDecimal(recordsWithAge.size()), 1, java.math.BigDecimal.ROUND_HALF_UP);
            }

            Map<String, Long> diagnosisCount = records.stream()
                .filter(record -> StringUtils.isNotEmpty(record.getDiagnosis()))
                .collect(Collectors.groupingBy(ClinicMedicalRecord::getDiagnosis, LinkedHashMap::new, Collectors.counting()));

            List<Map<String, Object>> diagnosisStats = diagnosisCount.entrySet().stream()
                .sorted((left, right) -> Long.compare(right.getValue(), left.getValue()))
                .limit(20)
                .map(entry -> {
                    Map<String, Object> item = new LinkedHashMap<>();
                    item.put("diagnosis", entry.getKey());
                    item.put("count", entry.getValue());
                    return item;
                })
                .collect(Collectors.toList());

            Map<String, Integer> trend = buildTrend(start, days, formatter);
            for (ClinicMedicalRecord record : records)
            {
                LocalDate visitDate = toLocalDate(record.getVisitTime());
                if (visitDate != null)
                {
                    String visitDateText = visitDate.format(formatter);
                    if (trend.containsKey(visitDateText))
                    {
                        trend.put(visitDateText, trend.get(visitDateText) + 1);
                    }
                }
            }

            List<Map<String, Object>> trendData = trend.entrySet().stream()
                .map(entry -> {
                    Map<String, Object> item = new LinkedHashMap<>();
                    item.put("date", entry.getKey());
                    item.put("count", entry.getValue());
                    return item;
                })
                .collect(Collectors.toList());

            Map<String, Object> result = new LinkedHashMap<>();
            result.put("totalRecords", totalRecords);
            result.put("todayRecords", todayRecords);
            result.put("totalPatients", totalPatients);
            result.put("averageAge", averageAge);
            result.put("diagnosisStats", diagnosisStats);
            result.put("trendData", trendData);
            return AjaxResult.success(result);
        }
        catch (Exception ex)
        {
            return AjaxResult.error("加载统计数据失败: " + ex.getMessage());
        }
    }

    @GetMapping("/statistics/export")
    public void exportStatistics(@RequestParam(defaultValue = "7d") String timeRange, HttpServletResponse response)
    {
        User currentUser = currentUser();
        if (currentUser == null)
        {
            writeErrorResponse(response, 401, "请先登录");
            return;
        }

        Set<String> roleKeys = getRoleKeys(currentUser);
        boolean isAdmin = ClinicSecuritySupport.isAdmin(roleKeys);
        boolean isDoctor = ClinicSecuritySupport.isDoctor(roleKeys);
        if (!isAdmin && !isDoctor)
        {
            writeErrorResponse(response, 403, "无权限访问");
            return;
        }

        Long doctorScopeId = isDoctor && !isAdmin ? currentUser.getUserId() : null;
        try
        {
            int days = resolveDays(timeRange);
            LocalDate end = LocalDate.now();
            LocalDate start = end.minusDays(days - 1);
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

            ClinicMedicalRecord criteria = new ClinicMedicalRecord();
            criteria.setDoctorId(doctorScopeId);
            List<ClinicMedicalRecord> all = clinicMedicalRecordService.selectClinicMedicalRecordList(criteria);
            if (all == null)
            {
                all = new ArrayList<>();
            }
            List<ClinicMedicalRecord> records = filterByDateRange(all, start, end, formatter);

            int totalRecords = records.size();
            int todayRecords = (int) records.stream()
                .filter(record -> end.equals(toLocalDate(record.getVisitTime())))
                .count();

            Map<String, Long> diagnosisCount = records.stream()
                .filter(record -> StringUtils.isNotEmpty(record.getDiagnosis()))
                .collect(Collectors.groupingBy(ClinicMedicalRecord::getDiagnosis, LinkedHashMap::new, Collectors.counting()));

            Map<String, Integer> trend = buildTrend(start, days, formatter);
            for (ClinicMedicalRecord record : records)
            {
                LocalDate visitDate = toLocalDate(record.getVisitTime());
                if (visitDate != null)
                {
                    String visitDateText = visitDate.format(formatter);
                    if (trend.containsKey(visitDateText))
                    {
                        trend.put(visitDateText, trend.get(visitDateText) + 1);
                    }
                }
            }

            StringBuilder builder = new StringBuilder();
            builder.append("统计范围\t").append(start.format(formatter)).append(" ~ ").append(end.format(formatter)).append("\n");
            builder.append("病历总数\t").append(totalRecords).append("\n");
            builder.append("今日病历数\t").append(todayRecords).append("\n\n");
            builder.append("诊断\t数量\n");
            diagnosisCount.entrySet().stream()
                .sorted((left, right) -> Long.compare(right.getValue(), left.getValue()))
                .limit(50)
                .forEach(entry -> builder.append(entry.getKey()).append("\t").append(entry.getValue()).append("\n"));
            builder.append("\n");
            builder.append("日期\t数量\n");
            trend.forEach((key, value) -> builder.append(key).append("\t").append(value).append("\n"));

            byte[] bytes = ("\uFEFF" + builder.toString()).getBytes(StandardCharsets.UTF_8);
            response.setCharacterEncoding("UTF-8");
            response.setContentType("application/vnd.ms-excel");
            response.setHeader("Content-Disposition", "attachment; filename=\"medical_statistics.xls\"");
            response.setContentLength(bytes.length);
            OutputStream outputStream = response.getOutputStream();
            outputStream.write(bytes);
            outputStream.flush();
        }
        catch (Exception ex)
        {
            try
            {
                response.setStatus(500);
                response.setContentType("text/plain;charset=UTF-8");
                response.getWriter().write("导出失败");
            }
            catch (Exception ignored)
            {
            }
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

    private Long resolveCurrentPatientId(User currentUser, Set<String> roleKeys)
    {
        return ClinicSecuritySupport.resolvePatientProfileId(currentUser,
            ClinicSecuritySupport.normalizeRoleKeys(roleKeys), clinicPatientService);
    }

    private int resolveDays(String timeRange)
    {
        if ("30d".equals(timeRange))
        {
            return 30;
        }
        if ("90d".equals(timeRange))
        {
            return 90;
        }
        if ("1y".equals(timeRange))
        {
            return 365;
        }
        return 7;
    }

    private List<ClinicMedicalRecord> filterByDateRange(List<ClinicMedicalRecord> records, LocalDate start, LocalDate end,
        DateTimeFormatter formatter)
    {
        return records.stream()
            .filter(record -> record.getVisitTime() != null)
            .filter(record -> {
                try
                {
                    LocalDate visitDate = toLocalDate(record.getVisitTime());
                    if (visitDate == null)
                    {
                        return false;
                    }
                    return !visitDate.isBefore(start) && !visitDate.isAfter(end);
                }
                catch (Exception ex)
                {
                    return false;
                }
            })
            .collect(Collectors.toList());
    }

    private LocalDate toLocalDate(java.util.Date date)
    {
        if (date == null)
        {
            return null;
        }
        return date.toInstant().atZone(ZoneId.systemDefault()).toLocalDate();
    }

    private Map<String, Integer> buildTrend(LocalDate start, int days, DateTimeFormatter formatter)
    {
        Map<String, Integer> trend = new LinkedHashMap<>();
        for (int i = 0; i < days; i++)
        {
            LocalDate date = start.plusDays(i);
            trend.put(date.format(formatter), 0);
        }
        return trend;
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

    private AjaxResult forbiddenAjax(String message)
    {
        AjaxResult result = AjaxResult.error(message);
        result.put(AjaxResult.CODE_TAG, 403);
        return result;
    }

    private void writeErrorResponse(HttpServletResponse response, int status, String message)
    {
        if (response == null)
        {
            return;
        }
        try
        {
            response.setStatus(status);
            response.setContentType("text/plain;charset=UTF-8");
            response.getWriter().write(message);
        }
        catch (Exception ignored)
        {
        }
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

    private TableDataInfo emptyTable()
    {
        TableDataInfo data = new TableDataInfo();
        data.setCode(0);
        data.setMsg("成功");
        data.setRows(new ArrayList<>());
        data.setTotal(0);
        return data;
    }

    public static class ClinicMedicalRecordQuery
    {
        private Integer pageNum;
        private Integer pageSize;
        private Long patientId;
        private String patientName;
        private String patientPhone;
        private Long doctorId;
        private String diagnosis;
        private String startDate;
        private String endDate;

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

        public Long getPatientId()
        {
            return patientId;
        }

        public void setPatientId(Long patientId)
        {
            this.patientId = patientId;
        }

        public String getPatientName()
        {
            return patientName;
        }

        public void setPatientName(String patientName)
        {
            this.patientName = patientName;
        }

        public String getPatientPhone()
        {
            return patientPhone;
        }

        public void setPatientPhone(String patientPhone)
        {
            this.patientPhone = patientPhone;
        }

        public Long getDoctorId()
        {
            return doctorId;
        }

        public void setDoctorId(Long doctorId)
        {
            this.doctorId = doctorId;
        }

        public String getDiagnosis()
        {
            return diagnosis;
        }

        public void setDiagnosis(String diagnosis)
        {
            this.diagnosis = diagnosis;
        }

        public String getStartDate()
        {
            return startDate;
        }

        public void setStartDate(String startDate)
        {
            this.startDate = startDate;
        }

        public String getEndDate()
        {
            return endDate;
        }

        public void setEndDate(String endDate)
        {
            this.endDate = endDate;
        }
    }
}
