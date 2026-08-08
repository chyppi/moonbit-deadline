# moonbit-deadline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use the MoonBit agent guide and test-driven development workflow to implement this plan task-by-task.

**Goal:** Build and publish a maintainable MoonBit legal-deadline library and CLI with injectable calendars, reproducible tests, CI, and competition-ready repository evidence.

**Architecture:** Keep a single public root package for `Date`, `Calendar`, `DateRule`, `Deadline`, and result types. Split implementation into cohesive `.mbt` files and keep CLI parsing under `cmd/deadline`; inject calendar data rather than embedding legal conclusions in the engine.

**Tech Stack:** MoonBit 0.10.4 currently installed locally, `moon.mod`/`moon.pkg`, native/wasm/js-compatible pure MoonBit code, GitHub Actions, Mooncakes metadata, Markdown documentation, Apache-2.0.

## Global Constraints

- Core behavior must be implemented primarily in MoonBit.
- The reference effective-code scale is 4,000–10,000 lines; code must grow through real functionality, tests, docs, and examples rather than filler.
- The project must avoid high-overlap mature MoonBit packages; it must remain distinct from generic date/time, Cron/RRULE, iCalendar, and traditional-calendar packages.
- All public behavior needs tests or executable documentation.
- CI must run formatting, check, tests, generated interface checks, and coverage on supported platforms.
- Before completion run `moon fmt --deny-warn`, `moon info --deny-warn`, `moon check --deny-warn`, `moon test --deny-warn`, and a build.
- Keep only the user's real account as commit author; never add bot or virtual contributors.
- Never place GitLink credentials in files, remotes, scripts, logs, or commit messages.

## File Map

- `moon.mod`, root `moon.pkg`: module identity, metadata, and public package configuration.
- `src/date_types.mbt`, `src/date_parse.mbt`, `src/date_arithmetic.mbt`: date model and Gregorian arithmetic.
- `src/calendar_types.mbt`, `src/calendar_logic.mbt`: injectable calendars and business-day lookup.
- `src/rule_types.mbt`, `src/deadline_types.mbt`, `src/deadline_engine.mbt`: public deadline model, rule evaluation, adjustment trace.
- `src/date_test.mbt`, `src/calendar_test.mbt`, `src/deadline_test.mbt`: black-box behavior tests.
- `examples/sample_calendar.mbt`: clearly labeled demonstration calendar.
- `cmd/deadline/main.mbt`, `cmd/deadline/moon.pkg`: runnable CLI.
- `README.md`, `README.mbt.md`, `docs/api.md`, `docs/calendar-data.md`, `docs/submission.md`, `CHANGELOG.md`, `LICENSE`: user-facing and competition evidence.
- `.github/workflows/check.yml`: cross-platform CI and generated-file cleanliness checks.

---

### Task 1: Establish MoonBit module metadata

**Files:** Create `moon.mod`, `moon.pkg`, `.gitignore`.

**Interfaces:** Produces a compilable empty root package and module name chosen after checking the authenticated GitHub owner; no production API yet.

- [ ] Create the module with the exact owner/name accepted by the local MoonBit toolchain.
- [ ] Add metadata for version `0.1.0`, Apache-2.0, and keywords describing legal deadlines, calendars, business days, and MoonBit; set repository URLs once the final public remotes exist.
- [ ] Run `moon check` and `moon info` on the empty package.
- [ ] Commit as `chore: initialize MoonBit module` using the authenticated user's author identity.

### Task 2: Define failing tests for Date

**Files:** Create `src/date_test.mbt`.

**Interfaces:** Tests describe `Date::new`, parsing, formatting, comparison, `add_days`, `add_months`, and `weekday` without depending on implementation details.

- [ ] Add tests for `2024-02-29`, invalid `2023-02-29`, `2026-01-31 + 1 month = 2026-02-28`, crossing year boundaries, and Monday/ Sunday weekday values.
- [ ] Add a test that parsing and formatting `YYYY-MM-DD` round trips.
- [ ] Run `moon test` and record the expected missing-symbol/compiler failure in `progress.md`.
- [ ] Commit as `test: specify Gregorian date behavior`.

### Task 3: Implement Date and verify green

**Files:** Create `src/date_types.mbt`, `src/date_parse.mbt`, `src/date_arithmetic.mbt`.

**Interfaces:** Implements the Date API required by Task 2 with explicit validation and deterministic Gregorian arithmetic.

