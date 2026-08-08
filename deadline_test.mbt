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
