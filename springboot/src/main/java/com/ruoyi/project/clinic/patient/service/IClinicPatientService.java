package com.ruoyi.project.clinic.patient.service;

import com.ruoyi.project.clinic.patient.domain.ClinicPatient;
import java.util.List;

public interface IClinicPatientService
{
    public ClinicPatient selectClinicPatientById(Long patientId);

    public ClinicPatient selectClinicPatientByUserId(Long userId);

    public List<ClinicPatient> selectClinicPatientList(ClinicPatient clinicPatient);

    public int insertClinicPatient(ClinicPatient clinicPatient);

    public int updateClinicPatient(ClinicPatient clinicPatient);

    public int deleteClinicPatientByIds(Long[] patientIds);

    public int deleteClinicPatientById(Long patientId);

    public int countPatient();
}
