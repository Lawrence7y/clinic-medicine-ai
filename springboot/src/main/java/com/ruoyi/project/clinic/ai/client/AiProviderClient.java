package com.ruoyi.project.clinic.ai.client;

import java.util.List;
import com.ruoyi.project.clinic.ai.domain.ClinicAiModel;
import com.ruoyi.project.clinic.ai.domain.ClinicAiProvider;
import com.ruoyi.project.clinic.ai.domain.ClinicAiSceneBinding;
import com.ruoyi.project.clinic.medicine.dto.MedicineRecognitionCandidate;

public interface AiProviderClient
{
    boolean supports(String providerCode);

    List<MedicineRecognitionCandidate> recognizeByCode(ClinicAiProvider provider, ClinicAiModel model,
        ClinicAiSceneBinding sceneBinding, String scene, String code);

    List<MedicineRecognitionCandidate> recognizeByImage(ClinicAiProvider provider, ClinicAiModel model,
        ClinicAiSceneBinding sceneBinding, String scene, String fileName, byte[] fileBytes, String contentType);

    default String chat(ClinicAiProvider provider, ClinicAiModel model, String systemPrompt, String userPrompt)
    {
        throw new UnsupportedOperationException("Chat is not supported for current AI provider.");
    }

    String testConnection(ClinicAiProvider provider);

    default String testConnection(ClinicAiProvider provider, ClinicAiModel model)
    {
        return testConnection(provider);
    }
}
