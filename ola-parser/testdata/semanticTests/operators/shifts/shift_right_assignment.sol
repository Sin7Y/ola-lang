contract C {
    fn f(u256 a, u256 b)  -> (u256) {
        a >>= b;
        return a;
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f(u256,u256): 0x4266, 0x0 -> 0x4266
// f(u256,u256): 0x4266, 0x8 -> 0x42
// f(u256,u256): 0x4266, 0x10 -> 0
// f(u256,u256): 0x4266, 0x11 -> 0
