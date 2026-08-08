# moonbit-deadline 4K 源码扩展实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox syntax for tracking.

**Goal:** 在保持现有日期、日历、期限和 CLI 兼容的前提下，把有效 .mbt 源码扩展到约 4,000–4,400 行，并交付可复用的区间、计划、暂停、时间线、版本化日历和报告能力。

**Architecture:** 继续使用根 MoonBit 包，按职责新增小型类型/逻辑/测试文件。新增功能共享现有 Date、Calendar、DateRule 和 Deadline，由计划引擎统一阶段计算，由时间线和报告层消费结构化结果；CLI 只负责参数解析和渲染，不重复计算。

**Tech Stack:** MoonBit 0.10.x-compatible syntax, moon check, moon test, moon build, moon fmt, moon info, existing root package and CLI package.

## Global Constraints

- .mbt 有效源码目标为约 4,000–4,400 行；生成的 .mbti、构建产物和临时文件不计入规模。
- 现有 Date、DateRule、Deadline、Calendar、ExtensionPolicy API 和单规则 CLI 语法保持兼容。
- 所有新增行为必须先写失败测试并观察预期失败，再写最小实现。
- 所有日期算法复用现有 Date，不引入第二套日期表示或第三方运行时依赖。
- 节假日数据由调用方或明确来源的 fixture 提供，不把法域事实伪装成全球默认规则。
- 所有新增 public 类型和行为都要有 API 文档或 README 示例。
- 最终必须通过四目标 moon check --target all --deny-warn、moon test --target all --deny-warn、moon build --target all、格式/生成文件差异检查和三平台 CI。

---

### Task 1: 区间基础模型与统计

Files:
- Create: date_range_types.mbt
- Create: date_range_logic.mbt
- Test: date_range_test.mbt

Interfaces:
- Consumes: Date、DateError、Calendar。
- Produces: DateRange::closed、DateRange::single、contains、overlaps、intersection、union、calendar_days、business_days。

- [ ] Step 1: Write the failing test

Test reversed endpoints and a shared closed intersection. The first expected assertions are:
  DateRange::closed(2026-05-02, 2026-05-01) returns Err(DateRangeError::Reversed).
  The intersection of 2026-05-01..2026-05-05 and 2026-05-04..2026-05-08 is 2026-05-04..2026-05-05.

- [ ] Step 2: Run RED

Run moon test --deny-warn. Expected: failure because DateRange and DateRangeError do not exist.

- [ ] Step 3: Implement the minimum range model

Add Reversed, OutOfRange, and NoIntersection errors; store validated start/end; implement closed containment and intersection using existing comparison and checked day arithmetic. Count calendar and business days by iterating through existing Date and Calendar APIs.

- [ ] Step 4: Run focused and full tests

Run moon test --deny-warn; expected: all existing tests and range tests pass.

- [ ] Step 5: Commit

git add date_range_types.mbt date_range_logic.mbt date_range_test.mbt
git commit -m "feat: add date range operations"

### Task 2: Versioned calendars and observed holidays

Files:
- Create: calendar_version_types.mbt
- Create: calendar_version_logic.mbt
- Create: calendar_observance.mbt
- Test: calendar_version_test.mbt
- Modify: calendar_types.mbt, calendar_logic.mbt, sample_calendar.mbt, sample_calendar_test.mbt

Interfaces:
- Consumes: Calendar、WeekendPolicy、existing holiday and extra-workday precedence.
- Produces: CalendarSource、CalendarVersion、Calendar::with_version、Calendar::with_observed_holidays、metadata accessors and observed_date.

- [ ] Step 1: Write the failing metadata test

Construct CalendarVersion with name, region, version, source, valid_from and valid_to. Assert that calendar.with_version(version) preserves version and region.

- [ ] Step 2: Run RED

Run moon test --deny-warn. Expected: missing version and observed-holiday APIs.

- [ ] Step 3: Implement metadata and observed-day overlay

Validate valid_from <= valid_to. Add an immutable overlay that copies the base calendar and applies observed holidays before extra workdays, preserving existing precedence. Reject observations outside the version range.

- [ ] Step 4: Add source and fixture tests

Cover weekend observation, extra-workday override, out-of-range dates, and the existing 2026 official-source metadata.

- [ ] Step 5: Run and commit

Run moon test --deny-warn.
git add calendar_types.mbt calendar_logic.mbt calendar_version_types.mbt calendar_version_logic.mbt calendar_observance.mbt calendar_version_test.mbt sample_calendar.mbt sample_calendar_test.mbt
git commit -m "feat: add versioned calendar metadata"

