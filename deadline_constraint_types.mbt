///|
pub enum DeadlineConstraint {
  Within(Date, Date)
  MustBeBusinessDay
  NotCrossingYear
} derive(Debug, Eq, Compare)

///|
pub enum ConstraintError {
  ConstraintInvalidRange
  ConstraintViolation(String)
  ConstraintDeadlineFailure(DeadlineError)
} derive(Debug)

///|
pub struct ConstrainedDeadline {
  start_date : Date
  rule : DateRule
  start_rule : StartDateRule
  calendar : Calendar
  extension : ExtensionPolicy
  constraints : Array[DeadlineConstraint]
}
