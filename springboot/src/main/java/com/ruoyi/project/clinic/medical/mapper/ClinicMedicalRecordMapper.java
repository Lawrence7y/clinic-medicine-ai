package com.ruoyi.project.clinic.medical.mapper;

import com.ruoyi.project.clinic.medical.domain.ClinicMedicalRecord;
import java.util.List;
import org.apache.ibatis.annotations.Param;

public interface ClinicMedicalRecordMapper
{
    public ClinicMedicalRecord selectClinicMedicalRecordById(Long recordId);

    public List<ClinicMedicalRecord> selectClinicMedicalRecordList(ClinicMedicalRecord clinicMedicalRecord);

    public int insertClinicMedicalRecord(ClinicMedicalRecord clinicMedicalRecord);

    public int updateClinicMedicalRecord(ClinicMedicalRecord clinicMedicalRecord);

    public int deleteClinicMedicalRecordById(Long recordId);

    public int deleteClinicMedicalRecordByIds(Long[] recordIds);

    public int countMedicalRecord();

    public int updateDoctorNameByDoctorId(@Param("doctorId") Long doctorId, @Param("doctorName") String doctorName);

    public int updatePatientInfoByPatientId(@Param("patientId") Long patientId,
                                            @Param("patientName") String patientName,
                                            @Param("patientPhone") String patientPhone);

    int countTodayRecords(@Param("date") String date, @Param("doctorId") Long doctorId);
}
