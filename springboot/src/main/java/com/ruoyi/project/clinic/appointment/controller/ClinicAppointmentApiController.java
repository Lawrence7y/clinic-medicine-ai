package com.ruoyi.project.clinic.appointment.controller;

import com.github.pagehelper.PageHelper;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.security.ShiroUtils;
import com.ruoyi.framework.web.controller.BaseController;
import com.ruoyi.framework.web.domain.AjaxResult;
import com.ruoyi.framework.web.page.TableDataInfo;
import com.ruoyi.project.clinic.audit.service.AuditTrailService;
import com.ruoyi.project.clinic.appointment.domain.ClinicAppointment;
import com.ruoyi.project.clinic.appointment.domain.ClinicAppointmentSubscription;
import com.ruoyi.project.clinic.appointment.service.IClinicAppointmentService;
import com.ruoyi.project.clinic.common.ClinicSecuritySupport;
import com.ruoyi.project.clinic.config.service.ClinicConfigSupportService;
import com.ruoyi.project.clinic.patient.domain.ClinicPatient;
import com.ruoyi.project.clinic.patient.service.IClinicPatientService;
import com.ruoyi.project.system.role.service.IRoleService;
import com.ruoyi.project.system.user.domain.User;
import com.ruoyi.project.system.user.service.IUserService;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.apache.shiro.authz.annotation.RequiresPermissions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
@RequestMapping("/api/clinic/appointment")
public class ClinicAppointmentApiController extends BaseController
{
    private static final int PATIENT_CANCEL_MINUTES_BEFORE = 120;

    @Autowired
    private IClinicAppointmentService clinicAppointmentService;

    @Autowired
    private IRoleService roleService;

    @Autowired
    private IUserService userService;

    @Autowired
    private IClinicPatientService clinicPatientService;

    @Autowired(required = false)
    private ClinicConfigSupportService clinicConfigSupportService;

    @Autowired
    private AuditTrailService auditTrailService;

    @PostMapping("/list")
    @ResponseBody
    public TableDataInfo list(@RequestBody(required = false) ClinicAppointmentQuery query)
    {
        if (query == null)
        {
            query = new ClinicAppointmentQuery();
        }

        User currentUser = currentUser();
        if (currentUser != null)
        {
            Set<String> roleKeys = getRoleKeys(currentUser);
            if (ClinicSecuritySupport.isPatient(roleKeys))
            {
                Long patientId = resolveCurrentPatientProfileId(currentUser, roleKeys);
                if (patientId == null)
                {
                    return emptyTable();
                }
                query.setDoctorId(null);
                query.setPatientId(patientId);
            }
            else if (ClinicSecuritySupport.isDoctor(roleKeys) && !ClinicSecuritySupport.isAdmin(roleKeys))
            {
                query.setDoctorId(currentUser.getUserId());
            }
        }

        int pageNum = query.getPageNum() != null ? query.getPageNum() : 1;
        int pageSize = query.getPageSize() != null ? query.getPageSize() : 10;
        if (pageSize > 200)
        {
            pageSize = 200;
        }
        PageHelper.startPage(pageNum, pageSize);
        PageHelper.orderBy("create_time DESC, appointment_id DESC");

        ClinicAppointment criteria = new ClinicAppointment();
        criteria.setPatientId(query.getPatientId());
        criteria.setDoctorId(query.getDoctorId());
        criteria.setStatus(query.getStatus());
        criteria.setAppointmentDate(DateUtils.parseDate(query.getAppointmentDate()));
        criteria.setPatientName(query.getPatientName());
        criteria.setDoctorName(query.getDoctorName());

        List<ClinicAppointment> list = clinicAppointmentService.selectClinicAppointmentList(criteria);
        return getDataTable(list);
    }

    @GetMapping("/getInfo")
    @ResponseBody
    public AjaxResult getInfo(@RequestParam Long appointmentId)
    {
        ClinicAppointment appointment = clinicAppointmentService.selectClinicAppointmentById(appointmentId);
        if (appointment == null)
        {
            return AjaxResult.error("预约不存在");
        }

        User currentUser = currentUser();
        if (currentUser != null)
        {
            Set<String> roleKeys = getRoleKeys(currentUser);
            if (ClinicSecuritySupport.isPatient(roleKeys))
            {
                Long patientId = resolveCurrentPatientProfileId(currentUser, roleKeys);
                if (patientId == null || !patientId.equals(appointment.getPatientId()))
                {
                    return forbiddenAjax("无权限访问");
                }
            }
            else if (ClinicSecuritySupport.isDoctor(roleKeys) && !ClinicSecuritySupport.isAdmin(roleKeys))
            {
                if (appointment.getDoctorId() != null && !appointment.getDoctorId().equals(currentUser.getUserId()))
                {
                    return forbiddenAjax("无权限访问");
                }
            }
        }

        return AjaxResult.success(appointment);
    }

