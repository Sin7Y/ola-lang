contract C {
    fn f()  -> (uint8 x) {
        unchecked {
            return uint8(0)**uint8(uint8(2)**uint8(8));
        }
    }
}

// ====
// compileViaYul: also
// compileToEwasm: also
// ----
// f() -> 0x1
