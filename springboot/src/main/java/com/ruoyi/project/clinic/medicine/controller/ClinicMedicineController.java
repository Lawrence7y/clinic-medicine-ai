package com.ruoyi.project.clinic.medicine.controller;

import java.util.List;
import java.util.Arrays;
import java.util.Map;
import org.apache.shiro.authz.annotation.RequiresPermissions;
import org.apache.shiro.authz.annotation.Logical;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import com.ruoyi.framework.aspectj.lang.annotation.Log;
import com.ruoyi.framework.aspectj.lang.enums.BusinessType;
import com.ruoyi.project.clinic.medicine.domain.ClinicMedicine;
import com.ruoyi.project.clinic.medicine.domain.ClinicStockRecord;
import com.ruoyi.project.clinic.medicine.service.IClinicMedicineService;
import com.ruoyi.project.clinic.medicine.service.IClinicStockRecordService;
import com.ruoyi.project.clinic.medicine.mapper.ClinicStockBatchMapper;
import com.ruoyi.framework.web.controller.BaseController;
import com.ruoyi.framework.web.domain.AjaxResult;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.common.utils.security.ShiroUtils;
import com.ruoyi.framework.web.page.TableDataInfo;
import com.ruoyi.project.system.user.domain.User;

@Controller
@RequestMapping("/clinic/medicine")
public class ClinicMedicineController extends BaseController
{
    private String prefix = "clinic/medicine";

    @Autowired
    private IClinicMedicineService clinicMedicineService;
    @Autowired
    private IClinicStockRecordService clinicStockRecordService;
    @Autowired
    private ClinicStockBatchMapper clinicStockBatchMapper;

    @RequiresPermissions("clinic:medicine:view")
    @GetMapping()
    public String medicine()
    {
        return prefix + "/medicine";
    }

    @RequiresPermissions(value = {"clinic:medicine:view", "clinic:medicine:edit"}, logical = Logical.OR)
    @GetMapping("/stock-in")
    public String stockIn()
    {
        return prefix + "/stock-in";
    }

    @RequiresPermissions(value = {"clinic:medicine:view", "clinic:medicine:edit"}, logical = Logical.OR)
    @GetMapping("/stock-out")
    public String stockOut()
    {
        return prefix + "/stock-out";
    }

    @RequiresPermissions(value = {"clinic:medicine:view", "clinic:medicine:edit"}, logical = Logical.OR)
    @GetMapping("/stockOut")
    public String stockOutCompat()
    {
        return prefix + "/stock-out";
    }

    @RequiresPermissions(value = {"clinic:medicine:view", "clinic:medicine:edit"}, logical = Logical.OR)
    @GetMapping({"/stockout", "/stock_out"})
    public String stockOutCompat2()
    {
        return prefix + "/stock-out";
    }

    @RequiresPermissions(value = {"clinic:medicine:view", "clinic:medicine:edit"}, logical = Logical.OR)
    @GetMapping("/batch")
    public String batch()
    {
        return prefix + "/batch";
    }

    @RequiresPermissions(value = {"clinic:medicine:view", "clinic:medicine:edit"}, logical = Logical.OR)
    @GetMapping("/expiry-warning")
    public String expiryWarning()
    {
        return prefix + "/expiry-warning";
    }

    @RequiresPermissions("clinic:medicine:list")
    @PostMapping("/list")
    @ResponseBody
    public TableDataInfo list(ClinicMedicine clinicMedicine)
    {
        startPage();
        List<ClinicMedicine> list = clinicMedicineService.selectClinicMedicineList(clinicMedicine);
        return getDataTable(list);
    }

