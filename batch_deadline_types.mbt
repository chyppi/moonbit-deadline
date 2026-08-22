///|
/// A named deadline in a batch calculation.
pub struct BatchTask {
  name : String
  event : String?
  dependency : String?
  rule : DateRule
  start_rule : StartDateRule
  calendar : Calendar
  extension : ExtensionPolicy
}

///|
pub enum BatchError {
  BatchDuplicate(String)
  BatchMissingDependency(String)
  BatchCycle(String)
  BatchEmpty
  BatchEventFailure(EventError)
  BatchDeadlineFailure(DeadlineError)
} derive(Debug)

///|
struct BatchResultEntry {
  name : String
  result : DeadlineResult
}

///|
pub struct BatchResult {
  entries : Array[BatchResultEntry]
}

///|
pub struct BatchDeadline {
  tasks : Array[BatchTask]
}
