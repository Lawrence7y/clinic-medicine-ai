package com.ruoyi.project.clinic.medicine.mapper;

import com.ruoyi.project.clinic.medicine.domain.ClinicPackLossRecord;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

public interface ClinicPackLossRecordMapper {
    int insertPackLossRecord(ClinicPackLossRecord record);

    List<Map<String, Object>> selectPackLossSummary();

    List<ClinicPackLossRecord> selectUnprocessedByMedicineId(@Param("medicineId") Long medicineId);

    int markAsProcessed(@Param("medicineId") Long medicineId);

    int deleteById(@Param("id") Long id);
}