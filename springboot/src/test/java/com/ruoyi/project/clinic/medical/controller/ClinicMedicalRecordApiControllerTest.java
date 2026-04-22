package com.ruoyi.project.clinic.medical.controller;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.ruoyi.framework.web.domain.AjaxResult;
import com.ruoyi.project.clinic.medical.domain.ClinicMedicalRecord;
import com.ruoyi.project.clinic.medical.service.IClinicMedicalRecordService;
import com.ruoyi.project.clinic.patient.service.IClinicPatientService;
import com.ruoyi.project.clinic.support.ShiroTestSupport;
import com.ruoyi.project.system.role.domain.Role;
import com.ruoyi.project.system.role.service.IRoleService;
import com.ruoyi.project.system.user.domain.User;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
public class ClinicMedicalRecordApiControllerTest
{
    @Mock
    private IClinicMedicalRecordService clinicMedicalRecordService;

    @Mock
    private IRoleService roleService;

    @Mock
    private IClinicPatientService clinicPatientService;

    @InjectMocks
    private ClinicMedicalRecordApiController controller;

    @AfterEach
    public void tearDown()
    {
        ShiroTestSupport.clear();
    }

    @Test
    public void statistics_shouldCountVisitDateUsingRealDateValue()
    {
        User currentUser = new User();
        currentUser.setUserId(1L);
        currentUser.setUserName("admin");
        currentUser.setRoles(Arrays.asList(role("admin")));
        ShiroTestSupport.bindUser(currentUser);

        LocalDate today = LocalDate.now();

        ClinicMedicalRecord todayRecord = new ClinicMedicalRecord();
        todayRecord.setRecordId(1L);
        todayRecord.setPatientId(100L);
        todayRecord.setPatientAge(30);
        todayRecord.setDiagnosis("感冒");
        todayRecord.setVisitTime(java.util.Date.from(
            LocalDateTime.of(today, java.time.LocalTime.of(9, 0))
                .atZone(ZoneId.systemDefault())
                .toInstant()));

        ClinicMedicalRecord yesterdayRecord = new ClinicMedicalRecord();
        yesterdayRecord.setRecordId(2L);
        yesterdayRecord.setPatientId(101L);
        yesterdayRecord.setPatientAge(40);
        yesterdayRecord.setDiagnosis("发热");
        yesterdayRecord.setVisitTime(java.util.Date.from(
            LocalDateTime.of(today.minusDays(1), java.time.LocalTime.of(10, 0))
                .atZone(ZoneId.systemDefault())
                .toInstant()));

        when(clinicMedicalRecordService.selectClinicMedicalRecordList(any(ClinicMedicalRecord.class)))
            .thenReturn(Arrays.asList(todayRecord, yesterdayRecord));

        AjaxResult result = controller.statistics("7d");

        assertTrue(result.isSuccess());
        @SuppressWarnings("unchecked")
        Map<String, Object> data = (Map<String, Object>) result.get(AjaxResult.DATA_TAG);
        assertEquals(2, ((Number) data.get("totalRecords")).intValue());
        assertEquals(1, ((Number) data.get("todayRecords")).intValue());
        assertEquals(2L, ((Number) data.get("totalPatients")).longValue());

        @SuppressWarnings("unchecked")
        List<Map<String, Object>> trendData = (List<Map<String, Object>>) data.get("trendData");
        String todayText = today.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        assertTrue(trendData.stream().anyMatch(item ->
            todayText.equals(String.valueOf(item.get("date")))
                && ((Number) item.get("count")).intValue() == 1));
    }

    @Test
    public void list_shouldForceDoctorScopeToCurrentUser()
    {
        User currentUser = new User();
        currentUser.setUserId(9L);
        currentUser.setUserName("doctorA");
        currentUser.setRoles(Arrays.asList(role("doctor")));
        ShiroTestSupport.bindUser(currentUser);

        when(clinicMedicalRecordService.selectClinicMedicalRecordList(any(ClinicMedicalRecord.class)))
            .thenReturn(Collections.emptyList());

        ClinicMedicalRecordApiController.ClinicMedicalRecordQuery query =
            new ClinicMedicalRecordApiController.ClinicMedicalRecordQuery();
        query.setDoctorId(88L);
        controller.list(query);

        ArgumentCaptor<ClinicMedicalRecord> captor = ArgumentCaptor.forClass(ClinicMedicalRecord.class);
        verify(clinicMedicalRecordService).selectClinicMedicalRecordList(captor.capture());
        assertEquals(9L, captor.getValue().getDoctorId());
    }

    @Test
    public void statistics_shouldRejectPatientRole()
    {
        User currentUser = new User();
        currentUser.setUserId(100L);
        currentUser.setUserName("patientA");
        currentUser.setRoles(Arrays.asList(role("patient")));
        ShiroTestSupport.bindUser(currentUser);

        AjaxResult result = controller.statistics("7d");

        assertEquals(403, result.get(AjaxResult.CODE_TAG));
    }

    @Test
    public void getInfo_shouldRejectDoctorWhenRecordBelongsToAnotherDoctor()
    {
        User currentUser = new User();
        currentUser.setUserId(9L);
        currentUser.setUserName("doctorA");
        currentUser.setRoles(Arrays.asList(role("doctor")));
        ShiroTestSupport.bindUser(currentUser);

        ClinicMedicalRecord record = new ClinicMedicalRecord();
        record.setRecordId(1L);
        record.setDoctorId(10L);
        when(clinicMedicalRecordService.selectClinicMedicalRecordById(1L)).thenReturn(record);

        AjaxResult result = controller.getInfo(1L);

        assertEquals(403, result.get(AjaxResult.CODE_TAG));
    }

    private Role role(String roleKey)
    {
        Role role = new Role();
        role.setRoleKey(roleKey);
        role.setRoleName(roleKey);
        return role;
    }
}
