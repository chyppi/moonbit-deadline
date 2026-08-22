///|
test "calendar summary last business date is returned" {
  let calendar = Calendar::standard()
  let summary = calendar
    .summarize(
      start=Date::parse("2026-08-03").unwrap(),
      end=Date::parse("2026-08-04").unwrap(),
    )
    .unwrap()
  inspect(
    summary.last_business_day().unwrap().to_string(),
    content="2026-08-04",
  )
  inspect(summary.business_days(), content="2")
}

///|
test "event deadline result includes the event start in audit steps" {
  let context = EventContext::new()
    .insert("event", EventSpec::fixed(Date::parse("2026-08-03").unwrap()))
    .unwrap()
  let result = EventDeadline::new(
      event="event",
      rule=DateRule::calendar_days(0),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .calculate(context)
    .unwrap()
  inspect(result.steps()[0].note(), content="start date")
  inspect(result.steps().length(), content="3")
}
