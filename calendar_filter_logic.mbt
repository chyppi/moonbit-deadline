///|
fn filter_calendar_date(
  calendar : Calendar,
  date : Date,
  filter : CalendarDateFilter,
) -> Bool {
  match filter {
    BusinessDays => calendar.is_business_day(date)
    Closures => !calendar.is_business_day(date)
    Holidays => calendar.holidays.contains(date)
    ObservedHolidays => calendar.observed_holidays.contains(date)
    ExtraWorkdays => calendar.extra_workdays.contains(date)
  }
}

///|
/// Return dates matching one calendar classification in ascending order.
pub fn Calendar::dates_between(
  self : Calendar,
  start~ : Date,
  end~ : Date,
  filter~ : CalendarDateFilter,
) -> Result[Array[Date], CalendarValidationError] {
  if start > end {
    return Err(CalendarInvalidRange)
  }
  let dates = Array::new()
  let mut current = start
  while true {
    if filter_calendar_date(self, current, filter) {
      dates.push(current)
    }
    if current == end {
      break
    }
    current = match current.try_add_days(1) {
      Ok(value) => value
      Err(_) => return Err(CalendarInvalidRange)
    }
  }
  Ok(dates)
}
