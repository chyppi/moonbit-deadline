///|
pub fn CalendarSource::new(name~ : String, url~ : String) -> CalendarSource {
  { name, url }
}

///|
pub fn CalendarSource::name(self : CalendarSource) -> String {
  self.name
}

///|
pub fn CalendarSource::url(self : CalendarSource) -> String {
  self.url
}

///|
pub fn CalendarVersion::new(
  name~ : String,
  region~ : String,
  version~ : String,
  source~ : CalendarSource,
  valid_from~ : Date,
  valid_to~ : Date,
) -> Result[CalendarVersion, CalendarVersionError] {
  if valid_from > valid_to {
    Err(InvalidRange)
  } else {
    Ok({ name, region, version, source, valid_from, valid_to })
  }
}

///|
pub fn CalendarVersion::name(self : CalendarVersion) -> String {
  self.name
}

///|
pub fn CalendarVersion::region(self : CalendarVersion) -> String {
  self.region
}

///|
pub fn CalendarVersion::version(self : CalendarVersion) -> String {
  self.version
}

///|
pub fn CalendarVersion::source(self : CalendarVersion) -> CalendarSource {
  self.source
}

///|
pub fn CalendarVersion::valid_from(self : CalendarVersion) -> Date {
  self.valid_from
}

///|
pub fn CalendarVersion::valid_to(self : CalendarVersion) -> Date {
  self.valid_to
}
