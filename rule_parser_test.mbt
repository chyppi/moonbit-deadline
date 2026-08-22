///|
test "library rule parser matches the CLI grammar" {
  inspect(
    DateRule::parse("business-days:5").unwrap().describe(),
    content="business-days:5",
  )
  inspect(
    DateRule::parse("calendar-days:3,business-days:2").unwrap().describe(),
    content="calendar-days:3,business-days:2",
  )
  inspect(
    DateRule::parse("months:12").unwrap().estimated_calendar_days(),
    content="360",
  )
}

///|
test "library rule parser rejects malformed units counts and sequences" {
  match DateRule::parse("unknown:4") {
    Err(RuleUnknownUnit(_)) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
  match DateRule::parse("business-days:-1") {
    Err(RuleParseNegativeCount) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
  match DateRule::parse("calendar-days:1,") {
    Err(RuleInvalidFormat) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}

///|
test "library rule parser handles whitespace-free zero rules" {
  inspect(
    DateRule::parse("calendar-days:0").unwrap().describe(),
    content="calendar-days:0",
  )
}
