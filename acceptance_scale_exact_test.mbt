///|
test "date rule calendar day description is exact" {
  inspect(DateRule::calendar_days(0).describe(), content="calendar-days:0")
}
