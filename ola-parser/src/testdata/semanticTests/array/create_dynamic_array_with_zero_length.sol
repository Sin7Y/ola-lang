contract C {
    fn f()  -> (u256) {
        u256[][]  a = new u256[][](0);
        return 7;
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 7
