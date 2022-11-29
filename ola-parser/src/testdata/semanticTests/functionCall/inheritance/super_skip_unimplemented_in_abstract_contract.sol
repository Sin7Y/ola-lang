contract A {
    fn f()  virtual -> (u256) {
        return 42;
    }
}

abstract contract I {
    fn f() external virtual -> (u256);
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
