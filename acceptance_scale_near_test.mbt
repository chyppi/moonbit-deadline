///|
test "deadline window contains its shifted start" {
  let window = DeadlineWindow::new(
      start=Date::parse("2026-08-03").unwrap(),
      end=Date::parse("2026-08-05").unwrap(),
    )
    .unwrap()
    .shift(1)
    .unwrap()
  inspect(window.contains(Date::parse("2026-08-04").unwrap()), content="true")
  inspect(window.end().to_string(), content="2026-08-06")
}

///|
test "matrix same scenario duplicate is rejected" {
  let matrix = DeadlineMatrix::new(
      start=Date::parse("2026-08-03").unwrap(),
      rule=DateRule::calendar_days(1),
      start_rule=StartDateRule::exclude(),
      extension=ExtensionPolicy::no_extension(),
    )
    .add_calendar("same", Calendar::standard())
    .unwrap()
  match matrix.add_calendar("same", Calendar::standard()) {
    Err(MatrixDuplicate(name)) => inspect(name, content="same")
    _ => inspect(false, content="true")
  }
}
