package com.ruoyi.project.clinic.medicine.domain;

import java.util.Date;

public class ClinicStockBatch
{
    private Long batchId;
    private Long medicineId;
    private String batchNumber;
    private Date expiryDate;
    private Integer remainingQuantity;
    private Date createTime;
    private Date updateTime;

    public Long getBatchId()
    {
        return batchId;
    }

    public void setBatchId(Long batchId)
    {
        this.batchId = batchId;
    }

    public Long getMedicineId()
    {
        return medicineId;
    }

    public void setMedicineId(Long medicineId)
    {
        this.medicineId = medicineId;
    }

    public String getBatchNumber()
    {
        return batchNumber;
    }

    public void setBatchNumber(String batchNumber)
    {
        this.batchNumber = batchNumber;
    }

    public Date getExpiryDate()
    {
        return expiryDate;
    }

    public void setExpiryDate(Date expiryDate)
    {
        this.expiryDate = expiryDate;
    }

    public Integer getRemainingQuantity()
    {
        return remainingQuantity;
    }

    public void setRemainingQuantity(Integer remainingQuantity)
    {
        this.remainingQuantity = remainingQuantity;
    }

    public Date getCreateTime()
    {
        return createTime;
    }

    public void setCreateTime(Date createTime)
    {
        this.createTime = createTime;
    }

    public Date getUpdateTime()
    {
        return updateTime;
    }

    public void setUpdateTime(Date updateTime)
    {
        this.updateTime = updateTime;
    }
}
