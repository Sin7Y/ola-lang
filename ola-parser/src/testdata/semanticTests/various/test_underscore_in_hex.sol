contract test {
    fn f(bool cond)  -> (u256) {
        uint32 x = 0x1234_ab;
        u256 y = 0x1234_abcd_1234;
        return cond ? x : y;
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// f(bool): true -> 0x1234ab
// f(bool): false -> 0x1234abcd1234
