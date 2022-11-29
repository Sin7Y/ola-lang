contract c {
    fn test(u256[8]  a, u256[]  b, u256[5]  c, u256 a_index, u256 b_index, u256 c_index)
             -> (u256 av, u256 bv, u256 cv) {
        av = a[a_index];
        bv = b[b_index];
        cv = c[c_index];
    }
}
// ====
// compileToEwasm: also
// compileViaYul: also
// ----
// test(u256[8],u256[],u256[5],u256,u256,u256): 1, 2, 3, 4, 5, 6, 7, 8, 0x220, 21, 22, 23, 24, 25, 0, 1, 2, 3, 11, 12, 13 -> 1, 12, 23
