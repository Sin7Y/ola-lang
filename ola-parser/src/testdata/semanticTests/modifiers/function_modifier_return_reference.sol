contract C {
    modifier m1(u256 value) {
        _;
    }
    modifier m2(u256 value) {
        _;
    }

    fn f()  m1(x = 2) m2(y = 3) -> (u256 x, u256 y) {
    }
}
// ====
// compileViaYul: also
// ----
// f() -> 2, 3
