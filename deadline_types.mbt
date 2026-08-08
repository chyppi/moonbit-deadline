///|
pub enum StepKind {
  Start
  Count
  Extension
  Complete
} derive(Debug, Eq, Compare)

///|
pub struct CalculationStep {
  kind : StepKind
  date : Date
  note : String
} derive(Debug)

///|
pub enum DeadlineError {
  NegativeRuleCount
  CalendarFailure(CalendarError)
} derive(Debug)

///|
pub struct Deadline {
  start_date : Date
  rule : DateRule
  start_rule : StartDateRule
  calendar : Calendar
  extension : ExtensionPolicy
} derive(Debug)

///|
pub fn Deadline::new(
  start_date~ : Date,
  rule~ : DateRule,
  start_rule~ : StartDateRule,
  calendar~ : Calendar,
  extension~ : ExtensionPolicy,
) -> Deadline {
  { start_date, rule, start_rule, calendar, extension }
}

///|
pub struct DeadlineResult {
  original : Date
  adjusted : Date
  steps : Array[CalculationStep]
  explanation : String
} derive(Debug)

///|
pub fn DeadlineResult::original_date(self : DeadlineResult) -> Date {
  self.original
}

///|
pub fn DeadlineResult::adjusted_date(self : DeadlineResult) -> Date {
  self.adjusted
}

///|
pub fn DeadlineResult::steps(self : DeadlineResult) -> Array[CalculationStep] {
  self.steps.copy()
}

///|
pub fn DeadlineResult::explain(self : DeadlineResult) -> String {
  self.explanation
}
