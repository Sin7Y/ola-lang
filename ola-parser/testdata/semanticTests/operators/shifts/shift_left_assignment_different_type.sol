contract C {
    fn f(u256 a, uint8 b)  -> (u256) {
        a <<= b;
        return a;
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f(u256,uint8): 0x4266, 0x0 -> 0x4266
// f(u256,uint8): 0x4266, 0x8 -> 0x426600
// f(u256,uint8): 0x4266, 0x10 -> 0x42660000
// f(u256,uint8): 0x4266, 0x11 -> 0x84cc0000
// f(u256,uint8): 0x4266, 0xf0 -> 0x4266000000000000000000000000000000000000000000000000000000000000
