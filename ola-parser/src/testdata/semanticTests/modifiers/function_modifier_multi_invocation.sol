contract C {
    modifier repeat(bool twice) {
        if (twice) _;
        _;
    }

    fn f(bool twice) public repeat(twice) -> (u256 r) {
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
// f(bool): false -> 1
// f(bool): true -> 2
