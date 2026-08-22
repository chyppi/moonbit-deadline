///|
test "deadline status classifies pending due and overdue states" {
  let result = Deadline::new(
      start_date=Date::parse("2026-08-07").unwrap(),
      rule=DateRule::calendar_days(3),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .calculate()
    .unwrap()
  match result.status(Date::parse("2026-08-09").unwrap()) {
    Pending => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
  match result.status(Date::parse("2026-08-10").unwrap()) {
    DueToday => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
  match result.status(Date::parse("2026-08-11").unwrap()) {
    Overdue => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}

///|
test "deadline record changes to completed only after a receipt" {
  let result = Deadline::new(
      start_date=Date::parse("2026-08-07").unwrap(),
      rule=DateRule::calendar_days(1),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .calculate()
    .unwrap()
  let record = DeadlineRecord::new("filing", result)
  match record.status(Date::parse("2026-08-20").unwrap()) {
    Overdue => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
  let completed = record.complete(Date::parse("2026-08-12").unwrap()).unwrap()
  match completed.status(Date::parse("2026-08-20").unwrap()) {
    Completed => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}

///|
test "deadline record rejects completion after the evidence date" {
  let result = Deadline::new(
      start_date=Date::parse("2026-08-07").unwrap(),
      rule=DateRule::calendar_days(1),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .calculate()
    .unwrap()
  let record = DeadlineRecord::new("filing", result)
  match record.complete(Date::parse("2026-08-06").unwrap()) {
    Err(CompletionBeforeStart) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}
