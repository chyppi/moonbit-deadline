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
