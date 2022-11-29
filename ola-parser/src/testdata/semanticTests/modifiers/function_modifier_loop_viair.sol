contract C {
    modifier repeat(u256 count) {
        u256 i;
        for (i = 0; i < count; ++i) _;
    }

    fn f() public repeat(10) -> (u256 r) {
        r += 1;
    }
}
// ====
// compileViaYul: true
// compileToEwasm: also
// ----
// f() -> 1
