///|
pub enum CalendarDateFilter {
  BusinessDays
  Closures
  Holidays
  ObservedHolidays
  ExtraWorkdays
} derive(Debug, Eq, Compare)

///|
pub fn CalendarDateFilter::business_days() -> CalendarDateFilter {
  BusinessDays
}

///|
pub fn CalendarDateFilter::closures() -> CalendarDateFilter {
  Closures
}

///|
pub fn CalendarDateFilter::holidays() -> CalendarDateFilter {
  Holidays
}

///|
pub fn CalendarDateFilter::observed_holidays() -> CalendarDateFilter {
  ObservedHolidays
}

///|
pub fn CalendarDateFilter::extra_workdays() -> CalendarDateFilter {
  ExtraWorkdays
}
