package com.ruoyi.project.clinic.ai.domain;

import com.ruoyi.framework.web.domain.BaseEntity;

public class ClinicAiSceneBinding extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long sceneId;
    private String sceneCode;
    private String sceneName;
    private String executionMode;
    private Long primaryModelId;
    private Long fallbackModelId;
    private String primaryModelName;
    private String fallbackModelName;
    private Integer candidateLimit;
    private Integer timeoutMs;
    private Integer enabled;

    public Long getSceneId()
    {
        return sceneId;
    }

    public void setSceneId(Long sceneId)
    {
        this.sceneId = sceneId;
    }

    public String getSceneCode()
    {
        return sceneCode;
    }

    public void setSceneCode(String sceneCode)
    {
        this.sceneCode = sceneCode;
    }

    public String getSceneName()
    {
        return sceneName;
    }

    public void setSceneName(String sceneName)
    {
        this.sceneName = sceneName;
    }

    public String getExecutionMode()
    {
        return executionMode;
    }

    public void setExecutionMode(String executionMode)
    {
        this.executionMode = executionMode;
    }

    public Long getPrimaryModelId()
    {
        return primaryModelId;
    }

    public void setPrimaryModelId(Long primaryModelId)
    {
        this.primaryModelId = primaryModelId;
    }

    public Long getFallbackModelId()
    {
        return fallbackModelId;
    }

    public void setFallbackModelId(Long fallbackModelId)
    {
        this.fallbackModelId = fallbackModelId;
    }

    public String getPrimaryModelName()
    {
        return primaryModelName;
    }

    public void setPrimaryModelName(String primaryModelName)
    {
        this.primaryModelName = primaryModelName;
    }

    public String getFallbackModelName()
    {
        return fallbackModelName;
    }

    public void setFallbackModelName(String fallbackModelName)
    {
        this.fallbackModelName = fallbackModelName;
    }

    public Integer getCandidateLimit()
    {
        return candidateLimit;
    }

    public void setCandidateLimit(Integer candidateLimit)
    {
        this.candidateLimit = candidateLimit;
    }

    public Integer getTimeoutMs()
    {
        return timeoutMs;
    }

    public void setTimeoutMs(Integer timeoutMs)
    {
        this.timeoutMs = timeoutMs;
    }

    public Integer getEnabled()
    {
        return enabled;
    }

    public void setEnabled(Integer enabled)
    {
        this.enabled = enabled;
    }
}
