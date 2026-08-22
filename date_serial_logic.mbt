///|
fn ordinal_epoch() -> Int {
  days_from_civil(1, 1, 1)
}

///|
/// Return a zero-based ordinal suitable for compact storage.
pub fn Date::ordinal(self : Date) -> Int {
  days_from_civil(self.year, self.month, self.day) - ordinal_epoch()
}

///|
/// Restore a date from a zero-based ordinal.
pub fn Date::from_ordinal(ordinal : Int) -> Result[Date, DateError] {
  if ordinal < 0 {
    return Err(OutOfRange)
  }
  let (year, month, day) = civil_from_days(ordinal + ordinal_epoch())
  if year < 1 || year > 9999 {
    Err(OutOfRange)
  } else {
    Ok({ year, month, day })
  }
}
