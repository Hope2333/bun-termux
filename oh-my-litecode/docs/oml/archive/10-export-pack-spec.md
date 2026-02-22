# OML Export Pack 规范（可复现/可迁移）

更新时间：2026-02-15

Scope: 本文针对 `oml/omg` 的 export pack 规范（跨设备复现）。术语见 `00-glossary-and-scope.md`。

## 目标

提供一个“可复制到其他设备”的最小包：

- 可定义命令名（并用正则约束）
- 支持 env 双栈：`QWEN_API_KEY/QWEN_BASE_URL` 与 `OPENAI_API_KEY/OPENAI_BASE_URL`
- 支持两种安装目标：
  - `fakehome`：隔离到 `~/.local/home/<name>`，不污染 `~/.qwen`
  - `userhome`：直接使用默认 `~/.qwen`（满足特殊用户需求）

> 本规范不包含任何敏感信息。

---

## pack 结构

```
oml-export-<profile>/
  bin/
    wrapper.sh         # 主 wrapper（安装时会复制/改名为 commandName）
  conf/
    profile.json       # profile 配置（无敏感信息）
    model_aliases.json # 模型别名映射（可扩展）
  docs/
    README.md
  install.sh
```

---

## profile.json 字段

| 字段 | 说明 |
|---|---|
| profileName | profile 名称，用于多套共存 |
| commandName | 要安装的命令名（例如 `qwenx-dev`） |
| commandRegex | commandName 的正则约束（部署时显示提示） |
| installTarget | `fakehome` 或 `userhome` |
| homeName | fakehome 时的目录名（例如 `qwenx` / `alice`） |
| envMode | `qwen` / `openai` / `dual` |

---

## env 兼容策略

### 手机上的默认建议

继续以 `QWEN_API_KEY/QWEN_BASE_URL` 为主（与你现有 qwenx 生态一致）。

### 导出包要求

导出包必须支持两者皆可用：

- 只设置 `OPENAI_*` 也能工作（wrapper 自动映射到 `QWEN_*`）
- 只设置 `QWEN_*` 也能工作（wrapper 自动映射到 `OPENAI_*`）

---

## 命令名正则（示例）

默认：

```
^[a-z][a-z0-9_-]{1,31}$
```

解释：

- 必须小写字母开头
- 允许小写/数字/`_`/`-`
- 总长度 2~32

如果某设备需要更松/更严策略，重新生成 export pack 并显式给出 `--command-regex` 与 `--command-name`。

---

## 模型别名策略（阶段性）

### v0（当前）

仅做“安全的形态归一化 + 少量固定别名”，避免误映射。

支持：

- 大小写不敏感
- 去除 `-` / `_` / `.` 的归一化 key
- 支持 `openai::xxx` 这种前缀保留
- 支持 `org/name` 与 `name` 共存（不做跨 org 的强制映射）

### v1（后续）

按 provider 维度建立别名集，并由 `models sync` 自动生成/更新（失败则回落本地静态 alias）。