- [ ] Implement year/month/day validation and `DateError` values.
- [ ] Implement leap-year and days-in-month helpers, serial-day conversion, inverse conversion, weekday, ISO parsing, and formatting.
- [ ] Implement month/year clamping and day addition without time-zone dependencies.
- [ ] Run targeted date tests, then `moon check --deny-warn` and `moon fmt`.
- [ ] Commit as `feat: add Gregorian date primitives`.

### Task 4: Define failing tests for Calendar

**Files:** Create `src/calendar_test.mbt`.

**Interfaces:** Tests define `Calendar::new`, `is_business_day`, `next_business_day`, and `previous_business_day` behavior.

- [ ] Add tests for Saturday/Sunday weekend exclusion, holiday exclusion, extra-workday override, and searching across consecutive holidays.
- [ ] Add a test proving override precedence: extra workday beats weekend; holiday beats ordinary weekday.
- [ ] Run the tests and confirm failure because Calendar symbols do not exist.
- [ ] Commit as `test: specify injectable business calendars`.

### Task 5: Implement Calendar and sample data

**Files:** Create `src/calendar_types.mbt`, `src/calendar_logic.mbt`, `examples/sample_calendar.mbt`.

**Interfaces:** Produces `Calendar`, `WeekendPolicy`, and deterministic business-day methods; exports a clearly labeled sample calendar constructor.

- [ ] Implement calendar construction with sorted/normalized holiday and extra-workday arrays.
- [ ] Implement business-day precedence and bounded forward/backward search with an explicit error for impossible search limits.
- [ ] Add a small 2026 demonstration calendar with comments identifying every date as sample data, not legal advice or a complete official schedule.
- [ ] Run calendar tests, format, check, and info generation.
- [ ] Commit as `feat: add injectable business calendars`.

### Task 6: Define failing tests for rules and deadline evaluation

**Files:** Extend `src/deadline_test.mbt`.

**Interfaces:** Tests define `DateRule`, `StartDateRule`, `ExtensionPolicy`, `Deadline`, `DeadlineResult`, and `CalculationStep` semantics.

- [ ] Add tests for included/excluded start dates with calendar days.
- [ ] Add tests for business-day counting across weekends and holidays.
- [ ] Add tests for Following, ModifiedFollowing, Preceding, and NoExtension.
- [ ] Add tests for sequence rules and stable explanation steps.
- [ ] Run `moon test` and verify the failure is due to absent rule/deadline API.
- [ ] Commit as `test: specify deadline rules and adjustments`.

### Task 7: Implement public rule types and engine

**Files:** Create `src/rule_types.mbt`, `src/deadline_types.mbt`, `src/deadline_engine.mbt`.

**Interfaces:** Implements the approved public API and returns structured errors/results rather than hiding invalid input.

- [ ] Implement rule validation, start-date handling, and sequence evaluation.
- [ ] Implement natural-day, business-day, week, month, and year calculations with the semantics in the design document.
- [ ] Implement extension strategies and record each step in order.
- [ ] Implement `DeadlineResult::explain` from structured steps, keeping formatting outside the calculation logic where practical.
- [ ] Run targeted tests, full tests, `moon check --deny-warn`, and `moon info --deny-warn`.
- [ ] Commit as `feat: implement deadline calculation engine`.

### Task 8: Add CLI parser and executable example

**Files:** Create `cmd/deadline/moon.pkg`, `cmd/deadline/main.mbt`.

**Interfaces:** CLI accepts `--start`, `--rule`, optional `--exclude-start`, `--calendar`, `--extension`, and `--explain`; it prints result fields and returns nonzero on invalid input.

- [ ] Add parser tests for supported rule spellings and invalid arguments in the nearest testable package.
- [ ] Implement argument parsing without hiding errors or panicking on missing values.
- [ ] Wire the sample calendar and root package into a runnable command.
- [ ] Run the three design-document commands and execute at least three successful CLI examples plus invalid-input checks.
- [ ] Commit as `feat: add deadline calculation CLI`.

### Task 9: Add documentation and source/usage boundary

**Files:** Create/update `README.md`, `README.mbt.md`, `docs/api.md`, `docs/calendar-data.md`, `docs/submission.md`, `CHANGELOG.md`, `LICENSE`.

**Interfaces:** Documents install, API, CLI, examples, limitations, calendar provenance, Mooncakes name, competition checklist, and AI/source responsibility.

