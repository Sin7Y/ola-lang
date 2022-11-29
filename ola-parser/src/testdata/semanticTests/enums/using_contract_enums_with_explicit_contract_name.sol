contract test {
    enum Choice {A, B, C}

    fn answer()  -> (test.Choice _ret) {
        _ret = test.Choice.B;
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// answer() -> 1
