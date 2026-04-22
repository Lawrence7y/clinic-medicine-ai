package com.ruoyi.project.clinic.ai.factory;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.project.clinic.ai.client.AiProviderClient;

@Component
public class AiProviderClientFactory
{
    @Autowired(required = false)
    private List<AiProviderClient> clients;

    public AiProviderClient getClient(String providerCode)
    {
        if (clients == null || clients.isEmpty())
        {
            return null;
        }
        for (AiProviderClient client : clients)
        {
            if (client.supports(providerCode))
            {
                return client;
            }
        }
        return null;
    }

    public void ensureSupported(String providerCode)
    {
        if (getClient(providerCode) == null)
        {
            throw new IllegalArgumentException("不支持的 AI 服务商: " + StringUtils.defaultString(providerCode));
        }
    }
}
