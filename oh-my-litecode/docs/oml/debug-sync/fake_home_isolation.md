# Termux 中的假 HOME 目录隔离技术详解

## 概述
在 Termux 环境中，为了实现不同 CLI 工具实例之间的完全隔离，我们采用了假 HOME 目录技术。这种技术通过重定向环境变量来实现配置、认证和会话数据的完全分离。

## 技术原理

### 1. 环境变量重定向
- **HOME**: 重定向到隔离目录
- **配置路径**: 工具通常在 $HOME/.<tool> 存储配置
- **认证缓存**: OAuth 令牌等存储在隔离目录中

### 2. 隔离目录结构
```
~/.local/home/
├── qwenx/           # qwenx 分身的假 HOME
│   └── .qwen/       # Qwen Code 配置
└── geminix/         # geminix 分身的假 HOME
    └── .gemini/     # Gemini CLI 配置
```

## 实现细节

### 1. qwenx 实现
```bash
# Store the real home directory
export _REALHOME="$HOME"
export REALHOME="$HOME"
# Set the fake home directory for complete isolation
export _FAKEHOME="/data/data/com.termux/files/home/.local/home/qwenx"
export HOME="$_FAKEHOME"

# Set the API key as an environment variable
export QWEN_API_KEY="sk-...[敏感信息已隐藏]..."
```

### 2. geminix 实现
```bash
# Store the real home directory
export _REALHOME="$HOME"
export REALHOME="$HOME"
# Set the fake home directory for complete isolation
export _FAKEHOME="/data/data/com.termux/files/home/.local/home/geminix"
export HOME="$_FAKEHOME"

# Set the environment variables for the custom API
export GOOGLE_GEMINI_BASE_URL="[敏感信息已隐藏]"
export GEMINI_API_KEY="sk-...[敏感信息已隐藏]..."
```

## 优势

### 1. 完全配置隔离
- 每个分身有独立的配置文件
- 不会相互影响或覆盖设置
- 可以为每个分身配置不同的模型和参数

### 2. 认证隔离
- 每个分身使用独立的认证信息
- 避免认证信息交叉污染
- 支持不同的 API 提供商

### 3. 会话隔离
- 每个分身有独立的会话历史
- 不会混淆不同分身的对话历史
- 保持各分身的上下文独立

### 4. 资源效率
- 避免重复安装多个 CLI 工具
- 共享同一个工具的多个实例
- 节省存储空间和内存

## 安全考虑

### 1. API 密钥管理
- 通过环境变量传递，不存储在配置文件中
- 每个分身使用独立的密钥
- 避免密钥泄露风险

### 2. 配置文件权限
- 配置文件使用适当的权限设置
- 避免敏感信息被其他应用访问
- 遵循最小权限原则

## 与 Oh-My-OpenCode (OMO) 的比较

| 特性 | OMO | OML (本实现) |
|------|-----|--------------|
| 代理数量 | 多个专业代理 | 2个主要分身 |
| 隔离级别 | 高 | 完全隔离 |
| 资源占用 | 较高 | 轻量级 |
| Termux 优化 | 一般 | 高度优化 |
| 配置复杂度 | 复杂 | 简洁 |
| MCP 集成 | 完整 | 核心功能 |

## 适用场景

### 1. 多账户管理
- 使用不同 API 提供商的账户
- 为不同项目使用不同配置

### 2. 实验性配置
- 测试新模型而不影响主配置
- 尝试不同设置组合

### 3. 安全隔离
- 避免敏感配置泄露
- 隔离不同安全级别的任务

## 局限性

### 1. 管理复杂度
- 需要维护多个配置文件
- 需要分别更新各分身

### 2. 存储使用
- 每个分身需要独立存储空间
- 可能会增加总体存储需求

## 结论

假 HOME 目录技术为在 Termux 环境中实现 CLI 工具的完全隔离提供了一个有效解决方案。通过环境变量重定向，我们实现了配置、认证和会话的完全分离，同时保持了资源效率。这种技术特别适合在资源受限的移动环境中使用，为用户提供了一个安全、高效的多实例管理方案。