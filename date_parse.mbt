///|
fn parse_fixed_digits(
  text : String,
  start : Int,
  end : Int,
) -> Result[Int, DateError] {
  let mut index = start
  let mut value = 0
  while index < end {
    let code = text.at(index).to_int()
    if code < 48 || code > 57 {
      return Err(InvalidNumber)
    }
    value = value * 10 + code - 48
    index = index + 1
  }
  Ok(value)
}

///|
pub fn Date::parse(text : String) -> Result[Date, DateError] {
  if text.length() != 10 ||
    text.at(4).to_int() != 45 ||
    text.at(7).to_int() != 45 {
    return Err(InvalidFormat)
  }
  let year = parse_fixed_digits(text, 0, 4)
  let month = parse_fixed_digits(text, 5, 7)
  let day = parse_fixed_digits(text, 8, 10)
  match (year, month, day) {
    (Ok(year), Ok(month), Ok(day)) => Date::new(year~, month~, day~)
    _ => Err(InvalidNumber)
  }
}

///|
fn days_in_month(year : Int, month : Int) -> Int {
  match month {
    2 => if is_leap_year(year) { 29 } else { 28 }
    4 | 6 | 9 | 11 => 30
    _ => 31
  }
}

///|
fn is_leap_year(year : Int) -> Bool {
  year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)
}
