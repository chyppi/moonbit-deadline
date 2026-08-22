///|
/// A named date that can be used as the start of a deadline workflow.
pub enum EventSpec {
  Fixed(Date)
  After(String, Int)
} derive(Debug, Eq, Compare)

///|
/// Errors produced while resolving named events.
pub enum EventError {
  EventDuplicate(String)
  EventMissing(String)
  EventCycle(String)
  EventNegativeOffset(String)
  EventDateFailure(DateError)
} derive(Debug, Eq, Compare)

///|
struct EventEntry {
  name : String
  spec : EventSpec
}

///|
/// An immutable collection of named event definitions.
pub struct EventContext {
  entries : Array[EventEntry]
}

///|
/// A deadline whose start date is resolved from an event context.
pub struct EventDeadline {
  event : String
  rule : DateRule
  start_rule : StartDateRule
  calendar : Calendar
  extension : ExtensionPolicy
}

///|
pub enum EventDeadlineError {
  Event(EventError)
  Deadline(DeadlineError)
} derive(Debug)
