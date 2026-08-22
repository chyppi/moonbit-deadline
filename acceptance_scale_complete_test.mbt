///|
test "deadline record result preserves adjusted date" {
  let result = Deadline::new(
      start_date=Date::parse("2026-08-03").unwrap(),
      rule=DateRule::calendar_days(1),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .calculate()
    .unwrap()
  let record = DeadlineRecord::new("id", result)
  inspect(record.result().adjusted_date().to_string(), content="2026-08-04")
}

///|
test "calendar timeline first and last are equal for one date" {
  let date = Date::parse("2026-08-03").unwrap()
  let timeline = CalendarTimeline::between(
    calendar=Calendar::standard(),
    start=date,
    end=date,
  ).unwrap()
  inspect(timeline.first().unwrap().date().to_string(), content="2026-08-03")
  inspect(timeline.last().unwrap().date().to_string(), content="2026-08-03")
}
