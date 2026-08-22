///|
pub enum ScheduleRule {
  EveryCalendarDays(Int)
  EveryBusinessDays(Int)
  WeeklyOn(Weekday, Int)
  MonthlyOn(Int, Int)
} derive(Debug, Eq, Compare)

///|
pub fn ScheduleRule::every_calendar_days(interval : Int) -> ScheduleRule {
  EveryCalendarDays(interval)
}

///|
pub fn ScheduleRule::every_business_days(interval : Int) -> ScheduleRule {
  EveryBusinessDays(interval)
}

///|
pub fn ScheduleRule::weekly_on(
  weekday~ : Weekday,
  interval~ : Int,
) -> ScheduleRule {
  WeeklyOn(weekday, interval)
}

///|
pub fn ScheduleRule::monthly_on(day~ : Int, interval~ : Int) -> ScheduleRule {
  MonthlyOn(day, interval)
}

///|
pub enum ScheduleError {
  ScheduleInvalidInterval
  ScheduleInvalidCount
  ScheduleDateFailure(DateError)
  ScheduleCalendarFailure(CalendarError)
} derive(Debug)

///|
pub struct ObligationSchedule {
  start : Date
  rule : ScheduleRule
  calendar : Calendar
  extension : ExtensionPolicy
}
