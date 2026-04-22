package com.ruoyi.project.clinic.medical.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.security.ShiroUtils;
import com.ruoyi.project.clinic.medical.mapper.ClinicMedicalRecordMapper;
import com.ruoyi.project.clinic.medical.domain.ClinicMedicalRecord;
import com.ruoyi.project.clinic.medical.service.IClinicMedicalRecordService;

@Service
public class ClinicMedicalRecordServiceImpl implements IClinicMedicalRecordService
{
    @Autowired
    private ClinicMedicalRecordMapper clinicMedicalRecordMapper;

    private String safeLoginName()
    {
        try
        {
            String loginName = ShiroUtils.getLoginName();
            return loginName != null ? loginName : "";
        }
        catch (Exception ignored)
        {
            return "";
        }
    }

    @Override
    public ClinicMedicalRecord selectClinicMedicalRecordById(Long recordId)
    {
        return clinicMedicalRecordMapper.selectClinicMedicalRecordById(recordId);
    }

    @Override
    public List<ClinicMedicalRecord> selectClinicMedicalRecordList(ClinicMedicalRecord clinicMedicalRecord)
    {
        return clinicMedicalRecordMapper.selectClinicMedicalRecordList(clinicMedicalRecord);
    }

    @Override
    public int insertClinicMedicalRecord(ClinicMedicalRecord clinicMedicalRecord)
    {
        if (clinicMedicalRecord.getCreateBy() == null || clinicMedicalRecord.getCreateBy().trim().isEmpty())
        {
            clinicMedicalRecord.setCreateBy(safeLoginName());
        }
        if (clinicMedicalRecord.getCreateTime() == null)
        {
            clinicMedicalRecord.setCreateTime(DateUtils.getNowDate());
        }
        return clinicMedicalRecordMapper.insertClinicMedicalRecord(clinicMedicalRecord);
    }

    @Override
    public int updateClinicMedicalRecord(ClinicMedicalRecord clinicMedicalRecord)
    {
        if (clinicMedicalRecord.getUpdateBy() == null || clinicMedicalRecord.getUpdateBy().trim().isEmpty())
        {
            clinicMedicalRecord.setUpdateBy(safeLoginName());
        }
        if (clinicMedicalRecord.getUpdateTime() == null)
        {
            clinicMedicalRecord.setUpdateTime(DateUtils.getNowDate());
        }
        return clinicMedicalRecordMapper.updateClinicMedicalRecord(clinicMedicalRecord);
    }

    @Override
    public int deleteClinicMedicalRecordByIds(Long[] recordIds)
    {
        return clinicMedicalRecordMapper.deleteClinicMedicalRecordByIds(recordIds);
    }

    @Override
    public int deleteClinicMedicalRecordById(Long recordId)
    {
        return clinicMedicalRecordMapper.deleteClinicMedicalRecordById(recordId);
    }

    @Override
    public int countMedicalRecord()
    {
        return clinicMedicalRecordMapper.countMedicalRecord();
    }

    @Override
    public int syncDoctorName(Long doctorId, String doctorName)
    {
        if (doctorId == null || doctorName == null)
        {
            return 0;
        }
        return clinicMedicalRecordMapper.updateDoctorNameByDoctorId(doctorId, doctorName);
    }

    @Override
    public int syncPatientInfo(Long patientId, String patientName, String patientPhone)
    {
        if (patientId == null)
        {
            return 0;
        }
        return clinicMedicalRecordMapper.updatePatientInfoByPatientId(patientId, patientName, patientPhone);
    }

    @Override
    public int countTodayRecords(String date, Long doctorId)
    {
        return clinicMedicalRecordMapper.countTodayRecords(date, doctorId);
    }
}
