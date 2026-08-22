///|
test "calendar catalog selects a named version and preserves insertion order" {
  let catalog = CalendarCatalog::new()
    .add(
      Calendar::new(
        name="cn",
        version="2026",
        weekend=WeekendPolicy::saturday_sunday(),
        holidays=[],
        extra_workdays=[],
      ),
    )
    .unwrap()
    .add(
      Calendar::new(
        name="us",
        version="2026",
        weekend=WeekendPolicy::saturday_sunday(),
        holidays=[],
        extra_workdays=[],
      ),
    )
    .unwrap()
  inspect(catalog.names()[0], content="cn@2026")
  inspect(catalog.find("us", "2026").unwrap().name(), content="us")
}

///|
test "calendar catalog rejects duplicate identity and missing lookup" {
  let calendar = Calendar::standard()
  let catalog = CalendarCatalog::new().add(calendar).unwrap()
  match catalog.add(Calendar::standard()) {
    Err(CatalogDuplicate(name)) => inspect(name, content="standard@builtin")
    _ => inspect(false, content="true")
  }
  match catalog.find("missing", "1") {
    None => inspect(true, content="true")
    Some(_) => inspect(false, content="true")
  }
}

///|
test "calendar catalog can validate every registered calendar" {
  let catalog = CalendarCatalog::new()
    .add(Calendar::standard())
    .unwrap()
    .add(
      Calendar::new(
        name="custom",
        version="1",
        weekend=WeekendPolicy::friday_saturday(),
        holidays=[],
        extra_workdays=[],
      ),
    )
    .unwrap()
  match catalog.validate() {
    Ok(_) => inspect(true, content="true")
    Err(_) => inspect(false, content="true")
  }
}
