///|
pub enum TimelineError {
  TimelineReversed
  TimelineOutOfRange
} derive(Debug, Eq, Compare)

///|
/// Materialized daily calendar classifications for export and UI adapters.
pub struct CalendarTimeline {
  entries : Array[CalendarDayInfo]
}

///|
pub fn CalendarTimeline::days(
  self : CalendarTimeline,
) -> Array[CalendarDayInfo] {
  self.entries.copy()
}

///|
pub fn CalendarTimeline::business_days(
  self : CalendarTimeline,
) -> Array[CalendarDayInfo] {
  [
    for entry in self.entries if entry.kind() == BusinessDay => entry
  ]
}

///|
pub fn CalendarTimeline::closures(
  self : CalendarTimeline,
) -> Array[CalendarDayInfo] {
  [
    for entry in self.entries if entry.kind() != BusinessDay => entry
  ]
}
