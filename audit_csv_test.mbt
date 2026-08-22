///|
test "audit report exports a stable csv with escaped notes" {
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
  let csv = AuditReport::from_result(result, calendar).to_csv()
  inspect(csv.has_prefix("date,kind,note\n"), content="true")
  inspect(csv.contains("2026-08-07,start,start date"), content="true")
  inspect(csv.contains("2026-08-09,complete,deadline"), content="true")
}
