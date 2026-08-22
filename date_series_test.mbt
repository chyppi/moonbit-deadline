///|
test "date series generates inclusive stepped dates" {
  let series = DateSeries::new(
    start=Date::parse("2026-08-01").unwrap(),
    end=Date::parse("2026-08-07").unwrap(),
    step=2,
  ).unwrap()
  let dates = series.collect().unwrap()
  inspect(dates.length(), content="4")
  inspect(dates[0].to_string(), content="2026-08-01")
  inspect(dates[3].to_string(), content="2026-08-07")
  inspect(series.contains(Date::parse("2026-08-05").unwrap()), content="true")
  inspect(series.contains(Date::parse("2026-08-06").unwrap()), content="false")
}

///|
test "business day series filters a calendar range" {
  let series = BusinessDaySeries::new(
    calendar=Calendar::standard(),
    start=Date::parse("2026-08-07").unwrap(),
    end=Date::parse("2026-08-11").unwrap(),
  ).unwrap()
  let dates = series.collect()
  inspect(dates.length(), content="3")
  inspect(dates[1].to_string(), content="2026-08-10")
}

///|
test "date series rejects zero step and reversed intervals" {
  match
    DateSeries::new(
      start=Date::parse("2026-08-01").unwrap(),
      end=Date::parse("2026-08-07").unwrap(),
      step=0,
    ) {
    Err(SeriesInvalidStep) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
  match
    BusinessDaySeries::new(
      calendar=Calendar::standard(),
      start=Date::parse("2026-08-11").unwrap(),
      end=Date::parse("2026-08-07").unwrap(),
    ) {
    Err(SeriesReversed) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}
