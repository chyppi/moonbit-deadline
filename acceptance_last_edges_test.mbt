///|
test "calendar query reports an ordinary business day" {
  let info = Calendar::standard().query(Date::parse("2026-08-03").unwrap())
  inspect(info.kind().to_string(), content="business-day")
  inspect(info.calendar_name(), content="standard")
}

///|
test "calendar diff shared holiday is retained" {
  let date = Date::parse("2026-08-03").unwrap()
  let left = Calendar::new(
    name="left",
    version="1",
    weekend=WeekendPolicy::saturday_sunday(),
    holidays=[date],
    extra_workdays=[],
  )
  let right = Calendar::new(
    name="right",
    version="1",
    weekend=WeekendPolicy::saturday_sunday(),
    holidays=[date],
    extra_workdays=[],
  )
  inspect(
    Calendar::diff(left, right).shared()[0].to_string(),
    content="2026-08-03",
  )
}

///|
test "schedule daily interval produces adjacent dates" {
  let schedule = ObligationSchedule::new(
    start=Date::parse("2026-08-03").unwrap(),
    rule=ScheduleRule::every_calendar_days(1),
    calendar=Calendar::standard(),
    extension=ExtensionPolicy::no_extension(),
  ).unwrap()
  let dates = schedule.occurrences(2).unwrap()
  inspect(dates[0].to_string(), content="2026-08-03")
  inspect(dates[1].to_string(), content="2026-08-04")
}

///|
test "batch empty name is rejected" {
  let task = BatchTask::from_event(
    name="",
    event="event",
    rule=DateRule::calendar_days(1),
    start_rule=StartDateRule::exclude(),
    calendar=Calendar::standard(),
    extension=ExtensionPolicy::no_extension(),
  )
  match BatchDeadline::new().add(task) {
    Err(BatchDuplicate(name)) => inspect(name, content="")
    _ => inspect(false, content="true")
  }
}

///|
test "rule validation accepts zero nested counts" {
  match
    DateRule::sequence([DateRule::calendar_days(0), DateRule::business_days(0)]).validate() {
    Ok(_) => inspect(true, content="true")
    Err(_) => inspect(false, content="true")
  }
}

///|
test "deadline record id remains unchanged after completion" {
  let result = Deadline::new(
      start_date=Date::parse("2026-08-03").unwrap(),
      rule=DateRule::calendar_days(1),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .calculate()
    .unwrap()
  let record = DeadlineRecord::new("record", result)
    .complete(Date::parse("2026-08-05").unwrap())
    .unwrap()
  inspect(record.id(), content="record")
  inspect(
    record.status(Date::parse("2026-08-06").unwrap()).to_string(),
    content="completed",
  )
}

///|
test "forecast dates remain aligned with requested count order" {
  let forecast = DeadlineForecast::new(
    start=Date::parse("2026-08-03").unwrap(),
    unit=ForecastUnit::calendar_days(),
    start_rule=StartDateRule::exclude(),
    calendar=Calendar::standard(),
    extension=ExtensionPolicy::no_extension(),
  )
  let dates = forecast.calculate([3, 1]).unwrap().dates()
  inspect(dates[0].to_string(), content="2026-08-06")
  inspect(dates[1].to_string(), content="2026-08-04")
}

///|
test "report csv and table share the same completion date" {
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
  let report = AuditReport::from_result(result, calendar)
  inspect(report.to_csv().contains("2026-08-04,complete"), content="true")
  inspect(report.to_table().contains("2026-08-04 | complete"), content="true")
}
