package com.ruoyi.project.clinic.medicine.dto;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class MedicineRecognitionResult implements Serializable
{
    private static final long serialVersionUID = 1L;

    private String scene;
    private String source;
    private String sessionId;
    private boolean localMatched;
    private String recognizedText;
    private Integer imageCount = 0;
    private List<MedicineRecognitionCandidate> candidates = new ArrayList<MedicineRecognitionCandidate>();
    private List<String> warnings = new ArrayList<String>();

    public String getScene()
    {
        return scene;
    }

    public void setScene(String scene)
    {
        this.scene = scene;
    }

    public String getSource()
    {
        return source;
    }

    public void setSource(String source)
    {
        this.source = source;
    }

    public String getSessionId()
    {
        return sessionId;
    }

    public void setSessionId(String sessionId)
    {
        this.sessionId = sessionId;
    }

    public boolean isLocalMatched()
    {
        return localMatched;
    }

    public void setLocalMatched(boolean localMatched)
    {
        this.localMatched = localMatched;
    }

    public String getRecognizedText()
    {
        return recognizedText;
    }

    public void setRecognizedText(String recognizedText)
    {
        this.recognizedText = recognizedText;
    }

    public Integer getImageCount()
    {
        return imageCount;
    }

    public void setImageCount(Integer imageCount)
    {
        this.imageCount = imageCount;
    }

    public List<MedicineRecognitionCandidate> getCandidates()
    {
        return candidates;
    }

    public void setCandidates(List<MedicineRecognitionCandidate> candidates)
    {
        this.candidates = candidates != null ? candidates : new ArrayList<MedicineRecognitionCandidate>();
    }

    public List<String> getWarnings()
    {
        return warnings;
    }

    public void setWarnings(List<String> warnings)
    {
        this.warnings = warnings != null ? warnings : new ArrayList<String>();
    }
}
