///|
test "deadline forecast compares several counts in stable order" {
  let forecast = DeadlineForecast::new(
    start=Date::parse("2026-08-07").unwrap(),
    unit=ForecastUnit::business_days(),
    start_rule=StartDateRule::exclude(),
    calendar=Calendar::standard(),
    extension=ExtensionPolicy::no_extension(),
  )
  let result = forecast.calculate([1, 3, 5]).unwrap()
  inspect(result.counts()[0], content="1")
  inspect(result.dates()[0].to_string(), content="2026-08-10")
  inspect(result.dates()[2].to_string(), content="2026-08-14")
  inspect(result.get(3).unwrap().to_string(), content="2026-08-12")
}

///|
test "deadline forecast supports months and rejects invalid counts" {
  let forecast = DeadlineForecast::new(
    start=Date::parse("2026-01-31").unwrap(),
    unit=ForecastUnit::months(),
    start_rule=StartDateRule::exclude(),
    calendar=Calendar::standard(),
    extension=ExtensionPolicy::no_extension(),
  )
  inspect(
    forecast.calculate([1, 2]).unwrap().dates()[1].to_string(),
    content="2026-03-31",
  )
  match forecast.calculate([0, -1]) {
    Err(ForecastNegativeCount) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}

///|
test "deadline forecast rejects an empty request" {
  let forecast = DeadlineForecast::new(
    start=Date::parse("2026-08-07").unwrap(),
    unit=ForecastUnit::calendar_days(),
    start_rule=StartDateRule::exclude(),
    calendar=Calendar::standard(),
    extension=ExtensionPolicy::no_extension(),
  )
  match forecast.calculate([]) {
    Err(ForecastEmpty) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}
