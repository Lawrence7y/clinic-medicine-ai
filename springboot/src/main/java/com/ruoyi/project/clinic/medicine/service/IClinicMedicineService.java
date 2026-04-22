package com.ruoyi.project.clinic.medicine.service;

import com.ruoyi.project.clinic.medicine.domain.ClinicMedicine;
import java.util.List;

public interface IClinicMedicineService
{
    public ClinicMedicine selectClinicMedicineById(Long medicineId);

    public ClinicMedicine selectClinicMedicineByBarcode(String barcode);

    public List<ClinicMedicine> selectClinicMedicineList(ClinicMedicine clinicMedicine);

    public int insertClinicMedicine(ClinicMedicine clinicMedicine);

    public int updateClinicMedicine(ClinicMedicine clinicMedicine);

    public int deleteClinicMedicineByIds(Long[] medicineIds);

    public int deleteClinicMedicineById(Long medicineId);

    public int countMedicine();

    public int countLowStockMedicine();

    /**
     * 批量查询药品详情（解决N+1查询问题）
     */
    List<ClinicMedicine> selectMedicineByIds(List<Long> medicineIds);
}
