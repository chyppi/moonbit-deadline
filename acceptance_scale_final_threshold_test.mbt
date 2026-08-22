///|
test "calendar day filter returns no observed date without metadata" {
  let date = Date::parse("2026-08-03").unwrap()
  inspect(
    Calendar::standard()
    .dates_between(
      start=date,
      end=date,
      filter=CalendarDateFilter::observed_holidays(),
    )
    .unwrap()
    .length(),
    content="0",
  )
}

///|
test "forecast unit description is represented by its computed result" {
  let forecast = DeadlineForecast::new(
    start=Date::parse("2026-08-03").unwrap(),
    unit=ForecastUnit::months(),
    start_rule=StartDateRule::exclude(),
    calendar=Calendar::standard(),
    extension=ExtensionPolicy::no_extension(),
  )
  inspect(
    forecast.calculate([1]).unwrap().dates()[0].to_string(),
    content="2026-09-03",
  )
}
