# 外置编排层 MVP（alpha）：todo/session/snapshot/ralph-loop

更新时间：2026-02-16

Scope: 本文针对 `oml/omg` 仓库中的外置编排 MVP（不依赖修改上游客户端 UI）。术语见 `00-glossary-and-scope.md`。

## 目标

在 alpha 阶段先构建一个可被上游客户端（以 Qwen 为例）调用的“外置编排最小闭环”，包含：

- todo 写入/读取（持久化）
- session snapshot（脱敏快照）
- `ralph_loop_mvp`（播种 todo + 给出下一步行动）

---

## 工具列表（oml-tools）

- `oml.todo_write`
- `oml.todo_list`
- `oml.session_snapshot`
- `oml.ralph_loop_mvp`

它们通过 Qwen 的 `tools.discoveryCommand/tools.callCommand` 外置机制暴露给模型。

---

## 状态文件路径（持久化）

默认落到：

`$XDG_STATE_HOME/oml/orchestrator/sessions/<sessionId>/`

文件：

- `todos.json`
- `snapshot.json`

若未设置 `XDG_STATE_HOME`，默认：`~/.local/state`。

---

## 验收门禁（必须）

1) `oml.todo_write` 写入后，`oml.todo_list` 能读到同样的 todo。
2) `oml.session_snapshot` 输出不包含明文 key（只 redacted）。
3) `oml.ralph_loop_mvp` 在空 todo 时会播种一个最小 todo 列表。
4) 在 Termux 上用 `qwen --approval-mode yolo` 调用上述工具成功。

---

## 示例（Qwen 端到端）

```text
Call tool oml.ralph_loop_mvp with {"sessionId":"rl1","goal":"Bootstrap external orchestration MVP"}.
Then call tool oml.todo_list with {"sessionId":"rl1"}.
Then call tool oml.healthcheck with {"mode":"termux"}.
Finally output ONLY RALPH_MVP_OK.
```

预期：返回 `RALPH_MVP_OK`。
