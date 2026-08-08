# moonbit-deadline

面向法律、合同和合规流程的 MoonBit 期限计算库。它把“如何计日”和“遇到非工作日怎么办”拆成可组合规则，并允许调用方注入司法辖区、机构或合同自己的工作日历。

## 解决的问题

- 自然日、工作日、周、月、年和多级期限计算
- 起算日计入或排除
- 周末、节假日和调休工作日
- Following、Modified Following、Preceding 和不顺延策略
- 可审计的计算步骤与解释文本
- 同一套核心 API 供 MoonBit 程序和命令行使用

本项目是确定性计算库，不提供法律意见。生产使用时应由业务方确认适用法域、送达规则、法院日历和合同条款，并通过 `Calendar::new` 注入经过审核的数据。

## 快速开始

运行一个“起算日不计入、顺延到下一个工作日”的工作日期限：

```bash
moon run cmd/deadline -- --start 2026-08-07 --rule business-days:5 --exclude-start --extension following --explain
```

输出示例：

```text
2026-08-07 — start date
2026-08-14 — business days: 5
2026-08-14 — deadline
```

规则格式为 `calendar-days:N`、`business-days:N`、`weeks:N`、`months:N` 或 `years:N`。使用逗号可以串联多个阶段，例如 `calendar-days:3,business-days:2`。

## 库 API

```moonbit
// In a dependent package, import { "chyppi/moonbit-deadline" @deadline, }
let calendar = @deadline.Calendar::china_2026()
let deadline = @deadline.Deadline::new(
  start_date=Date::parse("2026-04-30").unwrap(),
  rule=@deadline.DateRule::business_days(1),
  start_rule=@deadline.StartDateRule::exclude(),
  calendar~,
  extension=@deadline.ExtensionPolicy::following(),
)
let result = deadline.calculate().unwrap()
println(result.explain())
```

核心类型：

- `DateRule`：期限的计数规则，支持 `Sequence`
- `Deadline`：绑定起算日、规则、日历和顺延策略
- `Calendar`：周末政策、节假日和额外工作日
- `ExtensionPolicy`：届满日调整策略

## 日历数据来源

`Calendar::china_2026()` 是一个可复现的示例 fixture，版本标记为 `2025-11-04`，日期来自国务院办公厅《关于 2026 年部分节假日安排的通知》：[北京市人民政府转载的官方政策页面](https://www.beijing.gov.cn/gate/big5/www.beijing.gov.cn/zhengce/zhengcefagui/202511/t20251104_4258873.html)。它不代表所有地区、法院、行业或合同的完整工作日历；请勿直接把它当作法律结论。

命令行可以选择它：

```bash
moon run cmd/deadline -- --start 2026-04-30 --rule business-days:1 --exclude-start --calendar china-2026
```

## 开发与验收

```bash
moon check --deny-warn
moon test --deny-warn
moon run cmd/deadline -- --start 2026-08-07 --rule business-days:5 --exclude-start --extension following --explain
moon fmt --check
moon info
git diff --exit-code
```

CI 参考 [moonbit-community/.github 的 check workflow 模板](https://github.com/moonbit-community/.github/tree/main/workflow-templates)，覆盖 Linux、macOS 和 Windows，并执行全目标检查、测试、格式化、信息生成和 CLI 冒烟测试。

当前开发环境为 `moon 0.1.20260713` / `moonc 0.10.4`。该版本支持 `check/test --deny-warn`，但尚不接受 `fmt/info --deny-warn` 参数；因此仓库对后两项使用官方模板同等严格的“运行命令后检查 `git diff`”流程。升级到支持该参数的工具链后，可将 CI 中对应命令直接替换为带 `--deny-warn` 的形式。

## 项目边界与路线

当前实现聚焦确定性日期算术和可注入日历，后续可扩展：

1. 合同约定的自定义工作周和截止时刻
2. 多法域日历与日历版本管理
3. 期限事件的结构化 JSON/表格输出
4. 更细的“送达日、起算事件、暂停/中止”规则模型

节假日数据不内置为全球常量，避免把不断变化的外部事实伪装成稳定算法。

## 许可证

MIT，见 [LICENSE](LICENSE)。
