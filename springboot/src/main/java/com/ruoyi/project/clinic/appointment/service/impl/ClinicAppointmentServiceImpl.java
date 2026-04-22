package com.ruoyi.project.clinic.appointment.service.impl;

import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Objects;
import java.util.Set;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.security.ShiroUtils;
import com.ruoyi.project.clinic.appointment.domain.ClinicAppointment;
import com.ruoyi.project.clinic.appointment.domain.ClinicAppointmentSubscription;
import com.ruoyi.project.clinic.appointment.mapper.ClinicAppointmentMapper;
import com.ruoyi.project.clinic.appointment.mapper.ClinicAppointmentSubscriptionMapper;
import com.ruoyi.project.clinic.appointment.service.IClinicAppointmentService;
import com.ruoyi.project.clinic.config.service.ClinicConfigSupportService;
import com.ruoyi.project.clinic.schedule.domain.ClinicSchedule;
import com.ruoyi.project.clinic.schedule.mapper.ClinicScheduleMapper;

@Service
public class ClinicAppointmentServiceImpl implements IClinicAppointmentService
{
    private static final Set<String> ALLOWED_APPOINTMENT_STATUS = new HashSet<String>(
        Arrays.asList("pending", "confirmed", "completed", "cancelled", "expired"));

    @Autowired
    private ClinicAppointmentMapper clinicAppointmentMapper;

    @Autowired
    private ClinicScheduleMapper clinicScheduleMapper;

    @Autowired(required = false)
    private ClinicAppointmentSubscriptionMapper subscriptionMapper;

    @Autowired(required = false)
    private ClinicConfigSupportService clinicConfigSupportService;

    private String safeLoginName()
    {
        try
        {
            String loginName = ShiroUtils.getLoginName();
            return loginName != null ? loginName : "";
        }
        catch (Exception ignored)
        {
            return "";
        }
    }

    @Override
    public ClinicAppointment selectClinicAppointmentById(Long appointmentId)
    {
        expirePendingAppointmentsIfNeeded();
        return clinicAppointmentMapper.selectClinicAppointmentById(appointmentId);
    }

    @Override
    public List<ClinicAppointment> selectClinicAppointmentList(ClinicAppointment clinicAppointment)
    {
        expirePendingAppointmentsIfNeeded();
        return clinicAppointmentMapper.selectClinicAppointmentList(clinicAppointment);
    }

