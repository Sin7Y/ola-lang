contract test {
    fn run(u256 x1, u256 x2, u256 x3)  ->(u256 y) {
        u32 a = 0x1; u32 b = 0x10; u32 c = 0x100;
        y = a + b + c + x1 + x2 + x3;
        y += b + x2;
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// run(u256,u256,u256): 0x1000, 0x10000, 0x100000 -> 0x121121
