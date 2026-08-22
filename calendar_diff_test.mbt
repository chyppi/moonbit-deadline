///|
test "calendar diff reports additions removals and shared dates" {
  let left = Calendar::new(
    name="left",
    version="1",
    weekend=WeekendPolicy::saturday_sunday(),
    holidays=[
      Date::parse("2026-08-10").unwrap(),
      Date::parse("2026-08-11").unwrap(),
    ],
    extra_workdays=[],
  )
  let right = Calendar::new(
    name="right",
    version="2",
    weekend=WeekendPolicy::saturday_sunday(),
    holidays=[
      Date::parse("2026-08-11").unwrap(),
      Date::parse("2026-08-12").unwrap(),
    ],
    extra_workdays=[],
  )
  let diff = Calendar::diff(left, right)
  inspect(diff.only_left().length(), content="1")
  inspect(diff.only_right().length(), content="1")
  inspect(diff.shared().length(), content="1")
  inspect(diff.only_left()[0].to_string(), content="2026-08-10")
}

///|
test "calendar diff includes extra workday changes" {
  let left = Calendar::new(
    name="left",
    version="1",
    weekend=WeekendPolicy::saturday_sunday(),
    holidays=[],
    extra_workdays=[Date::parse("2026-08-08").unwrap()],
  )
  let right = Calendar::standard()
  let diff = Calendar::diff(left, right)
  inspect(diff.extra_workdays_only_left().length(), content="1")
  inspect(diff.extra_workdays_only_left()[0].to_string(), content="2026-08-08")
}

///|
test "calendar diff includes observed holiday changes" {
  let left = CalendarBuilder::new(
      name="left",
      version="1",
      weekend=WeekendPolicy::saturday_sunday(),
    )
    .valid_during(
      start=Date::parse("2026-01-01").unwrap(),
      end=Date::parse("2026-12-31").unwrap(),
    )
    .build()
    .unwrap()
    .with_observed_holidays([Date::parse("2026-08-08").unwrap()])
    .unwrap()
  let right = CalendarBuilder::new(
      name="right",
      version="1",
      weekend=WeekendPolicy::saturday_sunday(),
    )
    .valid_during(
      start=Date::parse("2026-01-01").unwrap(),
      end=Date::parse("2026-12-31").unwrap(),
    )
    .build()
    .unwrap()
  let diff = Calendar::diff(left, right)
  inspect(diff.observed_holidays_only_left().length(), content="1")
  inspect(
    diff.observed_holidays_only_left()[0].to_string(),
    content="2026-08-10",
  )
}
