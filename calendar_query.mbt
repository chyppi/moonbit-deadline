///|
/// Combine a primary calendar with a fallback calendar.
pub fn Calendar::merge(
  primary : Calendar,
  secondary : Calendar,
) -> Result[Calendar, CalendarValidationError] {
  let holidays = normalize_dates(
    concat_dates(primary.holidays, secondary.holidays),
  )
  let extra_workdays = normalize_dates(
    concat_dates(primary.extra_workdays, secondary.extra_workdays),
  )
  let filtered_holidays = remove_dates(holidays, extra_workdays)
  let merged = Calendar::new(
    name=primary.name + "+" + secondary.name,
    version=primary.version + "+" + secondary.version,
    weekend=primary.weekend,
    holidays=filtered_holidays,
    extra_workdays~,
  )
  let observed_holidays = normalize_dates(
    concat_dates(primary.observed_holidays, secondary.observed_holidays),
  )
  let merged = {
    ..merged,
    region: primary.region,
    source: primary.source,
    valid_from: primary.valid_from,
    valid_to: primary.valid_to,
    versioned: primary.versioned,
    observed_holidays,
  }
  merged.validate().map(fn(_) { merged })
}

///|
fn concat_dates(left : Array[Date], right : Array[Date]) -> Array[Date] {
  let result = left.copy()
  for date in right {
    result.push(date)
  }
  result
}

///|
fn remove_dates(dates : Array[Date], removed : Array[Date]) -> Array[Date] {
  let result = Array::new()
  for date in dates {
    if !removed.contains(date) {
      result.push(date)
    }
  }
  result
}

///|
/// Explain the classification of one date under this calendar.
pub fn Calendar::query(self : Calendar, date : Date) -> CalendarDayInfo {
  let kind = if self.extra_workdays.contains(date) {
    BusinessDay
  } else if self.holidays.contains(date) {
    Holiday
  } else if self.observed_holidays.contains(date) {
    ObservedHoliday
  } else if self.weekend.is_weekend(date.weekday()) {
    Weekend
  } else {
    BusinessDay
  }
  { date, kind, calendar_name: self.name, calendar_version: self.version }
}

///|
/// Date returned by a calendar query.
pub fn CalendarDayInfo::date(self : CalendarDayInfo) -> Date {
  self.date
}

///|
/// Classification returned by a calendar query.
pub fn CalendarDayInfo::kind(self : CalendarDayInfo) -> CalendarDayKind {
  self.kind
}

///|
/// Calendar identity returned by a query.
pub fn CalendarDayInfo::calendar_name(self : CalendarDayInfo) -> String {
  self.calendar_name
}

///|
/// Calendar version returned by a query.
pub fn CalendarDayInfo::calendar_version(self : CalendarDayInfo) -> String {
  self.calendar_version
}
