# omaider 首轮实现与兼容性结论（alpha）

更新时间：2026-02-16

Scope: 本文针对 `oml/omg` 的 Aider 线（oml/oma）首轮落地。术语见 `00-glossary-and-scope.md`。

## 本轮落地

已新增：

- `scripts/omaider-configure-tools.sh`
  - 作用：生成/更新 `~/.config/oml/oma/profile.json`
  - 写入外置工具契约：`discoveryCommand` / `callCommand`

- `scripts/omaider-bootstrap.sh`
  - 作用：探测本机 Python 兼容性并尝试安装 aider-chat（仅在支持版本时）
  - 当前行为：当 Python >= 3.13 时返回结构化失败提示，不做破坏性安装

---

## 实测结论（本机）

1. 本机已存在 `aiderx` 启动器（`~/.local/bin/aiderx`）。
2. 本机没有可执行的 `aider` 二进制（`command not found`）。
3. `aider-chat` 当前版本要求 Python `<3.13`，本机 Python 为 `3.14`，因此无法直接安装。

这说明：

- omaider 线在当前环境可先推进“外置编排与契约层”，
- 但真实 aider runtime 需要单独提供 Python 3.12/3.11 userland 运行时。

---

## 下一步（不改变 alpha 状态）

1. 在调试机恢复可连后，探测其 Python 版本与 aider 可安装性。
2. 若调试机存在 Python 3.12/3.11，优先在调试机建立 omaider 运行闭环。
3. 将该兼容性约束写入 omaider 的 0.1.0 前门禁。

---

## 网络连通补充（2026-02-16 20:33）

本轮从执行端对调试机连通性复测结果：

- `172.18.0.1:8022` -> connection refused
- `192.168.1.164:8022` -> no route to host

因此本轮未能继续远端 omaider 探测，已记录日志：

`termux-lab/logs/ssh-probe-20260216-2033.txt`

后续策略：

1. 连接恢复后优先走 `172.18.0.1`，失败再试 `192.168.1.164`。
2. 连通后立即执行 omaider 探测命令组（python/aider/aiderx/profile）。
