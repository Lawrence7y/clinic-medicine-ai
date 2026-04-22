package com.ruoyi.project.clinic.medicine.mapper;

import com.ruoyi.project.clinic.medicine.domain.ClinicStockRecord;
import java.util.List;
import org.apache.ibatis.annotations.Param;

public interface ClinicStockRecordMapper {
    public ClinicStockRecord selectClinicStockRecordById(Long recordId);

    public List<ClinicStockRecord> selectClinicStockRecordList(ClinicStockRecord clinicStockRecord);

    public int insertClinicStockRecord(ClinicStockRecord clinicStockRecord);

    public int updateClinicStockRecord(ClinicStockRecord clinicStockRecord);

    public int deleteClinicStockRecordById(Long recordId);

    public int deleteClinicStockRecordByIds(Long[] recordIds);

    public int updateOperatorNameByOperatorId(@Param("operatorId") Long operatorId, @Param("operatorName") String operatorName);

    public int updatePatientNameByPatientId(@Param("patientId") Long patientId, @Param("patientName") String patientName);

    public int updateDoctorNameByDoctorId(@Param("doctorId") Long doctorId, @Param("doctorName") String doctorName);
}
