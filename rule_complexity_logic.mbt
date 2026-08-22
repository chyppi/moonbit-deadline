///|
/// Count the rule node and all nested sequence nodes.
pub fn DateRule::node_count(self : DateRule) -> Int {
  match self {
    Sequence(rules) =>
      1 + rules.fold(init=0, (total, rule) => total + rule.node_count())
    _ => 1
  }
}

///|
/// Return the maximum nested sequence depth, with a leaf at depth zero.
pub fn DateRule::max_depth(self : DateRule) -> Int {
  match self {
    Sequence(rules) => {
      let mut deepest = 0
      for rule in rules {
        deepest = Int::max(deepest, rule.max_depth() + 1)
      }
      deepest
    }
    _ => 0
  }
}

///|
/// Check whether a rule tree includes a business-day operation.
pub fn DateRule::uses_business_days(self : DateRule) -> Bool {
  match self {
    BusinessDays(_) => true
    Sequence(rules) => {
      for rule in rules {
        if rule.uses_business_days() {
          return true
        }
      }
      false
    }
    _ => false
  }
}
