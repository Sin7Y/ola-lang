contract C {
  struct S {
    u256 a;
  }

  fn f() external -> (u256) {
    S memory s = S(1);
    return s.a;
  }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 1
