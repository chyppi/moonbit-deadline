///|
/// Define a task that starts at an event in an EventContext.
pub fn BatchTask::from_event(
  name~ : String,
  event~ : String,
  rule~ : DateRule,
  start_rule~ : StartDateRule,
  calendar~ : Calendar,
  extension~ : ExtensionPolicy,
) -> BatchTask {
  {
    name,
    event: Some(event),
    dependency: None,
    rule,
    start_rule,
    calendar,
    extension,
  }
}

///|
/// Define a task that starts at another task's adjusted result.
pub fn BatchTask::after(
  name~ : String,
  dependency~ : String,
  rule~ : DateRule,
  start_rule~ : StartDateRule,
  calendar~ : Calendar,
  extension~ : ExtensionPolicy,
) -> BatchTask {
  {
    name,
    event: None,
    dependency: Some(dependency),
    rule,
    start_rule,
    calendar,
    extension,
  }
}

///|
/// Start an empty batch.
pub fn BatchDeadline::new() -> BatchDeadline {
  { tasks: [] }
}

///|
/// Add a uniquely named task without mutating the original batch.
pub fn BatchDeadline::add(
  self : BatchDeadline,
  task : BatchTask,
) -> Result[BatchDeadline, BatchError] {
  if task.name.length() == 0 {
    return Err(BatchDuplicate(task.name))
  }
  for current in self.tasks {
    if current.name == task.name {
      return Err(BatchDuplicate(task.name))
    }
  }
  let tasks = self.tasks.copy()
  tasks.push(task)
  Ok({ tasks, })
}

///|
/// Calculate all tasks in dependency order.
pub fn BatchDeadline::calculate(
  self : BatchDeadline,
  context : EventContext,
) -> Result[BatchResult, BatchError] {
  if self.tasks.is_empty() {
    return Err(BatchEmpty)
  }
  let states = Array::make(self.tasks.length(), 0)
  let results = Array::new()
  let mut index = 0
  while index < self.tasks.length() {
    match calculate_task(self, context, index, states, results) {
      Ok(_) => ()
      Err(error) => return Err(error)
    }
    index = index + 1
  }
  Ok({ entries: results.copy() })
}

///|
fn task_index(tasks : Array[BatchTask], name : String) -> Int {
  let mut index = 0
  while index < tasks.length() {
    if tasks[index].name == name {
      return index
    }
    index = index + 1
  }
  -1
}

///|
fn result_index(results : Array[BatchResultEntry], name : String) -> Int {
  let mut index = 0
  while index < results.length() {
    if results[index].name == name {
      return index
    }
    index = index + 1
  }
  -1
}

///|
fn calculate_task(
  batch : BatchDeadline,
  context : EventContext,
  index : Int,
  states : Array[Int],
  results : Array[BatchResultEntry],
) -> Result[Unit, BatchError] {
  if states[index] == 2 {
    return Ok(())
  }
  let task = batch.tasks[index]
  if states[index] == 1 {
    return Err(BatchCycle(task.name))
  }
  states[index] = 1
  let start = match task.dependency {
    Some(dependency) => {
      let dependency_index = task_index(batch.tasks, dependency)
      if dependency_index < 0 {
        return Err(BatchMissingDependency(dependency))
      }
      match calculate_task(batch, context, dependency_index, states, results) {
        Ok(_) => ()
        Err(error) => return Err(error)
      }
      let result_index = result_index(results, dependency)
      if result_index < 0 {
        return Err(BatchMissingDependency(dependency))
      }
      results[result_index].result.adjusted_date()
    }
    None =>
      match task.event {
        Some(event) =>
          match context.resolve(event) {
            Ok(date) => date
            Err(error) => return Err(BatchEventFailure(error))
          }
        None => return Err(BatchMissingDependency(task.name))
      }
  }
  let deadline = Deadline::new(
    start_date=start,
    rule=task.rule,
    start_rule=task.start_rule,
    calendar=task.calendar,
    extension=task.extension,
  )
  let result = match deadline.calculate() {
    Ok(value) => value
    Err(error) => return Err(BatchDeadlineFailure(error))
  }
  results.push({ name: task.name, result })
  states[index] = 2
  Ok(())
}

///|
/// Return task names in deterministic calculation order.
pub fn BatchResult::ordered(self : BatchResult) -> Array[String] {
  [
    for entry in self.entries => entry.name
  ]
}

///|
/// Look up one calculated task.
pub fn BatchResult::get(self : BatchResult, name : String) -> DeadlineResult? {
  let index = result_index(self.entries, name)
  if index < 0 {
    None
  } else {
    Some(self.entries[index].result)
  }
}

///|
/// Render a compact audit summary for the complete batch.
pub fn BatchResult::explain(self : BatchResult) -> String {
  let mut output = ""
  for entry in self.entries {
    output = output +
      entry.name +
      ": " +
      entry.result.adjusted_date().to_string() +
      "\n"
  }
  output
}
