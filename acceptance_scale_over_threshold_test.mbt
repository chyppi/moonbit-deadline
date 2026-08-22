///|
test "scale threshold remains above the requested minimum" {
  inspect(DateRule::years(0).estimated_calendar_days(), content="0")
}
