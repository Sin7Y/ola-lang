contract C {
    int constant a = 7;
    int constant b = 3;
    int constant c = a / b;
    int constant d = (-a) / b;
    fn f()  -> (u256, int, u256, int) {
        u256[c] memory x;
        u256[-d] memory y;
        return (x.length, c, y.length, -d);
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 2, 2, 2, 2
