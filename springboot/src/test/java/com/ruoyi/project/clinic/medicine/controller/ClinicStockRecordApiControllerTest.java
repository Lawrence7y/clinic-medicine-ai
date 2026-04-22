package com.ruoyi.project.clinic.medicine.controller;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import com.ruoyi.framework.web.domain.AjaxResult;
import com.ruoyi.framework.web.page.TableDataInfo;
import com.ruoyi.project.clinic.medicine.domain.ClinicStockRecord;
import com.ruoyi.project.clinic.medicine.mapper.ClinicStockBatchMapper;
import com.ruoyi.project.clinic.medicine.service.IClinicStockRecordService;
import com.ruoyi.project.clinic.patient.service.IClinicPatientService;
import com.ruoyi.project.clinic.support.ShiroTestSupport;
import com.ruoyi.project.system.role.domain.Role;
import com.ruoyi.project.system.role.service.IRoleService;
import com.ruoyi.project.system.user.domain.User;
import java.lang.reflect.Method;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import org.apache.shiro.authz.annotation.RequiresPermissions;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
public class ClinicStockRecordApiControllerTest
{
    @Mock
    private IClinicStockRecordService clinicStockRecordService;

    @Mock
    private IRoleService roleService;

    @Mock
    private ClinicStockBatchMapper clinicStockBatchMapper;

    @Mock
    private IClinicPatientService clinicPatientService;

    @InjectMocks
    private ClinicStockRecordApiController controller;

    @AfterEach
    public void tearDown()
    {
        ShiroTestSupport.clear();
    }

    @Test
    public void patientShouldReceive403OnSensitiveStockEndpoints()
    {
        ShiroTestSupport.bindUser(patientUser());

        AjaxResult summary = controller.getPackLossSummary();
        AjaxResult execute = controller.executePackLossOut(1L);
        Map<String, Object> params = new HashMap<>();
        params.put("batchId", 2L);
        AjaxResult offShelf = controller.offShelfBatch(params);

        assertEquals(403, summary.get(AjaxResult.CODE_TAG));
        assertEquals(403, execute.get(AjaxResult.CODE_TAG));
        assertEquals(403, offShelf.get(AjaxResult.CODE_TAG));
        verify(clinicStockRecordService, never()).getPackLossSummary();
        verify(clinicStockRecordService, never()).executePackLossOut(anyLong(), anyLong(), org.mockito.ArgumentMatchers.anyString());
        verify(clinicStockRecordService, never()).offShelfBatch(anyLong(), anyLong(), org.mockito.ArgumentMatchers.anyString(), org.mockito.ArgumentMatchers.anyString());
    }

    @Test
    public void list_shouldReturnReadableMessageWhenServiceThrows()
    {
        User admin = new User();
        admin.setUserId(1L);
        admin.setUserName("admin");
        admin.setRoles(Arrays.asList(role("admin")));
        ShiroTestSupport.bindUser(admin);
        when(clinicStockRecordService.selectClinicStockRecordList(any(ClinicStockRecord.class)))
            .thenThrow(new RuntimeException("stock table init failed"));

        ClinicStockRecord query = new ClinicStockRecord();
        query.setPageNum(1);
        query.setPageSize(20);

        TableDataInfo result = controller.list(query);

        assertEquals(500, result.getCode());
        assertTrue(result.getMsg().contains("stock table init failed"));
    }

    @Test
    public void stockCrudEndpoints_shouldNotRequireExplicitShiroPermissions() throws Exception
    {
        assertNoPermissionAnnotation("list", ClinicStockRecord.class);
        assertNoPermissionAnnotation("listForm", ClinicStockRecord.class);
        assertNoPermissionAnnotation("listFormDirect", ClinicStockRecord.class);
        assertNoPermissionAnnotation("addSave", ClinicStockRecord.class);
        assertNoPermissionAnnotation("addSaveForm", ClinicStockRecord.class);
        assertNoPermissionAnnotation("addSaveFormDirect", ClinicStockRecord.class);
        assertNoPermissionAnnotation("editSave", ClinicStockRecord.class);
        assertNoPermissionAnnotation("editSaveForm", ClinicStockRecord.class);
        assertNoPermissionAnnotation("remove", Map.class);
        assertNoPermissionAnnotation("removeForm", String.class);
    }

