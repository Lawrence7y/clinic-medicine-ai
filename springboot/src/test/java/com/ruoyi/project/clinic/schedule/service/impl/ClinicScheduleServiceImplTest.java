package com.ruoyi.project.clinic.schedule.service.impl;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.ruoyi.project.clinic.schedule.domain.ClinicSchedule;
import com.ruoyi.project.clinic.schedule.mapper.ClinicScheduleMapper;
import com.ruoyi.project.system.user.service.IUserService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentMatchers;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
public class ClinicScheduleServiceImplTest
{
    @Mock
    private ClinicScheduleMapper clinicScheduleMapper;

    @Mock
    private IUserService userService;

    @InjectMocks
    private ClinicScheduleServiceImpl service;

    @Test
    public void insertScheduleShouldDefaultBookedSlotsToZero()
    {
        when(clinicScheduleMapper.insertClinicSchedule(any(ClinicSchedule.class))).thenReturn(1);

        ClinicSchedule schedule = new ClinicSchedule();
        schedule.setDoctorId(7L);
        schedule.setDoctorName("doctor");
        schedule.setScheduleDate(new java.util.Date());
        schedule.setStartTime("08:00");
        schedule.setEndTime("12:00");
        schedule.setTotalSlots(20);

        int rows = service.insertClinicSchedule(schedule);

        assertEquals(1, rows);
        verify(clinicScheduleMapper).insertClinicSchedule(ArgumentMatchers.argThat(saved ->
            Integer.valueOf(0).equals(saved.getBookedSlots())));
    }

    @Test
    public void updateScheduleShouldKeepExistingBookedSlotsWhenClientDoesNotSendIt()
    {
        ClinicSchedule old = new ClinicSchedule();
        old.setScheduleId(5L);
        old.setBookedSlots(3);

        when(clinicScheduleMapper.selectClinicScheduleById(5L)).thenReturn(old);
        when(clinicScheduleMapper.updateClinicSchedule(any(ClinicSchedule.class))).thenReturn(1);

        ClinicSchedule schedule = new ClinicSchedule();
        schedule.setScheduleId(5L);
        schedule.setDoctorId(7L);
        schedule.setDoctorName("doctor");
        schedule.setScheduleDate(new java.util.Date());
        schedule.setStartTime("08:00");
        schedule.setEndTime("12:00");
        schedule.setTotalSlots(20);

        int rows = service.updateClinicSchedule(schedule);

        assertEquals(1, rows);
        verify(clinicScheduleMapper).updateClinicSchedule(ArgumentMatchers.argThat(updated ->
            Integer.valueOf(3).equals(updated.getBookedSlots())));
    }
}
