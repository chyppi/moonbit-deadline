///|
pub enum CalendarValidationError {
  CalendarMissingName
  CalendarMissingVersion
  CalendarInvalidRange
} derive(Debug, Eq, Compare)

///|
/// A small immutable builder for calendars assembled by an application.
pub struct CalendarBuilder {
  name : String
  version : String
  region : String
  source : CalendarSource
  valid_from : Date?
  valid_to : Date?
  weekend : WeekendPolicy
  holidays : Array[Date]
  extra_workdays : Array[Date]
}

///|
pub enum CalendarDayKind {
  BusinessDay
  Weekend
  Holiday
  ObservedHoliday
} derive(Debug, Eq, Compare)

///|
pub fn CalendarDayKind::to_string(self : CalendarDayKind) -> String {
  match self {
    BusinessDay => "business-day"
    Weekend => "weekend"
    Holiday => "holiday"
    ObservedHoliday => "observed-holiday"
  }
}

///|
pub struct CalendarDayInfo {
  date : Date
  kind : CalendarDayKind
  calendar_name : String
  calendar_version : String
}