    @PostMapping("/add")
    @ResponseBody
    @RequiresPermissions("clinic:appointment:add")
    public AjaxResult addSave(@RequestBody ClinicAppointment clinicAppointment)
    {
        AjaxResult disabled = appointmentDisabled();
        if (disabled != null)
        {
            return disabled;
        }

        User currentUser = currentUser();
        if (currentUser == null)
        {
            return AjaxResult.error("请先登录");
        }

        Set<String> roleKeys = getRoleKeys(currentUser);
        boolean isAdmin = ClinicSecuritySupport.isAdmin(roleKeys);
        boolean isDoctor = ClinicSecuritySupport.isDoctor(roleKeys);
        boolean isPatient = ClinicSecuritySupport.isPatient(roleKeys);
        if (!isAdmin && !isDoctor && !isPatient)
        {
            return forbiddenAjax("无权限访问");
        }

        if (isPatient)
        {
            Long patientId = resolveCurrentPatientProfileId(currentUser, roleKeys);
            if (patientId == null)
            {
                return AjaxResult.error("患者档案不存在");
            }
            clinicAppointment.setPatientId(patientId);
            clinicAppointment.setPatientPhone(currentUser.getPhonenumber());
        }

        int rows = clinicAppointmentService.insertClinicAppointment(clinicAppointment);
        if (rows <= 0)
        {
            return AjaxResult.error("创建预约失败");
        }

        Map<String, Object> data = new HashMap<>();
        data.put("appointmentId", clinicAppointment.getAppointmentId());
        data.put("sequenceNumber", clinicAppointment.getSequenceNumber());
        auditTrailService.record(
            "appointment",
            "create",
            clinicAppointment.getAppointmentId() != null ? String.valueOf(clinicAppointment.getAppointmentId()) : "-",
            "创建预约：" + StringUtils.defaultString(clinicAppointment.getAppointmentDate() != null ? clinicAppointment.getAppointmentDate().toString() : "-", "-")
        );
        return AjaxResult.success(data);
    }

    @PostMapping("/offlineAdd")
    @ResponseBody
    public AjaxResult offlineAdd(@RequestBody(required = false) Map<String, Object> params)
    {
        AjaxResult disabled = appointmentDisabled();
        if (disabled != null)
        {
            return disabled;
        }

        User currentUser = currentUser();
        if (currentUser == null)
        {
            return AjaxResult.error("请先登录");
        }

        Set<String> roleKeys = getRoleKeys(currentUser);
        boolean allowed = ClinicSecuritySupport.isDoctor(roleKeys) || ClinicSecuritySupport.isAdmin(roleKeys);
        if (!allowed)
        {
            return forbiddenAjax("无权限访问");
        }
        if (params == null)
        {
            return AjaxResult.error("参数错误");
        }

        Long scheduleId = parseLong(params.get("scheduleId"));
        String patientPhone = stringValue(params.get("patientPhone"));
        String patientName = stringValue(params.get("patientName"));
        if (scheduleId == null || StringUtils.isEmpty(patientPhone))
        {
            return AjaxResult.error("参数错误");
        }

        User patientUser = userService.selectUserByPhoneNumber(patientPhone);
        if (patientUser == null)
        {
            return AjaxResult.error("未找到患者账号");
        }

        ClinicPatient patient = clinicPatientService.selectClinicPatientByUserId(patientUser.getUserId());
        if (patient == null || patient.getPatientId() == null)
        {
            return AjaxResult.error("患者档案不存在");
        }

        ClinicAppointment appointment = new ClinicAppointment();
        appointment.setScheduleId(scheduleId);
        appointment.setPatientId(patient.getPatientId());
        appointment.setPatientPhone(patientPhone);
        appointment.setPatientName(StringUtils.isNotEmpty(patientName) ? patientName : patientUser.getUserName());
        appointment.setStatus("pending");

        int rows = clinicAppointmentService.insertClinicAppointment(appointment);
        if (rows <= 0)
        {
            return AjaxResult.error("创建预约失败");
        }

        Map<String, Object> data = new HashMap<>();
        data.put("appointmentId", appointment.getAppointmentId());
        data.put("sequenceNumber", appointment.getSequenceNumber());
        auditTrailService.record(
            "appointment",
            "offline_create",
            appointment.getAppointmentId() != null ? String.valueOf(appointment.getAppointmentId()) : "-",
            "线下加号：" + StringUtils.defaultString(appointment.getAppointmentDate() != null ? appointment.getAppointmentDate().toString() : "-", "-")
        );
        return AjaxResult.success(data);
    }

