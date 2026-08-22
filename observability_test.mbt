///|
test "rule complexity metrics describe nested planning cost" {
  let rule = DateRule::sequence([
    DateRule::calendar_days(1),
    DateRule::sequence([DateRule::business_days(2), DateRule::months(1)]),
  ])
  inspect(rule.node_count(), content="5")
  inspect(rule.max_depth(), content="2")
  inspect(rule.uses_business_days(), content="true")
}

///|
test "calendar diff renders audit-friendly text" {
  let left = Calendar::new(
    name="left",
    version="1",
    weekend=WeekendPolicy::saturday_sunday(),
    holidays=[Date::parse("2026-08-10").unwrap()],
    extra_workdays=[],
  )
  let right = Calendar::new(
    name="right",
    version="2",
    weekend=WeekendPolicy::saturday_sunday(),
    holidays=[Date::parse("2026-08-11").unwrap()],
    extra_workdays=[],
  )
  let text = Calendar::diff(left, right).to_text()
  inspect(text.contains("only-left=2026-08-10"), content="true")
  inspect(text.contains("only-right=2026-08-11"), content="true")
}

///|
test "deadline result counts step kinds for metrics" {
  let calendar = Calendar::new(
    name="demo",
    version="1",
    weekend=WeekendPolicy::saturday_sunday(),
    holidays=[Date::parse("2026-08-10").unwrap()],
    extra_workdays=[],
  )
  let result = Deadline::new(
      start_date=Date::parse("2026-08-07").unwrap(),
      rule=DateRule::calendar_days(1),
      start_rule=StartDateRule::exclude(),
      calendar~,
      extension=ExtensionPolicy::following(),
    )
    .calculate()
    .unwrap()
  inspect(result.step_notes().length(), content="4")
  inspect(result.count_kind(StepKind::extension()), content="1")
}
