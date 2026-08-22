///|
test "date add and subtract days round trip" {
  let date = Date::parse("2026-08-22").unwrap()
  inspect(date.add_days(30).add_days(-30).to_string(), content="2026-08-22")
  inspect(date.add_months(12).add_years(-1).to_string(), content="2026-08-22")
}

///|
test "weekday names are stable for all constructor helpers" {
  inspect(Weekday::monday().to_string(), content="Monday")
  inspect(Weekday::tuesday().to_string(), content="Tuesday")
  inspect(Weekday::wednesday().to_string(), content="Wednesday")
  inspect(Weekday::thursday().to_string(), content="Thursday")
  inspect(Weekday::friday().to_string(), content="Friday")
  inspect(Weekday::saturday().to_string(), content="Saturday")
  inspect(Weekday::sunday().to_string(), content="Sunday")
}

///|
test "date range membership includes both endpoints" {
  let range = DateRange::closed(
    start=Date::parse("2026-08-01").unwrap(),
    end=Date::parse("2026-08-03").unwrap(),
  ).unwrap()
  inspect(range.contains(Date::parse("2026-08-01").unwrap()), content="true")
  inspect(range.contains(Date::parse("2026-08-03").unwrap()), content="true")
  inspect(range.contains(Date::parse("2026-08-04").unwrap()), content="false")
}

///|
test "calendar query distinguishes holiday observed and weekend" {
  let source = CalendarSource::new(name="source", url="https://example.test")
  let version = CalendarVersion::new(
    name="demo",
    region="X",
    version="1",
    source~,
    valid_from=Date::parse("2026-01-01").unwrap(),
    valid_to=Date::parse("2026-12-31").unwrap(),
  ).unwrap()
  let calendar = Calendar::new(
      name="demo",
      version="1",
      weekend=WeekendPolicy::saturday_sunday(),
      holidays=[Date::parse("2026-08-10").unwrap()],
      extra_workdays=[],
    )
    .with_version(version)
    .with_observed_holidays([Date::parse("2026-08-08").unwrap()])
    .unwrap()
  inspect(
    calendar.query(Date::parse("2026-08-10").unwrap()).kind().to_string(),
    content="holiday",
  )
  inspect(
    calendar.query(Date::parse("2026-08-10").unwrap()).calendar_name(),
    content="demo",
  )
}

///|
test "calendar builder preserves source URL and validity" {
  let start = Date::parse("2026-01-01").unwrap()
  let end = Date::parse("2026-12-31").unwrap()
  let calendar = CalendarBuilder::new(
      name="source-demo",
      version="v1",
      weekend=WeekendPolicy::saturday_sunday(),
    )
    .source(
      CalendarSource::new(name="policy", url="https://example.test/policy"),
    )
    .valid_during(start~, end~)
    .build()
    .unwrap()
  inspect(calendar.source().url(), content="https://example.test/policy")
  inspect(calendar.valid_from().to_string(), content="2026-01-01")
  inspect(calendar.valid_to().to_string(), content="2026-12-31")
}

///|
test "event fixed date resolves without a dependency" {
  let date = Date::parse("2026-08-22").unwrap()
  let context = EventContext::new()
    .insert("fixed", EventSpec::fixed(date))
    .unwrap()
  inspect(context.resolve("fixed").unwrap().to_string(), content="2026-08-22")
}

///|
test "batch ordered names are insertion independent after dependencies" {
  let context = EventContext::new()
    .insert("fixed", EventSpec::fixed(Date::parse("2026-08-22").unwrap()))
    .unwrap()
  let batch = BatchDeadline::new()
    .add(
      BatchTask::after(
        name="second",
        dependency="first",
        rule=DateRule::calendar_days(1),
        start_rule=StartDateRule::exclude(),
        calendar=Calendar::standard(),
        extension=ExtensionPolicy::no_extension(),
      ),
    )
    .unwrap()
    .add(
      BatchTask::from_event(
        name="first",
        event="fixed",
        rule=DateRule::calendar_days(1),
        start_rule=StartDateRule::exclude(),
        calendar=Calendar::standard(),
        extension=ExtensionPolicy::no_extension(),
      ),
    )
    .unwrap()
  let result = batch.calculate(context).unwrap()
  inspect(result.ordered()[0], content="first")
  inspect(result.ordered()[1], content="second")
}

///|
test "audit table includes a count row" {
  let calendar = Calendar::standard()
  let result = Deadline::new(
      start_date=Date::parse("2026-08-22").unwrap(),
      rule=DateRule::calendar_days(1),
      start_rule=StartDateRule::exclude(),
      calendar~,
      extension=ExtensionPolicy::no_extension(),
    )
    .calculate()
    .unwrap()
  inspect(
    AuditReport::from_result(result, calendar).to_table().contains("count"),
    content="true",
  )
}

