///|
pub enum ServiceError {
  ServiceInvalidId
  ServiceInvalidRule(RuleError)
  ServiceDeadlineFailure(DeadlineError)
} derive(Debug)

///|
/// A validated request boundary for application integrations.
pub struct DeadlineRequest {
  id : String
  start : Date
  rule : DateRule
  start_rule : StartDateRule
  calendar : Calendar
  extension : ExtensionPolicy
}

///|
pub enum DeadlineService {}
