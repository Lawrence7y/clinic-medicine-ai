package com.ruoyi.project.clinic.patient.controller;

import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import com.ruoyi.framework.web.domain.AjaxResult;
import com.ruoyi.project.clinic.patient.domain.ClinicPatient;
import com.ruoyi.project.clinic.patient.service.IClinicPatientService;
import com.ruoyi.project.clinic.support.ShiroTestSupport;
import com.ruoyi.project.system.role.service.IRoleService;
import com.ruoyi.project.system.user.domain.User;
import java.util.Collections;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
public class ClinicPatientApiControllerTest
{
    @Mock
    private IClinicPatientService clinicPatientService;

    @Mock
    private IRoleService roleService;

    @InjectMocks
    private ClinicPatientApiController controller;

    @AfterEach
    public void tearDown()
    {
        ShiroTestSupport.clear();
    }

    @Test
    public void editSave_shouldAllowPatientUpdatingOwnProfile()
    {
        User currentUser = new User();
        currentUser.setUserId(55L);
        currentUser.setUserName("patient");
        ShiroTestSupport.bindUser(currentUser);
        when(roleService.selectRoleKeys(55L)).thenReturn(Collections.singleton("patient"));

        ClinicPatient existing = new ClinicPatient();
        existing.setPatientId(9L);
        existing.setUserId(55L);
        when(clinicPatientService.selectClinicPatientById(9L)).thenReturn(existing);
        when(clinicPatientService.updateClinicPatient(any(ClinicPatient.class))).thenReturn(1);

        ClinicPatient incoming = new ClinicPatient();
        incoming.setPatientId(9L);
        incoming.setName("张三");
        incoming.setPhone("13800138000");

        AjaxResult result = controller.editSave(incoming);

        assertTrue(result.isSuccess());
        verify(clinicPatientService).updateClinicPatient(any(ClinicPatient.class));
    }
}
