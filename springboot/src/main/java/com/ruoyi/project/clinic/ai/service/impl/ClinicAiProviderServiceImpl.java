package com.ruoyi.project.clinic.ai.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.project.clinic.ai.domain.ClinicAiModel;
import com.ruoyi.common.utils.security.ShiroUtils;
import com.ruoyi.project.clinic.ai.domain.ClinicAiProvider;
import com.ruoyi.project.clinic.ai.factory.AiProviderClientFactory;
import com.ruoyi.project.clinic.ai.mapper.ClinicAiProviderMapper;
import com.ruoyi.project.clinic.ai.service.IClinicAiModelService;
import com.ruoyi.project.clinic.ai.service.IClinicAiProviderService;

@Service
public class ClinicAiProviderServiceImpl implements IClinicAiProviderService
{
    @Autowired
    private ClinicAiProviderMapper providerMapper;

    @Autowired
    private AiProviderClientFactory clientFactory;

    @Autowired
    private IClinicAiModelService modelService;

    @Override
    public ClinicAiProvider selectClinicAiProviderById(Long providerId)
    {
        return providerMapper.selectClinicAiProviderById(providerId);
    }

    @Override
    public ClinicAiProvider selectClinicAiProviderByCode(String providerCode)
    {
        return providerMapper.selectClinicAiProviderByCode(StringUtils.trim(providerCode));
    }

    @Override
    public List<ClinicAiProvider> selectClinicAiProviderList(ClinicAiProvider provider)
    {
        return providerMapper.selectClinicAiProviderList(provider);
    }

    @Override
    public List<ClinicAiProvider> selectEnabledProviders()
    {
        return providerMapper.selectEnabledProviders();
    }

    @Override
    public int insertClinicAiProvider(ClinicAiProvider provider)
    {
        normalizeProvider(provider, false);
        provider.setCreateBy(defaultUser(provider.getCreateBy()));
        provider.setCreateTime(DateUtils.getNowDate());
        provider.setUpdateBy(defaultUser(provider.getUpdateBy()));
        provider.setUpdateTime(DateUtils.getNowDate());
        return providerMapper.insertClinicAiProvider(provider);
    }

    @Override
    public int updateClinicAiProvider(ClinicAiProvider provider)
    {
        normalizeProvider(provider, true);
        provider.setUpdateBy(defaultUser(provider.getUpdateBy()));
        provider.setUpdateTime(DateUtils.getNowDate());
        return providerMapper.updateClinicAiProvider(provider);
    }

    @Override
    public int deleteClinicAiProviderByIds(Long[] providerIds)
    {
        return providerMapper.deleteClinicAiProviderByIds(providerIds);
    }

    @Override
    public String testConnection(Long providerId)
    {
        ClinicAiProvider provider = selectClinicAiProviderById(providerId);
        if (provider == null)
        {
            throw new IllegalArgumentException("AI 服务商不存在");
        }
        clientFactory.ensureSupported(provider.getProviderCode());
        return clientFactory.getClient(provider.getProviderCode()).testConnection(provider, selectTestModel(providerId));
    }

    private void normalizeProvider(ClinicAiProvider provider, boolean keepOldKey)
    {
        if (provider == null)
        {
            throw new IllegalArgumentException("AI 服务商不能为空");
        }
        provider.setProviderCode(StringUtils.trim(provider.getProviderCode()));
        provider.setProviderName(StringUtils.trim(provider.getProviderName()));
        provider.setApiBaseUrl(StringUtils.trim(provider.getApiBaseUrl()));
        provider.setApiKey(StringUtils.trim(provider.getApiKey()));
        if (provider.getEnabled() == null)
        {
            provider.setEnabled(1);
        }
        if (StringUtils.isEmpty(provider.getProviderCode()) || StringUtils.isEmpty(provider.getProviderName()))
        {
            throw new IllegalArgumentException("服务商编码和名称不能为空");
        }
        if (keepOldKey && StringUtils.isEmpty(provider.getApiKey()) && provider.getProviderId() != null)
        {
            ClinicAiProvider existing = selectClinicAiProviderById(provider.getProviderId());
            if (existing != null)
            {
                provider.setApiKey(existing.getApiKey());
            }
        }
    }

    private String defaultUser(String value)
    {
        if (StringUtils.isNotEmpty(value))
        {
            return value;
        }
        try
        {
            return StringUtils.defaultIfEmpty(ShiroUtils.getLoginName(), "admin");
        }
        catch (Exception ignored)
        {
            return "admin";
        }
    }

    private ClinicAiModel selectTestModel(Long providerId)
    {
        ClinicAiModel query = new ClinicAiModel();
        query.setProviderId(providerId);
        query.setEnabled(1);
        List<ClinicAiModel> models = modelService.selectClinicAiModelList(query);
        return models.isEmpty() ? null : models.get(0);
    }
}
