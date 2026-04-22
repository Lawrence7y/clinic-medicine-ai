# 药品扫码/拍照识别改造方案

## 1. 目标

为当前诊所管理系统增加药品识别能力，覆盖以下场景：

1. 新建药品
2. 药品入库
3. 药品出库
4. 后台 AI 模型配置与切换

核心要求：

1. 新建药品界面主要依赖大模型联网搜索与图片识别。
2. 入库、出库优先使用数据库中已有药品信息，不依赖联网搜索。
3. 扫码或拍照后只自动填充药品名称、厂家、规格、药理信息等文字字段。
4. `price` 始终手动填写，不自动回填。
5. 大模型支持后台新增、修改、启用、切换。
6. 新建药品识别结果返回多个候选，由用户手动选择后再回填。

## 2. 总体方案

### 2.1 新建药品

流程：

1. 小程序用户点击 `扫码识别` 或 `拍照识别`。
2. 小程序调用后端识别接口。
3. 后端根据场景调用配置好的大模型：
   - 扫码：把条码值交给模型联网搜索药品资料。
   - 拍照：把药盒/包装图片交给视觉模型识别，并结合联网搜索补全信息。
4. 后端返回多个候选药品。
5. 小程序展示候选列表。
6. 用户选择候选后，自动回填表单文字信息。
7. 用户手动填写价格并保存。

### 2.2 入库

流程：

1. 小程序用户点击 `扫码选药`。
2. 后端按 `barcode` 在本地 `clinic_medicine` 表中精确匹配。
3. 命中后自动选中药品，并显示药品名称、规格、厂家。
4. 用户继续手动填写数量、批次号、有效期、备注。
5. 未命中则提示先去新建药品建档。

### 2.3 出库

流程：

1. 小程序用户点击 `扫码选药`。
2. 后端按 `barcode` 匹配本地药品。
3. 命中后自动选中药品并加载可用批次。
4. 用户继续手动确认数量、病历、患者、医生、用途等业务字段。
5. 未命中则提示系统未建档，不能直接出库。

## 3. 场景划分

建议定义以下固定场景：

1. `medicine_create_code`
2. `medicine_create_image`
3. `medicine_stock_in_code`
4. `medicine_stock_out_code`

建议增加 `execution_mode` 字段，控制场景执行方式：

1. `model_only`
2. `local_only`
3. `local_then_model`

默认建议：

1. `medicine_create_code` -> `local_then_model`
2. `medicine_create_image` -> `model_only`
3. `medicine_stock_in_code` -> `local_only`
4. `medicine_stock_out_code` -> `local_only`

## 4. 数据库改造

### 4.1 药品表扩展

表：`clinic_medicine`

新增字段：

1. `barcode varchar(64) null comment '药品条码'`

新增索引：

1. `idx_barcode (barcode)`

说明：

1. 暂不加唯一索引，避免历史数据或包装差异导致冲突。
2. 新建药品时，将识别出的条码保存到该字段。

### 4.2 AI 配置表

建议新增 3 张表：

#### `clinic_ai_provider`

字段建议：

1. `provider_id`
2. `provider_code`
3. `provider_name`
4. `api_base_url`
5. `api_key`
6. `enabled`
7. `remark`
8. `create_by`
9. `create_time`
10. `update_by`
11. `update_time`

#### `clinic_ai_model`

字段建议：

1. `model_id`
2. `provider_id`
3. `model_code`
4. `model_name`
5. `supports_vision`
6. `supports_web_search`
7. `supports_json_schema`
8. `enabled`
9. `remark`
10. `create_by`
11. `create_time`
12. `update_by`
13. `update_time`

#### `clinic_ai_scene_binding`

字段建议：

1. `scene_id`
2. `scene_code`
3. `scene_name`
4. `execution_mode`
5. `primary_model_id`
6. `fallback_model_id`
7. `candidate_limit`
8. `timeout_ms`
9. `enabled`
10. `remark`
11. `create_by`
12. `create_time`
13. `update_by`
14. `update_time`

### 4.3 SQL 文件建议

新增：

1. `springboot/sql/20260404_add_clinic_medicine_barcode.sql`
2. `springboot/sql/20260404_add_clinic_ai_tables.sql`
3. `springboot/sql/20260404_add_ai_admin_menu.sql`

同步更新：

1. `springboot/sql/clinic_data_init.sql`
2. `springboot/sql/ry123.sql`

## 5. 后端改造

### 5.1 药品字段链路

需要改造的文件：

