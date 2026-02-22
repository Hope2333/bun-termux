# omaider（oml/oma）alpha 维护计划

更新时间：2026-02-15

Scope: 本文针对 `oml/omg` 体系中的 Aider 线（oml/oma）。术语见 `00-glossary-and-scope.md`。

备注：本线中 `oml/oma` = Aider（omaider/aiderx），不再使用其它别名。

## 当前定位

- `oml/oma`（Aider 线）当前处于 **alpha 无版本号** 阶段。
- 在达到“0.1.0 标准”之前，持续进行：搜罗 -> 对比 -> 计划 -> 小步验证。

---

## 维护目标（alpha 阶段）

1. 建立与 `oml-tools` 的兼容边界（不重复造轮子）。
2. 明确 Aider 线的最小可用路径（userland 安装 + 外置工具协作）。
3. 累积证据与门禁，直到满足 0.1.0 发布标准。

---

## 持续工作流（循环）

每轮迭代都执行：

1) **搜罗**：官方文档/issue/示例与本地实验现状对比  
2) **计划**：将新增发现写入 milestone 草案  
3) **验证**：做最小命令级验证（可复现、可回滚）  
4) **沉淀**：更新文档与风险清单（不写密钥）

---

## 0.1.0 发布前门禁（必须全部满足）

1. 用户态安装规范明确（XDG + `~/.local/bin` + uninstall + doctor）。
2. 与 `oml-tools` 至少 2 个外置工具链路跑通（示例：healthcheck、mcp_call 或等价）。
3. 脱敏导出流程可执行，且扫描无明文 key。
4. 跨设备复现文档可在新环境复跑。
5. 已知风险有处置策略（至少记录 workaround 与不支持项）。

6. 运行时兼容门禁：
   - 若使用 `aider-chat`，需满足 Python `<3.13`。
   - 若目标环境 Python >= 3.13，必须提供独立 userland 运行时（3.12/3.11）方案。

未满足门禁前：保持 alpha，不发布 `oml-aider-0.1.0`。
