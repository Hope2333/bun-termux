# 接下来执行清单（按你要求）

更新时间：2026-02-15

Scope: 本文针对 `oml/omg` 当前执行清单。术语见 `00-glossary-and-scope.md`。

## 已确认约束

1. oml-tools 是大基线，不只管 qwen。
2. 继续直接做。
3. 可选模块先占位，不强推功能定义。
4. `~/.qwen` 特殊安装路径必须支持并验收。

---

## Step 1（现在）

- [x] 完成 `oml-tools` discover/call 协议骨架
- [x] 完成 `omqwen` settings 注入脚本
- [x] 验证 `~/.qwen` 路径可用（非 fakehome）

## Step 2（下一步）

- [x] 把 `oml-tools` 的 `oml.mcp_call` 从占位改成真实 gateway（HTTP MCP）
- [ ] 对接 context7/websearch/grep-app 三件套
- [ ] 增加超时/重试/错误码规范

## Step 3（并行）

- [ ] 导出包加入 `commandRegex` 交互提示与冲突检测
- [ ] 模型 alias 规则按 provider 细化（大小写、分隔符、org/name）

## Step 4（必须）

- [ ] 在 fakehome 与 `~/.qwen` 两路径各跑一次完整验收
  - [x] qwen 可执行（`--approval-mode yolo` 下外置工具调用成功）
  - [x] 外置工具可 discover（oml-tools-discover 输出可被解析）
  - [x] 外置工具 call 成功（oml.mcp_call 返回 status 200）
- [ ] MCP 三件套工具调用级通过（当前已验证 websearch/context7，grep-app 外置网关待补）
  - [x] MCP 三件套工具调用级通过（websearch/context7/grep-app 均已验证）

## Step 5（并行维护）

- [x] 将 `oml/oma`（omaider/aiderx）标记为 alpha（无版本号）
- [x] 建立 omaider alpha 维护计划（持续搜罗/计划/验证）
- [x] 建立 omaider 子项目模板规范（XDG + Makefile + 门禁）
