///|
test "reminder plan generates calendar and business day notices" {
  let result = Deadline::new(
      start_date=Date::parse("2026-08-07").unwrap(),
      rule=DateRule::calendar_days(5),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .calculate()
    .unwrap()
  let plan = ReminderPlan::new(result, Calendar::standard())
    .add(ReminderRule::calendar_days_before(2).unwrap())
    .unwrap()
    .add(ReminderRule::business_days_before(1).unwrap())
    .unwrap()
  let reminders = plan.calculate().unwrap()
  inspect(reminders[0].to_string(), content="2026-08-10")
  inspect(reminders[1].to_string(), content="2026-08-11")
}

///|
test "reminder plan rejects negative offsets and duplicates" {
  match ReminderRule::calendar_days_before(-1) {
    Err(ReminderNegativeOffset) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
  let result = Deadline::new(
      start_date=Date::parse("2026-08-07").unwrap(),
      rule=DateRule::calendar_days(3),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .calculate()
    .unwrap()
  let plan = ReminderPlan::new(result, Calendar::standard())
    .add(ReminderRule::calendar_days_before(1).unwrap())
    .unwrap()
  match plan.add(ReminderRule::calendar_days_before(1).unwrap()) {
    Err(ReminderDuplicateOffset) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}

///|
test "reminder plan rejects a reminder before the supported date range" {
  let result = Deadline::new(
      start_date=Date::parse("0001-01-01").unwrap(),
      rule=DateRule::calendar_days(0),
      start_rule=StartDateRule::including_start(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .calculate()
    .unwrap()
  let plan = ReminderPlan::new(result, Calendar::standard())
  match
    plan
    .add(ReminderRule::calendar_days_before(1).unwrap())
    .unwrap()
    .calculate() {
    Err(ReminderDateFailure) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}
