///|
fn days_from_civil(year : Int, month : Int, day : Int) -> Int {
  let adjusted_year = year - (if month <= 2 { 1 } else { 0 })
  let era = adjusted_year / 400
  let year_of_era = adjusted_year - era * 400
  let month_prime = month + (if month > 2 { -3 } else { 9 })
  let day_of_year = (153 * month_prime + 2) / 5 + day - 1
  let day_of_era = year_of_era * 365 +
    year_of_era / 4 -
    year_of_era / 100 +
    day_of_year
  era * 146097 + day_of_era - 719468
}

///|
fn civil_from_days(serial : Int) -> (Int, Int, Int) {
  let shifted = serial + 719468
  let era = shifted / 146097
  let day_of_era = shifted - era * 146097
  let year_of_era = (
      day_of_era - day_of_era / 1460 + day_of_era / 36524 - day_of_era / 146096
    ) /
    365
  let year_base = year_of_era + era * 400
  let day_of_year = day_of_era -
    (365 * year_of_era + year_of_era / 4 - year_of_era / 100)
  let month_prime = (5 * day_of_year + 2) / 153
  let day = day_of_year - (153 * month_prime + 2) / 5 + 1
  let month = month_prime + (if month_prime < 10 { 3 } else { -9 })
  let year = year_base + (if month <= 2 { 1 } else { 0 })
  (year, month, day)
}

///|
pub fn Date::add_days(self : Date, count : Int) -> Date {
  let (year, month, day) = civil_from_days(
    days_from_civil(self.year, self.month, self.day) + count,
  )
  { year, month, day }
}

///|
pub fn Date::add_months(self : Date, count : Int) -> Date {
  let zero_based = self.year * 12 + self.month - 1 + count
  let year = zero_based / 12
  let month = zero_based % 12 + 1
  let day = Int::min(self.day, days_in_month(year, month))
  { year, month, day }
}

///|
pub fn Date::add_years(self : Date, count : Int) -> Date {
  let year = self.year + count
  let day = Int::min(self.day, days_in_month(year, self.month))
  { year, month: self.month, day }
}
