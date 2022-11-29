contract C {
    fn f() public -> (u256) {
        u256[][] memory a = new u256[][](0);
        return 7;
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 7
