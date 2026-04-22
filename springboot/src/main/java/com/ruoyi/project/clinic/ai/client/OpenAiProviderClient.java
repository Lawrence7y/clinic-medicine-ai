package com.ruoyi.project.clinic.ai.client;

import org.springframework.stereotype.Component;
import com.ruoyi.common.utils.StringUtils;

@Component
public class OpenAiProviderClient extends AbstractJsonAiProviderClient
{
    @Override
    public boolean supports(String providerCode)
    {
        return StringUtils.equalsIgnoreCase("openai", providerCode)
            || StringUtils.equalsIgnoreCase("openai_compatible", providerCode);
    }
}
