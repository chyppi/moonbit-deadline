///|
test "calendar filters return business and closure dates in order" {
  let calendar = Calendar::new(
    name="demo",
    version="1",
    weekend=WeekendPolicy::saturday_sunday(),
    holidays=[Date::parse("2026-08-10").unwrap()],
    extra_workdays=[Date::parse("2026-08-08").unwrap()],
  )
  let business = calendar
    .dates_between(
      start=Date::parse("2026-08-07").unwrap(),
      end=Date::parse("2026-08-10").unwrap(),
      filter=CalendarDateFilter::business_days(),
    )
    .unwrap()
  inspect(business.length(), content="2")
  inspect(business[1].to_string(), content="2026-08-08")
  let closures = calendar
    .dates_between(
      start=Date::parse("2026-08-07").unwrap(),
      end=Date::parse("2026-08-10").unwrap(),
      filter=CalendarDateFilter::closures(),
    )
    .unwrap()
  inspect(closures.length(), content="2")
  inspect(closures[0].to_string(), content="2026-08-09")
}

///|
test "calendar filters reject reversed ranges" {
  match
    Calendar::standard().dates_between(
      start=Date::parse("2026-08-10").unwrap(),
      end=Date::parse("2026-08-07").unwrap(),
      filter=CalendarDateFilter::holidays(),
    ) {
    Err(CalendarInvalidRange) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}
