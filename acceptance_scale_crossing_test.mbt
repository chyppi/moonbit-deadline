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
