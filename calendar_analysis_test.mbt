///|
test "calendar summary counts business days and closures" {
  let calendar = Calendar::new(
    name="demo",
    version="1",
    weekend=WeekendPolicy::saturday_sunday(),
    holidays=[Date::parse("2026-08-10").unwrap()],
    extra_workdays=[Date::parse("2026-08-08").unwrap()],
  )
  let summary = calendar
    .summarize(
      start=Date::parse("2026-08-07").unwrap(),
      end=Date::parse("2026-08-10").unwrap(),
    )
    .unwrap()
  inspect(summary.total_days(), content="4")
  inspect(summary.business_days(), content="2")
  inspect(summary.holiday_days(), content="1")
  inspect(summary.weekend_days(), content="1")
  inspect(summary.extra_workdays(), content="1")
}

///|
test "calendar summary rejects a reversed interval" {
  match
    Calendar::standard().summarize(
      start=Date::parse("2026-08-10").unwrap(),
      end=Date::parse("2026-08-01").unwrap(),
    ) {
    Err(CalendarInvalidRange) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}

///|
test "calendar can find the next and previous business days in a window" {
  let calendar = Calendar::new(
    name="demo",
    version="1",
    weekend=WeekendPolicy::saturday_sunday(),
    holidays=[Date::parse("2026-08-10").unwrap()],
    extra_workdays=[],
  )
  let summary = calendar
    .summarize(
      start=Date::parse("2026-08-07").unwrap(),
      end=Date::parse("2026-08-11").unwrap(),
    )
    .unwrap()
  inspect(
    summary.first_business_day().unwrap().to_string(),
    content="2026-08-07",
  )
  inspect(
    summary.last_business_day().unwrap().to_string(),
    content="2026-08-11",
  )
}
