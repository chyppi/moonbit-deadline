///|
test "event offsets preserve month and year transitions" {
  let context = EventContext::new()
    .insert("new-year", EventSpec::fixed(Date::parse("2026-12-31").unwrap()))
    .unwrap()
    .insert("next-year", EventSpec::after("new-year", 1))
    .unwrap()
  inspect(
    context.resolve("next-year").unwrap().to_string(),
    content="2027-01-01",
  )
}

///|
test "event context returns missing roots before date errors" {
  let context = EventContext::new()
    .insert("child", EventSpec::after("root", 1))
    .unwrap()
  match context.resolve("child") {
    Err(EventMissing(name)) => inspect(name, content="root")
    _ => inspect(false, content="true")
  }
}

///|
test "event context detects a three-node cycle" {
  let context = EventContext::new()
    .insert("a", EventSpec::after("b", 1))
    .unwrap()
    .insert("b", EventSpec::after("c", 1))
    .unwrap()
    .insert("c", EventSpec::after("a", 1))
    .unwrap()
  match context.resolve("a") {
    Err(EventCycle(name)) => inspect(name, content="a")
    _ => inspect(false, content="true")
  }
}

///|
test "batch result explanation includes every completed task" {
  let context = EventContext::new()
    .insert("filed", EventSpec::fixed(Date::parse("2026-08-07").unwrap()))
    .unwrap()
  let batch = BatchDeadline::new()
    .add(
      BatchTask::from_event(
        name="notice",
        event="filed",
        rule=DateRule::calendar_days(1),
        start_rule=StartDateRule::exclude(),
        calendar=Calendar::standard(),
        extension=ExtensionPolicy::no_extension(),
      ),
    )
    .unwrap()
  inspect(
    batch.calculate(context).unwrap().explain().contains("notice: 2026-08-08"),
    content="true",
  )
}

///|
test "batch dependency results use adjusted rather than original dates" {
  let context = EventContext::new()
    .insert("filed", EventSpec::fixed(Date::parse("2026-08-07").unwrap()))
    .unwrap()
  let batch = BatchDeadline::new()
    .add(
      BatchTask::from_event(
        name="first",
        event="filed",
        rule=DateRule::calendar_days(1),
        start_rule=StartDateRule::exclude(),
        calendar=Calendar::new(
          name="closed",
          version="1",
          weekend=WeekendPolicy::saturday_sunday(),
          holidays=[Date::parse("2026-08-08").unwrap()],
          extra_workdays=[],
        ),
        extension=ExtensionPolicy::following(),
      ),
    )
    .unwrap()
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
  inspect(
    batch
    .calculate(context)
    .unwrap()
    .get("second")
    .unwrap()
    .adjusted_date()
    .to_string(),
    content="2026-08-11",
  )
}

///|
test "inclusive suspension counts one day and exclusive suspension counts zero" {
  let period = SuspensionPeriod::new(
    start=Date::parse("2026-08-10").unwrap(),
    end=Date::parse("2026-08-10").unwrap(),
  ).unwrap()
  inspect(
    SuspensionSet::new(
      periods=[period],
      policy=SuspensionPolicy::pause_inclusive(),
    ).calendar_days(),
    content="1",
  )
  inspect(
    SuspensionSet::new(
      periods=[period],
      policy=SuspensionPolicy::pause_exclusive(),
    ).calendar_days(),
    content="0",
  )
}

///|
test "deadline status string values are stable for integrations" {
  inspect(DeadlineStatus::pending().to_string(), content="pending")
  inspect(DeadlineStatus::due_today().to_string(), content="due-today")
  inspect(DeadlineStatus::overdue().to_string(), content="overdue")
  inspect(DeadlineStatus::completed().to_string(), content="completed")
}

