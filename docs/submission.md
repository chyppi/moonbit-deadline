# OSC2026 submission self-check

This file records the local evidence prepared for the August 2026 MoonBit hackathon. It is an audit aid, not an official submission form.

| Check | Evidence | Local status |
|---|---|---|
| Public project identity | `moon.mod`, `README.md` | ready |
| Open-source license | `LICENSE`, `license = "MIT"` | ready |
| Core implementation | root `.mbt` modules and generated `pkg.generated.mbti` | ready |
| CLI and examples | `cmd/deadline`, `README.md` | ready |
| Tests | 27 tests across wasm, wasm-gc, js and native | verified locally |
| CI | `.github/workflows/ci.yml`, Ubuntu/macOS/Windows | ready |
| Calendar provenance | `sample_calendar.mbt`, `docs/calendar-data.md` | ready |
| Change traceability | `CHANGELOG.md`, focused commits, `progress.md` | ready |
| Mooncakes discoverability | `moon.mod` keywords and package metadata | prepared; publication requires credentials |
| Single contributor identity | Git history is authored by one configured user | verify after remote push |
| Default branch and public remotes | GitHub/GitLink repository settings | pending remote creation |

## Scope differentiation

Mooncakes research covered `deadline`, `business-day`, `working-day`, `legal`, `holiday`, `date` and `calendar`. Existing matches were generic date/time packages, Cron/RRULE/iCalendar packages and traditional-calendar packages. No mature MoonBit package with the same legal-deadline plus injectable-business-calendar scope was found during the project survey.

## Toolchain note

The local toolchain reports `moon 0.1.20260713` and `moonc 0.10.4`. It accepts `moon check/test --deny-warn` but rejects `moon fmt/info --deny-warn`; the supported equivalent is `moon fmt`/`moon info` followed by `git diff --exit-code`. This limitation is recorded rather than hidden.
