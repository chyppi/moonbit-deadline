///| 
/// Boundary and cross-feature acceptance coverage.

///|
test "date range business count sees a weekend closure" {
  let range = DateRange::closed(
    start=Date::parse("2026-08-08").unwrap(),
    end=Date::parse("2026-08-09").unwrap(),
  ).unwrap()
  inspect(range.calendar_days(), content="2")
  inspect(range.business_days(Calendar::standard()), content="0")
}

///|
test "deadline result has no extension for a business completion" {
  let result = Deadline::new(
      start_date=Date::parse("2026-08-03").unwrap(),
      rule=DateRule::calendar_days(1),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::following(),
    )
    .calculate()
    .unwrap()
  inspect(result.has_extension(), content="false")
  inspect(result.adjusted_date().to_string(), content="2026-08-04")
}

///|
test "calendar filter holidays is empty on a plain workday" {
  let date = Date::parse("2026-08-03").unwrap()
  inspect(
    Calendar::standard()
    .dates_between(start=date, end=date, filter=CalendarDateFilter::holidays())
    .unwrap()
    .length(),
    content="0",
  )
}

///|
test "schedule invalid monthly day is rejected" {
  match
    ObligationSchedule::new(
      start=Date::parse("2026-08-03").unwrap(),
      rule=ScheduleRule::monthly_on(day=32, interval=1),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    ) {
    Err(ScheduleInvalidInterval) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}

///|
test "reminder negative business offset is rejected" {
  match ReminderRule::business_days_before(-1) {
    Err(ReminderNegativeOffset) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}

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

///|
test "deadline result summary is stable" {
  let result = Deadline::new(
      start_date=Date::parse("2026-08-03").unwrap(),
      rule=DateRule::calendar_days(0),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .calculate()
    .unwrap()
  inspect(result.summary(), content="2026-08-03 -> 2026-08-03")
}

///|
test "calendar query version is returned for callers" {
  let calendar = Calendar::new(
    name="demo",
    version="2026",
    weekend=WeekendPolicy::saturday_sunday(),
    holidays=[],
    extra_workdays=[],
  )
  inspect(
    calendar.query(Date::parse("2026-08-03").unwrap()).calendar_version(),
    content="2026",
  )
}

///|
test "business day series includes a single weekday" {
  let date = Date::parse("2026-08-03").unwrap()
  let dates = BusinessDaySeries::new(
      calendar=Calendar::standard(),
      start=date,
      end=date,
    )
    .unwrap()
    .collect()
  inspect(dates.length(), content="1")
  inspect(dates[0].to_string(), content="2026-08-03")
}

///|
test "forecast result get returns an exact requested point" {
  let result = DeadlineForecast::new(
      start=Date::parse("2026-08-03").unwrap(),
      unit=ForecastUnit::calendar_days(),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .calculate([2])
    .unwrap()
  inspect(result.get(2).unwrap().to_string(), content="2026-08-05")
}

///|
test "deadline record status is pending before due date" {
  let result = Deadline::new(
      start_date=Date::parse("2026-08-03").unwrap(),
      rule=DateRule::calendar_days(2),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .calculate()
    .unwrap()
  let record = DeadlineRecord::new("pending", result)
  inspect(
    record.status(Date::parse("2026-08-04").unwrap()).to_string(),
    content="pending",
  )
}

///|
test "date rule calendar day description is exact" {
  inspect(DateRule::calendar_days(0).describe(), content="calendar-days:0")
}

///|
test "calendar day info date is preserved" {
  let date = Date::parse("2026-08-03").unwrap()
  inspect(
    Calendar::standard().query(date).date().to_string(),
    content="2026-08-03",
  )
  inspect(
    Calendar::standard().query(date).kind().to_string(),
    content="business-day",
  )
}

///|
test "deadline result crossed month is false inside month" {
  let result = Deadline::new(
      start_date=Date::parse("2026-08-03").unwrap(),
      rule=DateRule::calendar_days(1),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .calculate()
    .unwrap()
  inspect(result.crossed_month(), content="false")
  inspect(result.crossed_year(), content="false")
}

///|
test "date rule unit description remains machine readable" {
  inspect(DateRule::business_days(1).describe(), content="business-days:1")
  inspect(DateRule::weeks(1).describe(), content="weeks:1")
}

///|
test "calendar standard next business day preserves a weekday" {
  let date = Date::parse("2026-08-03").unwrap()
  inspect(
    Calendar::standard().next_business_day(date).unwrap().to_string(),
    content="2026-08-03",
  )
}

///|
test "deadline window shift preserves duration" {
  let window = DeadlineWindow::new(
    start=Date::parse("2026-08-03").unwrap(),
    end=Date::parse("2026-08-05").unwrap(),
  ).unwrap()
  let shifted = window.shift(10).unwrap()
  inspect(shifted.calendar_days(), content="3")
  inspect(shifted.start().to_string(), content="2026-08-13")
}

///|
test "matrix result get returns none for an absent calendar" {
  let result = DeadlineMatrix::new(
      start=Date::parse("2026-08-03").unwrap(),
      rule=DateRule::calendar_days(1),
      start_rule=StartDateRule::exclude(),
      extension=ExtensionPolicy::no_extension(),
    )
    .add_calendar("known", Calendar::standard())
    .unwrap()
    .calculate()
    .unwrap()
  match result.get("absent") {
    None => inspect(true, content="true")
    Some(_) => inspect(false, content="true")
  }
}

///|
test "audit report text includes adjusted date" {
  let calendar = Calendar::standard()
  let result = Deadline::new(
      start_date=Date::parse("2026-08-03").unwrap(),
      rule=DateRule::calendar_days(1),
      start_rule=StartDateRule::exclude(),
      calendar~,
      extension=ExtensionPolicy::no_extension(),
    )
    .calculate()
    .unwrap()
  inspect(
    AuditReport::from_result(result, calendar)
    .to_text()
    .contains("adjusted=2026-08-04"),
    content="true",
  )
}

///|
test "calendar day filter returns no observed date without metadata" {
  let date = Date::parse("2026-08-03").unwrap()
  inspect(
    Calendar::standard()
    .dates_between(
      start=date,
      end=date,
      filter=CalendarDateFilter::observed_holidays(),
    )
    .unwrap()
    .length(),
    content="0",
  )
}

///|
test "forecast unit description is represented by its computed result" {
  let forecast = DeadlineForecast::new(
    start=Date::parse("2026-08-03").unwrap(),
    unit=ForecastUnit::months(),
    start_rule=StartDateRule::exclude(),
    calendar=Calendar::standard(),
    extension=ExtensionPolicy::no_extension(),
  )
  inspect(
    forecast.calculate([1]).unwrap().dates()[0].to_string(),
    content="2026-09-03",
  )
}

///|
test "date ordinal roundtrip works for a current date" {
  let date = Date::parse("2026-08-03").unwrap()
  inspect(
    Date::from_ordinal(date.ordinal()).unwrap().to_string(),
    content="2026-08-03",
  )
}

///|
test "audit report summary starts at the requested date" {
  let calendar = Calendar::standard()
  let result = Deadline::new(
      start_date=Date::parse("2026-08-03").unwrap(),
      rule=DateRule::calendar_days(1),
      start_rule=StartDateRule::exclude(),
      calendar~,
      extension=ExtensionPolicy::no_extension(),
    )
    .calculate()
    .unwrap()
  inspect(result.summary(), content="2026-08-03 -> 2026-08-04")
}

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

///|
test "holiday calendar summary counts only the exceptional closure" {
  let holiday = Date::parse("2026-08-03").unwrap()
  let calendar = Calendar::new(
    name="holiday",
    version="1",
    weekend=WeekendPolicy::no_weekend(),
    holidays=[holiday],
    extra_workdays=[],
  )
  let summary = calendar.summarize(start=holiday, end=holiday).unwrap()
  inspect(summary.total_days(), content="1")
  inspect(summary.business_days(), content="0")
  inspect(summary.holiday_days(), content="1")
}

///|
test "deadline rule description survives a zero sequence" {
  let rule = DateRule::sequence([
    DateRule::calendar_days(0),
    DateRule::business_days(0),
  ])
  inspect(rule.describe(), content="calendar-days:0,business-days:0")
  inspect(rule.estimated_calendar_days(), content="0")
}

///|
test "reminder plan returns one date for one rule" {
  let result = Deadline::new(
      start_date=Date::parse("2026-08-03").unwrap(),
      rule=DateRule::calendar_days(4),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .calculate()
    .unwrap()
  let dates = ReminderPlan::new(result, Calendar::standard())
    .add(ReminderRule::calendar_days_before(2).unwrap())
    .unwrap()
    .calculate()
    .unwrap()
  inspect(dates.length(), content="1")
  inspect(dates[0].to_string(), content="2026-08-05")
}

///|
test "batch result get returns the calculated final date" {
  let context = EventContext::new()
    .insert("start", EventSpec::fixed(Date::parse("2026-08-03").unwrap()))
    .unwrap()
  let batch = BatchDeadline::new()
    .add(
      BatchTask::from_event(
        name="one",
        event="start",
        rule=DateRule::calendar_days(2),
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
    .get("one")
    .unwrap()
    .adjusted_date()
    .to_string(),
    content="2026-08-05",
  )
}

///|
test "date serial consecutive values differ by one" {
  let first = Date::parse("2026-08-03").unwrap().ordinal()
  let second = Date::parse("2026-08-04").unwrap().ordinal()
  inspect(second - first, content="1")
  inspect(Date::from_ordinal(first).unwrap().to_string(), content="2026-08-03")
}

///|
test "deadline window contains its shifted start" {
  let window = DeadlineWindow::new(
      start=Date::parse("2026-08-03").unwrap(),
      end=Date::parse("2026-08-05").unwrap(),
    )
    .unwrap()
    .shift(1)
    .unwrap()
  inspect(window.contains(Date::parse("2026-08-04").unwrap()), content="true")
  inspect(window.end().to_string(), content="2026-08-06")
}

///|
test "matrix same scenario duplicate is rejected" {
  let matrix = DeadlineMatrix::new(
      start=Date::parse("2026-08-03").unwrap(),
      rule=DateRule::calendar_days(1),
      start_rule=StartDateRule::exclude(),
      extension=ExtensionPolicy::no_extension(),
    )
    .add_calendar("same", Calendar::standard())
    .unwrap()
  match matrix.add_calendar("same", Calendar::standard()) {
    Err(MatrixDuplicate(name)) => inspect(name, content="same")
    _ => inspect(false, content="true")
  }
}

///|
test "deadline status pending text is stable" {
  let result = Deadline::new(
      start_date=Date::parse("2026-08-03").unwrap(),
      rule=DateRule::calendar_days(2),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .calculate()
    .unwrap()
  inspect(
    result.status(Date::parse("2026-08-04").unwrap()).to_string(),
    content="pending",
  )
}

///|
test "calendar standard has no holiday dates in a weekday" {
  let date = Date::parse("2026-08-03").unwrap()
  inspect(
    Calendar::standard()
    .dates_between(start=date, end=date, filter=CalendarDateFilter::holidays())
    .unwrap()
    .length(),
    content="0",
  )
}

///|
test "calendar catalog can find its standard entry" {
  let catalog = CalendarCatalog::new().add(Calendar::standard()).unwrap()
  inspect(
    catalog.find("standard", "builtin").unwrap().name(),
    content="standard",
  )
}

///|
test "date window intersection keeps shared endpoints" {
  let one = DeadlineWindow::new(
    start=Date::parse("2026-08-01").unwrap(),
    end=Date::parse("2026-08-03").unwrap(),
  ).unwrap()
  let two = DeadlineWindow::new(
    start=Date::parse("2026-08-03").unwrap(),
    end=Date::parse("2026-08-04").unwrap(),
  ).unwrap()
  inspect(one.intersection(two).unwrap().calendar_days(), content="1")
  inspect(one.intersects(two), content="true")
}

///|
test "rule parser rejects an empty string" {
  match DateRule::parse("") {
    Err(RuleInvalidFormat) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}

///|
test "calendar query date and version form a stable record" {
  let date = Date::parse("2026-08-03").unwrap()
  let info = Calendar::standard().query(date)
  inspect(info.date().to_string(), content="2026-08-03")
  inspect(info.calendar_version(), content="builtin")
}

///|
test "deadline window calendar length is inclusive" {
  let window = DeadlineWindow::new(
    start=Date::parse("2026-08-03").unwrap(),
    end=Date::parse("2026-08-03").unwrap(),
  ).unwrap()
  inspect(window.calendar_days(), content="1")
}

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
