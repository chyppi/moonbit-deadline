///|
test "calendar excludes Saturday and Sunday" {
  let calendar = Calendar::standard()
  inspect(
    calendar.is_business_day(Date::parse("2026-08-08").unwrap()),
    content="false",
  )
  inspect(
    calendar.is_business_day(Date::parse("2026-08-10").unwrap()),
    content="true",
  )
}

///|
test "calendar holidays override ordinary weekdays" {
  let holiday = Date::parse("2026-08-10").unwrap()
  let calendar = Calendar::new(
    name="demo",
    version="2026.1",
    weekend=WeekendPolicy::saturday_sunday(),
    holidays=[holiday],
    extra_workdays=[],
  )
  inspect(calendar.is_business_day(holiday), content="false")
}

///|
test "calendar extra workdays override the weekend" {
  let workday = Date::parse("2026-08-08").unwrap()
  let calendar = Calendar::new(
    name="demo",
    version="2026.1",
    weekend=WeekendPolicy::saturday_sunday(),
    holidays=[],
    extra_workdays=[workday],
  )
  inspect(calendar.is_business_day(workday), content="true")
}

///|
test "calendar finds the next business day across a weekend and holiday" {
  let holiday = Date::parse("2026-08-10").unwrap()
  let calendar = Calendar::new(
    name="demo",
    version="2026.1",
    weekend=WeekendPolicy::saturday_sunday(),
    holidays=[holiday],
    extra_workdays=[],
  )
  match calendar.next_business_day(Date::parse("2026-08-08").unwrap()) {
    Ok(date) => inspect(date.to_string(), content="2026-08-11")
    Err(_) => inspect(false, content="true")
  }
}

///|
test "calendar can advance a long running business-day rule" {
  match
    Calendar::standard().advance_business_days(
      Date::parse("2026-01-01").unwrap(),
      3000,
    ) {
    Ok(date) => inspect(date.to_string().length() > 0, content="true")
    Err(_) => inspect(false, content="true")
  }
}

///|
test "calendar can include or exclude a business-day start" {
  let start = Date::parse("2026-08-07").unwrap()
  let calendar = Calendar::standard()
  inspect(
    calendar
    .advance_business_days(start, 1, include_start=true)
    .unwrap()
    .to_string(),
    content="2026-08-07",
  )
  inspect(
    calendar.advance_business_days(start, 1).unwrap().to_string(),
    content="2026-08-10",
  )
}
