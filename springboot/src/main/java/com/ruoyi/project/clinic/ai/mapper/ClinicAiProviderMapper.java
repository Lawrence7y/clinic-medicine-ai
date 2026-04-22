package com.ruoyi.project.clinic.ai.mapper;

import java.util.List;
import com.ruoyi.project.clinic.ai.domain.ClinicAiProvider;

public interface ClinicAiProviderMapper
{
    ClinicAiProvider selectClinicAiProviderById(Long providerId);

    ClinicAiProvider selectClinicAiProviderByCode(String providerCode);

    List<ClinicAiProvider> selectClinicAiProviderList(ClinicAiProvider provider);

    List<ClinicAiProvider> selectEnabledProviders();

    int insertClinicAiProvider(ClinicAiProvider provider);

    int updateClinicAiProvider(ClinicAiProvider provider);

    int deleteClinicAiProviderById(Long providerId);

    int deleteClinicAiProviderByIds(Long[] providerIds);
}
