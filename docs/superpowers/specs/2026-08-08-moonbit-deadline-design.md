# moonbit-deadline 设计说明

## 目标

`moonbit-deadline` 是一个以 MoonBit 为主要实现语言的法律与合同期限计算库，同时提供可现场演示的 CLI。它把“期限计算算法”与“法域/组织日历数据”分开，支持自然日、工作日、起算日规则、届满日顺延、多级期限和可审计解释。

它不是法律意见系统，也不对任何法域的具体结果作权威承诺。示例中国日历仅用于演示可注入日历模型，README 必须标注数据范围、来源与使用者复核责任。

## 设计原则

1. 日期只表示公历日期，不引入时区或时间戳语义。
2. 算法是确定性的：同一日期、规则和日历必须产生同一结果。
3. `Calendar` 是依赖注入边界；核心不写死中国节假日，也不把日历数据散落到算法中。
4. 计算结果保留原始届满日、调整后届满日和步骤说明，便于调试、审计和 CLI 展示。
5. 公开类型归属于用户直接导入的根包；内部解析与算术辅助不泄漏为公共 API。
6. 先用测试确定语义，再实现最小行为；所有公开行为都有黑盒测试或 README 示例。

## 术语与语义

### 日期

`Date` 表示有效的公历年月日，支持闰年、月份长度、跨月/跨年加减、星期计算和 ISO-8601 `YYYY-MM-DD` 解析/格式化。项目首版限制年份为 1–9999，并拒绝无效日期。

### 起算日

`StartDateRule` 至少包含 `Include` 和 `Exclude`：

- `Include`：起算日作为第一个计数日。
- `Exclude`：从起算日之后的第一个符合条件的日子开始计数。

### 期限规则

`DateRule` 支持：

- `CalendarDays(Int)`：自然日数量。
- `BusinessDays(Int)`：由 `Calendar` 判定的工作日数量。
- `Weeks(Int)`、`Months(Int)`、`Years(Int)`：公历单位运算；月底溢出采用目标月份最后一天钳制。
- `Sequence(Array[DateRule])`：前一阶段的届满日作为后一阶段起点，形成多级期限。

首版只接受非负数量；负数返回明确错误。`Sequence` 允许空序列并返回起算日，避免隐藏的特殊值。

### 工作日日历

`Calendar` 包含名称/版本、周末策略、节假日集合和特殊工作日集合：

- 先判断特殊工作日；再判断节假日；最后判断周末策略。
- `is_business_day` 的优先级保证调休工作日可以覆盖周末，节假日可以覆盖默认工作日。
- 日历数据使用日期数组和确定性查找，避免将第三方集合 API 作为核心依赖。

### 顺延策略

`ExtensionPolicy` 至少包含：

- `NoExtension`：不调整自然届满日。
- `Following`：若届满日非工作日，顺延到下一个工作日。
- `ModifiedFollowing`：优先顺延；若跨月则改为上一个工作日。
- `Preceding`：若届满日非工作日，提前到上一个工作日。

自然日规则可以选择是否应用顺延；工作日规则本身会跳过非工作日，但仍可在最终届满阶段应用策略，调用方通过 `Deadline` 配置明确表达意图。

### 计算结果

`DeadlineResult` 包含：起算日、规则、自然计算出的届满日、调整后届满日、调整次数、是否发生跨月/跨年以及按顺序排列的 `CalculationStep`。步骤说明使用结构化枚举与可读文本，CLI 只负责格式化，不重新实现算法。

## 公共 API 草案

最终签名以本机 MoonBit 0.10.4 的编译器和生成接口为准，以下是稳定的设计意图：

```text
Date::new(year~, month~, day~) -> Result[Date, DateError]
Date::parse(text) -> Result[Date, DateError]
Date::to_string() -> String
Date::add_days(count) -> Date
Date::add_months(count) -> Date
Date::weekday() -> Weekday

Calendar::new(name~, version~, weekend~, holidays~, extra_workdays~) -> Calendar
Calendar::is_business_day(date) -> Bool
Calendar::next_business_day(date) -> Date
Calendar::previous_business_day(date) -> Date

Deadline::new(start_date~, rule~, start_rule~, calendar~, extension~) -> Deadline
Deadline::calculate() -> Result[DeadlineResult, DeadlineError]
DeadlineResult::adjusted_date() -> Date
DeadlineResult::explain() -> String
```

