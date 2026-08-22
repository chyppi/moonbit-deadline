///|
test "deadline status pending text is stable" {
  let result = Deadline::new(
      start_date=Date::parse("2026-08-03").unwrap(),
      rule=DateRule::calendar_days(2),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .calculate()
    .unwrap()
  inspect(
    result.status(Date::parse("2026-08-04").unwrap()).to_string(),
    content="pending",
  )
}

///|
test "calendar standard has no holiday dates in a weekday" {
  let date = Date::parse("2026-08-03").unwrap()
  inspect(
    Calendar::standard()
    .dates_between(start=date, end=date, filter=CalendarDateFilter::holidays())
    .unwrap()
    .length(),
    content="0",
  )
}
