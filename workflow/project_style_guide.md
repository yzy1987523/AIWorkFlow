# 项目风格指南 (Project Style Guide)

> 本文档由主Agent动态维护，所有子Agent必须遵循。

## 版本信息

- **版本**: 1.0.0
- **创建时间**: 2026-02-15
- **最后更新**: 2026-02-15
- **维护者**: Main Agent

---

## 1. 编码规范

### 1.1 命名约定

#### Python命名规范
```python
# 变量和函数: snake_case
user_name = "test"
def get_user_by_id(user_id: str) -> User:
    pass

# 类名: PascalCase
class UserService:
    pass

# 常量: UPPER_SNAKE_CASE
MAX_RETRY_COUNT = 3
DEFAULT_TIMEOUT_SECONDS = 30
```

### 1.2 类型提示

**强制要求**: 所有公开函数必须有完整的类型提示。

```python
# ✅ 正确
from typing import Dict, List, Optional, Any

async def get_user(
    user_id: str,
    include_deleted: bool = False
) -> Optional[Dict[str, Any]]:
    """获取用户信息"""
    pass

# ❌ 错误 - 缺少类型提示
def get_user(user_id, include_deleted=False):
    pass
```

---

## 2. 架构决策记录 (ADR)

### ADR-001: 选择 FastAPI 作为 Web 框架

**日期**: 2026-02-15

**背景**
需要一个高性能、支持异步的 Python Web 框架，支持自动 API 文档生成。

**决策**
使用 FastAPI 框架。

**理由**
1. 原生支持 async/await，适合高并发场景
2. 自动生成 OpenAPI 文档
3. 内置数据验证（Pydantic）
4. 类型提示友好

---

## 3. 测试规范

### 3.1 测试文件组织

```
tests/
├── unit/                      # 单元测试
├── integration/               # 集成测试
├── contract/                  # 契约测试
└── conftest.py               # pytest 配置
```

### 3.2 测试结构 (AAA 模式)

```python
def test_login_valid_credentials_returns_token():
    # Arrange (准备)
    user_service = UserService()
    username = "test_user"
    password = "valid_password"
    
    # Act (执行)
    result = user_service.login(username, password)
    
    # Assert (断言)
    assert result.is_success
    assert result.value["token"] is not None
```

---

## 4. 错误处理

**使用 Result 模式，禁止裸抛异常**

```python
from dataclasses import dataclass
from typing import Generic, TypeVar, Union

T = TypeVar('T')

@dataclass
class Success(Generic[T]):
    value: T
    
    @property
    def is_success(self) -> bool:
        return True

@dataclass
class Failure:
    error_code: str
    message: str

Result = Union[Success[T], Failure]

# ✅ 正确 - 使用 Result 模式
async def login(username: str, password: str) -> Result[Dict[str, Any]]:
    if not validate_credentials(username, password):
        return Failure(
            error_code="INVALID_CREDENTIALS",
            message="用户名或密码错误"
        )
    return Success({"user": user, "token": generate_token(user)})
```

---

## 5. 安全规范

### 5.1 敏感数据处理

```python
import os

# ✅ 正确 - 从环境变量读取
DATABASE_URL = os.environ.get("DATABASE_URL")
JWT_SECRET = os.environ.get("JWT_SECRET")

# ❌ 错误 - 硬编码敏感信息
API_KEY = "sk-xxxxx"  # 绝对禁止
```

---

*此文档会随着项目发展持续更新，子Agent完成任务后如有新的模式发现，应自动追加到此文档。*
