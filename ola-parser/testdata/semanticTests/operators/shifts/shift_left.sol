contract C {
    fn f(u256 a, u256 b)  -> (u256) {
        return a << b;
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f(u256,u256): 0x4266, 0x0 -> 0x4266
// f(u256,u256): 0x4266, 0x8 -> 0x426600
// f(u256,u256): 0x4266, 0x10 -> 0x42660000
// f(u256,u256): 0x4266, 0x11 -> 0x84cc0000
// f(u256,u256): 0x4266, 0xf0 -> 0x4266000000000000000000000000000000000000000000000000000000000000
// f(u256,u256): 0x4266, 0x100 -> 0
