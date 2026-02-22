# oml/oma（omaider/aiderx）子项目模板规范（alpha）

更新时间：2026-02-15

Scope: 本文针对 `oml/omg` 体系中的 Aider 线（oml/oma）。术语见 `00-glossary-and-scope.md`。

备注：`oml/oma` = Aider（omaider/aiderx）。

## 目的

在 alpha 阶段先统一“目录、脚本、验收门禁”的模板规范，避免后续进入 0.1.0 时再返工。

---

## 目录规范（XDG 优先）

- bin：`~/.local/bin/aiderx`（命令名可配置）
- config：`~/.config/oml/oma/profile.json`
- data：`~/.local/share/oml/oma/`
- state：`~/.local/state/oml/oma/backups`

---

## Makefile 目标（alpha 预留）

- `make install`：用户态安装（不要求 root）
- `make uninstall`：卸载 launcher
- `make doctor`：输出环境检查（不包含敏感信息）
- `make package`：打包（alpha 可先不启用）
- `make sha`：生成 sha256（alpha 可先不启用）

---

## 适配策略（外置优先）

### Aider 线现实边界

- Aider 更偏“git/编辑循环”，MCP-first 集成通常弱于 Qwen/Gemini。

### 推荐策略

- 通过 `oml-tools` 完成检索/文档/代码搜索等外置能力。
- Aider 只承担“改代码”环节。
- 由编排层（未来的 OMO 级外置编排）把流程串起来。

---

## alpha 验收门禁（最小）

1) `aiderx --version` 可运行（或等价启动成功）。
2) 外置工具链：至少能执行 `oml.healthcheck` 并输出脱敏结果。
3) 不产生明文密钥落盘。
