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
