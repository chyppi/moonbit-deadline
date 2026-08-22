///|
pub enum SeriesError {
  SeriesInvalidStep
  SeriesReversed
  SeriesOutOfRange
} derive(Debug, Eq, Compare)

///|
pub struct DateSeries {
  start : Date
  end : Date
  step : Int
}

///|
pub struct BusinessDaySeries {
  calendar : Calendar
  start : Date
  end : Date
}
