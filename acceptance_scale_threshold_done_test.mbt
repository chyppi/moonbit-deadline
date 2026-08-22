///|
test "calendar query date and version form a stable record" {
  let date = Date::parse("2026-08-03").unwrap()
  let info = Calendar::standard().query(date)
  inspect(info.date().to_string(), content="2026-08-03")
  inspect(info.calendar_version(), content="builtin")
}

///|
test "deadline window calendar length is inclusive" {
  let window = DeadlineWindow::new(
    start=Date::parse("2026-08-03").unwrap(),
    end=Date::parse("2026-08-03").unwrap(),
  ).unwrap()
  inspect(window.calendar_days(), content="1")
}
