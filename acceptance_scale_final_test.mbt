///|
test "calendar standard next business day preserves a weekday" {
  let date = Date::parse("2026-08-03").unwrap()
  inspect(
    Calendar::standard().next_business_day(date).unwrap().to_string(),
    content="2026-08-03",
  )
}

///|
test "deadline window shift preserves duration" {
  let window = DeadlineWindow::new(
    start=Date::parse("2026-08-03").unwrap(),
    end=Date::parse("2026-08-05").unwrap(),
  ).unwrap()
  let shifted = window.shift(10).unwrap()
  inspect(shifted.calendar_days(), content="3")
  inspect(shifted.start().to_string(), content="2026-08-13")
}

///|
test "matrix result get returns none for an absent calendar" {
  let result = DeadlineMatrix::new(
      start=Date::parse("2026-08-03").unwrap(),
      rule=DateRule::calendar_days(1),
      start_rule=StartDateRule::exclude(),
      extension=ExtensionPolicy::no_extension(),
    )
    .add_calendar("known", Calendar::standard())
    .unwrap()
    .calculate()
    .unwrap()
  match result.get("absent") {
    None => inspect(true, content="true")
    Some(_) => inspect(false, content="true")
  }
}

///|
test "audit report text includes adjusted date" {
  let calendar = Calendar::standard()
  let result = Deadline::new(
      start_date=Date::parse("2026-08-03").unwrap(),
      rule=DateRule::calendar_days(1),
      start_rule=StartDateRule::exclude(),
      calendar~,
      extension=ExtensionPolicy::no_extension(),
    )
    .calculate()
    .unwrap()
  inspect(
    AuditReport::from_result(result, calendar)
    .to_text()
    .contains("adjusted=2026-08-04"),
    content="true",
  )
}
