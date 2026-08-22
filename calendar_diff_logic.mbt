///|
fn difference(left : Array[Date], right : Array[Date]) -> Array[Date] {
  let result = Array::new()
  for date in left {
    if !right.contains(date) {
      result.push(date)
    }
  }
  result.sort()
  result
}

///|
fn shared_dates(left : Array[Date], right : Array[Date]) -> Array[Date] {
  let result = Array::new()
  for date in left {
    if right.contains(date) {
      result.push(date)
    }
  }
  result.sort()
  result
}

///|
/// Compare closure and exceptional-workday data from two calendars.
pub fn Calendar::diff(left : Calendar, right : Calendar) -> CalendarDiff {
  {
    only_left: difference(left.holidays, right.holidays),
    only_right: difference(right.holidays, left.holidays),
    shared: shared_dates(left.holidays, right.holidays),
    extra_only_left: difference(left.extra_workdays, right.extra_workdays),
    extra_only_right: difference(right.extra_workdays, left.extra_workdays),
    observed_only_left: difference(
      left.observed_holidays,
      right.observed_holidays,
    ),
    observed_only_right: difference(
      right.observed_holidays,
      left.observed_holidays,
    ),
    observed_shared: shared_dates(
      left.observed_holidays,
      right.observed_holidays,
    ),
  }
}

///|
/// Render changed closure dates as stable key/value lines.
pub fn CalendarDiff::to_text(self : CalendarDiff) -> String {
  let mut text = "only-left="
  for date in self.only_left {
    text = text + date.to_string() + ";"
  }
  text = text + "\nonly-right="
  for date in self.only_right {
    text = text + date.to_string() + ";"
  }
  text = text + "\nshared="
  for date in self.shared {
    text = text + date.to_string() + ";"
  }
  text = text + "\nobserved-only-left="
  for date in self.observed_only_left {
    text = text + date.to_string() + ";"
  }
  text = text + "\nobserved-only-right="
  for date in self.observed_only_right {
    text = text + date.to_string() + ";"
  }
  text
}
