///|
/// Difference sets between two holiday/workday calendars.
pub struct CalendarDiff {
  only_left : Array[Date]
  only_right : Array[Date]
  shared : Array[Date]
  extra_only_left : Array[Date]
  extra_only_right : Array[Date]
  observed_only_left : Array[Date]
  observed_only_right : Array[Date]
  observed_shared : Array[Date]
}

///|
pub fn CalendarDiff::only_left(self : CalendarDiff) -> Array[Date] {
  self.only_left.copy()
}

///|
pub fn CalendarDiff::only_right(self : CalendarDiff) -> Array[Date] {
  self.only_right.copy()
}

///|
pub fn CalendarDiff::shared(self : CalendarDiff) -> Array[Date] {
  self.shared.copy()
}

///|
pub fn CalendarDiff::extra_workdays_only_left(
  self : CalendarDiff,
) -> Array[Date] {
  self.extra_only_left.copy()
}

///|
pub fn CalendarDiff::extra_workdays_only_right(
  self : CalendarDiff,
) -> Array[Date] {
  self.extra_only_right.copy()
}

///|
/// Observed holidays present only in the left calendar.
pub fn CalendarDiff::observed_holidays_only_left(
  self : CalendarDiff,
) -> Array[Date] {
  self.observed_only_left.copy()
}

///|
/// Observed holidays present only in the right calendar.
pub fn CalendarDiff::observed_holidays_only_right(
  self : CalendarDiff,
) -> Array[Date] {
  self.observed_only_right.copy()
}

///|
/// Observed holidays shared by both calendars.
pub fn CalendarDiff::shared_observed_holidays(
  self : CalendarDiff,
) -> Array[Date] {
  self.observed_shared.copy()
}
