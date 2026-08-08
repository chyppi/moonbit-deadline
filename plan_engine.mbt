///|
pub fn DeadlinePlan::calculate(
  self : DeadlinePlan,
) -> Result[PlanResult, PlanError] {
  let stage_results = Array::new()
  let mut previous : DeadlineResult? = None
  for index, stage in self.stages {
    let start_date = match previous {
      Some(result) =>
        match stage.start_source() {
          PreviousAdjusted => result.adjusted_date()
          PreviousOriginal => result.original_date()
        }
      None => self.start_date
    }
    let deadline = Deadline::new(
      start_date~,
      rule=stage.rule(),
      start_rule=stage.start_rule(),
      calendar=stage.calendar(),
      extension=stage.extension(),
    )
    let result = match deadline.calculate() {
      Ok(result) => result
      Err(error) =>
        return Err(StageDeadlineFailure(index, stage.label(), error))
    }
    let result = match stage.suspension() {
      Some(suspension) =>
        match apply_stage_suspension(stage, result, suspension) {
          Ok(suspended) => suspended
          Err(error) =>
            return Err(StageSuspensionFailure(index, stage.label(), error))
        }
      None => result
    }
    stage_results.push({ index, label: stage.label(), result })
    previous = Some(result)
  }
  match previous {
    Some(result) =>
      Ok({
        start_date: self.start_date,
        stages: stage_results.copy(),
        final_original: result.original_date(),
        final_adjusted: result.adjusted_date(),
      })
    None =>
      Ok({
        start_date: self.start_date,
        stages: [],
        final_original: self.start_date,
        final_adjusted: self.start_date,
      })
  }
}

///|
fn apply_stage_suspension(
  stage : PlanStage,
  base : DeadlineResult,
  suspension : SuspensionSet,
) -> Result[DeadlineResult, SuspensionError] {
  let mut current_original = base.original
  let mut current_adjusted = base.adjusted
  let window_start = match suspension_window_start(stage, base.start) {
    Ok(start) => start
    Err(error) => return Err(error)
  }
  let use_business_days = suspension_uses_business_days(stage.rule())
  for ;; {
    if should_abort(suspension, window_start, current_adjusted) {
      return Err(Aborted)
    }
    let delay = if use_business_days {
      suspension_business_days_in_window(
        suspension,
        window_start,
        current_adjusted,
        stage.calendar(),
      )
    } else {
      suspension_days_in_window(suspension, window_start, current_adjusted)
    }
    let shifted_original = match
      shift_suspended_date(
        base.original,
        delay,
        use_business_days~,
        calendar=stage.calendar(),
      ) {
      Ok(date) => date
      Err(error) => return Err(error)
    }
    let extension_steps = Array::new()
    let shifted_adjusted = match
      apply_extension(
        stage.extension(),
        shifted_original,
        stage.calendar(),
        extension_steps,
      ) {
      Ok(date) => date
      Err(_) => return Err(OutOfRange)
    }
    if shifted_original == current_original &&
      shifted_adjusted == current_adjusted {
      return Ok(
        suspended_result(
          base, shifted_original, shifted_adjusted, delay, extension_steps,
        ),
      )
    }
    current_original = shifted_original
    current_adjusted = shifted_adjusted
  }
  Err(OutOfRange)
}

///|
fn suspension_window_start(
  stage : PlanStage,
  start : Date,
) -> Result[Date, SuspensionError] {
  if stage.start_rule() == Include {
    Ok(start)
  } else if suspension_uses_business_days(stage.rule()) {
    match stage.calendar().advance_business_days(start, 1) {
      Ok(date) => Ok(date)
      Err(_) => Err(OutOfRange)
    }
  } else {
    match start.try_add_days(1) {
      Ok(date) => Ok(date)
      Err(_) => Err(OutOfRange)
    }
  }
}

///|
fn suspension_uses_business_days(rule : DateRule) -> Bool {
  match rule {
    BusinessDays(_) => true
    _ => false
  }
}

///|
fn should_abort(suspension : SuspensionSet, start : Date, end : Date) -> Bool {
  match suspension.abort_on() {
    Some(date) => start <= date && date <= end
    None => false
  }
}

///|
fn shift_suspended_date(
  base : Date,
  delay : Int,
  use_business_days~ : Bool,
  calendar~ : Calendar,
) -> Result[Date, SuspensionError] {
  if use_business_days {
    match calendar.advance_business_days(base, delay) {
      Ok(date) => Ok(date)
      Err(_) => Err(OutOfRange)
    }
  } else {
    match base.try_add_days(delay) {
      Ok(date) => Ok(date)
      Err(_) => Err(OutOfRange)
    }
  }
}

///|
fn suspended_result(
  base : DeadlineResult,
  original : Date,
  adjusted : Date,
  delay : Int,
  extension_steps : Array[CalculationStep],
) -> DeadlineResult {
  let steps = base.steps.filter(fn(step) {
    step.kind != Extension && step.kind != Complete
  })
  if delay > 0 {
    steps.push({
      kind: Count,
      date: original,
      note: "suspension days: \{delay}",
    })
  }
  steps.append(extension_steps)
  if adjusted == original {
    steps.push({
      kind: Complete,
      date: adjusted,
      note: "deadline after suspension",
    })
  } else {
    steps.push({
      kind: Complete,
      date: adjusted,
      note: "adjusted deadline after suspension",
    })
  }
  {
    start: base.start,
    rule: base.rule,
    original,
    adjusted,
    adjustment_count: if adjusted == original {
      0
    } else {
      1
    },
    crossed_month: base.start.month != adjusted.month,
    crossed_year: base.start.year != adjusted.year,
    steps: steps.copy(),
    explanation: render_steps(steps),
  }
}