    @PostMapping("/edit")
    @ResponseBody
    public AjaxResult editSave(@RequestBody ClinicAppointment clinicAppointment)
    {
        AjaxResult disabled = appointmentDisabled();
        if (disabled != null)
        {
            return disabled;
        }

        User currentUser = currentUser();
        if (currentUser == null)
        {
            return AjaxResult.error("请先登录");
        }

        Set<String> roleKeys = getRoleKeys(currentUser);
        boolean isAdmin = ClinicSecuritySupport.isAdmin(roleKeys);
        boolean isDoctor = ClinicSecuritySupport.isDoctor(roleKeys);
        boolean isPatient = ClinicSecuritySupport.isPatient(roleKeys);
        if (!isAdmin && !isDoctor && !isPatient)
        {
            return forbiddenAjax("无权限访问");
        }
        if (clinicAppointment.getAppointmentId() == null)
        {
            return AjaxResult.error("参数错误");
        }

        ClinicAppointment old = clinicAppointmentService.selectClinicAppointmentById(clinicAppointment.getAppointmentId());
        if (old == null)
        {
            return AjaxResult.error("预约不存在");
        }
        if (isDoctor && !isAdmin && old.getDoctorId() != null && !old.getDoctorId().equals(currentUser.getUserId()))
        {
            return forbiddenAjax("无权限访问");
        }
        if (isPatient)
        {
            Long patientId = resolveCurrentPatientProfileId(currentUser, roleKeys);
            if (patientId == null || (old.getPatientId() != null && !old.getPatientId().equals(patientId)))
            {
                return forbiddenAjax("无权限访问");
            }
            if (!"cancelled".equals(clinicAppointment.getStatus()))
            {
                return AjaxResult.error("患者仅可取消自己的预约");
            }
            if ("completed".equals(old.getStatus()) || "cancelled".equals(old.getStatus()) || "expired".equals(old.getStatus()))
            {
                return AjaxResult.error("当前预约状态不可取消");
            }
            if (old.getCalled() != null && old.getCalled() == 1)
            {
                return AjaxResult.error("已叫号预约不支持线上取消，请联系医生处理");
            }
            if (isWithinPatientCancellationWindow(old, resolvePatientCancelAdvanceMinutes()))
            {
                return AjaxResult.error("就诊前2小时内不可取消，请联系医生处理");
            }
            clinicAppointment.setPatientId(old.getPatientId());
            clinicAppointment.setDoctorId(old.getDoctorId());
        }

        try
        {
            if ("completed".equals(clinicAppointment.getStatus()) && !"completed".equals(old.getStatus()))
            {
                boolean success = clinicAppointmentService.completeAppointment(clinicAppointment.getAppointmentId());
                if (success)
                {
                    auditTrailService.record(
                        "appointment",
                        "complete",
                        String.valueOf(clinicAppointment.getAppointmentId()),
                        "完成就诊"
                    );
                }
                return success ? AjaxResult.success() : AjaxResult.error("完成就诊失败");
            }

            int rows = clinicAppointmentService.updateClinicAppointment(clinicAppointment);
            if (rows > 0)
            {
                String nextStatus = StringUtils.defaultString(clinicAppointment.getStatus(), old.getStatus());
                auditTrailService.record(
                    "appointment",
                    "update",
                    String.valueOf(clinicAppointment.getAppointmentId()),
                    "状态：" + StringUtils.defaultString(old.getStatus(), "-") + " -> " + StringUtils.defaultString(nextStatus, "-")
                );
            }
            return toAjax(rows);
        }
        catch (RuntimeException ex)
        {
            return AjaxResult.error(ex.getMessage());
        }
    }

    @PostMapping("/remove")
    @ResponseBody
    @RequiresPermissions("clinic:appointment:remove")
    public AjaxResult remove(@RequestBody(required = false) Map<String, String> params)
    {
        AjaxResult disabled = appointmentDisabled();
        if (disabled != null)
        {
            return disabled;
        }

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

        String ids = params != null ? params.get("ids") : null;
        if (StringUtils.isEmpty(ids))
        {
            return AjaxResult.error("请提供要删除的预约ID");
        }

        Long[] appointmentIds = Arrays.stream(ids.split(","))
            .map(String::trim)
            .filter(StringUtils::isNotEmpty)
            .map(Long::valueOf)
            .toArray(Long[]::new);
        int rows = clinicAppointmentService.deleteClinicAppointmentByIds(appointmentIds);
        if (rows > 0)
        {
            auditTrailService.record(
                "appointment",
                "delete",
                ids,
                "删除预约ID：" + ids
            );
        }
        return toAjax(rows);
    }

    @PostMapping("/{id}/call")
    @ResponseBody
    public AjaxResult callAppointment(@PathVariable("id") Long appointmentId)
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
        if (ClinicSecuritySupport.isDoctor(roleKeys) && !ClinicSecuritySupport.isAdmin(roleKeys))
        {
            ClinicAppointment appointment = clinicAppointmentService.selectClinicAppointmentById(appointmentId);
            if (appointment == null)
            {
                return AjaxResult.error("预约不存在");
            }
            if (appointment.getDoctorId() != null && !appointment.getDoctorId().equals(currentUser.getUserId()))
            {
                return forbiddenAjax("无权限访问");
            }
        }

