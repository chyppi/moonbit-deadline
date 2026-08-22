///|
test "date rule unit description remains machine readable" {
  inspect(DateRule::business_days(1).describe(), content="business-days:1")
  inspect(DateRule::weeks(1).describe(), content="weeks:1")
}
