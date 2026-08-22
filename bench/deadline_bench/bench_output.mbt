///|
pub fn render_case(name : String, iterations : Int, checksum : Int) -> String {
  BenchmarkCase::new(name~, iterations~, checksum~).line()
}

///|
pub fn render_suite(cases : Array[BenchmarkCase]) -> String {
  let mut output = ""
  for item in cases {
    output = output + item.line() + "\n"
  }
  output
}
