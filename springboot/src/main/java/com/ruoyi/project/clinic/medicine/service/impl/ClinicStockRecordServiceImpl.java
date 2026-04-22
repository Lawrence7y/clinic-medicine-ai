package com.ruoyi.project.clinic.medicine.service.impl;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.project.clinic.medical.domain.ClinicMedicalRecord;
import com.ruoyi.project.clinic.medical.service.IClinicMedicalRecordService;
import com.ruoyi.project.clinic.medicine.domain.ClinicMedicine;
import com.ruoyi.project.clinic.medicine.domain.ClinicPackLossRecord;
import com.ruoyi.project.clinic.medicine.domain.ClinicStockBatch;
import com.ruoyi.project.clinic.medicine.domain.ClinicStockRecord;
import com.ruoyi.project.clinic.medicine.mapper.ClinicMedicineMapper;
import com.ruoyi.project.clinic.medicine.mapper.ClinicPackLossRecordMapper;
import com.ruoyi.project.clinic.medicine.mapper.ClinicStockBatchMapper;
import com.ruoyi.project.clinic.medicine.mapper.ClinicStockRecordMapper;
import com.ruoyi.project.clinic.medicine.service.IClinicStockRecordService;
import java.sql.Connection;
import java.sql.Date;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import javax.sql.DataSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ClinicStockRecordServiceImpl implements IClinicStockRecordService
{
    private static final DateTimeFormatter BATCH_DATE_FORMATTER = DateTimeFormatter.BASIC_ISO_DATE;
    private static final Date LEGACY_FALLBACK_EXPIRY = Date.valueOf(LocalDate.of(2099, 12, 31));

    @Autowired
    private ClinicStockRecordMapper clinicStockRecordMapper;

    @Autowired
    private ClinicMedicineMapper clinicMedicineMapper;

    @Autowired
    private ClinicStockBatchMapper clinicStockBatchMapper;

    @Autowired
    private ClinicPackLossRecordMapper clinicPackLossRecordMapper;

    @Autowired
    private IClinicMedicalRecordService clinicMedicalRecordService;

    @Autowired
    private DataSource dataSource;

    private final Object stockRecordSchemaLock = new Object();
    private volatile boolean stockRecordSchemaChecked = false;

    @Override
    public ClinicStockRecord selectClinicStockRecordById(Long recordId)
    {
        ensureStockRecordSchema();
        return clinicStockRecordMapper.selectClinicStockRecordById(recordId);
    }

    @Override
    public List<ClinicStockRecord> selectClinicStockRecordList(ClinicStockRecord clinicStockRecord)
    {
        ensureStockRecordSchema();
        return clinicStockRecordMapper.selectClinicStockRecordList(clinicStockRecord);
    }

    @Override
    @Transactional
    public int insertClinicStockRecord(ClinicStockRecord clinicStockRecord)
    {
        ensureStockRecordSchema();
        if (clinicStockRecord == null || clinicStockRecord.getMedicineId() == null)
        {
            throw new RuntimeException("缺少药品ID");
        }
        if (clinicStockRecord.getQuantity() == null || clinicStockRecord.getQuantity() <= 0)
        {
            throw new RuntimeException("数量必须大于0");
        }
        if (StringUtils.isEmpty(clinicStockRecord.getOperationType()))
        {
            throw new RuntimeException("缺少库存操作类型");
        }

        clinicStockRecord.setSupplier(normalizeBlank(clinicStockRecord.getSupplier()));
        clinicStockRecord.setBatchNumber(normalizeBlank(clinicStockRecord.getBatchNumber()));
        clinicStockRecord.setPatientName(normalizeBlank(clinicStockRecord.getPatientName()));
        clinicStockRecord.setDoctorName(normalizeBlank(clinicStockRecord.getDoctorName()));
        clinicStockRecord.setRelatedRecordId(normalizeBlank(clinicStockRecord.getRelatedRecordId()));
        clinicStockRecord.setRelatedRecordType(normalizeRelatedRecordType(clinicStockRecord.getRelatedRecordType()));
        clinicStockRecord.setPackItems(normalizeBlank(clinicStockRecord.getPackItems()));
        clinicStockRecord.setRemark(normalizeBlank(clinicStockRecord.getRemark()));
        fillPatientAndDoctorFromRelatedRecord(clinicStockRecord);

        ClinicMedicine currentMedicine = clinicMedicineMapper.selectClinicMedicineById(clinicStockRecord.getMedicineId());
        if (currentMedicine == null)
        {
            throw new RuntimeException("药品不存在");
        }

        int beforeStock = currentMedicine.getStock() != null ? currentMedicine.getStock() : 0;
        int operationQuantity = clinicStockRecord.getQuantity() != null ? clinicStockRecord.getQuantity() : 0;
        int afterStock;

        java.util.Date now = new java.util.Date();
        Date today = Date.valueOf(LocalDate.now());

        bootstrapLegacyStockToBatch(currentMedicine, now);

        if ("in".equals(clinicStockRecord.getOperationType()))
        {
            Date stockInExpiryDate = normalizeExpiryDate(clinicStockRecord.getExpiryDate());
            if (stockInExpiryDate == null)
            {
                throw new RuntimeException("入库必须填写有效期");
            }
            if (stockInExpiryDate.before(today))
            {
                throw new RuntimeException("入库有效期不能早于今天");
            }

            // 批次号现在是必填项
            String batchNumber = clinicStockRecord.getBatchNumber();
            if (StringUtils.isEmpty(batchNumber))
            {
                throw new RuntimeException("入库必须填写批次号");
            }

            upsertBatch(currentMedicine.getMedicineId(), batchNumber, stockInExpiryDate, operationQuantity, now);
            clinicStockRecord.setExpiryDate(stockInExpiryDate);
            afterStock = beforeStock + operationQuantity;
        }
        else if ("out".equals(clinicStockRecord.getOperationType()))
        {
            // 检查是否为包药类型，包药不扣减库存
            if (clinicStockRecord.getIsPackMedicine() != null && clinicStockRecord.getIsPackMedicine() == 1)
            {
                // 包药：不扣减库存，只记录流水
                afterStock = beforeStock;
                String packRemark = normalizeBlank(clinicStockRecord.getRemark());
                clinicStockRecord.setRemark(packRemark != null ? packRemark + " [包药不计库存]" : "[包药不计库存]");
                // 记录包药损耗
                addPackLossRecordFromJson(clinicStockRecord, now);
            }
            else
            {
                // 普通出库：扣减库存
                afterStock = beforeStock - operationQuantity;
                if (afterStock < 0)
                {
                    throw new RuntimeException("库存不足");
                }

                validatePrescriptionBinding(clinicStockRecord, currentMedicine);
                BatchConsumeResult consumeResult = consumeFromBatches(currentMedicine.getMedicineId(),
                    clinicStockRecord.getBatchId(), operationQuantity, today, now);
                clinicStockRecord.setBatchNumber(consumeResult.getDisplayBatchNumber());
                clinicStockRecord.setExpiryDate(consumeResult.getFirstExpiryDate());
            }
        }
        else if ("check".equals(clinicStockRecord.getOperationType()))
        {
            // 盘点操作：将库存调整为盘点数量
            afterStock = operationQuantity;
            int difference = afterStock - beforeStock;
            String remark = normalizeBlank(clinicStockRecord.getRemark());
            if (difference > 0)
            {
                remark = (remark != null ? remark + " " : "") + "[盘盈:" + difference + "]";
            }
            else if (difference < 0)
            {
                remark = (remark != null ? remark + " " : "") + "[盘亏:" + Math.abs(difference) + "]";
            }
            else
            {
                remark = (remark != null ? remark + " " : "") + "[账实相符]";
            }
            clinicStockRecord.setRemark(remark);
            clinicStockRecord.setBatchNumber("STOCK_CHECK");
        }
        else
        {
            throw new RuntimeException("不支持的库存操作类型");
        }

        clinicStockRecord.setBeforeStock(beforeStock);
        clinicStockRecord.setAfterStock(afterStock);
        clinicStockRecord.setMedicineName(currentMedicine.getName());
        clinicStockRecord.setCreateTime(now);

        // 包药不扣减库存，无需更新药品库存
        if (!(clinicStockRecord.getIsPackMedicine() != null && clinicStockRecord.getIsPackMedicine() == 1))
        {
            currentMedicine.setStock(afterStock);
            currentMedicine.setUpdateBy(clinicStockRecord.getOperatorName());
            currentMedicine.setUpdateTime(now);
            currentMedicine.setExpiryDate(clinicStockBatchMapper.selectNearestExpiryDateByMedicineId(currentMedicine.getMedicineId()));
            clinicMedicineMapper.updateClinicMedicine(currentMedicine);
        }

        return clinicStockRecordMapper.insertClinicStockRecord(clinicStockRecord);
    }

    private void validatePrescriptionBinding(ClinicStockRecord clinicStockRecord, ClinicMedicine currentMedicine)
    {
        if (currentMedicine.getIsPrescription() == null || currentMedicine.getIsPrescription() != 1)
        {
            return;
        }

        if (StringUtils.isEmpty(clinicStockRecord.getRelatedRecordId()))
        {
            throw new RuntimeException("处方药必须选择关联病历");
        }

        Long recordId;
        try
        {
            recordId = Long.parseLong(clinicStockRecord.getRelatedRecordId());
        }
        catch (NumberFormatException ex)
        {
            throw new RuntimeException("关联病历ID格式不正确");
        }

        ClinicMedicalRecord medicalRecord = clinicMedicalRecordService.selectClinicMedicalRecordById(recordId);
        if (medicalRecord == null)
        {
            throw new RuntimeException("关联病历不存在");
        }

        if (StringUtils.isEmpty(medicalRecord.getPrescription()))
        {
            throw new RuntimeException("该病历没有处方信息");
        }

        boolean foundMedicine = false;
        try
        {
            JSONArray prescriptionArray = JSON.parseArray(medicalRecord.getPrescription());
            for (int i = 0; i < prescriptionArray.size(); i++)
            {
                JSONObject item = prescriptionArray.getJSONObject(i);
                Long itemMedicineId = item.getLong("medicineId");
                if (itemMedicineId != null && itemMedicineId.equals(currentMedicine.getMedicineId()))
                {
                    foundMedicine = true;
                    break;
                }
            }
        }
        catch (Exception e)
        {
            throw new RuntimeException("处方数据格式错误");
        }

        if (!foundMedicine)
        {
            throw new RuntimeException("该病历处方中不包含此药品");
        }
    }

    private void fillPatientAndDoctorFromRelatedRecord(ClinicStockRecord clinicStockRecord)
    {
        if (clinicStockRecord == null || !"medical_record".equals(clinicStockRecord.getRelatedRecordType())
            || StringUtils.isEmpty(clinicStockRecord.getRelatedRecordId()))
        {
            return;
        }

        Long recordId;
        try
        {
            recordId = Long.valueOf(clinicStockRecord.getRelatedRecordId());
        }
        catch (NumberFormatException ex)
        {
            return;
        }

        ClinicMedicalRecord medicalRecord = clinicMedicalRecordService.selectClinicMedicalRecordById(recordId);
        if (medicalRecord == null)
        {
            return;
        }

        clinicStockRecord.setPatientId(medicalRecord.getPatientId());
        clinicStockRecord.setPatientName(normalizeBlank(medicalRecord.getPatientName()));
        clinicStockRecord.setDoctorId(medicalRecord.getDoctorId());
        clinicStockRecord.setDoctorName(normalizeBlank(medicalRecord.getDoctorName()));
    }

    private Date normalizeExpiryDate(java.util.Date expiryDate)
    {
        if (expiryDate == null)
        {
            return null;
        }
        return new Date(expiryDate.getTime());
    }

    private String buildDefaultBatchNumber(Long medicineId, Date expiryDate, java.util.Date now)
    {
        String expiry = expiryDate.toLocalDate().format(BATCH_DATE_FORMATTER);
        long suffix = now.getTime() % 100000;
        return "AUTO-" + medicineId + "-" + expiry + "-" + suffix;
    }

    private void upsertBatch(Long medicineId, String batchNumber, Date expiryDate, int quantity, java.util.Date now)
    {
        ClinicStockBatch existed = clinicStockBatchMapper.selectBatchByUniqueForUpdate(medicineId, batchNumber, expiryDate);
        if (existed == null)
        {
            ClinicStockBatch batch = new ClinicStockBatch();
            batch.setMedicineId(medicineId);
            batch.setBatchNumber(batchNumber);
            batch.setExpiryDate(expiryDate);
            batch.setRemainingQuantity(quantity);
            batch.setCreateTime(now);
            batch.setUpdateTime(now);
            clinicStockBatchMapper.insertBatch(batch);
            return;
        }

        int oldRemaining = existed.getRemainingQuantity() != null ? existed.getRemainingQuantity() : 0;
        clinicStockBatchMapper.updateBatchRemainingQuantity(existed.getBatchId(), oldRemaining + quantity, now);
    }

    private void bootstrapLegacyStockToBatch(ClinicMedicine medicine, java.util.Date now)
    {
        int medicineStock = medicine.getStock() != null ? medicine.getStock() : 0;
        if (medicineStock <= 0)
        {
            return;
        }

        List<ClinicStockBatch> allBatches = clinicStockBatchMapper.selectAllBatchesByMedicineForUpdate(medicine.getMedicineId());
        int summed = 0;
        for (ClinicStockBatch batch : allBatches)
        {
            if (batch.getRemainingQuantity() != null && batch.getRemainingQuantity() > 0)
            {
                summed += batch.getRemainingQuantity();
            }
        }

        if (summed >= medicineStock)
        {
            return;
        }

        int missing = medicineStock - summed;
        Date expiryDate;
        if (medicine.getExpiryDate() != null)
        {
            expiryDate = new Date(medicine.getExpiryDate().getTime());
        }
        else
        {
            expiryDate = LEGACY_FALLBACK_EXPIRY;
        }

        upsertBatch(medicine.getMedicineId(), "INIT-" + medicine.getMedicineId(), expiryDate, missing, now);
    }

    private BatchConsumeResult consumeFromBatches(Long medicineId, Long batchId, int quantity, Date today,
        java.util.Date now)
    {
        List<ClinicStockBatch> usableBatches = clinicStockBatchMapper.selectUsableBatchesForUpdate(medicineId, today);
        if (batchId != null)
        {
            ClinicStockBatch selectedBatch = clinicStockBatchMapper.selectBatchById(batchId);
            if (selectedBatch == null || selectedBatch.getMedicineId() == null
                || !selectedBatch.getMedicineId().equals(medicineId))
            {
                throw new RuntimeException("所选批次不存在");
            }

            if (selectedBatch.getExpiryDate() != null && selectedBatch.getExpiryDate().before(today))
            {
                throw new RuntimeException("所选批次已过期");
            }

            int selectedRemaining = selectedBatch.getRemainingQuantity() != null ? selectedBatch.getRemainingQuantity() : 0;
            if (selectedRemaining < quantity)
            {
                throw new RuntimeException("所选批次库存不足");
            }

            List<ClinicStockBatch> selectedBatches = new ArrayList<>();
            for (ClinicStockBatch batch : usableBatches)
            {
                if (batchId.equals(batch.getBatchId()))
                {
                    selectedBatches.add(batch);
                    break;
                }
            }
            if (selectedBatches.isEmpty())
            {
                throw new RuntimeException("所选批次当前不可出库");
            }
            usableBatches = selectedBatches;
        }

        int totalUsable = 0;
        for (ClinicStockBatch batch : usableBatches)
        {
            totalUsable += batch.getRemainingQuantity() != null ? batch.getRemainingQuantity() : 0;
        }
        if (totalUsable < quantity)
        {
            throw new RuntimeException("可用库存不足（已自动排除过期批次）");
        }

        int remainingNeed = quantity;
        List<String> consumedBatchNumbers = new ArrayList<>();
        java.util.Date firstExpiryDate = null;

        for (ClinicStockBatch batch : usableBatches)
        {
            if (remainingNeed <= 0)
            {
                break;
            }

            int batchRemaining = batch.getRemainingQuantity() != null ? batch.getRemainingQuantity() : 0;
            if (batchRemaining <= 0)
            {
                continue;
            }

            int consume = Math.min(batchRemaining, remainingNeed);
            int newRemaining = batchRemaining - consume;
            clinicStockBatchMapper.updateBatchRemainingQuantity(batch.getBatchId(), newRemaining, now);

            if (consume > 0)
            {
                consumedBatchNumbers.add(batch.getBatchNumber());
                if (firstExpiryDate == null)
                {
                    firstExpiryDate = batch.getExpiryDate();
                }
                remainingNeed -= consume;
            }
        }

        if (remainingNeed > 0)
        {
            throw new RuntimeException("批次库存扣减失败，请稍后重试");
        }

        String displayBatchNumber;
        if (consumedBatchNumbers.isEmpty())
        {
            displayBatchNumber = null;
        }
        else if (consumedBatchNumbers.size() == 1)
        {
            displayBatchNumber = consumedBatchNumbers.get(0);
        }
        else
        {
            displayBatchNumber = consumedBatchNumbers.get(0) + " 等" + consumedBatchNumbers.size() + "个批次";
        }

        return new BatchConsumeResult(displayBatchNumber, firstExpiryDate);
    }

    private String normalizeBlank(String value)
    {
        if (value == null)
        {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private String normalizeRelatedRecordType(String relatedRecordType)
    {
        String normalized = normalizeBlank(relatedRecordType);
        if (normalized == null)
        {
            return null;
        }
        if ("medical".equalsIgnoreCase(normalized) || "medicalrecord".equalsIgnoreCase(normalized))
        {
            return "medical_record";
        }
        return normalized;
    }

    private void ensureStockRecordSchema()
    {
        if (stockRecordSchemaChecked)
        {
            return;
        }

        synchronized (stockRecordSchemaLock)
        {
            if (stockRecordSchemaChecked)
            {
                return;
            }

            try (Connection connection = dataSource.getConnection())
            {
                if (!hasColumn(connection, "clinic_stock_record", "patient_id"))
                {
                    executeDdl(connection,
                        "ALTER TABLE clinic_stock_record ADD COLUMN patient_id BIGINT(20) NULL DEFAULT NULL COMMENT '患者档案ID' AFTER patient_name");
                }
                if (!hasColumn(connection, "clinic_stock_record", "doctor_id"))
                {
                    executeDdl(connection,
                        "ALTER TABLE clinic_stock_record ADD COLUMN doctor_id BIGINT(20) NULL DEFAULT NULL COMMENT '医生用户ID' AFTER doctor_name");
                }
                if (!hasIndex(connection, "clinic_stock_record", "idx_clinic_stock_record_patient_id"))
                {
                    executeDdl(connection,
                        "ALTER TABLE clinic_stock_record ADD INDEX idx_clinic_stock_record_patient_id (patient_id)");
                }
                if (!hasIndex(connection, "clinic_stock_record", "idx_clinic_stock_record_doctor_id"))
                {
                    executeDdl(connection,
                        "ALTER TABLE clinic_stock_record ADD INDEX idx_clinic_stock_record_doctor_id (doctor_id)");
                }
            }
            catch (SQLException ex)
            {
                throw new RuntimeException("初始化库存记录表结构失败", ex);
            }

            stockRecordSchemaChecked = true;
        }
    }

    private boolean hasColumn(Connection connection, String tableName, String columnName) throws SQLException
    {
        DatabaseMetaData metaData = connection.getMetaData();
        try (ResultSet rs = metaData.getColumns(connection.getCatalog(), null, tableName, columnName))
        {
            return rs.next();
        }
    }

    private boolean hasIndex(Connection connection, String tableName, String indexName) throws SQLException
    {
        DatabaseMetaData metaData = connection.getMetaData();
        try (ResultSet rs = metaData.getIndexInfo(connection.getCatalog(), null, tableName, false, false))
        {
            while (rs.next())
            {
                String currentIndexName = rs.getString("INDEX_NAME");
                if (indexName.equalsIgnoreCase(currentIndexName))
                {
                    return true;
                }
            }
        }
        return false;
    }

    private void executeDdl(Connection connection, String sql) throws SQLException
    {
        try (Statement statement = connection.createStatement())
        {
            statement.execute(sql);
        }
        catch (SQLException ex)
        {
            if (!isIgnorableDdlError(ex))
            {
                throw ex;
            }
        }
    }

    private boolean isIgnorableDdlError(SQLException ex)
    {
        if (ex == null)
        {
            return false;
        }

        if (ex.getErrorCode() == 1060 || ex.getErrorCode() == 1061)
        {
            return true;
        }

        String message = ex.getMessage();
        if (message == null)
        {
            return false;
        }

        String normalized = message.toLowerCase(Locale.ROOT);
        return normalized.contains("duplicate column")
            || normalized.contains("duplicate key")
            || normalized.contains("duplicate index")
            || normalized.contains("already exists");
    }

    @Override
    public int updateClinicStockRecord(ClinicStockRecord clinicStockRecord)
    {
        ensureStockRecordSchema();
        return clinicStockRecordMapper.updateClinicStockRecord(clinicStockRecord);
    }

    @Override
    public int deleteClinicStockRecordByIds(Long[] recordIds)
    {
        ensureStockRecordSchema();
        return clinicStockRecordMapper.deleteClinicStockRecordByIds(recordIds);
    }

    @Override
    public int deleteClinicStockRecordById(Long recordId)
    {
        ensureStockRecordSchema();
        return clinicStockRecordMapper.deleteClinicStockRecordById(recordId);
    }

    @Override
    public int syncOperatorName(Long operatorId, String operatorName)
    {
        ensureStockRecordSchema();
        if (operatorId == null || operatorName == null)
        {
            return 0;
        }
        return clinicStockRecordMapper.updateOperatorNameByOperatorId(operatorId, operatorName);
    }

    @Override
    public int syncPatientName(Long patientId, String patientName)
    {
        ensureStockRecordSchema();
        if (patientId == null || StringUtils.isEmpty(patientName))
        {
            return 0;
        }
        return clinicStockRecordMapper.updatePatientNameByPatientId(patientId, patientName);
    }

    @Override
    public int syncDoctorName(Long doctorId, String doctorName)
    {
        ensureStockRecordSchema();
        if (doctorId == null || StringUtils.isEmpty(doctorName))
        {
            return 0;
        }
        return clinicStockRecordMapper.updateDoctorNameByDoctorId(doctorId, doctorName);
    }

    @Override
    public List<Map<String, Object>> selectNearExpiryBatchWarnings(Integer maxDays, Integer limit, String medicineName)
    {
        int thresholdDays = maxDays == null || maxDays <= 0 ? 30 : maxDays;
        Date today = Date.valueOf(LocalDate.now());

        List<Map<String, Object>> allRows = clinicStockBatchMapper.selectBatchPageList(medicineName, null);
        List<Map<String, Object>> nearExpiryRows = new ArrayList<>();

        for (Map<String, Object> row : allRows)
        {
            int remainingQuantity = toInt(row.get("remainingQuantity"));
            if (remainingQuantity <= 0)
            {
                continue;
            }

            Date expiryDate = toSqlDate(row.get("expiryDate"));
            if (expiryDate == null)
            {
                continue;
            }

            long daysToExpiry = (expiryDate.getTime() - today.getTime()) / (24L * 60L * 60L * 1000L);
            if (daysToExpiry > thresholdDays)
            {
                continue;
            }

            Map<String, Object> item = new HashMap<>(row);
            item.put("daysToExpiry", daysToExpiry);
            item.put("nearExpiry", true);
            nearExpiryRows.add(item);
        }

        nearExpiryRows.sort(Comparator.comparingLong(item -> toLong(item.get("daysToExpiry"))));
        if (limit != null && limit > 0 && nearExpiryRows.size() > limit)
        {
            return new ArrayList<>(nearExpiryRows.subList(0, limit));
        }
        return nearExpiryRows;
    }

    @Override
    public List<ClinicStockRecord> selectStockOutRecordsByPatientId(Long patientId)
    {
        ensureStockRecordSchema();
        if (patientId == null)
        {
            return new ArrayList<>();
        }

        ClinicStockRecord query = new ClinicStockRecord();
        query.setPatientId(patientId);
        query.setOperationType("out");
        return clinicStockRecordMapper.selectClinicStockRecordList(query);
    }

    @Override
    @Transactional
    public Map<String, Object> offShelfNearExpiryBatches(Integer maxDays, Long operatorId, String operatorName)
    {
        ensureStockRecordSchema();
        int thresholdDays = maxDays == null || maxDays <= 0 ? 30 : maxDays;
        Date today = Date.valueOf(LocalDate.now());
        java.util.Date now = new java.util.Date();

        List<Map<String, Object>> warningRows = selectNearExpiryBatchWarnings(thresholdDays, null, null);
        Set<Long> medicineIdSet = new HashSet<>();
        for (Map<String, Object> row : warningRows)
        {
            Long medicineId = toLongObj(row.get("medicineId"));
            if (medicineId != null)
            {
                medicineIdSet.add(medicineId);
            }
        }

        int affectedBatchCount = 0;
        int affectedMedicineCount = 0;
        int totalRemovedQuantity = 0;

        for (Long medicineId : medicineIdSet)
        {
            List<ClinicStockBatch> batchList = clinicStockBatchMapper.selectAllBatchesByMedicineForUpdate(medicineId);
            int medicineRemovedQuantity = 0;
            List<String> offShelfBatchNumbers = new ArrayList<>();
            Date firstExpiryDate = null;

            for (ClinicStockBatch batch : batchList)
            {
                int remainingQuantity = batch.getRemainingQuantity() != null ? batch.getRemainingQuantity() : 0;
                if (remainingQuantity <= 0 || batch.getExpiryDate() == null)
                {
                    continue;
                }

                Date expiryDate = new Date(batch.getExpiryDate().getTime());
                long daysToExpiry = (expiryDate.getTime() - today.getTime()) / (24L * 60L * 60L * 1000L);
                if (daysToExpiry < 0 || daysToExpiry > thresholdDays)
                {
                    continue;
                }

                clinicStockBatchMapper.updateBatchRemainingQuantity(batch.getBatchId(), 0, now);
                affectedBatchCount++;
                medicineRemovedQuantity += remainingQuantity;
                totalRemovedQuantity += remainingQuantity;
                offShelfBatchNumbers.add(batch.getBatchNumber());

                if (firstExpiryDate == null || expiryDate.before(firstExpiryDate))
                {
                    firstExpiryDate = expiryDate;
                }
            }

            if (medicineRemovedQuantity <= 0)
            {
                continue;
            }

            ClinicMedicine medicine = clinicMedicineMapper.selectClinicMedicineById(medicineId);
            if (medicine == null)
            {
                continue;
            }

            int beforeStock = medicine.getStock() != null ? medicine.getStock() : 0;
            int afterStock = Math.max(beforeStock - medicineRemovedQuantity, 0);
            medicine.setStock(afterStock);
            medicine.setUpdateBy(StringUtils.isNotEmpty(operatorName) ? operatorName : "system");
            medicine.setUpdateTime(now);
            medicine.setExpiryDate(clinicStockBatchMapper.selectNearestExpiryDateByMedicineId(medicineId));
            clinicMedicineMapper.updateClinicMedicine(medicine);

            ClinicStockRecord stockRecord = new ClinicStockRecord();
            stockRecord.setMedicineId(medicineId);
            stockRecord.setMedicineName(medicine.getName());
            stockRecord.setOperationType("out");
            stockRecord.setQuantity(medicineRemovedQuantity);
            stockRecord.setBeforeStock(beforeStock);
            stockRecord.setAfterStock(afterStock);
            stockRecord.setBatchNumber(buildOffShelfBatchSummary(offShelfBatchNumbers));
            stockRecord.setExpiryDate(firstExpiryDate);
            stockRecord.setOperatorId(operatorId);
            stockRecord.setOperatorName(StringUtils.isNotEmpty(operatorName) ? operatorName : "system");
            stockRecord.setRemark("批量下架临期批次（<= " + thresholdDays + "天）");
            stockRecord.setCreateTime(now);
            clinicStockRecordMapper.insertClinicStockRecord(stockRecord);

            affectedMedicineCount++;
        }

        Map<String, Object> result = new HashMap<>();
        result.put("affectedBatchCount", affectedBatchCount);
        result.put("affectedMedicineCount", affectedMedicineCount);
        result.put("totalRemovedQuantity", totalRemovedQuantity);
        return result;
    }

    @Override
    @Transactional
    public Map<String, Object> offShelfBatch(Long batchId, Long operatorId, String operatorName, String remark)
    {
        ensureStockRecordSchema();
        if (batchId == null)
        {
            throw new RuntimeException("缺少批次ID");
        }

        ClinicStockBatch batch = clinicStockBatchMapper.selectBatchById(batchId);
        if (batch == null)
        {
            throw new RuntimeException("批次不存在");
        }

        int remainingQuantity = batch.getRemainingQuantity() != null ? batch.getRemainingQuantity() : 0;
        if (remainingQuantity <= 0)
        {
            Map<String, Object> result = new HashMap<>();
            result.put("batchId", batchId);
            result.put("offShelfQuantity", 0);
            result.put("message", "该批次已经没有库存");
            return result;
        }

        Long medicineId = batch.getMedicineId();
        ClinicMedicine medicine = clinicMedicineMapper.selectClinicMedicineById(medicineId);
        if (medicine == null)
        {
            throw new RuntimeException("药品不存在");
        }

        java.util.Date now = new java.util.Date();

        // 清零批次库存
        clinicStockBatchMapper.updateBatchRemainingQuantity(batchId, 0, now);

        // 回写药品总库存
        int beforeStock = medicine.getStock() != null ? medicine.getStock() : 0;
        int afterStock = Math.max(beforeStock - remainingQuantity, 0);
        medicine.setStock(afterStock);
        medicine.setUpdateBy(StringUtils.isNotEmpty(operatorName) ? operatorName : "system");
        medicine.setUpdateTime(now);
        medicine.setExpiryDate(clinicStockBatchMapper.selectNearestExpiryDateByMedicineId(medicineId));
        clinicMedicineMapper.updateClinicMedicine(medicine);

        // 插入下架记录
        ClinicStockRecord stockRecord = new ClinicStockRecord();
        stockRecord.setMedicineId(medicineId);
        stockRecord.setMedicineName(medicine.getName());
        stockRecord.setOperationType("out");
        stockRecord.setQuantity(remainingQuantity);
        stockRecord.setBeforeStock(beforeStock);
        stockRecord.setAfterStock(afterStock);
        stockRecord.setBatchNumber(batch.getBatchNumber());
        stockRecord.setExpiryDate(batch.getExpiryDate());
        stockRecord.setOperatorId(operatorId);
        stockRecord.setOperatorName(StringUtils.isNotEmpty(operatorName) ? operatorName : "system");
        stockRecord.setRemark(StringUtils.isNotEmpty(remark) ? remark : "手动下架批次");
        stockRecord.setCreateTime(now);
        clinicStockRecordMapper.insertClinicStockRecord(stockRecord);

        Map<String, Object> result = new HashMap<>();
        result.put("batchId", batchId);
        result.put("offShelfQuantity", remainingQuantity);
        result.put("beforeStock", beforeStock);
        result.put("afterStock", afterStock);
        result.put("batchNumber", batch.getBatchNumber());
        return result;
    }

    private String buildOffShelfBatchSummary(List<String> batchNumbers)
    {
        if (batchNumbers == null || batchNumbers.isEmpty())
        {
            return "临期批次";
        }
        if (batchNumbers.size() <= 2)
        {
            return String.join("、", batchNumbers);
        }
        return batchNumbers.get(0) + " 等" + batchNumbers.size() + "个批次";
    }

    private int toInt(Object value)
    {
        if (value == null)
        {
            return 0;
        }
        if (value instanceof Number)
        {
            return ((Number) value).intValue();
        }
        try
        {
            return Integer.parseInt(String.valueOf(value));
        }
        catch (Exception e)
        {
            return 0;
        }
    }

    private long toLong(Object value)
    {
        if (value == null)
        {
            return 0L;
        }
        if (value instanceof Number)
        {
            return ((Number) value).longValue();
        }
        try
        {
            return Long.parseLong(String.valueOf(value));
        }
        catch (Exception e)
        {
            return 0L;
        }
    }

    private Long toLongObj(Object value)
    {
        if (value == null)
        {
            return null;
        }
        if (value instanceof Number)
        {
            return ((Number) value).longValue();
        }
        try
        {
            return Long.valueOf(String.valueOf(value));
        }
        catch (Exception e)
        {
            return null;
        }
    }

    private Date toSqlDate(Object value)
    {
        if (value == null)
        {
            return null;
        }
        if (value instanceof Date)
        {
            return (Date) value;
        }
        if (value instanceof java.util.Date)
        {
            return new Date(((java.util.Date) value).getTime());
        }
        try
        {
            return Date.valueOf(String.valueOf(value));
        }
        catch (Exception e)
        {
            return null;
        }
    }

    private static class BatchConsumeResult
    {
        private final String displayBatchNumber;
        private final java.util.Date firstExpiryDate;

        BatchConsumeResult(String displayBatchNumber, java.util.Date firstExpiryDate)
        {
            this.displayBatchNumber = displayBatchNumber;
            this.firstExpiryDate = firstExpiryDate;
        }

        public String getDisplayBatchNumber()
        {
            return displayBatchNumber;
        }

        public java.util.Date getFirstExpiryDate()
        {
            return firstExpiryDate;
        }
    }

    @Override
    public void addPackLossRecord(Long medicineId, String medicineName, Integer lossQuantity, String relatedRecordId, String batchNumber, String operatorName) {
        ClinicPackLossRecord record = new ClinicPackLossRecord();
        record.setMedicineId(medicineId);
        record.setMedicineName(medicineName);
        record.setLossQuantity(lossQuantity);
        record.setRelatedRecordId(relatedRecordId);
        record.setBatchNumber(batchNumber);
        record.setOperatorName(operatorName);
        record.setCreateTime(new java.util.Date());
        clinicPackLossRecordMapper.insertPackLossRecord(record);
    }

    @Override
    public List<Map<String, Object>> getPackLossSummary() {
        return clinicPackLossRecordMapper.selectPackLossSummary();
    }

    @Override
    @Transactional
    public Map<String, Object> executePackLossOut(Long medicineId, Long operatorId, String operatorName) {
        Map<String, Object> result = new HashMap<>();
        List<ClinicPackLossRecord> unprocessedRecords = clinicPackLossRecordMapper.selectUnprocessedByMedicineId(medicineId);
        if (unprocessedRecords == null || unprocessedRecords.isEmpty()) {
            result.put("success", false);
            result.put("message", "没有未处理的包药损耗记录");
            return result;
        }
        int totalLossQuantity = unprocessedRecords.stream().mapToInt(ClinicPackLossRecord::getLossQuantity).sum();
        ClinicMedicine medicine = clinicMedicineMapper.selectClinicMedicineById(medicineId);
        if (medicine == null) {
            result.put("success", false);
            result.put("message", "药品不存在");
            return result;
        }
        ClinicStockRecord stockRecord = new ClinicStockRecord();
        stockRecord.setOperationType("out");
        stockRecord.setMedicineId(medicineId);
        stockRecord.setQuantity(totalLossQuantity);
        stockRecord.setPatientName("包药损耗");
        stockRecord.setDoctorName(operatorName);
        stockRecord.setRelatedRecordId(null);
        stockRecord.setRelatedRecordType(null);
        stockRecord.setRemark("包药损耗出库");
        stockRecord.setIsPackMedicine(0);
        stockRecord.setOperatorName(operatorName);
        insertClinicStockRecord(stockRecord);
        clinicPackLossRecordMapper.markAsProcessed(medicineId);
        result.put("success", true);
        result.put("message", "出库成功");
        result.put("lossQuantity", totalLossQuantity);
        result.put("medicineName", medicine.getName());
        return result;
    }

    private void addPackLossRecordFromJson(ClinicStockRecord clinicStockRecord, java.util.Date now) {
        String packItemsJson = clinicStockRecord.getPackItems();
        if (StringUtils.isEmpty(packItemsJson)) {
            return;
        }
        try {
            JSONArray packItems = JSON.parseArray(packItemsJson);
            if (packItems == null || packItems.isEmpty()) {
                return;
            }
            for (int i = 0; i < packItems.size(); i++) {
                JSONObject item = packItems.getJSONObject(i);
                Long itemMedicineId = item.getLong("medicineId");
                String itemName = item.getString("name");
                Integer quantity = item.getInteger("quantity");
                String batchNumber = item.getString("batchNumber");
                if (itemMedicineId == null || quantity == null) {
                    continue;
                }
                ClinicPackLossRecord record = new ClinicPackLossRecord();
                record.setMedicineId(itemMedicineId);
                record.setMedicineName(itemName);
                record.setLossQuantity(quantity);
                record.setRelatedRecordId(clinicStockRecord.getRelatedRecordId());
                record.setBatchNumber(batchNumber);
                record.setOperatorName(clinicStockRecord.getOperatorName());
                record.setCreateTime(now);
                clinicPackLossRecordMapper.insertPackLossRecord(record);
            }
        } catch (Exception e) {
            throw new RuntimeException("解析包药明细失败: " + e.getMessage());
        }
    }
}
