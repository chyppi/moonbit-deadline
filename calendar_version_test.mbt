///|
test "calendar version metadata is preserved on the calendar" {
  let source = CalendarSource::new(
    name="Beijing government policy page",
    url="https://www.beijing.gov.cn/gate/big5/www.beijing.gov.cn/zhengce/zhengcefagui/202511/t20251104_4258873.html",
  )
  let version = CalendarVersion::new(
    name="china-national-2026",
    region="CN-11",
    version="2025-11-04",
    source=source,
    valid_from=Date::parse("2026-01-01").unwrap(),
    valid_to=Date::parse("2026-12-31").unwrap(),
  )
  match version {
    Ok(version) => {
      let calendar = Calendar::standard().with_version(version)
      inspect(calendar.version(), content="2025-11-04")
      inspect(calendar.region(), content="CN-11")
    }
    Err(_) => inspect(false, content="true")
  }
}

///|
test "observed holidays move a saturday holiday to monday" {
  let source = CalendarSource::new(
    name="Beijing government policy page",
    url="https://www.beijing.gov.cn/gate/big5/www.beijing.gov.cn/zhengce/zhengcefagui/202511/t20251104_4258873.html",
  )
  let version = CalendarVersion::new(
    name="demo",
    region="CN",
    version="2026.1",
    source=source,
    valid_from=Date::parse("2026-08-01").unwrap(),
    valid_to=Date::parse("2026-08-31").unwrap(),
  ).unwrap()
  let holiday = Date::parse("2026-08-08").unwrap()
  let calendar = Calendar::standard().with_version(version)
  match calendar.with_observed_holidays([holiday]) {
    Ok(calendar) => {
      inspect(calendar.observed_date(holiday).to_string(), content="2026-08-10")
      inspect(calendar.is_business_day(Date::parse("2026-08-10").unwrap()), content="false")
    }
    Err(_) => inspect(false, content="true")
  }
}

///|
test "extra workdays override observed holidays" {
  let source = CalendarSource::new(
    name="Beijing government policy page",
    url="https://www.beijing.gov.cn/gate/big5/www.beijing.gov.cn/zhengce/zhengcefagui/202511/t20251104_4258873.html",
  )
  let version = CalendarVersion::new(
    name="demo",
    region="CN",
    version="2026.1",
    source=source,
    valid_from=Date::parse("2026-08-01").unwrap(),
    valid_to=Date::parse("2026-08-31").unwrap(),
  ).unwrap()
  let holiday = Date::parse("2026-08-08").unwrap()
  let calendar = Calendar::new(
    name="demo",
    version="2026.1",
    weekend=WeekendPolicy::saturday_sunday(),
    holidays=[],
    extra_workdays=[Date::parse("2026-08-10").unwrap()],
  ).with_version(version)
  match calendar.with_observed_holidays([holiday]) {
    Ok(calendar) =>
      inspect(calendar.is_business_day(Date::parse("2026-08-10").unwrap()), content="true")
    Err(_) => inspect(false, content="true")
  }
}

///|
test "duplicate observed holidays are deduplicated" {
  let source = CalendarSource::new(
    name="Beijing government policy page",
    url="https://www.beijing.gov.cn/gate/big5/www.beijing.gov.cn/zhengce/zhengcefagui/202511/t20251104_4258873.html",
  )
  let version = CalendarVersion::new(
    name="demo",
    region="CN",
    version="2026.1",
    source=source,
    valid_from=Date::parse("2026-08-01").unwrap(),
    valid_to=Date::parse("2026-08-31").unwrap(),
  ).unwrap()
  let holiday = Date::parse("2026-08-08").unwrap()
  let calendar = Calendar::standard().with_version(version)
  match calendar.with_observed_holidays([holiday, holiday]) {
    Ok(calendar) => inspect(calendar.observed_holidays().length(), content="1")
    Err(_) => inspect(false, content="true")
  }
}

///|
test "observed holidays reject dates outside the version range" {
  let source = CalendarSource::new(
    name="Beijing government policy page",
    url="https://www.beijing.gov.cn/gate/big5/www.beijing.gov.cn/zhengce/zhengcefagui/202511/t20251104_4258873.html",
  )
  let version = CalendarVersion::new(
    name="demo",
    region="CN",
    version="2026.1",
    source=source,
    valid_from=Date::parse("2026-08-01").unwrap(),
    valid_to=Date::parse("2026-08-31").unwrap(),
  ).unwrap()
  let calendar = Calendar::standard().with_version(version)
  match calendar.with_observed_holidays([Date::parse("2026-07-31").unwrap()]) {
    Ok(_) => inspect(false, content="true")
    Err(ObservationOutOfRange(_)) => inspect(true, content="true")
    Err(_) => inspect(false, content="true")
  }
}

///|
test "calendar version rejects reversed metadata ranges" {
  let source = CalendarSource::new(
    name="Beijing government policy page",
    url="https://www.beijing.gov.cn/gate/big5/www.beijing.gov.cn/zhengce/zhengcefagui/202511/t20251104_4258873.html",
  )
  match CalendarVersion::new(
    name="demo",
    region="CN",
    version="2026.1",
    source=source,
    valid_from=Date::parse("2026-12-31").unwrap(),
    valid_to=Date::parse("2026-01-01").unwrap(),
  ) {
    Ok(_) => inspect(false, content="true")
    Err(InvalidRange) => inspect(true, content="true")
    Err(_) => inspect(false, content="true")
  }
}
