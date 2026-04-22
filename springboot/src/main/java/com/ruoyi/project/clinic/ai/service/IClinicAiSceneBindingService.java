package com.ruoyi.project.clinic.ai.service;

import java.util.List;
import com.ruoyi.project.clinic.ai.domain.ClinicAiSceneBinding;

public interface IClinicAiSceneBindingService
{
    ClinicAiSceneBinding selectClinicAiSceneBindingById(Long sceneId);

    ClinicAiSceneBinding selectClinicAiSceneBindingByCode(String sceneCode);

    List<ClinicAiSceneBinding> selectClinicAiSceneBindingList(ClinicAiSceneBinding sceneBinding);

    int insertClinicAiSceneBinding(ClinicAiSceneBinding sceneBinding);

    int updateClinicAiSceneBinding(ClinicAiSceneBinding sceneBinding);

    int deleteClinicAiSceneBindingByIds(Long[] sceneIds);
}
