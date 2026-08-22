///|
test "schedule generates calendar and business day occurrences" {
  let calendar = Calendar::standard()
  let daily = ObligationSchedule::new(
    start=Date::parse("2026-08-07").unwrap(),
    rule=ScheduleRule::every_calendar_days(2),
    calendar~,
    extension=ExtensionPolicy::no_extension(),
  ).unwrap()
  let dates = daily.occurrences(4).unwrap()
  inspect(dates[0].to_string(), content="2026-08-07")
  inspect(dates[3].to_string(), content="2026-08-13")
  let business = ObligationSchedule::new(
    start=Date::parse("2026-08-07").unwrap(),
    rule=ScheduleRule::every_business_days(1),
    calendar~,
    extension=ExtensionPolicy::no_extension(),
  ).unwrap()
  inspect(business.occurrences(3).unwrap()[2].to_string(), content="2026-08-11")
}

///|
test "schedule supports weekly weekdays and monthly anchors" {
  let weekly = ObligationSchedule::new(
    start=Date::parse("2026-08-07").unwrap(),
    rule=ScheduleRule::weekly_on(weekday=Weekday::monday(), interval=1),
    calendar=Calendar::standard(),
    extension=ExtensionPolicy::no_extension(),
  ).unwrap()
  inspect(weekly.occurrences(2).unwrap()[1].to_string(), content="2026-08-17")
  let monthly = ObligationSchedule::new(
    start=Date::parse("2026-01-31").unwrap(),
    rule=ScheduleRule::monthly_on(day=31, interval=1),
    calendar=Calendar::standard(),
    extension=ExtensionPolicy::no_extension(),
  ).unwrap()
  inspect(monthly.occurrences(2).unwrap()[1].to_string(), content="2026-02-28")
}

///|
test "schedule rejects invalid intervals and counts" {
  match
    ObligationSchedule::new(
      start=Date::parse("2026-08-07").unwrap(),
      rule=ScheduleRule::every_calendar_days(0),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    ) {
    Err(ScheduleInvalidInterval) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
  let schedule = ObligationSchedule::new(
    start=Date::parse("2026-08-07").unwrap(),
    rule=ScheduleRule::every_calendar_days(1),
    calendar=Calendar::standard(),
    extension=ExtensionPolicy::no_extension(),
  ).unwrap()
  match schedule.occurrences(0) {
    Err(ScheduleInvalidCount) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}

///|
test "schedule extensions do not emit duplicate business dates" {
  let schedule = ObligationSchedule::new(
    start=Date::parse("2026-08-07").unwrap(),
    rule=ScheduleRule::every_calendar_days(1),
    calendar=Calendar::standard(),
    extension=ExtensionPolicy::following(),
  ).unwrap()
  let dates = schedule.occurrences(3).unwrap()
  inspect(dates[0].to_string(), content="2026-08-07")
  inspect(dates[1].to_string(), content="2026-08-10")
  inspect(dates[2].to_string(), content="2026-08-11")
}
