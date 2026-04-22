package com.ruoyi.project.clinic.schedule.controller;

import com.github.pagehelper.PageHelper;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.security.ShiroUtils;
import com.ruoyi.framework.web.controller.BaseController;
import com.ruoyi.framework.web.domain.AjaxResult;
import com.ruoyi.framework.web.page.TableDataInfo;
import com.ruoyi.project.clinic.schedule.domain.ClinicSchedule;
import com.ruoyi.project.clinic.schedule.service.IClinicScheduleService;
import com.ruoyi.project.system.role.service.IRoleService;
import com.ruoyi.project.system.user.domain.User;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
@RequestMapping("/api/clinic/schedule")
public class ClinicScheduleApiController extends BaseController
{
    @Autowired
    private IClinicScheduleService clinicScheduleService;

    @Autowired
    private IRoleService roleService;

    @PostMapping(value = "/list", consumes = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public TableDataInfo list(@RequestBody(required = false) ClinicScheduleQuery query)
    {
        return listInternal(query);
    }

    @PostMapping(value = "/list", consumes = MediaType.APPLICATION_FORM_URLENCODED_VALUE)
    @ResponseBody
    public TableDataInfo listForm(ClinicScheduleQuery query)
    {
        return listInternal(query);
    }

    private TableDataInfo listInternal(ClinicScheduleQuery query)
    {
        User currentUser = ShiroUtils.getSysUser();
        if (currentUser != null)
        {
            Set<String> roleKeys = roleService.selectRoleKeys(currentUser.getUserId());
            if (roleKeys != null && roleKeys.contains("doctor"))
            {
                if (query == null)
                {
                    query = new ClinicScheduleQuery();
                }
                query.setDoctorId(currentUser.getUserId());
            }
        }

        if (query == null)
        {
            query = new ClinicScheduleQuery();
        }

        int pageNum = query.getPageNum() != null ? query.getPageNum() : 1;
        int pageSize = query.getPageSize() != null ? query.getPageSize() : 10;
        if (pageSize > 200) { pageSize = 200; }
        PageHelper.startPage(pageNum, pageSize);

        ClinicSchedule criteria = new ClinicSchedule();
        criteria.setDoctorId(query.getDoctorId());
        criteria.setDoctorName(query.getDoctorName());
        criteria.setScheduleDate(DateUtils.parseDate(query.getScheduleDate()));

        List<ClinicSchedule> list = clinicScheduleService.selectClinicScheduleList(criteria);
        return getDataTable(list);
    }

    @GetMapping("/getInfo")
    @ResponseBody
    public AjaxResult getInfo(@RequestParam Long scheduleId)
    {
        User currentUser = ShiroUtils.getSysUser();
        if (currentUser == null)
        {
            return AjaxResult.error("未登录");
        }
        Set<String> roleKeys = roleService.selectRoleKeys(currentUser.getUserId());
        ClinicSchedule schedule = clinicScheduleService.selectClinicScheduleById(scheduleId);
        if (schedule == null)
        {
            return AjaxResult.error("排班不存在");
        }
        if (roleKeys != null && roleKeys.contains("doctor") && schedule.getDoctorId() != null
            && !schedule.getDoctorId().equals(currentUser.getUserId()))
        {
            return AjaxResult.error("无权限访问");
        }
        return AjaxResult.success(schedule);
    }

    @PostMapping("/add")
    @ResponseBody
    public AjaxResult addSave(@RequestBody ClinicSchedule clinicSchedule)
    {
        User currentUser = ShiroUtils.getSysUser();
        if (currentUser == null)
        {
            return AjaxResult.error("未登录");
        }
        Set<String> roleKeys = roleService.selectRoleKeys(currentUser.getUserId());
        if (roleKeys == null || (!roleKeys.contains("doctor") && !roleKeys.contains("admin")
                && !roleKeys.contains("common") && !roleKeys.contains("clinic_admin")))
        {
            return AjaxResult.error("无权限访问");
        }
        if (roleKeys.contains("doctor"))
        {
            clinicSchedule.setDoctorId(currentUser.getUserId());
            clinicSchedule.setDoctorName(currentUser.getUserName());
        }
        try
        {
            return toAjax(clinicScheduleService.insertClinicSchedule(clinicSchedule));
        }
        catch (RuntimeException ex)
        {
            return AjaxResult.error(ex.getMessage());
        }
    }

    @PostMapping("/edit")
    @ResponseBody
    public AjaxResult editSave(@RequestBody ClinicSchedule clinicSchedule)
    {
        User currentUser = ShiroUtils.getSysUser();
        if (currentUser == null)
        {
            return AjaxResult.error("未登录");
        }
        Set<String> roleKeys = roleService.selectRoleKeys(currentUser.getUserId());
        if (roleKeys == null || (!roleKeys.contains("doctor") && !roleKeys.contains("admin")
                && !roleKeys.contains("common") && !roleKeys.contains("clinic_admin")))
        {
            return AjaxResult.error("无权限访问");
        }
        if (clinicSchedule.getScheduleId() == null)
        {
            return AjaxResult.error("参数错误");
        }
        if (roleKeys.contains("doctor"))
        {
            ClinicSchedule old = clinicScheduleService.selectClinicScheduleById(clinicSchedule.getScheduleId());
            if (old == null)
            {
                return AjaxResult.error("排班不存在");
            }
            if (old.getDoctorId() != null && !old.getDoctorId().equals(currentUser.getUserId()))
            {
                return AjaxResult.error("无权限操作该排班");
            }
            clinicSchedule.setDoctorId(currentUser.getUserId());
            clinicSchedule.setDoctorName(currentUser.getUserName());
        }
        try
        {
            return toAjax(clinicScheduleService.updateClinicSchedule(clinicSchedule));
        }
        catch (RuntimeException ex)
        {
            return AjaxResult.error(ex.getMessage());
        }
    }

    @PostMapping("/remove")
    @ResponseBody
    public AjaxResult remove(@RequestBody(required = false) Map<String, String> params)
    {
        User currentUser = ShiroUtils.getSysUser();
        if (currentUser == null)
        {
            return AjaxResult.error("未登录");
        }
        Set<String> roleKeys = roleService.selectRoleKeys(currentUser.getUserId());
        if (roleKeys == null || (!roleKeys.contains("doctor") && !roleKeys.contains("admin")
                && !roleKeys.contains("common") && !roleKeys.contains("clinic_admin")))
        {
            return AjaxResult.error("无权限访问");
        }
        String ids = params != null && params.get("ids") != null ? params.get("ids") : null;
        if (StringUtils.isEmpty(ids))
        {
            return error("请提供要删除的ID");
        }
        Long[] scheduleIds = Arrays.stream(ids.split(",")).map(Long::valueOf).toArray(Long[]::new);
        if (roleKeys.contains("doctor"))
        {
            for (Long scheduleId : scheduleIds)
            {
                ClinicSchedule schedule = clinicScheduleService.selectClinicScheduleById(scheduleId);
                if (schedule != null && schedule.getDoctorId() != null && !schedule.getDoctorId().equals(currentUser.getUserId()))
                {
                    return AjaxResult.error("无权限删除他人排班");
                }
            }
        }
        return toAjax(clinicScheduleService.deleteClinicScheduleByIds(scheduleIds));
    }

    public static class ClinicScheduleQuery
    {
        private Integer pageNum;
        private Integer pageSize;
        private Long doctorId;
        private String doctorName;
        private String scheduleDate;

        public Integer getPageNum()
        {
            return pageNum;
        }

        public void setPageNum(Integer pageNum)
        {
            this.pageNum = pageNum;
        }

        public Integer getPageSize()
        {
            return pageSize;
        }

        public void setPageSize(Integer pageSize)
        {
            this.pageSize = pageSize;
        }

        public Long getDoctorId()
        {
            return doctorId;
        }

        public void setDoctorId(Long doctorId)
        {
            this.doctorId = doctorId;
        }

        public String getDoctorName()
        {
            return doctorName;
        }

        public void setDoctorName(String doctorName)
        {
            this.doctorName = doctorName;
        }

        public String getScheduleDate()
        {
            return scheduleDate;
        }

        public void setScheduleDate(String scheduleDate)
        {
            this.scheduleDate = scheduleDate;
        }
    }
}
