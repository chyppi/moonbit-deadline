///|
test "deadline service validates and evaluates a request" {
  let request = DeadlineRequest::new(
    id="filing",
    start=Date::parse("2026-08-07").unwrap(),
    rule=DateRule::business_days(1),
    start_rule=StartDateRule::exclude(),
    calendar=Calendar::standard(),
    extension=ExtensionPolicy::no_extension(),
  )
  match DeadlineService::evaluate(request) {
    Ok(record) => inspect(record.id(), content="filing")
    Err(_) => inspect(false, content="true")
  }
}

///|
test "deadline service rejects empty ids and invalid rules" {
  let request = DeadlineRequest::new(
    id="",
    start=Date::parse("2026-08-07").unwrap(),
    rule=DateRule::calendar_days(-1),
    start_rule=StartDateRule::exclude(),
    calendar=Calendar::standard(),
    extension=ExtensionPolicy::no_extension(),
  )
  match DeadlineService::evaluate(request) {
    Err(ServiceInvalidId) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}

///|
test "deadline ledger finds due overdue and completed records" {
  let first = DeadlineService::evaluate(
    DeadlineRequest::new(
      id="first",
      start=Date::parse("2026-08-07").unwrap(),
      rule=DateRule::calendar_days(3),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    ),
  ).unwrap()
  let second = DeadlineService::evaluate(
    DeadlineRequest::new(
      id="second",
      start=Date::parse("2026-08-07").unwrap(),
      rule=DateRule::calendar_days(5),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    ),
  ).unwrap()
  let completed = first.complete(Date::parse("2026-08-10").unwrap()).unwrap()
  let ledger = DeadlineLedger::new()
    .add(completed)
    .unwrap()
    .add(second)
    .unwrap()
  inspect(
    ledger.completed(Date::parse("2026-08-20").unwrap()).length(),
    content="1",
  )
  inspect(
    ledger.overdue(Date::parse("2026-08-20").unwrap()).length(),
    content="1",
  )
  match ledger.find("second") {
    Some(_) => inspect(true, content="true")
    None => inspect(false, content="true")
  }
}

///|
test "deadline ledger rejects duplicate ids" {
  let request = DeadlineRequest::new(
    id="same",
    start=Date::parse("2026-08-07").unwrap(),
    rule=DateRule::calendar_days(1),
    start_rule=StartDateRule::exclude(),
    calendar=Calendar::standard(),
    extension=ExtensionPolicy::no_extension(),
  )
  let first = DeadlineService::evaluate(request).unwrap()
  let second = DeadlineService::evaluate(
    DeadlineRequest::new(
      id="same",
      start=Date::parse("2026-08-08").unwrap(),
      rule=DateRule::calendar_days(1),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    ),
  ).unwrap()
  match DeadlineLedger::new().add(first).unwrap().add(second) {
    Err(LedgerDuplicate(name)) => inspect(name, content="same")
    _ => inspect(false, content="true")
  }
}
