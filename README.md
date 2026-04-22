# 🏥 Clinic Medicine AI Recognition

<p align="center">
  <a href="#english">English</a> | <a href="#中文">中文</a>
</p>

---

<div id="english"></div>

## English

An **AI-powered medicine recognition module** integrated into a clinic management WeChat mini-program. Supports barcode scanning and photo recognition for medicine identification, with a configurable multi-model AI backend.

> 📄 **Full PRD**: See `MEDICINE_RECOGNITION_PLAN.md` for the complete 600+ line product design document.

### ✨ Key Features

| Module | Feature |
|---|---|
| **New Medicine** | Barcode scan / photo recognition to auto-fill medicine info |
| **Stock In** | Barcode lookup from local DB, auto-select medicine |
| **Stock Out** | Barcode lookup + auto-load available batches |
| **Multi-Model AI** | GPT-5.4 + MiniMax-M2.7 with adapter layer |
| **Admin Console** | Backend web UI for Provider/Model/Scene configuration |
| **Zero-Code Switch** | Change AI models without modifying code |
| **Candidate Results** | Returns multiple candidates for human confirmation |
| **Local Fallback** | Stock operations use local DB first, no AI dependency |

### 🏗 System Architecture

```
Clinic Medicine AI
├── WeChat Mini-Program (Frontend)
│   ├── Scan/Photo capture
│   ├── Candidate selection UI
│   ├── Medicine form auto-fill
│   └── Stock in/out workflows
├── SpringBoot Backend
│   ├── Medicine CRUD APIs
│   ├── AI Recognition Service
│   │   ├── AiProviderClient (abstract)
│   │   ├── OpenAiProviderClient
│   │   └── MiniMaxProviderClient
│   └── Stock Management
├── AI Configuration (Admin)
│   ├── Provider management
│   ├── Model management
│   └── Scene-Model binding
└── MySQL Database
    ├── clinic_medicine (with barcode)
    ├── clinic_ai_provider
    ├── clinic_ai_model
    └── clinic_ai_scene_binding
```

### 🚀 Quick Start

#### Mini-Program

Import the `pages/` and `services/` directories into the WeChat Developer Tools.

#### SpringBoot Backend

```bash
cd springboot
mvn clean install
mvn spring-boot:run
```

#### AI Configuration

1. Login to the RuoYi admin console
2. Navigate to: Clinic Management → AI Model Config
3. Add Provider (OpenAI / MiniMax)
4. Add Models (GPT-5.4, MiniMax-M2.7)
5. Bind Scenes to Models:
   - `medicine_create_code` → GPT-5.4
   - `medicine_create_image` → GPT-5.4
   - `medicine_stock_in_code` → Local DB
   - `medicine_stock_out_code` → Local DB

### 📦 Project Structure

```
clinic-medicine-ai/
├── pages/                          # WeChat mini-program pages
│   ├── medicine/
│   │   ├── edit/                   # New medicine (scan/photo)
│   │   ├── stock-in/               # Stock in (barcode lookup)
│   │   └── stock-out/              # Stock out (batch selection)
│   └── ...
├── services/                       # Mini-program API services
│   ├── medicine-recognition/
│   └── medicine/
├── springboot/
│   ├── src/main/java/.../clinic/
│   │   ├── ai/                     # AI module
│   │   │   ├── client/             # Provider clients
│   │   │   ├── controller/
│   │   │   ├── domain/
│   │   │   ├── service/
│   │   │   └── mapper/
│   │   └── medicine/               # Medicine module
│   └── src/main/resources/
│       ├── mybatis/
│       └── templates/clinic/ai/    # Admin HTML pages
├── MEDICINE_RECOGNITION_PLAN.md    # Full PRD document
└── README.md
```

### 🛠 Tech Stack

| Layer | Technology |
|---|---|
| Frontend | WeChat Mini-Program (WXML/WXSS/JS) |
| Backend | Java 17, SpringBoot, MyBatis |
| Database | MySQL 8.0 |
| Admin UI | RuoYi Framework (Thymeleaf) |
| AI Models | GPT-5.4, MiniMax-M2.7 |
| AI Adapter | OpenAI API, MiniMax API |

### 📋 API Endpoints

```
POST /api/clinic/medicine/recognize/code
  Body: { "scene": "create", "code": "6901234567890" }

POST /api/clinic/medicine/recognize/image
  Form: scene=create, file=<image>

GET /api/clinic/medicine/list
GET /api/clinic/medicine/{id}
POST /api/clinic/medicine
PUT /api/clinic/medicine
DELETE /api/clinic/medicine/{ids}
```

### 🔮 Roadmap

- [ ] Batch barcode scanning for stock operations
- [ ] AI-generated batch number & expiry recognition
- [ ] Medicine interaction checking
- [ ] Voice-based medicine lookup
- [ ] Integration with national drug database

