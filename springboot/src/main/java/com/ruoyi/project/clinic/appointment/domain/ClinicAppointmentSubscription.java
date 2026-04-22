package com.ruoyi.project.clinic.appointment.domain;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.ruoyi.framework.web.domain.BaseEntity;
import org.springframework.format.annotation.DateTimeFormat;

import java.util.Date;

public class ClinicAppointmentSubscription extends BaseEntity {
    private static final long serialVersionUID = 1L;

    private Long subscriptionId;
    private Long userId;
    private String openid;
    private Integer appointmentReminder;
    private Integer remindDaysBefore;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date lastRemindTime;

    private String subscribeStatus;
    private String templateId;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date createTime;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date updateTime;

    public Long getSubscriptionId() {
        return subscriptionId;
    }

    public void setSubscriptionId(Long subscriptionId) {
        this.subscriptionId = subscriptionId;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getOpenid() {
        return openid;
    }

    public void setOpenid(String openid) {
        this.openid = openid;
    }

    public Integer getAppointmentReminder() {
        return appointmentReminder;
    }

    public void setAppointmentReminder(Integer appointmentReminder) {
        this.appointmentReminder = appointmentReminder;
    }

    public Integer getRemindDaysBefore() {
        return remindDaysBefore;
    }

    public void setRemindDaysBefore(Integer remindDaysBefore) {
        this.remindDaysBefore = remindDaysBefore;
    }

    public Date getLastRemindTime() {
        return lastRemindTime;
    }

    public void setLastRemindTime(Date lastRemindTime) {
        this.lastRemindTime = lastRemindTime;
    }

    public String getSubscribeStatus() {
        return subscribeStatus;
    }

    public void setSubscribeStatus(String subscribeStatus) {
        this.subscribeStatus = subscribeStatus;
    }

    public String getTemplateId() {
        return templateId;
    }

    public void setTemplateId(String templateId) {
        this.templateId = templateId;
    }

    public Date getCreateTime() {
        return createTime;
    }

    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }

    public Date getUpdateTime() {
        return updateTime;
    }

    public void setUpdateTime(Date updateTime) {
        this.updateTime = updateTime;
    }
}
