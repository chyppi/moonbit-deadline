///|
fn builder_date(text : String) -> Date {
  Date::parse(text).unwrap()
}

///|
test "calendar builder creates a versioned custom-weekend calendar" {
  let calendar = CalendarBuilder::new(
      name="middle-east",
      version="2026.1",
      weekend=WeekendPolicy::friday_saturday(),
    )
    .region("AE")
    .source(
      CalendarSource::new(
        name="internal policy",
        url="https://example.test/calendar",
      ),
    )
    .valid_during(
      start=builder_date("2026-01-01"),
      end=builder_date("2026-12-31"),
    )
    .holiday(builder_date("2026-01-01"))
    .extra_workday(builder_date("2026-01-02"))
    .build()
    .unwrap()
  inspect(calendar.region(), content="AE")
  inspect(calendar.is_business_day(builder_date("2026-01-02")), content="true")
  inspect(calendar.is_business_day(builder_date("2026-01-04")), content="true")
  inspect(calendar.is_business_day(builder_date("2026-01-01")), content="false")
}

///|
test "calendar builder rejects missing identity and reversed range" {
  match
    CalendarBuilder::new(
      name="",
      version="2026.1",
      weekend=WeekendPolicy::saturday_sunday(),
    ).build() {
    Err(CalendarMissingName) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
  match
    CalendarBuilder::new(
      name="demo",
      version="2026.1",
      weekend=WeekendPolicy::saturday_sunday(),
    )
    .valid_during(
      start=builder_date("2026-12-31"),
      end=builder_date("2026-01-01"),
    )
    .build() {
    Err(CalendarInvalidRange) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}

///|
test "calendar merge lets primary extra workdays override holidays" {
  let primary = CalendarBuilder::new(
      name="primary",
      version="p",
      weekend=WeekendPolicy::saturday_sunday(),
    )
    .holiday(builder_date("2026-08-10"))
    .extra_workday(builder_date("2026-08-10"))
    .build()
    .unwrap()
  let secondary = CalendarBuilder::new(
      name="secondary",
      version="s",
      weekend=WeekendPolicy::saturday_sunday(),
    )
    .holiday(builder_date("2026-08-11"))
    .build()
    .unwrap()
  let merged = Calendar::merge(primary, secondary).unwrap()
  inspect(merged.is_business_day(builder_date("2026-08-10")), content="true")
  inspect(merged.is_business_day(builder_date("2026-08-11")), content="false")
}

///|
test "calendar merge preserves primary provenance and observed holidays" {
  let primary = CalendarBuilder::new(
      name="primary",
      version="2026.1",
      weekend=WeekendPolicy::saturday_sunday(),
    )
    .region("CN")
    .source(
      CalendarSource::new(
        name="primary-source",
        url="https://example.test/primary",
      ),
    )
    .valid_during(
      start=builder_date("2026-01-01"),
      end=builder_date("2026-12-31"),
    )
    .build()
    .unwrap()
    .with_observed_holidays([builder_date("2026-08-08")])
    .unwrap()
  let secondary = Calendar::standard()
  let merged = Calendar::merge(primary, secondary).unwrap()
  inspect(merged.region(), content="CN")
  inspect(merged.source().name(), content="primary-source")
  inspect(merged.valid_from().to_string(), content="2026-01-01")
  inspect(merged.observed_holidays().length(), content="1")
  inspect(
    merged.query(builder_date("2026-08-10")).kind().to_string(),
    content="observed-holiday",
  )
}

///|
test "calendar query explains why a date is not a business day" {
  let date = builder_date("2026-08-08")
  let calendar = Calendar::standard()
  let info = calendar.query(date)
  inspect(info.date().to_string(), content="2026-08-08")
  inspect(info.kind().to_string(), content="weekend")
  inspect(info.calendar_name(), content="standard")
}
