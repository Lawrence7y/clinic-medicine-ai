package com.ruoyi.project.clinic.ai.mapper;

import java.util.List;
import java.util.Date;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.project.clinic.ai.domain.ClinicAiSceneBinding;

public interface ClinicAiSceneBindingMapper
{
    ClinicAiSceneBinding selectClinicAiSceneBindingById(Long sceneId);

    ClinicAiSceneBinding selectClinicAiSceneBindingByCode(String sceneCode);

    List<ClinicAiSceneBinding> selectClinicAiSceneBindingList(ClinicAiSceneBinding sceneBinding);

    int insertClinicAiSceneBinding(ClinicAiSceneBinding sceneBinding);

    int updateClinicAiSceneBinding(ClinicAiSceneBinding sceneBinding);

    int syncGlobalModels(@Param("primaryModelId") Long primaryModelId,
        @Param("fallbackModelId") Long fallbackModelId,
        @Param("updateBy") String updateBy,
        @Param("updateTime") Date updateTime);

    int deleteClinicAiSceneBindingById(Long sceneId);

    int deleteClinicAiSceneBindingByIds(Long[] sceneIds);
}
