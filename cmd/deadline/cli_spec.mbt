///|
test "cli parses business day rules" {
  match parse_rule_spec("business-days:5") {
    Ok(rule) =>
      match rule {
        @lib.DateRule::BusinessDays(count) => inspect(count, content="5")
        _ => inspect(false, content="true")
      }
    Err(_) => inspect(false, content="true")
  }
}

///|
test "cli parses a sequence rule" {
  match parse_rule_spec("calendar-days:3,business-days:2") {
    Ok(@lib.DateRule::Sequence(rules)) => inspect(rules.length(), content="2")
    _ => inspect(false, content="true")
  }
}

///|
test "cli parses extension and start options" {
  match
    parse_cli_arguments([
      "--start", "2026-08-07", "--rule", "business-days:5", "--exclude-start", "--extension",
      "following",
    ]) {
    Ok(config) => {
      inspect(config.start.to_string(), content="2026-08-07")
      inspect(config.exclude_start, content="true")
      match config.extension {
        @lib.ExtensionPolicy::Following => inspect(true, content="true")
        _ => inspect(false, content="true")
      }
    }
    Err(_) => inspect(false, content="true")
  }
}

///|
test "cli rejects malformed rules" {
  match parse_rule_spec("unknown:4") {
    Ok(_) => inspect(false, content="true")
    Err(_) => inspect(true, content="true")
  }
}
