///|
/// Start a cross-calendar deadline comparison.
pub fn DeadlineMatrix::new(
  start~ : Date,
  rule~ : DateRule,
  start_rule~ : StartDateRule,
  extension~ : ExtensionPolicy,
) -> DeadlineMatrix {
  { start, rule, start_rule, extension, scenarios: [] }
}

///|
/// Add a named calendar scenario.
pub fn DeadlineMatrix::add_calendar(
  self : DeadlineMatrix,
  name : String,
  calendar : Calendar,
) -> Result[DeadlineMatrix, MatrixError] {
  for scenario in self.scenarios {
    if scenario.name == name {
      return Err(MatrixDuplicate(name))
    }
  }
  let scenarios = self.scenarios.copy()
  scenarios.push({ name, calendar })
  Ok({ ..self, scenarios, })
}

///|
/// Calculate scenarios in insertion order.
pub fn DeadlineMatrix::calculate(
  self : DeadlineMatrix,
) -> Result[MatrixResult, MatrixError] {
  if self.scenarios.is_empty() {
    return Err(MatrixEmpty)
  }
  let entries : Array[MatrixEntry] = Array::new()
  for scenario in self.scenarios {
    let deadline = Deadline::new(
      start_date=self.start,
      rule=self.rule,
      start_rule=self.start_rule,
      calendar=scenario.calendar,
      extension=self.extension,
    )
    match deadline.calculate() {
      Ok(result) => entries.push({ name: scenario.name, result })
      Err(error) => return Err(MatrixDeadlineFailure(error))
    }
  }
  Ok({ entries, })
}

///|
fn matrix_index(entries : Array[MatrixEntry], name : String) -> Int {
  let mut index = 0
  while index < entries.length() {
    if entries[index].name == name {
      return index
    }
    index = index + 1
  }
  -1
}

///|
/// Return scenario names in calculation order.
pub fn MatrixResult::ordered(self : MatrixResult) -> Array[String] {
  [
    for entry in self.entries => entry.name
  ]
}

///|
/// Look up one scenario result.
pub fn MatrixResult::get(self : MatrixResult, name : String) -> DeadlineResult? {
  let index = matrix_index(self.entries, name)
  if index < 0 {
    None
  } else {
    Some(self.entries[index].result)
  }
}

///|
/// Difference in adjusted calendar days between two scenarios.
pub fn MatrixResult::delta(
  self : MatrixResult,
  left : String,
  right : String,
) -> Result[Int, MatrixError] {
  let left_index = matrix_index(self.entries, left)
  let right_index = matrix_index(self.entries, right)
  if left_index < 0 {
    return Err(MatrixMissing(left))
  }
  if right_index < 0 {
    return Err(MatrixMissing(right))
  }
  let left_date = self.entries[left_index].result.adjusted_date()
  let right_date = self.entries[right_index].result.adjusted_date()
  Ok(
    days_from_civil(right_date.year, right_date.month, right_date.day) -
    days_from_civil(left_date.year, left_date.month, left_date.day),
  )
}
