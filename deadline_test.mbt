///|
test "deadline excludes the start date for calendar days" {
  let deadline = Deadline::new(
    start_date=Date::parse("2026-08-01").unwrap(),
    rule=DateRule::calendar_days(10),
    start_rule=StartDateRule::exclude(),
    calendar=Calendar::standard(),
    extension=ExtensionPolicy::no_extension(),
  )
  match deadline.calculate() {
    Ok(result) =>
      inspect(result.adjusted_date().to_string(), content="2026-08-11")
    Err(_) => inspect(false, content="true")
  }
}

///|
test "deadline counts five business days after a Friday" {
  let deadline = Deadline::new(
    start_date=Date::parse("2026-08-07").unwrap(),
    rule=DateRule::business_days(5),
    start_rule=StartDateRule::exclude(),
    calendar=Calendar::standard(),
    extension=ExtensionPolicy::no_extension(),
  )
  match deadline.calculate() {
    Ok(result) =>
      inspect(result.adjusted_date().to_string(), content="2026-08-14")
    Err(_) => inspect(false, content="true")
  }
}

///|
test "deadline follows a holiday after natural day counting" {
  let holiday = Date::parse("2026-08-10").unwrap()
  let calendar = Calendar::new(
    name="demo",
    version="2026.1",
    weekend=WeekendPolicy::saturday_sunday(),
    holidays=[holiday],
    extra_workdays=[],
  )
  let deadline = Deadline::new(
    start_date=Date::parse("2026-08-07").unwrap(),
    rule=DateRule::calendar_days(3),
    start_rule=StartDateRule::exclude(),
    calendar~,
    extension=ExtensionPolicy::following(),
  )
  match deadline.calculate() {
    Ok(result) => {
      inspect(result.original_date().to_string(), content="2026-08-10")
      inspect(result.adjusted_date().to_string(), content="2026-08-11")
    }
    Err(_) => inspect(false, content="true")
  }
}

///|
test "modified following stays in the original month" {
  let deadline = Deadline::new(
    start_date=Date::parse("2026-01-30").unwrap(),
    rule=DateRule::calendar_days(1),
    start_rule=StartDateRule::exclude(),
    calendar=Calendar::standard(),
    extension=ExtensionPolicy::modified_following(),
  )
  match deadline.calculate() {
    Ok(result) =>
      inspect(result.adjusted_date().to_string(), content="2026-01-30")
    Err(_) => inspect(false, content="true")
  }
}

///|
test "sequence applies the first start rule once" {
  let deadline = Deadline::new(
    start_date=Date::parse("2026-08-01").unwrap(),
    rule=DateRule::sequence([
      DateRule::calendar_days(2),
      DateRule::business_days(2),
    ]),
    start_rule=StartDateRule::exclude(),
    calendar=Calendar::standard(),
    extension=ExtensionPolicy::no_extension(),
  )
  match deadline.calculate() {
    Ok(result) =>
      inspect(result.adjusted_date().to_string(), content="2026-08-04")
    Err(_) => inspect(false, content="true")
  }
}

///|
test "month and year rules honor an included start date" {
  let calendar = Calendar::standard()
  let month_deadline = Deadline::new(
    start_date=Date::parse("2026-01-31").unwrap(),
    rule=DateRule::months(1),
    start_rule=StartDateRule::including_start(),
    calendar~,
    extension=ExtensionPolicy::no_extension(),
  )
  let year_deadline = Deadline::new(
    start_date=Date::parse("2024-02-29").unwrap(),
    rule=DateRule::years(1),
    start_rule=StartDateRule::including_start(),
    calendar~,
    extension=ExtensionPolicy::no_extension(),
  )
  inspect(
    month_deadline.calculate().unwrap().adjusted_date().to_string(),
    content="2026-01-31",
  )
  inspect(
    year_deadline.calculate().unwrap().adjusted_date().to_string(),
    content="2024-02-29",
  )
}

///|
test "deadline result exposes audit fields and step details" {
  let deadline = Deadline::new(
    start_date=Date::parse("2026-08-08").unwrap(),
    rule=DateRule::calendar_days(1),
    start_rule=StartDateRule::exclude(),
    calendar=Calendar::standard(),
    extension=ExtensionPolicy::following(),
  )
  let result = deadline.calculate().unwrap()
  inspect(result.start_date().to_string(), content="2026-08-08")
  inspect(result.adjustment_count(), content="1")
  inspect(result.crossed_month(), content="false")
  let steps = result.steps()
  match steps[0].kind() {
    Start => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
  inspect(steps[0].date().to_string(), content="2026-08-08")
  inspect(steps[0].note(), content="start date")
}

///|
test "weeks and empty sequences have explicit semantics" {
  let weekly = Deadline::new(
    start_date=Date::parse("2026-08-07").unwrap(),
    rule=DateRule::weeks(1),
    start_rule=StartDateRule::exclude(),
    calendar=Calendar::standard(),
    extension=ExtensionPolicy::no_extension(),
  )
  let empty = Deadline::new(
    start_date=Date::parse("2026-08-07").unwrap(),
    rule=DateRule::sequence([]),
    start_rule=StartDateRule::exclude(),
    calendar=Calendar::standard(),
    extension=ExtensionPolicy::no_extension(),
  )
  inspect(
    weekly.calculate().unwrap().adjusted_date().to_string(),
    content="2026-08-14",
  )
  inspect(
    empty.calculate().unwrap().adjusted_date().to_string(),
    content="2026-08-07",
  )
}

///|
test "deadline rejects negative counts and date overflow" {
  match
    Deadline::new(
      start_date=Date::parse("2026-08-07").unwrap(),
      rule=DateRule::calendar_days(-1),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    ).calculate() {
    Err(NegativeRuleCount) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
  match
    Deadline::new(
      start_date=Date::parse("9999-12-31").unwrap(),
      rule=DateRule::calendar_days(1),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    ).calculate() {
    Err(DateFailure(OutOfRange)) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}
