///|
/// Create an application-facing deadline request.
pub fn DeadlineRequest::new(
  id~ : String,
  start~ : Date,
  rule~ : DateRule,
  start_rule~ : StartDateRule,
  calendar~ : Calendar,
  extension~ : ExtensionPolicy,
) -> DeadlineRequest {
  { id, start, rule, start_rule, calendar, extension }
}

///|
fn DeadlineRequest::validate(
  self : DeadlineRequest,
) -> Result[Unit, ServiceError] {
  if self.id.length() == 0 {
    return Err(ServiceInvalidId)
  }
  match self.rule.validate() {
    Ok(_) => Ok(())
    Err(error) => Err(ServiceInvalidRule(error))
  }
}

///|
/// Validate and calculate one request into a trackable record.
pub fn DeadlineService::evaluate(
  request : DeadlineRequest,
) -> Result[DeadlineRecord, ServiceError] {
  match request.validate() {
    Ok(_) => ()
    Err(error) => return Err(error)
  }
  let deadline = Deadline::new(
    start_date=request.start,
    rule=request.rule,
    start_rule=request.start_rule,
    calendar=request.calendar,
    extension=request.extension,
  )
  match deadline.calculate() {
    Ok(result) => Ok(DeadlineRecord::new(request.id, result))
    Err(error) => Err(ServiceDeadlineFailure(error))
  }
}

///|
pub enum LedgerError {
  LedgerDuplicate(String)
} derive(Debug, Eq, Compare)

///|
pub struct DeadlineLedger {
  records : Array[DeadlineRecord]
}

///|
/// Create an empty in-memory deadline ledger.
pub fn DeadlineLedger::new() -> DeadlineLedger {
  { records: [] }
}

///|
/// Add a record with a unique application identifier.
pub fn DeadlineLedger::add(
  self : DeadlineLedger,
  record : DeadlineRecord,
) -> Result[DeadlineLedger, LedgerError] {
  for existing in self.records {
    if existing.id() == record.id() {
      return Err(LedgerDuplicate(record.id()))
    }
  }
  let records = self.records.copy()
  records.push(record)
  Ok({ records, })
}

///|
/// Find a record by application identifier.
pub fn DeadlineLedger::find(
  self : DeadlineLedger,
  id : String,
) -> DeadlineRecord? {
  for record in self.records {
    if record.id() == id {
      return Some(record)
    }
  }
  None
}

///|
fn records_with_status(
  records : Array[DeadlineRecord],
  as_of : Date,
  status : DeadlineStatus,
) -> Array[String] {
  let ids = Array::new()
  for record in records {
    if record.status(as_of) == status {
      ids.push(record.id())
    }
  }
  ids
}

///|
/// Return identifiers due on the supplied date.
pub fn DeadlineLedger::due(
  self : DeadlineLedger,
  as_of : Date,
) -> Array[String] {
  records_with_status(self.records, as_of, DueToday)
}

///|
/// Return identifiers past due and not completed.
pub fn DeadlineLedger::overdue(
  self : DeadlineLedger,
  as_of : Date,
) -> Array[String] {
  records_with_status(self.records, as_of, Overdue)
}

///|
/// Return identifiers with completion evidence.
pub fn DeadlineLedger::completed(
  self : DeadlineLedger,
  as_of : Date,
) -> Array[String] {
  records_with_status(self.records, as_of, Completed)
}
