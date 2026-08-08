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
  weekend : WeekendPolicy
  holidays : Array[Date]
  extra_workdays : Array[Date]
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
    weekend,
    holidays: normalize_dates(holidays),
    extra_workdays: normalize_dates(extra_workdays),
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
fn normalize_dates(dates : Array[Date]) -> Array[Date] {
  let normalized = dates.copy()
  normalized.sort()
  normalized.dedup()
  normalized
}
