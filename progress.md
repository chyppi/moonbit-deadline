# 进度日志

- TDD RED verified: `moon test --deny-warn` fails because the intended `Date` type and API are not yet defined; the failure is the expected missing-feature diagnostic.
- TDD RED verified for Calendar: the suite fails only because `Calendar` and `WeekendPolicy` are not yet defined.
- TDD RED verified for deadline engine: the suite fails only because the rule, policy, deadline, and result APIs are not yet defined.

## 2026-08-08

- 通过 `moon new` 临时脚手架核对 `moon.mod` 格式；模块初始化检查通过。当前 0.10.4 的 `moon fmt`/`moon info` 不接受 `--deny-warn`，已记录为工具链兼容性差异。

- 完成工作区只读审计：空仓库、无提交、`master` 分支。
- 检查本机工具：MoonBit 0.10.4 编译器可用，`gh` 命令可用。
- 读取并展开 Feishu 比赛说明第 1–13 节，提取报名、项目规模、仓库验收、CI、Mooncakes、版权、AI 和提交记录要求。
- 核对官方 MoonBit 文档的 `moon fmt/info --deny-warn` 相关说明与社区 workflow-templates 目录。
- 在 Mooncakes.io 检索 7 个关键词并核对相邻包元数据；未发现法律期限/工作日顺延的高度重合成熟包。
- 读取社区 `check.yml` 与用户给定参考链接实际重定向后的 `PaiGack/moonbit_sshclient` `test.yml`，确认 CI 命令组合。
- 记录网页访问后备方案和一次严格定位错误，已改用角色链接定位。
- 用户确认“通用核心 + 标注为示例的中国日历适配包”设计。
- 完成并自审设计文档 `docs/superpowers/specs/2026-08-08-moonbit-deadline-design.md` 与实施计划 `docs/superpowers/plans/2026-08-08-moonbit-deadline.md`，已纳入提交历史。
- CLI implemented and verified with parser tests, sequence rules, calendar selection and an explanation-mode smoke test.
- Added an explicit China 2026 calendar fixture with holiday and extra-workday tests; README records the official source and the production-data boundary.
- Added MIT license, README, changelog, contribution guide and a three-OS CI workflow based on the MoonBit community template.
- Current local result: 27 tests pass for wasm, wasm-gc, js and native; `moon check --target all --deny-warn`, `moon fmt`, `moon info` and `git diff --exit-code` pass.
- Review fixes: checked date arithmetic now returns `OutOfRange`, calendar search no longer has a fixed 3660-day ceiling, deadline results expose audit metadata and step accessors, and month/year rules apply the start-date convention.
- Final local history was rewritten once so every commit uses the active GitHub/GitLink account identity `chyppi`; both remotes now point at `22bc350280c94f8cf381188d804ef629a7396175` on `main`.
- GitHub Actions three-OS CI passed after the generated-interface whitespace compatibility gate was corrected; GitHub and GitLink show `main`, more than 10 commits, and `chyppi` as the sole contributor.
