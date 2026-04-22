package com.ruoyi.project.clinic.medical.service;

import com.ruoyi.project.clinic.medical.domain.ClinicMedicalRecord;
import java.util.List;

public interface IClinicMedicalRecordService
{
    public ClinicMedicalRecord selectClinicMedicalRecordById(Long recordId);

    public List<ClinicMedicalRecord> selectClinicMedicalRecordList(ClinicMedicalRecord clinicMedicalRecord);

    public int insertClinicMedicalRecord(ClinicMedicalRecord clinicMedicalRecord);

    public int updateClinicMedicalRecord(ClinicMedicalRecord clinicMedicalRecord);

    public int deleteClinicMedicalRecordByIds(Long[] recordIds);

    public int deleteClinicMedicalRecordById(Long recordId);

    public int countMedicalRecord();

    public int syncDoctorName(Long doctorId, String doctorName);

    public int syncPatientInfo(Long patientId, String patientName, String patientPhone);

    /**
     * 统计今日病历数量
     */
    int countTodayRecords(String date, Long doctorId);
}
