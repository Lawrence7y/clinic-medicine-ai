package com.ruoyi.project.clinic.prescription.mapper;

import com.ruoyi.project.clinic.prescription.domain.ClinicPrescription;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface ClinicPrescriptionMapper {

    public ClinicPrescription selectPrescriptionById(@Param("prescriptionId") Long prescriptionId);

    public List<ClinicPrescription> selectPrescriptionList(ClinicPrescription prescription);

    public int insertPrescription(ClinicPrescription prescription);

    public int updatePrescription(ClinicPrescription prescription);

    public int deletePrescriptionById(@Param("prescriptionId") Long prescriptionId);

    public int deletePrescriptionByIds(@Param("prescriptionIds") Long[] prescriptionIds);

    public int countPrescriptionByPatient(@Param("patientId") Long patientId);
}
