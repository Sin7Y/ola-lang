fn add(u256 a, u256 b) pure -> (u256) {
  return a + b;
}

contract C {
  fn f(u256 x)  -> (u256) {
    return add(x, 2);
  }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f(u256): 7 -> 9
