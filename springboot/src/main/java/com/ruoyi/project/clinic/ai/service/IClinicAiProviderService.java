package com.ruoyi.project.clinic.ai.service;

import java.util.List;
import com.ruoyi.project.clinic.ai.domain.ClinicAiProvider;

public interface IClinicAiProviderService
{
    ClinicAiProvider selectClinicAiProviderById(Long providerId);

    ClinicAiProvider selectClinicAiProviderByCode(String providerCode);

    List<ClinicAiProvider> selectClinicAiProviderList(ClinicAiProvider provider);

    List<ClinicAiProvider> selectEnabledProviders();

    int insertClinicAiProvider(ClinicAiProvider provider);

    int updateClinicAiProvider(ClinicAiProvider provider);

    int deleteClinicAiProviderByIds(Long[] providerIds);

    String testConnection(Long providerId);
}