    @Override
    @Transactional
    public int insertClinicAppointment(ClinicAppointment clinicAppointment)
    {
        expirePendingAppointmentsIfNeeded();
        if (clinicAppointment == null)
        {
            throw new RuntimeException("预约参数不能为空");
        }
        if (clinicAppointment.getCreateBy() == null || clinicAppointment.getCreateBy().trim().isEmpty())
        {
            clinicAppointment.setCreateBy(safeLoginName());
        }
        if (clinicAppointment.getCreateTime() == null)
        {
            clinicAppointment.setCreateTime(DateUtils.getNowDate());
        }
        if (clinicAppointment.getStatus() == null || clinicAppointment.getStatus().trim().isEmpty())
        {
            clinicAppointment.setStatus("pending");
        }
        validateStatus(clinicAppointment.getStatus());

        // 预约冲突检查：同一医生在同一时间段不能有多个有效预约
        if (clinicAppointment.getScheduleId() == null
                && clinicAppointment.getDoctorId() != null
                && clinicAppointment.getAppointmentDate() != null
                && clinicAppointment.getAppointmentTime() != null
                && occupiesSlot(clinicAppointment.getStatus())) {
            ClinicAppointment conflictQuery = new ClinicAppointment();
            conflictQuery.setDoctorId(clinicAppointment.getDoctorId());
            conflictQuery.setAppointmentDate(clinicAppointment.getAppointmentDate());
            conflictQuery.setAppointmentTime(clinicAppointment.getAppointmentTime());
            List<ClinicAppointment> conflicts = clinicAppointmentMapper.selectClinicAppointmentList(conflictQuery);
            if (conflicts != null && !conflicts.isEmpty()) {
                for (ClinicAppointment existing : conflicts) {
                    if (existing != null && occupiesSlot(existing.getStatus())
                            && existing.getAppointmentId() != null
                            && !existing.getAppointmentId().equals(clinicAppointment.getAppointmentId())) {
                        throw new RuntimeException("该医生在此时间段已有预约，请选择其他时间");
                    }
                }
            }
        }

        if (clinicAppointment.getScheduleId() != null)
        {
            ClinicSchedule schedule = clinicScheduleMapper.selectClinicScheduleById(clinicAppointment.getScheduleId());
            if (schedule != null)
            {
                fillFromScheduleIfNeeded(clinicAppointment, schedule);
            }
            else
            {
                throw new RuntimeException("排班不存在或已失效");
            }

            if (occupiesSlot(clinicAppointment.getStatus()))
            {
                int updated = clinicScheduleMapper.incrementBookedSlotsIfAvailable(clinicAppointment.getScheduleId());
                if (updated <= 0)
                {
                    throw new RuntimeException("当前时间段号源不足");
                }
                if (clinicAppointment.getSequenceNumber() == null)
                {
                    ClinicSchedule afterBook = clinicScheduleMapper.selectClinicScheduleById(clinicAppointment.getScheduleId());
                    if (afterBook != null && afterBook.getBookedSlots() != null)
                    {
                        clinicAppointment.setSequenceNumber(afterBook.getBookedSlots());
                    }
                }
            }
        }

        if (occupiesSlot(clinicAppointment.getStatus()))
        {
            ensureNoDuplicatePatientAppointment(
                null,
                clinicAppointment.getPatientId(),
                clinicAppointment.getDoctorId(),
                clinicAppointment.getAppointmentDate(),
                clinicAppointment.getAppointmentTime());
            if (clinicAppointment.getScheduleId() == null)
            {
                ensureDoctorSlotAvailable(
                    null,
                    clinicAppointment.getDoctorId(),
                    clinicAppointment.getAppointmentDate(),
                    clinicAppointment.getAppointmentTime());
            }
        }

        return clinicAppointmentMapper.insertClinicAppointment(clinicAppointment);
    }

