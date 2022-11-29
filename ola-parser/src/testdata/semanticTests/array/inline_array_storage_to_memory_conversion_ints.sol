contract C {
    fn f()  -> (u256 x, u256 y) {
        x = 3;
        y = 6;
        u256[2] memory z = [x, y];
        return (z[0], z[1]);
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 3, 6
