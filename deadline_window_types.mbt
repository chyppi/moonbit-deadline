///|
pub enum WindowError {
  WindowReversed
  WindowOutOfRange
} derive(Debug, Eq, Compare)

///|
/// A closed interval used for SLA windows and reporting periods.
pub struct DeadlineWindow {
  start : Date
  end : Date
}

///|
pub fn DeadlineWindow::new(
  start~ : Date,
  end~ : Date,
) -> Result[DeadlineWindow, WindowError] {
  if start > end {
    Err(WindowReversed)
  } else {
    Ok({ start, end })
  }
}
