///|
pub enum MatrixError {
  MatrixDuplicate(String)
  MatrixEmpty
  MatrixMissing(String)
  MatrixDeadlineFailure(DeadlineError)
} derive(Debug)

///|
struct MatrixScenario {
  name : String
  calendar : Calendar
}

///|
struct MatrixEntry {
  name : String
  result : DeadlineResult
}

///|
pub struct DeadlineMatrix {
  start : Date
  rule : DateRule
  start_rule : StartDateRule
  extension : ExtensionPolicy
  scenarios : Array[MatrixScenario]
}

///|
pub struct MatrixResult {
  entries : Array[MatrixEntry]
}
