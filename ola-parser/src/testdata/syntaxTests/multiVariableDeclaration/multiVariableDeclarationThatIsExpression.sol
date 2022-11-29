contract C {
  struct S { fn() returns (S storage)[] x; }
  S s;
  fn f() internal pure returns (uint, uint, uint, S storage, uint, uint) {
    (,,,s.x[2](),,) = f();
  }
}
// ----
// TypeError 4247: (160-168): Expression has to be an lvalue.
