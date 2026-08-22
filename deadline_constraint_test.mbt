///|
test "constrained deadline accepts a business day inside a window" {
  let constrained = ConstrainedDeadline::new(
      start_date=Date::parse("2026-08-07").unwrap(),
      rule=DateRule::business_days(1),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .add_constraint(
      DeadlineConstraint::within(
        start=Date::parse("2026-08-10").unwrap(),
        end=Date::parse("2026-08-12").unwrap(),
      ).unwrap(),
    )
    .unwrap()
    .add_constraint(DeadlineConstraint::must_be_business_day())
    .unwrap()
  let result = constrained.calculate().unwrap()
  inspect(result.adjusted_date().to_string(), content="2026-08-10")
}

///|
test "constrained deadline reports a failed window constraint" {
  let constrained = ConstrainedDeadline::new(
      start_date=Date::parse("2026-08-07").unwrap(),
      rule=DateRule::calendar_days(3),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .add_constraint(
      DeadlineConstraint::within(
        start=Date::parse("2026-08-01").unwrap(),
        end=Date::parse("2026-08-09").unwrap(),
      ).unwrap(),
    )
    .unwrap()
  match constrained.calculate() {
    Err(ConstraintViolation(name)) => inspect(name, content="within")
    _ => inspect(false, content="true")
  }
}

///|
test "constrained deadline rejects reversed constraint ranges and cross-year results" {
  match
    DeadlineConstraint::within(
      start=Date::parse("2026-08-10").unwrap(),
      end=Date::parse("2026-08-01").unwrap(),
    ) {
    Err(ConstraintInvalidRange) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
  let constrained = ConstrainedDeadline::new(
      start_date=Date::parse("2026-12-31").unwrap(),
      rule=DateRule::calendar_days(1),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .add_constraint(DeadlineConstraint::not_crossing_year())
    .unwrap()
  match constrained.calculate() {
    Err(ConstraintViolation(name)) => inspect(name, content="not-crossing-year")
    _ => inspect(false, content="true")
  }
}
