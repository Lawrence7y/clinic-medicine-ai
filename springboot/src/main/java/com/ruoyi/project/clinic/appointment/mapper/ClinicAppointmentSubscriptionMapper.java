package com.ruoyi.project.clinic.appointment.mapper;

import com.ruoyi.project.clinic.appointment.domain.ClinicAppointmentSubscription;
import org.apache.ibatis.annotations.Param;

public interface ClinicAppointmentSubscriptionMapper {

    public ClinicAppointmentSubscription selectSubscriptionByUserId(@Param("userId") Long userId);

    public int insertSubscription(ClinicAppointmentSubscription subscription);

    public int updateSubscription(ClinicAppointmentSubscription subscription);

    public int updateLastRemindTime(@Param("subscriptionId") Long subscriptionId);

    public int deleteSubscriptionByUserId(@Param("userId") Long userId);
}
