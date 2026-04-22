package com.ruoyi.project.clinic.ai.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.security.ShiroUtils;
import com.ruoyi.project.clinic.ai.domain.ClinicAiModel;
import com.ruoyi.project.clinic.ai.mapper.ClinicAiModelMapper;
import com.ruoyi.project.clinic.ai.service.IClinicAiModelService;

@Service
public class ClinicAiModelServiceImpl implements IClinicAiModelService
{
    @Autowired
    private ClinicAiModelMapper modelMapper;

    @Override
    public ClinicAiModel selectClinicAiModelById(Long modelId)
    {
        return modelMapper.selectClinicAiModelById(modelId);
    }

    @Override
    public List<ClinicAiModel> selectClinicAiModelList(ClinicAiModel model)
    {
        return modelMapper.selectClinicAiModelList(model);
    }

    @Override
    public List<ClinicAiModel> selectEnabledModels()
    {
        return modelMapper.selectEnabledModels();
    }

    @Override
    public int insertClinicAiModel(ClinicAiModel model)
    {
        normalizeModel(model);
        model.setCreateBy(defaultUser(model.getCreateBy()));
        model.setCreateTime(DateUtils.getNowDate());
        model.setUpdateBy(defaultUser(model.getUpdateBy()));
        model.setUpdateTime(DateUtils.getNowDate());
        return modelMapper.insertClinicAiModel(model);
    }

    @Override
    public int updateClinicAiModel(ClinicAiModel model)
    {
        normalizeModel(model);
        model.setUpdateBy(defaultUser(model.getUpdateBy()));
        model.setUpdateTime(DateUtils.getNowDate());
        return modelMapper.updateClinicAiModel(model);
    }

    @Override
    public int deleteClinicAiModelByIds(Long[] modelIds)
    {
        return modelMapper.deleteClinicAiModelByIds(modelIds);
    }

    private void normalizeModel(ClinicAiModel model)
    {
        if (model == null)
        {
            throw new IllegalArgumentException("AI 模型不能为空");
        }
        model.setModelCode(StringUtils.trim(model.getModelCode()));
        model.setModelName(StringUtils.trim(model.getModelName()));
        if (model.getProviderId() == null)
        {
            throw new IllegalArgumentException("请选择服务商");
        }
        if (StringUtils.isEmpty(model.getModelCode()) || StringUtils.isEmpty(model.getModelName()))
        {
            throw new IllegalArgumentException("模型编码和模型名称不能为空");
        }
        if (model.getSupportsVision() == null)
        {
            model.setSupportsVision(0);
        }
        if (model.getSupportsWebSearch() == null)
        {
            model.setSupportsWebSearch(0);
        }
        if (model.getSupportsJsonSchema() == null)
        {
            model.setSupportsJsonSchema(0);
        }
        if (model.getEnabled() == null)
        {
            model.setEnabled(1);
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
