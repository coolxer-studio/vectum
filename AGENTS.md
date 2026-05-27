# AGENTS.md

---

## 1. 项目概述

**Vectum** 是基于 Vector 封装的轻量级数据管道管理工具，面向运维/DevOps团队，提供可视化界面 + RESTful API + MCP协议三位一体能力，用于统一管理、调度、监控多实例 Vector 数据采集任务。

**技术栈**：Java 17 + Spring Boot 3.2.0 + Spring AI MCP Server 1.1.4 + SpringDoc OpenAPI 2.3.0 + Vector 0.35+

**仓库结构**：
- `src/main/java/com/coolxer/` - 后端业务代码
- `src/main/resources/` - 配置文件与静态资源
- `deploy/` - Docker部署配置
- `doc/` - 项目文档

**核心能力**：多实例Vector管理、RESTful API、可视化Web UI、MCP协议支持、自然语言配置生成

---

## 2. 快速命令

### 构建与启动
| 命令 | 说明 |
|------|------|
| `mvn clean compile` | 编译项目 |
| `mvn spring-boot:run` | 开发态运行 |
| `mvn clean package` | 打包构建 |
| `java -jar target/application.jar` | 运行打包后的Jar |
| `docker build -t vectum:latest .` | 构建Docker镜像 |
| `docker run -d -p 11002:11002 vectum:latest` | 运行Docker容器 |

### 质量检查
| 命令 | 说明 |
|------|------|
| `mvn test` | 运行单元测试 |
| `mvn checkstyle:check` | 代码风格检查 |

### 环境变量配置
- **配置文件位置**：`src/main/resources/application.properties`
- **开发环境**：`application-dev.properties`
- **生产环境**：`application-prod.properties`
- **启动参数**：`--spring.config.location=src/main/resources/application.properties`

**关键配置项**：
| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| `server.port` | 11002 | 服务端口 |
| `vector.home` | /vector/ | Vector安装目录 |
| `task.workspace` | /workspace/ | 任务工作空间目录 |

---

## 3. 后端架构

### 包结构树
```
src/main/java/com/coolxer/
├── Application.java          # Spring Boot启动类
├── controller/               # REST API控制器层
│   ├── IndexController.java  # 首页路由
│   └── TaskController.java   # 任务管理API
├── service/                  # 业务服务层
│   ├── impl/                 # 服务实现类
│   │   ├── MonitorServiceImpl.java
│   │   ├── TaskServiceImpl.java
│   │   └── VectorServiceImpl.java
│   ├── McpTaskTools.java     # MCP工具类（AI交互）
│   ├── MonitorService.java   # 日志监控接口
│   ├── TaskService.java      # 任务管理接口
│   └── VectorService.java    # Vector进程管理接口
├── model/                    # 数据模型
│   ├── dto/                  # 数据传输对象（入参）
│   │   └── TaskDto.java
│   ├── vo/                   # 视图对象（出参）
│   │   ├── ResponseWrap.java
│   │   └── TaskVo.java
│   └── *.java                # 业务实体类
├── dao/                      # 数据访问层
│   ├── TaskRepository.java
│   └── TaskRepositoryImpl.java
├── config/                   # 配置类
│   ├── AsyncConfig.java      # 异步线程池配置
│   ├── JacksonConfig.java    # JSON序列化配置
│   ├── McpConfig.java        # MCP协议配置
│   └── OpenApiConfig.java    # Swagger文档配置
├── commons/                  # 公共组件
│   ├── enums/                # 枚举类
│   └── exception/            # 异常处理
├── component/                # Spring组件
│   └── StartRunnerComponent.java
└── utils/                    # 工具类
    └── FileUtil.java
```

### 核心子系统说明
| 子系统 | 职责 | 关键文件 |
|--------|------|----------|
| 任务管理 | CRUD操作、状态管理 | `TaskController.java`, `TaskServiceImpl.java` |
| 进程管理 | Vector进程启停、监控 | `VectorServiceImpl.java` |
| 日志监控 | 日志采集、实时查看 | `MonitorServiceImpl.java` |
| MCP协议 | AI智能体交互接口 | `McpConfig.java`, `McpTaskTools.java` |

### 详细文档链接
- API接口文档：`doc/API接口.md`
- 系统架构图：`doc/architecture.png`

---

## 4. 前端架构

### 技术栈
- **低代码框架**：AMIS（百度开源）
- **模板引擎**：Thymeleaf（用于渲染AMIS配置JSON）
- **图标库**：FontAwesome（AMIS内置支持）
- **代码编辑器**：CodeMirror（AMIS集成）

### AMIS配置方式
- 通过JSON Schema配置页面结构
- 动态渲染表单、表格、弹窗等组件
- 支持远程数据源绑定

### 路由方案
- `/` - 首页（任务列表）- AMIS表格组件
- `/task/add` - 创建任务 - AMIS表单组件
- `/task/{id}/edit` - 编辑任务 - AMIS表单组件（动态加载数据）
- `/task/{id}/log` - 查看日志 - AMIS代码编辑器组件

### API层约定
- 基础路径：`/vectum/api/v1/task`
- 统一响应格式：`{status, msg, data}`
- AMIS数据源配置：通过`api`属性绑定后端接口
- 数据格式：JSON

### AMIS组件规范
- 使用AMIS内置组件：`Page`、`Table`、`Form`、`Dialog`、`CodeEditor`
- 图标使用AMIS内置图标或FontAwesome
- 表单校验使用AMIS内置校验规则
- 表格分页、排序由AMIS自动处理

---

## 5. 关键约定

### 硬性编码规则