///|
test "matrix reports missing scenario names" {
  let result = DeadlineMatrix::new(
      start=Date::parse("2026-08-07").unwrap(),
      rule=DateRule::calendar_days(1),
      start_rule=StartDateRule::exclude(),
      extension=ExtensionPolicy::no_extension(),
    )
    .add_calendar("standard", Calendar::standard())
    .unwrap()
    .calculate()
    .unwrap()
  match result.delta("standard", "missing") {
    Err(MatrixMissing(name)) => inspect(name, content="missing")
    _ => inspect(false, content="true")
  }
}

///|
test "constraint checks business-day policy after extension" {
  let calendar = Calendar::new(
    name="closed",
    version="1",
    weekend=WeekendPolicy::saturday_sunday(),
    holidays=[Date::parse("2026-08-10").unwrap()],
    extra_workdays=[],
  )
  let request = ConstrainedDeadline::new(
      start_date=Date::parse("2026-08-07").unwrap(),
      rule=DateRule::calendar_days(3),
      start_rule=StartDateRule::exclude(),
      calendar~,
      extension=ExtensionPolicy::following(),
    )
    .add_constraint(DeadlineConstraint::must_be_business_day())
    .unwrap()
  inspect(
    request.calculate().unwrap().adjusted_date().to_string(),
    content="2026-08-11",
  )
}