1. `springboot/src/main/java/com/ruoyi/project/clinic/medicine/domain/ClinicMedicine.java`
2. `springboot/src/main/java/com/ruoyi/project/clinic/medicine/mapper/ClinicMedicineMapper.java`
3. `springboot/src/main/java/com/ruoyi/project/clinic/medicine/service/IClinicMedicineService.java`
4. `springboot/src/main/java/com/ruoyi/project/clinic/medicine/service/impl/ClinicMedicineServiceImpl.java`
5. `springboot/src/main/resources/mybatis/clinic/ClinicMedicineMapper.xml`
6. `springboot/src/main/java/com/ruoyi/project/clinic/medicine/controller/ClinicMedicineApiController.java`

改造内容：

1. 增加 `barcode` 字段。
2. 增加按 `barcode` 查询能力。
3. 新增/编辑接口支持提交 `barcode`。
4. 保证前后端返回数据里包含 `manufacturer`、`barcode`。

### 5.2 后端 AI 配置模块

建议新增包：

1. `com.ruoyi.project.clinic.ai.controller`
2. `com.ruoyi.project.clinic.ai.domain`
3. `com.ruoyi.project.clinic.ai.mapper`
4. `com.ruoyi.project.clinic.ai.service`
5. `com.ruoyi.project.clinic.ai.service.impl`
6. `com.ruoyi.project.clinic.ai.client`
7. `com.ruoyi.project.clinic.ai.factory`

建议新增类：

1. `ClinicAiProvider`
2. `ClinicAiModel`
3. `ClinicAiSceneBinding`
4. `ClinicAiProviderMapper`
5. `ClinicAiModelMapper`
6. `ClinicAiSceneBindingMapper`
7. `IClinicAiProviderService`
8. `IClinicAiModelService`
9. `IClinicAiSceneBindingService`
10. `ClinicAiProviderServiceImpl`
11. `ClinicAiModelServiceImpl`
12. `ClinicAiSceneBindingServiceImpl`
13. `AiProviderClient`
14. `OpenAiProviderClient`
15. `MiniMaxProviderClient`
16. `AiProviderClientFactory`

### 5.3 后台 Web 管理端

AI 配置不放小程序管理员页，放若依后台 Web 管理端。

菜单建议挂载：

1. `诊所管理`
2. `AI模型配置`
3. `Provider配置`
4. `Model配置`
5. `场景绑定`

建议新增控制器：

1. `ClinicAiProviderController`
2. `ClinicAiModelController`
3. `ClinicAiSceneController`

建议新增模板：

1. `templates/clinic/ai/provider/provider.html`
2. `templates/clinic/ai/provider/add.html`
3. `templates/clinic/ai/provider/edit.html`
4. `templates/clinic/ai/model/model.html`
5. `templates/clinic/ai/model/add.html`
6. `templates/clinic/ai/model/edit.html`
7. `templates/clinic/ai/scene/scene.html`
8. `templates/clinic/ai/scene/add.html`
9. `templates/clinic/ai/scene/edit.html`

### 5.4 Provider 配置后台字段

字段：

1. `providerCode`
2. `providerName`
3. `apiBaseUrl`
4. `apiKey`
5. `enabled`
6. `remark`

说明：

1. 列表页只展示 `apiKey` 掩码。
2. 编辑页允许 `apiKey` 为空，表示保留旧值。
3. 增加 `测试连接` 按钮。

### 5.5 Model 配置后台字段

字段：

1. `providerId`
2. `modelCode`
3. `modelName`
4. `supportsVision`
5. `supportsWebSearch`
6. `supportsJsonSchema`
7. `enabled`
8. `remark`

初始化建议：

1. `gpt-5.4`
2. `minimax-M2.7`

### 5.6 场景绑定后台字段

字段：

1. `sceneCode`
2. `sceneName`
3. `executionMode`
4. `primaryModelId`
5. `fallbackModelId`
6. `candidateLimit`
7. `timeoutMs`
8. `enabled`
9. `remark`

### 5.7 识别接口

建议新增接口：

1. `POST /api/clinic/medicine/recognize/code`
2. `POST /api/clinic/medicine/recognize/image`

#### 扫码识别请求

```json
{
  "scene": "create",
  "code": "6901234567890"
}
```

#### 图片识别请求

表单字段：

1. `scene=create`
2. `file=<图片>`

#### 统一响应结构

