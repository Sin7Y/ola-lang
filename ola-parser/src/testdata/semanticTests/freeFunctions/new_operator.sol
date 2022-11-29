contract C {
  u256  x = 2;
}

fn test() -> (u256) {
  return (new C()).x();
}

contract D {
  fn f()  -> (u256) {
    return test();
  }
}
// ====
// compileViaYul: also
// ----
// f() -> 2
// gas legacy: 101626
