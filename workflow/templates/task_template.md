# 任务详情模板

> 此模板用于定义单个任务的详细信息，由架构Agent创建，程序Agent执行。

---

## 任务基本信息

| 字段 | 值 |
|-----|-----|
| **任务ID** | task-XXX |
| **标题** | [任务标题] |
| **模块** | [所属模块] |
| **优先级** | HIGH / MEDIUM / LOW |
| **权重** | CORE / SERVICE / UTIL |
| **状态** | BLOCKED / READY / RUNNING / DONE / FAILED |
| **创建时间** | YYYY-MM-DD HH:MM:SS |
| **依赖任务** | [task-XXX, task-YYY] |

---

## 1. 任务描述

### 1.1 功能概述
[简要描述任务要实现的功能]

### 1.2 详细需求
1. [需求点1]
2. [需求点2]
3. [需求点3]

---

## 2. 契约定义

### 2.1 接口方法
```json
{
  "method_name": {
    "input": {
      "param1": { "type": "string", "required": true }
    },
    "output": {
      "result": { "type": "boolean" }
    },
    "constraints": [
      "response_time < 500ms"
    ]
  }
}
```

### 2.2 错误码
| 错误码 | 描述 |
|-------|------|
| ERROR_001 | [错误描述] |

---

## 3. 完成标准 (DoD)

- [ ] 接口测试通过
- [ ] 逻辑测试覆盖
- [ ] 契约验证通过
- [ ] 代码审查完成
- [ ] 文档更新完成

---

## 4. 注意事项

### 4.1 必须遵循
- [注意事项1]
- [注意事项2]

### 4.2 禁止事项
- ❌ [禁止事项1]
- ❌ [禁止事项2]

---

## 5. 上下文注入

### 5.1 需要读取的文件
- `contract.json` - 契约定义
- `business_rules.yaml` - 业务规则
- `project_style_guide.md` - 编码规范

### 5.2 依赖任务产出
| 依赖任务 | 产出物 | 使用方式 |
|---------|-------|---------|
| task-XXX | [产出物] | [如何使用] |

---

## 6. 测试要点

### 6.1 接口测试
```python
def test_method_name_success():
    """测试正常调用"""
    pass

def test_method_name_error():
    """测试异常情况"""
    pass
```

### 6.2 边界用例
| 场景 | 输入 | 预期输出 |
|-----|------|---------|
| [场景1] | [输入] | [输出] |

---

## 7. 执行记录

| 时间 | 操作 | 结果 |
|-----|------|------|
| YYYY-MM-DD HH:MM | 开始执行 | - |
| YYYY-MM-DD HH:MM | 测试通过 | ✅ |

---

*任务完成后，程序Agent需生成总结日志到 `logs/log_task_XXX.md`*
