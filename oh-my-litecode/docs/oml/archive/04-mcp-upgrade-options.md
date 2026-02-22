# OML MCP 升级选项：从“能用”到“接近 OMO”

更新时间：2026-02-15

Scope: 本文针对 `oml/omg` 的 MCP 升级选项。术语见 `00-glossary-and-scope.md`。

## 当前基线

已稳定：

- `context7`（stdio）
- `grep-app`（stdio）
- `websearch`（remote Exa MCP）

这三项足以覆盖 OMO 的“查文档 / 搜代码 / 联网搜索”核心检索面。

---

## 升级方向 1：浏览器自动化（Playwright MCP）

### 能力

Playwright MCP 可以提供：

- 页面导航、点击、输入、表单填充
- 可访问性快照（代替视觉截图决策）
- 网络请求/控制台日志抓取

### 官方实现

- Repo: `microsoft/playwright-mcp`
- 推荐配置（stdio）：

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

### Termux 注意

- 运行成本高（浏览器体积、依赖、缓存）
- 在 Android/Termux 上可能需要 headless + no-sandbox 等参数调优
- 建议作为“可选能力”，默认不启用

---

## 升级方向 2：RAG（本地/远端检索库）

### 能力

- 文档 ingestion（本地目录、PDF、md 等）
- 向量化与相似检索
- 工具化的 query/retrieve

### 现实建议

Termux 上做本地向量库要谨慎：

- Python 依赖重、构建慢
- 存储与性能受限

更现实的路线：

1. 先选远端 RAG MCP（HTTP）
2. 或者选轻量本地实现（纯文本索引 + bm25/embedding 可选）

---

## 升级方向 3：语义代码检索（Serena MCP）

### 能力

Serena 提供“语义级代码检索与编辑”能力，目标是让 LLM 像 IDE 一样按 symbol/关系结构定位与修改代码。

参考：`oraios/serena`（MCP server + toolkit）。

### 与 OMO 的关系

这类能力可以补足 OMO 在“工程级理解/修改”上的效率差距（尤其在移动端上下文受限时）。

### Termux 注意

- Python 项目，依赖与性能需评估
- 更适合在“有项目目录”的场景，不是纯聊天

---

## 对占位项（8080/8081/8082）的处理策略

建议用“真实实现替换占位端口”，而不是继续维护空服务：

- `playwright`: 用 `@playwright/mcp@latest`（stdio）或单独跑 HTTP transport
- `rag`: 选定一个明确的 RAG MCP（HTTP/stdio）
- `code-analyzer`: 明确是 grep 还是语义分析（Serena）
