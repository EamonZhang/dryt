# Task Orchestration for Drycc

## 概述

tod 是基于 Taskfile 的 Drycc 云平台资源编排工具，通过声明式配置，实现项目云平台环境自动化构建。

工具使用 Go Task (taskfile.dev) 作为任务运行器，定义任务来自动化执行应用程序创建、基础服务资源部署和初始化等操作。

## 核心作用

一键构建企业云环境
场景：一个项目启动，需要为开发、测试、演示，各自搭建一套功能相同但独立的云环境

| 对比维度       | 传统方式痛点（手动搭积木）   | TOD 方案优势（配置即蓝图）                 |
| -------------- | ---------------------------- | ------------------------------------------ |
| **流程自动化** | 每套环境需手工搭建，重复劳动 | 定义蓝图后环境自动复制，解放双手           |
| **环境可靠性** | 搭建易出错，配置不稳定       | 最佳实践固化为模板，消除人为失误，保障稳定 |
| **环境一致性** | 多套环境差异大，管理困难     | 基于同一蓝图生成的环境 100%一致，流程顺畅  |
| **交付效率**   | 依赖人员熟练度               | 快速环境交付，快速响应需求                 |

## 系统要求

1. **Go Task**: 需要安装 task 命令行工具

   ```bash
   # 安装方法参考: https://taskfile.dev/installation/
   ```

2. **Drycc CLI**: 需要安装 drycc 命令行工具

   ```bash
   # 确保 drycc 命令可用
   ```

3. **客户端工具(可选)**:
   - PostgreSQL: psql 客户端（用于数据库初始化）
   - Minio: mc 客户端 (用于 MINIO 初始化)

## 项目结构

```
task/
├── Taskfile.yml              # 主任务配置文件
├── readme.md                 # 简要使用说明
├── app/
│   └── Taskfile.yml         # 应用创建任务
├── resource/
│   └── Taskfile.yml         # 资源创建任务（通用）
├── scripts/
│   ├── create-app.sh        # 创建应用脚本
│   ├── create-resources.sh  # 创建资源脚本
│   ├── bind-resources.sh    # 绑定资源脚本
│   ├── wait-resources.sh    # 等待资源就绪脚本
│   ├── init-resources.sh    # 初始化资源脚本
│   ├── prepare-resources.sh # 准备资源脚本
│   └── describe-resources.sh # 描述资源脚本
├── describe/                # 资源信息存储目录
├── mysql-cluster/          # MySQL 资源配置
│   └── values.yml          # Drycc 中使用的 values.yml
├── mongodb/                # MongoDB 资源配置
│   └── values.yml
├── postgresql-cluster-17/  # PostgreSQL 17 资源配置
│   └── values.yml
└── grafana/                # Grafana 资源配置
    └── values.yml
```

### 基本命令

```bash
# 查看所有可用任务
task -l

# 预演任务（不实际执行）
task -n

# 执行默认任务（完整流程）
task

# 执行特定任务
task <任务名称>
```

### 任务说明

#### 默认任务 (default)

执行完整的应用和资源创建流程：

1. 创建应用程序
2. 创建基础资源（MySQL、MongoDB）
3. 创建扩展资源（PostgreSQL）
4. 输出完成信息

```bash
task  # 执行默认任务
```

#### 创建应用任务 (create-app)

单独创建应用程序：

```bash
task create-app
```

#### 创建基础资源任务 (create-resource-base)

创建 MySQL 和 MongoDB 资源（并行执行）：

```bash
task create-resource-base
```

#### 创建扩展资源任务 (create-resource-base02)

创建 PostgreSQL 资源：

```bash
task create-resource-base02
```

#### 单独创建特定资源

可以直接调用预定义的资源任务：

```bash
task mysql-cluster     # 创建 MySQL 集群
task mongodb          # 创建 MongoDB 数据库
task postgresql-cluster-17  # 创建 PostgreSQL 集群
task grafana          # 创建 Grafana 实例
```

### 配置说明

#### 应用名称配置

默认应用名称为 `apptest01`，可以在主 Taskfile.yml 中修改：

```yaml
vars:
  APP: apptest01 # 修改此处更改应用名称
```

#### 资源配置

每个资源都有特定的配置参数：

1. **MySQL Cluster**:

   - NAME: mysql01 # 资源名称
   - PLAN: standard-2c4g20 # 资源规格

2. **MongoDB**:

   - NAME: mongodb01 # 资源名称
   - PLAN: standard-2c4g20 # 资源规格

3. **PostgreSQL Cluster 17**:

   - NAME: postgresql17-01 # 资源名称
   - PLAN: standard-2c4g20 # 资源规格
   - INIT: "true" # 是否初始化数据库（创建用户和数据库）

