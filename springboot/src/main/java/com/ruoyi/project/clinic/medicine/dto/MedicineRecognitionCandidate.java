package com.ruoyi.project.clinic.medicine.dto;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class MedicineRecognitionCandidate implements Serializable
{
    private static final long serialVersionUID = 1L;

    private String candidateId;
    private String source;
    private Double confidence;
    private Long medicineId;
    private String barcode;
    private String name;
    private String specification;
    private String manufacturer;
    private String dosageForm;
    private String form;
    private String category;
    private String storage;
    private String pharmacology;
    private String indications;
    private String dosage;
    private String sideEffects;
    private List<String> evidenceUrls = new ArrayList<String>();

    public String getCandidateId()
    {
        return candidateId;
    }

    public void setCandidateId(String candidateId)
    {
        this.candidateId = candidateId;
    }

    public String getSource()
    {
        return source;
    }

    public void setSource(String source)
    {
        this.source = source;
    }

    public Double getConfidence()
    {
        return confidence;
    }

    public void setConfidence(Double confidence)
    {
        this.confidence = confidence;
    }

    public Long getMedicineId()
    {
        return medicineId;
    }

    public void setMedicineId(Long medicineId)
    {
        this.medicineId = medicineId;
    }

    public String getBarcode()
    {
        return barcode;
    }

    public void setBarcode(String barcode)
    {
        this.barcode = barcode;
    }

    public String getName()
    {
        return name;
    }

    public void setName(String name)
    {
        this.name = name;
    }

    public String getSpecification()
    {
        return specification;
    }

    public void setSpecification(String specification)
    {
        this.specification = specification;
    }

    public String getManufacturer()
    {
        return manufacturer;
    }

    public void setManufacturer(String manufacturer)
    {
        this.manufacturer = manufacturer;
    }

    public String getDosageForm()
    {
        return dosageForm;
    }

    public void setDosageForm(String dosageForm)
    {
        this.dosageForm = dosageForm;
    }

    public String getForm()
    {
        return form;
    }

    public void setForm(String form)
    {
        this.form = form;
    }

    public String getCategory()
    {
        return category;
    }

    public void setCategory(String category)
    {
        this.category = category;
    }

    public String getStorage()
    {
        return storage;
    }

    public void setStorage(String storage)
    {
        this.storage = storage;
    }

    public String getPharmacology()
    {
        return pharmacology;
    }

    public void setPharmacology(String pharmacology)
    {
        this.pharmacology = pharmacology;
    }

    public String getIndications()
    {
        return indications;
    }

    public void setIndications(String indications)
    {
        this.indications = indications;
    }

    public String getDosage()
    {
        return dosage;
    }

    public void setDosage(String dosage)
    {
        this.dosage = dosage;
    }

    public String getSideEffects()
    {
        return sideEffects;
    }

    public void setSideEffects(String sideEffects)
    {
        this.sideEffects = sideEffects;
    }

    public List<String> getEvidenceUrls()
    {
        return evidenceUrls;
    }

    public void setEvidenceUrls(List<String> evidenceUrls)
    {
        this.evidenceUrls = evidenceUrls != null ? evidenceUrls : new ArrayList<String>();
    }
}
