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
