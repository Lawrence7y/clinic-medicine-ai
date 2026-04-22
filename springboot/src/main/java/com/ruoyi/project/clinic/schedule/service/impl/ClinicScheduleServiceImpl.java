package com.ruoyi.project.clinic.schedule.service.impl;

import java.util.List;
import java.time.LocalTime;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.security.ShiroUtils;
import com.ruoyi.project.clinic.schedule.domain.ClinicSchedule;
import com.ruoyi.project.clinic.schedule.mapper.ClinicScheduleMapper;
import com.ruoyi.project.clinic.schedule.service.IClinicScheduleService;
import com.ruoyi.project.system.user.domain.User;
import com.ruoyi.project.system.user.service.IUserService;

@Service
public class ClinicScheduleServiceImpl implements IClinicScheduleService
{
    @Autowired
    private ClinicScheduleMapper clinicScheduleMapper;

    @Autowired
    private IUserService userService;

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
    public ClinicSchedule selectClinicScheduleById(Long scheduleId)
    {
        return clinicScheduleMapper.selectClinicScheduleById(scheduleId);
    }

    @Override
    public List<ClinicSchedule> selectClinicScheduleList(ClinicSchedule clinicSchedule)
    {
        return clinicScheduleMapper.selectClinicScheduleList(clinicSchedule);
    }

    @Override
    public int insertClinicSchedule(ClinicSchedule clinicSchedule)
    {
        fillDoctorInfo(clinicSchedule);
        validateSchedule(clinicSchedule, null);
        if (clinicSchedule.getCreateBy() == null || clinicSchedule.getCreateBy().trim().isEmpty())
        {
            clinicSchedule.setCreateBy(safeLoginName());
        }
        if (clinicSchedule.getCreateTime() == null)
        {
            clinicSchedule.setCreateTime(DateUtils.getNowDate());
        }
        if (clinicSchedule.getBookedSlots() == null)
        {
            clinicSchedule.setBookedSlots(0);
        }
        if (clinicSchedule.getStatus() == null || clinicSchedule.getStatus().trim().isEmpty())
        {
            clinicSchedule.setStatus("active");
        }
        return clinicScheduleMapper.insertClinicSchedule(clinicSchedule);
    }

    @Override
    public int updateClinicSchedule(ClinicSchedule clinicSchedule)
    {
        fillDoctorInfo(clinicSchedule);
        validateSchedule(clinicSchedule, clinicSchedule.getScheduleId());
        if (clinicSchedule.getUpdateBy() == null || clinicSchedule.getUpdateBy().trim().isEmpty())
        {
            clinicSchedule.setUpdateBy(safeLoginName());
        }
        if (clinicSchedule.getUpdateTime() == null)
        {
            clinicSchedule.setUpdateTime(DateUtils.getNowDate());
        }
        if (clinicSchedule.getBookedSlots() == null)
        {
            ClinicSchedule old = clinicSchedule.getScheduleId() != null
                ? clinicScheduleMapper.selectClinicScheduleById(clinicSchedule.getScheduleId())
                : null;
            clinicSchedule.setBookedSlots(old != null && old.getBookedSlots() != null ? old.getBookedSlots() : 0);
        }
        if (clinicSchedule.getStatus() == null || clinicSchedule.getStatus().trim().isEmpty())
        {
            clinicSchedule.setStatus("active");
        }
        return clinicScheduleMapper.updateClinicSchedule(clinicSchedule);
    }

    @Override
    public int deleteClinicScheduleByIds(Long[] scheduleIds)
    {
        return clinicScheduleMapper.deleteClinicScheduleByIds(scheduleIds);
    }

    @Override
    public int deleteClinicScheduleById(Long scheduleId)
    {
        return clinicScheduleMapper.deleteClinicScheduleById(scheduleId);
    }