    @Test
    public void doctorList_shouldBeScopedToCurrentOperator()
    {
        User doctor = new User();
        doctor.setUserId(8L);
        doctor.setUserName("doctor");
        doctor.setRoles(Arrays.asList(role("doctor")));
        ShiroTestSupport.bindUser(doctor);
        when(clinicStockRecordService.selectClinicStockRecordList(any(ClinicStockRecord.class)))
            .thenReturn(Collections.emptyList());

        ClinicStockRecord query = new ClinicStockRecord();
        query.setPageNum(1);
        query.setPageSize(20);

        TableDataInfo result = controller.list(query);
        ArgumentCaptor<ClinicStockRecord> captor = ArgumentCaptor.forClass(ClinicStockRecord.class);
        verify(clinicStockRecordService).selectClinicStockRecordList(captor.capture());

        assertEquals(0, result.getCode());
        assertEquals(doctor.getUserId(), captor.getValue().getOperatorId());
    }

    @Test
    public void addSave_shouldRejectDoctorWhenAddingStockRecord()
    {
        User doctor = new User();
        doctor.setUserId(8L);
        doctor.setUserName("doctor");
        doctor.setRoles(Arrays.asList(role("doctor")));
        ShiroTestSupport.bindUser(doctor);

        ClinicStockRecord record = new ClinicStockRecord();
        record.setMedicineId(10L);
        record.setQuantity(2);
        record.setOperationType("in");

        AjaxResult result = controller.addSave(record);

        assertEquals(403, result.get(AjaxResult.CODE_TAG));
        verify(clinicStockRecordService, never()).insertClinicStockRecord(any(ClinicStockRecord.class));
    }

    @Test
    public void addSave_shouldAllowDoctorWhenOperationIsStockOut()
    {
        User doctor = new User();
        doctor.setUserId(8L);
        doctor.setUserName("doctor");
        doctor.setRoles(Arrays.asList(role("doctor")));
        ShiroTestSupport.bindUser(doctor);
        when(clinicStockRecordService.insertClinicStockRecord(any(ClinicStockRecord.class)))
            .thenAnswer(invocation -> {
                ClinicStockRecord record = invocation.getArgument(0);
                record.setRecordId(100L);
                return 1;
            });

        ClinicStockRecord record = new ClinicStockRecord();
        record.setMedicineId(10L);
        record.setQuantity(2);
        record.setOperationType("out");

        AjaxResult result = controller.addSave(record);
        ArgumentCaptor<ClinicStockRecord> captor = ArgumentCaptor.forClass(ClinicStockRecord.class);
        verify(clinicStockRecordService).insertClinicStockRecord(captor.capture());

        assertEquals(0, result.get(AjaxResult.CODE_TAG));
        assertEquals(doctor.getUserId(), captor.getValue().getOperatorId());
        assertEquals(doctor.getUserName(), captor.getValue().getOperatorName());
    }

    @Test
    public void addSave_shouldAllowAdminAndPopulateOperator()
    {
        User admin = new User();
        admin.setUserId(1L);
        admin.setUserName("admin");
        admin.setRoles(Arrays.asList(role("admin")));
        ShiroTestSupport.bindUser(admin);
        when(clinicStockRecordService.insertClinicStockRecord(any(ClinicStockRecord.class)))
            .thenAnswer(invocation -> {
                ClinicStockRecord record = invocation.getArgument(0);
                record.setRecordId(99L);
                return 1;
            });

        ClinicStockRecord record = new ClinicStockRecord();
        record.setMedicineId(10L);
        record.setQuantity(2);
        record.setOperationType("in");

        AjaxResult result = controller.addSave(record);
        ArgumentCaptor<ClinicStockRecord> captor = ArgumentCaptor.forClass(ClinicStockRecord.class);
        verify(clinicStockRecordService).insertClinicStockRecord(captor.capture());

        assertEquals(0, result.get(AjaxResult.CODE_TAG));
        assertEquals(admin.getUserId(), captor.getValue().getOperatorId());
        assertEquals(admin.getUserName(), captor.getValue().getOperatorName());
    }

    private User patientUser()
    {
        User user = new User();
        user.setUserId(55L);
        user.setUserName("patient");
        user.setRoles(Arrays.asList(role("patient")));
        return user;
    }

    private Role role(String roleKey)
    {
        Role role = new Role();
        role.setRoleKey(roleKey);
        role.setRoleName(roleKey);
        return role;
    }

    private void assertNoPermissionAnnotation(String methodName, Class<?>... parameterTypes) throws Exception
    {
        Method method = ClinicStockRecordApiController.class.getMethod(methodName, parameterTypes);
        assertNull(method.getAnnotation(RequiresPermissions.class));
    }
}
