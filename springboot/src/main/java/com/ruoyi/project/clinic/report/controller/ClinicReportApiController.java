package com.ruoyi.project.clinic.report.controller;

import com.alibaba.fastjson2.JSONObject;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.security.ShiroUtils;
import com.ruoyi.framework.web.controller.BaseController;
import com.ruoyi.framework.web.domain.AjaxResult;
import com.ruoyi.project.clinic.ai.service.support.AiInvocationLogService;
import com.ruoyi.project.clinic.appointment.domain.ClinicAppointment;
import com.ruoyi.project.clinic.appointment.service.IClinicAppointmentService;
import com.ruoyi.project.clinic.common.ClinicSecuritySupport;
import com.ruoyi.project.clinic.medicine.domain.ClinicMedicine;
import com.ruoyi.project.clinic.medicine.service.IClinicMedicineService;
import com.ruoyi.project.clinic.medicine.service.IClinicStockRecordService;
import com.ruoyi.project.system.role.service.IRoleService;
import com.ruoyi.project.system.user.domain.User;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/clinic/report")
public class ClinicReportApiController extends BaseController
{
    private static final int AI_LOG_LIMIT = 1000;
    private static final DateTimeFormatter AI_TIME_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    @Autowired
    private IRoleService roleService;

    @Autowired
    private IClinicAppointmentService clinicAppointmentService;

    @Autowired
    private IClinicMedicineService clinicMedicineService;

    @Autowired
    private IClinicStockRecordService clinicStockRecordService;

    @Autowired
    private AiInvocationLogService aiInvocationLogService;

    @GetMapping("/overview")
    public AjaxResult overview(
        @RequestParam(value = "startDate", required = false) String startDate,
        @RequestParam(value = "endDate", required = false) String endDate,
        @RequestParam(value = "dimension", required = false, defaultValue = "day") String dimension
    )
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

        LocalDate rangeStart = parseLocalDate(startDate);
        LocalDate rangeEnd = parseLocalDate(endDate);
        if (StringUtils.isNotEmpty(startDate) && rangeStart == null)
        {
            return AjaxResult.error("开始日期格式不正确");
        }
        if (StringUtils.isNotEmpty(endDate) && rangeEnd == null)
        {
            return AjaxResult.error("结束日期格式不正确");
        }
        if (rangeStart != null && rangeEnd != null && rangeStart.isAfter(rangeEnd))
        {
            return AjaxResult.error("开始日期不能晚于结束日期");
        }
        String normalizedDimension = normalizeDimension(dimension);
        if (normalizedDimension == null)
        {
            return AjaxResult.error("时间维度仅支持 day / week / month");
        }

