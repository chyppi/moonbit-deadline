///|
/// Create an empty event context.
pub fn EventContext::new() -> EventContext {
  { entries: [] }
}

///|
/// Create a fixed-date event definition.
pub fn EventSpec::fixed(date : Date) -> EventSpec {
  Fixed(date)
}

///|
/// Create an event offset by calendar days from another event.
pub fn EventSpec::after(name : String, offset : Int) -> EventSpec {
  After(name, offset)
}

///|
/// Add a definition without mutating the original context.
pub fn EventContext::insert(
  self : EventContext,
  name : String,
  spec : EventSpec,
) -> Result[EventContext, EventError] {
  if name.length() == 0 {
    return Err(EventDuplicate(name))
  }
  for entry in self.entries {
    if entry.name == name {
      return Err(EventDuplicate(name))
    }
  }
  match spec {
    After(_, offset) if offset < 0 => Err(EventNegativeOffset(name))
    _ => {
      let entries = self.entries.copy()
      entries.push({ name, spec })
      Ok({ entries, })
    }
  }
}

///|
/// Resolve a named event and all of its dependencies.
pub fn EventContext::resolve(
  self : EventContext,
  name : String,
) -> Result[Date, EventError] {
  resolve_event(self, name, [])
}

///|
fn find_event(context : EventContext, name : String) -> EventSpec? {
  for entry in context.entries {
    if entry.name == name {
      return Some(entry.spec)
    }
  }
  None
}

///|
fn contains_name(names : Array[String], name : String) -> Bool {
  for item in names {
    if item == name {
      return true
    }
  }
  false
}

///|
fn resolve_event(
  context : EventContext,
  name : String,
  stack : Array[String],
) -> Result[Date, EventError] {
  if contains_name(stack, name) {
    return Err(EventCycle(name))
  }
  let spec = match find_event(context, name) {
    Some(value) => value
    None => return Err(EventMissing(name))
  }
  let next_stack = stack.copy()
  next_stack.push(name)
  match spec {
    Fixed(date) => Ok(date)
    After(parent, offset) =>
      match resolve_event(context, parent, next_stack) {
        Ok(date) =>
          match date.try_add_days(offset) {
            Ok(result) => Ok(result)
            Err(error) => Err(EventDateFailure(error))
          }
        Err(error) => Err(error)
      }
  }
}

///|
/// Create a deadline that starts at a named event.
pub fn EventDeadline::new(
  event~ : String,
  rule~ : DateRule,
  start_rule~ : StartDateRule,
  calendar~ : Calendar,
  extension~ : ExtensionPolicy,
) -> EventDeadline {
  { event, rule, start_rule, calendar, extension }
}

///|
/// Resolve the event and run the standard deadline engine.
pub fn EventDeadline::calculate(
  self : EventDeadline,
  context : EventContext,
) -> Result[DeadlineResult, EventDeadlineError] {
  let start = match context.resolve(self.event) {
    Ok(date) => date
    Err(error) => return Err(Event(error))
  }
  let deadline = Deadline::new(
    start_date=start,
    rule=self.rule,
    start_rule=self.start_rule,
    calendar=self.calendar,
    extension=self.extension,
  )
  match deadline.calculate() {
    Ok(result) => Ok(result)
    Err(error) => Err(Deadline(error))
  }
}
