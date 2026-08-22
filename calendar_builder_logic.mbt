///|
/// Start assembling a calendar with explicit identity and weekend policy.
pub fn CalendarBuilder::new(
  name~ : String,
  version~ : String,
  weekend~ : WeekendPolicy,
) -> CalendarBuilder {
  {
    name,
    version,
    region: "",
    source: CalendarSource::new(name="", url=""),
    valid_from: None,
    valid_to: None,
    weekend,
    holidays: [],
    extra_workdays: [],
  }
}

///|
/// Set a jurisdiction or organization label.
pub fn CalendarBuilder::region(
  self : CalendarBuilder,
  region : String,
) -> CalendarBuilder {
  { ..self, region, }
}

///|
/// Set the source metadata for the assembled calendar.
pub fn CalendarBuilder::source(
  self : CalendarBuilder,
  source : CalendarSource,
) -> CalendarBuilder {
  { ..self, source, }
}

///|
/// Set the inclusive validity interval.
pub fn CalendarBuilder::valid_during(
  self : CalendarBuilder,
  start~ : Date,
  end~ : Date,
) -> CalendarBuilder {
  { ..self, valid_from: Some(start), valid_to: Some(end) }
}

///|
/// Add a holiday. Duplicate dates are removed during build.
pub fn CalendarBuilder::holiday(
  self : CalendarBuilder,
  date : Date,
) -> CalendarBuilder {
  let holidays = self.holidays.copy()
  holidays.push(date)
  { ..self, holidays, }
}

///|
/// Add an exceptional workday, which has priority over closure dates.
pub fn CalendarBuilder::extra_workday(
  self : CalendarBuilder,
  date : Date,
) -> CalendarBuilder {
  let extra_workdays = self.extra_workdays.copy()
  extra_workdays.push(date)
  { ..self, extra_workdays, }
}

///|
/// Validate and build a calendar.
pub fn CalendarBuilder::build(
  self : CalendarBuilder,
) -> Result[Calendar, CalendarValidationError] {
  if self.name.length() == 0 {
    return Err(CalendarMissingName)
  }
  if self.version.length() == 0 {
    return Err(CalendarMissingVersion)
  }
  let valid_from = match self.valid_from {
    Some(value) => value
    None => return build_unversioned(self)
  }
  let valid_to = match self.valid_to {
    Some(value) => value
    None => return Err(CalendarInvalidRange)
  }
  if valid_from > valid_to {
    return Err(CalendarInvalidRange)
  }
  let version = match
    CalendarVersion::new(
      name=self.name,
      region=self.region,
      version=self.version,
      source=self.source,
      valid_from~,
      valid_to~,
    ) {
    Ok(value) => value
    Err(_) => return Err(CalendarInvalidRange)
  }
  let calendar = Calendar::new(
    name=version.name(),
    version=version.version(),
    weekend=self.weekend,
    holidays=normalize_dates(self.holidays),
    extra_workdays=normalize_dates(self.extra_workdays),
  )
  Ok(calendar.with_version(version))
}

///|
fn build_unversioned(
  builder : CalendarBuilder,
) -> Result[Calendar, CalendarValidationError] {
  if builder.valid_to != None {
    return Err(CalendarInvalidRange)
  }
  Ok(
    Calendar::new(
      name=builder.name,
      version=builder.version,
      weekend=builder.weekend,
      holidays=normalize_dates(builder.holidays),
      extra_workdays=normalize_dates(builder.extra_workdays),
    ),
  )
}

///|
/// Validate a calendar assembled by any API.
pub fn Calendar::validate(
  self : Calendar,
) -> Result[Unit, CalendarValidationError] {
  if self.name.length() == 0 {
    return Err(CalendarMissingName)
  }
  if self.version.length() == 0 {
    return Err(CalendarMissingVersion)
  }
  if self.versioned && self.valid_from > self.valid_to {
    return Err(CalendarInvalidRange)
  }
  for holiday in self.holidays {
    if self.extra_workdays.contains(holiday) {
      continue
    }
  }
  Ok(())
}
