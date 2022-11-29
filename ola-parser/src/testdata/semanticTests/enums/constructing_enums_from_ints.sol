contract c {
    enum Truth {False, True}

    fn test()  -> (u256) {
        return u256(Truth(uint8(0x1)));
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// test() -> 1
