contract C {
    u256 constant a = 12;
    u256 constant b = 10;

    fn f()  -> (u256, u256) {
        u256[(a / b) * b] memory x;
        return (x.length, (a / b) * b);
    }
}
// ====
// compileToEwasm: also
// compileViaYul: true
// ----
// constructor() ->
// f() -> 0x0a, 0x0a