**1. 缩进与格式**
- 必须使用4个空格缩进，禁止Tab
- 行尾必须加分号
- 代码块首尾必须有空格

**2. 命名规范**
- Java类名：大驼峰（如`TaskController`）
- 方法/变量：小驼峰（如`taskService`）
- 常量：全大写+下划线（如`MAX_TASK_COUNT`）
- 枚举类：后缀Enum（如`ResultCodeEnum`）
- **禁止使用拼音命名**

**3. 注释规范**
- 类必须有类级注释说明职责
- 公共方法必须有Javadoc注释
- 复杂逻辑必须有单行注释解释

**4. 异常处理**
- 必须使用统一的`ApiException`处理业务异常
- 禁止捕获异常后静默吞掉
- 异常信息必须包含上下文

**5. 日志规范**
- 使用SLF4J日志框架
- 禁止生产代码中使用`System.out.println`
- 日志级别：DEBUG用于开发调试，INFO用于业务流程，WARN用于警告，ERROR用于错误

**6. 依赖管理**
- 必须通过Maven管理依赖
- 禁止手动添加JAR包
- 依赖版本必须在`pom.xml`中统一管理

**7. 配置管理**
- 配置项必须在`application.properties`中定义
- 禁止硬编码配置值
- 敏感配置必须通过环境变量注入

---

## 6. 本地开发及验证流程

### 完整闭环：改 → 构建 → 启动 → 验证

**1. 修改代码**
- 使用IDE打开项目，修改对应文件
- 遵循编码规范

**2. 编译构建**
```bash
mvn clean compile
```

**3. 启动服务**
```bash
mvn spring-boot:run
```
- 服务启动后访问：`http://localhost:11002`

**4. 验证接口**

### curl验证模板

**创建任务**：
```bash
curl -X POST http://localhost:11002/vectum/api/v1/task/add \
  -H "Content-Type: application/json" \
  -d '{
    "name": "test-task",
    "description": "测试任务",
    "config": "[sources]\n  test = { type = \"file\", path = \"/var/log/test.log\" }\n\n[sinks]\n  console = { type = \"console\" }",
    "source": "manual"
  }'
```

**查询所有任务**：
```bash
curl -X GET http://localhost:11002/vectum/api/v1/task/all
```

**启动/停止任务**：
```bash
curl -X POST http://localhost:11002/vectum/api/v1/task/{id}/toggle
```

**获取任务日志**：
```bash
curl -X GET "http://localhost:11002/vectum/api/v1/task/{id}/log?log_type=console"
```

### 日志路径
- 应用日志：`logs/vectum.log`
- 任务日志：`{task.workspace}/{task.id}/vector.log`

---

## 7. 质量检查

### 命令矩阵

| 命令 | 用途 | 检查内容 |
|------|------|----------|
| `mvn clean compile` | 编译检查 | 语法错误、依赖问题 |
| `mvn test` | 单元测试 | 测试覆盖率、业务逻辑 |
| `mvn checkstyle:check` | 代码风格 | 编码规范、格式问题 |
| `mvn dependency:tree` | 依赖分析 | 依赖冲突、版本问题 |
| `mvn spring-boot:run` | 启动验证 | 配置正确性、服务可用性 |

### 检查顺序建议
1. `mvn clean compile` - 先确保编译通过
2. `mvn checkstyle:check` - 检查代码风格
3. `mvn test` - 运行单元测试
4. `mvn spring-boot:run` - 启动验证

---

## 8. 参考项目约定

### 参考项目列表

| 优先级 | 项目 | 用途 |
|--------|------|------|
| 1 | Spring Boot官方文档 | 框架使用规范 |
| 2 | Spring AI官方文档 | MCP协议实现 |
| 3 | AMIS官方文档 | 前端低代码框架使用规范 |
| 4 | Vector官方文档 | 数据管道配置 |
| 5 | SpringDoc OpenAPI | API文档生成 |
| 6 | Lombok官方文档 | 代码简化 |

### 优先级规则
1. 优先遵循Spring Boot官方规范
2. MCP协议实现必须符合Spring AI标准
3. 前端开发必须遵循AMIS官方规范
4. Vector配置必须兼容0.35+版本
5. 冲突时以本项目约定为准

### AMIS前端约定
1. **组件使用**：优先使用AMIS内置组件，避免自定义组件
2. **配置方式**：通过JSON Schema配置页面，禁止直接操作DOM
3. **数据源**：通过`api`属性绑定后端接口，统一使用POST方法
4. **响应格式**：后端返回必须包含`status`、`msg`、`data`字段
5. **表单校验**：使用AMIS内置校验规则，禁止前端自定义校验
6. **样式定制**：通过AMIS的`className`和`style`属性定制样式
7. **路由管理**：使用AMIS的`Page`组件配合后端路由实现页面跳转

---

## 9. 文档导航

### 文档索引表

| 文档名称 | 路径 | 说明 |
|----------|------|------|
| 项目说明 | `README.md` | 项目介绍、快速上手 |
| API接口 | `doc/API接口.md` | 完整API文档 |
| 系统架构 | `doc/architecture.png` | 架构图 |
| AI协作指南 | `agents.md` | 本文件 |
| Docker部署 | `deploy/docker-compose.yml` | 部署配置 |
| 许可证 | `LICENSE` | Apache 2.0 |
| 贡献指南 | `CONTRIBUTING.md` | 开发贡献规范 |

### 服务访问地址

| 服务 | 地址 |
|------|------|
| API服务 | `http://<ip>:11002` |
| Swagger文档 | `http://<ip>:11002/swagger-ui/index.html` |
| MCP接口 | `http://<ip>:11002/sse` |