    @Override
    @Transactional
    public int updateClinicAppointment(ClinicAppointment clinicAppointment)
    {
        expirePendingAppointmentsIfNeeded();
        if (clinicAppointment == null || clinicAppointment.getAppointmentId() == null)
        {
            throw new RuntimeException("预约参数错误");
        }
        ClinicAppointment old = clinicAppointment.getAppointmentId() != null
                ? clinicAppointmentMapper.selectClinicAppointmentById(clinicAppointment.getAppointmentId())
                : null;
        if (old == null)
        {
            throw new RuntimeException("预约记录不存在");
        }

        String oldStatus = old.getStatus();
        String newStatus = (clinicAppointment.getStatus() == null || clinicAppointment.getStatus().trim().isEmpty())
                ? oldStatus
                : clinicAppointment.getStatus();
        validateStatus(newStatus);
        validateStatusTransition(oldStatus, newStatus);
        Long oldScheduleId = old.getScheduleId();
        Long newScheduleId = clinicAppointment.getScheduleId() != null ? clinicAppointment.getScheduleId() : oldScheduleId;
        Long targetPatientId = clinicAppointment.getPatientId() != null ? clinicAppointment.getPatientId() : old.getPatientId();
        boolean oldOccupies = occupiesSlot(oldStatus);
        boolean newOccupies = occupiesSlot(newStatus);
        boolean scheduleChanged = oldScheduleId != null ? !oldScheduleId.equals(newScheduleId) : newScheduleId != null;
        Long targetDoctorId = clinicAppointment.getDoctorId() != null ? clinicAppointment.getDoctorId() : old.getDoctorId();
        java.util.Date targetAppointmentDate = clinicAppointment.getAppointmentDate() != null
                ? clinicAppointment.getAppointmentDate()
                : old.getAppointmentDate();
        String targetAppointmentTime = StringUtils.isNotEmpty(clinicAppointment.getAppointmentTime())
                ? clinicAppointment.getAppointmentTime()
                : old.getAppointmentTime();
        boolean doctorChanged = !Objects.equals(old.getDoctorId(), targetDoctorId);
        boolean dateChanged = !Objects.equals(old.getAppointmentDate(), targetAppointmentDate);
        boolean timeChanged = !Objects.equals(old.getAppointmentTime(), targetAppointmentTime);

        if (scheduleChanged && oldOccupies && oldScheduleId != null)
        {
            clinicScheduleMapper.decrementBookedSlots(oldScheduleId);
        }

        if (newOccupies && (!oldOccupies || scheduleChanged) && newScheduleId != null)
        {
            int changed = clinicScheduleMapper.incrementBookedSlotsIfAvailable(newScheduleId);
            if (changed <= 0)
            {
                throw new RuntimeException("当前时间段号源不足");
            }
            if (scheduleChanged || clinicAppointment.getSequenceNumber() == null)
            {
                ClinicSchedule afterBook = clinicScheduleMapper.selectClinicScheduleById(newScheduleId);
                if (afterBook != null && afterBook.getBookedSlots() != null)
                {
                    clinicAppointment.setSequenceNumber(afterBook.getBookedSlots());
                }
            }
        }
        else if (!newOccupies && oldOccupies && !scheduleChanged && oldScheduleId != null)
        {
            clinicScheduleMapper.decrementBookedSlots(oldScheduleId);
        }

        if (scheduleChanged && newScheduleId != null)
        {
            ClinicSchedule newSchedule = clinicScheduleMapper.selectClinicScheduleById(newScheduleId);
            if (newSchedule != null)
            {
                fillFromScheduleIfNeeded(clinicAppointment, newSchedule);
                targetDoctorId = clinicAppointment.getDoctorId() != null ? clinicAppointment.getDoctorId() : old.getDoctorId();
                targetAppointmentDate = clinicAppointment.getAppointmentDate() != null
                        ? clinicAppointment.getAppointmentDate()
                        : old.getAppointmentDate();
                targetAppointmentTime = StringUtils.isNotEmpty(clinicAppointment.getAppointmentTime())
                        ? clinicAppointment.getAppointmentTime()
                        : old.getAppointmentTime();
                doctorChanged = !Objects.equals(old.getDoctorId(), targetDoctorId);
                dateChanged = !Objects.equals(old.getAppointmentDate(), targetAppointmentDate);
                timeChanged = !Objects.equals(old.getAppointmentTime(), targetAppointmentTime);
            }
            else
            {
                throw new RuntimeException("排班不存在或已失效");
            }
        }

        if (clinicAppointment.getUpdateBy() == null || clinicAppointment.getUpdateBy().trim().isEmpty())
        {
            clinicAppointment.setUpdateBy(safeLoginName());
        }
        if (clinicAppointment.getUpdateTime() == null)
        {
            clinicAppointment.setUpdateTime(DateUtils.getNowDate());
        }

        // 预约冲突检查（仅当时间或医生变更时检查）
        if (newScheduleId == null
                && newOccupies
                && targetDoctorId != null
                && targetAppointmentDate != null
                && StringUtils.isNotEmpty(targetAppointmentTime)
                && (scheduleChanged || doctorChanged || dateChanged || timeChanged)) {
            ClinicAppointment conflictQuery = new ClinicAppointment();
            conflictQuery.setDoctorId(targetDoctorId);
            conflictQuery.setAppointmentDate(targetAppointmentDate);
            conflictQuery.setAppointmentTime(targetAppointmentTime);
            List<ClinicAppointment> conflicts = clinicAppointmentMapper.selectClinicAppointmentList(conflictQuery);
            if (conflicts != null && !conflicts.isEmpty()) {
                for (ClinicAppointment existing : conflicts) {
                    if (existing != null && occupiesSlot(existing.getStatus())
                            && existing.getAppointmentId() != null
                            && !existing.getAppointmentId().equals(clinicAppointment.getAppointmentId())) {
                        throw new RuntimeException("该医生在此时间段已有预约，请选择其他时间");
                    }
                }
            }
        }

        if (newOccupies)
        {
            ensureNoDuplicatePatientAppointment(
                clinicAppointment.getAppointmentId(),
                targetPatientId,
                targetDoctorId,
                targetAppointmentDate,
                targetAppointmentTime);
            if (newScheduleId == null)
            {
                ensureDoctorSlotAvailable(
                    clinicAppointment.getAppointmentId(),
                    targetDoctorId,
                    targetAppointmentDate,
                    targetAppointmentTime);
            }
        }

        return clinicAppointmentMapper.updateClinicAppointment(clinicAppointment);
    }

