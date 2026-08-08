///|
fn suspension_date(text : String) -> Date {
  Date::parse(text).unwrap()
}

///|
fn inclusive_set(periods : Array[SuspensionPeriod]) -> SuspensionSet {
  SuspensionSet::new(periods~, policy=SuspensionPolicy::pause_inclusive())
}

///|
fn exclusive_set(periods : Array[SuspensionPeriod]) -> SuspensionSet {
  SuspensionSet::new(periods~, policy=SuspensionPolicy::pause_exclusive())
}

///|
test "suspension normalization merges shared endpoints without double-counting" {
  let set = inclusive_set([
    SuspensionPeriod::new(
      start=suspension_date("2026-06-10"),
      end=suspension_date("2026-06-12"),
    ).unwrap(),
    SuspensionPeriod::new(
      start=suspension_date("2026-06-12"),
      end=suspension_date("2026-06-15"),
    ).unwrap(),
  ]).normalize()
  let periods = set.periods()
  inspect(periods.length(), content="1")
  inspect(periods[0].start().to_string(), content="2026-06-10")
  inspect(periods[0].end().to_string(), content="2026-06-15")
  inspect(set.calendar_days(), content="6")
}

///|
test "suspension period rejects reversed dates" {
  match
    SuspensionPeriod::new(
      start=suspension_date("2026-06-15"),
      end=suspension_date("2026-06-12"),
    ) {
    Err(Reversed) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}

///|
test "pause exclusive excludes single-day and adjacent endpoints" {
  let single_day = exclusive_set([
    SuspensionPeriod::new(
      start=suspension_date("2026-06-10"),
      end=suspension_date("2026-06-10"),
    ).unwrap(),
  ]).normalize()
  inspect(single_day.calendar_days(), content="0")

  let adjacent = exclusive_set([
    SuspensionPeriod::new(
      start=suspension_date("2026-06-10"),
      end=suspension_date("2026-06-11"),
    ).unwrap(),
    SuspensionPeriod::new(
      start=suspension_date("2026-06-12"),
      end=suspension_date("2026-06-13"),
    ).unwrap(),
  ]).normalize()
  inspect(adjacent.calendar_days(), content="2")
}

///|
test "suspension business-day counting uses the supplied calendar" {
  let set = inclusive_set([
    SuspensionPeriod::new(
      start=suspension_date("2026-08-07"),
      end=suspension_date("2026-08-10"),
    ).unwrap(),
  ])
  inspect(set.business_days(Calendar::standard()), content="2")
  let exclusive = exclusive_set(set.periods())
  inspect(exclusive.business_days(Calendar::standard()), content="0")
}