        try
        {
            clinicAppointmentService.callAppointment(appointmentId);
            auditTrailService.record("appointment", "call", String.valueOf(appointmentId), "执行叫号");
            return AjaxResult.success("叫号成功");
        }
        catch (RuntimeException ex)
        {
            return AjaxResult.error(ex.getMessage());
        }
    }

    @PostMapping("/{id}/complete")
    @ResponseBody
    public AjaxResult completeAppointment(@PathVariable("id") Long appointmentId)
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
        if (ClinicSecuritySupport.isDoctor(roleKeys) && !ClinicSecuritySupport.isAdmin(roleKeys))
        {
            ClinicAppointment appointment = clinicAppointmentService.selectClinicAppointmentById(appointmentId);
            if (appointment == null)
            {
                return AjaxResult.error("预约不存在");
            }
            if (appointment.getDoctorId() != null && !appointment.getDoctorId().equals(currentUser.getUserId()))
            {
                return forbiddenAjax("无权限访问");
            }
        }

        try
        {
            clinicAppointmentService.completeAppointment(appointmentId);
            auditTrailService.record("appointment", "complete", String.valueOf(appointmentId), "完成就诊");
            return AjaxResult.success("完成就诊成功");
        }
        catch (RuntimeException ex)
        {
            return AjaxResult.error(ex.getMessage());
        }
    }

    @GetMapping("/queue")
    @ResponseBody
    public AjaxResult getQueue(@RequestParam Long doctorId, @RequestParam String date)
    {
        User currentUser = currentUser();
        if (currentUser == null)
        {
            return AjaxResult.error("请先登录");
        }

        Set<String> roleKeys = getRoleKeys(currentUser);
        if (ClinicSecuritySupport.isPatient(roleKeys))
        {
            Long patientId = resolveCurrentPatientProfileId(currentUser, roleKeys);
            if (patientId == null)
            {
                return forbiddenAjax("无权限访问");
            }

            ClinicAppointment selfAppointment = findSelfAppointment(patientId, doctorId, date);
            if (selfAppointment == null)
            {
                return forbiddenAjax("无权限访问");
            }

            Map<String, Object> result = new HashMap<>();
            result.put("appointmentId", selfAppointment.getAppointmentId());
            result.put("position", clinicAppointmentService.getQueuePosition(selfAppointment.getAppointmentId()));
            result.put("queue", Collections.emptyList());
            return AjaxResult.success(result);
        }

        if (ClinicSecuritySupport.isDoctor(roleKeys) && !ClinicSecuritySupport.isAdmin(roleKeys)
            && !doctorId.equals(currentUser.getUserId()))
        {
            return forbiddenAjax("无权限访问");
        }
        if (!ClinicSecuritySupport.isAdmin(roleKeys) && !ClinicSecuritySupport.isDoctor(roleKeys))
        {
            return forbiddenAjax("无权限访问");
        }

        List<ClinicAppointment> queue = clinicAppointmentService.getQueueByDoctorAndDate(doctorId, date);
        Map<String, Object> result = buildQueueResult(queue);
        return AjaxResult.success(result);
    }

    @GetMapping("/position")
    @ResponseBody
    public AjaxResult getPosition(@RequestParam(required = false) Long appointmentId,
        @RequestParam(required = false) Long doctorId,
        @RequestParam(required = false) String date)
    {
        User currentUser = currentUser();
        if (currentUser == null)
        {
            return AjaxResult.error("请先登录");
        }
        if (appointmentId == null && (doctorId == null || date == null))
        {
            return AjaxResult.error("参数错误");
        }

        Set<String> roleKeys = getRoleKeys(currentUser);
        Long targetAppointmentId = appointmentId;

        if (targetAppointmentId == null)
        {
            if (!ClinicSecuritySupport.isPatient(roleKeys))
            {
                return forbiddenAjax("无权限访问");
            }

            Long patientId = resolveCurrentPatientProfileId(currentUser, roleKeys);
            if (patientId == null)
            {
                return forbiddenAjax("无权限访问");
            }

            ClinicAppointment selfAppointment = findSelfAppointment(patientId, doctorId, date);
            if (selfAppointment == null)
            {
                return AjaxResult.error("预约不存在");
            }
            targetAppointmentId = selfAppointment.getAppointmentId();
        }
        else
        {
            ClinicAppointment appointment = clinicAppointmentService.selectClinicAppointmentById(targetAppointmentId);
            if (appointment == null)
            {
                return AjaxResult.error("预约不存在");
            }

            if (ClinicSecuritySupport.isPatient(roleKeys))
            {
                Long patientId = resolveCurrentPatientProfileId(currentUser, roleKeys);
                if (patientId == null || !patientId.equals(appointment.getPatientId()))
                {
                    return forbiddenAjax("无权限访问");
                }
            }
            else if (ClinicSecuritySupport.isDoctor(roleKeys) && !ClinicSecuritySupport.isAdmin(roleKeys))
            {
                if (appointment.getDoctorId() != null && !appointment.getDoctorId().equals(currentUser.getUserId()))
                {
                    return forbiddenAjax("无权限访问");
                }
            }
            else if (!ClinicSecuritySupport.isAdmin(roleKeys) && !ClinicSecuritySupport.isDoctor(roleKeys))
            {
                return forbiddenAjax("无权限访问");
            }
        }

        Map<String, Object> result = new HashMap<>();
        result.put("position", clinicAppointmentService.getQueuePosition(targetAppointmentId));
        result.put("appointmentId", targetAppointmentId);
        return AjaxResult.success(result);
    }

    private AjaxResult appointmentDisabled()
    {
        return null;
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

        int updated = clinicAppointmentService.syncDoctorName(doctorId, doctorName);
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
        Long currentPatientId = resolveCurrentPatientProfileId(currentUser, roleKeys);
        boolean isSelfPatient = ClinicSecuritySupport.isPatient(roleKeys)
            && currentPatientId != null
            && currentPatientId.equals(patientId);
        if (!ClinicSecuritySupport.isAdmin(roleKeys) && !isSelfPatient)
        {
            return forbiddenAjax("无权限访问");
        }

        int updated = clinicAppointmentService.syncPatientInfo(patientId, patientName, patientPhone);
        return AjaxResult.success("更新成功", updated);
    }

    @GetMapping("/reminders")
    @ResponseBody
    public AjaxResult reminders()
    {
        User currentUser = currentUser();
        if (currentUser == null)
        {
            return AjaxResult.error("请先登录");
        }

        Set<String> roleKeys = getRoleKeys(currentUser);
        Long patientId = null;
        Long doctorId = null;
        if (ClinicSecuritySupport.isPatient(roleKeys))
        {
            patientId = resolveCurrentPatientProfileId(currentUser, roleKeys);
            if (patientId == null)
            {
                return AjaxResult.success(Collections.emptyList());
            }
        }
        else if (ClinicSecuritySupport.isDoctor(roleKeys))
        {
            doctorId = currentUser.getUserId();
        }
        else if (!ClinicSecuritySupport.isAdmin(roleKeys))
        {
            return AjaxResult.success(Collections.emptyList());
        }

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        LocalDate today = LocalDate.now();
        LocalDate start = today.minusDays(7);
        LocalDate end = today.plusDays(7);

        List<ClinicAppointment> rawList = clinicAppointmentService.selectUpcomingAppointments(
            patientId, doctorId, start.format(formatter), end.format(formatter));
        if (rawList == null)
        {
            rawList = new ArrayList<>();
        }

        ClinicAppointment cancelQuery = new ClinicAppointment();
        cancelQuery.setPatientId(patientId);
        cancelQuery.setDoctorId(doctorId);
        List<ClinicAppointment> allHistory = clinicAppointmentService.selectClinicAppointmentList(cancelQuery);
        if (allHistory != null && !allHistory.isEmpty())
        {
            for (ClinicAppointment item : allHistory)
            {
                if (item == null || !"cancelled".equals(item.getStatus()) || item.getUpdateTime() == null)
                {
                    continue;
                }
                LocalDate updateDate = item.getUpdateTime().toInstant().atZone(ZoneId.systemDefault()).toLocalDate();
                if (updateDate.isBefore(today.minusDays(7)))
                {
                    continue;
                }
                boolean exists = false;
                for (ClinicAppointment existing : rawList)
                {
                    if (existing != null && existing.getAppointmentId() != null
                        && existing.getAppointmentId().equals(item.getAppointmentId()))
                    {
                        exists = true;
                        break;
                    }
                }
                if (!exists)
                {
                    rawList.add(item);
                }
            }
        }

        List<Map<String, Object>> reminderList = buildReminderEvents(rawList, roleKeys);
        return AjaxResult.success(reminderList);
    }

    @GetMapping("/todo")
    @ResponseBody
    public AjaxResult todo()
    {
        User currentUser = currentUser();
        if (currentUser == null)
        {
            return AjaxResult.error("请先登录");
        }

        Set<String> roleKeys = getRoleKeys(currentUser);
        if (!ClinicSecuritySupport.isDoctor(roleKeys) && !ClinicSecuritySupport.isAdmin(roleKeys))
        {
            return forbiddenAjax("无权限访问");
        }

        Long doctorId = ClinicSecuritySupport.isDoctor(roleKeys) && !ClinicSecuritySupport.isAdmin(roleKeys)
            ? currentUser.getUserId()
            : null;

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        LocalDate today = LocalDate.now();
        String todayText = today.format(formatter);
        String tomorrowText = today.plusDays(1).format(formatter);

        List<ClinicAppointment> list = clinicAppointmentService.selectUpcomingAppointments(
            null, doctorId, todayText, tomorrowText);
        if (list == null)
        {
            list = new ArrayList<>();
        }

        int pendingCount = 0;
        int confirmedCount = 0;
        int todayCount = 0;
        int nearVisitCount = 0;
        LocalDateTime now = LocalDateTime.now();

        List<Map<String, Object>> todoItems = new ArrayList<>();
        for (ClinicAppointment item : list)
        {
            if (item == null) continue;
            String status = item.getStatus();
            if ("pending".equals(status)) pendingCount++;
            if ("confirmed".equals(status)) confirmedCount++;
            if (isAppointmentDate(item, today)) todayCount++;
            if ("confirmed".equals(status) && isWithinHours(item, now, 2)) nearVisitCount++;

            if ("pending".equals(status) || ("confirmed".equals(status) && isWithinHours(item, now, 2)))
            {
                Map<String, Object> todo = toReminderItem(item, "doctor_todo", "医生待办");
                todo.put("todoType", "pending".equals(status) ? "confirm" : "prepare");
                todoItems.add(todo);
            }
        }

        todoItems.sort(Comparator.comparing(o -> String.valueOf(o.getOrDefault("appointmentDate", ""))));
        if (todoItems.size() > 20)
        {
            todoItems = todoItems.subList(0, 20);
        }

        Map<String, Object> data = new HashMap<>();
        data.put("pendingCount", pendingCount);
        data.put("confirmedCount", confirmedCount);
        data.put("todayCount", todayCount);
        data.put("nearVisitCount", nearVisitCount);
        data.put("todoList", todoItems);
        return AjaxResult.success(data);
    }

    @GetMapping("/coming")
    @ResponseBody
    public AjaxResult getComingAppointments()
    {
        User currentUser = currentUser();
        if (currentUser == null)
        {
            return AjaxResult.error("请先登录");
        }

        Set<String> roleKeys = getRoleKeys(currentUser);
        if (!ClinicSecuritySupport.isPatient(roleKeys))
        {
            return AjaxResult.success(Collections.emptyList());
        }

        Long patientId = resolveCurrentPatientProfileId(currentUser, roleKeys);
        if (patientId == null)
        {
            return AjaxResult.success(Collections.emptyList());
        }

        LocalDate today = LocalDate.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        List<ClinicAppointment> list = clinicAppointmentService.getCalledAppointments(patientId, today.format(formatter));
        return AjaxResult.success(list);
    }

    @GetMapping("/subscription")
    @ResponseBody
    public AjaxResult getSubscription()
    {
        User currentUser = currentUser();
        if (currentUser == null)
        {
            return AjaxResult.error("请先登录");
        }

        ClinicAppointmentSubscription subscription = clinicAppointmentService.getSubscriptionByUserId(currentUser.getUserId());
        return AjaxResult.success(subscription);
    }

    @PostMapping("/subscription/save")
    @ResponseBody
    public AjaxResult saveSubscription(@RequestBody Map<String, Object> params)
    {
        User currentUser = currentUser();
        if (currentUser == null)
        {
            return AjaxResult.error("请先登录");
        }

        ClinicAppointmentSubscription subscription = new ClinicAppointmentSubscription();
        subscription.setUserId(currentUser.getUserId());
        if (params.containsKey("appointmentReminder"))
        {
            subscription.setAppointmentReminder("true".equals(String.valueOf(params.get("appointmentReminder"))) ? 1 : 0);
        }
        if (params.containsKey("remindDaysBefore"))
        {
            subscription.setRemindDaysBefore(Integer.valueOf(String.valueOf(params.get("remindDaysBefore"))));
        }
        if (params.containsKey("templateId"))
        {
            subscription.setTemplateId(String.valueOf(params.get("templateId")));
        }
        if (params.containsKey("subscribeStatus"))
        {
            subscription.setSubscribeStatus(String.valueOf(params.get("subscribeStatus")));
        }
        if (params.containsKey("openid"))
        {
            subscription.setOpenid(String.valueOf(params.get("openid")));
        }

        clinicAppointmentService.saveOrUpdateSubscription(subscription);
        return AjaxResult.success();
    }

    private User currentUser()
    {
        return ShiroUtils.getSysUser();
    }

    private Set<String> getRoleKeys(User user)
    {
        return ClinicSecuritySupport.getRoleKeys(user, roleService);
    }

    private Long resolveCurrentPatientProfileId(User currentUser, Set<String> roleKeys)
    {
        return ClinicSecuritySupport.resolvePatientProfileId(currentUser,
            ClinicSecuritySupport.normalizeRoleKeys(roleKeys), clinicPatientService);
    }

    private ClinicAppointment findSelfAppointment(Long patientId, Long doctorId, String date)
    {
        ClinicAppointment query = new ClinicAppointment();
        query.setPatientId(patientId);
        query.setDoctorId(doctorId);
        query.setAppointmentDate(DateUtils.parseDate(date));
        List<ClinicAppointment> appointments = clinicAppointmentService.selectClinicAppointmentList(query);
        return appointments != null && !appointments.isEmpty() ? appointments.get(0) : null;
    }

    private Map<String, Object> buildQueueResult(List<ClinicAppointment> queue)
    {
        Map<String, Object> result = new HashMap<>();
        result.put("total", queue != null ? queue.size() : 0);
        result.put("queue", queue != null ? queue : new ArrayList<>());

        Integer currentCalled = null;
        Integer nextSequence = null;
        if (queue != null)
        {
            for (ClinicAppointment appointment : queue)
            {
                if (appointment.getCalled() != null && appointment.getCalled() == 1)
                {
                    currentCalled = appointment.getSequenceNumber();
                    break;
                }
            }

            if (currentCalled != null)
            {
                for (ClinicAppointment appointment : queue)
                {
                    if (appointment.getSequenceNumber() != null
                        && appointment.getSequenceNumber() == currentCalled + 1)
                    {
                        nextSequence = appointment.getSequenceNumber();
                        break;
                    }
                }
            }
            else if (!queue.isEmpty() && queue.get(0).getSequenceNumber() != null)
            {
                nextSequence = queue.get(0).getSequenceNumber();
            }
        }

        result.put("currentCalled", currentCalled);
        result.put("nextSequence", nextSequence);
        return result;
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

    private TableDataInfo emptyTable()
    {
        TableDataInfo data = new TableDataInfo();
        data.setCode(0);
        data.setMsg("成功");
        data.setRows(new ArrayList<>());
        data.setTotal(0);
        return data;
    }

    private List<Map<String, Object>> buildReminderEvents(List<ClinicAppointment> source, Set<String> roleKeys)
    {
        if (source == null || source.isEmpty())
        {
            return Collections.emptyList();
        }

        boolean isPatient = ClinicSecuritySupport.isPatient(roleKeys);
        LocalDateTime now = LocalDateTime.now();
        List<Map<String, Object>> reminders = new ArrayList<>();

        for (ClinicAppointment item : source)
        {
            if (item == null)
            {
                continue;
            }
            String status = item.getStatus() == null ? "" : item.getStatus();
            if ("expired".equals(status))
            {
                continue;
            }

            LocalDateTime startAt = parseAppointmentStart(item);
            if ("cancelled".equals(status) && item.getUpdateTime() != null)
            {
                LocalDateTime updatedAt = LocalDateTime.ofInstant(
                    item.getUpdateTime().toInstant(), ZoneId.systemDefault());
                if (updatedAt.isAfter(now.minusDays(7)))
                {
                    reminders.add(toReminderItem(item, "appointment_cancelled", "预约已取消"));
                }
                continue;
            }

            if (!"pending".equals(status) && !"confirmed".equals(status))
            {
                continue;
            }

            if (item.getCreateTime() != null)
            {
                LocalDateTime createdAt = LocalDateTime.ofInstant(
                    item.getCreateTime().toInstant(), ZoneId.systemDefault());
                if (createdAt.isAfter(now.minusHours(24)) && (startAt == null || startAt.isAfter(now.minusHours(1))))
                {
                    reminders.add(toReminderItem(item, "appointment_created", "预约已创建"));
                }
            }

            if (item.getUpdateTime() != null && item.getCreateTime() != null
                && item.getUpdateTime().after(item.getCreateTime()))
            {
                LocalDateTime updatedAt = LocalDateTime.ofInstant(
                    item.getUpdateTime().toInstant(), ZoneId.systemDefault());
                if (updatedAt.isAfter(now.minusDays(7)))
                {
                    reminders.add(toReminderItem(item, "appointment_rescheduled", "预约已改期"));
                }
            }

            if ("confirmed".equals(status) && startAt != null && startAt.isAfter(now) && startAt.isBefore(now.plusHours(24)))
            {
                reminders.add(toReminderItem(item, "before_visit", isPatient ? "就诊前提醒" : "临近就诊提醒"));
            }
        }

        reminders.sort((a, b) -> String.valueOf(b.getOrDefault("createTime", ""))
            .compareTo(String.valueOf(a.getOrDefault("createTime", ""))));
        if (reminders.size() > 100)
        {
            return reminders.subList(0, 100);
        }
        return reminders;
    }

    private Map<String, Object> toReminderItem(ClinicAppointment item, String scene, String sceneText)
    {
        Map<String, Object> row = new HashMap<>();
        row.put("id", item.getAppointmentId());
        row.put("appointmentId", item.getAppointmentId());
        row.put("patientId", item.getPatientId());
        row.put("patientName", item.getPatientName());
        row.put("patientPhone", item.getPatientPhone());
        row.put("doctorId", item.getDoctorId());
        row.put("doctorName", item.getDoctorName());
        row.put("appointmentDate", item.getAppointmentDate());
        row.put("appointmentTime", item.getAppointmentTime());
        row.put("sequenceNumber", item.getSequenceNumber());
        row.put("status", item.getStatus());
        row.put("statusText", statusText(item.getStatus()));
        row.put("scene", scene);
        row.put("sceneText", sceneText);
        row.put("createTime", item.getCreateTime());
        row.put("updateTime", item.getUpdateTime());
        return row;
    }

    private String statusText(String status)
    {
        if ("pending".equals(status)) return "待确认";
        if ("confirmed".equals(status)) return "已确认";
        if ("completed".equals(status)) return "已完成";
        if ("cancelled".equals(status)) return "已取消";
        if ("expired".equals(status)) return "已过期";
        return status == null ? "-" : status;
    }

    private boolean isAppointmentDate(ClinicAppointment item, LocalDate date)
    {
        if (item == null || item.getAppointmentDate() == null || date == null) return false;
        LocalDate appointmentDate = item.getAppointmentDate().toInstant().atZone(ZoneId.systemDefault()).toLocalDate();
        return appointmentDate.equals(date);
    }

    private boolean isWithinHours(ClinicAppointment item, LocalDateTime now, int hours)
    {
        LocalDateTime startAt = parseAppointmentStart(item);
        return startAt != null && startAt.isAfter(now) && startAt.isBefore(now.plusHours(hours));
    }

    private LocalDateTime parseAppointmentStart(ClinicAppointment item)
    {
        if (item == null || item.getAppointmentDate() == null || StringUtils.isEmpty(item.getAppointmentTime()))
        {
            return null;
        }
        try
        {
            String appointmentTime = item.getAppointmentTime().trim();
            if (appointmentTime.contains("-"))
            {
                appointmentTime = appointmentTime.split("-")[0].trim();
            }
            if (appointmentTime.length() == 5)
            {
                appointmentTime = appointmentTime + ":00";
            }
            LocalDate appointmentDate = item.getAppointmentDate().toInstant().atZone(ZoneId.systemDefault()).toLocalDate();
            return LocalDateTime.of(appointmentDate, LocalTime.parse(appointmentTime));
        }
        catch (Exception ignored)
        {
            return null;
        }
    }

    private int resolvePatientCancelAdvanceMinutes()
    {
        try
        {
            if (clinicConfigSupportService != null)
            {
                int minutes = clinicConfigSupportService.getPatientCancelAdvanceMinutes();
                if (minutes >= 30 && minutes <= 24 * 60)
                {
                    return minutes;
                }
            }
        }
        catch (Exception ignored)
        {
            // fallback below
        }
        return PATIENT_CANCEL_MINUTES_BEFORE;
    }

    private boolean isWithinPatientCancellationWindow(ClinicAppointment appointment, int minMinutesBeforeStart)
    {
        if (appointment == null || appointment.getAppointmentDate() == null || StringUtils.isEmpty(appointment.getAppointmentTime()))
        {
            return false;
        }
        try
        {
            String startTimeText = appointment.getAppointmentTime();
            if (startTimeText.contains("-"))
            {
                startTimeText = startTimeText.split("-")[0];
            }
            startTimeText = startTimeText.trim();
            if (startTimeText.length() == 5)
            {
                startTimeText = startTimeText + ":00";
            }

            LocalDate appointmentDate = appointment.getAppointmentDate()
                .toInstant()
                .atZone(ZoneId.systemDefault())
                .toLocalDate();
            LocalTime appointmentStartTime = LocalTime.parse(startTimeText);
            LocalDateTime appointmentStartAt = LocalDateTime.of(appointmentDate, appointmentStartTime);
            LocalDateTime deadline = LocalDateTime.now().plusMinutes(minMinutesBeforeStart);
            return !deadline.isBefore(appointmentStartAt);
        }
        catch (Exception ignored)
        {
            return false;
        }
    }

    public static class ClinicAppointmentQuery
    {
        private Integer pageNum;
        private Integer pageSize;
        private Long patientId;
        private Long doctorId;
        private String status;
        private String appointmentDate;
        private String patientName;
        private String doctorName;

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

        public Long getDoctorId()
        {
            return doctorId;
        }

        public void setDoctorId(Long doctorId)
        {
            this.doctorId = doctorId;
        }

        public String getStatus()
        {
            return status;
        }

        public void setStatus(String status)
        {
            this.status = status;
        }

        public String getAppointmentDate()
        {
            return appointmentDate;
        }

        public void setAppointmentDate(String appointmentDate)
        {
            this.appointmentDate = appointmentDate;
        }

        public String getPatientName()
        {
            return patientName;
        }

        public void setPatientName(String patientName)
        {
            this.patientName = patientName;
        }

        public String getDoctorName()
        {
            return doctorName;
        }

        public void setDoctorName(String doctorName)
        {
            this.doctorName = doctorName;
        }
    }
}