    @RequiresPermissions("clinic:medicine:export")
    @Log(title = "药品管理", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    @ResponseBody
    public AjaxResult export(ClinicMedicine clinicMedicine)
    {
        List<ClinicMedicine> list = clinicMedicineService.selectClinicMedicineList(clinicMedicine);
        ExcelUtil<ClinicMedicine> util = new ExcelUtil<ClinicMedicine>(ClinicMedicine.class);
        return util.exportExcel(list, "药品数据");
    }

    @GetMapping("/add")
    public String add()
    {
        return prefix + "/add";
    }

    @RequiresPermissions("clinic:medicine:add")
    @Log(title = "药品管理", businessType = BusinessType.INSERT)
    @PostMapping("/add")
    @ResponseBody
    public AjaxResult addSave(ClinicMedicine clinicMedicine)
    {
        return toAjax(clinicMedicineService.insertClinicMedicine(clinicMedicine));
    }

    @GetMapping("/edit/{medicineId}")
    public String edit(@PathVariable("medicineId") Long medicineId, ModelMap mmap)
    {
        ClinicMedicine clinicMedicine = clinicMedicineService.selectClinicMedicineById(medicineId);
        mmap.put("clinicMedicine", clinicMedicine);
        return prefix + "/edit";
    }

    @RequiresPermissions("clinic:medicine:edit")
    @Log(title = "药品管理", businessType = BusinessType.UPDATE)
    @PostMapping("/edit")
    @ResponseBody
    public AjaxResult editSave(ClinicMedicine clinicMedicine)
    {
        if (clinicMedicine.getMedicineId() == null)
        {
            return AjaxResult.error("参数错误");
        }
        ClinicMedicine dbMedicine = clinicMedicineService.selectClinicMedicineById(clinicMedicine.getMedicineId());
        if (dbMedicine == null)
        {
            return AjaxResult.error("药品不存在");
        }
        // 编辑页面不允许直接修改库存，库存仅允许通过入库/出库变更
        clinicMedicine.setStock(dbMedicine.getStock());
        return toAjax(clinicMedicineService.updateClinicMedicine(clinicMedicine));
    }

    @RequiresPermissions("clinic:medicine:remove")
    @Log(title = "药品管理", businessType = BusinessType.DELETE)
    @PostMapping("/remove")
    @ResponseBody
    public AjaxResult remove(String ids)
    {
        Long[] medicineIds = Arrays.stream(ids.split(","))
                .map(Long::valueOf)
                .toArray(Long[]::new);
        return toAjax(clinicMedicineService.deleteClinicMedicineByIds(medicineIds));
    }

    @RequiresPermissions("clinic:medicine:view")
    @PostMapping("/stock/list")
    @ResponseBody
    public TableDataInfo stockList(ClinicStockRecord clinicStockRecord)
    {
        startPage();
        List<ClinicStockRecord> list = clinicStockRecordService.selectClinicStockRecordList(clinicStockRecord);
        return getDataTable(list);
    }

    @RequiresPermissions("clinic:medicine:view")
    @PostMapping("/batch/list")
    @ResponseBody
    public TableDataInfo batchList(String medicineName, Long medicineId)
    {
        startPage();
        List<Map<String, Object>> list = clinicStockBatchMapper.selectBatchPageList(medicineName, medicineId);
        return getDataTable(list);
    }

    @RequiresPermissions("clinic:medicine:view")
    @PostMapping("/expiry-warning/list")
    @ResponseBody
    public TableDataInfo expiryWarningList(String medicineName, Integer days)
    {
        List<Map<String, Object>> list = clinicStockRecordService.selectNearExpiryBatchWarnings(days, null, medicineName);
        return getDataTable(list);
    }

    @RequiresPermissions("clinic:medicine:edit")
    @PostMapping("/expiry-warning/off-shelf")
    @ResponseBody
    public AjaxResult offShelfNearExpiry(String ids, Integer days)
    {
        User currentUser = ShiroUtils.getSysUser();
        if (currentUser == null)
        {
            return AjaxResult.error("未登录");
        }
        Map<String, Object> result =
            clinicStockRecordService.offShelfNearExpiryBatches(days, currentUser.getUserId(), currentUser.getUserName());
        return AjaxResult.success(result);
    }

    @RequiresPermissions("clinic:medicine:remove")
    @PostMapping("/expiry-warning/remove")
    @ResponseBody
    public AjaxResult removeExpiryBatch(String ids)
    {
        if (ids == null || ids.trim().isEmpty())
        {
            return AjaxResult.error("请选择要删除的批次");
        }
        Long[] recordIds = Arrays.stream(ids.split(","))
                .map(Long::valueOf)
                .toArray(Long[]::new);
        return toAjax(clinicStockRecordService.deleteClinicStockRecordByIds(recordIds));
    }

    @RequiresPermissions("clinic:medicine:edit")
    @PostMapping("/stock/add")
    @ResponseBody
    public AjaxResult stockAdd(ClinicStockRecord clinicStockRecord)
    {
        User currentUser = ShiroUtils.getSysUser();
        if (currentUser == null)
        {
            return AjaxResult.error("未登录");
        }
        clinicStockRecord.setOperatorId(currentUser.getUserId());
        clinicStockRecord.setOperatorName(currentUser.getUserName());
        try
        {
            return toAjax(clinicStockRecordService.insertClinicStockRecord(clinicStockRecord));
        }
        catch (RuntimeException ex)
        {
            return AjaxResult.error(ex.getMessage());
        }
    }
}
