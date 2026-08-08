///|
fn required_date(text : String) -> Date {
  match Date::parse(text) {
    Ok(date) => date
    Err(_) => panic()
  }
}

///| Create a calendar from the State Council's published 2026 holiday plan.

///|
/// The date list is intentionally explicit so callers can replace it with
/// their own jurisdiction, court, or contract calendar without changing the
/// deadline engine.
pub fn Calendar::china_2026() -> Calendar {
  let version = CalendarVersion::new(
    name="china-national-2026",
    region="China",
    version="2025-11-04",
    source=CalendarSource::new(
      name="Beijing government policy page",
      url="https://www.beijing.gov.cn/gate/big5/www.beijing.gov.cn/zhengce/zhengcefagui/202511/t20251104_4258873.html",
    ),
    valid_from=required_date("2026-01-01"),
    valid_to=required_date("2026-12-31"),
  )
  match version {
    Ok(version) =>
      Calendar::new(
        name="china-national-2026",
        version="2025-11-04",
        weekend=WeekendPolicy::saturday_sunday(),
        holidays=[
          required_date("2026-01-01"),
          required_date("2026-01-02"),
          required_date("2026-01-03"),
          required_date("2026-02-15"),
          required_date("2026-02-16"),
          required_date("2026-02-17"),
          required_date("2026-02-18"),
          required_date("2026-02-19"),
          required_date("2026-02-20"),
          required_date("2026-02-21"),
          required_date("2026-02-22"),
          required_date("2026-02-23"),
          required_date("2026-04-04"),
          required_date("2026-04-05"),
          required_date("2026-04-06"),
          required_date("2026-05-01"),
          required_date("2026-05-02"),
          required_date("2026-05-03"),
          required_date("2026-05-04"),
          required_date("2026-05-05"),
          required_date("2026-06-19"),
          required_date("2026-06-20"),
          required_date("2026-06-21"),
          required_date("2026-09-25"),
          required_date("2026-09-26"),
          required_date("2026-09-27"),
          required_date("2026-10-01"),
          required_date("2026-10-02"),
          required_date("2026-10-03"),
          required_date("2026-10-04"),
          required_date("2026-10-05"),
          required_date("2026-10-06"),
          required_date("2026-10-07"),
        ],
        extra_workdays=[
          required_date("2026-01-04"),
          required_date("2026-02-14"),
          required_date("2026-02-28"),
          required_date("2026-05-09"),
          required_date("2026-09-20"),
          required_date("2026-10-10"),
        ],
      ).with_version(version)
    Err(_) => panic()
  }
}