    private void fillDoctorInfo(ClinicSchedule clinicSchedule)
    {
        if (clinicSchedule == null)
        {
            throw new RuntimeException("排班信息不能为空");
        }

        if (clinicSchedule.getDoctorId() == null && StringUtils.isNotEmpty(clinicSchedule.getDoctorName()))
        {
            User doctor = userService.selectUserByUserName(clinicSchedule.getDoctorName());
            if (doctor == null)
            {
                doctor = userService.selectUserByLoginName(clinicSchedule.getDoctorName());
            }
            if (doctor != null)
            {
                clinicSchedule.setDoctorId(doctor.getUserId());
                clinicSchedule.setDoctorName(doctor.getUserName());
            }
        }

        if (clinicSchedule.getDoctorId() != null && StringUtils.isEmpty(clinicSchedule.getDoctorName()))
        {
            User doctor = userService.selectUserById(clinicSchedule.getDoctorId());
            if (doctor != null)
            {
                clinicSchedule.setDoctorName(doctor.getUserName());
            }
        }

        if (clinicSchedule.getDoctorId() == null)
        {
            throw new RuntimeException("请选择医生");
        }
    }

    private void validateSchedule(ClinicSchedule clinicSchedule, Long currentScheduleId)
    {
        if (clinicSchedule == null)
        {
            throw new RuntimeException("排班信息不能为空");
        }
        if (clinicSchedule.getScheduleDate() == null)
        {
            throw new RuntimeException("请选择排班日期");
        }
        if (StringUtils.isEmpty(clinicSchedule.getStartTime()) || StringUtils.isEmpty(clinicSchedule.getEndTime()))
        {
            throw new RuntimeException("请选择完整的排班时间");
        }

        LocalTime startTime;
        LocalTime endTime;
        try
        {
            startTime = LocalTime.parse(clinicSchedule.getStartTime().trim());
            endTime = LocalTime.parse(clinicSchedule.getEndTime().trim());
        }
        catch (Exception ignored)
        {
            throw new RuntimeException("排班时间格式不正确");
        }
        if (!startTime.isBefore(endTime))
        {
            throw new RuntimeException("排班开始时间必须早于结束时间");
        }

        Integer totalSlots = clinicSchedule.getTotalSlots();
        if (totalSlots == null || totalSlots <= 0)
        {
            throw new RuntimeException("号源数量必须大于 0");
        }

        Integer bookedSlots = clinicSchedule.getBookedSlots();
        if (bookedSlots == null && currentScheduleId != null)
        {
            ClinicSchedule old = clinicScheduleMapper.selectClinicScheduleById(currentScheduleId);
            bookedSlots = old != null ? old.getBookedSlots() : null;
        }
        if (bookedSlots != null && bookedSlots > totalSlots)
        {
            throw new RuntimeException("号源数量不能小于已预约数量");
        }

        List<ClinicSchedule> sameDaySchedules = clinicScheduleMapper.selectSchedulesByDoctorAndDate(
            clinicSchedule.getDoctorId(), clinicSchedule.getScheduleDate());
        if (sameDaySchedules == null || sameDaySchedules.isEmpty())
        {
            return;
        }

        for (ClinicSchedule existing : sameDaySchedules)
        {
            if (existing == null || existing.getScheduleId() == null)
            {
                continue;
            }
            if (currentScheduleId != null && currentScheduleId.equals(existing.getScheduleId()))
            {
                continue;
            }
            String existingStatus = existing.getStatus();
            if (StringUtils.isEmpty(existingStatus))
            {
                existingStatus = "active";
            }
            if (!"active".equalsIgnoreCase(existingStatus))
            {
                continue;
            }
            if (StringUtils.isEmpty(existing.getStartTime()) || StringUtils.isEmpty(existing.getEndTime()))
            {
                continue;
            }

            LocalTime existStart;
            LocalTime existEnd;
            try
            {
                existStart = LocalTime.parse(existing.getStartTime().trim());
                existEnd = LocalTime.parse(existing.getEndTime().trim());
            }
            catch (Exception ignored)
            {
                continue;
            }

            boolean overlap = startTime.isBefore(existEnd) && endTime.isAfter(existStart);
            if (overlap)
            {
                throw new RuntimeException(
                    String.format("排班时间冲突：%s-%s 已存在排班", existing.getStartTime(), existing.getEndTime()));
            }
        }
    }
}
