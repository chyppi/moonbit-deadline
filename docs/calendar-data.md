# Calendar data policy

The calculation engine does not claim that one holiday table is universally correct. A calendar is a versioned input with a named jurisdiction or contract context.

`Calendar::china_2026()` is the repository's reproducible fixture. Its `version` is `2025-11-04`, the publication date of the State Council notice. The holiday ranges and make-up workdays are copied into explicit `Date` values so tests remain deterministic. The source is the [Beijing government policy page reproducing the State Council notice](https://www.beijing.gov.cn/gate/big5/www.beijing.gov.cn/zhengce/zhengcefagui/202511/t20251104_4258873.html).

The fixture is not a complete legal database. Regional holidays, court closure days, industry schedules, contract-defined working days and later amendments must be supplied by the caller:

```moonbit
let calendar = Calendar::new(
  name="contract-a",
  version="2026.1",
  weekend=WeekendPolicy::saturday_sunday(),
  holidays=[Date::parse("2026-10-02").unwrap()],
  extra_workdays=[],
)
```

When updating a fixture, change its version, record the source URL and add a regression test for both a closed date and an override workday.
