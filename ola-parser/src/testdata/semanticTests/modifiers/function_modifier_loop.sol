contract C {
    modifier repeat(u256 count) {
        u256 i;
        for (i = 0; i < count; ++i) _;
    }

    fn f() public repeat(10) -> (u256 r) {
        r += 1;
    }
}
// via yul disabled because the return variables are
// fresh variables each time, while in the old code generator,
// they share a stack slot when the fn is
// invoked multiple times via `_`.

// ====
// compileViaYul: false
// ----
// f() -> 10
