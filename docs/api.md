# API notes

The root package is intentionally small at the boundary and explicit in its data dependencies.

## Date

`Date::new` validates a Gregorian year, month and day. `Date::parse` accepts only `YYYY-MM-DD`; there is no implicit timezone or locale conversion. `add_days` uses serial-day arithmetic, while `add_months` and `add_years` clamp the day to the last valid day of the destination month.

## Calendar

`Calendar` combines a `WeekendPolicy`, holiday dates and extra workdays. The decision order is:

1. An extra workday is open, even when it is a weekend or appears in the holiday table.
2. A holiday is closed.
3. The weekend policy is applied.
4. All other dates are open.

This order models common “调休” data while making the precedence visible and testable. `next_business_day` and `previous_business_day` are inclusive search helpers; `advance_business_days` provides counted movement.

## Deadline

`Deadline::calculate` first evaluates the rule, records the natural result, then applies the selected `ExtensionPolicy`. `DateRule::Sequence` applies the start-date convention only to its first stage, so later stages begin at the previous stage's result. The returned `DeadlineResult` retains structured `CalculationStep` values as well as `explain()` text.

Negative rule counts are rejected. Calendar searches are bounded and report `CalendarError` instead of looping forever when a malformed calendar cannot provide a result.
