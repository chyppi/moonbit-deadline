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
