///|
/// Create an inclusive forward date series.
pub fn DateSeries::new(
  start~ : Date,
  end~ : Date,
  step~ : Int,
) -> Result[DateSeries, SeriesError] {
  if step <= 0 {
    Err(SeriesInvalidStep)
  } else if start > end {
    Err(SeriesReversed)
  } else {
    Ok({ start, end, step })
  }
}

///|
/// Materialize the inclusive date series.
pub fn DateSeries::collect(
  self : DateSeries,
) -> Result[Array[Date], SeriesError] {
  let dates = Array::new()
  let mut current = self.start
  while current <= self.end {
    dates.push(current)
    if current == self.end {
      break
    }
    current = match current.try_add_days(self.step) {
      Ok(value) => value
      Err(_) => return Err(SeriesOutOfRange)
    }
  }
  Ok(dates)
}

///|
/// Check whether a date lies on a generated series point.
pub fn DateSeries::contains(self : DateSeries, date : Date) -> Bool {
  if date < self.start || date > self.end {
    false
  } else {
    (date.ordinal() - self.start.ordinal()) % self.step == 0
  }
}

///|
/// Create a materialized business-day series over a closed interval.
pub fn BusinessDaySeries::new(
  calendar~ : Calendar,
  start~ : Date,
  end~ : Date,
) -> Result[BusinessDaySeries, SeriesError] {
  if start > end {
    Err(SeriesReversed)
  } else {
    Ok({ calendar, start, end })
  }
}

///|
/// Collect only business dates in the interval.
pub fn BusinessDaySeries::collect(self : BusinessDaySeries) -> Array[Date] {
  let dates = Array::new()
  let mut current = self.start
  while true {
    if self.calendar.is_business_day(current) {
      dates.push(current)
    }
    if current == self.end {
      break
    }
    current = match current.try_add_days(1) {
      Ok(value) => value
      Err(_) => break
    }
  }
  dates
}
