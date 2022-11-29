contract C {
    fn _()  -> (u256) {
        return 88;
    }

    fn g()  -> (u256){
        return _();
    }

    fn h()  -> (u256) {
        _;
        return 33;
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// _() -> 88
// g() -> 88
// h() -> 33
