contract test {
    uint8 x;
    u256 v;
    fn f()  -> (u256 r) {
        u256 a = 6;
        r = a;
        r += (a++) * 0x10;
        r += (++a) * 0x100;
        v = 3;
        r += (v++) * 0x1000;
        r += (++v) * 0x10000;
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 0x053866
