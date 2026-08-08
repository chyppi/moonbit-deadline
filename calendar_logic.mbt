///|
pub fn Calendar::is_business_day(self : Calendar, date : Date) -> Bool {
  if self.extra_workdays.contains(date) {
    true
  } else if self.holidays.contains(date) {
    false
  } else {
    !self.weekend.is_weekend(date.weekday())
  }
}

///|
pub fn Calendar::next_business_day(
  self : Calendar,
  date : Date,
) -> Result[Date, CalendarError] {
  let mut candidate = date
  let mut attempts = 0
  while attempts < 3660 {
    if self.is_business_day(candidate) {
      return Ok(candidate)
    }
    candidate = candidate.add_days(1)
    attempts = attempts + 1
  }
  Err(SearchLimitExceeded)
}

///|
pub fn Calendar::previous_business_day(
  self : Calendar,
  date : Date,
) -> Result[Date, CalendarError] {
  let mut candidate = date
  let mut attempts = 0
  while attempts < 3660 {
    if self.is_business_day(candidate) {
      return Ok(candidate)
    }
    candidate = candidate.add_days(-1)
    attempts = attempts + 1
  }
  Err(SearchLimitExceeded)
}

///|
pub fn Calendar::advance_business_days(
  self : Calendar,
  start : Date,
  count : Int,
  include_start? : Bool = false,
) -> Result[Date, CalendarError] {
  if count < 0 {
    return Err(NegativeBusinessDayCount)
  }
  let mut candidate = start
  let mut remaining = count
  if include_start && self.is_business_day(candidate) && remaining > 0 {
    remaining = remaining - 1
  }
  let mut attempts = 0
  while remaining > 0 && attempts < 3660 {
    candidate = candidate.add_days(1)
    if self.is_business_day(candidate) {
      remaining = remaining - 1
    }
    attempts = attempts + 1
  }
  if remaining == 0 {
    Ok(candidate)
  } else {
    Err(SearchLimitExceeded)
  }
}
