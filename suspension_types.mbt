///|
pub enum SuspensionError {
  Reversed
  OutOfRange
  Aborted
} derive(Debug, Eq, Compare)

///|
pub enum SuspensionPolicy {
  PauseInclusive
  PauseExclusive
} derive(Debug, Eq, Compare)

///|
pub fn SuspensionPolicy::pause_inclusive() -> SuspensionPolicy {
  PauseInclusive
}

///|
pub fn SuspensionPolicy::pause_exclusive() -> SuspensionPolicy {
  PauseExclusive
}

///|
pub struct SuspensionPeriod {
  start : Date
  end : Date
} derive(Debug, Eq, Compare)

///|
pub fn SuspensionPeriod::new(
  start~ : Date,
  end~ : Date,
) -> Result[SuspensionPeriod, SuspensionError] {
  if start > end {
    Err(Reversed)
  } else {
    Ok({ start, end })
  }
}

///|
pub fn SuspensionPeriod::start(self : SuspensionPeriod) -> Date {
  self.start
}

///|
pub fn SuspensionPeriod::end(self : SuspensionPeriod) -> Date {
  self.end
}

///|
pub struct SuspensionSet {
  periods : Array[SuspensionPeriod]
  policy : SuspensionPolicy
  abort_on : Date?
} derive(Debug)

///|
pub fn SuspensionSet::new(
  periods~ : Array[SuspensionPeriod],
  policy? : SuspensionPolicy = PauseInclusive,
  abort_on? : Date,
) -> SuspensionSet {
  { periods: periods.copy(), policy, abort_on }
}

///|
pub fn SuspensionSet::periods(self : SuspensionSet) -> Array[SuspensionPeriod] {
  self.periods.copy()
}

///|
pub fn SuspensionSet::policy(self : SuspensionSet) -> SuspensionPolicy {
  self.policy
}

///|
pub fn SuspensionSet::abort_on(self : SuspensionSet) -> Date? {
  self.abort_on
}
