///|
test "audit report includes calendar metadata and calculation fields" {
  let calendar = Calendar::china_2026()
  let deadline = Deadline::new(
    start_date=Date::parse("2026-05-03").unwrap(),
    rule=DateRule::calendar_days(1),
    start_rule=StartDateRule::exclude(),
    calendar~,
    extension=ExtensionPolicy::following(),
  )
  let result = deadline.calculate().unwrap()
  let report = AuditReport::from_result(result, calendar)
  let text = report.to_text()
  inspect(text.contains("calendar=china-national-2026"), content="true")
  inspect(text.contains("original=2026-05-04"), content="true")
  inspect(text.contains("adjusted=2026-05-06"), content="true")
  inspect(text.contains("source="), content="true")
}

///|
test "audit report table has a stable header and one row per step" {
  let calendar = Calendar::standard()
  let result = Deadline::new(
      start_date=Date::parse("2026-08-07").unwrap(),
      rule=DateRule::calendar_days(2),
      start_rule=StartDateRule::exclude(),
      calendar~,
      extension=ExtensionPolicy::no_extension(),
    )
    .calculate()
    .unwrap()
  let table = AuditReport::from_result(result, calendar).to_table()
  inspect(table.has_prefix("date | kind | note\n"), content="true")
  inspect(table.contains("2026-08-07 | start | start date"), content="true")
  inspect(table.contains("2026-08-09 | complete | deadline"), content="true")
}
