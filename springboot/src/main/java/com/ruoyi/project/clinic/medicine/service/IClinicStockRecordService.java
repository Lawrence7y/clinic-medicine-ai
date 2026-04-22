package com.ruoyi.project.clinic.medicine.service;

import com.ruoyi.project.clinic.medicine.domain.ClinicStockRecord;
import java.util.List;
import java.util.Map;

public interface IClinicStockRecordService {
    public ClinicStockRecord selectClinicStockRecordById(Long recordId);

    public List<ClinicStockRecord> selectClinicStockRecordList(ClinicStockRecord clinicStockRecord);

    public int insertClinicStockRecord(ClinicStockRecord clinicStockRecord);

    public int updateClinicStockRecord(ClinicStockRecord clinicStockRecord);

    public int deleteClinicStockRecordByIds(Long[] recordIds);

    public int deleteClinicStockRecordById(Long recordId);

    public int syncOperatorName(Long operatorId, String operatorName);

    public int syncPatientName(Long patientId, String patientName);

    public int syncDoctorName(Long doctorId, String doctorName);

    /**
     * 查询临期批次（按距有效期天数升序）
     *
     * @param maxDays 临期阈值天数（默认30）
     * @param limit 最多返回条数（null 表示不限制）
     * @param medicineName 药品名称关键字（可空）
     * @return 临期批次列表
     */
    public List<Map<String, Object>> selectNearExpiryBatchWarnings(Integer maxDays, Integer limit, String medicineName);

    /**
     * 根据患者姓名查询出库记录
     *
     * @param patientName 患者姓名
     * @return 出库记录列表
     */
    public List<ClinicStockRecord> selectStockOutRecordsByPatientId(Long patientId);

    /**
     * 一键下架临期批次（将临期批次剩余库存清零并回写药品库存）
     *
     * @param maxDays 临期阈值天数（默认30）
     * @param operatorId 操作人ID
     * @param operatorName 操作人名称
     * @return 下架结果
     */
    public Map<String, Object> offShelfNearExpiryBatches(Integer maxDays, Long operatorId, String operatorName);

    /**
     * 下架指定批次（将批次剩余库存清零并回写药品库存）
     *
     * @param batchId 批次ID
     * @param operatorId 操作人ID
     * @param operatorName 操作人名称
     * @param remark 备注
     * @return 下架结果
     */
    public Map<String, Object> offShelfBatch(Long batchId, Long operatorId, String operatorName, String remark);

    /**
     * 添加包药损耗记录
     *
     * @param medicineId 药品ID
     * @param medicineName 药品名称
     * @param lossQuantity 损耗数量
     * @param relatedRecordId 关联病历ID
     * @param batchNumber 批次号
     * @param operatorName 操作人名称
     */
    public void addPackLossRecord(Long medicineId, String medicineName, Integer lossQuantity, String relatedRecordId, String batchNumber, String operatorName);

    /**
     * 获取包药损耗累计列表
     *
     * @return 包药损耗累计列表
     */
    public List<Map<String, Object>> getPackLossSummary();

    /**
     * 执行包药损耗出库
     *
     * @param medicineId 药品ID
     * @param operatorId 操作人ID
     * @param operatorName 操作人名称
     * @return 出库结果
     */
    public Map<String, Object> executePackLossOut(Long medicineId, Long operatorId, String operatorName);
}
