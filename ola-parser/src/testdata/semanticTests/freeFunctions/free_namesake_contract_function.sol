fn f() pure -> (u256) { return 1337; }
contract C {
  fn f()  -> (u256) {
    return f();
  }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> FAILURE
