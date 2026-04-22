package com.ruoyi.project.clinic.schedule.mapper;

import com.ruoyi.project.clinic.schedule.domain.ClinicSchedule;
import java.util.List;

public interface ClinicScheduleMapper
{
    public ClinicSchedule selectClinicScheduleById(Long scheduleId);

    public List<ClinicSchedule> selectClinicScheduleList(ClinicSchedule clinicSchedule);

    public int insertClinicSchedule(ClinicSchedule clinicSchedule);

    public int updateClinicSchedule(ClinicSchedule clinicSchedule);

    public int deleteClinicScheduleById(Long scheduleId);

    public int deleteClinicScheduleByIds(Long[] scheduleIds);

    public int incrementBookedSlotsIfAvailable(Long scheduleId);

    public int decrementBookedSlots(Long scheduleId);

    public List<ClinicSchedule> selectSchedulesByDoctorAndDate(Long doctorId, java.util.Date scheduleDate);
}
