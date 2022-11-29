contract C {
    modifier repeat(bool twice) {
        if (twice) _;
        _;
    }

    fn f(bool twice) public repeat(twice) -> (u256 r) {
        r += 1;
    }
}
// ====
// compileViaYul: true
// compileToEwasm: also
// ----
// f(bool): false -> 1
// f(bool): true -> 1
