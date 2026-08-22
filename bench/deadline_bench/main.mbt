///|
fn parse_iterations(args : Array[String]) -> Int {
  let mut index = 0
  while index < args.length() {
    if args[index] == "--iterations" && index + 1 < args.length() {
      let text = args[index + 1]
      let mut value = 0
      let mut digit = 0
      while digit < text.length() {
        value = value * 10 + text.at(digit).to_int() - 48
        digit = digit + 1
      }
      return if value > 0 { value } else { 1 }
    }
    index = index + 1
  }
  100
}

///|
fn calendar_workload(iterations : Int) -> Int {
  let calendar = @deadline.Calendar::china_2026()
  let start = @deadline.Date::parse("2026-01-01").unwrap()
  let mut checksum = 0
  let mut index = 0
  while index < iterations {
    let date = start.add_days(index % 365)
    if calendar.is_business_day(date) {
      checksum = checksum + date.ordinal() + 1
    }
    index = index + 1
  }
  checksum
}

///|
fn deadline_workload(iterations : Int) -> Int {
  let calendar = @deadline.Calendar::china_2026()
  let mut checksum = 0
  let mut index = 0
  while index < iterations {
    let start = @deadline.Date::parse("2026-01-01")
      .unwrap()
      .add_days(index % 180)
    let deadline = @deadline.Deadline::new(
      start_date=start,
      rule=@deadline.DateRule::business_days(5),
      start_rule=@deadline.StartDateRule::exclude(),
      calendar~,
      extension=@deadline.ExtensionPolicy::following(),
    )
    checksum = checksum +
      deadline.calculate().unwrap().adjusted_date().ordinal()
    index = index + 1
  }
  checksum
}

///|
fn batch_workload(iterations : Int) -> Int {
  let context = @deadline.EventContext::new()
    .insert(
      "filed",
      @deadline.EventSpec::fixed(@deadline.Date::parse("2026-08-07").unwrap()),
    )
    .unwrap()
  let batch = @deadline.BatchDeadline::new()
    .add(
      @deadline.BatchTask::from_event(
        name="notice",
        event="filed",
        rule=@deadline.DateRule::business_days(2),
        start_rule=@deadline.StartDateRule::exclude(),
        calendar=@deadline.Calendar::standard(),
        extension=@deadline.ExtensionPolicy::no_extension(),
      ),
    )
    .unwrap()
  let mut checksum = 0
  let mut index = 0
  while index < iterations {
    let result = batch.calculate(context).unwrap()
    checksum = checksum +
      result.get("notice").unwrap().adjusted_date().ordinal()
    index = index + 1
  }
  checksum
}

///|
fn main {
  let iterations = parse_iterations(@env.args())
  let cases = [
    BenchmarkCase::new(
      name="calendar",
      iterations~,
      checksum=calendar_workload(iterations),
    ),
    BenchmarkCase::new(
      name="deadline",
      iterations~,
      checksum=deadline_workload(iterations),
    ),
    BenchmarkCase::new(
      name="batch",
      iterations~,
      checksum=batch_workload(iterations),
    ),
  ]
  println(render_suite(cases))
}
