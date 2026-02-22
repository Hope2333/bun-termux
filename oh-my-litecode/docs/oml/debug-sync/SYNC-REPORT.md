# OML 调试机同步记录

> 最后同步：2026-02-20

---

## 同步来源

- 调试机：`u0_a450@192.168.1.164:8022`
- 源目录：`~/termux.opencode.all/docs/` 和 `~/oml_project/docs/`

---

## 新增文档

### 来自 termux.opencode.all/docs/

| 文档 | 内容 |
|------|------|
| `00-scope-and-target.md` | 项目范围与目标、文档索引 |
| `10-bun-build-plan.md` | Bun 构建计划与 loader 集成 |
| `11-opencode-build-plan.md` | OpenCode 构建计划与运行时模式 |
| `12-bun-executable-structure.md` | Bun 可执行文件结构与兼容性 |
| `20-packaging-deb.md` | Debian 打包流程 |
| `21-packaging-pkg-tar-xz.md` | Pacman 打包流程 |
| `22-termux-services-opencode-web.md` | opencode-web sv 服务配置 |
| `99-open-issues-and-upstream-sync.md` | 开放问题与上游同步 |

### 来自 oml_project/docs/

| 文档 | 内容 |
|------|------|
| `architecture.md` | OML 架构设计 |
| `project_summary.md` | 项目总结（完成度、与 OMO 对比） |
| `fake_home_isolation.md` | 假 HOME 目录隔离实现 |
| `user_guide.md` | 用户指南 |
| `security.md` | 安全特性 |
| `forge_mcp_integration.md` | Forge MCP 集成 |
| `completion_report.md` | 完成报告 |

---

## 关键发现

### 1. OML 原始实现（来自 oml_project）

- **完成度**：~39%
- **qwenx**：70% - MCP 集成完成
- **geminix**：40% - 配置隔离完成
- **核心功能**：假 HOME 目录实现配置隔离

### 2. OCT/BUN 构建流程（来自 termux.opencode.all）

- **RUNTIME_MODE**：
  - `release-loader`：使用 bun-termux-loader 包装
  - `release-raw`：直接使用 bun runtime
  - `source-only`：依赖外部 bun
- **UPX 不可用**：会破坏 Bun 嵌入标记
- **strip 可用**：减少 10-30% 体积

### 3. 技术限制

| 限制 | 原因 | 解决方案 |
|------|------|----------|
| UPX 不兼容 | 破坏 `---- Bun! ----` 标记 | 使用 strip + zstd 压缩 |
| opencode 无 HTTPS | Bun.serve 未暴露 TLS | 反向代理 / Tunnel |
| `/proc/self/exe` 问题 | glibc vs bionic 差异 | userspace exec (loader) |

---

## 需要合并的内容

1. **打包流程文档**：`20-packaging-deb.md` 和 `21-packaging-pkg-tar-xz.md` 应合并到 `build-rules.md`
2. **上游问题跟踪**：`99-open-issues-and-upstream-sync.md` 应作为持续跟踪文档
3. **OML 原始实现**：作为历史参考，与当前 OML 架构对比

---

## 待办

- [ ] 将 `99-open-issues-and-upstream-sync.md` 整合到 OML 文档
- [ ] 验证调试机上的 opencode 和 bun 版本
- [ ] 同步调试机上的 PKGBUILD 改动