///|
test "schedule weekly anchor includes same-day matches" {
  let schedule = ObligationSchedule::new(
    start=Date::parse("2026-08-24").unwrap(),
    rule=ScheduleRule::weekly_on(weekday=Weekday::monday(), interval=1),
    calendar=Calendar::standard(),
    extension=ExtensionPolicy::no_extension(),
  ).unwrap()
  inspect(schedule.occurrences(1).unwrap()[0].to_string(), content="2026-08-24")
}

///|
test "forecast year unit uses conservative planning span" {
  let forecast = DeadlineForecast::new(
    start=Date::parse("2026-01-01").unwrap(),
    unit=ForecastUnit::years(),
    start_rule=StartDateRule::exclude(),
    calendar=Calendar::standard(),
    extension=ExtensionPolicy::no_extension(),
  )
  inspect(
    forecast.calculate([1]).unwrap().dates()[0].to_string(),
    content="2027-01-01",
  )
}

///|
test "reminder plan keeps configured order" {
  let result = Deadline::new(
      start_date=Date::parse("2026-08-22").unwrap(),
      rule=DateRule::calendar_days(5),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .calculate()
    .unwrap()
  let plan = ReminderPlan::new(result, Calendar::standard())
    .add(ReminderRule::calendar_days_before(1).unwrap())
    .unwrap()
    .add(ReminderRule::calendar_days_before(3).unwrap())
    .unwrap()
  let dates = plan.calculate().unwrap()
  inspect(dates[0].to_string(), content="2026-08-26")
  inspect(dates[1].to_string(), content="2026-08-24")
}

///|
test "matrix delta is zero for equal calendars" {
  let result = DeadlineMatrix::new(
      start=Date::parse("2026-08-22").unwrap(),
      rule=DateRule::calendar_days(2),
      start_rule=StartDateRule::exclude(),
      extension=ExtensionPolicy::no_extension(),
    )
    .add_calendar("a", Calendar::standard())
    .unwrap()
    .add_calendar("b", Calendar::standard())
    .unwrap()
    .calculate()
    .unwrap()
  inspect(result.delta("a", "b").unwrap(), content="0")
}

///|
test "constraint within accepts both window endpoints" {
  let result = Deadline::new(
      start_date=Date::parse("2026-08-22").unwrap(),
      rule=DateRule::calendar_days(2),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .calculate()
    .unwrap()
  let constraint = DeadlineConstraint::within(
    start=result.adjusted_date(),
    end=result.adjusted_date(),
  ).unwrap()
  match
    ConstrainedDeadline::new(
      start_date=Date::parse("2026-08-22").unwrap(),
      rule=DateRule::calendar_days(2),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .add_constraint(constraint)
    .unwrap()
    .calculate() {
    Ok(_) => inspect(true, content="true")
    Err(_) => inspect(false, content="true")
  }
}

///|
test "ledger find returns none for an unknown id" {
  let ledger = DeadlineLedger::new()
  match ledger.find("unknown") {
    None => inspect(true, content="true")
    Some(_) => inspect(false, content="true")
  }
}

///|
test "cursor forward count one is the next business date" {
  let dates = BusinessDayCursor::new(
      date=Date::parse("2026-08-22").unwrap(),
      calendar=Calendar::standard(),
    )
    .forward(1)
    .unwrap()
  inspect(dates[0].to_string(), content="2026-08-24")
}

///|
test "timeline csv contains the configured calendar identity" {
  let calendar = Calendar::new(
    name="timeline",
    version="v1",
    weekend=WeekendPolicy::saturday_sunday(),
    holidays=[],
    extra_workdays=[],
  )
  let csv = CalendarTimeline::between(
      calendar~,
      start=Date::parse("2026-08-22").unwrap(),
      end=Date::parse("2026-08-22").unwrap(),
    )
    .unwrap()
    .to_csv()
  inspect(csv.contains("timeline,v1"), content="true")
}

///|
test "rule complexity leaf metrics are minimal" {
  let rule = DateRule::years(2)
  inspect(rule.node_count(), content="1")
  inspect(rule.max_depth(), content="0")
  inspect(rule.uses_business_days(), content="false")
}

///|
test "date from ordinal restores the maximum supported date" {
  let date = Date::parse("9999-12-31").unwrap()
  inspect(
    Date::from_ordinal(date.ordinal()).unwrap().to_string(),
    content="9999-12-31",
  )
}

///|
test "date filter can select observed holidays only" {
  let source = CalendarSource::new(name="source", url="https://example.test")
  let version = CalendarVersion::new(
    name="demo",
    region="X",
    version="1",
    source~,
    valid_from=Date::parse("2026-01-01").unwrap(),
    valid_to=Date::parse("2026-12-31").unwrap(),
  ).unwrap()
  let calendar = Calendar::standard()
    .with_version(version)
    .with_observed_holidays([Date::parse("2026-08-08").unwrap()])
    .unwrap()
  let dates = calendar
    .dates_between(
      start=Date::parse("2026-08-08").unwrap(),
      end=Date::parse("2026-08-10").unwrap(),
      filter=CalendarDateFilter::observed_holidays(),
    )
    .unwrap()
  inspect(dates.length(), content="1")
}
