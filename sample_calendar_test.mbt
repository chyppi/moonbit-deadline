///|
test "china 2026 calendar includes published holidays" {
  let calendar = Calendar::china_2026()
  inspect(
    calendar.is_business_day(Date::parse("2026-05-01").unwrap()),
    content="false",
  )
  inspect(
    calendar.is_business_day(Date::parse("2026-05-09").unwrap()),
    content="true",
  )
}

///|
test "china 2026 calendar keeps ordinary weekdays open" {
  inspect(
    Calendar::china_2026().is_business_day(Date::parse("2026-05-08").unwrap()),
    content="true",
  )
}

///|
test "china 2026 calendar exposes official metadata" {
  let calendar = Calendar::china_2026()
  inspect(calendar.version(), content="2025-11-04")
  inspect(calendar.region(), content="China")
  inspect(
    calendar.source().url(),
    content="https://www.beijing.gov.cn/gate/big5/www.beijing.gov.cn/zhengce/zhengcefagui/202511/t20251104_4258873.html",
  )
}