- [ ] Write an overview that differentiates the library from generic date/time, Cron/RRULE, iCalendar, and traditional-calendar packages found in Mooncakes.
- [ ] Document every public type, rule semantic, example calendar limitation, and extension-policy behavior.
- [ ] Add executable Markdown examples where supported and include a no-surprises command transcript for the CLI.
- [ ] Add Apache-2.0 text, changelog entries, and a one-page submission brief.
- [ ] Run documentation checks supported by the installed toolchain.
- [ ] Commit as `docs: document API examples and calendar provenance`.

### Task 10: Add CI and generated-interface gates

**Files:** Create `.github/workflows/check.yml`, update `.gitignore` and package metadata as needed.

**Interfaces:** CI runs on Ubuntu, macOS, and Windows; checks formatting, warnings, tests, build, generated interface cleanliness, and coverage where supported.

- [ ] Adapt the MoonBit community workflow template to this pure MoonBit project.
- [ ] Include `moon version --all`, `moon update`, `moon fmt --check` or equivalent deny-warn formatting gate, `moon check --deny-warn`, `moon info --deny-warn`, `git diff --exit-code`, `moon test --deny-warn`, and coverage reporting if available.
- [ ] Keep the workflow free of OpenSSL/FFI setup that this project does not need.
- [ ] Run the same commands locally and check YAML for an uncommitted generated-file diff.
- [ ] Commit as `ci: add cross-platform MoonBit checks`.

### Task 11: Scale with meaningful domain modules and tests

**Files:** Add focused source/test files only where a real behavior gap is identified; update docs for each new public behavior.

**Interfaces:** Expand coverage to multiple calendar data versions, rule composition, trace rendering, parser diagnostics, and boundary cases without adding duplicate filler.

- [ ] Measure effective MoonBit code and test count.
- [ ] Add real reusable abstractions only for discovered needs, such as calendar normalization, trace formatting, rule parser diagnostics, or data validation.
- [ ] Add regression tests before each behavior change and run the full suite after each change.
- [ ] Commit each coherent expansion separately; do not batch unrelated changes.

### Task 12: Release preparation and repository evidence

**Files:** Update `moon.mod`, README, `CHANGELOG.md`, `docs/submission.md`, `.github/workflows/publish.yml` only if supported by the official template.

**Interfaces:** Repository is ready for Mooncakes publication and competition review.

- [ ] Set final module/repository URLs and version.
- [ ] Regenerate `pkg.generated.mbti` using `moon info`; never edit it directly.
- [ ] Run the complete local verification matrix, capture results in `progress.md`, and inspect `git diff`.
- [ ] Ensure at least 11 meaningful commits exist and all commits use the one authenticated user identity.
- [ ] Commit as `release: prepare mooncakes publication`.

### Task 13: Authenticated GitHub and GitLink delivery

**Files:** No source changes unless remote-specific metadata is required.

**Interfaces:** Public GitHub and GitLink repositories point to the same verified commit and default branch.

- [ ] Run `gh auth status` and `gh api user --jq .login`; use only that active identity.
- [ ] Create the GitHub repository through `gh`, set the default branch explicitly, add the remote without embedded credentials, and push.
- [ ] Create the GitLink repository through its authenticated UI/CLI path using the user-provided account; never echo or persist the password.
- [ ] Push the exact commit set, then verify repository visibility, default branch, README, LICENSE, workflow, commit count, author identity, and source-scale report.
- [ ] Do not create Issues, PRs, bot commits, or synthetic contributors unless the user explicitly asks for them.

### Task 14: Final OSC2026 self-audit

**Files:** Update `docs/submission.md`, `progress.md`, and `findings.md` with evidence only.

**Interfaces:** A concise audit report maps every official requirement to a repository path and command result.

- [ ] Check structure, README, license, history, default branch, MoonBit source scale, source attribution, CI, tests, build, generated files, and public links.
- [ ] Record any limitation honestly, especially sample calendar coverage and exact toolchain version.
- [ ] Request code review on the final commit range before claiming completion.
- [ ] Run all fresh verification commands again after review fixes.

## Implementation status update

The implementation uses the repository root as the public MoonBit package rather than a `src/` directory. The current tree includes the root date/calendar/deadline modules, `sample_calendar.mbt`, `cmd/deadline`, `.github/workflows/ci.yml`, README, MIT license, changelog and contribution guide. The license is MIT, matching `moon.mod` and the repository file.

The installed MoonBit toolchain is `moon 0.1.20260713` / `moonc 0.10.4`. `moon check/test --deny-warn` pass; this toolchain rejects `moon fmt/info --deny-warn`, so CI uses `moon fmt` and `moon info` followed by `git diff --exit-code`, matching the official community workflow's generated-file gate.
