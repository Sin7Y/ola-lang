contract C {
    u256 public x;
    modifier m() {
        for (u256 i = 0; i < 10; i++) {
            _;
            ++x;
            return;
        }
    }

    fn f() public m m m -> (uint) {
        for (u256 i = 0; i < 10; i++) {
            ++x;
            return 42;
        }
    }
}
// ====
// compileViaYul: also
// compileToEwasm: also
// ----
// x() -> 0
// f() -> 42
// x() -> 4
