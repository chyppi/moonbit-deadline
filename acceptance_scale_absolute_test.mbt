///|
test "date range business count sees a weekend closure" {
  let range = DateRange::closed(
    start=Date::parse("2026-08-08").unwrap(),
    end=Date::parse("2026-08-09").unwrap(),
  ).unwrap()
  inspect(range.calendar_days(), content="2")
  inspect(range.business_days(Calendar::standard()), content="0")
}

///|
test "deadline result has no extension for a business completion" {
  let result = Deadline::new(
      start_date=Date::parse("2026-08-03").unwrap(),
      rule=DateRule::calendar_days(1),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::following(),
    )
    .calculate()
    .unwrap()
  inspect(result.has_extension(), content="false")
  inspect(result.adjusted_date().to_string(), content="2026-08-04")
}

///|
test "calendar filter holidays is empty on a plain workday" {
  let date = Date::parse("2026-08-03").unwrap()
  inspect(
    Calendar::standard()
    .dates_between(start=date, end=date, filter=CalendarDateFilter::holidays())
    .unwrap()
    .length(),
    content="0",
  )
}
