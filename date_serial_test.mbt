///|
test "date serial round trips leap days and year boundaries" {
  let dates = ["0001-01-01", "2024-02-29", "2026-12-31", "9999-12-31"]
  for text in dates {
    let date = Date::parse(text).unwrap()
    inspect(
      Date::from_ordinal(date.ordinal()).unwrap().to_string(),
      content=text,
    )
  }
  inspect(Date::parse("0001-01-01").unwrap().ordinal(), content="0")
}

///|
test "date serial rejects negative and excessive ordinals" {
  match Date::from_ordinal(-1) {
    Err(OutOfRange) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
  match Date::from_ordinal(4000000) {
    Err(OutOfRange) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}
