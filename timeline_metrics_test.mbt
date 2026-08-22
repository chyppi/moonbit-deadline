///|
test "timeline metrics summarize closures and render markdown" {
  let timeline = CalendarTimeline::between(
    calendar=Calendar::standard(),
    start=Date::parse("2026-08-07").unwrap(),
    end=Date::parse("2026-08-10").unwrap(),
  ).unwrap()
  inspect(timeline.closure_count(), content="2")
  inspect(timeline.business_day_ratio(), content="0.50")
  inspect(timeline.first().unwrap().date().to_string(), content="2026-08-07")
  inspect(timeline.last().unwrap().date().to_string(), content="2026-08-10")
  inspect(
    timeline.to_markdown().contains("| 2026-08-08 | weekend |"),
    content="true",
  )
}

///|
test "deadline result exposes stable metrics" {
  let result = Deadline::new(
      start_date=Date::parse("2026-08-07").unwrap(),
      rule=DateRule::calendar_days(2),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .calculate()
    .unwrap()
  inspect(result.step_count(), content="3")
  inspect(result.has_extension(), content="false")
  inspect(result.summary(), content="2026-08-07 -> 2026-08-09")
}
