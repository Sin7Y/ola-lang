contract test {
    fn f()  ->(int d) { return (-2) ** 3; }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> -8
