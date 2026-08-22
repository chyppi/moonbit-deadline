///|
/// A deterministic summary of a calendar over a closed date range.
pub struct CalendarSummary {
  start : Date
  end : Date
  total_days : Int
  business_days : Int
  weekend_days : Int
  holiday_days : Int
  observed_holiday_days : Int
  extra_workdays : Int
  first_business : Date?
  last_business : Date?
}

///|
pub fn CalendarSummary::start(self : CalendarSummary) -> Date {
  self.start
}

///|
pub fn CalendarSummary::end(self : CalendarSummary) -> Date {
  self.end
}

///|
pub fn CalendarSummary::total_days(self : CalendarSummary) -> Int {
  self.total_days
}

///|
pub fn CalendarSummary::business_days(self : CalendarSummary) -> Int {
  self.business_days
}

///|
pub fn CalendarSummary::weekend_days(self : CalendarSummary) -> Int {
  self.weekend_days
}

///|
pub fn CalendarSummary::holiday_days(self : CalendarSummary) -> Int {
  self.holiday_days
}

///|
pub fn CalendarSummary::observed_holiday_days(self : CalendarSummary) -> Int {
  self.observed_holiday_days
}

///|
pub fn CalendarSummary::extra_workdays(self : CalendarSummary) -> Int {
  self.extra_workdays
}

///|
pub fn CalendarSummary::first_business_day(self : CalendarSummary) -> Date? {
  self.first_business
}

///|
pub fn CalendarSummary::last_business_day(self : CalendarSummary) -> Date? {
  self.last_business
}