类型名称和字段最终以 `moon info` 生成的 `pkg.generated.mbti` 为准；实现过程中不得直接编辑生成文件。

## 模块和文件边界

```text
moon.mod
moon.pkg
src/
  date_types.mbt          # Date、Weekday、DateError
  date_parse.mbt          # ISO 日期解析与格式化
  date_arithmetic.mbt     # 闰年、序号日、跨月/跨年运算
  calendar_types.mbt      # Calendar、WeekendPolicy、CalendarError
  calendar_logic.mbt      # 工作日判定与前后查找
  rule_types.mbt          # DateRule、StartDateRule、ExtensionPolicy
  deadline_types.mbt      # Deadline、DeadlineResult、CalculationStep
  deadline_engine.mbt     # 规则解释与顺延引擎
  date_test.mbt           # 日期黑盒测试
  calendar_test.mbt       # 日历和工作日测试
  deadline_test.mbt       # 期限与顺延测试
examples/
  sample_calendar.mbt     # 示例中国 2026 日历，仅供演示
cmd/deadline/
  main.mbt                # CLI 参数解析与输出
  moon.pkg
docs/
  calendar-data.md        # 数据来源、版本与适用边界
  api.md                  # API 使用说明
  submission.md           # 比赛申报书与验收自检
.github/workflows/
  check.yml               # 跨平台格式、check、test、info、coverage
LICENSE
README.md
README.mbt.md             # 可执行文档示例（如工具链支持）
CHANGELOG.md
```

## CLI 设计

示例命令：

```text
moon run cmd/deadline -- --start 2026-01-30 --rule calendar-days:10 --exclude-start --extension following
moon run cmd/deadline -- --start 2026-01-03 --rule business-days:5 --calendar sample-china-2026 --explain
moon run cmd/deadline -- --start 2026-02-27 --rule sequence:calendar-days:5,business-days:3 --extension modified-following
```

CLI 必须在参数错误时返回非零退出码，并把可读错误写到标准输出/错误流；成功输出起算日、规则、原始届满日、调整后届满日和步骤。CLI 不承担法律判断，只展示库计算结果。

## 测试范围

- 无效日期、闰年、月末钳制、跨月、跨年。
- 起算日包含/排除。
- 自然日、工作日、周末、节假日、调休工作日。
- Following、ModifiedFollowing、Preceding 和无顺延。
- 空规则、多级规则、跨月的多级规则。
- 结果步骤顺序和解释文本稳定性。
- CLI 的成功、缺少参数、无效日期、未知规则和示例日历。
- 生成接口后 `moon info --deny-warn` 无未提交差异。

## 非目标

- 不内置权威法律条文、诉讼管辖、时区、时间戳或法律意见。
- 不复制第三方日期库源码；通用日期能力仅实现本项目需要且有测试证明的部分。
- 不把示例节假日数据宣传为完整或官方的中国法定节假日数据库。
- 不为了达到行数指标生成重复代码；规模通过真实的解析、规则、日历、解释、测试和文档能力增长。

## 验收与发布

完成条件：公开可访问仓库，README/许可证/来源说明完整，CLI 和示例可运行，测试与 CI 通过，`moon fmt --deny-warn`、`moon info --deny-warn`、`moon check --deny-warn`、`moon test --deny-warn` 和构建通过，Mooncakes 发布配置准备完成，提交历史包含不少于 10 个功能性提交且作者身份只有用户本人。

## 来源

- 比赛说明：<https://bxup9uklfcb.feishu.cn/wiki/KNrVwEVFziPHiGkQtwhc6w3gndd>
- MoonBit 命令文档：<https://docs.moonbitlang.com/en/latest/toolchain/moon/commands.html>
- MoonBit 包配置：<https://docs.moonbitlang.com/en/latest/toolchain/moon/package.html>
- 社区工作流模板：<https://github.com/moonbit-community/.github/tree/main/workflow-templates>
- Mooncakes 检索：<https://mooncakes.io/>
