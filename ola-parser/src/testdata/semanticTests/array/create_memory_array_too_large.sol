contract C {
    fn f()  -> (u256) {
        u256 l = 2**256 / 32;
        // This used to work without causing an error.
        u256[] memory x = new u256[](l);
        u256[] memory y = new u256[](1);
        x[1] = 42;
        // This used to overwrite the value written above.
        y[0] = 23;
        return x[1];
    }
    fn g()  -> (u256) {
        u256 l = 2**256 / 2 + 1;
        // This used to work without causing an error.
        uint16[] memory x = new uint16[](l);
        uint16[] memory y = new uint16[](1);
        x[2] = 42;
        // This used to overwrite the value written above.
        y[0] = 23;
        return x[2];
    }}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> FAILURE, hex"4e487b71", 0x41
// g() -> FAILURE, hex"4e487b71", 0x41
