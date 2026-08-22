///|
fn event_date(text : String) -> Date {
  Date::parse(text).unwrap()
}

///|
test "event context resolves fixed and offset events" {
  let context = EventContext::new()
    .insert("filing", EventSpec::fixed(event_date("2026-02-27")))
    .unwrap()
    .insert("notice", EventSpec::after("filing", 3))
    .unwrap()
  inspect(context.resolve("notice").unwrap().to_string(), content="2026-03-02")
}

///|
test "event context reports a missing dependency" {
  let context = EventContext::new()
    .insert("notice", EventSpec::after("missing", 1))
    .unwrap()
  match context.resolve("notice") {
    Err(EventMissing(name)) => inspect(name, content="missing")
    _ => inspect(false, content="true")
  }
}

///|
test "event context reports cycles instead of recursing forever" {
  let context = EventContext::new()
    .insert("a", EventSpec::after("b", 1))
    .unwrap()
    .insert("b", EventSpec::after("a", 1))
    .unwrap()
  match context.resolve("a") {
    Err(EventCycle(name)) => inspect(name, content="a")
    _ => inspect(false, content="true")
  }
}

///|
test "event context rejects duplicate names and invalid offsets" {
  let context = EventContext::new()
    .insert("filing", EventSpec::fixed(event_date("2026-01-01")))
    .unwrap()
  match context.insert("filing", EventSpec::fixed(event_date("2026-01-02"))) {
    Err(EventDuplicate(name)) => inspect(name, content="filing")
    _ => inspect(false, content="true")
  }
  match context.insert("bad", EventSpec::after("filing", -1)) {
    Err(EventNegativeOffset(name)) => inspect(name, content="bad")
    _ => inspect(false, content="true")
  }
}

///|
test "event deadline reuses the regular deadline engine" {
  let context = EventContext::new()
    .insert("filed", EventSpec::fixed(event_date("2026-08-07")))
    .unwrap()
  let event_deadline = EventDeadline::new(
    event="filed",
    rule=DateRule::business_days(1),
    start_rule=StartDateRule::exclude(),
    calendar=Calendar::standard(),
    extension=ExtensionPolicy::no_extension(),
  )
  inspect(
    event_deadline.calculate(context).unwrap().adjusted_date().to_string(),
    content="2026-08-10",
  )
}
