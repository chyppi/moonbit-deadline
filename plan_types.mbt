///|
pub enum StageStartSource {
  PreviousAdjusted
  PreviousOriginal
} derive(Debug, Eq, Compare)

///|
pub fn StageStartSource::previous_adjusted() -> StageStartSource {
  PreviousAdjusted
}

///|
pub fn StageStartSource::previous_original() -> StageStartSource {
  PreviousOriginal
}

///|
pub enum PlanError {
  EmptyStageLabel
  StageIndexOutOfRange(Int)
  StageLabelNotFound(String)
  StageDeadlineFailure(Int, String, DeadlineError)
  StageSuspensionFailure(Int, String, SuspensionError)
} derive(Debug)

///|
pub struct PlanStage {
  label : String
  rule : DateRule
  start_rule : StartDateRule
  calendar : Calendar
  extension : ExtensionPolicy
  start_source : StageStartSource
  suspension : SuspensionSet?
} derive(Debug)

///|
pub fn PlanStage::new(
  label~ : String,
  rule~ : DateRule,
  start_rule~ : StartDateRule,
  calendar~ : Calendar,
  extension~ : ExtensionPolicy,
  start_source? : StageStartSource = PreviousAdjusted,
  suspension? : SuspensionSet,
) -> Result[PlanStage, PlanError] {
  if label == "" {
    Err(EmptyStageLabel)
  } else {
    Ok({
      label,
      rule,
      start_rule,
      calendar,
      extension,
      start_source,
      suspension,
    })
  }
}

///|
pub fn PlanStage::label(self : PlanStage) -> String {
  self.label
}

///|
pub fn PlanStage::rule(self : PlanStage) -> DateRule {
  self.rule
}

///|
pub fn PlanStage::start_rule(self : PlanStage) -> StartDateRule {
  self.start_rule
}

///|
pub fn PlanStage::calendar(self : PlanStage) -> Calendar {
  self.calendar
}

///|
pub fn PlanStage::extension(self : PlanStage) -> ExtensionPolicy {
  self.extension
}

///|
pub fn PlanStage::start_source(self : PlanStage) -> StageStartSource {
  self.start_source
}

///|
pub fn PlanStage::suspension(self : PlanStage) -> SuspensionSet? {
  self.suspension
}

///|
pub struct DeadlinePlan {
  start_date : Date
  stages : Array[PlanStage]
} derive(Debug)

///|
pub fn DeadlinePlan::new(start_date~ : Date) -> DeadlinePlan {
  { start_date, stages: [] }
}

///|
pub fn DeadlinePlan::start_date(self : DeadlinePlan) -> Date {
  self.start_date
}

///|
pub fn DeadlinePlan::stage_count(self : DeadlinePlan) -> Int {
  self.stages.length()
}

///|
pub fn DeadlinePlan::stages(self : DeadlinePlan) -> Array[PlanStage] {
  self.stages.copy()
}

///|
pub fn DeadlinePlan::stage(
  self : DeadlinePlan,
  index : Int,
) -> Result[PlanStage, PlanError] {
  if index < 0 || index >= self.stages.length() {
    Err(StageIndexOutOfRange(index))
  } else {
    Ok(self.stages[index])
  }
}

///|
pub fn DeadlinePlan::add_stage(
  self : DeadlinePlan,
  label~ : String,
  rule~ : DateRule,
  start_rule~ : StartDateRule,
  calendar~ : Calendar,
  extension~ : ExtensionPolicy,
  start_source? : StageStartSource = PreviousAdjusted,
  suspension? : SuspensionSet,
) -> Result[DeadlinePlan, PlanError] {
  let stage_result = match suspension {
    Some(suspension) =>
      PlanStage::new(
        label~,
        rule~,
        start_rule~,
        calendar~,
        extension~,
        start_source~,
        suspension~,
      )
    None =>
      PlanStage::new(
        label~,
        rule~,
        start_rule~,
        calendar~,
        extension~,
        start_source~,
      )
  }
  match stage_result {
    Ok(stage) => {
      let stages = self.stages.copy()
      stages.push(stage)
      Ok({ start_date: self.start_date, stages })
    }
    Err(error) => Err(error)
  }
}

///|
pub struct PlanStageResult {
  index : Int
  label : String
  result : DeadlineResult
} derive(Debug)

///|
pub fn PlanStageResult::index(self : PlanStageResult) -> Int {
  self.index
}

///|
pub fn PlanStageResult::label(self : PlanStageResult) -> String {
  self.label
}

///|
pub fn PlanStageResult::start_date(self : PlanStageResult) -> Date {
  self.result.start_date()
}

///|
pub fn PlanStageResult::original_date(self : PlanStageResult) -> Date {
  self.result.original_date()
}

///|
pub fn PlanStageResult::adjusted_date(self : PlanStageResult) -> Date {
  self.result.adjusted_date()
}

///|
pub fn PlanStageResult::deadline_result(
  self : PlanStageResult,
) -> DeadlineResult {
  self.result
}

///|
pub struct PlanResult {
  start_date : Date
  stages : Array[PlanStageResult]
  final_original : Date
  final_adjusted : Date
} derive(Debug)

///|
pub fn PlanResult::start_date(self : PlanResult) -> Date {
  self.start_date
}

///|
pub fn PlanResult::stage_count(self : PlanResult) -> Int {
  self.stages.length()
}

///|
pub fn PlanResult::stages(self : PlanResult) -> Array[PlanStageResult] {
  self.stages.copy()
}

///|
pub fn PlanResult::stage(
  self : PlanResult,
  index : Int,
) -> Result[PlanStageResult, PlanError] {
  if index < 0 || index >= self.stages.length() {
    Err(StageIndexOutOfRange(index))
  } else {
    Ok(self.stages[index])
  }
}

///|
pub fn PlanResult::stage_named(
  self : PlanResult,
  label : String,
) -> Result[PlanStageResult, PlanError] {
  for stage in self.stages {
    if stage.label == label {
      return Ok(stage)
    }
  }
  Err(StageLabelNotFound(label))
}

///|
pub fn PlanResult::final_original_date(self : PlanResult) -> Date {
  self.final_original
}

///|
pub fn PlanResult::final_adjusted_date(self : PlanResult) -> Date {
  self.final_adjusted
}
