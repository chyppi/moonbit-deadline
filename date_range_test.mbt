///|
test "date range rejects reversed endpoints" {
  match
    DateRange::closed(
      start=Date::parse("2026-05-02").unwrap(),
      end=Date::parse("2026-05-01").unwrap(),
    ) {
    Ok(_) => inspect(false, content="true")
    Err(Reversed) => inspect(true, content="true")
    Err(_) => inspect(false, content="true")
  }
}

///|
test "date range intersection returns the closed overlap" {
  let left = DateRange::closed(
    start=Date::parse("2026-05-01").unwrap(),
    end=Date::parse("2026-05-05").unwrap(),
  ).unwrap()
  let right = DateRange::closed(
    start=Date::parse("2026-05-04").unwrap(),
    end=Date::parse("2026-05-08").unwrap(),
  ).unwrap()
  match left.intersection(right) {
    Ok(range) => {
      inspect(
        range.contains(Date::parse("2026-05-04").unwrap()),
        content="true",
      )
      inspect(
        range.contains(Date::parse("2026-05-05").unwrap()),
        content="true",
      )
      inspect(range.calendar_days(), content="2")
    }
    Err(_) => inspect(false, content="true")
  }
}

///|
test "date range single day contains the endpoint and counts one calendar day" {
  let range = DateRange::single(Date::parse("2026-08-10").unwrap())
  inspect(range.contains(Date::parse("2026-08-10").unwrap()), content="true")
  inspect(range.calendar_days(), content="1")
}

///|
test "date range union joins adjacent closed ranges" {
  let left = DateRange::closed(
    start=Date::parse("2026-05-01").unwrap(),
    end=Date::parse("2026-05-03").unwrap(),
  ).unwrap()
  let right = DateRange::closed(
    start=Date::parse("2026-05-04").unwrap(),
    end=Date::parse("2026-05-06").unwrap(),
  ).unwrap()
  match left.union(right) {
    Ok(range) => {
      inspect(
        range.contains(Date::parse("2026-05-01").unwrap()),
        content="true",
      )
      inspect(
        range.contains(Date::parse("2026-05-06").unwrap()),
        content="true",
      )
      inspect(range.calendar_days(), content="6")
    }
    Err(_) => inspect(false, content="true")
  }
}

///|
test "date range union rejects disjoint ranges" {
  let left = DateRange::closed(
    start=Date::parse("2026-05-01").unwrap(),
    end=Date::parse("2026-05-03").unwrap(),
  ).unwrap()
  let right = DateRange::closed(
    start=Date::parse("2026-05-05").unwrap(),
    end=Date::parse("2026-05-08").unwrap(),
  ).unwrap()
  match left.union(right) {
    Ok(_) => inspect(false, content="true")
    Err(NoIntersection) => inspect(true, content="true")
    Err(_) => inspect(false, content="true")
  }
}

///|
test "date range counts days across a month boundary" {
  let range = DateRange::closed(
    start=Date::parse("2026-01-30").unwrap(),
    end=Date::parse("2026-02-02").unwrap(),
  ).unwrap()
  inspect(range.calendar_days(), content="4")
}

///|
test "date range counts leap year days" {
  let range = DateRange::closed(
    start=Date::parse("2024-02-28").unwrap(),
    end=Date::parse("2024-03-01").unwrap(),
  ).unwrap()
  inspect(range.calendar_days(), content="3")
}

///|
test "date range counts business days with the standard weekend policy" {
  let calendar = Calendar::standard()
  let range = DateRange::closed(
    start=Date::parse("2026-08-07").unwrap(),
    end=Date::parse("2026-08-10").unwrap(),
  ).unwrap()
  inspect(range.business_days(calendar), content="2")
}

///|
test "date range honors holiday and extra-workday precedence" {
  let special = Date::parse("2026-08-10").unwrap()
  let calendar = Calendar::new(
    name="demo",
    version="2026.1",
    weekend=WeekendPolicy::saturday_sunday(),
    holidays=[special],
    extra_workdays=[special],
  )
  let range = DateRange::single(special)
  inspect(calendar.is_business_day(special), content="true")
  inspect(range.business_days(calendar), content="1")
}

///|
test "date range counts business days under a Friday Saturday weekend" {
  let calendar = Calendar::new(
    name="demo",
    version="2026.1",
    weekend=WeekendPolicy::friday_saturday(),
    holidays=[],
    extra_workdays=[],
  )
  let range = DateRange::closed(
    start=Date::parse("2026-08-06").unwrap(),
    end=Date::parse("2026-08-10").unwrap(),
  ).unwrap()
  inspect(range.business_days(calendar), content="3")
}