```json
{
  "code": 0,
  "msg": "操作成功",
  "data": {
    "scene": "create",
    "source": "code",
    "sessionId": "rec_20260404_xxx",
    "localMatched": false,
    "candidates": [
      {
        "candidateId": "cand_1",
        "source": "model_search",
        "confidence": 0.92,
        "medicineId": null,
        "barcode": "6901234567890",
        "name": "阿莫西林胶囊",
        "specification": "0.25g*24粒",
        "manufacturer": "某某药业",
        "dosageForm": "胶囊剂",
        "form": "内服",
        "category": "抗生素",
        "storage": "阴凉干燥处",
        "pharmacology": "青霉素类抗生素...",
        "indications": "用于敏感菌引起的感染...",
        "dosage": "口服，一次...",
        "sideEffects": "恶心、腹泻...",
        "evidenceUrls": [
          "https://example.com/a",
          "https://example.com/b"
        ]
      }
    ],
    "warnings": [
      "价格需手动填写"
    ]
  }
}
```

### 5.8 识别服务逻辑

#### `scene=create`

1. 先按 `barcode` 查本地。
2. 若本地已存在，可作为候选 1 返回，避免重复建档。
3. 再调用大模型联网搜索或视觉识别，返回多个候选。
4. 合并本地候选和模型候选。
5. 截断到 `candidate_limit`。

#### `scene=stock_in`

1. 只查本地 `barcode`。
2. 命中则返回本地药品。
3. 未命中则直接提示先建档。

#### `scene=stock_out`

1. 只查本地 `barcode`。
2. 命中则返回本地药品。
3. 未命中则提示未建档，不能出库。

### 5.9 模型调用适配层

统一抽象：

1. `AiProviderClient`

建议能力：

1. `recognizeByCode(...)`
2. `recognizeByImage(...)`
3. `testConnection(...)`

实现类：

1. `OpenAiProviderClient`
2. `MiniMaxProviderClient`

说明：

1. 后台 `apiBaseUrl` 建议填写成实际调用地址，而不是单纯域名。
2. 新增模型时尽量通过 provider + model + scene 的组合完成，不把模型名称写死在业务代码中。

### 5.10 Prompt 约束

模型必须只输出 JSON，不返回自然语言说明。

要求：

1. 最多返回 3 个候选。
2. 价格不要返回。
3. 批次号、有效期不要臆造。
4. 看不清的字段返回 `null`。
5. 尽量返回 `evidenceUrls`。

## 6. 小程序端改造

### 6.1 公共 service

新增：

1. `services/_utils/upload.js`
2. `services/medicine-recognition/index.js`

建议方法：

1. `scanMedicineCode()`
2. `recognizeMedicineByCode(code, scene)`
3. `recognizeMedicineByImage(filePath, scene)`

### 6.2 药品服务层

文件：`services/medicine/index.js`

改造内容：

1. 补齐 `manufacturer` 映射。
2. 补齐 `barcode` 映射。
3. 新增/编辑药品时提交 `manufacturer`、`barcode`。
4. 保证 `dosageForm` / `form` 字段映射一致。

### 6.3 新建药品页

文件：

1. `pages/medicine/edit/index.js`
2. `pages/medicine/edit/index.wxml`
3. `pages/medicine/edit/index.wxss`

新增能力：

1. 增加 `生产厂家` 输入项。
2. 增加 `条码` 输入项。
3. 增加 `扫码识别` 按钮。
4. 增加 `拍照识别` 按钮。
5. 增加候选药品弹层或候选列表区域。
6. 用户选择候选后才回填表单。

回填字段：

1. `barcode`
2. `name`
3. `specification`
4. `manufacturer`
5. `dosageForm`
6. `form`
7. `category`
8. `storage`
9. `pharmacology`
10. `indications`
11. `dosage`
12. `sideEffects`

不回填字段：

1. `price`
2. `warningThreshold`
3. `warningStock`
4. `minStock`

额外要求：

1. 页面显式提示：`价格请手动填写`。
2. 若表单已有内容，应用候选前先二次确认，避免无提示覆盖。

### 6.4 入库页

文件：

1. `pages/medicine/stock-in/index.js`
2. `pages/medicine/stock-in/index.wxml`
3. `pages/medicine/stock-in/index.wxss`

新增能力：

1. 在药品搜索区域增加 `扫码选药` 按钮。
2. 扫码后调用 `scene=stock_in`。
3. 命中本地药品后自动选中药品。
4. 未命中时提示去新建药品。

仍由用户手动填写：

1. 数量
2. 批次号
3. 有效期
4. 备注

### 6.5 出库页

文件：

