///|
test "calendar business day count includes an ordinary Friday" {
  let calendar = Calendar::standard()
  let summary = calendar
    .summarize(
      start=Date::parse("2026-08-07").unwrap(),
      end=Date::parse("2026-08-07").unwrap(),
    )
    .unwrap()
  inspect(summary.total_days(), content="1")
  inspect(summary.business_days(), content="1")
  inspect(
    summary.first_business_day().unwrap().to_string(),
    content="2026-08-07",
  )
}

///|
test "calendar closure count includes Sunday" {
  let timeline = CalendarTimeline::between(
    calendar=Calendar::standard(),
    start=Date::parse("2026-08-09").unwrap(),
    end=Date::parse("2026-08-09").unwrap(),
  ).unwrap()
  inspect(timeline.closure_count(), content="1")
  inspect(timeline.business_days().length(), content="0")
  inspect(timeline.closures()[0].kind().to_string(), content="weekend")
}

///|
test "date series contains only congruent points" {
  let series = DateSeries::new(
    start=Date::parse("2026-08-01").unwrap(),
    end=Date::parse("2026-08-11").unwrap(),
    step=5,
  ).unwrap()
  inspect(series.contains(Date::parse("2026-08-06").unwrap()), content="true")
  inspect(series.contains(Date::parse("2026-08-07").unwrap()), content="false")
  inspect(series.collect().unwrap()[2].to_string(), content="2026-08-11")
}

///|
test "business series excludes a holiday weekday" {
  let date = Date::parse("2026-08-10").unwrap()
  let calendar = Calendar::new(
    name="holiday",
    version="1",
    weekend=WeekendPolicy::saturday_sunday(),
    holidays=[date],
    extra_workdays=[],
  )
  let series = BusinessDaySeries::new(
    calendar~,
    start=Date::parse("2026-08-07").unwrap(),
    end=Date::parse("2026-08-11").unwrap(),
  ).unwrap()
  inspect(series.collect().length(), content="2")
  inspect(series.collect()[1].to_string(), content="2026-08-11")
}

///|
test "forecast lookup returns none for an unknown count" {
  let forecast = DeadlineForecast::new(
    start=Date::parse("2026-08-01").unwrap(),
    unit=ForecastUnit::weeks(),
    start_rule=StartDateRule::exclude(),
    calendar=Calendar::standard(),
    extension=ExtensionPolicy::no_extension(),
  )
  let result = forecast.calculate([1, 2]).unwrap()
  match result.get(3) {
    None => inspect(true, content="true")
    Some(_) => inspect(false, content="true")
  }
}

///|
test "rule parser preserves a single supported unit" {
  let rule = DateRule::parse("years:1").unwrap()
  inspect(rule.describe(), content="years:1")
  inspect(rule.estimated_calendar_days(), content="365")
}

///|
test "deadline result summary uses adjusted date" {
  let result = Deadline::new(
      start_date=Date::parse("2026-08-01").unwrap(),
      rule=DateRule::calendar_days(1),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .calculate()
    .unwrap()
  inspect(result.summary(), content="2026-08-01 -> 2026-08-02")
  inspect(result.step_count(), content="3")
}

///|
test "reminder business offset skips weekend" {
  let result = Deadline::new(
      start_date=Date::parse("2026-08-01").unwrap(),
      rule=DateRule::calendar_days(9),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .calculate()
    .unwrap()
  let date = ReminderPlan::new(result, Calendar::standard())
    .add(ReminderRule::business_days_before(1).unwrap())
    .unwrap()
    .calculate()
    .unwrap()[0]
  inspect(date.to_string(), content="2026-08-07")
}

///|
test "matrix ordered output exposes all scenarios" {
  let matrix = DeadlineMatrix::new(
      start=Date::parse("2026-08-01").unwrap(),
      rule=DateRule::calendar_days(1),
      start_rule=StartDateRule::exclude(),
      extension=ExtensionPolicy::no_extension(),
    )
    .add_calendar("one", Calendar::standard())
    .unwrap()
    .add_calendar("two", Calendar::standard())
    .unwrap()
  let names = matrix.calculate().unwrap().ordered()
  inspect(names.length(), content="2")
  inspect(names[1], content="two")
}

///|
test "catalog validation succeeds after lookup" {
  let catalog = CalendarCatalog::new().add(Calendar::standard()).unwrap()
  match catalog.find("standard", "builtin") {
    Some(calendar) =>
      match calendar.validate() {
        Ok(_) => inspect(true, content="true")
        Err(_) => inspect(false, content="true")
      }
    None => inspect(false, content="true")
  }
}

///|
test "audit text includes source metadata even when empty" {
  let calendar = Calendar::standard()
  let result = Deadline::new(
      start_date=Date::parse("2026-08-01").unwrap(),
      rule=DateRule::calendar_days(1),
      start_rule=StartDateRule::exclude(),
      calendar~,
      extension=ExtensionPolicy::no_extension(),
    )
    .calculate()
    .unwrap()
  let text = AuditReport::from_result(result, calendar).to_text()
  inspect(text.contains("source_url="), content="true")
  inspect(text.contains("crossed_year=false"), content="true")
}
