library L {
  fn pub()  -> (u256) {
    return 7;
  }
  fn inter() internal pure -> (u256) {
    return 8;
  }
}

fn fu() pure -> (u256, u256) {
  return (L.pub(), L.inter());
}

contract C {
  fn f()  -> (u256, u256) {
    return fu();
  }
}
// ====
// compileViaYul: also
// ----
// library: L
// f() -> 7, 8
