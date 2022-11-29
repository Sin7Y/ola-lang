contract A {
    fn f()  virtual -> (u256 r) {
        return 1;
    }
}


contract B is A {
    fn f()  virtual override -> (u256 r) {
        return ((super).f)() | 2;
    }
}


contract C is A {
    fn f()  virtual override -> (u256 r) {
        return ((super).f)() | 4;
    }
}


contract D is B, C {
    fn f()  override(B, C) -> (u256 r) {
        return ((super).f)() | 8;
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 15
