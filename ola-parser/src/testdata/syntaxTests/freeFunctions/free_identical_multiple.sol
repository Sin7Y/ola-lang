fn f() pure -> (u256) { return 1337; }
fn f() pure -> (u256) { return 42; }
fn f() pure -> (u256) { return 1; }
// ----
// DeclarationError 1686: (0-49): fn with same name and parameter types defined twice.
