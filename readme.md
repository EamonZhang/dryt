# Dryt

Don't Repeat Your Tool

## 概述

dryt 是基于 Taskfile 的 Drycc 云平台资源编排工具，通过声明式配置，实现项目云平台环境自动化构建。

工具使用 Go Task (taskfile.dev) 作为任务运行器，定义任务来自动化执行应用程序创建、基础服务资源部署和初始化等操作。

## 核心作用

一键构建企业云环境
场景：一个项目启动，需要为开发、测试、演示，各自搭建一套功能相同但独立的云环境

| 对比维度       | 传统方式痛点 ⚡️ （手动搭积木） | TOD 方案优势 🚀（配置即蓝图）              |
| -------------- | ------------------------------- | ------------------------------------------ |
| **流程自动化** | 每套环境需手工搭建，重复劳动    | 定义蓝图后环境自动创建，解放双手           |
| **环境可靠性** | 搭建过程复杂，容易出错          | 最佳实践固化为模板，消除人为失误，保障稳定 |
| **环境一致性** | 多套环境，管理困难              | 基于同一蓝图生成的环境 100%一致，流程顺畅  |
| **交付效率**   | 依赖人员熟练度                  | 快速环境交付，快速响应需求                 |

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
tod/
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
$ task -l

# 预演任务（不实际执行）
task -n

# 执行默认任务（完整流程）
task

# 执行特定任务
task <任务名称>
```

### 任务说明

#### 查看任务列表

```
$ task --list
- create-resource-base01: Create and bind database resources
- create-resource-base02: Create and bind database resources
- create-app:default: Create APP (aliases: create-app)
- grafana:default: Deploy grafana grafana01 standard-1c1g5 in apptest01 and bind it (aliases: grafana)
- grafana:resource-bind: Bind the grafana resources
- grafana:resource-create: Create a grafana grafana01 standard-1c1g5 in apptest01
- grafana:resource-init: Initialize the grafana grafana01 standard-1c1g5 in apptest01
- grafana:resource-prepare: Prepare the grafana grafana01 standard-1c1g5 in apptest01
- grafana:resource-wait-ready: Wait the grafana grafana01 standard-1c1g5 in apptest01 Ready
- mongodb:default: Deploy mongodb mongodb01 standard-2c4g20 in apptest01 and bind it (aliases: mongodb)
- mongodb:resource-bind: Bind the mongodb resources
- mongodb:resource-create: Create a mongodb mongodb01 standard-2c4g20 in apptest01
- mongodb:resource-init: Initialize the mongodb mongodb01 standard-2c4g20 in apptest01
- mongodb:resource-prepare: Prepare the mongodb mongodb01 standard-2c4g20 in apptest01
- mongodb:resource-wait-ready: Wait the mongodb mongodb01 standard-2c4g20 in apptest01 Ready
- mysql-cluster:default: Deploy mysql-cluster mysql01 standard-2c4g20 in apptest01 and bind it (aliases: mysql-cluster)
- mysql-cluster:resource-bind: Bind the mysql-cluster resources
- mysql-cluster:resource-create: Create a mysql-cluster mysql01 standard-2c4g20 in apptest01
- mysql-cluster:resource-init: Initialize the mysql-cluster mysql01 standard-2c4g20 in apptest01
- mysql-cluster:resource-prepare: Prepare the mysql-cluster mysql01 standard-2c4g20 in apptest01
- mysql-cluster:resource-wait-ready: Wait the mysql-cluster mysql01 standard-2c4g20 in apptest01 Ready
- postgresql-cluster-17:default: Deploy postgresql-cluster-17 postgresql17-01 standard-2c4g20 in apptest01 and bind it (aliases: postgresql-cluster-17)
- postgresql-cluster-17:resource-bind: Bind the postgresql-cluster-17 resources
- postgresql-cluster-17:resource-create: Create a postgresql-cluster-17 postgresql17-01 standard-2c4g20 in apptest01
- postgresql-cluster-17:resource-init: Initialize the postgresql-cluster-17 postgresql17-01 standard-2c4g20 in apptest01
- postgresql-cluster-17:resource-prepare: Prepare the postgresql-cluster-17 postgresql17-01 standard-2c4g20 in apptest01
- postgresql-cluster-17:resource-wait-ready: Wait the postgresql-cluster-17 postgresql17-01 standard-2c4g20 in apptest01 Ready
```

#### 默认任务 (default)

执行完整的应用和资源创建流程：

1. 创建应用空间
2. 创建基础资源 并输出资源列表到 describe 文件夹
3. 创建 xxxx
4. 输出完成信息

```bash
task  # 执行默认任务
```

#### 创建应用任务 (create-app)

创建应用空间：

```bash
task create-app
```

#### 单独创建特定资源

可以直接调用预定义的资源任务：

```bash
task mysql-cluster     # 创建 MySQL 集群
task mongodb          # 创建 MongoDB 数据库
task postgresql-cluster-17  # 创建 PostgreSQL 集群
task grafana          # 创建 Grafana 实例
```

#### 创建基础资源集任务

定义资源集 resource-base 包括如 MySQL 和 MongoDB 等资源

```bash
task create-resource-base # 并行创建 resource-base 中定义的所有资源
```

### 配置说明

#### 应用名称配置

默认应用名称为 `apptest01`，可以在主 Taskfile.yml 中修改：

```yaml
vars:
  APP: apptest01 # 修改此处更改应用名称
