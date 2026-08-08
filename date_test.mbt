///|
test "date accepts leap day and formats ISO" {
  match Date::new(year=2024, month=2, day=29) {
    Ok(date) => inspect(date.to_string(), content="2024-02-29")
    Err(_) => inspect(false, content="true")
  }
}

///|
test "date rejects an invalid leap day" {
  match Date::new(year=2023, month=2, day=29) {
    Ok(_) => inspect(false, content="true")
    Err(_) => inspect(true, content="true")
  }
}

///|
test "date arithmetic crosses month and year boundaries" {
  let start = Date::parse("2023-12-31")
  match start {
    Ok(date) => {
      inspect(date.add_days(1).to_string(), content="2024-01-01")
      inspect(date.add_months(2).to_string(), content="2024-02-29")
    }
    Err(_) => inspect(false, content="true")
  }
}

///|
test "date arithmetic clamps a month end" {
  match Date::parse("2026-01-31") {
    Ok(date) => inspect(date.add_months(1).to_string(), content="2026-02-28")
    Err(_) => inspect(false, content="true")
  }
}

///|
test "date reports a stable weekday" {
  match Date::parse("2026-08-10") {
    Ok(date) => {
      inspect(date.weekday().is_monday(), content="true")
      inspect(date.weekday().to_string(), content="Monday")
    }
    Err(_) => inspect(false, content="true")
  }
}

///|
test "date checked arithmetic rejects year overflow" {
  match Date::parse("9999-12-31").unwrap().try_add_days(1) {
    Ok(_) => inspect(false, content="true")
    Err(OutOfRange) => inspect(true, content="true")
    Err(_) => inspect(false, content="true")
  }
}
