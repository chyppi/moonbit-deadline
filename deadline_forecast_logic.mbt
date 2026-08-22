///|
/// Create a forecast for one rule family.
pub fn DeadlineForecast::new(
  start~ : Date,
  unit~ : ForecastUnit,
  start_rule~ : StartDateRule,
  calendar~ : Calendar,
  extension~ : ExtensionPolicy,
) -> DeadlineForecast {
  { start, unit, start_rule, calendar, extension }
}

///|
/// Evaluate each requested count without reordering the input.
pub fn DeadlineForecast::calculate(
  self : DeadlineForecast,
  counts : Array[Int],
) -> Result[ForecastResult, ForecastError] {
  if counts.is_empty() {
    return Err(ForecastEmpty)
  }
  let dates = Array::new()
  for count in counts {
    if count < 0 {
      return Err(ForecastNegativeCount)
    }
    let rule = match self.unit {
      CalendarDays => DateRule::calendar_days(count)
      BusinessDays => DateRule::business_days(count)
      Weeks => DateRule::weeks(count)
      Months => DateRule::months(count)
      Years => DateRule::years(count)
    }
    let deadline = Deadline::new(
      start_date=self.start,
      rule~,
      start_rule=self.start_rule,
      calendar=self.calendar,
      extension=self.extension,
    )
    match deadline.calculate() {
      Ok(result) => dates.push(result.adjusted_date())
      Err(error) => return Err(ForecastDeadlineFailure(error))
    }
  }
  Ok({ counts: counts.copy(), dates })
}

///|
pub fn ForecastResult::counts(self : ForecastResult) -> Array[Int] {
  self.counts.copy()
}

///|
pub fn ForecastResult::dates(self : ForecastResult) -> Array[Date] {
  self.dates.copy()
}

///|
pub fn ForecastResult::get(self : ForecastResult, count : Int) -> Date? {
  let mut index = 0
  while index < self.counts.length() {
    if self.counts[index] == count {
      return Some(self.dates[index])
    }
    index = index + 1
  }
  None
}
