contract C {
  struct I {
    u256 b;
    u256 c;
    fn(u256)  -> (u256) x;
  }
  struct S {
    I a;
  }

  fn o(u256 a)  ->(u256) { return a+1; }

  fn f()  -> (u256) {
    S  s = S(I(1,2, this.o));
    return s.a.x(1);
  }
}



// ====
// compileViaYul: also
// ----
// f() -> 2