4. **Grafana**:
   - NAME: grafana01 # 资源名称
   - PLAN: standard-1c1g5 # 资源规格
   - DEPENDENT: postgresql17-01 # 依赖的 PostgreSQL 资源

#### 资源规格

可根据需要修改 PLAN 参数：

- standard-2c4g20: 2 核 CPU, 4GB 内存, 20GB 存储
- standard-1c1g5: 1 核 CPU, 1GB 内存, 5GB 存储
- 其他可用规格请参考 Drycc 文档

#### 自定义配置

每个资源目录下的 values.yml 文件可以包含更详细的配置参数，用于自定义资源部署。

## 工作流程详解

### 完整流程示例

1. **准备阶段**:

   ```bash
   # 检查项目结构
   ls -la task/
   ```

2. **执行默认任务**:

   ```bash
   task
   ```

   这将按顺序执行：

   - 创建应用程序 (apptest01)
   - 并行创建 MySQL 和 MongoDB 资源
   - 创建 PostgreSQL 资源（含数据库初始化）
   - 显示完成信息

3. **验证资源状态**:
   ```bash
   # 查看已创建的资源
   drycc-test resources list -a apptest01
   ```

### 自定义流程

如果需要自定义资源创建顺序，可以修改主 Taskfile.yml 中的任务依赖关系。

#### 创建 Grafana 监控

如果需要 Grafana 监控，需要先创建 PostgreSQL 资源：

```bash
# 创建 PostgreSQL 资源（包含初始化）
task postgresql-cluster-17

# 创建 Grafana 资源（依赖 PostgreSQL）
task grafana
```

#### 仅创建数据库

如果只需要数据库资源，不创建应用：

```bash
# 修改主 Taskfile.yml，注释掉应用创建
# 然后执行：
task create-resource-base
task create-resource-base02
```

## 高级配置

### 修改资源参数

编辑主 Taskfile.yml 中的 includes 部分，修改以下参数：
130

- `NAME`: 资源实例名称
- `PLAN`: 资源规格
- `INIT`: 是否初始化（仅 PostgreSQL）
- `DEPENDENT`: 依赖资源（仅 Grafana）

### 自定义初始化脚本

如果需要自定义数据库初始化，编辑 `scripts/init-resources.sh` 文件，修改 `initialize_postgresql` 函数中的 SQL 语句。

### 添加新的资源类型

要添加新的资源类型：

1. 创建资源目录和 values.yml 文件：

   ```bash
   mkdir -p task/new-resource
   cp task/mysql-cluster/values.yml task/new-resource/
   ```

2. 在主 Taskfile.yml 中添加新的资源任务：

   ```yaml
   includes:
     new-resource:
       taskfile: resource/Taskfile.yml
       vars:
         RESOURCE: "new-resource"
         NAME: newresource01
         PLAN: standard-1c1g5
   ```

3. 根据需要修改资源特定的脚本逻辑。

## 故障排除

### 常见问题

1. **任务执行失败**:

   ```bash
   # 查看详细错误信息
   task -v

   # 检查 drycc-test 是否可用
   drycc-test --version
   ```

2. **资源创建超时**:

   - 检查网络连接
   - 增加等待时间（修改 wait-resources.sh 中的 TIMEOUT 参数）

3. **数据库初始化失败**:

   - 检查 psql 客户端是否安装
   - 验证数据库连接信息

4. **Grafana 依赖问题**:
   - 确保 PostgreSQL 资源已创建且就绪
   - 检查 describe/ 目录下的描述文件

### 日志和调试

1. **启用详细输出**:

   ```bash
   task -v
   ```

2. **查看脚本输出**:

   - 脚本执行日志会显示在控制台
   - 重要信息会以 ✅ 或 ❌ 图标标记

3. **资源状态检查**:
   ```bash
   # 查看特定资源状态
   drycc-test resources describe <资源名称> -a <应用名称>
   ```

## 最佳实践

1. **预演模式**: 在执行实际任务前，先使用预演模式：

   ```bash
   task -n
   ```

2. **分步执行**: 对于复杂部署，建议分步执行任务：

   ```bash
   task create-app
   task mysql-cluster
   task postgresql-cluster-17
   # 验证每个步骤成功后再继续
   ```

3. **版本控制**: 将 Taskfile.yml 和 values.yml 文件纳入版本控制，便于追溯和回滚。

4. **环境分离**: 为不同环境（开发、测试、生产）创建不同的 Taskfile 配置。

## 注意事项

1. **资源成本**: 创建的云资源会产生费用，请确认规格和数量。

2. **数据安全**:

   - 数据库密码等敏感信息应妥善保管

3. **依赖关系**:
   - Grafana 依赖 PostgreSQL，确保正确的执行顺序
   - 资源创建有依赖关系时，注意任务执行顺序
