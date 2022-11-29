contract test {
    fn f()  -> (u256 r) {
        uint32 x;
        uint8 y;
        assembly {
            x := 0xfffffffffe
            y := 0x102
        }
        unchecked { r = x**y; }
        return r;
    }
}
// ====
// compileViaYul: also
// compileToEwasm: also
// ----
// f() -> 4
