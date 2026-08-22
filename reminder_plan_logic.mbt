///|
/// Create a reminder plan for one calculated deadline.
pub fn ReminderPlan::new(
  result : DeadlineResult,
  calendar : Calendar,
) -> ReminderPlan {
  { result, calendar, rules: [] }
}

///|
/// Create a calendar-day reminder rule.
pub fn ReminderRule::calendar_days_before(
  count : Int,
) -> Result[ReminderRule, ReminderError] {
  if count < 0 {
    Err(ReminderNegativeOffset)
  } else {
    Ok(CalendarDaysBefore(count))
  }
}

///|
/// Create a business-day reminder rule.
pub fn ReminderRule::business_days_before(
  count : Int,
) -> Result[ReminderRule, ReminderError] {
  if count < 0 {
    Err(ReminderNegativeOffset)
  } else {
    Ok(BusinessDaysBefore(count))
  }
}

///|
/// Add a unique offset rule.
pub fn ReminderPlan::add(
  self : ReminderPlan,
  rule : ReminderRule,
) -> Result[ReminderPlan, ReminderError] {
  for existing in self.rules {
    if existing == rule {
      return Err(ReminderDuplicateOffset)
    }
  }
  let rules = self.rules.copy()
  rules.push(rule)
  Ok({ ..self, rules, })
}

///|
/// Calculate reminders in configured order.
pub fn ReminderPlan::calculate(
  self : ReminderPlan,
) -> Result[Array[Date], ReminderError] {
  let reminders = Array::new()
  for rule in self.rules {
    match rule {
      CalendarDaysBefore(count) =>
        match self.result.adjusted_date().try_add_days(-count) {
          Ok(date) => reminders.push(date)
          Err(_) => return Err(ReminderDateFailure)
        }
      BusinessDaysBefore(count) => {
        let mut current = self.result.adjusted_date()
        let mut remaining = count
        while remaining > 0 {
          current = match current.try_add_days(-1) {
            Ok(date) => date
            Err(_) => return Err(ReminderDateFailure)
          }
          if self.calendar.is_business_day(current) {
            remaining = remaining - 1
          }
        }
        reminders.push(current)
      }
    }
  }
  Ok(reminders)
}
