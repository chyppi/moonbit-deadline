# 研究发现

## 2026 MoonBit 8 月黑客松官网

来源：<https://bxup9uklfcb.feishu.cn/wiki/KNrVwEVFziPHiGkQtwhc6w3gndd>（页面标注 2026-07-28 修改）

- 活动定位：以 MoonBit 及工具链为基础，鼓励完成开源生态库、开发工具和示例工程的设计、开发、移植与完善；允许合理使用 AI 辅助。
- 报名时间：2026-07-22 至 2026-08-24；报名截止 2026-08-24 24:00。
- 申报材料：基本信息、公开可访问代码仓库、一页左右 Markdown 项目申报书、现有基础、本次新增内容、目标与技术路线、预计功能/测试/文档；移植项目还需提供原项目、链接、许可证和移植范围。
- 项目类型：原创 MoonBit 开源库、其他语言成熟库的 MoonBit 移植、开发工具或示例工程；应尽量避免与 MoonBit 生态已有成熟项目高度重合；核心功能必须主要用 MoonBit 实现。
- 项目规模：参考有效 MoonBit 代码 4,000–10,000 行，但不是硬性验收线；更看重真实可用性、边界、工程结构、文档、测试、示例、维护价值和生态价值。
- 验收：公开可访问仓库、完整 README、用途/功能/用法说明、可运行示例、CI、可运行测试、可构建、按要求发布 Mooncakes、可追踪开发过程/提交记录、清晰边界与维护价值、许可证合规。
- 建议保留：Git 提交、Issue/工单、合并请求、测试记录、更新日志、版本发布记录、重要技术方案和设计说明。
- 版权：必须使用 OSI 认可许可证；不得提交未经授权的私有/闭源/商业/来源不明内容；使用或参考第三方项目需保留版权、许可证和来源说明。
- AI：可以用于代码生成、接口设计、测试、文档、移植分析、解释、调试和工程改进，但参赛者对目标、路线、质量、边界、安全性、来源准确性、许可证、可解释性、可测试性和可维护性负责。
- 参考方向包括解释器、事件总线、QUIC、状态管理、动态规则校验、WebHook、音频解码、分布式仿真、渲染、LSP、布局引擎、CLI、Web 服务器、大数据、SQL、Actor、WASM K8S、OCI、数据库驱动等；允许其他具有生态价值的项目。
- 奖励：通过初审 150 元/人；通过验收再 350 元/人；完整通过合计 500 元/人。

## 项目方向初步判断

`moonbit-deadline` 属于原创 MoonBit 开源库，应用场景清晰，和官方参考的“动态规则校验引擎/其他有复用价值应用”相邻，但不是简单窄工具。为避免变成只支持单一法域的硬编码程序，设计应把“法律期限计算内核”和“法域/组织日历数据”分离：

- 核心：日期、周期、起算/届满规则、工作日判定、顺延策略、复合期限。
- 数据：可注入的 `Calendar`，包含周末规则、法定节假日/调休、特殊工作日和命名版本。
- 场景：通过策略组合覆盖中国法、合同约定、国际业务日历，而不是把某一法域写死在算法里。
- 交付：库 API + 可演示 CLI + 可复用日历格式/样例 + 完整测试与边界说明。

## 官方 MoonBit 工具链 / CI 参考

- 官方文档：<https://docs.moonbitlang.com/en/latest/toolchain/moon/commands.html>
- 包配置与 `moon.pkg`：<https://docs.moonbitlang.com/en/latest/toolchain/moon/package.html>
- 当前官方文档明确支持 `--deny-warn`，并建议在 CI 中把警告视为错误；`moon info` 可生成包接口信息。
- MoonBit 社区工作流模板：<https://github.com/moonbit-community/.github/tree/main/workflow-templates>
  - 目录包含 `check.yml`、`publish.yml`、`copilot-setup-steps.yml` 及对应 properties 文件。
- 官方 `check.yml` 的核心做法：Ubuntu/macOS/Windows 矩阵；安装 Moon；运行 `moon version --all`、`moon update`、`moon check --target all`、`moon test --target all`；最后运行 `moon fmt && git diff --exit-code` 与 `moon info && git diff --exit-code`。
- 用户要求参考的 <https://github.com/PaiGack/moonbitlang-OSC2026/blob/main/.github/workflows/test.yml> 会重定向到 <https://github.com/PaiGack/moonbit_sshclient/blob/main/.github/workflows/test.yml>；已读取该实际仓库的 `test.yml`。它进一步采用三平台矩阵、Windows 的 MSYS2/MinGW/OpenSSL、`moon fmt --check`、`moon check --deny-warn`、`moon info`、`git diff --exit-code`、`moon test --deny-warn --enable-coverage`、`moon coverage report -f summary` 和 `moon coverage analyze`，并额外执行 native 测试。我们的纯 MoonBit 项目不需要 OpenSSL/FFI，但会吸收其跨平台、deny-warn、coverage 和生成文件无脏 diff 的检查思路。

## 选题与去重待查

已在 <https://mooncakes.io/> 的模块搜索框检索：`deadline`、`date`、`calendar`、`business-day`、`working-day`、`legal`、`holiday`。

- `deadline`、`business-day`、`working-day`、`legal`、`holiday`：无结果。
- `date`：命中 `mizchi/bit_date`（Git 日期解析，Apache-2.0）、`brickfrog/tempo`（UTC/RFC3339 时间运算）、`suiyunonghen/datetime`、`iceBear67/time`、`Asterless/MoonPtime` 等通用日期时间包；没有法律期限语义。
- `calendar`：命中 `ciqingweiyang/mooncal`（iCalendar/RRULE）、`100kkk/moon-schedule`（UTC Cron/RFC5545 recurrence）、`001-Elsa/mooncron`（Cron）、`justinwongcn/tyme4mb`（中国传统历法）等；均不提供法律期限、工作日/节假日顺延策略。
- 逐个查看了相邻包的 Mooncakes 元数据：`moon-schedule` 为 MIT、0.1.0、低下载量且面向 Cron/RRULE；`tyme4mb` 为 MIT、0.2.1、面向传统历法；`bit_date` 为 Apache-2.0、0.45.6、面向 Git date parsing。它们不是功能高度重合的成熟法律期限项目。

去重结论：`moonbit-deadline` 可以作为原创库继续，但必须把差异写进 README 和 API 文档：它解决的是“法律/合同期限的规则化计算与可审计解释”，而不是通用时间戳、Cron、RRULE、传统历法或 iCalendar 解析。核心类型应围绕 `DateRule`、`Deadline`、`Calendar`、`ExtensionPolicy` 和可解释结果展开，并通过可注入日历支持多个法域/组织日历。

## 安全与身份

- GitHub 只使用当前 `gh auth login` 的授权身份；不得从历史缓存选择其他身份。
- GitLink 密码仅用于交互式认证或安全凭据输入，不写入仓库、脚本、远程 URL、提交信息或日志。
- 不创建虚拟账号、虚拟署名或伪造贡献者；提交作者需使用用户本人身份配置。
