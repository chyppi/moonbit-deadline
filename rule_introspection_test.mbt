///|
test "date rules provide stable descriptions and validation" {
  let sequence = DateRule::sequence([
    DateRule::calendar_days(2),
    DateRule::business_days(3),
    DateRule::months(1),
  ])
  inspect(
    sequence.describe(),
    content="calendar-days:2,business-days:3,months:1",
  )
  match sequence.validate() {
    Ok(_) => inspect(true, content="true")
    Err(_) => inspect(false, content="true")
  }
}

///|
test "date rules reject negative nested counts" {
  match
    DateRule::sequence([DateRule::calendar_days(1), DateRule::years(-1)]).validate() {
    Err(RuleNegativeCount) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}

///|
test "date rules expose estimated calendar span" {
  inspect(DateRule::weeks(2).estimated_calendar_days(), content="14")
  inspect(
    DateRule::sequence([DateRule::calendar_days(3), DateRule::weeks(1)]).estimated_calendar_days(),
    content="10",
  )
}
