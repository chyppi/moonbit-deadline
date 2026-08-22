///|
test "calendar timeline exposes daily classifications and csv output" {
  let timeline = CalendarTimeline::between(
    calendar=Calendar::standard(),
    start=Date::parse("2026-08-07").unwrap(),
    end=Date::parse("2026-08-10").unwrap(),
  ).unwrap()
  inspect(timeline.days().length(), content="4")
  inspect(timeline.business_days().length(), content="2")
  let csv = timeline.to_csv()
  inspect(csv.has_prefix("date,kind,calendar,version\n"), content="true")
  inspect(csv.contains("2026-08-08,weekend"), content="true")
}

///|
test "calendar timeline rejects reversed range and supports closures" {
  match
    CalendarTimeline::between(
      calendar=Calendar::standard(),
      start=Date::parse("2026-08-10").unwrap(),
      end=Date::parse("2026-08-07").unwrap(),
    ) {
    Err(TimelineReversed) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
  let timeline = CalendarTimeline::between(
    calendar=Calendar::new(
      name="demo",
      version="1",
      weekend=WeekendPolicy::saturday_sunday(),
      holidays=[Date::parse("2026-08-10").unwrap()],
      extra_workdays=[],
    ),
    start=Date::parse("2026-08-07").unwrap(),
    end=Date::parse("2026-08-10").unwrap(),
  ).unwrap()
  inspect(timeline.closures().length(), content="3")
}
