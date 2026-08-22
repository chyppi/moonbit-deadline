///|
fn batch_date(text : String) -> Date {
  Date::parse(text).unwrap()
}

///|
fn batch_event_context() -> EventContext {
  EventContext::new()
  .insert("filed", EventSpec::fixed(batch_date("2026-08-07")))
  .unwrap()
  .insert("reviewed", EventSpec::fixed(batch_date("2026-08-10")))
  .unwrap()
}

///|
fn batch_task(name : String, event : String) -> BatchTask {
  BatchTask::from_event(
    name~,
    event~,
    rule=DateRule::business_days(1),
    start_rule=StartDateRule::exclude(),
    calendar=Calendar::standard(),
    extension=ExtensionPolicy::no_extension(),
  )
}

///|
test "batch deadlines calculate in dependency order" {
  let batch = BatchDeadline::new()
    .add(batch_task("notice", "filed"))
    .unwrap()
    .add(
      BatchTask::after(
        name="appeal",
        dependency="notice",
        rule=DateRule::calendar_days(3),
        start_rule=StartDateRule::exclude(),
        calendar=Calendar::standard(),
        extension=ExtensionPolicy::no_extension(),
      ),
    )
    .unwrap()
  let result = batch.calculate(batch_event_context()).unwrap()
  inspect(result.ordered()[0], content="notice")
  inspect(result.ordered()[1], content="appeal")
  inspect(
    result.get("notice").unwrap().adjusted_date().to_string(),
    content="2026-08-10",
  )
  inspect(
    result.get("appeal").unwrap().adjusted_date().to_string(),
    content="2026-08-13",
  )
}

///|
test "batch deadlines reject duplicate names and missing dependencies" {
  let duplicate = BatchDeadline::new()
    .add(batch_task("notice", "filed"))
    .unwrap()
  match duplicate.add(batch_task("notice", "reviewed")) {
    Err(BatchDuplicate(name)) => inspect(name, content="notice")
    _ => inspect(false, content="true")
  }
  let missing = BatchDeadline::new()
    .add(
      BatchTask::after(
        name="appeal",
        dependency="unknown",
        rule=DateRule::calendar_days(1),
        start_rule=StartDateRule::exclude(),
        calendar=Calendar::standard(),
        extension=ExtensionPolicy::no_extension(),
      ),
    )
    .unwrap()
  match missing.calculate(batch_event_context()) {
    Err(BatchMissingDependency(name)) => inspect(name, content="unknown")
    _ => inspect(false, content="true")
  }
}

///|
test "batch deadlines report cycles and empty plans" {
  let cycle = BatchDeadline::new()
    .add(
      BatchTask::after(
        name="a",
        dependency="b",
        rule=DateRule::calendar_days(1),
        start_rule=StartDateRule::exclude(),
        calendar=Calendar::standard(),
        extension=ExtensionPolicy::no_extension(),
      ),
    )
    .unwrap()
    .add(
      BatchTask::after(
        name="b",
        dependency="a",
        rule=DateRule::calendar_days(1),
        start_rule=StartDateRule::exclude(),
        calendar=Calendar::standard(),
        extension=ExtensionPolicy::no_extension(),
      ),
    )
    .unwrap()
  match cycle.calculate(batch_event_context()) {
    Err(BatchCycle(name)) => inspect(name, content="a")
    _ => inspect(false, content="true")
  }
  match BatchDeadline::new().calculate(batch_event_context()) {
    Err(BatchEmpty) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}
