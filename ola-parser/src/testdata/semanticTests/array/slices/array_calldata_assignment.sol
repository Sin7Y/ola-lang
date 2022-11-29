contract C {
    fn f(u256[]  x, u256[]  y, u256 i)  -> (u256) {
        x = y;
        return x[i];
    }
}
// ====
// compileViaYul: also
// compileToEwasm: also
// ----
// f(u256[],u256[],u256): 0x60, 0xA0, 1, 1, 0, 2, 1, 2 -> 2
