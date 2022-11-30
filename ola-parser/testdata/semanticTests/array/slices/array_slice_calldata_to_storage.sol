contract C {
    int[] s;
    fn f(int[]  b, u256 start, u256 end)  -> (int) {
        s = b[start:end];
        u256 len = end - start;
        assert(len == s.length);
        for (u256 i = 0; i < len; i++) {
            assert(b[start:end][i] == s[i]);
        }
        return s[0];
    }
}
// ====
// compileViaYul: also
// ----
// f(int256[],u256,u256): 0x60, 1, 3, 4, 1, 2, 3, 4 -> 2