1. `pages/medicine/stock-out/index.js`
2. `pages/medicine/stock-out/index.wxml`
3. `pages/medicine/stock-out/index.wxss`

新增能力：

1. 在药品搜索区域增加 `扫码选药` 按钮。
2. 扫码后调用 `scene=stock_out`。
3. 命中本地药品后自动选中药品。
4. 自动加载该药品的可用批次。

仍由用户手动确认：

1. 数量
2. 病历
3. 患者
4. 医生
5. 用途
6. 备注

## 7. 后台菜单与权限

建议新增菜单：

1. `2060 AI模型配置`
2. `2061 Provider配置`
3. `2062 Model配置`
4. `2063 场景绑定`

建议权限：

1. `clinic:ai:provider:view`
2. `clinic:ai:provider:list`
3. `clinic:ai:provider:add`
4. `clinic:ai:provider:edit`
5. `clinic:ai:provider:remove`
6. `clinic:ai:provider:test`
7. `clinic:ai:model:view`
8. `clinic:ai:model:list`
9. `clinic:ai:model:add`
10. `clinic:ai:model:edit`
11. `clinic:ai:model:remove`
12. `clinic:ai:scene:view`
13. `clinic:ai:scene:list`
14. `clinic:ai:scene:add`
15. `clinic:ai:scene:edit`
16. `clinic:ai:scene:remove`

角色建议：

1. 超级管理员默认拥有所有 AI 菜单权限。
2. 诊所管理员可拥有查看与修改 AI 配置权限。
3. 医生和患者不开放 AI 配置菜单。

## 8. 实施顺序

建议按以下顺序实施：

1. 给 `clinic_medicine` 增加 `barcode` 字段。
2. 打通药品前后端 `manufacturer`、`barcode` 字段链路。
3. 新增 AI 配置表与后台菜单 SQL。
4. 实现后台 Web 的 Provider / Model / Scene 管理页面。
5. 实现 `AiProviderClient` 抽象和 `gpt-5.4`、`minimax-M2.7` 的适配层。
6. 实现药品识别接口 `/recognize/code` 与 `/recognize/image`。
7. 实现新建药品页扫码识别。
8. 实现新建药品页拍照识别。
9. 实现候选列表展示与“用户选择后回填”。
10. 实现入库页本地扫码选药。
11. 实现出库页本地扫码选药与批次联动。
12. 最后补测试连接、日志与错误提示。

## 9. 风险与约束

1. 目前没有独立条码药品库，所以新建药品必须依赖大模型联网搜索。
2. 大模型搜索结果可能来自非官方页面，必须保留候选选择步骤。
3. 同一条码可能存在不同厂家、不同包装版本。
4. 拍照识别受图片清晰度影响较大。
5. `price` 不能交给模型自动生成或自动回填。
6. 出库业务涉及病历和处方药约束，不适合模型全自动决定。

## 10. 验收标准

### 10.1 后台

1. 能在若依后台新增 Provider。
2. 能新增 Model 并绑定 Provider。
3. 能配置场景绑定。
4. 能切换主模型和兜底模型而不改代码。
5. 能测试 Provider 连接。

### 10.2 新建药品

1. 扫码能返回多个候选药品。
2. 拍照能返回多个候选药品。
3. 用户选择候选后，表单文字字段被正确回填。
4. `price` 仍为空且需要手动填写。

### 10.3 入库

1. 扫码能命中本地已建档药品。
2. 命中后自动选中药品。
3. 未命中时提示先建档。

### 10.4 出库

1. 扫码能命中本地已建档药品。
2. 命中后自动加载可出库批次。
3. 处方药仍保留原有病历校验。

## 11. 建议默认配置

1. `medicine_create_code`：主模型 `gpt-5.4`，兜底 `minimax-M2.7`。
2. `medicine_create_image`：主模型 `gpt-5.4`，兜底 `minimax-M2.7`。
3. `medicine_stock_in_code`：本地数据库模式。
4. `medicine_stock_out_code`：本地数据库模式。
5. 候选数默认 `3`。
6. 超时默认 `15000ms`。
7. 失败重试 `1` 次。

## 12. 备注

本方案优先保证：

1. 架构可扩展
2. AI 配置可后台维护
3. 库存业务稳定
4. 识别结果可人工确认

后续如需二期扩展，可考虑：

1. 入库拍照识别批次号和有效期
2. 识别调用日志与审计页面
3. Prompt 后台可编辑
4. Provider 请求头和高级参数配置化
5. 药品重复建档合并提醒
