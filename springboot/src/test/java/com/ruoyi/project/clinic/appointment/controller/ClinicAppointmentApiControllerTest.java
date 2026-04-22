package com.ruoyi.project.clinic.appointment.controller;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import com.ruoyi.framework.web.domain.AjaxResult;
import com.ruoyi.project.clinic.audit.service.AuditTrailService;
import com.ruoyi.project.clinic.appointment.domain.ClinicAppointment;
import com.ruoyi.project.clinic.appointment.service.IClinicAppointmentService;
import com.ruoyi.project.clinic.patient.domain.ClinicPatient;
import com.ruoyi.project.clinic.patient.service.IClinicPatientService;
import com.ruoyi.project.clinic.support.ShiroTestSupport;
import com.ruoyi.project.system.role.domain.Role;
import com.ruoyi.project.system.role.service.IRoleService;
import com.ruoyi.project.system.user.domain.User;
import com.ruoyi.project.system.user.service.IUserService;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Collections;
import java.util.Map;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
public class ClinicAppointmentApiControllerTest
{
    @Mock
    private IClinicAppointmentService clinicAppointmentService;

    @Mock
    private IRoleService roleService;

    @Mock
    private IUserService userService;

    @Mock
    private IClinicPatientService clinicPatientService;

    @Mock
    private AuditTrailService auditTrailService;

    @InjectMocks
    private ClinicAppointmentApiController controller;

    @AfterEach
    public void tearDown()
    {
        ShiroTestSupport.clear();
    }

    @Test
    public void patientQueueShouldOnlyReturnOwnPositionSummary()
    {
        User currentUser = new User();
        currentUser.setUserId(88L);
        currentUser.setUserName("patient");
        currentUser.setRoles(Arrays.asList(role("patient")));
        ShiroTestSupport.bindUser(currentUser);

        ClinicPatient patient = new ClinicPatient();
        patient.setPatientId(501L);
        when(clinicPatientService.selectClinicPatientByUserId(88L)).thenReturn(patient);

        ClinicAppointment appointment = new ClinicAppointment();
        appointment.setAppointmentId(700L);
        appointment.setPatientId(501L);
        appointment.setDoctorId(22L);
        try
        {
            appointment.setAppointmentDate(new SimpleDateFormat("yyyy-MM-dd").parse("2026-04-02"));
        }
        catch (Exception ex)
        {
            throw new RuntimeException(ex);
        }
        when(clinicAppointmentService.selectClinicAppointmentList(any(ClinicAppointment.class)))
            .thenReturn(Collections.singletonList(appointment));
        when(clinicAppointmentService.getQueuePosition(700L)).thenReturn(2);

        AjaxResult result = controller.getQueue(22L, "2026-04-02");

        assertTrue(result.isSuccess());
        @SuppressWarnings("unchecked")
        Map<String, Object> data = (Map<String, Object>) result.get(AjaxResult.DATA_TAG);
        assertEquals(700L, data.get("appointmentId"));
        assertEquals(2, data.get("position"));
        assertEquals(Collections.emptyList(), data.get("queue"));
    }

    @Test
    public void patientQueueShouldRejectOtherDoctorsQueueWhenNoOwnedAppointment()
    {
        User currentUser = new User();
        currentUser.setUserId(88L);
        currentUser.setUserName("patient");
        currentUser.setRoles(Arrays.asList(role("patient")));
        ShiroTestSupport.bindUser(currentUser);

        ClinicPatient patient = new ClinicPatient();
        patient.setPatientId(501L);
        when(clinicPatientService.selectClinicPatientByUserId(88L)).thenReturn(patient);
        when(clinicAppointmentService.selectClinicAppointmentList(any(ClinicAppointment.class)))
            .thenReturn(Collections.emptyList());

        AjaxResult result = controller.getQueue(22L, "2026-04-02");

        assertEquals(403, result.get(AjaxResult.CODE_TAG));
    }

    @Test
    public void editSave_shouldReturnReadableMessageWhenServiceThrows()
    {
        User currentUser = new User();
        currentUser.setUserId(1L);
        currentUser.setUserName("admin");
        currentUser.setRoles(Arrays.asList(role("admin")));
        ShiroTestSupport.bindUser(currentUser);

        ClinicAppointment old = new ClinicAppointment();
        old.setAppointmentId(100L);
        old.setDoctorId(22L);
        old.setPatientId(501L);
        old.setStatus("pending");
        when(clinicAppointmentService.selectClinicAppointmentById(100L)).thenReturn(old);
        when(clinicAppointmentService.updateClinicAppointment(any(ClinicAppointment.class)))
            .thenThrow(new RuntimeException("该时段无可用预约名额"));

        ClinicAppointment incoming = new ClinicAppointment();
        incoming.setAppointmentId(100L);
        incoming.setStatus("confirmed");

        AjaxResult result = controller.editSave(incoming);

        assertTrue(result.isError());
        assertTrue(String.valueOf(result.get(AjaxResult.MSG_TAG)).contains("无可用预约名额"));
    }

    @Test
    public void doctorCallShouldRejectOtherDoctorsAppointment()
    {
        User currentUser = new User();
        currentUser.setUserId(11L);
        currentUser.setUserName("doctorA");
        currentUser.setRoles(Arrays.asList(role("doctor")));
        ShiroTestSupport.bindUser(currentUser);

        ClinicAppointment appointment = new ClinicAppointment();
        appointment.setAppointmentId(100L);
        appointment.setDoctorId(22L);
        when(clinicAppointmentService.selectClinicAppointmentById(100L)).thenReturn(appointment);

        AjaxResult result = controller.callAppointment(100L);

        assertEquals(403, result.get(AjaxResult.CODE_TAG));
        verify(clinicAppointmentService, never()).callAppointment(any(Long.class));
    }

    @Test
    public void doctorCompleteShouldAllowOwnAppointment()
    {
        User currentUser = new User();
        currentUser.setUserId(11L);
        currentUser.setUserName("doctorA");
        currentUser.setRoles(Arrays.asList(role("doctor")));
        ShiroTestSupport.bindUser(currentUser);

        ClinicAppointment appointment = new ClinicAppointment();
        appointment.setAppointmentId(100L);
        appointment.setDoctorId(11L);
        when(clinicAppointmentService.selectClinicAppointmentById(100L)).thenReturn(appointment);

        AjaxResult result = controller.completeAppointment(100L);

        assertTrue(result.isSuccess());
        verify(clinicAppointmentService).completeAppointment(100L);
    }

    private Role role(String roleKey)
    {
        Role role = new Role();
        role.setRoleKey(roleKey);
        role.setRoleName(roleKey);
        return role;
    }
}
