///|
pub enum ForecastUnit {
  CalendarDays
  BusinessDays
  Weeks
  Months
  Years
} derive(Debug, Eq, Compare)

///|
pub fn ForecastUnit::calendar_days() -> ForecastUnit {
  CalendarDays
}

///|
pub fn ForecastUnit::business_days() -> ForecastUnit {
  BusinessDays
}

///|
pub fn ForecastUnit::weeks() -> ForecastUnit {
  Weeks
}

///|
pub fn ForecastUnit::months() -> ForecastUnit {
  Months
}

///|
pub fn ForecastUnit::years() -> ForecastUnit {
  Years
}

///|
pub enum ForecastError {
  ForecastEmpty
  ForecastNegativeCount
  ForecastDeadlineFailure(DeadlineError)
} derive(Debug)

///|
pub struct DeadlineForecast {
  start : Date
  unit : ForecastUnit
  start_rule : StartDateRule
  calendar : Calendar
  extension : ExtensionPolicy
}

///|
pub struct ForecastResult {
  counts : Array[Int]
  dates : Array[Date]
}
