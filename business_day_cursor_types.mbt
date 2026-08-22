///|
pub enum CursorError {
  CursorInvalidCount
  CursorCalendarFailure(CalendarError)
} derive(Debug)

///|
/// A stateless cursor anchor for repeatable business-day navigation.
pub struct BusinessDayCursor {
  date : Date
  calendar : Calendar
}