### Task 3: Multi-stage deadline plans

Files:
- Create: plan_types.mbt
- Create: plan_engine.mbt
- Test: plan_test.mbt
- Modify: deadline_types.mbt, deadline_engine.mbt, deadline_test.mbt

Interfaces:
- Consumes: DateRule、StartDateRule、ExtensionPolicy、Calendar、DeadlineResult。
- Produces: PlanStage、DeadlinePlan::new、DeadlinePlan::add_stage、PlanResult、PlanStageResult and stage lookup.

- [ ] Step 1: Write the failing plan test

Build a plan starting on 2026-08-07 with notice business-days:1 and response business-days:2. Assert that the response start date equals the notice adjusted date.

- [ ] Step 2: Run RED

Run moon test --deny-warn. Expected: missing plan types and stage lookup.

- [ ] Step 3: Implement immutable stages and engine

Copy stage arrays, reject empty labels and invalid stage indexes, reuse Deadline for each stage, wrap errors with stage index and label, and preserve original and adjusted dates.

- [ ] Step 4: Add edge-case tests

Cover zero stages, one-stage equivalence with Deadline, stage failure, repeated labels, cross-year plans, and original-versus-adjusted start selection.

- [ ] Step 5: Run and commit

Run moon test --deny-warn.
git add plan_types.mbt plan_engine.mbt plan_test.mbt deadline_types.mbt deadline_engine.mbt deadline_test.mbt
git commit -m "feat: add multi-stage deadline plans"

### Task 4: Suspension and interruption rules

Files:
- Create: suspension_types.mbt
- Create: suspension_logic.mbt
- Test: suspension_test.mbt
- Modify: plan_types.mbt, plan_engine.mbt, plan_test.mbt

Interfaces:
- Consumes: DateRange、DateRule、DeadlinePlan stage dates.
- Produces: SuspensionPeriod、SuspensionPolicy、SuspensionSet::normalize、SuspensionSet::business_days and opt-in stage suspension.

- [ ] Step 1: Write the failing normalization test

Create overlapping periods 2026-06-10..2026-06-12 and 2026-06-12..2026-06-15. Assert normalization counts six inclusive calendar days rather than double-counting the shared endpoint.

- [ ] Step 2: Run RED

Run moon test --deny-warn. Expected: missing suspension types.

- [ ] Step 3: Implement validation and normalization

Sort by start date, merge overlapping or adjacent periods, count inclusive days according to policy, and return Reversed, OutOfRange, or Aborted errors instead of fabricating dates.

- [ ] Step 4: Integrate with plans

Add opt-in suspension configuration to PlanStage; default remains no suspension. Test pause-inclusive/exclusive endpoints, recovery, abort, and suspension outside a stage.

- [ ] Step 5: Run and commit

Run moon test --deny-warn.
git add suspension_types.mbt suspension_logic.mbt suspension_test.mbt plan_types.mbt plan_engine.mbt plan_test.mbt
git commit -m "feat: add suspension periods"

### Task 5: Event timeline and audit records

Files:
- Create: timeline_types.mbt
- Create: timeline_logic.mbt
- Test: timeline_test.mbt
- Modify: deadline_engine.mbt, plan_engine.mbt

Interfaces:
- Consumes: DeadlineResult、PlanResult、SuspensionPeriod。
- Produces: DeadlineEventKind、DeadlineEvent、EventTimeline::from_result、stable event ordering and read-only accessors.

- [ ] Step 1: Write the failing timeline test

Calculate a three-calendar-day deadline and assert the first timeline event is Start and the final event is Complete.

- [ ] Step 2: Run RED

Run moon test --deny-warn. Expected: missing event and timeline APIs.

- [ ] Step 3: Implement event construction and ordering

Use explicit priority for same-day events: start, suspension/resume, stage completion, final completion. Copy arrays at API boundaries and include source notes and date deltas.

- [ ] Step 4: Add plan and error timeline tests

Cover same-day ordering, stage labels, suspension events, failed-stage markers, empty timelines, and conversion from existing calculation steps.

- [ ] Step 5: Run and commit

Run moon test --deny-warn.
git add timeline_types.mbt timeline_logic.mbt timeline_test.mbt deadline_engine.mbt plan_engine.mbt
git commit -m "feat: add auditable deadline timelines"

### Task 6: Report rendering

Files:
- Create: report_types.mbt
- Create: report_render.mbt
- Test: report_test.mbt
- Modify: README.md, docs/api.md, docs/calendar-data.md

