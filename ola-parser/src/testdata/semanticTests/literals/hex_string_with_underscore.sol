contract C {
    fn f()  ->(bytes memory) {
        return hex"12_34_5678_9A";
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 32, 5, left(0x123456789A)