    @Override
    @Transactional
    public int deleteClinicAppointmentByIds(Long[] appointmentIds)
    {
        if (appointmentIds != null)
        {
            for (Long appointmentId : appointmentIds)
            {
                ClinicAppointment old = clinicAppointmentMapper.selectClinicAppointmentById(appointmentId);
                if (old != null && old.getScheduleId() != null && occupiesSlot(old.getStatus()))
                {
                    clinicScheduleMapper.decrementBookedSlots(old.getScheduleId());
                }
            }
        }
        return clinicAppointmentMapper.deleteClinicAppointmentByIds(appointmentIds);
    }

    @Override
    @Transactional
    public int deleteClinicAppointmentById(Long appointmentId)
    {
        ClinicAppointment old = clinicAppointmentMapper.selectClinicAppointmentById(appointmentId);
        if (old != null && old.getScheduleId() != null && occupiesSlot(old.getStatus()))
        {
            clinicScheduleMapper.decrementBookedSlots(old.getScheduleId());
        }
        return clinicAppointmentMapper.deleteClinicAppointmentById(appointmentId);
    }

    @Override
    public int countAppointmentByStatus(String status)
    {
        expirePendingAppointmentsIfNeeded();
        return clinicAppointmentMapper.countAppointmentByStatus(status);
    }

    @Override
    public List<ClinicAppointment> selectPendingAppointments()
    {
        expirePendingAppointmentsIfNeeded();
        return clinicAppointmentMapper.selectPendingAppointments();
    }

    @Override
    public int syncDoctorName(Long doctorId, String doctorName)
    {
        if (doctorId == null || doctorName == null)
        {
            return 0;
        }
        return clinicAppointmentMapper.updateDoctorNameByDoctorId(doctorId, doctorName);
    }

    @Override
    public int syncPatientInfo(Long patientId, String patientName, String patientPhone)
    {
        if (patientId == null)
        {
            return 0;
        }
        return clinicAppointmentMapper.updatePatientInfoByPatientId(patientId, patientName, patientPhone);
    }

    @Override
    public List<ClinicAppointment> selectUpcomingAppointments(Long patientId, Long doctorId, String startDate, String endDate)
    {
        expirePendingAppointmentsIfNeeded();
        return clinicAppointmentMapper.selectUpcomingAppointments(patientId, doctorId, startDate, endDate);
    }
    
    @Override
    public List<ClinicAppointment> selectAppointmentsForReminder(String startDate, String endDate)
    {
        return clinicAppointmentMapper.selectAppointmentsForReminder(startDate, endDate);
    }

    @Override
    public int countTodayAppointments(String date, Long doctorId)
    {
        expirePendingAppointmentsIfNeeded();
        return clinicAppointmentMapper.countTodayAppointments(date, doctorId);
    }

