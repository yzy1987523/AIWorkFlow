# AI编程开发工作流 - 文件结构说明

## 目录结构

```
workflow/
├── contract.json              # 契约文件（架构Agent维护）
├── tasks.json                 # 任务索引（主Agent维护）
├── dependency_matrix.json     # 依赖矩阵（架构Agent维护）
├── global_config.json         # 全局配置（主Agent维护）
├── business_rules.yaml        # 业务规则（产品Agent维护）
├── project_style_guide.md     # 项目风格指南（主Agent动态维护）
│
├── roles/                     # 角色定义文档
│   ├── product_agent.md       # 产品Agent角色定义
│   ├── architect_agent.md     # 架构Agent角色定义
│   ├── main_agent.md          # 主Agent角色定义
│   └── dev_agent.md           # 程序Agent角色定义
│
├── rules/                     # 规则文档
│   ├── rule_triggers.yaml     # 规则触发器配置
│   ├── contract_negotiation.md # 契约协商规则
│   ├── stub_evolution.md      # 存根演进规则
│   └── ui_validation.md       # UI校验规则
│
├── templates/                 # 模板文件
│   ├── task_template.md       # 任务详情模板
│   └── log_template.md        # 任务总结模板
│
├── skills/                    # 技能注册表
│   └── skill_registry.yaml    # 技能定义
│
├── tasks/                     # 任务详情文件
│   └── task_001.md            # 示例任务
│
├── logs/                      # 任务总结日志
│   └── (任务完成后生成)
│
├── stubs/                     # 接口存根文件
│   └── auth_service_stub.py   # 示例存根
│
└── sandbox/                   # 沙盒数据目录
    └── (运行时生成)
```

## 核心文件说明

### 1. contract.json
契约文件，定义模块间的接口协议：
- 模块定义和接口方法
- 输入输出结构
- 性能约束
- 错误码定义
- 全局配置

**维护者**: 架构Agent
**更新时机**: 契约协商批准后

### 2. tasks.json
任务索引，管理所有任务的状态：
- 任务基本信息
- 任务状态（BLOCKED/READY/RUNNING/DONE等）
- 依赖关系图
- 统计信息

**维护者**: 主Agent
**更新时机**: 每次状态变更

### 3. dependency_matrix.json
依赖矩阵，记录模块间的依赖关系：
- 环境变量依赖
- 共享模块依赖
- 数据依赖
- 置信度评估

**维护者**: 架构Agent
**更新时机**: 架构设计阶段、发现新依赖时

### 4. business_rules.yaml
业务规则定义：
- 认证规则
- 用户规则
- 订单规则
- 权限规则
- 限流规则

**维护者**: 产品Agent
**更新时机**: 需求变更时

### 5. project_style_guide.md
项目风格指南：
- 编码规范
- 架构决策记录
- 测试规范
- 安全规范

**维护者**: 主Agent
**更新时机**: 发现新模式时动态追加

## 工作流程

```
1. 产品Agent
   ├── 读取需求
   ├── 反向提问
   ├── 输出 requirements.md
   └── 维护 business_rules.yaml
           │
           ↓
2. 架构Agent
   ├── 读取需求
   ├── 设计契约
   ├── 输出 contract.json
   ├── 分析依赖
   ├── 输出 dependency_matrix.json
   ├── 拆分任务
   └── 生成存根 stubs/*.py
           │
           ↓
3. 主Agent
   ├── 初始化 tasks.json
   ├── 调度任务
   ├── 注入上下文
   ├── 监控状态
   └── 压缩知识
           │
           ↓
4. 程序Agent
   ├── 读取任务 tasks/task_*.md
   ├── 测试设计
   ├── 填充存根
   ├── 运行测试
   ├── RCA分析（失败时）
   └── 输出总结 logs/log_*.md
           │
           ↓
5. 验收
   ├── 契约验证
   ├── DoD检查
   └── 端到端测试
```

## 状态机

```
BLOCKED (锁定)
    │
    │ 依赖完成
    ↓
READY (就绪)
    │
    │ 分配Agent
    ↓
RUNNING (运行中)
    │
    ├──────────────────────┐
    │                      │
    ↓                      ↓
DONE (完成)          SUSPENDING (挂起)
                          │
                          │ 超时
                          ↓
                    ESCALATED (升级)
                          │
                          │ 处理完成
                          ↓
                    READY/FAILED
```

## 关键机制

### 契约协商
1. 程序Agent发起 SPEC_CHANGE_REQUEST
2. 架构Agent评估影响力评分
3. 评分 < 5: 自动批准
4. 评分 5-15: 架构师审核
5. 评分 >= 15: 人工审批

### 存根演进
1. 架构师生成存根（Mock数据）
2. 程序Agent填充真实逻辑
3. 测试通过后替换存根
4. 通知下游任务

### 知识压缩
1. 提取任务日志关键信息
2. 生成免疫规则
3. 注入规则触发索引
4. 后续任务自动触发

## 使用示例

### 创建新任务
```bash
# 1. 架构Agent创建任务
cp templates/task_template.md tasks/task_002.md

# 2. 编辑任务详情
# 填充任务描述、DoD、注意事项等

# 3. 更新任务索引
# tasks.json 中添加新任务条目
```

### 执行任务
```bash
# 1. 主Agent分配任务
# 更新 tasks.json 中任务状态为 RUNNING

# 2. 程序Agent执行
# - 读取 tasks/task_002.md
# - 读取存根 stubs/xxx_stub.py
# - 填充实现
# - 运行测试

# 3. 完成任务
# - 更新任务状态为 DONE
# - 生成 logs/log_task_002.md
```

## 配置说明

### global_config.json 关键配置

```json
{
  "agents": {
    "main_agent": {
      "heartbeat_interval_seconds": 300,
      "suspending_timeout_minutes": 30,
      "max_concurrent_tasks": 3
    }
  },
  "sandbox": {
    "enabled": true,
    "isolation_mode": "row_level"
  },
  "thresholds": {
    "contract_change_max_affected_tasks": 2,
    "contract_change_max_impact_score": 15
  }
}
```

## 扩展指南

### 添加新模块
1. 在 contract.json 中定义模块接口
2. 在 dependency_matrix.json 中添加依赖
3. 生成对应的存根文件
4. 创建任务文件

### 添加新技能
1. 在 skills/skill_registry.yaml 中定义技能
2. 实现技能的输入输出规范
3. 更新技能索引

### 添加新规则
1. 在 rules/rule_triggers.yaml 中定义规则
2. 配置触发条件和注入消息
3. 更新触发索引

---

*本工作流系统基于6轮迭代优化，遵循奥卡姆剃刀原则设计。*
