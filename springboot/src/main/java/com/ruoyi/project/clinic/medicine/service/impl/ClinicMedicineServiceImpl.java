package com.ruoyi.project.clinic.medicine.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.security.ShiroUtils;
import com.ruoyi.project.clinic.medicine.mapper.ClinicMedicineMapper;
import com.ruoyi.project.clinic.medicine.domain.ClinicMedicine;
import com.ruoyi.project.clinic.medicine.service.IClinicMedicineService;

@Service
public class ClinicMedicineServiceImpl implements IClinicMedicineService
{
    @Autowired
    private ClinicMedicineMapper clinicMedicineMapper;

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

    private void applyInsertDefaults(ClinicMedicine clinicMedicine)
    {
        if (clinicMedicine.getStock() == null)
        {
            clinicMedicine.setStock(0);
        }
        if (clinicMedicine.getWarningStock() == null)
        {
            clinicMedicine.setWarningStock(10);
        }
        if (clinicMedicine.getWarningThreshold() == null)
        {
            clinicMedicine.setWarningThreshold(10);
        }
        if (clinicMedicine.getMinStock() == null)
        {
            clinicMedicine.setMinStock(10);
        }
        if (clinicMedicine.getIsPrescription() == null)
        {
            clinicMedicine.setIsPrescription(0);
        }
        if (clinicMedicine.getStatus() == null || clinicMedicine.getStatus().trim().isEmpty())
        {
            clinicMedicine.setStatus("active");
        }
        if (clinicMedicine.getCreateBy() == null)
        {
            clinicMedicine.setCreateBy("");
        }
        if (clinicMedicine.getCreateTime() == null)
        {
            clinicMedicine.setCreateTime(DateUtils.getNowDate());
        }
        if (clinicMedicine.getUpdateBy() == null)
        {
            clinicMedicine.setUpdateBy("");
        }
        if (clinicMedicine.getUpdateTime() == null)
        {
            clinicMedicine.setUpdateTime(DateUtils.getNowDate());
        }
    }

    private void normalizeMedicineName(ClinicMedicine clinicMedicine)
    {
        if (clinicMedicine == null)
        {
            return;
        }
        String name = StringUtils.trim(clinicMedicine.getName());
        if (StringUtils.isEmpty(name))
        {
            return;
        }
        // 药品名称不再包含厂商名，避免同一药品多个批次变成不同药品
        // 厂商信息应单独存储在 manufacturer 字段中
        clinicMedicine.setName(name);
    }

    private void normalizeMedicineFields(ClinicMedicine clinicMedicine)
    {
        if (clinicMedicine == null)
        {
            return;
        }
        normalizeMedicineName(clinicMedicine);
        clinicMedicine.setManufacturer(StringUtils.trim(clinicMedicine.getManufacturer()));
        clinicMedicine.setBarcode(StringUtils.trim(clinicMedicine.getBarcode()));
        if (StringUtils.isEmpty(clinicMedicine.getDosageForm()) && StringUtils.isNotEmpty(clinicMedicine.getForm()))
        {
            clinicMedicine.setDosageForm(clinicMedicine.getForm());
        }
        if (StringUtils.isEmpty(clinicMedicine.getForm()) && StringUtils.isNotEmpty(clinicMedicine.getDosageForm()))
        {
            clinicMedicine.setForm(clinicMedicine.getDosageForm());
        }
    }

    @Override
    public ClinicMedicine selectClinicMedicineById(Long medicineId)
    {
        return clinicMedicineMapper.selectClinicMedicineById(medicineId);
    }

    @Override
    public ClinicMedicine selectClinicMedicineByBarcode(String barcode)
    {
        return clinicMedicineMapper.selectClinicMedicineByBarcode(StringUtils.trim(barcode));
    }

    @Override
    public List<ClinicMedicine> selectClinicMedicineList(ClinicMedicine clinicMedicine)
    {
        return clinicMedicineMapper.selectClinicMedicineList(clinicMedicine);
    }

    @Override
    public int insertClinicMedicine(ClinicMedicine clinicMedicine)
    {
        normalizeMedicineFields(clinicMedicine);
        if (clinicMedicine.getCreateBy() == null || clinicMedicine.getCreateBy().trim().isEmpty())
        {
            clinicMedicine.setCreateBy(safeLoginName());
        }
        if (clinicMedicine.getUpdateBy() == null || clinicMedicine.getUpdateBy().trim().isEmpty())
        {
            clinicMedicine.setUpdateBy(clinicMedicine.getCreateBy());
        }
        applyInsertDefaults(clinicMedicine);
        return clinicMedicineMapper.insertClinicMedicine(clinicMedicine);
    }

    @Override
    public int updateClinicMedicine(ClinicMedicine clinicMedicine)
    {
        normalizeMedicineFields(clinicMedicine);
        if (clinicMedicine.getUpdateBy() == null || clinicMedicine.getUpdateBy().trim().isEmpty())
        {
            clinicMedicine.setUpdateBy(safeLoginName());
        }
        if (clinicMedicine.getUpdateTime() == null)
        {
            clinicMedicine.setUpdateTime(DateUtils.getNowDate());
        }
        // 保底：部分前端不传 status 时避免将其更新成 null
        if (clinicMedicine.getStatus() == null || clinicMedicine.getStatus().trim().isEmpty())
        {
            clinicMedicine.setStatus("active");
        }
        return clinicMedicineMapper.updateClinicMedicine(clinicMedicine);
    }

    @Override
    public int deleteClinicMedicineByIds(Long[] medicineIds)
    {
        return clinicMedicineMapper.deleteClinicMedicineByIds(medicineIds);
    }

    @Override
    public int deleteClinicMedicineById(Long medicineId)
    {
        return clinicMedicineMapper.deleteClinicMedicineById(medicineId);
    }

    @Override
    public int countMedicine()
    {
        return clinicMedicineMapper.countMedicine();
    }

    @Override
    public int countLowStockMedicine()
    {
        return clinicMedicineMapper.countLowStockMedicine();
    }

    @Override
    public List<ClinicMedicine> selectMedicineByIds(List<Long> medicineIds)
    {
        if (medicineIds == null || medicineIds.isEmpty())
        {
            return new java.util.ArrayList<>();
        }
        return clinicMedicineMapper.selectMedicineByIds(medicineIds);
    }
}
