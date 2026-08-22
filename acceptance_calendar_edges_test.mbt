///|
test "weekend policies classify their exact closure pairs" {
  let friday = Date::parse("2026-08-07").unwrap().weekday()
  let saturday = Date::parse("2026-08-08").unwrap().weekday()
  let sunday = Date::parse("2026-08-09").unwrap().weekday()
  inspect(WeekendPolicy::friday_saturday().is_weekend(friday), content="true")
  inspect(WeekendPolicy::friday_saturday().is_weekend(sunday), content="false")
  inspect(WeekendPolicy::saturday_sunday().is_weekend(saturday), content="true")
  inspect(WeekendPolicy::no_weekend().is_weekend(sunday), content="false")
}

///|
test "calendar holiday and extra workday precedence is explicit" {
  let date = Date::parse("2026-08-08").unwrap()
  let calendar = Calendar::new(
    name="demo",
    version="1",
    weekend=WeekendPolicy::saturday_sunday(),
    holidays=[date],
    extra_workdays=[date],
  )
  inspect(calendar.is_business_day(date), content="true")
  inspect(calendar.query(date).kind().to_string(), content="business-day")
}

///|
test "calendar standard metadata is stable" {
  let calendar = Calendar::standard()
  inspect(calendar.name(), content="standard")
  inspect(calendar.version(), content="builtin")
  inspect(calendar.region(), content="")
  inspect(calendar.source().name(), content="")
}

///|
test "calendar builder deduplicates repeated dates" {
  let date = Date::parse("2026-08-10").unwrap()
  let calendar = CalendarBuilder::new(
      name="demo",
      version="1",
      weekend=WeekendPolicy::saturday_sunday(),
    )
    .holiday(date)
    .holiday(date)
    .extra_workday(date)
    .extra_workday(date)
    .build()
    .unwrap()
  inspect(calendar.is_business_day(date), content="true")
  inspect(
    calendar
    .dates_between(start=date, end=date, filter=CalendarDateFilter::holidays())
    .unwrap()
    .length(),
    content="1",
  )
}

///|
test "calendar version rejects incomplete observed metadata" {
  match
    Calendar::standard().with_observed_holidays([
      Date::parse("2026-08-08").unwrap(),
    ]) {
    Err(MissingVersionMetadata) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}

///|
test "calendar navigation returns the anchor when it is a business day" {
  let date = Date::parse("2026-08-07").unwrap()
  let calendar = Calendar::standard()
  inspect(
    calendar.next_business_day(date).unwrap().to_string(),
    content="2026-08-07",
  )
  inspect(
    calendar.previous_business_day(date).unwrap().to_string(),
    content="2026-08-07",
  )
}

///|
test "calendar navigation fails at the supported date boundaries" {
  let calendar = Calendar::new(
    name="all-closed",
    version="1",
    weekend=WeekendPolicy::no_weekend(),
    holidays=[
      Date::parse("0001-01-01").unwrap(),
      Date::parse("9999-12-31").unwrap(),
    ],
    extra_workdays=[],
  )
  match calendar.previous_business_day(Date::parse("0001-01-01").unwrap()) {
    Err(DateOutOfRange) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
  let end = Date::parse("9999-12-31").unwrap()
  match calendar.next_business_day(end) {
    Err(DateOutOfRange) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}

///|
test "calendar summary reports empty business set" {
  let date = Date::parse("2026-08-08").unwrap()
  let calendar = Calendar::new(
    name="closed",
    version="1",
    weekend=WeekendPolicy::saturday_sunday(),
    holidays=[date],
    extra_workdays=[],
  )
  let summary = calendar.summarize(start=date, end=date).unwrap()
  inspect(summary.business_days(), content="0")
  match summary.first_business_day() {
    None => inspect(true, content="true")
    Some(_) => inspect(false, content="true")
  }
}

///|
test "calendar timeline handles a one-day closure" {
  let timeline = CalendarTimeline::between(
    calendar=Calendar::standard(),
    start=Date::parse("2026-08-08").unwrap(),
    end=Date::parse("2026-08-08").unwrap(),
  ).unwrap()
  inspect(timeline.days().length(), content="1")
  inspect(timeline.closure_count(), content="1")
  inspect(timeline.business_day_ratio(), content="0.00")
}

///|
test "calendar catalog keeps independent versions" {
  let first = Calendar::new(
    name="demo",
    version="1",
    weekend=WeekendPolicy::saturday_sunday(),
    holidays=[],
    extra_workdays=[],
  )
  let second = Calendar::new(
    name="demo",
    version="2",
    weekend=WeekendPolicy::friday_saturday(),
    holidays=[],
    extra_workdays=[],
  )
  let catalog = CalendarCatalog::new().add(first).unwrap().add(second).unwrap()
  inspect(catalog.names().length(), content="2")
  inspect(catalog.find("demo", "2").unwrap().version(), content="2")
}
