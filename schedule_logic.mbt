///|
/// Create a recurring obligation schedule.
pub fn ObligationSchedule::new(
  start~ : Date,
  rule~ : ScheduleRule,
  calendar~ : Calendar,
  extension~ : ExtensionPolicy,
) -> Result[ObligationSchedule, ScheduleError] {
  let valid = match rule {
    EveryCalendarDays(interval) => interval > 0
    EveryBusinessDays(interval) => interval > 0
    WeeklyOn(_, interval) => interval > 0
    MonthlyOn(day, interval) => day >= 1 && day <= 31 && interval > 0
  }
  if !valid {
    Err(ScheduleInvalidInterval)
  } else {
    Ok({ start, rule, calendar, extension })
  }
}

///|
/// Generate a fixed number of occurrences, including the start anchor.
pub fn ObligationSchedule::occurrences(
  self : ObligationSchedule,
  count : Int,
) -> Result[Array[Date], ScheduleError] {
  if count <= 0 {
    return Err(ScheduleInvalidCount)
  }
  let dates = Array::new()
  let mut current = self.start
  match self.rule {
    WeeklyOn(weekday, _) => current = next_weekday(current, weekday)
    _ => ()
  }
  let mut index = 0
  while index < count {
    let mut adjusted = match
      apply_schedule_extension(self.extension, current, self.calendar) {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    // Calendar extensions can map adjacent raw occurrences to the same
    // business date (for example Saturday and Sunday both following to
    // Monday). Skip such raw occurrences so the public schedule is strictly
    // increasing and never emits duplicate obligations.
    let mut searching = true
    while searching {
      match dates.last() {
        None => searching = false
        Some(previous) =>
          if adjusted > previous {
            searching = false
          } else {
            current = match next_occurrence(current, self.rule, self.calendar) {
              Ok(value) => value
              Err(error) => return Err(error)
            }
            adjusted = match
              apply_schedule_extension(self.extension, current, self.calendar) {
              Ok(value) => value
              Err(error) => return Err(error)
            }
          }
      }
    }
    dates.push(adjusted)
    if index + 1 == count {
      break
    }
    current = match next_occurrence(current, self.rule, self.calendar) {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    index = index + 1
  }
  Ok(dates)
}

///|
fn next_occurrence(
  current : Date,
  rule : ScheduleRule,
  calendar : Calendar,
) -> Result[Date, ScheduleError] {
  match rule {
    EveryCalendarDays(interval) =>
      match current.try_add_days(interval) {
        Ok(value) => Ok(value)
        Err(error) => Err(ScheduleDateFailure(error))
      }
    EveryBusinessDays(interval) =>
      match calendar.advance_business_days(current, interval) {
        Ok(value) => Ok(value)
        Err(error) => Err(ScheduleCalendarFailure(error))
      }
    WeeklyOn(_, interval) =>
      match current.try_add_days(interval * 7) {
        Ok(value) => Ok(value)
        Err(error) => Err(ScheduleDateFailure(error))
      }
    MonthlyOn(day, interval) => add_month_anchor(current, day, interval)
  }
}

///|
fn add_month_anchor(
  current : Date,
  day : Int,
  interval : Int,
) -> Result[Date, ScheduleError] {
  match current.try_add_months(interval) {
    Ok(value) =>
      match
        Date::new(
          year=value.year,
          month=value.month,
          day=Int::min(day, days_in_month(value.year, value.month)),
        ) {
        Ok(value) => Ok(value)
        Err(error) => Err(ScheduleDateFailure(error))
      }
    Err(error) => Err(ScheduleDateFailure(error))
  }
}

///|
fn next_weekday(start : Date, target : Weekday) -> Date {
  let mut current = start
  let mut steps = 0
  while current.weekday() != target && steps < 7 {
    current = current.add_days(1)
    steps = steps + 1
  }
  current
}

///|
fn apply_schedule_extension(
  policy : ExtensionPolicy,
  date : Date,
  calendar : Calendar,
) -> Result[Date, ScheduleError] {
  match policy {
    NoExtension => Ok(date)
    Following =>
      if calendar.is_business_day(date) {
        Ok(date)
      } else {
        match calendar.next_business_day(date) {
          Ok(value) => Ok(value)
          Err(error) => Err(ScheduleCalendarFailure(error))
        }
      }
    Preceding =>
      if calendar.is_business_day(date) {
        Ok(date)
      } else {
        match calendar.previous_business_day(date) {
          Ok(value) => Ok(value)
          Err(error) => Err(ScheduleCalendarFailure(error))
        }
      }
    ModifiedFollowing =>
      if calendar.is_business_day(date) {
        Ok(date)
      } else {
        match calendar.next_business_day(date) {
          Ok(next) =>
            if next.month == date.month {
              Ok(next)
            } else {
              match calendar.previous_business_day(date) {
                Ok(value) => Ok(value)
                Err(error) => Err(ScheduleCalendarFailure(error))
              }
            }
          Err(error) => Err(ScheduleCalendarFailure(error))
        }
      }
  }
}
