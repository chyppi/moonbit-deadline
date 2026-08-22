///|
pub struct BenchmarkCase {
  name : String
  iterations : Int
  checksum : Int
}

///|
pub fn BenchmarkCase::new(
  name~ : String,
  iterations~ : Int,
  checksum~ : Int,
) -> BenchmarkCase {
  { name, iterations, checksum }
}

///|
pub fn BenchmarkCase::line(self : BenchmarkCase) -> String {
  "case=" +
  self.name +
  " iterations=" +
  self.iterations.to_string() +
  " checksum=" +
  self.checksum.to_string()
}
