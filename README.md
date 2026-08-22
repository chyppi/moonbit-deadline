# moonbit-deadline

`moonbit-deadline` 是一个纯 MoonBit 的法律、合同和合规期限计算库。它把起算事件、计数规则、工作日历、顺延策略、暂停区间和审计输出组合成可复用的确定性 API。

它只计算日期，不提供法律意见。使用者应自行确认适用法域、送达规则、法院日历和合同条款，并注入经过审核的日历数据。

## 特性

- 自然日、工作日、周、月、年和序列期限。
- 起算日计入/排除、Following、Modified Following 和 Preceding 顺延。
- 可注入周末、节假日、调休、观察日、版本和来源的工作日历。
- 事件起算、暂停区间、批量依赖计划、跨日历矩阵和期限预测。
- 期限窗口、约束校验、完成回执、状态台账和提醒计划。
- 日历统计、差异比较、时间线 CSV/Markdown、审计文本/表格/CSV 输出。
- MoonBit 库 API、命令行示例和独立 benchmark workload。

## 快速开始

运行一个“起算日不计入、顺延到下一个工作日”的期限：

```bash
moon run cmd/deadline -- --start 2026-08-07 --rule business-days:5 --exclude-start --extension following --explain
```

规则格式为 `calendar-days:N`、`business-days:N`、`weeks:N`、`months:N` 或 `years:N`；逗号可以串联多个阶段。

```text
calendar=standard
version=builtin
region=
source=
source_url=
start=2026-08-07
original=2026-08-14
adjusted=2026-08-14
adjustments=0
crossed_month=false
crossed_year=false
```

表格输出：

```bash
moon run cmd/deadline -- --start 2026-08-07 --rule business-days:5 --exclude-start --format table
```

## 库 API

```moonbit
let calendar = @deadline.Calendar::china_2026()
let deadline = @deadline.Deadline::new(
  start_date=@deadline.Date::parse("2026-04-30").unwrap(),
  rule=@deadline.DateRule::business_days(1),
  start_rule=@deadline.StartDateRule::exclude(),
  calendar~,
  extension=@deadline.ExtensionPolicy::following(),
)
let result = deadline.calculate().unwrap()
println(result.summary())
println(@deadline.AuditReport::from_result(result, calendar).to_text())
```

模块名是 `chyppi/moonbit-deadline`。核心类型包括 `Date`、`DateRule`、`Deadline`、`Calendar`、`EventContext`、`BatchDeadline`、`DeadlineRecord` 和 `AuditReport`。

## 日历数据

`Calendar::china_2026()` 是可复现的示例 fixture，版本标记为 `2025-11-04`，日期来自国务院办公厅节假日安排通知的北京市人民政府转载页面：[官方政策页面](https://www.beijing.gov.cn/gate/big5/www.beijing.gov.cn/zhengce/zhengcefagui/202511/t20251104_4258873.html)。它不代表所有地区、法院、行业或合同的完整日历。

业务方可以使用 `CalendarBuilder` 构建自定义日历，使用 `CalendarCatalog` 管理多个版本，并用 `Calendar::diff` 检查数据更新。

## Benchmark

benchmark 运行真实的日历查询、工作日期限和批量期限计算，并输出 checksum，避免空循环被误计为性能结果：

```bash
moon run bench/deadline_bench -- --iterations 10
```

本地一次运行（Moon 0.1.20260814 / Moonc 0.10.8，100 次迭代）得到：

```text
case=calendar iterations=100 checksum=48818044
case=deadline iterations=100 checksum=73967272
case=batch iterations=100 checksum=73983800
```

耗时应由运行机器的外层命令测量；以上 checksum 用于确认 workload 确实完成了计算。

## 开发与验证

```bash
moon check --target all --deny-warn
moon test --target wasm-gc --deny-warn
moon run cmd/deadline -- --start 2026-08-07 --rule business-days:5 --exclude-start --extension following --explain
moon run bench/deadline_bench -- --iterations 100
moon fmt
moon info
git diff --exit-code
```

`scripts/audit.ps1` 会输出工具链版本、有效 `.mbt` 文件规模、测试数、远程默认分支和工作区状态。有效规模统计排除 `_build`、`.moon`、缓存和 `pkg.generated.mbti`。

CI 使用 MoonBit stable 安装脚本，覆盖 Linux、macOS 和 Windows；Linux/macOS 运行全目标检查，Windows 运行 wasm、wasm-gc 和 js 便携目标，并统一执行格式化和接口生成差异门禁。Windows native 目标依赖运行器提供兼容的 MSVC/Clang C 工具链。

## 贡献

请为规则、日历数据和边界行为添加聚焦测试。日历数据变更应记录适用地区、来源和有效版本。提交前请阅读 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 许可证

MIT，见 [LICENSE](LICENSE)。
