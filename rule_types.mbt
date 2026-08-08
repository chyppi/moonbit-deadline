///|
pub enum DateRule {
  CalendarDays(Int)
  BusinessDays(Int)
  Weeks(Int)
  Months(Int)
  Years(Int)
  Sequence(Array[DateRule])
} derive(Debug)

///|
pub fn DateRule::calendar_days(count : Int) -> DateRule {
  CalendarDays(count)
}

///|
pub fn DateRule::business_days(count : Int) -> DateRule {
  BusinessDays(count)
}

///|
pub fn DateRule::weeks(count : Int) -> DateRule {
  Weeks(count)
}

///|
pub fn DateRule::months(count : Int) -> DateRule {
  Months(count)
}

///|
pub fn DateRule::years(count : Int) -> DateRule {
  Years(count)
}

///|
pub fn DateRule::sequence(rules : Array[DateRule]) -> DateRule {
  Sequence(rules)
}

///|
pub enum StartDateRule {
  Include
  Exclude
} derive(Debug, Eq, Compare)

///|
pub fn StartDateRule::including_start() -> StartDateRule {
  Include
}

///|
pub fn StartDateRule::exclude() -> StartDateRule {
  Exclude
}

///|
pub enum ExtensionPolicy {
  NoExtension
  Following
  ModifiedFollowing
  Preceding
} derive(Debug, Eq, Compare)

///|
pub fn ExtensionPolicy::no_extension() -> ExtensionPolicy {
  NoExtension
}

///|
pub fn ExtensionPolicy::following() -> ExtensionPolicy {
  Following
}

///|
pub fn ExtensionPolicy::modified_following() -> ExtensionPolicy {
  ModifiedFollowing
}

///|
pub fn ExtensionPolicy::preceding() -> ExtensionPolicy {
  Preceding
}
