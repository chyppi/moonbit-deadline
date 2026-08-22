///|
/// Create a cursor anchored at a date.
pub fn BusinessDayCursor::new(
  date~ : Date,
  calendar~ : Calendar,
) -> BusinessDayCursor {
  { date, calendar }
}

///|
/// Find the first business day after the anchor.
pub fn BusinessDayCursor::next(
  self : BusinessDayCursor,
) -> Result[Date, CursorError] {
  match self.calendar.advance_business_days(self.date, 1) {
    Ok(value) => Ok(value)
    Err(error) => Err(CursorCalendarFailure(error))
  }
}

///|
/// Find the first business day before the anchor.
pub fn BusinessDayCursor::previous(
  self : BusinessDayCursor,
) -> Result[Date, CursorError] {
  let mut current = self.date
  let mut searching = true
  while searching {
    current = match current.try_add_days(-1) {
      Ok(value) => value
      Err(_) => return Err(CursorCalendarFailure(DateOutOfRange))
    }
    if self.calendar.is_business_day(current) {
      searching = false
    }
  }
  Ok(current)
}

///|
/// Collect a forward sequence, excluding the anchor.
pub fn BusinessDayCursor::forward(
  self : BusinessDayCursor,
  count : Int,
) -> Result[Array[Date], CursorError] {
  if count <= 0 {
    return Err(CursorInvalidCount)
  }
  let dates = Array::new()
  let mut current = self.date
  let mut index = 0
  while index < count {
    current = match self.calendar.advance_business_days(current, 1) {
      Ok(value) => value
      Err(error) => return Err(CursorCalendarFailure(error))
    }
    dates.push(current)
    index = index + 1
  }
  Ok(dates)
}
