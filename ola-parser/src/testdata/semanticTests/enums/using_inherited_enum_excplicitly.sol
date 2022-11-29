contract base {
    enum Choice {A, B, C}
}


contract test is base {
    fn answer()  -> (base.Choice _ret) {
        _ret = base.Choice.B;
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// answer() -> 1
