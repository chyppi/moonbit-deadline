///|
pub struct CliConfig {
  start : @lib.Date
  rule : @lib.DateRule
  exclude_start : Bool
  calendar : String
  extension : @lib.ExtensionPolicy
  explain : Bool
}

///|
pub enum CliError {
  MissingOption(String)
  InvalidOption(String)
  InvalidRule(String)
  InvalidNumber(String)
  InvalidDate(@lib.DateError)
} derive(Debug)

///|
fn parse_nonnegative_int(text : String) -> Result[Int, CliError] {
  if text.length() == 0 {
    return Err(InvalidNumber(text))
  }
  let mut value = 0
  let mut index = 0
  while index < text.length() {
    let code = text.at(index).to_int()
    if code < 48 || code > 57 {
      return Err(InvalidNumber(text))
    }
    value = value * 10 + code - 48
    index = index + 1
  }
  Ok(value)
}

///|
fn parse_one_rule(text : String) -> Result[@lib.DateRule, CliError] {
  let parts = [ for part in text.split(":") => part.to_owned() ]
  if parts.length() != 2 {
    return Err(InvalidRule(text))
  }
  let count = match parse_nonnegative_int(parts[1]) {
    Ok(value) => value
    Err(_) => return Err(InvalidRule(text))
  }
  match parts[0] {
    "calendar-days" => Ok(@lib.DateRule::calendar_days(count))
    "business-days" => Ok(@lib.DateRule::business_days(count))
    "weeks" => Ok(@lib.DateRule::weeks(count))
    "months" => Ok(@lib.DateRule::months(count))
    "years" => Ok(@lib.DateRule::years(count))
    _ => Err(InvalidRule(text))
  }
}

///|
pub fn parse_rule_spec(text : String) -> Result[@lib.DateRule, CliError] {
  let parts = [ for part in text.split(",") => part.to_owned() ]
  if parts.length() == 0 {
    return Err(InvalidRule(text))
  }
  if parts.length() == 1 {
    return parse_one_rule(parts[0])
  }
  let rules = Array::new()
  for part in parts {
    match parse_one_rule(part) {
      Ok(rule) => rules.push(rule)
      Err(_) => return Err(InvalidRule(part))
    }
  }
  Ok(@lib.DateRule::sequence(rules))
}

///|
fn parse_extension(text : String) -> Result[@lib.ExtensionPolicy, CliError] {
  match text {
    "none" => Ok(@lib.ExtensionPolicy::no_extension())
    "following" => Ok(@lib.ExtensionPolicy::following())
    "modified-following" => Ok(@lib.ExtensionPolicy::modified_following())
    "preceding" => Ok(@lib.ExtensionPolicy::preceding())
    _ => Err(InvalidOption("--extension=" + text))
  }
}

///|
pub fn parse_cli_arguments(args : Array[String]) -> Result[CliConfig, CliError] {
  let mut index = 0
  if args.length() > 0 && !args[0].has_prefix("--") {
    index = 1
  }
  let mut start_text = ""
  let mut rule_text = ""
  let mut calendar = "standard"
  let mut extension_text = "none"
  let mut exclude_start = false
  let mut explain = false
  while index < args.length() {
    match args[index] {
      "--start" => {
        index = index + 1
        if index >= args.length() {
          return Err(MissingOption("--start"))
        }
        start_text = args[index]
      }
      "--rule" => {
        index = index + 1
        if index >= args.length() {
          return Err(MissingOption("--rule"))
        }
        rule_text = args[index]
      }
      "--calendar" => {
        index = index + 1
        if index >= args.length() {
          return Err(MissingOption("--calendar"))
        }
        calendar = args[index]
      }
      "--extension" => {
        index = index + 1
        if index >= args.length() {
          return Err(MissingOption("--extension"))
        }
        extension_text = args[index]
      }
      "--exclude-start" => exclude_start = true
      "--explain" => explain = true
      "--help" => return Err(InvalidOption("help"))
      option => return Err(InvalidOption(option))
    }
    index = index + 1
  }
  if start_text == "" {
    return Err(MissingOption("--start"))
  }
  if rule_text == "" {
    return Err(MissingOption("--rule"))
  }
  let start = match @lib.Date::parse(start_text) {
    Ok(date) => date
    Err(error) => return Err(InvalidDate(error))
  }
  let rule = match parse_rule_spec(rule_text) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let extension = match parse_extension(extension_text) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  Ok({ start, rule, exclude_start, calendar, extension, explain })
}

///|
fn cli_error_message(error : CliError) -> String {
  match error {
    MissingOption(name) => "missing required option: " + name
    InvalidOption(name) => "invalid option or value: " + name
    InvalidRule(rule) => "invalid rule: " + rule
    InvalidNumber(value) => "invalid non-negative number: " + value
    InvalidDate(_) => "invalid date; expected YYYY-MM-DD"
  }
}

///|
fn calendar_for(name : String) -> Result[@lib.Calendar, CliError] {
  match name {
    "standard" => Ok(@lib.Calendar::standard())
    "china-2026" => Ok(@lib.Calendar::china_2026())
    _ => Err(InvalidOption("--calendar=" + name))
  }
}

///|
pub fn execute(args : Array[String]) -> Result[String, CliError] {
  let config = match parse_cli_arguments(args) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let calendar = match calendar_for(config.calendar) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let start_rule = if config.exclude_start {
    @lib.StartDateRule::exclude()
  } else {
    @lib.StartDateRule::including_start()
  }
  let deadline = @lib.Deadline::new(
    start_date=config.start,
    rule=config.rule,
    start_rule~,
    calendar~,
    extension=config.extension,
  )
  match deadline.calculate() {
    Ok(result) =>
      if config.explain {
        Ok(result.explain())
      } else {
        Ok(
          result.original_date().to_string() +
          " -> " +
          result.adjusted_date().to_string(),
        )
      }
    Err(_) => Err(InvalidOption("deadline calculation failed"))
  }
}
