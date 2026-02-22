# Oh-My-LiteCode (OML) 使用指南

## 概述
本指南详细介绍如何使用 Oh-My-LiteCode (OML) 提供的各种功能，包括两个主要分身 (qwenx 和 geminix) 以及主入口命令 (oml)。

## 安装后设置

### 1. 验证安装
```bash
# 检查所有组件是否正确安装
oml status

# 检查可用的分身
oml list
```

### 2. 配置 API 密钥
在使用分身前，您需要配置 API 密钥：

```bash
# 编辑 qwenx 配置文件
nano ~/.local/home/qwenx/.qwen/settings.json
# 将其中的 API 密钥替换为您的实际密钥

# 编辑 geminix 配置文件
nano ~/.local/home/geminix/.gemini/settings.json
# 将其中的 API 密钥替换为您的实际密钥
```

## 主要功能

### 1. qwenx 分身
qwenx 是 Qwen Code 的隔离分身，具有以下特点：

#### 基本使用
```bash
# 简单查询
qwenx "你好"

# 使用特定模型
qwenx --model "gpt-5.3-codex" "写一个 Python 函数"

# 交互模式
qwenx
```

#### 高级功能
```bash
# 使用 MCP 服务器 (如 Context7)
qwenx "查找 React useState 的官方文档"

# 传递其他参数
qwenx --temperature 0.7 --max-tokens 2000 "生成代码"
```

### 2. geminix 分身
geminix 是 Gemini CLI 的隔离分身，具有以下特点：

#### 基本使用
```bash
# 简单查询
geminix "你好"

# 使用特定模型
geminix --model "gpt-4o-mini" "解释这段代码"

# 交互模式
geminix
```

#### 高级功能
```bash
# 使用 MCP 服务器
geminix --model "gpt-5.3-codex" "搜索 GitHub 上的 React hooks 示例"

# 传递其他参数
geminix --temperature 0.5 "生成文档"
```

### 3. oml 主入口命令
oml 命令提供统一的管理接口：

```bash
# 查看帮助
oml help

# 查看状态
oml status

# 查看可用分身
oml list

# 安装/更新组件
oml install
```

## 配置管理

### 1. 隔离配置文件
每个分身都有独立的配置文件：

- **qwenx**: `~/.local/home/qwenx/.qwen/settings.json`
- **geminix**: `~/.local/home/geminix/.gemini/settings.json`

### 2. 模型提供商配置
在配置文件中，您可以配置不同的模型提供商：

```json
{
  "modelProviders": {
    "openai": [
      {
        "id": "gpt-5.3-codex",
        "name": "GPT-5.3 Codex (via custom API)",
        "envKey": "QWEN_API_KEY",
        "baseUrl": "[敏感信息已隐藏]"
      }
    ]
  }
}
```

### 3. MCP 服务器配置
MCP 服务器在配置文件中定义：

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": [
        "-y",
        "@upstash/context7-mcp"
      ],
      "env": {
        "CONTEXT7_API_KEY": "YOUR_CONTEXT7_API_KEY_HERE"
      }
    }
  }
}
```

## 高级用法

### 1. 会话管理
```bash
# 在分身中开始新会话
qwenx "让我们开始一个新项目"

# 恢复之前的会话（如果支持）
qwenx --resume latest
```

### 2. 参数传递
所有原始 CLI 工具的参数都可以传递给分身：

```bash
# 传递多个参数
qwenx --model "gpt-5.3-codex" --temperature 0.7 --max-tokens 1500 "写一个算法"

# 使用 MCP 相关参数
qwenx --mcp list  # 列出 MCP 服务器
```

### 3. 环境变量
分身使用环境变量管理敏感信息：

```bash
# 临时设置 API 密钥
QWEN_API_KEY="your-key" qwenx "查询"

# 在 shell 配置中永久设置
echo 'export QWEN_API_KEY="your-key"' >> ~/.bashrc
```

## 故障排除

### 1. 常见问题
- **API 密钥错误**: 检查配置文件中的密钥是否正确
- **MCP 服务器未找到**: 确保已安装相应的 MCP 包
- **参数冲突**: 某些参数可能与其他参数冲突，尝试单独使用

### 2. 调试方法
```bash
# 检查当前环境变量
env | grep -i qwen

# 检查配置文件
cat ~/.local/home/qwenx/.qwen/settings.json

# 检查分身脚本
cat $(which qwenx)
```

### 3. 重置配置
如果需要重置某个分身的配置：

```bash
# 备份当前配置
cp -r ~/.local/home/qwenx ~/.local/home/qwenx_backup

# 删除配置目录（将重新创建）
rm -rf ~/.local/home/qwenx

# 重新运行安装脚本
oml install
```

## 最佳实践

### 1. 安全性
- 不要在配置文件中明文存储 API 密钥
- 使用环境变量管理敏感信息
- 定期轮换 API 密钥

### 2. 性能
- 仅启用需要的 MCP 服务器
- 合理设置模型参数以平衡性能和质量
- 定期清理旧的会话历史

### 3. 维护
- 定期检查更新
- 备份重要配置
- 监控 API 使用量

## 与 Oh-My-OpenCode (OMO) 对比

| 功能 | OMO | OML | 说明 |
|------|-----|-----|------|
| 代理数量 | 多个专业代理 | 2个主要分身 | OML 更轻量 |
| 配置隔离 | 高 | 完全 | 两者都提供良好隔离 |
| 资源占用 | 高 | 低 | OML 为资源受限环境优化 |
| 扩展性 | 高 | 中等 | OML 专注于核心功能 |
| 安装复杂度 | 中等 | 低 | OML 更易安装 |

## 扩展功能

### 1. 添加新模型
在配置文件中添加新的模型提供商：

```json
{
  "modelProviders": {
    "openai": [
      {
        "id": "new-model-id",
        "name": "New Model (via custom API)",
        "envKey": "QWEN_API_KEY",
        "baseUrl": "https://your-api-endpoint.com/v1"
      }
    ]
  }
}
```

### 2. 添加新 MCP 服务器
在配置文件中添加新的 MCP 服务器：

```json
{
  "mcpServers": {
    "your-custom-server": {
      "command": "npx",
      "args": [
        "-y",
        "your-mcp-package"
      ],
      "env": {
        "YOUR_API_KEY": "YOUR_API_KEY_VALUE"
      }
    }
  }
}
```

## 总结
Oh-My-LiteCode 提供了一个轻量级但功能强大的环境，用于管理多个 AI CLI 工具实例。通过假 HOME 目录技术，实现了完全的配置和认证隔离，同时保持了简单易用的接口。按照本指南，您可以充分利用 OML 的所有功能，提高在 Termux 环境中使用 AI 工具的效率。