```

#### 资源配置

##### 资源特定的配置参数：

**MySQL Cluster 通用配置为例**:

- RESOURCE: "mysql-cluster" # 资源类型
- NAME: mysql01 # 资源名称
- PLAN: standard-2c4g20 # 资源规格

将 dryy 所依赖的 value.yml 放在 mysql-cluster 文件夹中

##### 资源创建后的初始化

如 创建完数据数据库后需创建 user 和 database 等工作

**PostgreSQL Cluster 17**:

- RESOURCE: postgresql-cluster-17
- NAME: postgresql17-01 # 资源名称
- PLAN: standard-2c4g20 # 资源规格
- INIT: "true" # 是否初始化数据库（创建用户和数据库）

定义 INIT: "true" , 并在 scripts/init-resources.sh 中定义具体的初始内容

##### 资源依赖

如 garafana 依赖 postgresql

**Grafana**:

- RESOURCE: grafana
- NAME: grafana01 # 资源名称
- PLAN: standard-1c1g5 # 资源规格
- DEPENDENT: postgresql17-01 # 依赖的 PostgreSQL 资源

在 scripts/prepare-resources.sh 中定义具体的依赖逻辑

## 任务工作流程详解

### 完整流程示例

1. **准备阶段**

2. **创建资源**

3. **等待资源创建并完成绑定**

4. **创建完成后的初始化工作**

### 创建新资源任务

在主 Taskfile.yml 中添加新的资源任务：

```yaml
includes:
  new-resource:
    taskfile: resource/Taskfile.yml
    vars:
      RESOURCE: "new-resource"
      NAME: newresource01
      PLAN: standard-1c1g5
```

## 故障排除

### 常见问题

1. **任务执行失败**:

   ```bash
   # 命令中查看详细错误信息
   task -v
   # 配置中开启输出详细运行流程
   silent: true
   ```

2. **资源创建超时**:

   - 检查网络连接
   - 增加等待时间（修改 wait-resources.sh 中的 TIMEOUT 参数）

3. **数据库初始化失败**:

   - 检查 psql 客户端是否安装
   - 验证数据库连接信息

## 注意事项

1. **资源成本**: 创建的云资源会产生费用，请确认规格和数量。

2. **数据安全**:

   - 数据库密码等敏感信息应妥善保管

3. **依赖关系**:
   - Grafana 依赖 PostgreSQL，确保正确的执行顺序
   - 资源创建有依赖关系时，注意任务执行顺序
