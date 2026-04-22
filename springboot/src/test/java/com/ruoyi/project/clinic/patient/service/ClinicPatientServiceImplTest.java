package com.ruoyi.project.clinic.patient.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import java.util.Arrays;
import java.util.Date;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import com.ruoyi.framework.shiro.service.PasswordService;
import com.ruoyi.project.clinic.patient.domain.ClinicPatient;
import com.ruoyi.project.clinic.patient.mapper.ClinicPatientMapper;
import com.ruoyi.project.clinic.support.ShiroTestSupport;
import com.ruoyi.project.clinic.patient.service.impl.ClinicPatientServiceImpl;
import com.ruoyi.project.system.user.domain.User;
import com.ruoyi.project.system.user.service.IUserService;

@ExtendWith(MockitoExtension.class)
public class ClinicPatientServiceImplTest
{
    @Mock
    private ClinicPatientMapper clinicPatientMapper;

    @Mock
    private IUserService userService;

    @Mock
    private PasswordService passwordService;

    @InjectMocks
    private ClinicPatientServiceImpl clinicPatientService;

    @BeforeEach
    public void setUp()
    {
        User user = new User();
        user.setUserId(1L);
        user.setLoginName("tester");
        user.setUserName("tester");
        ShiroTestSupport.bindUser(user);
    }

    @AfterEach
    public void tearDown()
    {
        ShiroTestSupport.clear();
    }

    @Test
    public void deleteClinicPatientByIds_shouldBatchLoadPatientsAndDeleteDistinctUsers()
    {
        Long[] patientIds = new Long[] { 1L, 2L, 3L };
        ClinicPatient patient1 = new ClinicPatient();
        patient1.setPatientId(1L);
        patient1.setUserId(101L);
        ClinicPatient patient2 = new ClinicPatient();
        patient2.setPatientId(2L);
        patient2.setUserId(102L);
        ClinicPatient patient3 = new ClinicPatient();
        patient3.setPatientId(3L);
        patient3.setUserId(101L);

        when(clinicPatientMapper.selectClinicPatientByIds(eq(patientIds)))
                .thenReturn(Arrays.asList(patient1, patient2, patient3));
        when(clinicPatientMapper.deleteClinicPatientByIds(eq(patientIds))).thenReturn(3);

        int rows = clinicPatientService.deleteClinicPatientByIds(patientIds);

        assertEquals(3, rows);
        verify(clinicPatientMapper, times(1)).selectClinicPatientByIds(eq(patientIds));
        verify(userService, times(1)).deleteUserById(101L);
        verify(userService, times(1)).deleteUserById(102L);
        verify(userService, times(2)).deleteUserById(anyLong());
        verify(clinicPatientMapper, times(1)).deleteClinicPatientByIds(eq(patientIds));
    }

    @Test
    public void insertClinicPatient_shouldCreateLinkedUserWhenUserIdMissing()
    {
        ClinicPatient patient = new ClinicPatient();
        patient.setName("Case User");
        patient.setPhone("13800138000");
        patient.setGender("male");
        patient.setAvatar("/avatar.png");
        patient.setCreateBy("tester");
        patient.setCreateTime(new Date());

        when(passwordService.encryptPassword(any(String.class), any(String.class), any(String.class)))
                .thenReturn("encrypted-password");
        when(userService.insertUser(any(User.class))).thenAnswer(invocation -> {
            User user = invocation.getArgument(0);
            user.setUserId(200L);
            return 1;
        });
        when(clinicPatientMapper.insertClinicPatient(any(ClinicPatient.class))).thenReturn(1);

        int rows = clinicPatientService.insertClinicPatient(patient);

        assertEquals(1, rows);
        assertEquals(Long.valueOf(200L), patient.getUserId());
        verify(userService, times(1)).insertUser(any(User.class));
        verify(clinicPatientMapper, times(1)).insertClinicPatient(eq(patient));

        ArgumentCaptor<User> userCaptor = ArgumentCaptor.forClass(User.class);
        verify(userService).insertUser(userCaptor.capture());
        User createdUser = userCaptor.getValue();
        assertNotNull(createdUser.getRoleIds());
        assertEquals(Long.valueOf(4L), createdUser.getRoleIds()[0]);
        assertEquals("0", createdUser.getSex());
    }

    @Test
    public void updateClinicPatient_shouldSyncUserProfileAndGender()
    {
        ClinicPatient patient = new ClinicPatient();
        patient.setPatientId(10L);
        patient.setUserId(88L);
        patient.setName("Updated Name");
        patient.setPhone("13900139000");
        patient.setAvatar("/new-avatar.png");
        patient.setGender("female");
        patient.setUpdateBy("tester");
        patient.setUpdateTime(new Date());

        User existingUser = new User();
        existingUser.setUserId(88L);
        when(userService.selectUserById(88L)).thenReturn(existingUser);
        when(clinicPatientMapper.updateClinicPatient(eq(patient))).thenReturn(1);

        int rows = clinicPatientService.updateClinicPatient(patient);

        assertEquals(1, rows);
        verify(userService, times(1)).selectUserById(88L);
        verify(userService, times(1)).updateUserInfo(any(User.class));
        verify(clinicPatientMapper, times(1)).updateClinicPatient(eq(patient));

        ArgumentCaptor<User> userCaptor = ArgumentCaptor.forClass(User.class);
        verify(userService).updateUserInfo(userCaptor.capture());
        assertEquals("1", userCaptor.getValue().getSex());
    }

    @Test
    public void deleteClinicPatientByIds_shouldReturnZeroWhenEmpty()
    {
        assertEquals(0, clinicPatientService.deleteClinicPatientByIds(new Long[] {}));
        assertEquals(0, clinicPatientService.deleteClinicPatientByIds(null));

        verify(clinicPatientMapper, times(0)).selectClinicPatientByIds(any(Long[].class));
        verify(clinicPatientMapper, times(0)).deleteClinicPatientByIds(any(Long[].class));
        verify(userService, times(0)).deleteUserById(anyLong());
    }
}
