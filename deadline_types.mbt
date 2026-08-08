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
pub fn CalculationStep::kind(self : CalculationStep) -> StepKind {
  self.kind
}

///|
pub fn CalculationStep::date(self : CalculationStep) -> Date {
  self.date
}

///|
pub fn CalculationStep::note(self : CalculationStep) -> String {
  self.note
}

///|
pub enum DeadlineError {
  NegativeRuleCount
  CalendarFailure(CalendarError)
  DateFailure(DateError)
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
  start : Date
  rule : DateRule
  original : Date
  adjusted : Date
  adjustment_count : Int
  crossed_month : Bool
  crossed_year : Bool
  steps : Array[CalculationStep]
  explanation : String
} derive(Debug)

///|
pub fn DeadlineResult::original_date(self : DeadlineResult) -> Date {
  self.original
}

///|
pub fn DeadlineResult::start_date(self : DeadlineResult) -> Date {
  self.start
}

///|
pub fn DeadlineResult::rule(self : DeadlineResult) -> DateRule {
  self.rule
}

///|
pub fn DeadlineResult::adjustment_count(self : DeadlineResult) -> Int {
  self.adjustment_count
}

///|
pub fn DeadlineResult::crossed_month(self : DeadlineResult) -> Bool {
  self.crossed_month
}

///|
pub fn DeadlineResult::crossed_year(self : DeadlineResult) -> Bool {
  self.crossed_year
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
