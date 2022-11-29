contract A {
    fn f()  virtual -> (u256) {
        return 42;
    }
}

interface I {
    fn f() external -> (u256);
}

contract B is A, I {
    fn f() override(A, I)  -> (u256) {
        // I.f() is before A.f() in the C3 linearized order
        // but it has no implementation.
        return super.f();
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 42
