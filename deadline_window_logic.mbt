///|
/// Inclusive first date of the window.
pub fn DeadlineWindow::start(self : DeadlineWindow) -> Date {
  self.start
}

///|
/// Inclusive last date of the window.
pub fn DeadlineWindow::end(self : DeadlineWindow) -> Date {
  self.end
}

///|
/// Number of calendar days in the window.
pub fn DeadlineWindow::calendar_days(self : DeadlineWindow) -> Int {
  DateRange::closed(start=self.start, end=self.end).unwrap().calendar_days()
}

///|
/// Number of business days in the window.
pub fn DeadlineWindow::business_days(
  self : DeadlineWindow,
  calendar : Calendar,
) -> Int {
  DateRange::closed(start=self.start, end=self.end)
  .unwrap()
  .business_days(calendar)
}

///|
/// Check inclusive membership.
pub fn DeadlineWindow::contains(self : DeadlineWindow, date : Date) -> Bool {
  self.start <= date && date <= self.end
}

///|
/// Check whether two windows share at least one date.
pub fn DeadlineWindow::intersects(
  self : DeadlineWindow,
  other : DeadlineWindow,
) -> Bool {
  self.start <= other.end && other.start <= self.end
}

///|
/// Return the shared closed interval.
pub fn DeadlineWindow::intersection(
  self : DeadlineWindow,
  other : DeadlineWindow,
) -> Result[DeadlineWindow, WindowError] {
  if !self.intersects(other) {
    return Err(WindowReversed)
  }
  let start = if self.start >= other.start { self.start } else { other.start }
  let end = if self.end <= other.end { self.end } else { other.end }
  Ok({ start, end })
}

///|
/// Move the whole window by a calendar-day offset.
pub fn DeadlineWindow::shift(
  self : DeadlineWindow,
  offset : Int,
) -> Result[DeadlineWindow, WindowError] {
  let start = match self.start.try_add_days(offset) {
    Ok(value) => value
    Err(_) => return Err(WindowOutOfRange)
  }
  let end = match self.end.try_add_days(offset) {
    Ok(value) => value
    Err(_) => return Err(WindowOutOfRange)
  }
  Ok({ start, end })
}