    @Override
    public List<ClinicAppointment> selectPendingAppointmentsList(int limit, Long doctorId)
    {
        expirePendingAppointmentsIfNeeded();
        return clinicAppointmentMapper.selectPendingAppointmentsList(limit, doctorId);
    }

    private void fillFromScheduleIfNeeded(ClinicAppointment clinicAppointment, ClinicSchedule schedule)
    {
        if (clinicAppointment.getDoctorId() == null)
        {
            clinicAppointment.setDoctorId(schedule.getDoctorId());
        }
        if (clinicAppointment.getDoctorName() == null || clinicAppointment.getDoctorName().trim().isEmpty())
        {
            clinicAppointment.setDoctorName(schedule.getDoctorName());
        }
        if (clinicAppointment.getAppointmentDate() == null)
        {
            clinicAppointment.setAppointmentDate(schedule.getScheduleDate());
        }
        if (clinicAppointment.getAppointmentTime() == null || clinicAppointment.getAppointmentTime().trim().isEmpty())
        {
            clinicAppointment.setAppointmentTime(String.format("%s-%s", schedule.getStartTime(), schedule.getEndTime()));
        }
    }

    private boolean occupiesSlot(String status)
    {
        if (status == null || status.trim().isEmpty())
        {
            return true;
        }
        return !"cancelled".equalsIgnoreCase(status) && !"expired".equalsIgnoreCase(status);
    }

    private void validateStatus(String status)
    {
        String normalized = status != null ? status.trim().toLowerCase() : "";
        if (StringUtils.isEmpty(normalized))
        {
            throw new RuntimeException("预约状态不能为空");
        }
        if (!ALLOWED_APPOINTMENT_STATUS.contains(normalized))
        {
            throw new RuntimeException("预约状态不合法: " + status);
        }
    }

    private void validateStatusTransition(String oldStatus, String newStatus)
    {
        String from = oldStatus == null ? "pending" : oldStatus.trim().toLowerCase();
        String to = newStatus == null ? from : newStatus.trim().toLowerCase();
        if (from.equals(to))
        {
            return;
        }

        if ("pending".equals(from))
        {
            if ("confirmed".equals(to) || "cancelled".equals(to) || "expired".equals(to))
            {
                return;
            }
        }
        else if ("confirmed".equals(from))
        {
            if ("completed".equals(to) || "cancelled".equals(to))
            {
                return;
            }
        }

        throw new RuntimeException("预约状态流转不允许: " + from + " -> " + to);
    }

    private void ensureDoctorSlotAvailable(Long excludeAppointmentId, Long doctorId, java.util.Date appointmentDate, String appointmentTime)
    {
        if (doctorId == null || appointmentDate == null || StringUtils.isEmpty(appointmentTime))
        {
            return;
        }
        ClinicAppointment conflictQuery = new ClinicAppointment();
        conflictQuery.setDoctorId(doctorId);
        conflictQuery.setAppointmentDate(appointmentDate);
        conflictQuery.setAppointmentTime(appointmentTime);
        List<ClinicAppointment> conflicts = clinicAppointmentMapper.selectClinicAppointmentList(conflictQuery);
        if (conflicts == null || conflicts.isEmpty())
        {
            return;
        }
        for (ClinicAppointment existing : conflicts)
        {
            if (existing == null || !occupiesSlot(existing.getStatus()))
            {
                continue;
            }
            if (excludeAppointmentId != null && excludeAppointmentId.equals(existing.getAppointmentId()))
            {
                continue;
            }
            throw new RuntimeException("该医生在此时间段已有预约，请选择其他时间");
        }
    }

