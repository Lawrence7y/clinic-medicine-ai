package com.ruoyi.project.clinic.medicine.mapper;

import com.ruoyi.project.clinic.medicine.domain.ClinicMedicine;
import java.util.List;

public interface ClinicMedicineMapper
{
    public ClinicMedicine selectClinicMedicineById(Long medicineId);

    public List<ClinicMedicine> selectClinicMedicineList(ClinicMedicine clinicMedicine);

    public ClinicMedicine selectClinicMedicineByBarcode(String barcode);

    public int insertClinicMedicine(ClinicMedicine clinicMedicine);

    public int updateClinicMedicine(ClinicMedicine clinicMedicine);

    public int deleteClinicMedicineById(Long medicineId);

    public int deleteClinicMedicineByIds(Long[] medicineIds);

    public int countMedicine();

    public int countLowStockMedicine();

    List<ClinicMedicine> selectMedicineByIds(java.util.List<Long> medicineIds);
}
