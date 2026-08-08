///|
fn main {
  match execute(@env.args()) {
    Ok(output) => println(output)
    Err(error) => {
      println("error: " + cli_error_message(error))
      println(
        "usage: moon run cmd/deadline -- --start YYYY-MM-DD --rule calendar-days:10",
      )
      panic()
    }
  }
}
