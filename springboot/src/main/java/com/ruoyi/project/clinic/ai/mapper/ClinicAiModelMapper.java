package com.ruoyi.project.clinic.ai.mapper;

import java.util.List;
import com.ruoyi.project.clinic.ai.domain.ClinicAiModel;

public interface ClinicAiModelMapper
{
    ClinicAiModel selectClinicAiModelById(Long modelId);

    List<ClinicAiModel> selectClinicAiModelList(ClinicAiModel model);

    List<ClinicAiModel> selectEnabledModels();

    int insertClinicAiModel(ClinicAiModel model);

    int updateClinicAiModel(ClinicAiModel model);

    int deleteClinicAiModelById(Long modelId);

    int deleteClinicAiModelByIds(Long[] modelIds);
}
