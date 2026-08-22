///|
/// Create an empty calendar catalog.
pub fn CalendarCatalog::new() -> CalendarCatalog {
  { entries: [] }
}

///|
fn catalog_key(calendar : Calendar) -> String {
  calendar.name() + "@" + calendar.version()
}

///|
/// Add a calendar after validating its metadata.
pub fn CalendarCatalog::add(
  self : CalendarCatalog,
  calendar : Calendar,
) -> Result[CalendarCatalog, CatalogError] {
  match calendar.validate() {
    Ok(_) => ()
    Err(error) => return Err(CatalogInvalid(error))
  }
  let key = catalog_key(calendar)
  for entry in self.entries {
    if catalog_key(entry.calendar) == key {
      return Err(CatalogDuplicate(key))
    }
  }
  let entries = self.entries.copy()
  entries.push({ calendar, })
  Ok({ entries, })
}

///|
/// Find an exact name/version pair.
pub fn CalendarCatalog::find(
  self : CalendarCatalog,
  name : String,
  version : String,
) -> Calendar? {
  for entry in self.entries {
    if entry.calendar.name() == name && entry.calendar.version() == version {
      return Some(entry.calendar)
    }
  }
  None
}

///|
/// Return stable catalog identities in insertion order.
pub fn CalendarCatalog::names(self : CalendarCatalog) -> Array[String] {
  [
    for entry in self.entries => catalog_key(entry.calendar)
  ]
}

///|
/// Revalidate all calendars in the catalog.
pub fn CalendarCatalog::validate(
  self : CalendarCatalog,
) -> Result[Unit, CatalogError] {
  for entry in self.entries {
    match entry.calendar.validate() {
      Ok(_) => ()
      Err(error) => return Err(CatalogInvalid(error))
    }
  }
  Ok(())
}
