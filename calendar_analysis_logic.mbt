///|
/// Count calendar classifications over an inclusive interval.
pub fn Calendar::summarize(
  self : Calendar,
  start~ : Date,
  end~ : Date,
) -> Result[CalendarSummary, CalendarValidationError] {
  if start > end {
    return Err(CalendarInvalidRange)
  }
  let mut current = start
  let mut total = 0
  let mut business = 0
  let mut weekend = 0
  let mut holiday = 0
  let mut observed = 0
  let mut extra = 0
  let mut first_business : Date? = None
  let mut last_business : Date? = None
  while true {
    let info = self.query(current)
    total = total + 1
    match info.kind() {
      BusinessDay => {
        business = business + 1
        if first_business == None {
          first_business = Some(current)
        }
        last_business = Some(current)
        if self.extra_workdays.contains(current) {
          extra = extra + 1
        }
      }
      Weekend => weekend = weekend + 1
      Holiday => holiday = holiday + 1
      ObservedHoliday => observed = observed + 1
    }
    if current == end {
      break
    }
    current = match current.try_add_days(1) {
      Ok(value) => value
      Err(_) => return Err(CalendarInvalidRange)
    }
  }
  Ok({
    start,
    end,
    total_days: total,
    business_days: business,
    weekend_days: weekend,
    holiday_days: holiday,
    observed_holiday_days: observed,
    extra_workdays: extra,
    first_business,
    last_business,
  })
}
