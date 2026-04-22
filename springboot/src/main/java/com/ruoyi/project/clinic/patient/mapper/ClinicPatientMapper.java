package com.ruoyi.project.clinic.patient.mapper;

import com.ruoyi.project.clinic.patient.domain.ClinicPatient;
import java.util.List;

public interface ClinicPatientMapper
{
    public ClinicPatient selectClinicPatientById(Long patientId);

    public ClinicPatient selectClinicPatientByUserId(Long userId);

    public List<ClinicPatient> selectClinicPatientList(ClinicPatient clinicPatient);

    public List<ClinicPatient> selectClinicPatientByIds(Long[] patientIds);

    public int insertClinicPatient(ClinicPatient clinicPatient);

    public int updateClinicPatient(ClinicPatient clinicPatient);

    public int deleteClinicPatientById(Long patientId);

    public int deleteClinicPatientByIds(Long[] patientIds);

    public int countPatient();
}
