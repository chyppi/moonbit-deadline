///|
pub fn Calendar::is_business_day(self : Calendar, date : Date) -> Bool {
  if self.extra_workdays.contains(date) {
    true
  } else if self.holidays.contains(date) ||
    self.observed_holidays.contains(date) {
    false
  } else {
    !self.weekend.is_weekend(date.weekday())
  }
}

///|
pub fn Calendar::with_version(
  self : Calendar,
  version : CalendarVersion,
) -> Calendar {
  {
    name: version.name,
    version: version.version,
    region: version.region,
    source: version.source,
    valid_from: version.valid_from,
    valid_to: version.valid_to,
    versioned: true,
    weekend: self.weekend,
    holidays: self.holidays,
    extra_workdays: self.extra_workdays,
    observed_holidays: self.observed_holidays,
  }
}

///|
pub fn Calendar::next_business_day(
  self : Calendar,
  date : Date,
) -> Result[Date, CalendarError] {
  let mut candidate = date
  let mut searching = true
  let mut result = Err(DateOutOfRange)
  while searching {
    if self.is_business_day(candidate) {
      result = Ok(candidate)
      searching = false
    } else {
      match candidate.try_add_days(1) {
        Ok(next) => candidate = next
        Err(_) => searching = false
      }
    }
  }
  result
}

///|
pub fn Calendar::previous_business_day(
  self : Calendar,
  date : Date,
) -> Result[Date, CalendarError] {
  let mut candidate = date
  let mut searching = true
  let mut result = Err(DateOutOfRange)
  while searching {
    if self.is_business_day(candidate) {
      result = Ok(candidate)
      searching = false
    } else {
      match candidate.try_add_days(-1) {
        Ok(previous) => candidate = previous
        Err(_) => searching = false
      }
    }
  }
  result
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
  while remaining > 0 {
    candidate = match candidate.try_add_days(1) {
      Ok(next) => next
      Err(_) => return Err(DateOutOfRange)
    }
    if self.is_business_day(candidate) {
      remaining = remaining - 1
    }
  }
  Ok(candidate)
}
