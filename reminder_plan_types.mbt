///|
pub enum ReminderRule {
  CalendarDaysBefore(Int)
  BusinessDaysBefore(Int)
} derive(Debug, Eq, Compare)

///|
pub enum ReminderError {
  ReminderNegativeOffset
  ReminderDuplicateOffset
  ReminderDateFailure
} derive(Debug)

///|
pub struct ReminderPlan {
  result : DeadlineResult
  calendar : Calendar
  rules : Array[ReminderRule]
}
