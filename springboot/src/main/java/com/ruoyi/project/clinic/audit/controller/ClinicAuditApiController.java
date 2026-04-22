package com.ruoyi.project.clinic.audit.controller;

import com.alibaba.fastjson2.JSONObject;
import com.ruoyi.common.utils.security.ShiroUtils;
import com.ruoyi.framework.web.controller.BaseController;
import com.ruoyi.framework.web.domain.AjaxResult;
import com.ruoyi.project.clinic.audit.service.AuditTrailService;
import com.ruoyi.project.clinic.common.ClinicSecuritySupport;
import com.ruoyi.project.system.role.service.IRoleService;
import com.ruoyi.project.system.user.domain.User;
import java.util.List;
import java.util.Set;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/clinic/audit")
public class ClinicAuditApiController extends BaseController
{
    @Autowired
    private AuditTrailService auditTrailService;

    @Autowired
    private IRoleService roleService;

    @GetMapping("/logs")
    public AjaxResult logs(
        @RequestParam(value = "limit", required = false, defaultValue = "100") Integer limit,
        @RequestParam(value = "module", required = false) String module,
        @RequestParam(value = "action", required = false) String action,
        @RequestParam(value = "keyword", required = false) String keyword,
        @RequestParam(value = "startTime", required = false) String startTime,
        @RequestParam(value = "endTime", required = false) String endTime
    )
    {
        User user = ShiroUtils.getSysUser();
        if (user == null)
        {
            return AjaxResult.error("请先登录");
        }
        Set<String> roleKeys = ClinicSecuritySupport.getRoleKeys(user, roleService);
        if (!ClinicSecuritySupport.isAdmin(roleKeys))
        {
            AjaxResult result = AjaxResult.error("暂无权限");
            result.put(AjaxResult.CODE_TAG, 403);
            return result;
        }

        List<JSONObject> list = auditTrailService.latest(
            limit != null ? limit : 100,
            module,
            action,
            keyword,
            startTime,
            endTime
        );
        return success(list);
    }
}
