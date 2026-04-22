package com.ruoyi.project.clinic.prescription.service;

import com.ruoyi.project.clinic.prescription.domain.ClinicPrescription;

import java.util.List;

public interface IClinicPrescriptionService {

    public ClinicPrescription selectPrescriptionById(Long prescriptionId);

    public List<ClinicPrescription> selectPrescriptionList(ClinicPrescription prescription);

    public int insertPrescription(ClinicPrescription prescription);

    public int updatePrescription(ClinicPrescription prescription);

    public int deletePrescriptionById(Long prescriptionId);

    public int deletePrescriptionByIds(Long[] prescriptionIds);

    public int countPrescriptionByPatient(Long patientId);

    public List<ClinicPrescription> selectPrescriptionByPatientId(Long patientId);
}