        Map<String, Object> data = new HashMap<>();
        data.put("appointment", buildAppointmentStats(rangeStart, rangeEnd, normalizedDimension));
        data.put("inventory", buildInventoryStats());
        data.put("nearExpiry", buildNearExpiryStats());
        data.put("aiInvocation", buildAiInvocationStats(rangeStart, rangeEnd, normalizedDimension));
        data.put("rangeStartDate", rangeStart != null ? rangeStart.toString() : "");
        data.put("rangeEndDate", rangeEnd != null ? rangeEnd.toString() : "");
        data.put("dimension", normalizedDimension);
        data.put("generatedAt", System.currentTimeMillis());
        return AjaxResult.success(data);
    }

    private Map<String, Object> buildAppointmentStats(LocalDate rangeStart, LocalDate rangeEnd, String dimension)
    {
        List<ClinicAppointment> rows = clinicAppointmentService.selectClinicAppointmentList(new ClinicAppointment());
        List<ClinicAppointment> list = rows != null ? rows : new ArrayList<ClinicAppointment>();
        LocalDate todayDate = LocalDate.now();

        int pending = 0;
        int confirmed = 0;
        int completed = 0;
        int cancelled = 0;
        int expired = 0;
        int today = 0;
        Map<String, Integer> dailyCountMap = new TreeMap<String, Integer>();

        for (ClinicAppointment item : list)
        {
            if (item == null)
            {
                continue;
            }
            LocalDate appointmentDate = parseLocalDate(item.getAppointmentDate());
            if (!isDateInRange(appointmentDate, rangeStart, rangeEnd))
            {
                continue;
            }
            if (appointmentDate != null && appointmentDate.equals(todayDate))
            {
                today++;
            }
            if (appointmentDate != null)
            {
                String key = resolveDimensionKey(appointmentDate, dimension);
                dailyCountMap.put(key, dailyCountMap.getOrDefault(key, 0) + 1);
            }

            String status = StringUtils.trimToEmpty(item.getStatus());
            if ("pending".equalsIgnoreCase(status))
            {
                pending++;
            }
            else if ("confirmed".equalsIgnoreCase(status))
            {
                confirmed++;
            }
            else if ("completed".equalsIgnoreCase(status))
            {
                completed++;
            }
            else if ("cancelled".equalsIgnoreCase(status))
            {
                cancelled++;
            }
            else if ("expired".equalsIgnoreCase(status))
            {
                expired++;
            }
        }

        List<Map<String, Object>> dailyStats = new ArrayList<Map<String, Object>>();
        for (Map.Entry<String, Integer> entry : dailyCountMap.entrySet())
        {
            Map<String, Object> point = new HashMap<String, Object>();
            point.put("date", entry.getKey());
            point.put("count", entry.getValue());
            dailyStats.add(point);
        }

        Map<String, Object> stats = new HashMap<>();
        stats.put("total", pending + confirmed + completed + cancelled + expired);
        stats.put("today", today);
        stats.put("pending", pending);
        stats.put("confirmed", confirmed);
        stats.put("completed", completed);
        stats.put("cancelled", cancelled);
        stats.put("expired", expired);
        stats.put("dailyStats", dailyStats);
        return stats;
    }

    private Map<String, Object> buildInventoryStats()
    {
        List<ClinicMedicine> medicines = clinicMedicineService.selectClinicMedicineList(new ClinicMedicine());
        List<ClinicMedicine> medicineList = medicines != null ? medicines : new ArrayList<ClinicMedicine>();

        long totalStockQuantity = 0L;
        BigDecimal totalStockValue = BigDecimal.ZERO;
        for (ClinicMedicine medicine : medicineList)
        {
            if (medicine == null)
            {
                continue;
            }
            int stock = medicine.getStock() != null ? medicine.getStock() : 0;
            BigDecimal price = medicine.getPrice() != null ? medicine.getPrice() : BigDecimal.ZERO;
            totalStockQuantity += Math.max(stock, 0);
            totalStockValue = totalStockValue.add(price.multiply(BigDecimal.valueOf(Math.max(stock, 0))));
        }

        Map<String, Object> stats = new HashMap<>();
        stats.put("medicineCount", medicineList.size());
        stats.put("lowStockCount", clinicMedicineService.countLowStockMedicine());
        stats.put("totalStockQuantity", totalStockQuantity);
        stats.put("totalStockValue", totalStockValue.setScale(2, RoundingMode.HALF_UP));
        return stats;
    }

    private Map<String, Object> buildNearExpiryStats()
    {
        List<Map<String, Object>> rows = clinicStockRecordService.selectNearExpiryBatchWarnings(30, null, null);
        List<Map<String, Object>> nearExpiryRows = rows != null ? rows : new ArrayList<Map<String, Object>>();

        long nearExpiryQuantity = 0L;
        long expiredQuantity = 0L;
        int expiredBatchCount = 0;
        for (Map<String, Object> item : nearExpiryRows)
        {
            int remainingQuantity = toInt(item.get("remainingQuantity"));
            nearExpiryQuantity += Math.max(remainingQuantity, 0);

            long daysToExpiry = toLong(item.get("daysToExpiry"));
            if (daysToExpiry < 0)
            {
                expiredBatchCount++;
                expiredQuantity += Math.max(remainingQuantity, 0);
            }
        }

        Map<String, Object> stats = new HashMap<>();
        stats.put("thresholdDays", 30);
        stats.put("nearExpiryBatchCount", nearExpiryRows.size());
        stats.put("nearExpiryQuantity", nearExpiryQuantity);
        stats.put("expiredBatchCount", expiredBatchCount);
        stats.put("expiredQuantity", expiredQuantity);
        return stats;
    }

    private Map<String, Object> buildAiInvocationStats(LocalDate rangeStart, LocalDate rangeEnd, String dimension)
    {
        String startTime = rangeStart != null ? rangeStart.toString() + " 00:00:00" : null;
        String endTime = rangeEnd != null ? rangeEnd.toString() + " 23:59:59" : null;
        List<JSONObject> logs = aiInvocationLogService.latest(AI_LOG_LIMIT, null, null, null, startTime, endTime);
        List<JSONObject> logList = logs != null ? logs : new ArrayList<JSONObject>();

        int successCount = 0;
        int failedCount = 0;
        long totalDurationMs = 0L;
        Map<String, Integer> sceneCountMap = new HashMap<>();
        Map<String, Integer> modelCountMap = new HashMap<>();
        Map<String, Map<String, Integer>> dailyCountMap = new TreeMap<String, Map<String, Integer>>();

        for (JSONObject item : logList)
        {
            if (item == null)
            {
                continue;
            }

            boolean success = item.getBooleanValue("success");
            if (success)
            {
                successCount++;
            }
            else
            {
                failedCount++;
            }

            long duration = item.getLongValue("durationMs");
            if (duration > 0)
            {
                totalDurationMs += duration;
            }

            LocalDateTime logTime = parseLocalDateTime(item.getString("time"));
            if (logTime != null)
            {
                String dayKey = resolveDimensionKey(logTime.toLocalDate(), dimension);
                Map<String, Integer> dayStats = dailyCountMap.get(dayKey);
                if (dayStats == null)
                {
                    dayStats = new HashMap<String, Integer>();
                    dayStats.put("success", 0);
                    dayStats.put("failed", 0);
                    dailyCountMap.put(dayKey, dayStats);
                }
                if (success)
                {
                    dayStats.put("success", dayStats.getOrDefault("success", 0) + 1);
                }
                else
                {
                    dayStats.put("failed", dayStats.getOrDefault("failed", 0) + 1);
                }
            }

            String scene = item.getString("scene");
            if (StringUtils.isEmpty(scene))
            {
                scene = "未知";
            }
            sceneCountMap.put(scene, sceneCountMap.getOrDefault(scene, 0) + 1);

            String model = item.getString("model");
            if (StringUtils.isEmpty(model))
            {
                model = "未知";
            }
            modelCountMap.put(model, modelCountMap.getOrDefault(model, 0) + 1);
        }

        long avgDurationMs = logList.isEmpty() ? 0L : totalDurationMs / logList.size();
        List<Map<String, Object>> dailyStats = new ArrayList<Map<String, Object>>();
        for (Map.Entry<String, Map<String, Integer>> entry : dailyCountMap.entrySet())
        {
            Map<String, Integer> row = entry.getValue();
            Map<String, Object> point = new HashMap<String, Object>();
            point.put("date", entry.getKey());
            point.put("success", row.getOrDefault("success", 0));
            point.put("failed", row.getOrDefault("failed", 0));
            point.put("total", row.getOrDefault("success", 0) + row.getOrDefault("failed", 0));
            dailyStats.add(point);
        }

        Map<String, Object> stats = new HashMap<>();
        stats.put("sampleSize", logList.size());
        stats.put("successCount", successCount);
        stats.put("failedCount", failedCount);
        stats.put("successRate", logList.isEmpty() ? 0D : roundPercent((double) successCount * 100D / logList.size()));
        stats.put("avgDurationMs", avgDurationMs);
        stats.put("sceneCountMap", sceneCountMap);
        stats.put("modelCountMap", modelCountMap);
        stats.put("dailyStats", dailyStats);
        return stats;
    }

    private String normalizeDimension(String dimension)
    {
        String normalized = StringUtils.trimToEmpty(dimension).toLowerCase();
        if (StringUtils.isEmpty(normalized))
        {
            return "day";
        }
        if ("day".equals(normalized) || "week".equals(normalized) || "month".equals(normalized))
        {
            return normalized;
        }
        return null;
    }

    private String resolveDimensionKey(LocalDate date, String dimension)
    {
        if (date == null)
        {
            return "";
        }
        if ("month".equals(dimension))
        {
            return String.format("%d-%02d", date.getYear(), date.getMonthValue());
        }
        if ("week".equals(dimension))
        {
            LocalDate monday = date.minusDays(date.getDayOfWeek().getValue() - 1);
            return monday.toString() + " 所在周";
        }
        return date.toString();
    }

    private LocalDate parseLocalDate(String value)
    {
        if (StringUtils.isEmpty(value))
        {
            return null;
        }
        try
        {
            return LocalDate.parse(value.trim());
        }
        catch (Exception ignored)
        {
            return null;
        }
    }

    private LocalDate parseLocalDate(Date value)
    {
        if (value == null)
        {
            return null;
        }
        try
        {
            return value.toInstant().atZone(ZoneId.systemDefault()).toLocalDate();
        }
        catch (Exception ignored)
        {
            return null;
        }
    }

    private LocalDateTime parseLocalDateTime(String value)
    {
        if (StringUtils.isEmpty(value))
        {
            return null;
        }
        try
        {
            return LocalDateTime.parse(value.trim(), AI_TIME_FORMATTER);
        }
        catch (Exception ignored)
        {
            return null;
        }
    }

    private boolean isDateInRange(LocalDate date, LocalDate start, LocalDate end)
    {
        if (date == null)
        {
            return false;
        }
        if (start != null && date.isBefore(start))
        {
            return false;
        }
        if (end != null && date.isAfter(end))
        {
            return false;
        }
        return true;
    }

    private double roundPercent(double value)
    {
        return BigDecimal.valueOf(value).setScale(2, RoundingMode.HALF_UP).doubleValue();
    }

    private int toInt(Object value)
    {
        if (value == null)
        {
            return 0;
        }
        if (value instanceof Number)
        {
            return ((Number) value).intValue();
        }
        try
        {
            return Integer.parseInt(String.valueOf(value).trim());
        }
        catch (Exception ignored)
        {
            return 0;
        }
    }

    private long toLong(Object value)
    {
        if (value == null)
        {
            return 0L;
        }
        if (value instanceof Number)
        {
            return ((Number) value).longValue();
        }
        try
        {
            return Long.parseLong(String.valueOf(value).trim());
        }
        catch (Exception ignored)
        {
            return 0L;
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
