///|
fn required_date(text : String) -> Date {
  Date::parse(text).unwrap()
}

///|
test "plan stages chain from the previous adjusted date by default" {
  let plan = DeadlinePlan::new(start_date=required_date("2026-08-07"))
    .add_stage(
      label="notice",
      rule=DateRule::business_days(1),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::following(),
    )
    .unwrap()
    .add_stage(
      label="response",
      rule=DateRule::business_days(2),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .unwrap()
  let result = plan.calculate().unwrap()
  let notice = result.stage(0).unwrap()
  let response = result.stage(1).unwrap()
  inspect(notice.adjusted_date().to_string(), content="2026-08-10")
  inspect(response.start_date().to_string(), content="2026-08-10")
  inspect(response.adjusted_date().to_string(), content="2026-08-12")
}

///|
test "zero-stage plans keep the original start date" {
  let result = DeadlinePlan::new(start_date=required_date("2026-08-07"))
    .calculate()
    .unwrap()
  inspect(result.stage_count(), content="0")
  inspect(result.final_original_date().to_string(), content="2026-08-07")
  inspect(result.final_adjusted_date().to_string(), content="2026-08-07")
}

///|
test "one-stage plans match the single deadline engine" {
  let stage_plan = DeadlinePlan::new(start_date=required_date("2026-08-07"))
    .add_stage(
      label="notice",
      rule=DateRule::business_days(3),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .unwrap()
  let plan_result = stage_plan.calculate().unwrap()
  let stage_result = plan_result.stage(0).unwrap()
  let deadline_result = Deadline::new(
      start_date=required_date("2026-08-07"),
      rule=DateRule::business_days(3),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .calculate()
    .unwrap()
  inspect(
    stage_result.original_date().to_string(),
    content=deadline_result.original_date().to_string(),
  )
  inspect(
    stage_result.adjusted_date().to_string(),
    content=deadline_result.adjusted_date().to_string(),
  )
}

///|
test "plan failures preserve the stage index label and deadline error" {
  let plan = DeadlinePlan::new(start_date=required_date("2026-08-07"))
    .add_stage(
      label="notice",
      rule=DateRule::calendar_days(-1),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .unwrap()
  match plan.calculate() {
    Err(StageDeadlineFailure(index, label, NegativeRuleCount)) => {
      inspect(index, content="0")
      inspect(label, content="notice")
    }
    _ => inspect(false, content="true")
  }
}

///|
test "repeated labels use deterministic first-match lookup" {
  let result = DeadlinePlan::new(start_date=required_date("2026-08-07"))
    .add_stage(
      label="notice",
      rule=DateRule::business_days(1),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .unwrap()
    .add_stage(
      label="notice",
      rule=DateRule::business_days(1),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .unwrap()
    .calculate()
    .unwrap()
  let first = result.stage_named("notice").unwrap()
  let second = result.stage(1).unwrap()
  inspect(first.index(), content="0")
  inspect(first.adjusted_date().to_string(), content="2026-08-10")
  inspect(second.adjusted_date().to_string(), content="2026-08-11")
}

///|
test "cross-year plans keep advancing from stage to stage" {
  let result = DeadlinePlan::new(start_date=required_date("2026-12-31"))
    .add_stage(
      label="notice",
      rule=DateRule::business_days(1),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .unwrap()
    .add_stage(
      label="response",
      rule=DateRule::calendar_days(2),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    )
    .unwrap()
    .calculate()
    .unwrap()
  inspect(result.final_adjusted_date().to_string(), content="2027-01-03")
}

///|
test "stages can deliberately start from the previous original date" {
  let result = DeadlinePlan::new(start_date=required_date("2026-08-07"))
    .add_stage(
      label="notice",
      rule=DateRule::calendar_days(2),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::new(
        name="demo",
        version="2026.1",
        weekend=WeekendPolicy::saturday_sunday(),
        holidays=[required_date("2026-08-09")],
        extra_workdays=[],
      ),
      extension=ExtensionPolicy::following(),
    )
    .unwrap()
    .add_stage(
      label="response",
      rule=DateRule::business_days(1),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
      start_source=StageStartSource::previous_original(),
    )
    .unwrap()
    .calculate()
    .unwrap()
  let notice = result.stage(0).unwrap()
  let response = result.stage(1).unwrap()
  inspect(notice.original_date().to_string(), content="2026-08-09")
  inspect(notice.adjusted_date().to_string(), content="2026-08-10")
  inspect(response.start_date().to_string(), content="2026-08-09")
}

///|
test "plan rejects empty labels and invalid stage indexes" {
  match
    DeadlinePlan::new(start_date=required_date("2026-08-07")).add_stage(
      label="",
      rule=DateRule::business_days(1),
      start_rule=StartDateRule::exclude(),
      calendar=Calendar::standard(),
      extension=ExtensionPolicy::no_extension(),
    ) {
    Err(EmptyStageLabel) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }

  let result = DeadlinePlan::new(start_date=required_date("2026-08-07"))
    .calculate()
    .unwrap()
  match result.stage(0) {
    Err(StageIndexOutOfRange(0)) => inspect(true, content="true")
    _ => inspect(false, content="true")
  }
}
