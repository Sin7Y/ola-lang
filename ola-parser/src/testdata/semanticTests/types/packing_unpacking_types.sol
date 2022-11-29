contract test {
    fn run(bool a, u32 b, u64 c)  ->(u256 y) {
        if (a) y = 1;
        y = y * 0x100000000 | ~b;
        y = y * 0x10000000000000000 | ~c;
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// run(bool,u32,u64): true, 0x0f0f0f0f, 0xf0f0f0f0f0f0f0f0
// -> 0x0000000000000000000000000000000000000001f0f0f0f00f0f0f0f0f0f0f0f
