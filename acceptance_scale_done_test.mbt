///|
test "calendar query version is returned for callers" {
  let calendar = Calendar::new(
    name="demo",
    version="2026",
    weekend=WeekendPolicy::saturday_sunday(),
    holidays=[],
    extra_workdays=[],
  )
  inspect(
    calendar.query(Date::parse("2026-08-03").unwrap()).calendar_version(),
    content="2026",
  )
}

///|
test "business day series includes a single weekday" {
  let date = Date::parse("2026-08-03").unwrap()
  let dates = BusinessDaySeries::new(
      calendar=Calendar::standard(),
      start=date,
      end=date,
    )
    .unwrap()
    .collect()
  inspect(dates.length(), content="1")
  inspect(dates[0].to_string(), content="2026-08-03")
}

///|
test "forecast result get returns an exact requested point" {
  let result = DeadlineForecast::new(
      start=Date::parse("2026-08-03").unwrap(),
      unit=ForecastUnit::calendar_days(),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .calculate([2])
    .unwrap()
  inspect(result.get(2).unwrap().to_string(), content="2026-08-05")
}

///|
test "deadline record status is pending before due date" {
  let result = Deadline::new(
      start_date=Date::parse("2026-08-03").unwrap(),
      rule=DateRule::calendar_days(2),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .calculate()
    .unwrap()
  let record = DeadlineRecord::new("pending", result)
  inspect(
    record.status(Date::parse("2026-08-04").unwrap()).to_string(),
    content="pending",
  )
}
