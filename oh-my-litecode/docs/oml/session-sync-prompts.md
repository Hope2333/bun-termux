# Oh-My-Litecode Session 同步提示词

> 用于在不同 session 间同步上下文，确保无缝继续工作。

---

## 🎯 快速同步提示词（推荐）

### 完整上下文同步

```
请阅读 ~/develop/oh-my-litecode/README.md 和 ~/develop/oh-my-litecode/CHANGELOG.md，
了解 Oh-My-Litecode (OML) 项目当前状态，然后继续工作。

当前任务：
- [填写具体任务]

已完成的工作：
- [填写已完成内容]

阻塞点：
- [填写遇到的阻塞]
```

### 简短同步

```
继续 OML 项目工作。项目位于 ~/develop/oh-my-litecode。
当前状态：v0.1.0-alpha，已完成 OCT 和 Bun 的 Termux 打包。
现在需要：[具体任务]
```

---

## 📋 分项目同步提示词

### OCT (OpenCode on Termux)

```
继续 OpenCode for Termux (OCT) 开发。

项目路径：~/develop/opencode-termux
仓库地址：https://github.com/Hope2333/opencode-termux

关键文件：
- packaging/pacman/PKGBUILD
- scripts/launcher.sh
- scripts/build.sh

当前版本：1.1.65-8

待解决问题：
- [具体问题]

请先阅读项目 README 和相关文档，然后继续。
```

### OML (Oh-My-Litecode 主项目)

```
继续 Oh-My-Litecode (OML) 总管项目开发。

项目路径：~/develop/oh-my-litecode
仓库地址：https://github.com/Hope2333/oh-my-litecode

子项目状态：
- OCT (opencode-termux): 已完成 ✅
- Bun (bun-termux): 已完成 ✅
- OMG (omgemini): 待开发
- OMA (omaider): 待开发

当前任务：
- [具体任务]

请阅读 CHANGELOG.md 了解最新进展。
```

---

## 🔧 调试机同步提示词

### Termux 调试环境

```
Termux 调试环境信息：

SSH 连接：
- 主机：u0_a450@172.18.0.1 -p 8022
- 备用：u0_a450@192.168.1.164 -p 8022
- 密码：0

环境：
- 包管理器：pacman
- 前缀：/data/data/com.termux/files/usr
- Shell：zsh

已安装：
- opencode-termux 1.1.65-8
- bun-termux 1.2.20-1
- glibc-runner

关键路径：
- 项目目录：~/termux.opencode.all
- 日志目录：~/.local/share/opencode/log
- 缓存目录：~/.cache/opencode

当前问题：
- [具体问题]

注意事项：
- 使用 command ls 而非 ls（避免 exa alias）
- 使用 python3 pexpect 进行 SSH 自动化
```

---

## 📚 文档引用模板

### 引用已有文档

```
请阅读以下文档了解背景：

1. 架构文档：
   - ~/develop/oh-my-litecode/docs/opencode/architecture.md
   - ~/develop/oh-my-litecode/docs/bun/architecture.md

2. 安装指南：
   - ~/develop/oh-my-litecode/docs/opencode/installation.md

3. 术语表：
   - ~/develop/oh-my-litecode/docs/oml/glossary.md

4. 历史记录：
   - ~/develop/oh-my-litecode/CHANGELOG.md
   - ~/termux-lab/reports/oml-docs/ (详细历史文档)
```

### 引用历史 session

```
请查看历史 session 了解前情：

Session 搜索关键词：
- "OCT" 或 "opencode-termux" - OpenCode Termux 相关
- "黑屏" 或 "setRawMode" - TTY 问题调试
- "EACCES" 或 "plugin" - 插件安装问题
- "pacman" 或 "makepkg" - 打包相关

关键 session ID（示例）：
- [如果知道具体 session_id]

使用方法：
- session_search(query="OCT")
- session_read(session_id="xxx")
```

---

## 🚀 新任务启动模板

### 创建新功能

```
开始为 OML 创建新功能。

功能名称：[功能名]
目标：[具体目标]
影响范围：[哪些子项目]

请：
1. 阅读 ~/develop/oh-my-litecode/README.md 了解项目结构
2. 阅读 ~/develop/oh-my-litecode/docs/oml/glossary.md 了解术语
3. 设计实现方案
4. 更新 CHANGELOG.md
```

### Bug 修复

```
修复 OML/OCT 的 Bug。

问题描述：
- [具体问题描述]

复现步骤：
- [复现方法]

环境：
- Termux/Android
- pacman 包管理器

相关文件：
- [可能相关的文件路径]

请：
1. 定位问题根因
2. 实现修复
3. 更新文档
4. 验证修复
```

---

## 💡 最佳实践

### DO ✅

- 始终先读取 README/CHANGELOG 了解当前状态
- 使用具体的文件路径（绝对路径）
- 说明具体任务和期望结果
- 引用相关的 issue/PR 编号

### DON'T ❌

- 不要假设项目状态
- 不要使用模糊描述
- 不要跳过文档阅读
- 不要忽略已完成的工作

---

## 📝 命名规范提醒

| 缩写 | 全名 | 用途 |
|------|------|------|
| OML | Oh-My-Litecode | 主项目 |
| OCT | OpenCode(-on)-Termux | OpenCode Termux 版 |
| OMG | omgemini | Gemini CLI 集成 |
| OMF | omforge | ForgeCode 集成 |
| OMA | omaider | Aider 集成 |

---

## 🔗 仓库地址

- OML 主项目：https://github.com/Hope2333/oh-my-litecode
- OCT 子项目：https://github.com/Hope2333/opencode-termux
