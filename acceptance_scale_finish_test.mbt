///|
test "date range single day business count is exact" {
  let date = Date::parse("2026-08-03").unwrap()
  let range = DateRange::closed(start=date, end=date).unwrap()
  inspect(range.business_days(Calendar::standard()), content="1")
  inspect(range.contains(date), content="true")
}

///|
test "deadline zero calendar count keeps a stable audit trail" {
  let result = Deadline::new(
      start_date=Date::parse("2026-08-03").unwrap(),
      rule=DateRule::calendar_days(0),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .calculate()
    .unwrap()
  inspect(result.step_count(), content="3")
  inspect(result.original_date().to_string(), content="2026-08-03")
}

///|
test "timeline ratio rounds a two-of-three business window" {
  let timeline = CalendarTimeline::between(
    calendar=Calendar::standard(),
    start=Date::parse("2026-08-03").unwrap(),
    end=Date::parse("2026-08-05").unwrap(),
  ).unwrap()
  inspect(timeline.business_day_ratio(), content="1.00")
  inspect(timeline.closure_count(), content="0")
}

///|
test "catalog names combine name and version deterministically" {
  let calendar = Calendar::new(
    name="registry",
    version="2026.08",
    weekend=WeekendPolicy::saturday_sunday(),
    holidays=[],
    extra_workdays=[],
  )
  inspect(
    CalendarCatalog::new().add(calendar).unwrap().names()[0],
    content="registry@2026.08",
  )
}

///|
test "business day cursor forward skips two closed days" {
  let cursor = BusinessDayCursor::new(
    date=Date::parse("2026-08-07").unwrap(),
    calendar=Calendar::standard(),
  )
  let dates = cursor.forward(2).unwrap()
  inspect(dates[0].to_string(), content="2026-08-10")
  inspect(dates[1].to_string(), content="2026-08-11")
}

///|
test "event deadline exposes the resolved start date" {
  let context = EventContext::new()
    .insert("start", EventSpec::fixed(Date::parse("2026-08-03").unwrap()))
    .unwrap()
  let result = EventDeadline::new(
      event="start",
      rule=DateRule::calendar_days(1),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .calculate(context)
    .unwrap()
  inspect(result.start_date().to_string(), content="2026-08-03")
  inspect(result.adjusted_date().to_string(), content="2026-08-04")
}