    private void ensureNoDuplicatePatientAppointment(Long excludeAppointmentId, Long patientId, Long doctorId,
        java.util.Date appointmentDate, String appointmentTime)
    {
        if (patientId == null || doctorId == null || appointmentDate == null || StringUtils.isEmpty(appointmentTime))
        {
            return;
        }
        ClinicAppointment duplicateQuery = new ClinicAppointment();
        duplicateQuery.setPatientId(patientId);
        duplicateQuery.setDoctorId(doctorId);
        duplicateQuery.setAppointmentDate(appointmentDate);
        duplicateQuery.setAppointmentTime(appointmentTime);
        List<ClinicAppointment> duplicates = clinicAppointmentMapper.selectClinicAppointmentList(duplicateQuery);
        if (duplicates == null || duplicates.isEmpty())
        {
            return;
        }
        for (ClinicAppointment existing : duplicates)
        {
            if (existing == null || !occupiesSlot(existing.getStatus()))
            {
                continue;
            }
            if (excludeAppointmentId != null && excludeAppointmentId.equals(existing.getAppointmentId()))
            {
                continue;
            }
            throw new RuntimeException("同一患者在该时段已预约，请勿重复预约");
        }
    }

    private void expirePendingAppointmentsIfNeeded()
    {
        String today = new SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
        String currentTime = new SimpleDateFormat("HH:mm").format(new java.util.Date());
        Integer pendingTimeoutMinutes = resolvePendingConfirmTimeoutMinutes();
        List<ClinicAppointment> expirableList = clinicAppointmentMapper.selectExpirablePendingAppointments(
                today, currentTime, pendingTimeoutMinutes);
        if (expirableList == null || expirableList.isEmpty())
        {
            return;
        }

        for (ClinicAppointment item : expirableList)
        {
            if (item == null || item.getAppointmentId() == null)
            {
                continue;
            }
            int changed = clinicAppointmentMapper.expirePendingAppointmentById(item.getAppointmentId(), "system");
            if (changed > 0 && item.getScheduleId() != null && occupiesSlot(item.getStatus()))
            {
                clinicScheduleMapper.decrementBookedSlots(item.getScheduleId());
            }
        }
    }

    private Integer resolvePendingConfirmTimeoutMinutes()
    {
        try
        {
            if (clinicConfigSupportService != null)
            {
                return clinicConfigSupportService.getPendingConfirmTimeoutMinutes();
            }
        }
        catch (Exception ignored)
        {
            // fallback below
        }
        return 30;
    }

    // ==================== 订阅相关 ====================

    @Override
    public ClinicAppointmentSubscription getSubscriptionByUserId(Long userId)
    {
        if (subscriptionMapper == null || userId == null)
        {
            return null;
        }
        return subscriptionMapper.selectSubscriptionByUserId(userId);
    }

    @Override
    @Transactional
    public int saveOrUpdateSubscription(ClinicAppointmentSubscription subscription)
    {
        if (subscriptionMapper == null || subscription == null || subscription.getUserId() == null)
        {
            return 0;
        }
        subscription.setUpdateTime(DateUtils.getNowDate());
        ClinicAppointmentSubscription existing = subscriptionMapper.selectSubscriptionByUserId(subscription.getUserId());
        if (existing != null)
        {
            return subscriptionMapper.updateSubscription(subscription);
        }
        else
        {
            subscription.setCreateTime(DateUtils.getNowDate());
            return subscriptionMapper.insertSubscription(subscription);
        }
    }

    @Override
    @Transactional
    public int updateLastRemindTime(Long subscriptionId)
    {
        if (subscriptionMapper == null || subscriptionId == null)
        {
            return 0;
        }
        return subscriptionMapper.updateLastRemindTime(subscriptionId);
    }

    // ==================== 叫号相关实现 ====================

