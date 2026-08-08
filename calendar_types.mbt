///|
pub enum WeekendPolicy {
  SaturdaySunday
  FridaySaturday
  NoWeekend
} derive(Debug, Eq, Compare)

///|
pub fn WeekendPolicy::saturday_sunday() -> WeekendPolicy {
  SaturdaySunday
}

///|
pub fn WeekendPolicy::friday_saturday() -> WeekendPolicy {
  FridaySaturday
}

///|
pub fn WeekendPolicy::no_weekend() -> WeekendPolicy {
  NoWeekend
}

///|
pub fn WeekendPolicy::is_weekend(
  self : WeekendPolicy,
  weekday : Weekday,
) -> Bool {
  match self {
    SaturdaySunday =>
      match weekday {
        Saturday | Sunday => true
        _ => false
      }
    FridaySaturday =>
      match weekday {
        Friday | Saturday => true
        _ => false
      }
    NoWeekend => false
  }
}

///|
pub enum CalendarError {
  NegativeBusinessDayCount
  DateOutOfRange
} derive(Debug, Eq, Compare)

///|
pub struct Calendar {
  name : String
  version : String
  region : String
  source : CalendarSource
  valid_from : Date
  valid_to : Date
  versioned : Bool
  weekend : WeekendPolicy
  holidays : Array[Date]
  extra_workdays : Array[Date]
  observed_holidays : Array[Date]
} derive(Debug)

///|
pub fn Calendar::new(
  name~ : String,
  version~ : String,
  weekend~ : WeekendPolicy,
  holidays~ : Array[Date],
  extra_workdays~ : Array[Date],
) -> Calendar {
  {
    name,
    version,
    region: "",
    source: CalendarSource::new(name="", url=""),
    valid_from: default_version_date(),
    valid_to: default_version_date(),
    versioned: false,
    weekend,
    holidays: normalize_dates(holidays),
    extra_workdays: normalize_dates(extra_workdays),
    observed_holidays: [],
  }
}

///|
pub fn Calendar::standard() -> Calendar {
  Calendar::new(
    name="standard",
    version="builtin",
    weekend=WeekendPolicy::saturday_sunday(),
    holidays=[],
    extra_workdays=[],
  )
}

///|
pub fn Calendar::name(self : Calendar) -> String {
  self.name
}

///|
pub fn Calendar::version(self : Calendar) -> String {
  self.version
}

///|
pub fn Calendar::region(self : Calendar) -> String {
  self.region
}

///|
pub fn Calendar::source(self : Calendar) -> CalendarSource {
  self.source
}

///|
pub fn Calendar::valid_from(self : Calendar) -> Date {
  self.valid_from
}

///|
pub fn Calendar::valid_to(self : Calendar) -> Date {
  self.valid_to
}

///|
pub fn Calendar::observed_holidays(self : Calendar) -> Array[Date] {
  self.observed_holidays.copy()
}

///|
fn normalize_dates(dates : Array[Date]) -> Array[Date] {
  let normalized = dates.copy()
  normalized.sort()
  normalized.dedup()
  normalized
}
