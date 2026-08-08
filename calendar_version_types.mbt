///|
pub enum CalendarVersionError {
  InvalidRange
  MissingVersionMetadata
  ObservationOutOfRange(Date)
} derive(Debug, Eq, Compare)

///|
pub struct CalendarSource {
  name : String
  url : String
} derive(Debug, Eq, Compare)

///|
pub struct CalendarVersion {
  name : String
  region : String
  version : String
  source : CalendarSource
  valid_from : Date
  valid_to : Date
} derive(Debug, Eq, Compare)
