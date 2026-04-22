package com.ruoyi.project.clinic.ai.client;

import org.springframework.stereotype.Component;
import com.ruoyi.common.utils.StringUtils;

@Component
public class MiniMaxProviderClient extends AbstractJsonAiProviderClient
{
    @Override
    public boolean supports(String providerCode)
    {
        return StringUtils.equalsIgnoreCase("minimax", providerCode)
            || StringUtils.equalsIgnoreCase("mini_max", providerCode);
    }
}
