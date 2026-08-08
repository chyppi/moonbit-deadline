# moonbit-deadline 任务计划

## 目标

为 2026 MoonBit 8 月黑客松准备 `moonbit-deadline`：一个面向法律期限计算的可复用 MoonBit 库与 CLI，完成设计、实现、测试、文档、CI、Mooncakes 发布准备，以及 GitHub/GitLink 仓库审计与推送。

## 阶段

1. [completed] 读取比赛要求、MoonBit 官方规范与 Mooncakes 生态，确认选题边界与去重结论。
2. [completed] 通过头脑风暴门槛确定架构、API、日历模型、CLI 交互和验收标准；用户已确认设计。
3. [completed] 建立 MoonBit 模块骨架，先写失败测试，再实现核心 API。
4. [completed] 扩展节假日/工作日/顺延/多级期限能力，补齐示例、CLI、文档与有效 MoonBit 代码规模。
5. [completed] 增加 CI、格式化/信息生成检查与 Mooncakes 发布配置，并完成 MoonBit 0.10.x 兼容性验证。
6. [completed] 形成 21 个真实、可追踪的提交，完善 LICENSE、README、CHANGELOG、来源说明与项目申报材料。
7. [completed] 以当前 `gh auth login` 身份创建并推送 GitHub；在 GitLink 使用用户提供的本人账号完成创建和推送；未制造虚拟贡献者。
8. [completed] 按 OSC2026 检查清单自查仓库结构、README、许可证、提交历史、默认分支、源码规模、来源说明与 CI 结果。

## 当前状态

- 工作区已完成实现与审计，当前分支 `main`，远程 GitHub/GitLink 已同步。
- 本机 MoonBit：`moon 0.1.20260713`，`moonc 0.10.4+2cc641edf`；高于用户提到的 0.10.3，需确认比赛 CI 版本策略。
- 用户明确要求项目标识 `moonbit-deadline`，并要求 GitHub/GitLink 各自保留账号创建者本人作为唯一贡献者。
- 用户要求有效提交次数超过 10 次、补充 CI、通过 `moon fmt --deny-warn` 与 `moon info --deny-warn`，并参考 `PaiGack/moonbitlang-OSC2026` 的工作流。

## 已知兼容性说明

- 当前已安装技能清单中没有名为 `moonbitlang/skills` 或 `osc2026-guide` 的技能；已确认工作区也没有同名 `SKILL.md`。将使用现有 MoonBit/规划/验证技能，并继续搜索公开的同名仓库或指南作为参考来源。
- 本机工具链接受 `check/test --deny-warn`，但拒绝 `fmt/info --deny-warn`；仓库使用运行命令后检查 `git diff` 的等价严格门禁，并已在 CI 通过。

## 错误记录

| 错误 | 尝试 | 处理 |
|---|---|---|
| Firecrawl CLI 未出现在本机命令列表 | 检查 `Get-Command firecrawl` | 改用已连接网页检索工具，并记录为等价后备 |
| 直接网页工具无法安全打开 Feishu、GitHub 工作流文件缓存未命中 | 直接 URL open | 读取浏览器控制技能后，用可见网页 DOM 只读方式访问 |
| Feishu 章节点击出现 2 个同名元素严格匹配错误 | `getByText("七、移植项目要求")` | 改用 TOC 的 `getByRole("link", ...)` 定位 |
| PowerShell 读取 Git superproject 空值时调用 `.Trim()` | `git rev-parse --show-superproject-working-tree 2>$null` | 记录为空并继续；当前仓库不是子模块 |
| 创建 `codex/moonbit-deadline` 分支时 `.git/HEAD.lock` 权限不足 | `git switch -c codex/moonbit-deadline` | 工作树写入可用但 Git 元数据只读；待需要提交时申请受控 Git 权限 |
- Core date, calendar, deadline engine, CLI and China 2026 fixture are implemented.
- README, MIT license, changelog, contribution guide and cross-platform CI are present.
- Local verification currently passes for all four targets with 27 tests; final remote synchronization, Mooncakes publication preparation and OSC2026 audit remain.
- The installed toolchain accepts `check/test --deny-warn` but rejects `fmt/info --deny-warn`; the repository documents and gates the supported equivalent until the requested toolchain exposes those flags.
- Remote delivery is complete: GitHub and GitLink both expose the same final main commit, use main as the default branch, and show the chyppi identity as the sole active contributor.
