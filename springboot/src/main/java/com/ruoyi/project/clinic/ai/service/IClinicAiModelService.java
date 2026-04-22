package com.ruoyi.project.clinic.ai.service;

import java.util.List;
import com.ruoyi.project.clinic.ai.domain.ClinicAiModel;

public interface IClinicAiModelService
{
    ClinicAiModel selectClinicAiModelById(Long modelId);

    List<ClinicAiModel> selectClinicAiModelList(ClinicAiModel model);

    List<ClinicAiModel> selectEnabledModels();

    int insertClinicAiModel(ClinicAiModel model);

    int updateClinicAiModel(ClinicAiModel model);

    int deleteClinicAiModelByIds(Long[] modelIds);
}