---

<div id="中文"></div>

## 中文

一个集成到诊所管理微信小程序的 **AI 药品识别模块**。支持药品条码扫描和拍照识别，并配有可配置的多模型 AI 后台管理系统。

> 📄 **完整产品方案**：参见 `MEDICINE_RECOGNITION_PLAN.md`，包含 600+ 行的详细 PRD 级设计文档。

### ✨ 核心功能

| 模块 | 功能 |
|---|---|
| **新建药品** | 条码扫描 / 拍照识别，自动填充药品信息 |
| **药品入库** | 本地数据库条码匹配，自动选中药品 |
| **药品出库** | 条码匹配 + 自动加载可用批次 |
| **多模型 AI** | GPT-5.4 + MiniMax-M2.7，带适配层 |
| **管理后台** | 后台 Web UI 配置 Provider/Model/场景 |
| **零代码切换** | 无需修改代码即可更换 AI 模型 |
| **多候选结果** | 返回多个候选供人工确认 |
| **本地兜底** | 入库出库优先使用本地数据库，不依赖 AI |

### 🏗 系统架构

```
诊所药品 AI 识别系统
├── 微信小程序（前端）
│   ├── 扫码/拍照采集
│   ├── 候选结果选择界面
│   ├── 药品表单自动填充
│   └── 入库出库工作流
├── SpringBoot 后端
│   ├── 药品 CRUD 接口
│   ├── AI 识别服务
│   │   ├── AiProviderClient（抽象层）
│   │   ├── OpenAiProviderClient
│   │   └── MiniMaxProviderClient
│   └── 库存管理
├── AI 配置（管理后台）
│   ├── Provider 管理
│   ├── Model 管理
│   └── 场景-模型绑定
└── MySQL 数据库
    ├── clinic_medicine（含条码字段）
    ├── clinic_ai_provider
    ├── clinic_ai_model
    └── clinic_ai_scene_binding
```

### 🚀 快速开始

#### 微信小程序

将 `pages/` 和 `services/` 目录导入微信开发者工具即可运行。

#### SpringBoot 后端

```bash
cd springboot
mvn clean install
mvn spring-boot:run
```

#### AI 配置

1. 登录若依（RuoYi）管理后台
2. 导航至：诊所管理 → AI 模型配置
3. 添加 Provider（OpenAI / MiniMax）
4. 添加模型（GPT-5.4、MiniMax-M2.7）
5. 绑定场景到模型：
   - `medicine_create_code` → GPT-5.4
   - `medicine_create_image` → GPT-5.4
   - `medicine_stock_in_code` → 本地数据库
   - `medicine_stock_out_code` → 本地数据库

### 📦 项目结构

```
clinic-medicine-ai/
├── pages/                          # 微信小程序页面
│   ├── medicine/
│   │   ├── edit/                   # 新建药品（扫码/拍照）
│   │   ├── stock-in/               # 入库（条码匹配）
│   │   └── stock-out/              # 出库（批次选择）
│   └── ...
├── services/                       # 小程序 API 服务层
│   ├── medicine-recognition/
│   └── medicine/
├── springboot/
│   ├── src/main/java/.../clinic/
│   │   ├── ai/                     # AI 模块
│   │   │   ├── client/             # Provider 客户端
│   │   │   ├── controller/
│   │   │   ├── domain/
│   │   │   ├── service/
│   │   │   └── mapper/
│   │   └── medicine/               # 药品模块
│   └── src/main/resources/
│       ├── mybatis/
│       └── templates/clinic/ai/    # 管理后台页面
├── MEDICINE_RECOGNITION_PLAN.md    # 完整方案文档
└── README.md
```

### 🛠 技术栈

| 层级 | 技术 |
|---|---|
| 前端 | 微信小程序（WXML/WXSS/JS） |
| 后端 | Java 17, SpringBoot, MyBatis |
| 数据库 | MySQL 8.0 |
| 管理后台 | 若依框架（Thymeleaf） |
| AI 模型 | GPT-5.4, MiniMax-M2.7 |
| AI 适配 | OpenAI API, MiniMax API |

### 📋 接口列表

```
POST /api/clinic/medicine/recognize/code
  请求体: { "scene": "create", "code": "6901234567890" }

POST /api/clinic/medicine/recognize/image
  表单: scene=create, file=<图片>

GET /api/clinic/medicine/list
GET /api/clinic/medicine/{id}
POST /api/clinic/medicine
PUT /api/clinic/medicine
DELETE /api/clinic/medicine/{ids}
```

### 🔮 未来规划

- [ ] 批量条码扫描入库
- [ ] AI 识别批号与有效期
- [ ] 药品相互作用检查
- [ ] 语音查询药品
- [ ] 对接国家药品数据库

---

## License

MIT
