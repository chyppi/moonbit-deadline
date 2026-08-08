///|
pub fn DateRange::contains(self : DateRange, date : Date) -> Bool {
  self.start <= date && date <= self.end
}

///|
pub fn DateRange::overlaps(self : DateRange, other : DateRange) -> Bool {
  self.start <= other.end && other.start <= self.end
}

///|
pub fn DateRange::intersection(
  self : DateRange,
  other : DateRange,
) -> Result[DateRange, DateRangeError] {
  if !self.overlaps(other) {
    Err(NoIntersection)
  } else {
    let start = if self.start >= other.start { self.start } else { other.start }
    let end = if self.end <= other.end { self.end } else { other.end }
    Ok({ start, end })
  }
}

///|
pub fn DateRange::union(
  self : DateRange,
  other : DateRange,
) -> Result[DateRange, DateRangeError] {
  let (left, right) = if self.start <= other.start {
    (self, other)
  } else {
    (other, self)
  }
  let left_end = days_from_civil(left.end.year, left.end.month, left.end.day)
  let right_start = days_from_civil(
    right.start.year,
    right.start.month,
    right.start.day,
  )
  if right_start - left_end > 1 {
    Err(NoIntersection)
  } else {
    let end = if left.end >= right.end { left.end } else { right.end }
    Ok({ start: left.start, end })
  }
}

///|
pub fn DateRange::calendar_days(self : DateRange) -> Int {
  days_from_civil(self.end.year, self.end.month, self.end.day) -
  days_from_civil(self.start.year, self.start.month, self.start.day) +
  1
}

///|
pub fn DateRange::business_days(self : DateRange, calendar : Calendar) -> Int {
  let mut current = self.start
  let mut count = 0
  while current != self.end {
    if calendar.is_business_day(current) {
      count = count + 1
    }
    current = match current.try_add_days(1) {
      Ok(next) => next
      Err(_) => panic()
    }
  }
  if calendar.is_business_day(current) {
    count = count + 1
  }
  count
}
