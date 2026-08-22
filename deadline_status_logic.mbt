///|
/// Classify the uncompleted state of a deadline at a given date.
pub fn DeadlineResult::status(
  self : DeadlineResult,
  as_of : Date,
) -> DeadlineStatus {
  if as_of < self.adjusted_date() {
    Pending
  } else if as_of == self.adjusted_date() {
    DueToday
  } else {
    Overdue
  }
}

///|
/// Create a trackable deadline record.
pub fn DeadlineRecord::new(
  id : String,
  result : DeadlineResult,
) -> DeadlineRecord {
  { id, result, completed_on: None }
}

///|
/// Record completion evidence, rejecting impossible pre-start evidence.
pub fn DeadlineRecord::complete(
  self : DeadlineRecord,
  completed_on : Date,
) -> Result[DeadlineRecord, CompletionError] {
  if completed_on < self.result.start_date() {
    Err(CompletionBeforeStart)
  } else {
    Ok({ ..self, completed_on: Some(completed_on) })
  }
}

///|
/// Return the business identifier of the record.
pub fn DeadlineRecord::id(self : DeadlineRecord) -> String {
  self.id
}

///|
/// Return the tracked deadline result.
pub fn DeadlineRecord::result(self : DeadlineRecord) -> DeadlineResult {
  self.result
}

///|
/// Classify a record, prioritizing completion evidence.
pub fn DeadlineRecord::status(
  self : DeadlineRecord,
  as_of : Date,
) -> DeadlineStatus {
  match self.completed_on {
    Some(_) => Completed
    None => self.result.status(as_of)
  }
}
