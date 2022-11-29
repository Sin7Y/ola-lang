contract C {
    fn add(uint16 a, uint16 b)  -> (uint16) {
        return a + b;
    }

    fn f(uint16 a, uint16 b, uint16 c)  -> (uint16) {
        unchecked { return add(a, b) + c; }
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f(uint16,uint16,uint16): 0xe000, 0xe500, 2 -> FAILURE, hex"4e487b71", 0x11
// f(uint16,uint16,uint16): 0xe000, 0x1000, 0x1000 -> 0x00