///|
test "constraint rejects a year boundary result" {
  let request = ConstrainedDeadline::new(
      start_date=Date::parse("2026-12-31").unwrap(),
      rule=DateRule::calendar_days(1),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .add_constraint(DeadlineConstraint::not_crossing_year())
    .unwrap()
  match request.calculate() {
    Err(ConstraintViolation(name)) => inspect(name, content="not-crossing-year")
    _ => inspect(false, content="true")
  }
}

///|
test "ledger due query returns only the exact due record" {
  let one = DeadlineService::evaluate(
    DeadlineRequest::new(
      id="one",
      start=Date::parse("2026-08-07").unwrap(),
      rule=DateRule::calendar_days(3),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    ),
  ).unwrap()
  let two = DeadlineService::evaluate(
    DeadlineRequest::new(
      id="two",
      start=Date::parse("2026-08-07").unwrap(),
      rule=DateRule::calendar_days(5),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    ),
  ).unwrap()
  let ledger = DeadlineLedger::new().add(one).unwrap().add(two).unwrap()
  inspect(ledger.due(Date::parse("2026-08-10").unwrap()).length(), content="1")
  inspect(ledger.due(Date::parse("2026-08-12").unwrap()).length(), content="1")
}

///|
test "forecast preserves duplicate count requests" {
  let forecast = DeadlineForecast::new(
    start=Date::parse("2026-08-07").unwrap(),
    unit=ForecastUnit::calendar_days(),
    start_rule=StartDateRule::exclude(),
    calendar=Calendar::standard(),
    extension=ExtensionPolicy::no_extension(),
  )
  let result = forecast.calculate([1, 1]).unwrap()
  inspect(result.counts().length(), content="2")
  inspect(result.dates()[0].to_string(), content="2026-08-08")
  inspect(result.dates()[1].to_string(), content="2026-08-08")
}

///|
test "reminder zero offset points to the adjusted deadline" {
  let result = Deadline::new(
      start_date=Date::parse("2026-08-07").unwrap(),
      rule=DateRule::calendar_days(1),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .calculate()
    .unwrap()
  let reminder = ReminderPlan::new(result, Calendar::standard())
    .add(ReminderRule::calendar_days_before(0).unwrap())
    .unwrap()
    .calculate()
    .unwrap()
  inspect(reminder[0].to_string(), content="2026-08-08")
}

///|
test "schedule monthly anchors clamp at February" {
  let schedule = ObligationSchedule::new(
    start=Date::parse("2026-01-31").unwrap(),
    rule=ScheduleRule::monthly_on(day=31, interval=1),
    calendar=Calendar::standard(),
    extension=ExtensionPolicy::no_extension(),
  ).unwrap()
  let dates = schedule.occurrences(3).unwrap()
  inspect(dates[0].to_string(), content="2026-01-31")
  inspect(dates[1].to_string(), content="2026-02-28")
  inspect(dates[2].to_string(), content="2026-03-31")
}

///|
test "schedule following extension moves a weekend occurrence" {
  let schedule = ObligationSchedule::new(
    start=Date::parse("2026-08-08").unwrap(),
    rule=ScheduleRule::every_calendar_days(1),
    calendar=Calendar::standard(),
    extension=ExtensionPolicy::following(),
  ).unwrap()
  inspect(schedule.occurrences(1).unwrap()[0].to_string(), content="2026-08-10")
}

///|
test "audit csv includes all semantic step kinds" {
  let calendar = Calendar::new(
    name="closed",
    version="1",
    weekend=WeekendPolicy::saturday_sunday(),
    holidays=[Date::parse("2026-08-08").unwrap()],
    extra_workdays=[],
  )
  let result = Deadline::new(
      start_date=Date::parse("2026-08-07").unwrap(),
      rule=DateRule::calendar_days(1),
      start_rule=StartDateRule::exclude(),
      calendar~,
      extension=ExtensionPolicy::following(),
    )
    .calculate()
    .unwrap()
  let csv = AuditReport::from_result(result, calendar).to_csv()
  inspect(csv.contains(",start,"), content="true")
  inspect(csv.contains(",count,"), content="true")
  inspect(csv.contains(",extension,"), content="true")
  inspect(csv.contains(",complete,"), content="true")
}

///|
test "rule parser composes all supported units" {
  let rule = DateRule::parse(
    "calendar-days:1,business-days:2,weeks:3,months:4,years:5",
  ).unwrap()
  inspect(rule.node_count(), content="6")
  inspect(rule.uses_business_days(), content="true")
}

///|
test "calendar diff shared set excludes changed dates" {
  let date = Date::parse("2026-08-10").unwrap()
  let same = Calendar::new(
    name="same",
    version="1",
    weekend=WeekendPolicy::saturday_sunday(),
    holidays=[date],
    extra_workdays=[],
  )
  let diff = Calendar::diff(same, Calendar::standard())
  inspect(diff.shared().length(), content="0")
  inspect(diff.to_text().contains("shared="), content="true")
}

///|
test "timeline markdown has one row per date" {
  let timeline = CalendarTimeline::between(
    calendar=Calendar::standard(),
    start=Date::parse("2026-08-07").unwrap(),
    end=Date::parse("2026-08-09").unwrap(),
  ).unwrap()
  let markdown = timeline.to_markdown()
  inspect(markdown.contains("| 2026-08-07 | business-day |"), content="true")
  inspect(markdown.contains("| 2026-08-09 | weekend |"), content="true")
}

///|
test "business cursor previous skips a weekend" {
  let cursor = BusinessDayCursor::new(
    date=Date::parse("2026-08-10").unwrap(),
    calendar=Calendar::standard(),
  )
  inspect(cursor.previous().unwrap().to_string(), content="2026-08-07")
}

///|
test "date series step larger than range returns only the start" {
  let series = DateSeries::new(
    start=Date::parse("2026-08-01").unwrap(),
    end=Date::parse("2026-08-02").unwrap(),
    step=10,
  ).unwrap()
  inspect(series.collect().unwrap().length(), content="1")
}

///|
test "calendar filter extra workday set is independently queryable" {
  let date = Date::parse("2026-08-08").unwrap()
  let calendar = Calendar::new(
    name="demo",
    version="1",
    weekend=WeekendPolicy::saturday_sunday(),
    holidays=[],
    extra_workdays=[date],
  )
  inspect(
    calendar
    .dates_between(
      start=date,
      end=date,
      filter=CalendarDateFilter::extra_workdays(),
    )
    .unwrap()
    .length(),
    content="1",
  )
  inspect(
    calendar
    .dates_between(
      start=date,
      end=date,
      filter=CalendarDateFilter::business_days(),
    )
    .unwrap()
    .length(),
    content="1",
  )
}
