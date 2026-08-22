///|
test "date parser rejects short and long forms" {
  match Date::parse("2026-01-1") {
    Err(InvalidFormat) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
  match Date::parse("20260-01-01") {
    Err(InvalidFormat) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
  match Date::parse("2026/01/01") {
    Err(InvalidFormat) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}

///|
test "date parser rejects nonnumeric fields" {
  match Date::parse("20a6-01-01") {
    Err(InvalidNumber) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
  match Date::parse("2026-aa-01") {
    Err(InvalidNumber) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
  match Date::parse("2026-01-aa") {
    Err(InvalidNumber) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}

///|
test "date constructor validates every calendar component" {
  match Date::new(year=0, month=1, day=1) {
    Err(InvalidYear) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
  match Date::new(year=2026, month=0, day=1) {
    Err(InvalidMonth) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
  match Date::new(year=2026, month=13, day=1) {
    Err(InvalidMonth) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
  match Date::new(year=2026, month=4, day=31) {
    Err(InvalidDay) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}

///|
test "date weekday constructors round trip through date values" {
  inspect(
    Date::parse("2026-08-10").unwrap().weekday().to_string(),
    content="Monday",
  )
  inspect(Weekday::monday().to_string(), content="Monday")
  inspect(Weekday::friday().to_string(), content="Friday")
  inspect(Weekday::sunday().to_string(), content="Sunday")
}

///|
test "date ordinal remains monotonic across leap insertion" {
  let before = Date::parse("2024-02-28").unwrap().ordinal()
  let leap = Date::parse("2024-02-29").unwrap().ordinal()
  let after = Date::parse("2024-03-01").unwrap().ordinal()
  inspect(leap - before, content="1")
  inspect(after - leap, content="1")
}

///|
test "date month arithmetic clamps short and long months" {
  inspect(
    Date::parse("2026-05-31").unwrap().add_months(-1).to_string(),
    content="2026-04-30",
  )
  inspect(
    Date::parse("2026-10-31").unwrap().add_months(1).to_string(),
    content="2026-11-30",
  )
  inspect(
    Date::parse("2024-02-29").unwrap().add_months(12).to_string(),
    content="2025-02-28",
  )
}

///|
test "date year arithmetic preserves valid leap day behavior" {
  inspect(
    Date::parse("2020-02-29").unwrap().add_years(4).to_string(),
    content="2024-02-29",
  )
  inspect(
    Date::parse("2020-02-29").unwrap().add_years(-1).to_string(),
    content="2019-02-28",
  )
}

///|
test "date ranges distinguish touching and disjoint intervals" {
  let one = DateRange::closed(
    start=Date::parse("2026-01-01").unwrap(),
    end=Date::parse("2026-01-01").unwrap(),
  ).unwrap()
  let two = DateRange::closed(
    start=Date::parse("2026-01-03").unwrap(),
    end=Date::parse("2026-01-04").unwrap(),
  ).unwrap()
  inspect(one.overlaps(two), content="false")
  match one.union(two) {
    Err(NoIntersection) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
  inspect(one.calendar_days(), content="1")
}

///|
test "date ranges preserve closed endpoint intersections" {
  let left = DateRange::closed(
    start=Date::parse("2026-01-01").unwrap(),
    end=Date::parse("2026-01-03").unwrap(),
  ).unwrap()
  let right = DateRange::closed(
    start=Date::parse("2026-01-03").unwrap(),
    end=Date::parse("2026-01-05").unwrap(),
  ).unwrap()
  inspect(left.intersection(right).unwrap().calendar_days(), content="1")
  inspect(left.union(right).unwrap().calendar_days(), content="5")
}

///|
test "date series accepts a single point" {
  let series = DateSeries::new(
    start=Date::parse("2026-01-01").unwrap(),
    end=Date::parse("2026-01-01").unwrap(),
    step=1,
  ).unwrap()
  inspect(series.collect().unwrap().length(), content="1")
  inspect(series.contains(Date::parse("2026-01-01").unwrap()), content="true")
}
