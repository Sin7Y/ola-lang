contract A {
    u256 x = 1;
    u256 y = 2;

    fn a()  -> (u256 x) {
        x = A.y;
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// a() -> 2
