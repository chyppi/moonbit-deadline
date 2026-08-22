///|
/// Materialize a closed range of calendar classifications.
pub fn CalendarTimeline::between(
  calendar~ : Calendar,
  start~ : Date,
  end~ : Date,
) -> Result[CalendarTimeline, TimelineError] {
  if start > end {
    return Err(TimelineReversed)
  }
  let entries = Array::new()
  let mut current = start
  while true {
    entries.push(calendar.query(current))
    if current == end {
      break
    }
    current = match current.try_add_days(1) {
      Ok(value) => value
      Err(_) => return Err(TimelineOutOfRange)
    }
  }
  Ok({ entries, })
}

///|
/// Export one row per date for simple downstream ingestion.
pub fn CalendarTimeline::to_csv(self : CalendarTimeline) -> String {
  let mut output = "date,kind,calendar,version\n"
  for entry in self.entries {
    output = output +
      entry.date().to_string() +
      "," +
      entry.kind().to_string() +
      "," +
      entry.calendar_name() +
      "," +
      entry.calendar_version() +
      "\n"
  }
  output
}

///|
/// Number of non-business days in the materialized range.
pub fn CalendarTimeline::closure_count(self : CalendarTimeline) -> Int {
  self.closures().length()
}

///|
/// Business-day share formatted to two decimal places.
pub fn CalendarTimeline::business_day_ratio(self : CalendarTimeline) -> String {
  let total = self.entries.length()
  let business = self.business_days().length()
  if total == 0 {
    "0.00"
  } else if business * 100 % total >= 50 {
    ((business * 100 / total + 1) / 100).to_string() +
    "." +
    ((business * 100 / total + 1) % 100).to_string().pad_start(2, '0')
  } else {
    (business * 100 / total / 100).to_string() +
    "." +
    (business * 100 / total % 100).to_string().pad_start(2, '0')
  }
}

///|
/// First materialized calendar entry.
pub fn CalendarTimeline::first(self : CalendarTimeline) -> CalendarDayInfo? {
  if self.entries.is_empty() {
    None
  } else {
    Some(self.entries[0])
  }
}

///|
/// Last materialized calendar entry.
pub fn CalendarTimeline::last(self : CalendarTimeline) -> CalendarDayInfo? {
  if self.entries.is_empty() {
    None
  } else {
    Some(self.entries[self.entries.length() - 1])
  }
}

///|
/// Render the timeline as a compact Markdown table.
pub fn CalendarTimeline::to_markdown(self : CalendarTimeline) -> String {
  let mut output = "| date | kind | calendar | version |\n| --- | --- | --- | --- |\n"
  for entry in self.entries {
    output = output +
      "| " +
      entry.date().to_string() +
      " | " +
      entry.kind().to_string() +
      " | " +
      entry.calendar_name() +
      " | " +
      entry.calendar_version() +
      " |\n"
  }
  output
}
