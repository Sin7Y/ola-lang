fn fun1()  { }
fn fun2() internal { }
// ----
// SyntaxError 4126: (0-26): Free functions cannot have visibility.
// SyntaxError 4126: (27-55): Free functions cannot have visibility.
