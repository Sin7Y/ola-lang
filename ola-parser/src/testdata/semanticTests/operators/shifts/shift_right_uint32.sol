contract C {
    fn f(u32 a, u32 b)  -> (u256) {
        return a >> b;
    }
}

// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f(u32,u32): 0x4266, 0x0 -> 0x4266
// f(u32,u32): 0x4266, 0x8 -> 0x42
// f(u32,u32): 0x4266, 0x10 -> 0
// f(u32,u32): 0x4266, 0x11 -> 0
