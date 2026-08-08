///|
fn default_version_date() -> Date {
  Date::parse("0001-01-01").unwrap()
}

///|
fn is_within_version(version : CalendarVersion, date : Date) -> Bool {
  version.valid_from <= date && date <= version.valid_to
}

///|
fn observed_closure_date(calendar : Calendar, date : Date) -> Date {
  if !calendar.weekend.is_weekend(date.weekday()) {
    date
  } else {
    let mut candidate = date
    let mut searching = true
    while searching {
      candidate = match candidate.try_add_days(1) {
        Ok(next) => next
        Err(_) => return date
      }
      if !calendar.weekend.is_weekend(candidate.weekday()) {
        searching = false
      }
    }
    candidate
  }
}

///|
pub fn Calendar::observed_date(self : Calendar, date : Date) -> Date {
  observed_closure_date(self, date)
}

///|
pub fn Calendar::with_observed_holidays(
  self : Calendar,
  observed_holidays : Array[Date],
) -> Result[Calendar, CalendarVersionError] {
  if !self.versioned {
    return Err(MissingVersionMetadata)
  }
  let observed = self.observed_holidays.copy()
  for holiday in observed_holidays {
    let closure_date = observed_closure_date(self, holiday)
    if !is_within_version(self.version_metadata(), holiday) ||
      !is_within_version(self.version_metadata(), closure_date) {
      return Err(ObservationOutOfRange(holiday))
    }
    observed.push(closure_date)
  }
  observed.sort()
  observed.dedup()
  Ok({
    name: self.name,
    version: self.version,
    region: self.region,
    source: self.source,
    valid_from: self.valid_from,
    valid_to: self.valid_to,
    versioned: self.versioned,
    weekend: self.weekend,
    holidays: self.holidays,
    extra_workdays: self.extra_workdays,
    observed_holidays: observed,
  })
}

///|
fn Calendar::version_metadata(self : Calendar) -> CalendarVersion {
  {
    name: self.name,
    region: self.region,
    version: self.version,
    source: self.source,
    valid_from: self.valid_from,
    valid_to: self.valid_to,
  }
}
