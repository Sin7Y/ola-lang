fn f(u256) -> (u256) {
    return 2;
}
fn f(string memory) -> (u256) {
    return 3;
}

contract C {
  fn g()  -> (u256, u256) {
      return (f(2), f("abc"));
  }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// g() -> 2, 3
