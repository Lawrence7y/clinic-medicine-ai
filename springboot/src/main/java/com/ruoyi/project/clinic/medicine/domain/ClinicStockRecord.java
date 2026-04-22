package com.ruoyi.project.clinic.medicine.domain;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.ruoyi.framework.web.domain.BaseEntity;
import org.springframework.format.annotation.DateTimeFormat;

import java.math.BigDecimal;
import java.util.Date;

public class ClinicStockRecord extends BaseEntity {
    private static final long serialVersionUID = 1L;

    /** 分页参数：页码 */
    private Integer pageNum;

    /** 分页参数：每页数量 */
    private Integer pageSize;

    private Long recordId;
    private Long medicineId;
    private String medicineName;
    private String operationType;
    private Integer quantity;
    private Integer beforeStock;
    private Integer afterStock;
    private String supplier;
    private BigDecimal purchasePrice;
    private String batchNumber;
    private Long batchId;
    @JsonFormat(pattern = "yyyy-MM-dd")
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private Date expiryDate;
    private Long operatorId;
    private String operatorName;
    private Long patientId;
    private String patientName;
    private Long doctorId;
    private String doctorName;
    private String relatedRecordId;
    private String relatedRecordType;
    /** 是否包药标识：1=包药（不扣减库存），0或null=普通出库 */
    private Integer isPackMedicine;
    /** 包药明细：JSON字符串，包含 [{medicineId, name, quantity, batchId, batchNumber}] */
    private String packItems;
    private String remark;
    private String keyword;
    private Date createTime;

    public Integer getPageNum() {
        return pageNum;
    }

    public void setPageNum(Integer pageNum) {
        this.pageNum = pageNum;
    }

    public Integer getPageSize() {
        return pageSize;
    }

    public void setPageSize(Integer pageSize) {
        this.pageSize = pageSize;
    }

    public Long getRecordId() {
        return recordId;
    }

    public void setRecordId(Long recordId) {
        this.recordId = recordId;
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

    public String getOperationType() {
        return operationType;
    }

    public void setOperationType(String operationType) {
        this.operationType = operationType;
    }

    public Integer getQuantity() {
        return quantity;
    }

    public void setQuantity(Integer quantity) {
        this.quantity = quantity;
    }

    public Integer getBeforeStock() {
        return beforeStock;
    }

    public void setBeforeStock(Integer beforeStock) {
        this.beforeStock = beforeStock;
    }

    public Integer getAfterStock() {
        return afterStock;
    }

    public void setAfterStock(Integer afterStock) {
        this.afterStock = afterStock;
    }

    public String getSupplier() {
        return supplier;
    }

    public void setSupplier(String supplier) {
        this.supplier = supplier;
    }

    public BigDecimal getPurchasePrice() {
        return purchasePrice;
    }

    public void setPurchasePrice(BigDecimal purchasePrice) {
        this.purchasePrice = purchasePrice;
    }

    public String getBatchNumber() {
        return batchNumber;
    }

    public void setBatchNumber(String batchNumber) {
        this.batchNumber = batchNumber;
    }

    public Long getBatchId() {
        return batchId;
    }

    public void setBatchId(Long batchId) {
        this.batchId = batchId;
    }

    public Date getExpiryDate() {
        return expiryDate;
    }

    public void setExpiryDate(Date expiryDate) {
        this.expiryDate = expiryDate;
    }

    public Long getOperatorId() {
        return operatorId;
    }

    public void setOperatorId(Long operatorId) {
        this.operatorId = operatorId;
    }

    public String getOperatorName() {
        return operatorName;
    }

    public void setOperatorName(String operatorName) {
        this.operatorName = operatorName;
    }

    public Long getPatientId() {
        return patientId;
    }

    public void setPatientId(Long patientId) {
        this.patientId = patientId;
    }

    public String getPatientName() {
        return patientName;
    }

    public void setPatientName(String patientName) {
        this.patientName = patientName;
    }

    public Long getDoctorId() {
        return doctorId;
    }

    public void setDoctorId(Long doctorId) {
        this.doctorId = doctorId;
    }

    public String getDoctorName() {
        return doctorName;
    }

    public void setDoctorName(String doctorName) {
        this.doctorName = doctorName;
    }

    public String getRelatedRecordId() {
        return relatedRecordId;
    }

    public void setRelatedRecordId(String relatedRecordId) {
        this.relatedRecordId = relatedRecordId;
    }

    public String getRelatedRecordType() {
        return relatedRecordType;
    }

    public void setRelatedRecordType(String relatedRecordType) {
        this.relatedRecordType = relatedRecordType;
    }

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }

    public Integer getIsPackMedicine() {
        return isPackMedicine;
    }

    public void setIsPackMedicine(Integer isPackMedicine) {
        this.isPackMedicine = isPackMedicine;
    }

    public String getPackItems() {
        return packItems;
    }

    public void setPackItems(String packItems) {
        this.packItems = packItems;
    }

    public String getKeyword() {
        return keyword;
    }

    public void setKeyword(String keyword) {
        this.keyword = keyword;
    }

    @Override
    public Date getCreateTime() {
        return createTime;
    }

    @Override
    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }
}
