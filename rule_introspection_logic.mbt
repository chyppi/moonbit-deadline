///|
/// Validate every count in a nested rule.
pub fn DateRule::validate(self : DateRule) -> Result[Unit, RuleError] {
  match self {
    CalendarDays(count)
    | BusinessDays(count)
    | Weeks(count)
    | Months(count)
    | Years(count) => if count < 0 { Err(RuleNegativeCount) } else { Ok(()) }
    Sequence(rules) => {
      for rule in rules {
        match rule.validate() {
          Ok(_) => ()
          Err(error) => return Err(error)
        }
      }
      Ok(())
    }
  }
}

///|
/// Render a machine-readable compact rule description.
pub fn DateRule::describe(self : DateRule) -> String {
  match self {
    CalendarDays(count) => "calendar-days:" + count.to_string()
    BusinessDays(count) => "business-days:" + count.to_string()
    Weeks(count) => "weeks:" + count.to_string()
    Months(count) => "months:" + count.to_string()
    Years(count) => "years:" + count.to_string()
    Sequence(rules) => {
      let descriptions = [ for rule in rules => rule.describe() ]
      descriptions.join(",")
    }
  }
}

///|
/// Return a conservative calendar-day estimate for planning UIs.
pub fn DateRule::estimated_calendar_days(self : DateRule) -> Int {
  match self {
    CalendarDays(count) => count
    BusinessDays(count) => count
    Weeks(count) => count * 7
    Months(count) => count * 30
    Years(count) => count * 365
    Sequence(rules) =>
      rules.fold(init=0, (total, rule) => total + rule.estimated_calendar_days())
  }
}
