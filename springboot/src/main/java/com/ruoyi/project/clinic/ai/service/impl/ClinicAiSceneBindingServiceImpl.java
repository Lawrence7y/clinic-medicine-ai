package com.ruoyi.project.clinic.ai.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.security.ShiroUtils;
import com.ruoyi.project.clinic.ai.domain.ClinicAiSceneBinding;
import com.ruoyi.project.clinic.ai.mapper.ClinicAiSceneBindingMapper;
import com.ruoyi.project.clinic.ai.service.IClinicAiSceneBindingService;

@Service
public class ClinicAiSceneBindingServiceImpl implements IClinicAiSceneBindingService
{
    @Autowired
    private ClinicAiSceneBindingMapper sceneBindingMapper;

    @Override
    public ClinicAiSceneBinding selectClinicAiSceneBindingById(Long sceneId)
    {
        return sceneBindingMapper.selectClinicAiSceneBindingById(sceneId);
    }

    @Override
    public ClinicAiSceneBinding selectClinicAiSceneBindingByCode(String sceneCode)
    {
        return sceneBindingMapper.selectClinicAiSceneBindingByCode(StringUtils.trim(sceneCode));
    }

    @Override
    public List<ClinicAiSceneBinding> selectClinicAiSceneBindingList(ClinicAiSceneBinding sceneBinding)
    {
        return sceneBindingMapper.selectClinicAiSceneBindingList(sceneBinding);
    }

    @Override
    public int insertClinicAiSceneBinding(ClinicAiSceneBinding sceneBinding)
    {
        normalizeScene(sceneBinding);
        sceneBinding.setCreateBy(defaultUser(sceneBinding.getCreateBy()));
        sceneBinding.setCreateTime(DateUtils.getNowDate());
        sceneBinding.setUpdateBy(defaultUser(sceneBinding.getUpdateBy()));
        sceneBinding.setUpdateTime(DateUtils.getNowDate());
        int rows = sceneBindingMapper.insertClinicAiSceneBinding(sceneBinding);
        syncGlobalModels(sceneBinding);
        return rows;
    }

    @Override
    public int updateClinicAiSceneBinding(ClinicAiSceneBinding sceneBinding)
    {
        normalizeScene(sceneBinding);
        sceneBinding.setUpdateBy(defaultUser(sceneBinding.getUpdateBy()));
        sceneBinding.setUpdateTime(DateUtils.getNowDate());
        int rows = sceneBindingMapper.updateClinicAiSceneBinding(sceneBinding);
        syncGlobalModels(sceneBinding);
        return rows;
    }

    @Override
    public int deleteClinicAiSceneBindingByIds(Long[] sceneIds)
    {
        return sceneBindingMapper.deleteClinicAiSceneBindingByIds(sceneIds);
    }

    private void syncGlobalModels(ClinicAiSceneBinding sceneBinding)
    {
        if (sceneBinding == null)
        {
            return;
        }
        if (sceneBinding.getPrimaryModelId() == null && sceneBinding.getFallbackModelId() == null)
        {
            return;
        }
        sceneBindingMapper.syncGlobalModels(sceneBinding.getPrimaryModelId(), sceneBinding.getFallbackModelId(),
            sceneBinding.getUpdateBy(), sceneBinding.getUpdateTime());
    }

    private void normalizeScene(ClinicAiSceneBinding sceneBinding)
    {
        if (sceneBinding == null)
        {
            throw new IllegalArgumentException("场景绑定不能为空");
        }
        sceneBinding.setSceneCode(StringUtils.trim(sceneBinding.getSceneCode()));
        sceneBinding.setSceneName(StringUtils.trim(sceneBinding.getSceneName()));
        sceneBinding.setExecutionMode(StringUtils.trim(sceneBinding.getExecutionMode()));
        if (StringUtils.isEmpty(sceneBinding.getSceneCode()) || StringUtils.isEmpty(sceneBinding.getSceneName()))
        {
            throw new IllegalArgumentException("场景编码和场景名称不能为空");
        }
        if (StringUtils.isEmpty(sceneBinding.getExecutionMode()))
        {
            sceneBinding.setExecutionMode("local_only");
        }
        if (sceneBinding.getCandidateLimit() == null || sceneBinding.getCandidateLimit() <= 0)
        {
            sceneBinding.setCandidateLimit(3);
        }
        if (sceneBinding.getTimeoutMs() == null || sceneBinding.getTimeoutMs() <= 0)
        {
            sceneBinding.setTimeoutMs(60000);
        }
        if (sceneBinding.getEnabled() == null)
        {
            sceneBinding.setEnabled(1);
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
}
