# chatlink

A new Flutter project.

## 项目架构

### 目录结构
```
lib/
├── main.dart                  # 入口文件
├── core/                      # 核心框架层
│   ├── router/                # 路由管理
│   ├── di/                    # 依赖注入配置
│   ├── services/              # 服务层 (新增)
│   └── theme/                 # 主题配置
│       ├── platform/          # 平台专属主题
│       │   ├── mobile.dart    # - 移动端主题
│       │   ├── desktop.dart   # - PC主题
│       │   ├── tv.dart        # - TV主题
│       │   └── vr.dart        # - VR主题
│
├── platform/                  # 平台适配层
│   ├── mobile/                # 移动端适配（Android/iOS）
│   │   ├── touch/             # - 触摸交互优化
│   │   ├── sensor/            # - 传感器适配
│   │   └── native/            # - 原生功能桥接
│   │
│   ├── desktop/               # PC端适配（Windows/Mac）
│   │   ├── keyboard/          # - 键盘快捷键
│   │   ├── mouse/             # - 鼠标交互
│   │   └── window/            # - 窗口管理
│   │
│   ├── tv/                    # TV端适配（电视盒子/智能电视）
│   │   ├── remote/            # - 遥控器支持
│   │   ├── focus/             # - 焦点导航
│   │   └── display/           # - 大屏渲染优化
│   │
│   └── vr/                    # VR端适配
│       ├── motion/            # - 动作追踪
│       ├── gesture/           # - 手势识别
│       └── spatial/           # - 空间定位
│
├── features/                  # 功能模块（核心业务）
│   ├── ai_chat/               # AI会话模块
│   │   ├── data/              # - 数据层 (新增)
│   │   │   ├── models/        # - 数据模型 (新增)
│   │   │   │   ├── chat_session.dart      # 聊天会话模型
│   │   │   │   └── chat_session.g.dart    # 聊天会话模型生成文件
│   │   │   └── repositories/  # - 数据仓库 (新增)
│   │   │       └── session_repository.dart # 会话数据仓库
│   │   ├── ui/                # - 界面层
│   │   │   ├── widgets/       # - UI组件
│   │   │   │   └── session_list.dart      # 会话列表组件
│   │   │   └── ai_chat_screen.dart        # AI聊天主界面
│   │   ├── model/             # - 数据模型 (原结构)
│   │   └── service/           # - 服务接口
│   │
│   ├── knowledge_base/        # 知识库模块
│   │   ├── data/              # - 数据层 (新增)
│   │   │   ├── models/        # - 数据模型 (新增)
│   │   │   └── repositories/  # - 数据仓库 (新增)
│   │   ├── document/          # - 文档管理 (原结构)
│   │   ├── search/            # - 搜索功能 (原结构)
│   │   └── storage/           # - 存储服务 (原结构)
│   │
│   ├── discovery/             # 发现模块
│   │   ├── data/              # - 数据层 (新增)
│   │   │   ├── models/        # - 数据模型 (新增)
│   │   │   └── repositories/  # - 数据仓库 (新增)
│   │   ├── agent/             # - 自定义Agent (原结构)
│   │   ├── plugin/            # - 插件库 (原结构)
│   │   └── mcp/               # - MCP集成 (原结构)
│   │
│   └── settings/              # 设置模块
│       ├── data/              # - 数据层 (新增)
│       │   ├── models/        # - 数据模型 (新增)
│       │   └── repositories/  # - 数据仓库 (新增)
│       ├── account/           # - 账户管理 (原结构)
│       ├── preference/        # - 偏好设置 (原结构)
│       ├── security/          # - 安全设置 (原结构)
│       └── ui/                # - 界面组件
│           ├── ai_settings_screen.dart     # AI设置界面
│           └── ai_model_list_screen.dart   # AI模型管理界面
│
├── integrations/              # 第三方服务集成 (新增)
│   ├── ai_models/             # AI模型接入配置文件
│   │   ├── ai_model_manager.dart      # AI模型配置管理器
│   │   ├── ai_service_interface.dart  # AI服务接口定义
│   │   ├── ai_service_factory.dart    # AI服务工厂
│   │   ├── openai_service.dart        # OpenAI服务实现
│   │   ├── anthropic_service.dart     # Anthropic服务实现
│   │   ├── google_service.dart        # Google服务实现
│   │   ├── azure_service.dart         # Azure服务实现
│   │   ├── ollama_service.dart        # Ollama服务实现
│   │   └── sample_configurations.dart # 示例配置文件
│   └── services/              # 其他服务集成
│
├── shared/                    # 公共组件层
│   ├── widgets/               # 通用UI组件（带平台适配扩展点）
│   ├── utils/                 # 工具类（封装平台检测）
│   │   └── toast_utils.dart   # Toast工具类
│   ├── constants/             # 常量定义
│   └── extensions/            # 扩展方法
│
└── generated/                 # 自动生成文件
```

### 开发建议
1. 先搭建core框架层
2. 开发shared公共组件
3. 逐个实现features模块
4. 最后完善data数据层