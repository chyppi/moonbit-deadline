///|
pub fn Deadline::calculate(
  self : Deadline,
) -> Result[DeadlineResult, DeadlineError] {
  let steps = Array::new()
  steps.push({ kind: Start, date: self.start_date, note: "start date" })
  let original = match
    evaluate_rule(
      self.rule,
      self.start_date,
      self.start_rule,
      self.calendar,
      steps,
    ) {
    Ok(date) => date
    Err(error) => return Err(error)
  }
  let adjusted = match
    apply_extension(self.extension, original, self.calendar, steps) {
    Ok(date) => date
    Err(error) => return Err(error)
  }
  if adjusted == original {
    steps.push({ kind: Complete, date: adjusted, note: "deadline" })
  } else {
    steps.push({ kind: Complete, date: adjusted, note: "adjusted deadline" })
  }
  Ok({
    original,
    adjusted,
    steps: steps.copy(),
    explanation: render_steps(steps),
  })
}

///|
fn evaluate_rule(
  rule : DateRule,
  start : Date,
  start_rule : StartDateRule,
  calendar : Calendar,
  steps : Array[CalculationStep],
) -> Result[Date, DeadlineError] {
  match rule {
    Sequence(rules) => {
      let mut current = start
      let mut first = true
      for item in rules {
        let policy = if first { start_rule } else { Include }
        current = match evaluate_rule(item, current, policy, calendar, steps) {
          Ok(date) => date
          Err(error) => return Err(error)
        }
        first = false
      }
      Ok(current)
    }
    CalendarDays(count) => {
      if count < 0 {
        return Err(NegativeRuleCount)
      }
      let include_start = start_rule == Include
      let offset = if include_start && count > 0 { count - 1 } else { count }
      let result = start.add_days(offset)
      steps.push({ kind: Count, date: result, note: "calendar days: \{count}" })
      Ok(result)
    }
    BusinessDays(count) => {
      if count < 0 {
        return Err(NegativeRuleCount)
      }
      let include_start = start_rule == Include
      match calendar.advance_business_days(start, count, include_start~) {
        Ok(result) => {
          steps.push({
            kind: Count,
            date: result,
            note: "business days: \{count}",
          })
          Ok(result)
        }
        Err(error) => Err(CalendarFailure(error))
      }
    }
    Weeks(count) => {
      if count < 0 {
        return Err(NegativeRuleCount)
      }
      evaluate_rule(CalendarDays(count * 7), start, start_rule, calendar, steps)
    }
    Months(count) => {
      if count < 0 {
        return Err(NegativeRuleCount)
      }
      let result = start.add_months(count)
      steps.push({
        kind: Count,
        date: result,
        note: "calendar months: \{count}",
      })
      Ok(result)
    }
    Years(count) => {
      if count < 0 {
        return Err(NegativeRuleCount)
      }
      let result = start.add_years(count)
      steps.push({ kind: Count, date: result, note: "calendar years: \{count}" })
      Ok(result)
    }
  }
}

///|
fn apply_extension(
  policy : ExtensionPolicy,
  original : Date,
  calendar : Calendar,
  steps : Array[CalculationStep],
) -> Result[Date, DeadlineError] {
  match policy {
    NoExtension => Ok(original)
    Following =>
      if calendar.is_business_day(original) {
        Ok(original)
      } else {
        match calendar.next_business_day(original) {
          Ok(result) => {
            steps.push({
              kind: Extension,
              date: result,
              note: "following business day",
            })
            Ok(result)
          }
          Err(error) => Err(CalendarFailure(error))
        }
      }
    Preceding =>
      if calendar.is_business_day(original) {
        Ok(original)
      } else {
        match calendar.previous_business_day(original) {
          Ok(result) => {
            steps.push({
              kind: Extension,
              date: result,
              note: "preceding business day",
            })
            Ok(result)
          }
          Err(error) => Err(CalendarFailure(error))
        }
      }
    ModifiedFollowing =>
      if calendar.is_business_day(original) {
        Ok(original)
      } else {
        match calendar.next_business_day(original) {
          Ok(next) =>
            if next.month != original.month {
              match calendar.previous_business_day(original) {
                Ok(result) => {
                  steps.push({
                    kind: Extension,
                    date: result,
                    note: "modified following: preceding business day",
                  })
                  Ok(result)
                }
                Err(error) => Err(CalendarFailure(error))
              }
            } else {
              steps.push({
                kind: Extension,
                date: next,
                note: "modified following business day",
              })
              Ok(next)
            }
          Err(error) => Err(CalendarFailure(error))
        }
      }
  }
}

///|
fn render_steps(steps : Array[CalculationStep]) -> String {
  let mut text = ""
  for step in steps {
    text = text + step.date.to_string() + " — " + step.note + "\n"
  }
  text
}
