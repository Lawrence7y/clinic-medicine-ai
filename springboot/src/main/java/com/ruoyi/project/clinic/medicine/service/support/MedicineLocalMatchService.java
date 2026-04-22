package com.ruoyi.project.clinic.medicine.service.support;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.project.clinic.medicine.domain.ClinicMedicine;
import com.ruoyi.project.clinic.medicine.dto.MedicineRecognitionCandidate;
import com.ruoyi.project.clinic.medicine.service.IClinicMedicineService;

@Service
public class MedicineLocalMatchService
{
    @Autowired
    private IClinicMedicineService clinicMedicineService;

    public ClinicMedicine selectByBarcode(String barcode)
    {
        String normalizedBarcode = StringUtils.trim(barcode);
        if (StringUtils.isEmpty(normalizedBarcode))
        {
            return null;
        }
        return clinicMedicineService.selectClinicMedicineByBarcode(normalizedBarcode);
    }

    public ClinicMedicine findExistingMedicine(MedicineRecognitionCandidate candidate)
    {
        if (candidate == null)
        {
            return null;
        }
        ClinicMedicine barcodeMatch = selectByBarcode(candidate.getBarcode());
        if (barcodeMatch != null)
        {
            return barcodeMatch;
        }
        if (StringUtils.isEmpty(candidate.getName()))
        {
            return null;
        }
        ClinicMedicine query = new ClinicMedicine();
        query.setName(candidate.getName());
        List<ClinicMedicine> list = clinicMedicineService.selectClinicMedicineList(query);
        if (list == null || list.isEmpty())
        {
            return null;
        }
        for (ClinicMedicine item : list)
        {
            if (sameText(item.getName(), candidate.getName())
                    && sameText(item.getManufacturer(), candidate.getManufacturer())
                    && sameText(item.getSpecification(), candidate.getSpecification()))
            {
                return item;
            }
        }
        return list.get(0);
    }

    public MedicineRecognitionCandidate buildCandidate(ClinicMedicine medicine, String source, double confidence)
    {
        MedicineRecognitionCandidate candidate = new MedicineRecognitionCandidate();
        if (medicine == null)
        {
            candidate.setSource(source);
            candidate.setConfidence(confidence);
            return candidate;
        }
        candidate.setCandidateId("local_" + medicine.getMedicineId());
        candidate.setSource(source);
        candidate.setConfidence(confidence);
        candidate.setMedicineId(medicine.getMedicineId());
        candidate.setBarcode(medicine.getBarcode());
        candidate.setName(medicine.getName());
        candidate.setSpecification(medicine.getSpecification());
        candidate.setManufacturer(medicine.getManufacturer());
        candidate.setDosageForm(medicine.getDosageForm());
        candidate.setForm(medicine.getForm());
        candidate.setCategory(medicine.getCategory());
        candidate.setStorage(medicine.getStorage());
        candidate.setPharmacology(medicine.getPharmacology());
        candidate.setIndications(medicine.getIndications());
        candidate.setDosage(medicine.getDosage());
        candidate.setSideEffects(medicine.getSideEffects());
        return candidate;
    }

    private boolean sameText(String left, String right)
    {
        String leftText = StringUtils.trim(left);
        String rightText = StringUtils.trim(right);
        if (StringUtils.isEmpty(leftText) && StringUtils.isEmpty(rightText))
        {
            return true;
        }
        if (StringUtils.isEmpty(leftText) || StringUtils.isEmpty(rightText))
        {
            return false;
        }
        return leftText.equalsIgnoreCase(rightText);
    }
}
