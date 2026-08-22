///|
test "business day cursor moves forward and backward without including current" {
  let calendar = Calendar::standard()
  let cursor = BusinessDayCursor::new(
    date=Date::parse("2026-08-07").unwrap(),
    calendar~,
  )
  let first = cursor.next().unwrap()
  inspect(first.to_string(), content="2026-08-10")
  inspect(
    BusinessDayCursor::new(date=first, calendar~).next().unwrap().to_string(),
    content="2026-08-11",
  )
  inspect(cursor.previous().unwrap().to_string(), content="2026-08-06")
}

///|
test "business day cursor collects a deterministic window" {
  let cursor = BusinessDayCursor::new(
    date=Date::parse("2026-08-07").unwrap(),
    calendar=Calendar::standard(),
  )
  let dates = cursor.forward(3).unwrap()
  inspect(dates[0].to_string(), content="2026-08-10")
  inspect(dates[2].to_string(), content="2026-08-12")
}

///|
test "business day cursor rejects zero collection count" {
  let cursor = BusinessDayCursor::new(
    date=Date::parse("2026-08-07").unwrap(),
    calendar=Calendar::standard(),
  )
  match cursor.forward(0) {
    Err(CursorInvalidCount) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}
