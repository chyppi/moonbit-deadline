///|
test "calendar catalog can find its standard entry" {
  let catalog = CalendarCatalog::new().add(Calendar::standard()).unwrap()
  inspect(
    catalog.find("standard", "builtin").unwrap().name(),
    content="standard",
  )
}

///|
test "date window intersection keeps shared endpoints" {
  let one = DeadlineWindow::new(
    start=Date::parse("2026-08-01").unwrap(),
    end=Date::parse("2026-08-03").unwrap(),
  ).unwrap()
  let two = DeadlineWindow::new(
    start=Date::parse("2026-08-03").unwrap(),
    end=Date::parse("2026-08-04").unwrap(),
  ).unwrap()
  inspect(one.intersection(two).unwrap().calendar_days(), content="1")
  inspect(one.intersects(two), content="true")
}

///|
test "rule parser rejects an empty string" {
  match DateRule::parse("") {
    Err(RuleInvalidFormat) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}
