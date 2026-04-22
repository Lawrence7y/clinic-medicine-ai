package com.ruoyi.project.clinic.prescription.service.impl;

import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.security.ShiroUtils;
import com.ruoyi.project.clinic.prescription.domain.ClinicPrescription;
import com.ruoyi.project.clinic.prescription.mapper.ClinicPrescriptionMapper;
import com.ruoyi.project.clinic.prescription.service.IClinicPrescriptionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class ClinicPrescriptionServiceImpl implements IClinicPrescriptionService {

    @Autowired
    private ClinicPrescriptionMapper clinicPrescriptionMapper;

    private String safeLoginName() {
        try {
            String loginName = ShiroUtils.getLoginName();
            return loginName != null ? loginName : "";
        } catch (Exception ignored) {
            return "";
        }
    }

    @Override
    public ClinicPrescription selectPrescriptionById(Long prescriptionId) {
        return clinicPrescriptionMapper.selectPrescriptionById(prescriptionId);
    }

    @Override
    public List<ClinicPrescription> selectPrescriptionList(ClinicPrescription prescription) {
        return clinicPrescriptionMapper.selectPrescriptionList(prescription);
    }

    @Override
    @Transactional
    public int insertPrescription(ClinicPrescription prescription) {
        if (prescription.getCreateBy() == null || prescription.getCreateBy().trim().isEmpty()) {
            prescription.setCreateBy(safeLoginName());
        }
        if (prescription.getCreateTime() == null) {
            prescription.setCreateTime(DateUtils.getNowDate());
        }
        if (prescription.getStatus() == null || prescription.getStatus().trim().isEmpty()) {
            prescription.setStatus("active");
        }
        return clinicPrescriptionMapper.insertPrescription(prescription);
    }

    @Override
    @Transactional
    public int updatePrescription(ClinicPrescription prescription) {
        if (prescription.getUpdateBy() == null || prescription.getUpdateBy().trim().isEmpty()) {
            prescription.setUpdateBy(safeLoginName());
        }
        if (prescription.getUpdateTime() == null) {
            prescription.setUpdateTime(DateUtils.getNowDate());
        }
        return clinicPrescriptionMapper.updatePrescription(prescription);
    }

    @Override
    @Transactional
    public int deletePrescriptionById(Long prescriptionId) {
        return clinicPrescriptionMapper.deletePrescriptionById(prescriptionId);
    }

    @Override
    @Transactional
    public int deletePrescriptionByIds(Long[] prescriptionIds) {
        return clinicPrescriptionMapper.deletePrescriptionByIds(prescriptionIds);
    }

    @Override
    public int countPrescriptionByPatient(Long patientId) {
        return clinicPrescriptionMapper.countPrescriptionByPatient(patientId);
    }

    @Override
    public List<ClinicPrescription> selectPrescriptionByPatientId(Long patientId) {
        ClinicPrescription prescription = new ClinicPrescription();
        prescription.setPatientId(patientId);
        return clinicPrescriptionMapper.selectPrescriptionList(prescription);
    }
}
