# OML/OCT 命名与范围规范（本轮统一）

更新时间：2026-02-15

Scope: 本文针对 `oml/oct` 命名与作用域。术语见 `00-glossary-and-scope.md`。

## 1) 总命名规则

- 主项目：`OML` = **Oh-My-LiteCode**
- OpenCode Termux 兼容/构建线：`OCT` = **OpenCode(-on)-Termux**

> 约定：文档中优先使用 `OCT`，避免写长名造成混淆。

## 2) 子项目缩写规则

除 OML/OCT 外，子项目统一使用 **3 字母缩写**（目录、文档、脚本一致）。

建议映射（可后续微调）：

- `OMG` → omgemini
- `OMF` → omforge
- `OMA` → omaider
- `OMQ` → oh-my-qwencode（如需要保留）

## 3) OCT 的边界（严格）

OCT 只聚焦：

1. OpenCode 在 Termux 无 proot 的兼容性
   - ELF interpreter / PIE / 动态链接问题
   - TUI 二次启动黑屏等运行态问题
2. bun-termux-loader 路线（及其可替代路径）
3. 上游 issue 证据链与同步

OCT 不包含：

- OMQ/qwenx/geminix 的实现细节
- OML 其他子项目的功能实现代码

## 4) 本 session 文案说明

本 session 中提及 `termux`、`opencode`、全称描述时，若落入 OCT 文档，统一替换为 `OCT` 语境表达。
