contract C {
  u256  x = 2;
}

fn test() -> (bool) {
  return type(C).runtimeCode.length > 20;
}

contract D {
  fn f()  -> (bool) {
    return test();
  }
}
// ====
// compileViaYul: also
// ----
// f() -> true
