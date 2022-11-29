contract C {
    fn add(uint16 a, uint16 b)  -> (uint16) {
        unchecked {
            return a + b;
        }
    }

    fn f(uint16 a)  -> (uint16) {
        return add(a, 0x100) + 0x100;
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f(uint16): 7 -> 0x0207
// f(uint16): 0xffff -> 511
// f(uint16): 0xfeff -> FAILURE, hex"4e487b71", 0x11
