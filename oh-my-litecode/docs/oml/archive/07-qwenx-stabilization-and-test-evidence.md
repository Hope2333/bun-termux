# qwenx 稳定化修复与测试证据（Termux）

更新时间：2026-02-15

Scope: 本文针对 `oml/omg` 体系中的 qwenx 稳定化记录。术语见 `00-glossary-and-scope.md`。

## 目标

修复 qwenx 与 qwen 的行为分叉，消除“qwen 可用但 qwenx 401”的假故障，并给出工具调用级证据。

---

## 问题复盘

### 现象

- `qwen -p 'say ONLY OK'` 可成功。
- `qwenx -p 'say ONLY OK'` 在同环境下报 401。

### 根因

qwenx 脚本尾部存在强制分支：

```bash
exec qwen --auth-type "openai" "$@"
```

这导致 qwenx 在某些场景下强行走 OpenAI auth 路径，与 qwen 默认路径不一致，造成认证行为分叉。

---

## 修复动作（已落地）

1. 保留 qwenx 的 fake HOME 隔离、ctx7 管理逻辑。
2. 移除强制 `--auth-type "openai"` 分支影响：
   - 当前尾部两分支均 `exec qwen "$@"`（功能等价，不再强制 auth-type）。
3. 清理脚本异常尾字符（历史错误写入的孤立 `n`）。

---

## 关键验证证据（实测）

### A. 基础调用恢复

在 Termux 上执行：

```bash
export QWEN_API_KEY='***REDACTED***'
export QWEN_BASE_URL='https://api.example.com/v1'
qwenx -p 'say ONLY OK' --output-format text
```

结果：`OK`。

### B. MCP 列表连通

```bash
qwenx mcp list
```

结果：

- context7: Connected
- grep-app: Connected
- websearch: Connected

### C. 工具调用级验证（Context7）

```bash
qwenx -p 'Call tool mcp__context7__resolve-library-id with {"libraryName":"react","query":"react hooks"} and then output ONLY CTX7_OK' --output-format text
```

结果：`CTX7_OK`。

### D. 工具调用级验证（Websearch）

```bash
qwenx -p 'Call tool mcp__websearch__web_search_exa with {"query":"OpenCode docs","numResults":3,"type":"fast","livecrawl":"fallback","contextMaxCharacters":2000} then output ONLY WS_OK' --output-format text
```

结果：`WS_OK`。

### E. 工具调用级验证（grep-app）

注意：grep-app 在某些参数组合下可能触发超大响应（>20MB）导致客户端 JSON 解析上限报错。
推荐用更收敛的 query / 参数组合。

示例：

```bash
qwenx -p 'Call tool mcp__grep-app__grep_count with {"query":"useState(","repo":"facebook/react","path":"","language":[],"useRegexp":false,"matchCase":false,"matchWholeWords":false} then output ONLY GREP_OK' --output-format text
```

结果：`GREP_OK`。

---

## 结论

qwenx 的 401 主因已从“脚本强制 auth-type 导致行为分叉”收敛并解除。当前已达到：

- 基础对话可用
- MCP 三件套连通
- 至少 context7/websearch 工具调用级通过

后续可进入 OMO 非 MCP 能力复刻阶段。
