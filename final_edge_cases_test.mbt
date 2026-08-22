///|
test "date arithmetic handles leap and century boundaries" {
  inspect(
    Date::parse("2024-02-29").unwrap().add_years(1).to_string(),
    content="2025-02-28",
  )
  inspect(
    Date::parse("2000-02-29").unwrap().add_years(1).to_string(),
    content="2001-02-28",
  )
  inspect(
    Date::parse("1900-02-28").unwrap().add_days(1).to_string(),
    content="1900-03-01",
  )
  inspect(
    Date::parse("2026-01-31").unwrap().add_months(1).to_string(),
    content="2026-02-28",
  )
  inspect(
    Date::parse("2026-03-31").unwrap().add_months(-1).to_string(),
    content="2026-02-28",
  )
}

///|
test "date arithmetic reports supported range edges" {
  match Date::parse("0001-01-01").unwrap().try_add_days(-1) {
    Err(OutOfRange) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
  match Date::parse("9999-12-31").unwrap().try_add_days(1) {
    Err(OutOfRange) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
  match Date::parse("2026-02-29") {
    Err(InvalidDay) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}

///|
test "deadline extension policies handle month transitions" {
  let calendar = Calendar::new(
    name="demo",
    version="1",
    weekend=WeekendPolicy::saturday_sunday(),
    holidays=[Date::parse("2026-02-28").unwrap()],
    extra_workdays=[],
  )
  let following = Deadline::new(
      start_date=Date::parse("2026-02-27").unwrap(),
      rule=DateRule::calendar_days(1),
      start_rule=StartDateRule::exclude(),
      calendar~,
      extension=ExtensionPolicy::following(),
    )
    .calculate()
    .unwrap()
  inspect(following.adjusted_date().to_string(), content="2026-03-02")
  let preceding = Deadline::new(
      start_date=Date::parse("2026-02-27").unwrap(),
      rule=DateRule::calendar_days(1),
      start_rule=StartDateRule::exclude(),
      calendar~,
      extension=ExtensionPolicy::preceding(),
    )
    .calculate()
    .unwrap()
  inspect(preceding.adjusted_date().to_string(), content="2026-02-27")
}

///|
test "zero rules preserve start semantics consistently" {
  let start = Date::parse("2026-08-07").unwrap()
  let calendar = Calendar::standard()
  inspect(
    Deadline::new(
      start_date=start,
      rule=DateRule::calendar_days(0),
      start_rule=StartDateRule::exclude(),
      calendar~,
      extension=ExtensionPolicy::no_extension(),
    )
    .calculate()
    .unwrap()
    .original_date()
    .to_string(),
    content="2026-08-07",
  )
  inspect(
    Deadline::new(
      start_date=start,
      rule=DateRule::business_days(0),
      start_rule=StartDateRule::including_start(),
      calendar~,
      extension=ExtensionPolicy::no_extension(),
    )
    .calculate()
    .unwrap()
    .original_date()
    .to_string(),
    content="2026-08-07",
  )
}

///|
test "suspension boundaries do not double count adjacent periods" {
  let periods = [
    SuspensionPeriod::new(
      start=Date::parse("2026-08-07").unwrap(),
      end=Date::parse("2026-08-08").unwrap(),
    ).unwrap(),
    SuspensionPeriod::new(
      start=Date::parse("2026-08-09").unwrap(),
      end=Date::parse("2026-08-10").unwrap(),
    ).unwrap(),
  ]
  let set = SuspensionSet::new(periods~).normalize()
  inspect(set.calendar_days(), content="4")
  inspect(set.periods().length(), content="1")
}

///|
test "batch failure propagates the first missing event" {
  let context = EventContext::new()
  let batch = BatchDeadline::new()
    .add(
      BatchTask::from_event(
        name="notice",
        event="missing",
        rule=DateRule::calendar_days(1),
        start_rule=StartDateRule::exclude(),
        calendar=Calendar::standard(),
        extension=ExtensionPolicy::no_extension(),
      ),
    )
    .unwrap()
  match batch.calculate(context) {
    Err(BatchEventFailure(EventMissing(name))) =>
      inspect(name, content="missing")
    _ => inspect(false, content="true")
  }
}

///|
test "calendar merge keeps primary custom weekend policy" {
  let primary = CalendarBuilder::new(
      name="primary",
      version="1",
      weekend=WeekendPolicy::friday_saturday(),
    )
    .build()
    .unwrap()
  let secondary = Calendar::standard()
  let merged = Calendar::merge(primary, secondary).unwrap()
  inspect(
    merged.is_business_day(Date::parse("2026-08-07").unwrap()),
    content="false",
  )
}

///|
test "rule descriptions remain stable for nested sequences" {
  let rule = DateRule::sequence([
    DateRule::weeks(1),
    DateRule::sequence([DateRule::months(2), DateRule::years(1)]),
  ])
  inspect(rule.describe(), content="weeks:1,months:2,years:1")
  inspect(rule.estimated_calendar_days(), content="432")
}
