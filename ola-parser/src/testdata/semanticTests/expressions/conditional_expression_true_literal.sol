contract test {
    fn f()  ->(u256 d) {
        return true ? 5 : 10;
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 5
