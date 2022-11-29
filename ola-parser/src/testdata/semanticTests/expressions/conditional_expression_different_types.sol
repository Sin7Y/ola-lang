contract test {
    fn f(bool cond)  -> (u256) {
        u32 x = 0xcd;
        u32 y = 0xabab;
        return cond ? x : y;
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f(bool): true -> 0xcd
// f(bool): false -> 0xabab
