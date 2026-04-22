package com.ruoyi.project.clinic.appointment.mapper;

import com.ruoyi.project.clinic.appointment.domain.ClinicAppointment;
import java.util.List;
import org.apache.ibatis.annotations.Param;

public interface ClinicAppointmentMapper
{
    public ClinicAppointment selectClinicAppointmentById(Long appointmentId);

    public List<ClinicAppointment> selectClinicAppointmentList(ClinicAppointment clinicAppointment);

    public int insertClinicAppointment(ClinicAppointment clinicAppointment);

    public int updateClinicAppointment(ClinicAppointment clinicAppointment);

    public int deleteClinicAppointmentById(Long appointmentId);

    public int deleteClinicAppointmentByIds(Long[] appointmentIds);

    public int countAppointmentByStatus(String status);

    public List<ClinicAppointment> selectPendingAppointments();

    public int updateDoctorNameByDoctorId(@Param("doctorId") Long doctorId, @Param("doctorName") String doctorName);

    public int updatePatientInfoByPatientId(@Param("patientId") Long patientId,
                                            @Param("patientName") String patientName,
                                            @Param("patientPhone") String patientPhone);

    public List<ClinicAppointment> selectUpcomingAppointments(@Param("patientId") Long patientId,
                                                              @Param("doctorId") Long doctorId,
                                                              @Param("startDate") String startDate,
                                                              @Param("endDate") String endDate);
    
    public List<ClinicAppointment> selectAppointmentsForReminder(@Param("startDate") String startDate, @Param("endDate") String endDate);

    int countTodayAppointments(@Param("date") String date, @Param("doctorId") Long doctorId);

    List<ClinicAppointment> selectPendingAppointmentsList(@Param("limit") int limit, @Param("doctorId") Long doctorId);

    // 叫号相关方法
    ClinicAppointment selectCalledAppointment(@Param("doctorId") Long doctorId,
                                              @Param("appointmentDate") String appointmentDate,
                                              @Param("appointmentTime") String appointmentTime);

    int clearCalledStatus(@Param("doctorId") Long doctorId,
                           @Param("appointmentDate") String appointmentDate,
                           @Param("appointmentTime") String appointmentTime);

    int callAppointment(@Param("appointmentId") Long appointmentId,
                        @Param("calledTime") java.util.Date calledTime);

    List<ClinicAppointment> selectNextConfirmedAppointments(@Param("doctorId") Long doctorId,
                                                            @Param("appointmentDate") String appointmentDate,
                                                            @Param("appointmentTime") String appointmentTime,
                                                            @Param("currentSequenceNumber") Integer currentSequenceNumber);

    List<ClinicAppointment> selectQueueByDoctorAndDate(@Param("doctorId") Long doctorId,
                                                        @Param("appointmentDate") String appointmentDate);

    int countAheadInQueue(@Param("doctorId") Long doctorId,
                          @Param("appointmentDate") String appointmentDate,
                          @Param("appointmentTime") String appointmentTime,
                          @Param("sequenceNumber") Integer sequenceNumber);

    int completeAppointment(@Param("appointmentId") Long appointmentId,
                            @Param("updateBy") String updateBy,
                            @Param("updateTime") java.util.Date updateTime);

    List<ClinicAppointment> getCalledAppointments(@Param("patientId") Long patientId,
                                                  @Param("appointmentDate") String appointmentDate);

    int expirePendingAppointments(@Param("today") String today,
                                  @Param("currentTime") String currentTime,
                                  @Param("updateBy") String updateBy);

    List<ClinicAppointment> selectExpirablePendingAppointments(@Param("today") String today,
                                                               @Param("currentTime") String currentTime,
                                                               @Param("pendingTimeoutMinutes") Integer pendingTimeoutMinutes);

    int expirePendingAppointmentById(@Param("appointmentId") Long appointmentId,
                                     @Param("updateBy") String updateBy);
}