Interfaces:
- Consumes: DeadlineResult、PlanResult、EventTimeline、CalendarVersion。
- Produces: DeadlineReport::from_result、render_text、render_table、render_key_value and stable warning/error output.

- [ ] Step 1: Write the failing renderer test

Build a report from a sample plan, then assert key-value output contains final_date=2026-08-14 and the stage.notice label.

- [ ] Step 2: Run RED

Run moon test --deny-warn. Expected: missing report APIs.

- [ ] Step 3: Implement deterministic renderers

Render fields in a fixed order with ISO dates, explicit none values, escaped labels, and no locale-dependent formatting. Errors render a type and message without a false final date.

- [ ] Step 4: Document public APIs and boundaries

Add examples for report generation, versioned calendars, plans, and suspension limitations to README.md and docs/api.md; record source and fixture boundaries in docs/calendar-data.md.

- [ ] Step 5: Run and commit

Run moon test --deny-warn and git diff --check.
git add report_types.mbt report_render.mbt report_test.mbt README.md docs/api.md docs/calendar-data.md
git commit -m "feat: add deterministic deadline reports"

### Task 7: CLI plan and report workflows

Files:
- Create: cmd/deadline/cli_plan.mbt
- Create: cmd/deadline/cli_report.mbt
- Test: cmd/deadline/cli_plan_spec.mbt, cmd/deadline/cli_report_spec.mbt
- Modify: cmd/deadline/cli.mbt, cmd/deadline/main.mbt, cmd/deadline/moon.pkg

Interfaces:
- Consumes: plan, suspension, timeline and report APIs.
- Produces: --stage, --suspend, --resume, --report text|table|key-value, while preserving single-rule invocation.

- [ ] Step 1: Write the failing CLI spec

Parse two stage arguments notice:business-days:1 and response:calendar-days:3 plus report table. Assert two stages and ReportMode::Table.

- [ ] Step 2: Run RED

Run moon test --target native --deny-warn. Expected: missing stage and report parser fields.

- [ ] Step 3: Implement parser and render dispatch

Parse each --stage label:rule independently, reject malformed labels/rules with usage text, collect suspension periods without silent deduplication, and dispatch all rendering through DeadlineReport.

- [ ] Step 4: Add smoke and failure tests

Test successful two-stage table output, key-value output, invalid stage, invalid suspension range, help, and non-zero invalid-input exit code.

- [ ] Step 5: Run and commit

Run moon test --target native --deny-warn.
Run moon run cmd/deadline -- --start 2026-08-07 --stage notice:business-days:1 --stage response:calendar-days:3 --report table.
git add cmd/deadline
git commit -m "feat: extend deadline CLI workflows"

### Task 8: Scale, documentation, and final verification

Files:
- Modify: README.md, docs/api.md, docs/calendar-data.md, docs/submission.md, CHANGELOG.md, progress.md, task_plan.md
- Modify: .github/workflows/ci.yml only if a new CLI smoke command is needed

- [ ] Step 1: Add data-driven and boundary tests

Add behavior-focused cases for leap years, month ends, weekend policies, calendar versions, stage transitions, suspension normalization, timeline ordering, and all report modes. Avoid duplicate assertions.

- [ ] Step 2: Measure effective source scale

Run this PowerShell command. Expected result is 4,000–4,400 lines, excluding .mbti:

  $files = rg --files -g '*.mbt'
  ($files | ForEach-Object { Get-Content -Encoding utf8 $_ }).Count

- [ ] Step 3: Run the complete local gate

Run moon fmt; moon check --target all --deny-warn; moon test --target all --deny-warn; moon build --target all; moon info; git diff --exit-code; git diff --check. Expected exit code 0 and no generated-file or formatting diff.

- [ ] Step 4: Update release and audit docs

Record the new API surface, source scale, test counts, toolchain caveat, and remote commit identity. Do not claim fmt/info --deny-warn support where the installed toolchain rejects those flags.

- [ ] Step 5: Push and verify both remotes

Push main to GitHub and GitLink; preserve GitLink's unified master pointer. Verify both remote refs resolve to the same final SHA, GitHub contributors contain only chyppi, and GitLink branch pages show identical main/master history.

- [ ] Step 6: Wait for CI and commit the final audit

Run gh run list --repo chyppi/moonbit-deadline --limit 1 --json databaseId --jq .[0].databaseId, then run gh run watch with that numeric database ID and --exit-status. Verify all three OS jobs, then update docs/submission.md and commit the final audit only after the run succeeds.
