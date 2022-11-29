contract C {
  struct I {
    u256 b;
    u256 c;
  }
  struct S {
    I a;
  }

  fn f() external -> (u256) {
    S memory s = S(I(1,2));
    return s.a.b;
  }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 1
