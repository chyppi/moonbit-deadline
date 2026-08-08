///|
pub fn SuspensionSet::normalize(self : SuspensionSet) -> SuspensionSet {
  let sorted = self.periods.copy()
  sorted.sort_by((left, right) => {
    if left.start < right.start {
      -1
    } else if left.start > right.start {
      1
    } else if left.end < right.end {
      -1
    } else if left.end > right.end {
      1
    } else {
      0
    }
  })
  let merged = Array::new()
  for period in sorted {
    if merged.is_empty() {
      merged.push(period)
    } else {
      let last_index = merged.length() - 1
      let last = merged[last_index]
      match
        DateRange::closed(start=last.start, end=last.end)
        .unwrap()
        .union(DateRange::closed(start=period.start, end=period.end).unwrap()) {
        Ok(union) => merged[last_index] = { start: union.start, end: union.end }
        Err(NoIntersection) => merged.push(period)
        Err(_) => panic()
      }
    }
  }
  { periods: merged.copy(), policy: self.policy, abort_on: self.abort_on }
}

///|
pub fn SuspensionSet::calendar_days(self : SuspensionSet) -> Int {
  let normalized = self.normalize()
  normalized.periods.fold(init=0, (count, period) => {
    count + period_count_calendar_days(period, normalized.policy)
  })
}

///|
pub fn SuspensionSet::business_days(
  self : SuspensionSet,
  calendar : Calendar,
) -> Int {
  let normalized = self.normalize()
  normalized.periods.fold(init=0, (count, period) => {
    count + period_count_business_days(period, normalized.policy, calendar)
  })
}

///|
fn period_count_calendar_days(
  period : SuspensionPeriod,
  policy : SuspensionPolicy,
) -> Int {
  match counted_range_for_period(period, policy) {
    Some(range) => range.calendar_days()
    None => 0
  }
}

///|
fn period_count_business_days(
  period : SuspensionPeriod,
  policy : SuspensionPolicy,
  calendar : Calendar,
) -> Int {
  match counted_range_for_period(period, policy) {
    Some(range) => range.business_days(calendar)
    None => 0
  }
}

///|
fn counted_range_for_period(
  period : SuspensionPeriod,
  policy : SuspensionPolicy,
) -> DateRange? {
  match policy {
    PauseInclusive =>
      Some(DateRange::closed(start=period.start, end=period.end).unwrap())
    PauseExclusive =>
      if period.start == period.end {
        None
      } else {
        let start = period.start.try_add_days(1).unwrap()
        let end = period.end.try_add_days(-1).unwrap()
        if start > end {
          None
        } else {
          Some(DateRange::closed(start~, end~).unwrap())
        }
      }
  }
}

///|
fn suspension_days_in_window(
  suspension : SuspensionSet,
  start : Date,
  end : Date,
) -> Int {
  if start > end {
    return 0
  }
  let window = DateRange::closed(start~, end~).unwrap()
  let normalized = suspension.normalize()
  normalized.periods.fold(init=0, (count, period) => {
    count + overlap_calendar_days(period, window, normalized.policy)
  })
}

///|
fn suspension_business_days_in_window(
  suspension : SuspensionSet,
  start : Date,
  end : Date,
  calendar : Calendar,
) -> Int {
  if start > end {
    return 0
  }
  let window = DateRange::closed(start~, end~).unwrap()
  let normalized = suspension.normalize()
  normalized.periods.fold(init=0, (count, period) => {
    count + overlap_business_days(period, window, normalized.policy, calendar)
  })
}

///|
fn overlap_calendar_days(
  period : SuspensionPeriod,
  window : DateRange,
  policy : SuspensionPolicy,
) -> Int {
  match counted_range_for_period(period, policy) {
    Some(range) =>
      match range.intersection(window) {
        Ok(intersection) => intersection.calendar_days()
        Err(NoIntersection) => 0
        Err(_) => panic()
      }
    None => 0
  }
}

///|
fn overlap_business_days(
  period : SuspensionPeriod,
  window : DateRange,
  policy : SuspensionPolicy,
  calendar : Calendar,
) -> Int {
  match counted_range_for_period(period, policy) {
    Some(range) =>
      match range.intersection(window) {
        Ok(intersection) => intersection.business_days(calendar)
        Err(NoIntersection) => 0
        Err(_) => panic()
      }
    None => 0
  }
}
