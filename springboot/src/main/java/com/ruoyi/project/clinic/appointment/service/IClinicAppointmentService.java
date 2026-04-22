package com.ruoyi.project.clinic.appointment.service;

import com.ruoyi.project.clinic.appointment.domain.ClinicAppointment;
import com.ruoyi.project.clinic.appointment.domain.ClinicAppointmentSubscription;
import java.util.List;

public interface IClinicAppointmentService
{
    public ClinicAppointment selectClinicAppointmentById(Long appointmentId);

    public List<ClinicAppointment> selectClinicAppointmentList(ClinicAppointment clinicAppointment);

    public int insertClinicAppointment(ClinicAppointment clinicAppointment);

    public int updateClinicAppointment(ClinicAppointment clinicAppointment);

    public int deleteClinicAppointmentByIds(Long[] appointmentIds);

    public int deleteClinicAppointmentById(Long appointmentId);

    public int countAppointmentByStatus(String status);

    public List<ClinicAppointment> selectPendingAppointments();

    public int syncDoctorName(Long doctorId, String doctorName);

    public int syncPatientInfo(Long patientId, String patientName, String patientPhone);

    public List<ClinicAppointment> selectUpcomingAppointments(Long patientId, Long doctorId, String startDate, String endDate);

    public List<ClinicAppointment> selectAppointmentsForReminder(String startDate, String endDate);

    /**
     * 统计今日预约数量
     */
    int countTodayAppointments(String date, Long doctorId);

    /**
     * 查询待确认预约列表（带分页限制）
     */
    List<ClinicAppointment> selectPendingAppointmentsList(int limit, Long doctorId);

    // ==================== 订阅相关 ====================

    /**
     * 获取用户订阅配置
     */
    ClinicAppointmentSubscription getSubscriptionByUserId(Long userId);

    /**
     * 保存或更新订阅配置
     */
    int saveOrUpdateSubscription(ClinicAppointmentSubscription subscription);

    /**
     * 更新最后提醒时间
     */
    int updateLastRemindTime(Long subscriptionId);

    // ==================== 叫号相关 ====================

    /**
     * 叫号：将指定预约标记为已叫号状态
     * @param appointmentId 预约ID
     * @return 成功返回true
     */
    boolean callAppointment(Long appointmentId);

    /**
     * 完成就诊：标记预约为已完成，并自动触发下一个预约的叫号
     * @param appointmentId 预约ID
     * @return 成功返回true
     */
    boolean completeAppointment(Long appointmentId);

    /**
     * 获取当日排队队列
     * @param doctorId 医生ID
     * @param date 日期 (yyyy-MM-dd)
     * @return 排队列表
     */
    List<ClinicAppointment> getQueueByDoctorAndDate(Long doctorId, String date);

    /**
     * 获取患者排队位置
     * @param appointmentId 预约ID
     * @return 前面等待人数
     */
    int getQueuePosition(Long appointmentId);

    /**
     * 获取被叫号的预约列表（即将就诊提醒）
     * @param patientId 患者ID
     * @param date 日期 (yyyy-MM-dd)
     * @return 被叫号的预约列表
     */
    List<ClinicAppointment> getCalledAppointments(Long patientId, String date);
}
