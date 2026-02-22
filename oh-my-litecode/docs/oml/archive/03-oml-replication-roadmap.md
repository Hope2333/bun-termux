# OML 升级路线图：先全方位复刻 OMO，再扩展 ForgeCode / Aider

更新时间：2026-02-15

Scope: 本文针对 `oml/omg` 的复刻与扩展路线。术语见 `00-glossary-and-scope.md`。

## 目标

分三阶段推进：

1. **Phase A（已打底）**：Qwen/Gemini 主线稳定可用
2. **Phase B（核心）**：在 OML 内复刻 OMO 的关键能力
3. **Phase C（扩展）**：把同样能力层迁移到 ForgeCode 与 Aider

---

## Phase A（现状）

### 已达成

- fake HOME 隔离（qwenx/geminix）
- 核心 MCP 三件套连通（context7/grep-app/websearch）
- 关键配置收敛，去除占位服务对主流程影响

### 未完成

- 统一健康检查脚本（机器可读 JSON 输出）
- wrapper 与文档的一致性自动校验

---

## Phase B：复刻 OMO 的能力分层（Qwen/Gemini）

## B1. 能力层映射（优先级高）

- MCP 管理：增删查、allow/exclude、scope
- Skills：内置/自定义技能目录规范
- Subagents：任务分发与会话延续
- Hooks：关键时机执行（安全检查、日志归档）
- Session：会话目录结构、导出与回放

## B2. 质量门禁（必须）

每次变更必须满足：

1. `mcp list` 连通基线通过
2. 至少 1 次工具调用成功
3. 无敏感信息落盘
4. 文档与实际配置一致

## B3. 建议新增模块

- `healthcheck.sh`：一键检测 qwen/qwenx/geminix 状态
- `sanitize.sh`：一键脱敏导出
- `audit-config.sh`：检查配置漂移（脚本/settings/文档）

---

## Phase C：向 ForgeCode 与 Aider 复刻

## C1. ForgeCode 复刻路径

根据本地资料，Forge 侧可走：

- 独立 fake HOME：`~/.local/home/forge`
- 通过 `forge mcp import` 导入 MCP
- 对齐到同样核心三件套（context7/grep-app/websearch）

验收：

- `forge mcp list` 可见并连通核心三项
- 与 qwenx/geminix 使用同一套脱敏与健康检查策略

## C2. Aider 复刻路径

Aider 自身偏“模型驱动 + git 工作流”，MCP 原生集成路径弱于 Qwen/Gemini/Forge。

建议采用“外接能力”策略：

- 保持 aiderx fake HOME 隔离
- 将检索/文档能力前置到外部脚本或并行工具层
- 在 Aider 中重点复刻：安全规范、会话与变更流程规范

验收：

- aiderx 启动稳定
- 模型配置与隔离可重复
- 安全与日志治理对齐 OML 标准

---

## 里程碑建议

### Milestone 1（1-2 天）

- 完成 healthcheck / sanitize / audit 三脚本
- 文档落地并可执行验证

### Milestone 2（3-5 天）

- Qwen/Gemini 侧 hooks + skills + session 规范化
- 形成 OML v0.2 基线

### Milestone 3（5-8 天）

- ForgeCode 完成同等三件套复刻
- 通过统一健康检查

### Milestone 4（8-12 天）

- Aider 完成隔离与治理复刻
- 发布 OML 多客户端统一规范 v1

---

## 不纳入“完成度”的项

以下内容若未通过运行态验证，不得计入完成度：

- 仅文档声明“已完成”
- 仅配置存在但未连通
- 占位服务（8080/8081/8082）无实际实现
