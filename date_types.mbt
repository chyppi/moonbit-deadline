///|
pub enum Weekday {
  Monday
  Tuesday
  Wednesday
  Thursday
  Friday
  Saturday
  Sunday
} derive(Debug, Eq, Compare)

///|
pub fn Weekday::is_monday(self : Weekday) -> Bool {
  match self {
    Monday => true
    _ => false
  }
}

///|
/// Construct a Monday weekday value for recurring schedules.
pub fn Weekday::monday() -> Weekday {
  Monday
}

///|
/// Construct a Tuesday weekday value for recurring schedules.
pub fn Weekday::tuesday() -> Weekday {
  Tuesday
}

///|
/// Construct a Wednesday weekday value for recurring schedules.
pub fn Weekday::wednesday() -> Weekday {
  Wednesday
}

///|
/// Construct a Thursday weekday value for recurring schedules.
pub fn Weekday::thursday() -> Weekday {
  Thursday
}

///|
/// Construct a Friday weekday value for recurring schedules.
pub fn Weekday::friday() -> Weekday {
  Friday
}

///|
/// Construct a Saturday weekday value for recurring schedules.
pub fn Weekday::saturday() -> Weekday {
  Saturday
}

///|
/// Construct a Sunday weekday value for recurring schedules.
pub fn Weekday::sunday() -> Weekday {
  Sunday
}

///|
pub fn Weekday::to_string(self : Weekday) -> String {
  match self {
    Monday => "Monday"
    Tuesday => "Tuesday"
    Wednesday => "Wednesday"
    Thursday => "Thursday"
    Friday => "Friday"
    Saturday => "Saturday"
    Sunday => "Sunday"
  }
}

///|
pub enum DateError {
  OutOfRange
  InvalidYear
  InvalidMonth
  InvalidDay
  InvalidFormat
  InvalidNumber
} derive(Debug, Eq, Compare)

///|
pub struct Date {
  year : Int
  month : Int
  day : Int
} derive(Debug, Eq, Compare)

///|
pub fn Date::new(
  year~ : Int,
  month~ : Int,
  day~ : Int,
) -> Result[Date, DateError] {
  if year < 1 || year > 9999 {
    Err(InvalidYear)
  } else if month < 1 || month > 12 {
    Err(InvalidMonth)
  } else if day < 1 || day > days_in_month(year, month) {
    Err(InvalidDay)
  } else {
    Ok({ year, month, day })
  }
}

///|
pub fn Date::weekday(self : Date) -> Weekday {
  let serial = days_from_civil(self.year, self.month, self.day)
  let mut index = serial % 7 + 3
  while index < 0 {
    index = index + 7
  }
  index = index % 7
  match index {
    0 => Monday
    1 => Tuesday
    2 => Wednesday
    3 => Thursday
    4 => Friday
    5 => Saturday
    _ => Sunday
  }
}

///|
pub fn Date::to_string(self : Date) -> String {
  self.year.to_string().pad_start(4, '0') +
  "-" +
  self.month.to_string().pad_start(2, '0') +
  "-" +
  self.day.to_string().pad_start(2, '0')
}
