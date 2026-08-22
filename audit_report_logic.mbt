///|
/// Build a report from an existing result and its calendar.
pub fn AuditReport::from_result(
  result : DeadlineResult,
  calendar : Calendar,
) -> AuditReport {
  { result, calendar }
}

///|
fn step_kind_text(kind : StepKind) -> String {
  match kind {
    Start => "start"
    Count => "count"
    Extension => "extension"
    Complete => "complete"
  }
}

///|
/// Render metadata followed by the calculation steps.
pub fn AuditReport::to_text(self : AuditReport) -> String {
  let source = self.calendar.source()
  let mut text = "calendar=" +
    self.calendar.name() +
    "\nversion=" +
    self.calendar.version() +
    "\nregion=" +
    self.calendar.region() +
    "\nsource=" +
    source.name() +
    "\nsource_url=" +
    source.url() +
    "\nstart=" +
    self.result.start_date().to_string() +
    "\noriginal=" +
    self.result.original_date().to_string() +
    "\nadjusted=" +
    self.result.adjusted_date().to_string() +
    "\nadjustments=" +
    self.result.adjustment_count().to_string() +
    "\ncrossed_month=" +
    self.result.crossed_month().to_string() +
    "\ncrossed_year=" +
    self.result.crossed_year().to_string() +
    "\nsteps:\n"
  for step in self.result.steps() {
    text = text +
      step.date().to_string() +
      " | " +
      step_kind_text(step.kind()) +
      " | " +
      step.note() +
      "\n"
  }
  text
}

///|
/// Render only the step table for terminal and downstream parsing use.
pub fn AuditReport::to_table(self : AuditReport) -> String {
  let mut text = "date | kind | note\n"
  for step in self.result.steps() {
    text = text +
      step.date().to_string() +
      " | " +
      step_kind_text(step.kind()) +
      " | " +
      step.note() +
      "\n"
  }
  text
}

///|
/// Export calculation steps as a CSV stream for spreadsheets and ETL tools.
pub fn AuditReport::to_csv(self : AuditReport) -> String {
  let mut text = "date,kind,note\n"
  for step in self.result.steps() {
    text = text +
      step.date().to_string() +
      "," +
      step_kind_text(step.kind()) +
      "," +
      step.note() +
      "\n"
  }
  text
}
