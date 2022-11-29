contract test {
    fn a()  ->(u256 n) { return 0; }
    fn b()  ->(u256 n) { return 1; }
    fn c()  ->(u256 n) { return 2; }
    fn f()  ->(u256 n) { return 3; }
}
// ====
// allowNonExistingFunctions: true
// compileToEwasm: also
// compileViaYul: also
// ----
// a() -> 0
// b() -> 1
// c() -> 2
// f() -> 3
// i_am_not_there() -> FAILURE
