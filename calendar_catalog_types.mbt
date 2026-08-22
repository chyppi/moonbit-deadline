///|
pub enum CatalogError {
  CatalogDuplicate(String)
  CatalogInvalid(CalendarValidationError)
} derive(Debug)

///|
struct CatalogEntry {
  calendar : Calendar
}

///|
/// A validated collection of named calendar versions.
pub struct CalendarCatalog {
  entries : Array[CatalogEntry]
}
