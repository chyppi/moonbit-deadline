///|
/// Create an inclusive date-window constraint.
pub fn DeadlineConstraint::within(
  start~ : Date,
  end~ : Date,
) -> Result[DeadlineConstraint, ConstraintError] {
  if start > end {
    Err(ConstraintInvalidRange)
  } else {
    Ok(Within(start, end))
  }
}

///|
/// Require the calculated date to be a business day.
pub fn DeadlineConstraint::must_be_business_day() -> DeadlineConstraint {
  MustBeBusinessDay
}

///|
/// Reject a result that crosses a calendar year from its start.
pub fn DeadlineConstraint::not_crossing_year() -> DeadlineConstraint {
  NotCrossingYear
}

///|
/// Create a deadline with no constraints.
pub fn ConstrainedDeadline::new(
  start_date~ : Date,
  rule~ : DateRule,
  start_rule~ : StartDateRule,
  calendar~ : Calendar,
  extension~ : ExtensionPolicy,
) -> ConstrainedDeadline {
  { start_date, rule, start_rule, calendar, extension, constraints: [] }
}

///|
/// Add one validated constraint.
pub fn ConstrainedDeadline::add_constraint(
  self : ConstrainedDeadline,
  constraint : DeadlineConstraint,
) -> Result[ConstrainedDeadline, ConstraintError] {
  let constraints = self.constraints.copy()
  constraints.push(constraint)
  Ok({ ..self, constraints, })
}

///|
/// Calculate and enforce every constraint in insertion order.
pub fn ConstrainedDeadline::calculate(
  self : ConstrainedDeadline,
) -> Result[DeadlineResult, ConstraintError] {
  let deadline = Deadline::new(
    start_date=self.start_date,
    rule=self.rule,
    start_rule=self.start_rule,
    calendar=self.calendar,
    extension=self.extension,
  )
  let result = match deadline.calculate() {
    Ok(value) => value
    Err(error) => return Err(ConstraintDeadlineFailure(error))
  }
  for constraint in self.constraints {
    match constraint {
      Within(start, end) =>
        if result.adjusted_date() < start || result.adjusted_date() > end {
          return Err(ConstraintViolation("within"))
        }
      MustBeBusinessDay =>
        if !self.calendar.is_business_day(result.adjusted_date()) {
          return Err(ConstraintViolation("must-be-business-day"))
        }
      NotCrossingYear =>
        if result.start_date().year != result.adjusted_date().year {
          return Err(ConstraintViolation("not-crossing-year"))
        }
    }
  }
  Ok(result)
}
