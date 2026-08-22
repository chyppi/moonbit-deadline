///|
fn parse_rule_number(text : String) -> Result[Int, RuleParseError] {
  if text.length() == 0 {
    return Err(RuleInvalidNumber(text))
  }
  if text.at(0).to_int() == 45 {
    return Err(RuleParseNegativeCount)
  }
  let mut value = 0
  let mut index = 0
  while index < text.length() {
    let code = text.at(index).to_int()
    if code < 48 || code > 57 {
      return Err(RuleInvalidNumber(text))
    }
    value = value * 10 + code - 48
    index = index + 1
  }
  Ok(value)
}

///|
fn parse_single_rule(text : String) -> Result[DateRule, RuleParseError] {
  let parts = [ for part in text.split(":") => part.to_owned() ]
  if parts.length() != 2 {
    return Err(RuleInvalidFormat)
  }
  let count = match parse_rule_number(parts[1]) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  match parts[0] {
    "calendar-days" => Ok(CalendarDays(count))
    "business-days" => Ok(BusinessDays(count))
    "weeks" => Ok(Weeks(count))
    "months" => Ok(Months(count))
    "years" => Ok(Years(count))
    unit => Err(RuleUnknownUnit(unit))
  }
}

///|
/// Parse a stable comma-separated rule specification for library callers.
pub fn DateRule::parse(text : String) -> Result[DateRule, RuleParseError] {
  if text.length() == 0 {
    return Err(RuleInvalidFormat)
  }
  let parts = [ for part in text.split(",") => part.to_owned() ]
  let rules = Array::new()
  for part in parts {
    if part.length() == 0 {
      return Err(RuleInvalidFormat)
    }
    match parse_single_rule(part) {
      Ok(rule) => rules.push(rule)
      Err(error) => return Err(error)
    }
  }
  if rules.length() == 1 {
    Ok(rules[0])
  } else {
    Ok(Sequence(rules))
  }
}
