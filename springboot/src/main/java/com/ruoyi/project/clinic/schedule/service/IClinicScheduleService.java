package com.ruoyi.project.clinic.schedule.service;

import com.ruoyi.project.clinic.schedule.domain.ClinicSchedule;
import java.util.List;

public interface IClinicScheduleService
{
    public ClinicSchedule selectClinicScheduleById(Long scheduleId);

    public List<ClinicSchedule> selectClinicScheduleList(ClinicSchedule clinicSchedule);

    public int insertClinicSchedule(ClinicSchedule clinicSchedule);

    public int updateClinicSchedule(ClinicSchedule clinicSchedule);

    public int deleteClinicScheduleByIds(Long[] scheduleIds);

    public int deleteClinicScheduleById(Long scheduleId);
}
