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
