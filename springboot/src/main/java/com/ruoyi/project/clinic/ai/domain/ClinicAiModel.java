package com.ruoyi.project.clinic.ai.domain;

import com.ruoyi.framework.web.domain.BaseEntity;

public class ClinicAiModel extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long modelId;
    private Long providerId;
    private String providerCode;
    private String providerName;
    private String modelCode;
    private String modelName;
    private Integer supportsVision;
    private Integer supportsWebSearch;
    private Integer supportsJsonSchema;
    private Integer enabled;

    public Long getModelId()
    {
        return modelId;
    }

    public void setModelId(Long modelId)
    {
        this.modelId = modelId;
    }

    public Long getProviderId()
    {
        return providerId;
    }

    public void setProviderId(Long providerId)
    {
        this.providerId = providerId;
    }

    public String getProviderCode()
    {
        return providerCode;
    }

    public void setProviderCode(String providerCode)
    {
        this.providerCode = providerCode;
    }

    public String getProviderName()
    {
        return providerName;
    }

    public void setProviderName(String providerName)
    {
        this.providerName = providerName;
    }

    public String getModelCode()
    {
        return modelCode;
    }

    public void setModelCode(String modelCode)
    {
        this.modelCode = modelCode;
    }

    public String getModelName()
    {
        return modelName;
    }

    public void setModelName(String modelName)
    {
        this.modelName = modelName;
    }

    public Integer getSupportsVision()
    {
        return supportsVision;
    }

    public void setSupportsVision(Integer supportsVision)
    {
        this.supportsVision = supportsVision;
    }

    public Integer getSupportsWebSearch()
    {
        return supportsWebSearch;
    }

    public void setSupportsWebSearch(Integer supportsWebSearch)
    {
        this.supportsWebSearch = supportsWebSearch;
    }

    public Integer getSupportsJsonSchema()
    {
        return supportsJsonSchema;
    }

    public void setSupportsJsonSchema(Integer supportsJsonSchema)
    {
        this.supportsJsonSchema = supportsJsonSchema;
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
