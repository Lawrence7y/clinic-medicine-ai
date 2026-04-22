package com.ruoyi.project.clinic.medicine.dto;

import java.io.Serializable;

public class MedicineRecognitionRequest implements Serializable
{
    private static final long serialVersionUID = 1L;

    private String scene;
    private String code;

    public String getScene()
    {
        return scene;
    }

    public void setScene(String scene)
    {
        this.scene = scene;
    }

    public String getCode()
    {
        return code;
    }

    public void setCode(String code)
    {
        this.code = code;
    }
}
