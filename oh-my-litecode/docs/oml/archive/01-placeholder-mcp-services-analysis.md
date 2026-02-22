# OML 本地占位 MCP 服务（8080/8081/8082）深度分析

更新时间：2026-02-15

Scope: 本文针对 `oml/omg` 体系的 MCP 占位服务说明。术语见 `00-glossary-and-scope.md`。

## 结论（先看）

你本地这 3 组服务本质上是**占位配置**，不是已实装服务：

- `playwright` / `playwright-mcp-server` → `http://localhost:8080`
- `rag` / `rag-mcp-server` → `http://localhost:8081`
- `code-analyzer` / `code-analyzer-mcp-server` → `http://localhost:8082`

当前状态：

- 配置里反复出现（setup 脚本与文档）
- 实机未见对应监听/服务进程
- 在 `mcp list` 中长期 Disconnected（此前已验证）

因此它们当前只能造成“看起来有功能”的假象，不提供真实能力。

---

## 本地证据（文件级）

### 1) 明确写入占位端口的来源

`oml_project/scripts/setup.sh` 中直接把三项写入配置：

- `playwright -> http://localhost:8080`
- `rag -> http://localhost:8081`
- `code-analyzer -> http://localhost:8082`

并且还有对应 `*-mcp-server` 命名版本。

### 2) 文档里存在“已集成”叙述，但与运行态不一致

在 `oml_project/docs/*.md` 中多处写了已集成 MCP；
但实机运行状态显示上述三项未连通。

### 3) 运行态验证

在手机 Termux 实测：

- `qwen mcp list / qwenx mcp list / geminix mcp list` 中，这三项此前持续断连
- 已将主路径收敛到可连通三件套（`context7 / grep-app / websearch`）

---

## 这三组“理论上能做什么”

> 下面是“若正确实装”的能力，不代表当前已可用。

### A. Playwright MCP（8080）

目标能力：浏览器自动化。

参考官方 `microsoft/playwright-mcp`：

- 页面导航、点击、输入、表单填充
- DOM/可访问性快照
- 网络日志、控制台日志
- 截图、文件上传、tab 管理

### B. RAG MCP（8081）

目标能力：检索增强（文档入库 + 相似检索 + 上下文召回）。

常见形态：

- 本地向量库（如 Chroma/LanceDB/FAISS）
- 远端检索服务（HTTP MCP）
- 文档 ingestion + query 工具

### C. Code-Analyzer MCP（8082）

目标能力：代码检索/分析。

在你当前历史配置里，`code-analyzer` 常被映射成 `@247arjun/mcp-grep`，其本质更接近“代码搜索”而非完整静态分析平台。

---

## 当前风险

1. **完成度幻觉风险**：文档写“已完成”，但运行态是 Disconnected。  
2. **维护分裂风险**：同义命名过多（playwright vs playwright-mcp-server）。  
3. **排障成本上升**：占位服务和真实服务混在一起，误导后续排错。

---

## 已采取处置（当前主线）

已把生产可用路径收敛为三件套：

- `context7`（stdio）
- `grep-app`（stdio）
- `websearch`（remote Exa MCP）

这三项在 `qwen / qwenx / geminix` 均验证为 Connected。

---

## 后续建议（针对 8080/8081/8082）

### 短期（建议）

- 保持它们默认禁用或从主配置移除
- 在文档中标记为“候选扩展，不计入完成度”

### 中期（若要实装）

- 8080：优先接 `@playwright/mcp@latest` 官方方案
- 8081：选定 1 个维护活跃的 RAG MCP，定义 ingest/query 协议
- 8082：明确是“grep 搜索”还是“语义分析”，避免命名误导

### 验收门槛（必须）

- `mcp list` 连通
- 至少 1 次真实工具调用成功
- 失败日志可定位（而非静默）
