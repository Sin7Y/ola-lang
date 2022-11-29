contract C {
  fn f()  -> (u256 y) {
    unchecked{{
        u256 max = type(u256).max;
        u256 x = max + 1;
        y = x;
    }}
  }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 0x00
