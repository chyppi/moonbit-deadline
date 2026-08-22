# Local project checklist

This file records the local evidence prepared for the August 2026 MoonBit hackathon. It is an audit aid, not an official submission form.

| Check | Evidence | Local status |
|---|---|---|
| Public project identity | `moon.mod`, `README.md` | ready |
| Open-source license | `LICENSE`, `license = "MIT"` | ready |
| Core implementation | root `.mbt` modules and generated `pkg.generated.mbti` | ready |
| CLI and examples | `cmd/deadline`, `README.md` | ready |
| Tests | 273 tests across wasm, wasm-gc and js | verified locally |
| CI | `.github/workflows/ci.yml`, Ubuntu/macOS/Windows | ready |
| Calendar provenance | `sample_calendar.mbt`, `docs/calendar-data.md` | ready |
| Change traceability | `CHANGELOG.md`, `progress.md`, local audit report | ready |
| Mooncakes discoverability | `moon.mod` keywords and package metadata | prepared for a later release |

## Local evidence

- GitHub workflow definitions are in `.github/workflows/ci.yml` and `benchmark.yml`.
- The local acceptance evidence is in `docs/acceptance-local-report.md`.
- The current working tree has not been published from this local run.

## Scope differentiation

Mooncakes research covered `deadline`, `business-day`, `working-day`, `legal`, `holiday`, `date` and `calendar`. Existing matches were generic date/time packages, Cron/RRULE/iCalendar packages and traditional-calendar packages. No mature MoonBit package with the same legal-deadline plus injectable-business-calendar scope was found during the project survey.

## Toolchain note

The local toolchain reports `moon 0.1.20260814` and `moonc 0.10.8`. Portable wasm, wasm-gc and JS checks, tests and builds pass locally. Windows native compilation is currently blocked by the installed MinGW runtime header/toolchain combination; the CI matrix keeps native coverage on Unix and portable targets on Windows.
