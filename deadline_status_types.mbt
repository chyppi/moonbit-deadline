///|
pub enum DeadlineStatus {
  Pending
  DueToday
  Overdue
  Completed
} derive(Debug, Eq, Compare)

///|
pub fn DeadlineStatus::pending() -> DeadlineStatus {
  Pending
}

///|
pub fn DeadlineStatus::due_today() -> DeadlineStatus {
  DueToday
}

///|
pub fn DeadlineStatus::overdue() -> DeadlineStatus {
  Overdue
}

///|
pub fn DeadlineStatus::completed() -> DeadlineStatus {
  Completed
}

///|
pub fn DeadlineStatus::to_string(self : DeadlineStatus) -> String {
  match self {
    Pending => "pending"
    DueToday => "due-today"
    Overdue => "overdue"
    Completed => "completed"
  }
}

///|
pub enum CompletionError {
  CompletionBeforeStart
} derive(Debug, Eq, Compare)

///|
pub struct DeadlineRecord {
  id : String
  result : DeadlineResult
  completed_on : Date?
}
