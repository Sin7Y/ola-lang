contract C {
    fn f()  -> (u256 a) {
        a = 0x4200;
        a >>= 8;
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 0x42
