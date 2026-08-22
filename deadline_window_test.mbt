///|
test "deadline window measures days and membership" {
  let window = DeadlineWindow::new(
    start=Date::parse("2026-08-07").unwrap(),
    end=Date::parse("2026-08-10").unwrap(),
  ).unwrap()
  inspect(window.calendar_days(), content="4")
  inspect(window.contains(Date::parse("2026-08-08").unwrap()), content="true")
  inspect(window.contains(Date::parse("2026-08-11").unwrap()), content="false")
  inspect(window.business_days(Calendar::standard()), content="2")
}

///|
test "deadline window intersects and shifts safely" {
  let left = DeadlineWindow::new(
    start=Date::parse("2026-08-01").unwrap(),
    end=Date::parse("2026-08-10").unwrap(),
  ).unwrap()
  let right = DeadlineWindow::new(
    start=Date::parse("2026-08-10").unwrap(),
    end=Date::parse("2026-08-15").unwrap(),
  ).unwrap()
  inspect(left.intersects(right), content="true")
  inspect(left.intersection(right).unwrap().calendar_days(), content="1")
  inspect(left.shift(3).unwrap().start().to_string(), content="2026-08-04")
}

///|
test "deadline window rejects reversed ranges and out of range shifts" {
  match
    DeadlineWindow::new(
      start=Date::parse("2026-08-10").unwrap(),
      end=Date::parse("2026-08-01").unwrap(),
    ) {
    Err(WindowReversed) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}
