///|
pub enum DateRangeError {
  Reversed
  OutOfRange
  NoIntersection
} derive(Debug, Eq, Compare)

///|
pub struct DateRange {
  start : Date
  end : Date
} derive(Debug, Eq, Compare)

///|
pub fn DateRange::closed(
  start~ : Date,
  end~ : Date,
) -> Result[DateRange, DateRangeError] {
  if start > end {
    Err(Reversed)
  } else {
    Ok({ start, end })
  }
}

///|
pub fn DateRange::single(date : Date) -> DateRange {
  { start: date, end: date }
}

///|
fn _date_range_out_of_range() -> DateRangeError {
  OutOfRange
}
