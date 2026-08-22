///|
pub enum RuleParseError {
  RuleInvalidFormat
  RuleInvalidNumber(String)
  RuleUnknownUnit(String)
  RuleParseNegativeCount
} derive(Debug, Eq, Compare)
