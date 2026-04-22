package com.ruoyi.project.clinic.medicine.mapper;

import com.ruoyi.project.clinic.medicine.domain.ClinicStockBatch;
import java.util.Date;
import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Param;

public interface ClinicStockBatchMapper
{
    public ClinicStockBatch selectBatchById(@Param("batchId") Long batchId);

    public ClinicStockBatch selectBatchByUniqueForUpdate(@Param("medicineId") Long medicineId,
        @Param("batchNumber") String batchNumber, @Param("expiryDate") Date expiryDate);

    public int insertBatch(ClinicStockBatch batch);

    public int updateBatchRemainingQuantity(@Param("batchId") Long batchId,
        @Param("remainingQuantity") Integer remainingQuantity, @Param("updateTime") Date updateTime);

    public List<ClinicStockBatch> selectUsableBatchesForUpdate(@Param("medicineId") Long medicineId,
        @Param("today") Date today);

    public List<ClinicStockBatch> selectAllBatchesByMedicineForUpdate(@Param("medicineId") Long medicineId);

    public Date selectNearestExpiryDateByMedicineId(@Param("medicineId") Long medicineId);

    public List<ClinicStockBatch> selectBatchListByMedicineId(@Param("medicineId") Long medicineId);

    public List<Map<String, Object>> selectBatchPageList(@Param("medicineName") String medicineName,
        @Param("medicineId") Long medicineId);
}