    @Override
    @Transactional
    public boolean callAppointment(Long appointmentId)
    {
        expirePendingAppointmentsIfNeeded();
        if (appointmentId == null)
        {
            return false;
        }
        ClinicAppointment appointment = clinicAppointmentMapper.selectClinicAppointmentById(appointmentId);
        if (appointment == null)
        {
            throw new RuntimeException("预约记录不存在");
        }
        if (!"confirmed".equals(appointment.getStatus()))
        {
            throw new RuntimeException("仅已确认的预约可执行叫号");
        }

        String appointmentDate = appointment.getAppointmentDate() != null
                ? new java.text.SimpleDateFormat("yyyy-MM-dd").format(appointment.getAppointmentDate())
                : null;

        // 清除同医生、同日期、同时间段的已叫号状态
        clinicAppointmentMapper.clearCalledStatus(
                appointment.getDoctorId(),
                appointmentDate,
                appointment.getAppointmentTime());

        // 设置当前预约为已叫号
        clinicAppointmentMapper.callAppointment(appointmentId, DateUtils.getNowDate());
        return true;
    }

    @Override
    @Transactional
    public boolean completeAppointment(Long appointmentId)
    {
        expirePendingAppointmentsIfNeeded();
        if (appointmentId == null)
        {
            return false;
        }
        ClinicAppointment appointment = clinicAppointmentMapper.selectClinicAppointmentById(appointmentId);
        if (appointment == null)
        {
            throw new RuntimeException("预约记录不存在");
        }

        // 使用专门的完成就诊方法
        if (!"confirmed".equals(appointment.getStatus()))
        {
            throw new RuntimeException("仅已确认预约可完成就诊");
        }
        clinicAppointmentMapper.completeAppointment(appointmentId, safeLoginName(), DateUtils.getNowDate());

        // 自动触发下一个和下下个预约的叫号
        String appointmentDate = appointment.getAppointmentDate() != null
                ? new java.text.SimpleDateFormat("yyyy-MM-dd").format(appointment.getAppointmentDate())
                : null;

        List<ClinicAppointment> nextAppointments = clinicAppointmentMapper.selectNextConfirmedAppointments(
                appointment.getDoctorId(),
                appointmentDate,
                appointment.getAppointmentTime(),
                appointment.getSequenceNumber());

        if (nextAppointments != null && !nextAppointments.isEmpty())
        {
            // 叫下一个
            ClinicAppointment next = nextAppointments.get(0);
            clinicAppointmentMapper.clearCalledStatus(
                    appointment.getDoctorId(),
                    appointmentDate,
                    appointment.getAppointmentTime());
            clinicAppointmentMapper.callAppointment(next.getAppointmentId(), DateUtils.getNowDate());

            // 叫下下个（即将就诊提醒）
            if (nextAppointments.size() > 1)
            {
                ClinicAppointment secondNext = nextAppointments.get(1);
                // 这里可以发送"即将就诊"提醒，具体实现取决于你的提醒机制
                // 目前仅标记叫号状态
            }
        }

        return true;
    }

    @Override
    public List<ClinicAppointment> getQueueByDoctorAndDate(Long doctorId, String date)
    {
        expirePendingAppointmentsIfNeeded();
        if (doctorId == null || date == null)
        {
            return Collections.emptyList();
        }
        return clinicAppointmentMapper.selectQueueByDoctorAndDate(doctorId, date);
    }

    @Override
    public int getQueuePosition(Long appointmentId)
    {
        expirePendingAppointmentsIfNeeded();
        if (appointmentId == null)
        {
            return 0;
        }
        ClinicAppointment appointment = clinicAppointmentMapper.selectClinicAppointmentById(appointmentId);
        if (appointment == null)
        {
            return 0;
        }

        String appointmentDate = appointment.getAppointmentDate() != null
                ? new java.text.SimpleDateFormat("yyyy-MM-dd").format(appointment.getAppointmentDate())
                : null;

        return clinicAppointmentMapper.countAheadInQueue(
                appointment.getDoctorId(),
                appointmentDate,
                appointment.getAppointmentTime(),
                appointment.getSequenceNumber());
    }

    @Override
    public List<ClinicAppointment> getCalledAppointments(Long patientId, String date)
    {
        expirePendingAppointmentsIfNeeded();
        if (patientId == null || date == null)
        {
            return Collections.emptyList();
        }
        return clinicAppointmentMapper.getCalledAppointments(patientId, date);
    }
}
