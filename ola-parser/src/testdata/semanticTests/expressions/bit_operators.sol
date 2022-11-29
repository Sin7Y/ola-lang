contract test {
    uint8 x;
    u256 v;
    fn f()  -> (u256 x, u256 y, u256 z) {
        uint16 a;
        uint32 b;
        assembly {
            a := 0x0f0f0f0f0f
            b := 0xff0fff0fff
        }
        x = a & b;
        y = a | b;
        z = a ^ b;
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f() -> 3855, 268374015, 268370160
