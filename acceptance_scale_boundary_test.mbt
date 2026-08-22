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
