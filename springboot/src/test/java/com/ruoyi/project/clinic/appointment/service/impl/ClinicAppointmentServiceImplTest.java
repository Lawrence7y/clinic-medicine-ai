package com.ruoyi.project.clinic.appointment.service.impl;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.ruoyi.project.clinic.appointment.domain.ClinicAppointment;
import com.ruoyi.project.clinic.appointment.mapper.ClinicAppointmentMapper;
import com.ruoyi.project.clinic.appointment.mapper.ClinicAppointmentSubscriptionMapper;
import com.ruoyi.project.clinic.schedule.domain.ClinicSchedule;
import com.ruoyi.project.clinic.schedule.mapper.ClinicScheduleMapper;
import java.text.SimpleDateFormat;
import java.util.Collections;
import java.util.Date;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentMatchers;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
public class ClinicAppointmentServiceImplTest
{
    @Mock
    private ClinicAppointmentMapper clinicAppointmentMapper;

    @Mock
    private ClinicScheduleMapper clinicScheduleMapper;

    @Mock
    private ClinicAppointmentSubscriptionMapper subscriptionMapper;

    @InjectMocks
    private ClinicAppointmentServiceImpl service;

    @Test
    public void scheduledAppointmentShouldUseScheduleCapacityInsteadOfTimeConflict() throws Exception
    {
        ClinicSchedule schedule = new ClinicSchedule();
        schedule.setScheduleId(9L);
        schedule.setDoctorId(7L);
        schedule.setDoctorName("doctor");
        schedule.setScheduleDate(new SimpleDateFormat("yyyy-MM-dd").parse("2026-04-03"));
        schedule.setStartTime("08:00");
        schedule.setEndTime("12:00");
        schedule.setBookedSlots(1);

        ClinicSchedule bookedSchedule = new ClinicSchedule();
        bookedSchedule.setScheduleId(9L);
        bookedSchedule.setBookedSlots(2);

        when(clinicScheduleMapper.selectClinicScheduleById(9L)).thenReturn(schedule, bookedSchedule);
        when(clinicScheduleMapper.incrementBookedSlotsIfAvailable(9L)).thenReturn(1);
        when(clinicAppointmentMapper.insertClinicAppointment(any(ClinicAppointment.class))).thenReturn(1);

        ClinicAppointment appointment = new ClinicAppointment();
        appointment.setScheduleId(9L);
        appointment.setStatus("pending");

        int rows = service.insertClinicAppointment(appointment);

        assertEquals(1, rows);
        verify(clinicAppointmentMapper, never()).selectClinicAppointmentList(any(ClinicAppointment.class));
        verify(clinicAppointmentMapper).insertClinicAppointment(ArgumentMatchers.argThat(saved ->
            Long.valueOf(7L).equals(saved.getDoctorId())
                && "doctor".equals(saved.getDoctorName())
                && "08:00-12:00".equals(saved.getAppointmentTime())
                && Integer.valueOf(2).equals(saved.getSequenceNumber())));
    }

    @Test
    public void completeAppointmentShouldPassUpdateTimeToMapper() throws Exception
    {
        ClinicAppointment appointment = new ClinicAppointment();
        appointment.setAppointmentId(1L);
        appointment.setDoctorId(7L);
        appointment.setStatus("confirmed");
        appointment.setAppointmentDate(new SimpleDateFormat("yyyy-MM-dd").parse("2026-04-03"));
        appointment.setAppointmentTime("08:00-12:00");
        appointment.setSequenceNumber(1);

        when(clinicAppointmentMapper.selectClinicAppointmentById(1L)).thenReturn(appointment);
        when(clinicAppointmentMapper.selectNextConfirmedAppointments(eq(7L), anyString(), eq("08:00-12:00"), eq(1)))
            .thenReturn(Collections.emptyList());

        service.completeAppointment(1L);

        verify(clinicAppointmentMapper).completeAppointment(eq(1L), anyString(), any(Date.class));
    }
}
