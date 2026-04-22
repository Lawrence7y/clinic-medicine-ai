package com.ruoyi.project.clinic.medicine.domain;

import com.fasterxml.jackson.annotation.JsonFormat;
import org.springframework.format.annotation.DateTimeFormat;

import java.util.Date;

public class ClinicPackLossRecord {
    private Long id;
    private Long medicineId;
    private String medicineName;
    private Integer lossQuantity;
    private String relatedRecordId;
    private String batchNumber;
    private Integer isProcessed;
    @JsonFormat(pattern = "yyyy-MM-dd")
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private Date createTime;
    private String operatorName;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getMedicineId() {
        return medicineId;
    }

    public void setMedicineId(Long medicineId) {
        this.medicineId = medicineId;
    }

    public String getMedicineName() {
        return medicineName;
    }

    public void setMedicineName(String medicineName) {
        this.medicineName = medicineName;
    }

    public Integer getLossQuantity() {
        return lossQuantity;
    }

    public void setLossQuantity(Integer lossQuantity) {
        this.lossQuantity = lossQuantity;
    }

    public String getRelatedRecordId() {
        return relatedRecordId;
    }

    public void setRelatedRecordId(String relatedRecordId) {
        this.relatedRecordId = relatedRecordId;
    }

    public String getBatchNumber() {
        return batchNumber;
    }

    public void setBatchNumber(String batchNumber) {
        this.batchNumber = batchNumber;
    }

    public Integer getIsProcessed() {
        return isProcessed;
    }

    public void setIsProcessed(Integer isProcessed) {
        this.isProcessed = isProcessed;
    }

    public Date getCreateTime() {
        return createTime;
    }

    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }

    public String getOperatorName() {
        return operatorName;
    }

    public void setOperatorName(String operatorName) {
        this.operatorName = operatorName;
    }
}