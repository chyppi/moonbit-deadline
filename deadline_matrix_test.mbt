///|
test "deadline matrix compares the same rule across calendars" {
  let standard = Calendar::standard()
  let holiday_calendar = Calendar::new(
    name="holiday",
    version="1",
    weekend=WeekendPolicy::saturday_sunday(),
    holidays=[Date::parse("2026-08-10").unwrap()],
    extra_workdays=[],
  )
  let matrix = DeadlineMatrix::new(
      start=Date::parse("2026-08-07").unwrap(),
      rule=DateRule::business_days(1),
      start_rule=StartDateRule::exclude(),
      extension=ExtensionPolicy::no_extension(),
    )
    .add_calendar("standard", standard)
    .unwrap()
    .add_calendar("holiday", holiday_calendar)
    .unwrap()
  let results = matrix.calculate().unwrap()
  inspect(results.ordered()[0], content="standard")
  inspect(
    results.get("standard").unwrap().adjusted_date().to_string(),
    content="2026-08-10",
  )
  inspect(
    results.get("holiday").unwrap().adjusted_date().to_string(),
    content="2026-08-11",
  )
  inspect(results.delta("standard", "holiday").unwrap(), content="1")
}

///|
test "deadline matrix rejects duplicates and empty scenarios" {
  let matrix = DeadlineMatrix::new(
      start=Date::parse("2026-08-07").unwrap(),
      rule=DateRule::calendar_days(1),
      start_rule=StartDateRule::exclude(),
      extension=ExtensionPolicy::no_extension(),
    )
    .add_calendar("standard", Calendar::standard())
    .unwrap()
  match matrix.add_calendar("standard", Calendar::standard()) {
    Err(MatrixDuplicate(name)) => inspect(name, content="standard")
    _ => inspect(false, content="true")
  }
  match
    DeadlineMatrix::new(
      start=Date::parse("2026-08-07").unwrap(),
      rule=DateRule::calendar_days(1),
      start_rule=StartDateRule::exclude(),
      extension=ExtensionPolicy::no_extension(),
    ).calculate() {
    Err(MatrixEmpty) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}
