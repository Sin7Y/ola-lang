// Used to trigger assert
contract s{}
fn f() {s[:][];}
// ----
// TypeError 1760: (53-57): Types cannot be sliced.
